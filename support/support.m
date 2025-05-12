#import "support_priv.h"
#import "hooks/hooks.h"
#import "fishhook/fishhook.h"
#import "litehook/litehook.h"
#import "memory/memory.h"

LS_STATIC NSString* _bundlePath;
LS_STATIC NSString* _bundleIdentifier = nil;
LS_STATIC NSString* _teamIdentifier = nil;
LS_STATIC NSArray*  _restrictedFiles = nil;
LS_STATIC NSArray*  _restrictedSchemes = nil;

LS_STATIC const char* _lsInitCallerPath = NULL;
LS_STATIC dispatch_once_t _lsInitCallerPathToken = 0;

void _supportinit_caller(const void *addr)
{
	dispatch_once(&_lsInitCallerPathToken, ^{
        _lsInitCallerPath = dyld_image_path_containing_address(addr);
    });
}
 
const char* _supportinit_callerpath(void) 
{ return _lsInitCallerPath; }

const char* SupportGetLibraryPath(void)
{
	LS_STATIC const char* libraryPath = NULL;
	LS_STATIC dispatch_once_t onceToken = 0;
	dispatch_once(&onceToken, ^{
		libraryPath = dyld_image_path_containing_address((void *)&SupportGetLibraryPath);
	});
	return libraryPath;
}

// Credits to AeonLucid
// Ref: https://github.com/AeonLucid/SnapHide/blob/master/Tweak/Detections/dyld.xm
// I can't seem to get this to work RIP our emulator checks
// even with JIT i can't get this shi to work wtf
LS_IGNORE LS_STATIC
void hijackEnvironment(void) 
{
	for(char* *env = environ; *env != 0; env++)
	{
		LS_LOG("hijackEnvironment() non modifeid Env var %zu: %s", 0, *env);
	}

	const mach_header_t *header = NULL; //(const struct mach_header_64 *)_dyld_get_image_header(i);

	LS_LOG("hijackEnvironment() What image is at index 0?: %s", _dyld_get_image_name(0));
	for (uint32_t i = 0; i < _dyld_image_count(); i++) 
	{
		const char *path = _dyld_get_image_name(i);
		if(/*strcmp(path, [getExecutablePath() fileSystemRepresentation]) == 0 ||*/ strstr(path, "/FrameworkClientApp.app/FrameworkClientApp") != NULL)
		{
			LS_LOG("hijackEnvironment() Found image: %s executable %@", path, getExecutablePath());
			header = (const struct mach_header_64 *)_dyld_get_image_header(i);
		}
	}

	if(!header)
	{
		LS_LOG("hijackEnvironment() Bad header.");
		return;
	}

	//const mach_header_t *header = (const mach_header_t*) _dyld_get_image_header(0);
    
	/*
	unsigned long sectionSize = 0;
	uint8_t *sectionData = getsectiondata(header, "__DATA", "__got", &sectionSize);

	if (sectionData == NULL || sectionSize == 0) 
	{
        LS_LOG("getsectiondata() error: failed to get section");
        return;
    }

	intptr_t startAddress = (intptr_t)sectionData;
	intptr_t endAddress = startAddress + sectionSize;
	*/

    const struct section_64 *section = getsectbynamefromheader_64(header, "__DATA", "__got");
    if (section == NULL) 
	{
		LS_LOG("getsectbynamefromheader_64() error: failed to get section");
        return;
	}

    const intptr_t startAddress = (intptr_t)header + section->offset;
    const intptr_t endAddress = startAddress + section->size;
	const intptr_t targetAddress = (intptr_t)environ;
	char ***environptr = NULL;

	LS_LOG("hijackEnvironment() " LS_TOSTRING(startAddress) " 0x%llx " LS_TOSTRING(endAddress) " 0x%llx ", startAddress, endAddress);

	for (intptr_t addr = startAddress; addr < endAddress; addr += sizeof(void *)) {
		intptr_t *ptrOne = *(intptr_t **)addr;  // Dereference the address as a pointer to a pointer
		if (ptrOne != NULL) {
			intptr_t ptrTwo = *ptrOne;  // Dereference ptrOne to get the actual address
			if (ptrTwo == targetAddress) {  // Check if this address matches environ
				environptr = (char ***)addr;  // Found the environ pointer
				LS_LOG("hijackEnvironment() found environptr: %p", (void *)addr);
				break;
			}
		}
	}

#if 0
    for (intptr_t addr = startAddress; addr < endAddress; addr += sizeof(void *)) 
	{
        char ***candidate = (char ***)addr;
        
	if (candidate != NULL && memcmp(candidate, &environ[0], environSize) == 0) {
        LS_LOG("hijackEnvironment() found environptr: %p", candidate);
        environptr = candidate;
        break;
    }

		/*
		if (*candidate == targetAddress) 
		{
			LS_LOG("hijackEnvironment() found environptr: %p", candidate);
            environptr = (char ***)candidate;
            break;
        }
		*/
    }
	#endif

	if(!environptr) 
	{
		LS_LOG("highjackenviron() Failed to hijack environment");
		return; // abort
	}

    size_t count = 0;
    while (environ[count]) count++;

	// allocate a new buffer to hold our modified environ
	// newEnvironData should be static so it dosn't go out of scope.
	NSMutableData *newEnvironData = [NSMutableData dataWithLength:(count + 1) * sizeof(char *)];
    char **newEnviron = (char **)newEnvironData.mutableBytes;
    size_t newIndex = 0;

    for (size_t i = 0; i < count; i++) 
	{
		char *entry = environ[i];
        if (strstr(entry, "SIMULATOR_DEVICE_NAME") != NULL ||
            strstr(entry, "DYLD_INSERT_LIBRARIES") != NULL) continue; //skip
        newEnviron[newIndex++] = entry; // copy everything else
    }

    newEnviron[newIndex] = NULL;

	//_supportmem_protect(environptr, sizeof(void *), LS_VM_PROT_RW);
    // *environptr = newEnviron;
	//_supportmem_protect(environptr, sizeof(void *), VM_PROT_READ);

	// check for the modifications:
	for (size_t i = 0; i < count; i++) 
	{
		if (environ[i] != NULL) 
		{
			// Log the environment variable
			LS_LOG("Env var %zu: %s", i, environ[i]);
		}
	}
}

