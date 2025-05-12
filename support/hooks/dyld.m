#import "hooks.h"

LS_STATIC NSMutableArray<NSDictionary *> *_support_dyld_collection;
LS_STATIC NSMutableArray<NSValue *> *_support_dyld_add_image;
LS_STATIC NSMutableArray<NSValue *> *_support_dyld_remove_image;
LS_STATIC BOOL _support_dyld_error = NO;

LS_STATIC uint32_t (*orig_dyld_image_count)(void);
LS_STATIC uint32_t new_dyld_image_count(void)
{
    if(isCallerTweak()) 
    {
        return orig_dyld_image_count();
    }

    return (uint32_t)[_support_dyld_collection count];
}

LS_STATIC const char* (*orig_dyld_get_image_name)(uint32_t image_index);
LS_STATIC const char* new_dyld_get_image_name(uint32_t image_index)
{
    if(isCallerTweak()) 
    {
        return orig_dyld_get_image_name(image_index);
    }

    if (image_index < [_support_dyld_collection count]) 
    {
        return [_support_dyld_collection[image_index][@"name"] fileSystemRepresentation];
    }

    return NULL;
}

LS_STATIC struct mach_header* (*orig_dyld_get_image_header)(uint32_t image_index);
LS_STATIC struct mach_header* new_dyld_get_image_header(uint32_t image_index)
{
    if(isCallerTweak()) 
    {
        return orig_dyld_get_image_header(image_index);
    }

    if(image_index < [_support_dyld_collection count])
    {
        return (struct mach_header *)[_support_dyld_collection[image_index][@"header"] pointerValue];
    }

    return NULL;
}

LS_STATIC intptr_t (*orig_dyld_get_image_vmaddr_slide)(uint32_t image_index);
LS_STATIC intptr_t new_dyld_get_image_vmaddr_slide(uint32_t image_index)
{
    if(isCallerTweak()) 
    {
        return orig_dyld_get_image_vmaddr_slide(image_index);
    }
    
    if(image_index < [_support_dyld_collection count])
    {
        return (intptr_t)[_support_dyld_collection[image_index][@"slide"] integerValue];
    }

    return 0;
}

LS_STATIC void (*orig_dyld_register_func_for_add_image)(void (*func)(const struct mach_header* mh, intptr_t vmaddr_slide));
LS_STATIC void new_dyld_register_func_for_add_image(void (*func)(const struct mach_header* mh, intptr_t vmaddr_slide)) 
{
    if(isCallerTweak() || !func) 
    {
        return orig_dyld_register_func_for_add_image(func);
    }

    [_support_dyld_add_image addObject:[NSValue valueWithPointer:func]];
    
    for(NSDictionary* image_info in _support_dyld_collection) 
    {
        func((struct mach_header *)[image_info[@"header"] pointerValue], (intptr_t)[image_info[@"slide"] integerValue]);
    }
}

LS_STATIC void (*orig_dyld_register_func_for_remove_image)(void (*func)(const struct mach_header* mh, intptr_t vmaddr_slide));
LS_STATIC void new_dyld_register_func_for_remove_image(void (*func)(const struct mach_header* mh, intptr_t vmaddr_slide)) 
{
    if(isCallerTweak() || !func) 
    {
        return orig_dyld_register_func_for_remove_image(func);
    }
    
    [_support_dyld_remove_image addObject:[NSValue valueWithPointer:func]];
}

LS_STATIC void support_dyld_add_image(const struct mach_header *mh, intptr_t vmaddr_slide) 
{
    if(!mh) return;

    const char* image_path = dyld_image_path_containing_address(mh);
    if(!image_path) return;
 
    NSString* path = [NSString stringWithUTF8String:image_path];

    if([path hasPrefix:@"/System"] || !isPathRestricted(path)) 
    {
        //NSLog(@"%@: %@: %@", @"dyld", @"adding lib", path);

        [_support_dyld_collection addObject:@{
            @"name" : path,
            @"header" : [NSValue valueWithPointer:mh],
            @"slide" : @(vmaddr_slide)
        }];

        // Call event handlers
        for(NSValue* value in _support_dyld_add_image) 
        {
            void (*func)(const struct mach_header*, intptr_t) = [value pointerValue];
            func(mh, vmaddr_slide);
        }
    }
}

LS_STATIC NSDictionary* support_dyld_image_info_for_header(const struct mach_header *mh)
{
    for(NSDictionary* image_info in _support_dyld_collection) 
    {
        if((struct mach_header *)[image_info[@"header"] pointerValue] == mh) 
        {
            return image_info;
        }
    }

    return nil;
}

