#include <stdio.h>
#include "UIKit/UIKit.h"
#include "support/support_load.h"

BOOL (*orig_didFinishLaunchingWithOptions)(id self, SEL selector, UIApplication* application, NSDictionary* launchOptions);
BOOL new_didFinishLaunchingWithOptions(id self, SEL selector, UIApplication* application, NSDictionary* launchOptions) 
{
	/*
	* pointer checks handler
	* outIndex - returns current func index
	*/
	hookedf_add(reinterpret_cast<void*>(new_didFinishLaunchingWithOptions), 
				reinterpret_cast<void*>(orig_didFinishLaunchingWithOptions), NULL);	
				
	// just objc hook example
	// your code
	NSLog(@"orig_didFinishLaunchingWithOptions");
    return orig_didFinishLaunchingWithOptions(self, selector, application, launchOptions);
}

const char* (*orig_dyld_get_image_name)(uint32_t image_index);
const char* new_dyld_get_image_name(uint32_t image_index)
{
	/*
	* pointer checks handler
	* outIndex - returns current func index
	*/
	hookedf_add(reinterpret_cast<void*>(new_dyld_get_image_name), 
				reinterpret_cast<void*>(orig_dyld_get_image_name), NULL);

	// useless if not used correctly.
	NSLog(@"new_dyld_get_image_name");
	return orig_dyld_get_image_name(image_index);
}

void (*orig_applicationDidBecomeActive)(id self, SEL selector, id arg0);
void new_applicationDidBecomeActive(id self, SEL selector, id arg0) 
{
	/*
	* pointer checks handler
	* outIndex - returns current func index
	*/
	hookedf_add(reinterpret_cast<void*>(new_dyld_get_image_name), 
				reinterpret_cast<void*>(orig_dyld_get_image_name), NULL);
	NSLog(@"new_applicationDidBecomeActive");

	orig_applicationDidBecomeActive(self, selector, arg0);
}

__attribute__((constructor)) static void entry() 
{
	/*
	* if your using support_load.h make sure support_init() is included + support_initialized
	* if your using support.h just call the functions the dylib needs to be linked it, + might get detected
	*/
	support_init();
	if(support_initialized()){

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

		objc_hook("UnityAppController", 
					"applicationDidBecomeActive:", 
					reinterpret_cast<SUPPORT_IMP>(&new_applicationDidBecomeActive),
					reinterpret_cast<SUPPORT_IMP *>(&orig_applicationDidBecomeActive));

		/* utilizes fishhook + function detection bypass */
		symbol_hook("dyld_get_image_name", 
					reinterpret_cast<void*>(new_dyld_get_image_name), 
					reinterpret_cast<void**>(&orig_dyld_get_image_name));
	}
}