// Early enter to register our stuff
// LS_CTOR_(0) { dyld_register_funcs(); }

LS_STATIC 
void _support_invalidate_restricted_loadcommands(void)
{
	mach_header_t *mh = (mach_header_t *)_dyld_get_image_header(0);
	if(!mh) return;

	const struct load_command* lc = (const struct load_command*)((uintptr_t)mh + sizeof(mach_header_t));
	for (uint32_t i = 0; i < mh->ncmds; i++) 
	{
		if (lc->cmd == LC_LOAD_DYLIB || lc->cmd == LC_LOAD_WEAK_DYLIB) 
		{
			struct dylib_command* dylib_cmd = (struct dylib_command*)lc;
			char* dylib_name = (char*)dylib_cmd + dylib_cmd->dylib.name.offset;

			if(isCPathRestricted(dylib_name))
			{
				LS_LOG("SupportInvalidateRestrictedLoadCommands() detected: %s but iOS said 'fuck you!' read-only", dylib_name);
                //dylib_cmd->cmd = LC_ID_DYLIB; //spoof
				//strncpy(dylib_name, "masked", dylib_cmd->dylib.name.offset);

                
				//static uint32_t patch = LC_ID_DYLIB;

				/*
				void* address = (void *)&dylib_cmd->cmd;
				uintptr_t page_start = _supportmem_pagestart(address);
    			size_t page_size = _supportmem_pagesize(address, dylib_cmd->cmdsize);

				_supportmem_protect((void *)page_start, page_size, VM_PROT_READ|VM_PROT_WRITE);
				dylib_cmd->cmd = LC_ID_DYLIB;
				//if(!_supportmem_copy((void *)&dylib_cmd->cmd, (uint8_t *)&patch, sizeof(patch))) return;
				_supportmem_protect((void *)page_start, page_size, VM_PROT_READ);
                */
                
				static const char* patch = "@rpath/libPatched.dylib";
				LS_UNUSED(patch);
				//if(_supportmem_code_patch((void *)dylib_name, (uint8_t *)patch, strlen(patch)) != LS_PATCH_SUCCESS)
				{
					LS_LOG("_supportmem_code_patch: dylib_cmd->cmd failed!");
				}

				/*
				if(_supportmem_protect((void *)dylib_name, strlen(dylib_name), LS_VM_PROT_RWX))
				{
                	strncpy(dylib_name, patch, strlen(patch));
					_supportmem_protect((void *)dylib_name, strlen(dylib_name), VM_PROT_READ);
				}
				*/
			}
		}
		lc = (const struct load_command*)((uintptr_t)lc + lc->cmdsize);
	}
}

