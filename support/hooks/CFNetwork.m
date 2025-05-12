/* This is just somthing I thought was intresting so I ended up messing with it lol */

#include "hooks.h"

// neuter iOSSecuritySuite ProxyChecker lol
// ---> start
LS_STATIC void new_CFNetworkCopySystemProxySettings$RemoveVPNInterfaces(const void *key, const void *value, void *context) {
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)context;
    CFStringRef interface = (CFStringRef)key;
    
	CFStringRef names[] = {
        CFSTR("tap"),
        CFSTR("tun"),
        CFSTR("ppp"),
        CFSTR("ipsec"),
        CFSTR("utun")
    };
    
    for (CFIndex i = 0; i < LS_ARRAYSIZE(names); i++) {
        if (CFStringFind(interface, names[i], 0).location != kCFNotFound) {
            CFDictionaryRemoveValue(dict, key);
            break;
        }
    }
}

LS_STATIC CFDictionaryRef (*orig_CFNetworkCopySystemProxySettings)(void);
LS_STATIC CFDictionaryRef new_CFNetworkCopySystemProxySettings(void) 
{
	CFDictionaryRef settings = orig_CFNetworkCopySystemProxySettings();
	if(isCallerTweak() || settings == NULL)
	{
		return settings;
	}

	CFMutableDictionaryRef newSettings = CFDictionaryCreateMutableCopy(
		kCFAllocatorDefault, 
		CFDictionaryGetCount(settings),
		settings
	);

	if(newSettings == NULL) 
		return settings;

	//iOSSecuritySuite considerVPNConnectionAsProxy no lol
	const void *ScopedKey = CFSTR("__SCOPED__");
	CFDictionaryRef scoped = CFDictionaryGetValue(newSettings, ScopedKey);
	if(scoped && CFGetTypeID(scoped) == CFDictionaryGetTypeID())
	{
		CFMutableDictionaryRef newScoped = CFDictionaryCreateMutableCopy(
			kCFAllocatorDefault,
			CFDictionaryGetCount(scoped),
			scoped
		);

		CFDictionaryApplyFunction(newScoped, new_CFNetworkCopySystemProxySettings$RemoveVPNInterfaces, newScoped);
		CFDictionaryRef finalScoped = CFDictionaryCreateCopy(kCFAllocatorDefault, newScoped); // set back to immutable state
		if(finalScoped)
		{
			CFDictionarySetValue(newSettings, ScopedKey, finalScoped);
			CFRelease(finalScoped);
		}
		CFRelease(newScoped);
	}

	// keys to be removed
	const void *proxyKeys[] = {
        CFSTR("HTTPProxy"),
        CFSTR("HTTPSProxy")
    };

	for (CFIndex i = 0; i < LS_ARRAYSIZE(proxyKeys); i++)
	{
		const void* key = proxyKeys[i];
		if(CFDictionaryContainsKey(newSettings, key))
		{
			CFDictionaryRemoveValue(newSettings, key);
		}
	}

	CFDictionaryRef finalSettings = CFDictionaryCreateCopy(kCFAllocatorDefault, newSettings);
    CFRelease(newSettings);
    CFRelease(settings);
	return finalSettings;
}
// --> end

void _supporthook_CFNetwork_antiproxy()
{
    LS_AutoHookSymbol(CFNetworkCopySystemProxySettings);
}