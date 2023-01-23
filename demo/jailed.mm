#include "UIKit/UIKit.h"
#include "support/support.h"

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
        .bundleIdentifier = NULL,
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
				new_didFinishLaunchingWithOptions,
				orig_didFinishLaunchingWithOptions);	
	
	SupportHookInstanceMessage("UnityAppController", 
				"applicationDidBecomeActive:", 
				new_applicationDidBecomeActive,
				orig_applicationDidBecomeActive);	

	SupportHookSymbolEx("dyld_get_image_name", 
				(void*)(new_dyld_get_image_name), 
				(void**)(&orig_dyld_get_image_name));
}