LS_STATIC 
BOOL _supportinitialize_config(SupportEntryInfo *info)
{
	if (LS_UNLIKELY(info == NULL))
	{
		LS_LOG("SupportInitialConfig() Invalid Argument: Expected non-NULL SupportEntryInfo, but received: " LS_TOSTRING(LSM_INVALID_ARGUMENTS));
		return NO;
	}

	_bundlePath = [getExecutablePath() stringByDeletingLastPathComponent];

	_bundlePath = getStandardizedPath(_bundlePath);

	if (info->bundleIdentifier != NULL)
	{
		_bundleIdentifier = [[NSString alloc] initWithCString:info->bundleIdentifier 
													 encoding:NSUTF8StringEncoding];
	}

	if (info->teamIdentifier != NULL)
	{
		_teamIdentifier = [[NSString alloc] initWithCString:info->teamIdentifier 
													 encoding:NSUTF8StringEncoding];
	}

    NSMutableArray *restrictedFiles = [NSMutableArray new];
	for (size_t i = 0; i < info->restrictedFileCount; i++)
	{
		[restrictedFiles addObject:[NSString stringWithUTF8String: info->restrictedFiles[i]]];
	}
	_restrictedFiles = [restrictedFiles copy];

	NSMutableArray *restrictedSchemes = [NSMutableArray arrayWithArray:@[@"cydia", @"undecimus", @"sileo", @"zbra", @"filza"]];
	for (size_t i = 0; i < info->restrictedURLSchemeCount; i++) {
		[restrictedSchemes addObject:[NSString stringWithUTF8String: info->restrictedURLSchemes[i]]];
	}
	_restrictedSchemes = [restrictedSchemes copy];

	return YES;
}

#pragma mark - libsupport export
 
