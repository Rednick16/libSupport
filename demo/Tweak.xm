#import <stdio.h>
#import "UIKit/UIKit.h"
#import "support/support.h"

__attribute__((visibility("default"))) void example_symbol()
{
	printf("example_symbol");
} // Don't do this or ur stuff might get detected.

BOOL (*orig_didFinishLaunchingWithOptions)(id self, SEL selector, UIApplication* application, NSDictionary* launchOptions);
BOOL new_didFinishLaunchingWithOptions(id self, SEL selector, UIApplication* application, NSDictionary* launchOptions) 
{
	// just objc hook example
	// your code

    return orig_didFinishLaunchingWithOptions(self, selector, application, launchOptions);
}

const char* (*orig_dyld_get_image_name)(uint32_t image_index);
const char* new_dyld_get_image_name(uint32_t image_index)
{
	// useless if not used correctly.
	return orig_dyld_get_image_name(image_index);
}

__attribute__((constructor)) static void entry() 
{
    struct support_bypass bypass = {
        NULL, /* custom uniuque id to spoof app no use for now */
        "com.rednick16.jailed.example", /* your app bundle id most basic detection but effective */
        {
			/* add any files u wish to bypass here */
            "embedded",
            "mobileprovision",
            "jailed_example",
            "libsupport"
        },
        {
			/* add any symbols u wish to bypass here */
			"example_symbol",
			"MSHookFunction",
			"MSHookMessage"
		}
    };
    
    initilize(bypass);

	/*
	safe objc hooking without supstrate + function detection bypass
	*/
    objc_hook("UnityAppController", 
				"application:didFinishLaunchingWithOptions:", 
				reinterpret_cast<SUPPORT_IMP>(&new_didFinishLaunchingWithOptions),
	 			reinterpret_cast<SUPPORT_IMP *>(&orig_didFinishLaunchingWithOptions));

	/* utilizes fishhook + function detection bypass */
	symbol_hook("dyld_get_image_name", reinterpret_cast<void*>(new_dyld_get_image_name), 
									reinterpret_cast<void**>(&orig_dyld_get_image_name));
}