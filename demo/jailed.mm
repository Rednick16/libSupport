#include "UIKit/UIKit.h"
#include "support.h"
#include "memory/MemoryPatch.h"

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

extern void* SecTaskCreateFromSelf(void *);
extern void* SecTaskCopySigningIdentifier(void *, void *);
extern CFDictionaryRef SecTaskCopyValuesForEntitlements(void *, CFArrayRef, CFErrorRef  _Nullable *);
extern CFTypeRef SecTaskCopyValueForEntitlement(void *, CFStringRef, CFErrorRef *);

#ifdef __cplusplus
}
#endif //__cplusplus

// ref: https://github.com/opa334/Choicy/blob/2066755c4065905860ee15800e5df3f78703feca/Tweak.x#L45C1-L55C2
SUPPORT_STATIC 
NSString *safe_getBundleIdentifier() {
	CFBundleRef mainBundle = CFBundleGetMainBundle();

	if (mainBundle != NULL) {
		CFStringRef bundleIdentifierCF = CFBundleGetIdentifier(mainBundle);

		return (__bridge NSString *)bundleIdentifierCF;
	}

	return nil;
}

// initilize libSupport to use somtimes dyld hooks break
void* SupportGetRealAdr(const char* image, uint64_t addr)
{
    uint32_t c = SupportGetImageCount();

    for (uint32_t i = 0; i < c; i++)
    {
        const char *image_name = SupportGetDyldImageName(i);
        if(strstr(image_name, image))
        {
            return reinterpret_cast<void *>(SupportGetImageVmaddrSlide(i) + addr);
        }
    }

    return reinterpret_cast<void *>(SupportGetImageVmaddrSlide(0) + addr);
}

SUPPORT_STATIC 
BOOL (*orig_didFinishLaunchingWithOptions)(id self, SEL selector, UIApplication* application, NSDictionary* launchOptions);
SUPPORT_STATIC 
BOOL new_didFinishLaunchingWithOptions(id self, SEL selector, UIApplication* application, NSDictionary* launchOptions) 
{
	NSLog(@"[BypassInjector]: orig_didFinishLaunchingWithOptions");
    return orig_didFinishLaunchingWithOptions(self, selector, application, launchOptions);
}

SUPPORT_STATIC 
const char* (*orig_dyld_get_image_name)(uint32_t image_index);
SUPPORT_STATIC 
const char* new_dyld_get_image_name(uint32_t image_index)
{
	NSLog(@"[BypassInjector]: new_dyld_get_image_name");
	return orig_dyld_get_image_name(image_index);
}

SUPPORT_STATIC SUPPORT_UNUSED
void (*original_NSLog)(NSString *format, ...) = NULL;
SUPPORT_STATIC 
void replaced_NSLog (NSString *format, ...) 
{
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%@", format] arguments:args];
    va_end(args);
    
    DLOG(@"HOOKED: %@", message);
    //original_NSLog(@"HOOKED: %@", message);
}

SUPPORT_CTOR 
{
    NSString* teamIdentifier = (__bridge NSString *)(SecTaskCopyValueForEntitlement(SecTaskCreateFromSelf(NULL), CFSTR("com.apple.developer.team-identifier"), NULL));
	NSString* bundleIdentifier = safe_getBundleIdentifier();

    const char* cBundleIdentifier = ([bundleIdentifier containsString:teamIdentifier] == YES) ? 
                                    [[bundleIdentifier stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", teamIdentifier] 
                                                                                 withString:@""] UTF8String] : [bundleIdentifier UTF8String];

    // SupportHookTypeE = super hacky non jailbroken hook. no orig yet
    SupportHookFunction((void *)NSLog, (void *)replaced_NSLog, NULL);

    // test NSLog. It may not work for us tbh
    NSLog(@"libSupport(%s) by Rednick16 Injected.\n\nBundleIdentifier:\n%s\n\nteamID: %@", SupportGetVersion(), cBundleIdentifier, teamIdentifier);

    //JIT is similar to a debugger.
    SupportDetectionInfo detectionInfo = SupportGetDetectionInfo();
    if(detectionInfo.isDebuggerPresent || detectionInfo.isJailbroken) {
        const uint8_t patch[] = {0xC0, 0x03, 0x5F, 0xD6}; //4 bytes
        Support::MemoryPatch patch_NSLog((void *)NSLog, patch, sizeof(patch));
        patch_NSLog.adjust(); // apply the patch
    }

	/* Create the structure
	.teamIdentifier -> (Currently paused)
	.bundleIdentifier -> "com.rednick16.myApp"
	.files -> (Files to bypass)
	.settings {
        .hookSymbols -> (enables function hooks uses fishhook),
        .hookMessages -> (enables objective c function hooks),
        .hookExpierimental -> (enables semi Jailbreak detection bypass),
        .allowDebugging -> (enables semi Anti Debugging bypassed (w.i.p)(90%))
	}
	*/
    SupportEntryInfo entry_info = {
        .teamIdentifier = NULL,
        .bundleIdentifier = cBundleIdentifier,
        .files = {
            "CydiaSubstrate",
            "embedded.mobileprovision",
            "libSupport",
            "BypassInjector",
            "H5GG",
            "iGameGod",
            NULL
        },
        // Use full power if possible.
        .general = {
            .settings = {
                .hookSymbols = true,
                .hookMessages = true,
                .hookExpierimental = true,
                .allowDebugging = true
            }
        }
    };

    SupportInitilize(&entry_info);

	SupportHookInstanceMessage("UnityAppController", 
				"application:didFinishLaunchingWithOptions:", 
				&new_didFinishLaunchingWithOptions,
				&orig_didFinishLaunchingWithOptions);	

	SupportHookSymbolEx("dyld_get_image_name", 
				(void*)(new_dyld_get_image_name), 
				(void**)(&orig_dyld_get_image_name));

    //SupportHookClassMessage("APMAEU", "isFAS", WRAPPER_OBJC_HOOK_TRUE, NULL);
    //SupportHookClassMessage("GULAppEnvironmentUtil", "isFromAppStore", WRAPPER_OBJC_HOOK_TRUE, NULL);
}