void SupportInitialize(SupportEntryInfo* info)
{
	if(!_supportinitialize_config(info)) return;

	// TODO: maybe ugh
	// Allow the caller of SupportInitilize to bypass hook calls 
	// so that they don't receive sanitized data.
	_supportinit_caller(LS_CALLER_ADDRESS());

	LS_LOG("SupportGetLibraryPath(): %s", SupportGetLibraryPath());

	//this is wrong.
	//sandbox_hooks();
	//hijackEnvironment();

	SupportHookFlags hf = info->hookFlags;

	if(hf & SupportHookFlagDynamicLibraries)
	{
		LS_LOG("dyld");
		_supporthook_dyld();
	}

	if(hf & SupportHookFlagAntiProxyAndVPN)
	{
		LS_LOG("proxy");
		_supporthook_CFNetwork_antiproxy();
	}
	if(hf & SupportHookFlagFilesystem)
	{
		LS_LOG("filesystem");
		_supporthook_libc();
		_supporthook_NSFileManager();
	}
	if(hf & SupportHookFlagURLScheme)
	{
		LS_LOG("urlscheme");
		_supporthook_UIApplication();
	}
	if(hf & SupportHookFlagFoundation)
	{
		LS_LOG("foundation");
		_supporthook_NSBundle();
		_supporthook_NSData();
		_supporthook_NSString();
		_supporthook_NSURL();
		_supporthook_NSArray();
		_supporthook_NSDictionary();
		_supporthook_UIImage();
		_supporthook_NSProcessInfo_antiemulator();
	}
	if(hf & SupportHookFlagCoreFoundation)
	{
		LS_LOG("corefoundation");
		_supporthook_CFBundle();
	}
	if(hf & SupportHookFlagDeviceCheck)
	{
		LS_LOG("devicecheck");
		_supporthook_DeviceCheck();
	}
	if(hf & SupportHookFlagObjCRuntime)
	{
		LS_LOG("objc_runtime");
		_supporthook_objc_runtime();
	}
	
	if(hf & SupportHookFlagSecurity)
	{
		LS_LOG("security");
		_supporthook_SecTask();
	}
	if(hf & SupportHookFlagAntiDebugging)
	{
		LS_LOG("debug");
		_supporthook_libc_antidebug();
	}
	if(hf & SupportHookFlagSyscall)
	{
		LS_LOG("syscall");
		_supporthook_syscall();
	}
	if(hf & SupportHookFlagSymLookup)
	{
		LS_LOG("dlfcn");
		_supporthook_dyld_symlookup();
		_supporthook_dyld_symaddrlookup();
	}

	_support_invalidate_restricted_loadcommands();

	// spoof ourselves, confuse any malware detections?
    Dl_info self_info;
    dladdr((void *)SupportInitialize, &self_info);
	size_t page_size = getpagesize();
	uintptr_t base_addr = (uintptr_t)(self_info.dli_fbase);
	size_t prot_size = (size_t)((base_addr + page_size - 1) & ~(page_size - 1));
	_supportmem_protect((void*)base_addr, prot_size, (LSM_PROT_READ|LSM_PROT_EXEC));
}

void SupportHookSymbolEx(const char* symbol, void* replacement, void* *original) 
{
	# if 1
	struct rebinding rebindings[] = {  
		{
			.name = symbol,
			.replacement = replacement,
			.replaced = original
		}
	}; 

	rebind_symbols(rebindings, LS_ARRAYSIZE(rebindings));
	#else
	void *symaddr = dlsym(RTLD_DEFAULT, symbol);
	if(symaddr)
	{
		if(original)
		{
			*original = symaddr;
		}

		litehook_rebind_symbol(LITEHOOK_REBIND_GLOBAL, symaddr, replacement, NULL);
	}
	#endif
}

int SupportMemoryProtectEx(void *addr, size_t size, int protection)
{
	return _supportmem_protect(addr, size, protection);
}
 
int SupportHookFunctionEx(SupportHookInfo hookInfo)
{
	void* address = hookInfo.address;
	void* replacement = hookInfo.replacement;
	void** original = hookInfo.original;

	return _supportmem_hookfunction_64(address, replacement, original);;
}
 
int SupportDestroy(SupportHookInfo hookInfo)
{ 
	if(hookInfo.original != NULL)
	{ 
		free(hookInfo.original); 
	} 
	return LSM_SUCCESS;
}
 
int SupportCodePatchEx(void* addr, const uint8_t* buffer, size_t size)
{	return _supportmem_code_patch(addr, buffer, size);
}
 
void SupportRunOnMainQueueWithoutDeadlocking(void (*callback)(void*), void* data)
{
    if ([NSThread isMainThread]){ callback(data); } 
	else { dispatch_sync(dispatch_get_main_queue(), ^{ callback(data); }); }
}

