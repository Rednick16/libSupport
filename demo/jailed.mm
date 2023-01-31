#include "UIKit/UIKit.h"
#include "support/support.h"

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

BOOL (*orig_didFinishLaunchingWithOptions)(id self, SEL selector, UIApplication* application, NSDictionary* launchOptions);
BOOL new_didFinishLaunchingWithOptions(id self, SEL selector, UIApplication* application, NSDictionary* launchOptions) 
{
	NSLog(@"orig_didFinishLaunchingWithOptions");
    return orig_didFinishLaunchingWithOptions(self, selector, application, launchOptions);
}

const char* (*orig_dyld_get_image_name)(uint32_t image_index);
const char* new_dyld_get_image_name(uint32_t image_index)
{
	NSLog(@"new_dyld_get_image_name");
	return orig_dyld_get_image_name(image_index);
}

void (*orig_applicationDidBecomeActive)(id self, SEL selector, id arg0);
void new_applicationDidBecomeActive(id self, SEL selector, id arg0) 
{
	NSLog(@"new_applicationDidBecomeActive");
	orig_applicationDidBecomeActive(self, selector, arg0);
}

SUPPORT_CTOR 
{
    NSString* teamIdentifier = CFBridgingRelease(SecTaskCopyValueForEntitlement(SecTaskCreateFromSelf(NULL), CFSTR("com.apple.developer.team-identifier"), NULL));
	NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

    // original bundleIdentifier after removing teamIdentifier
    const char* cBundleIdentifier = [bundleIdentifier hasPrefix:teamIdentifier] ? 
                                    [[bundleIdentifier stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", teamIdentifier] 
                                                                                 withString:@""] UTF8String] : [bundleIdentifier UTF8String];

    // DLOG(@"libSupport(%s) by Rednick16 Injected.", SupportGeVersion());

	/* Create the structure
	.teamIdentifier -> (Currently paused)
	.bundleIdentifier -> "com.rednick16.myApp"
	.files -> (Files to bypass)
	.settings {
        .hookSymbols -> (enables function hooks uses fishhook),
        .hookMessages -> (enables objective c function hooks),
        .hookExpierimental -> (enables semi Jailbreak detection bypass),
        .allowDebugging -> (enables semi Anti Debugging bypassed (w.i.p)(70%))
	}
	*/
    SupportEntryInfo entry_info = {
        .teamIdentifier = NULL,
        .bundleIdentifier = cBundleIdentifier,
        .files = {
            "CydiaSubstrate",
            "libsubstrate",
            "MobileSubstrate",
            "embedded.mobileprovision",
            "libSupport",
            NULL
        },
        .general = {
            .settings = {
                .hookSymbols = true,
                .hookMessages = true,
                .hookExpierimental = false,
                .allowDebugging = false
            }
        }
    };

    SupportInitilize(entry_info);

	SupportHookInstanceMessage("UnityAppController", 
				"application:didFinishLaunchingWithOptions:", 
				&new_didFinishLaunchingWithOptions,
				&orig_didFinishLaunchingWithOptions);	
	
	SupportHookInstanceMessage("UnityAppController", 
				"applicationDidBecomeActive:", 
				&new_applicationDidBecomeActive,
				&orig_applicationDidBecomeActive);	

	SupportHookSymbolEx("dyld_get_image_name", 
				(void*)(new_dyld_get_image_name), 
				(void**)(&orig_dyld_get_image_name));

    SupportHookClassMessage("APMAEU", "isFAS", WRAPPER_OBJC_HOOK_TRUE, NULL);
    SupportHookClassMessage("GULAppEnvironmentUtil", "isFromAppStore", WRAPPER_OBJC_HOOK_TRUE, NULL);
}