LS_STATIC void support_dyld_remove_image(const struct mach_header *mh, intptr_t vmaddr_slide) 
{
    if(!mh) return;

    NSDictionary *image_info = support_dyld_image_info_for_header(mh);
    if(!image_info) return;

    [_support_dyld_collection removeObject:image_info];

    for(NSValue* fptrValue in _support_dyld_remove_image) 
    {
        void (*func)(const struct mach_header*, intptr_t) = [fptrValue pointerValue];
        func(mh, vmaddr_slide);
    }
}

static char* (*orig_dlerror)(void);
static char* new_dlerror(void) 
{
    if(isCallerTweak() || !_support_dyld_error) 
    {
        return orig_dlerror();
    }

    _support_dyld_error = NO;
    return "library not found";
}

/*==========================================================================*/
LS_STATIC int (*orig_ptrace)(int request, pid_t pid, caddr_t addr, int data);
LS_STATIC int new_ptrace(int request, pid_t pid, caddr_t addr, int data) 
{
	if (request == PT_DENY_ATTACH) 
    {
        return 0;
    }
    return orig_ptrace(request, pid, addr, data);
}
/*==========================================================================*/

LS_STATIC void *(*orig_dlsym)(void* handle, const char *symbol);
LS_STATIC void *new_dlsym(void *handle, const char *symbol)
{
    void* addr = orig_dlsym(handle, symbol);

    if(!isCallerTweak() && isAddrRestricted(addr)) 
    {
        if(symbol) 
        {
            NSLog(@"%@: %@: %s", @"dlsym", @"restricted symbol lookup", symbol);
        }

        _support_dyld_error = YES;
        return NULL;
    }

    // temp impl untill I find a better way to do this.
    // bro thought he was sneaky (x_x)
    // 02/13/25 saved by litehook this is no longer needed :)
    if (addr && strcmp(symbol, "ptrace") == 0) 
    {
        orig_ptrace = addr;
        return (void*)new_ptrace;
    }

    return addr;
}

LS_STATIC int (*orig_dladdr)(const void* addr, Dl_info* info);
LS_STATIC int new_dladdr(const void* addr, Dl_info* info) 
{
    if(isCallerTweak()) 
    {
        return orig_dladdr(addr, info);
    }

    int result = orig_dladdr(addr, info);
    
    // This might actaully work correctly with fishhook but I havn't been able to properly test it 
    // I don't know tbh
    # if 0
    if(result && isAddrRestricted(addr)) 
    {
        if(info) 
        {
            void* sym;

            // try to find the real original addr
            do 
            {
                sym = dlsym(RTLD_NEXT, info->dli_sname);
            } while(sym && isAddrRestricted(sym));
            
            if(sym) 
            {
                return orig_dladdr(sym, info);
            } 
            else 
            {
                // fallback
                info->dli_fname = [getExecutablePath() fileSystemRepresentation];
            }
        }
    }

    #endif
    return result;
}

# if 0
LS_STATIC void *(*orig_NSAddImage)(const char *path, unsigned long flags);
LS_STATIC void *new_NSAddImage(const char *path, unsigned long flags) 
{
    if(isCallerTweak() || !filename) 
    {
        return orig_dlopen(filename, flags);
    }

    void* result = orig_NSAddImage(path, flags);
	if(result)
	{
        if(isAddrRestricted(result) || isCPathRestricted(path))
		{
		    return NULL;
	    }
	}

	return result;
}
#endif

LS_STATIC void *(*orig_dlopen)(const char *filename, int flags);
LS_STATIC void *new_dlopen(const char *filename, int flags)
{
    if(isCallerTweak() || !filename) 
    {
        return orig_dlopen(filename, flags);
    }

	void* handle = orig_dlopen(filename, flags);
	if(handle)
	{
        if(isAddrRestricted(handle) || isCPathRestricted(filename))
		{
            _support_dyld_error = YES;
		    return NULL;
	    }
	}

	return handle;
}

static void* (*orig_dlopen_internal)(const char* path, int mode, void* caller);
static void* new_dlopen_internal(const char* path, int mode, void* caller) {
    if(isCallerTweak() || !path) {
        return orig_dlopen_internal(path, mode, caller);
    }

    if(!isCPathRestricted(path)) {
        return orig_dlopen_internal(path, mode, caller);
    }

    _support_dyld_error = YES;
    return NULL;
}

LS_STATIC bool (*orig_dlopen_preflight)(const char* path);
LS_STATIC bool new_dlopen_preflight(const char* path) 
{
    if(isCallerTweak() || !path) 
    {
        return orig_dlopen_preflight(path);
    }

    bool result = orig_dlopen_preflight(path);
    if(result) 
    {
        if(isCPathRestricted(path)) 
		{
            return false;
        }
    }

    return result;
}