# if 0 
void SupportGetApplicationWindowInfo(SupportApplicationWindowInfo *info) {
	id window = SupportGetKeyWindowInternal();
	id rootViewController = ((UIWindow *)window).rootViewController;
	id currentRootViewController = SupportGetCurrentViewControllerFrom(rootViewController);

	info->window = (__bridge const void *)window;
	info->rootViewController = (__bridge const void *)rootViewController;
	info->currentRootViewController = (__bridge const void *)currentRootViewController;
}
#endif
 
void SupportGetDetectionInfo(SupportDetectionInfo* detectionInfo) 
{
	if (LS_UNLIKELY(detectionInfo == NULL)) 
		return;
    
	if(LS_LIKELY(!detectionInfo->isJailbroken))
	{
		detectionInfo->isJailbroken = access("/var/mobile", R_OK) == 0;
	}

	if(LS_LIKELY(!detectionInfo->isDebuggerPresent))
	{
		int flags = 0;
    	csops(getpid(), 0, &flags, sizeof(flags));
    	detectionInfo->isDebuggerPresent = (flags & CS_DEBUGGED) != 0;
	}
}

const char* SupportGetVersion()
{
	return LIBRARY_BUILD_VERSION;
}


#pragma mark - libsupport private api impl

BOOL isAddrRestricted( const void * addr ) {
    if(addr) {
        // See if this address belongs to a restricted file.
        const char* image_path = dyld_image_path_containing_address(addr);
        return isCPathRestricted(image_path);
    }

    return NO;
}

BOOL isCFURLRestricted( CFURLRef path )
{
    NSURL* result = (__bridge NSURL *)(path);
    return isURLRestricted(result);
}

BOOL isCFPathRestricted( CFStringRef path )
{
    NSString* result = (__bridge NSString *)(path);
    return isPathRestricted(result);
}

BOOL isURLRestricted( NSURL* url )
{
    if(!url) return NO;
    if([url isFileURL]) 
    {
        NSString* path = [url path];

        if([url isFileReferenceURL]) 
        {
            NSURL *surl = [url standardizedURL];

            if(surl) 
            {
                path = [surl path];
            }            
        }

        if(isPathRestricted(path))
        {
            return YES;
        }
    }

	return isSchemeRestricted([url scheme]);
}

BOOL isPathRestricted( NSString* path )
{
    if (!path || ![path respondsToSelector:@selector(rangeOfString:)]) return NO;
    for (NSString* file in getRestrictedFiles())
    {
        if ([file characterAtIndex:0] == '/' && [path respondsToSelector:@selector(hasPrefix:)] && [path hasPrefix:file]) return YES;
        if ([path rangeOfString:file].location != NSNotFound) return YES;
    }

    return NO;
}

BOOL isCPathRestricted(const char* path)
{
	if(path)
	{
        return isPathRestricted([[NSFileManager defaultManager] stringWithFileSystemRepresentation:path length:strlen(path)]);
	}
	return NO;
}

LS_FORCE_INLINE NSString* getBundlePath() { return _bundlePath; }
LS_FORCE_INLINE NSString* getBundleIdentifier(){ return _bundleIdentifier; }
LS_FORCE_INLINE NSString* getTeamIdentifier(){ return _teamIdentifier; }
LS_FORCE_INLINE NSArray* getRestrictedFiles(){ return _restrictedFiles; }

BOOL isAddrExternal(const void *addr) 
{
	if(!addr) return NO;

    const char* image_path = dyld_image_path_containing_address(addr);
	if(!image_path) return NO;

	if(strcmp(image_path, SupportGetLibraryPath()) == 0)
	{
		return NO;
	}

	// FIXME:
	//if(strcmp(image_path, SupportInitCallerPath()) == 0)
	//{
	//	return NO;
	//}

	return YES;
}

# if 0
// Shadow impl (ref)
BOOL isAddrExternal(const void *addr) 
{
	if(!addr) return NO;

    const char* image_path = dyld_image_path_containing_address(addr);
	if(!image_path) return NO;

    if (strstr(image_path, [getBundlePath() fileSystemRepresentation]) != NULL) 
    {
		if (strstr(image_path, "libSupport.dylib") != NULL) 
        {
            return YES; // Treat libSupport as external even though it's within the app's bundle.
        }
        return NO; // It's internal
    }

    return YES; // It's external
}
#endif

#pragma mark - libsupport utilities

id getAdjustedDictionary(NSBundle *bundle, id dictionary, BOOL mutable)
{
    NSMutableDictionary *mutableDictionary = mutable ? dictionary : [dictionary mutableCopy];
	
    if (bundle == NSBundle.mainBundle)
    {
		NSString *adjustedBundleIdentifier = getBundleIdentifier();
		if (adjustedBundleIdentifier != nil)
		{
			static NSString *bundleIdentifierKey = @"CFBundleIdentifier";
			if ([mutableDictionary objectForKey:bundleIdentifierKey] != nil)
			{
				[mutableDictionary setObject:adjustedBundleIdentifier forKey:bundleIdentifierKey];
			}

			// Fix for iosgods spoofer thing remove this shit wtf dude, by default sideloadly adds this to the info.plist file
			// libSupport is not compatible with their spoofer, it will just crash the app
			// We are trying to restore the info.plist to its original state and these guys are adding on to it lol
			static NSString *altBundleIdentifierKey = @"ALTBundleIdentifier";
        	if ([mutableDictionary objectForKey:altBundleIdentifierKey] != nil)
			{
            	[mutableDictionary removeObjectForKey:altBundleIdentifierKey];
			}
		}
    }

	// return the original sate
    return mutable ? mutableDictionary : [mutableDictionary copy];
}

NSString *getStandardizedPath(NSString *path)
{
    if(!path) {
        return path;
    }

    NSURL* url = [NSURL URLWithString:path];

    if(!url) {
        url = [NSURL fileURLWithPath:path];
    }

    NSString* standardized_path = [[url standardizedURL] path];

    if(standardized_path) {
        path = standardized_path;
    }

    while([path containsString:@"/./"]) {
        path = [path stringByReplacingOccurrencesOfString:@"/./" withString:@"/"];
    }

    while([path containsString:@"//"]) {
        path = [path stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    }

    if([path length] > 1) {
        if([path hasSuffix:@"/"]) {
            path = [path substringToIndex:[path length] - 1];
        }

        while([path hasSuffix:@"/."]) {
            path = [path stringByDeletingLastPathComponent];
        }
        
        while([path hasSuffix:@"/.."]) {
            path = [path stringByDeletingLastPathComponent];
            path = [path stringByDeletingLastPathComponent];
        }
    }

    if([path hasPrefix:@"/private/var"] || [path hasPrefix:@"/private/etc"]) {
        NSMutableArray* pathComponents = [[path pathComponents] mutableCopy];
        [pathComponents removeObjectAtIndex:1];
        path = [NSString pathWithComponents:pathComponents];
    }

    if([path hasPrefix:@"/var/tmp"]) {
        NSMutableArray* pathComponents = [[path pathComponents] mutableCopy];
        [pathComponents removeObjectAtIndex:1];
        path = [NSString pathWithComponents:pathComponents];
    }

    return path;
}

// taken from oppa (TrollStore)
// ref: https://github.com/opa334/TrollStore/blob/704d3ffd45f90edc2ba796511222079b5d69cfd4/Shared/TSUtil.m#L29
extern char*** _NSGetArgv();
NSString* getExecutablePath()
{
	//char* executablePathC = **_NSGetArgv();
	//return [NSString stringWithUTF8String:executablePathC];

	return [[NSProcessInfo processInfo].arguments firstObject];
}

LS_FORCE_INLINE
BOOL isSchemeRestricted(NSString * scheme) 
{
    return [_restrictedSchemes containsObject:scheme];
}