LS_STATIC kern_return_t (*orig_task_info)(task_name_t target_task, task_flavor_t flavor, task_info_t task_info_out, mach_msg_type_number_t *task_info_outCnt);
LS_STATIC kern_return_t new_task_info(task_name_t target_task, task_flavor_t flavor, task_info_t task_info_out, mach_msg_type_number_t *task_info_outCnt)
{    
    if(isCallerTweak()) 
    {
        return orig_task_info(target_task, flavor, task_info_out, task_info_outCnt);
    }

    kern_return_t ret = orig_task_info(target_task, flavor, task_info_out, task_info_outCnt);

	// Log(LOG(@"%@", [NSString stringWithFormat:@"HOOKED TASK_INFO"]));
    if(flavor == TASK_DYLD_INFO) 
	{
        if (ret == KERN_SUCCESS) 
		{
            // I will come back later and filter this
            struct task_dyld_info *task_info = (struct task_dyld_info *) task_info_out;
            struct dyld_all_image_infos *dyld_info = (struct dyld_all_image_infos *) task_info->all_image_info_addr;

			// Log(LOG(@"%@", [NSString stringWithFormat:@"%u", dyld_info->infoArrayCount]));
            dyld_info->infoArrayCount = 1;
            dyld_info->uuidArrayCount = 1;
        }
    }
    else if(flavor == TASK_EXTMOD_INFO)
    {
        return KERN_FAILURE;
    }

    return ret;
}

void _supporthook_dyld(void)
{
    _support_dyld_collection = [NSMutableArray new];
    _support_dyld_add_image = [NSMutableArray new];
    _support_dyld_remove_image = [NSMutableArray new];

    // Register the image add and remove functions before hooking
    _dyld_register_func_for_add_image(support_dyld_add_image);
    _dyld_register_func_for_remove_image(support_dyld_remove_image);
    
	SupportHookSymbolEx("_dyld_image_count", new_dyld_image_count, (void **)&orig_dyld_image_count);
	SupportHookSymbolEx("_dyld_get_image_name", new_dyld_get_image_name, (void **)&orig_dyld_get_image_name);
    SupportHookSymbolEx("_dyld_get_image_header", new_dyld_get_image_header, (void **)&orig_dyld_get_image_header);
	SupportHookSymbolEx("_dyld_get_image_vmaddr_slide", new_dyld_get_image_vmaddr_slide, (void **)&orig_dyld_get_image_vmaddr_slide);
    SupportHookSymbolEx("_dyld_register_func_for_add_image", new_dyld_register_func_for_add_image, (void **)&orig_dyld_register_func_for_add_image);
    SupportHookSymbolEx("_dyld_register_func_for_remove_image", new_dyld_register_func_for_remove_image, (void **)&orig_dyld_register_func_for_remove_image);
	
    SupportHookSymbolEx("task_info", new_task_info, (void **)&orig_task_info);

	SupportHookSymbolEx("dlopen", new_dlopen, (void **)&orig_dlopen);

    LS_UNUSED(new_dlopen_internal);
    LS_UNUSED(orig_dlopen_internal);
	//SupportHookSymbolEx("dlopen_from", new_dlopen_internal, (void **)&orig_dlopen_internal);
    SupportHookSymbolEx("dlopen_preflight", new_dlopen_preflight, (void **)&orig_dlopen_preflight);

    SupportHookSymbolEx("dlerror", new_dlerror, (void **) &orig_dlerror);
}

void _supporthook_dyld_symlookup(void)
{
	SupportHookSymbolEx("dlsym", new_dlsym, (void **)&orig_dlsym);
}

void _supporthook_dyld_symaddrlookup(void)
{
	SupportHookSymbolEx("dladdr", new_dladdr, (void **)&orig_dladdr);
}

/* Would anyone use this? I mean its already here :| */
LS_EXPORT 
uint32_t _support_dyld_image_count(void)
{
    return [_support_dyld_collection count];
}

LS_EXPORT 
const char* _support_dyld_get_image_name(uint32_t image_index)
{
    return image_index < [_support_dyld_collection count] ? 
        [_support_dyld_collection[image_index][@"name"] fileSystemRepresentation] : NULL;
}

LS_EXPORT
const struct mach_header* _support_dyld_get_image_header(uint32_t image_index)
{
    return image_index < [_support_dyld_collection count] ? 
        (struct mach_header *)[_support_dyld_collection[image_index][@"mach_header"] pointerValue] : NULL;
}

LS_EXPORT 
intptr_t _support_dyld_get_image_vmaddr_slide(uint32_t image_index)
{
    return image_index < [_support_dyld_collection count] ? 
        (intptr_t)[_support_dyld_collection[image_index][@"slide"] pointerValue] : 0;
}
