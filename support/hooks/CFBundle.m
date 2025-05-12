/*
 The reason this exist is because for some reason my NSBundle hooks didn't effect CFBundle
 So I am just manually hooking CFBundle just incase some developers think they are being sneaky lol
*/

#include "hooks.h"

# if 1
LS_STATIC CFURLRef (*orig_CFBundleCopyBundleURL)(CFBundleRef bundle);
LS_STATIC CFURLRef new_CFBundleCopyBundleURL(CFBundleRef bundle)
{
	CFURLRef result = orig_CFBundleCopyBundleURL(bundle);
	if(!isCallerTweak() && result)
	{
		if(isCFURLRestricted(result))
		{
			return nil;
		}
	}

	return result;
}
#endif

LS_STATIC CFURLRef (*orig_CFBundleCopyResourceURL)(CFBundleRef bundle, CFStringRef resourceName, CFStringRef resourceType, CFStringRef subDirName);
LS_STATIC CFURLRef new_CFBundleCopyResourceURL(CFBundleRef bundle, CFStringRef resourceName, CFStringRef resourceType, CFStringRef subDirName)
{
	CFURLRef result = orig_CFBundleCopyResourceURL(bundle, resourceName, resourceType, subDirName);
	if(result)
	{
		if(!isCallerTweak() && isCFURLRestricted(result))
		{
			return nil;
		}
	}

	return result;
}

LS_STATIC CFURLRef (*orig_CFBundleCopyResourceURLInDirectory)(CFURLRef bundleURL, CFStringRef resourceName, CFStringRef resourceType, CFStringRef subDirName);
LS_STATIC CFURLRef new_CFBundleCopyResourceURLInDirectory(CFURLRef bundleURL, CFStringRef resourceName, CFStringRef resourceType, CFStringRef subDirName)
{
	CFURLRef result = orig_CFBundleCopyResourceURLInDirectory(bundleURL, resourceName, resourceType, subDirName);
	if(result)
	{
		if(!isCallerTweak() && isCFURLRestricted(result))
		{
			return nil;
		}
	}

	return result;
}

LS_STATIC CFDictionaryRef (*orig_CFBundleGetInfoDictionary)(CFBundleRef bundle);
LS_STATIC CFDictionaryRef new_CFBundleGetInfoDictionary(CFBundleRef bundle)
{
	CFDictionaryRef infoDict = orig_CFBundleGetInfoDictionary(bundle);
	if(isCallerTweak() || !infoDict)
	{
		return infoDict;
	}

	// tempoary solution
	return (__bridge CFDictionaryRef)getAdjustedDictionary((__bridge NSBundle *)bundle, (__bridge NSDictionary *)infoDict, NO);

	# if 0
	if(!isCallerTweak() && infoDict)
	{
        const void* bundleIdentifierKey = CFSTR("CFBundleIdentifier");
		CFStringRef bundleIdentifier = (__bridge CFStringRef)(getBundleIdentifier());
        if(CFDictionaryGetValue(infoDict, bundleIdentifierKey) != nil)
		    CFDictionarySetValue((CFMutableDictionaryRef)infoDict, bundleIdentifierKey, bundleIdentifier);

		const void* altBundleIdentifierKey = CFSTR("ALTBundleIdentifier");
		if(CFDictionaryGetValue(infoDict, altBundleIdentifierKey) != nil)
			CFDictionaryRemoveValue((CFMutableDictionaryRef)infoDict, altBundleIdentifierKey);

		/*
		CFArrayRef URLTypesArray = (CFArrayRef)CFDictionaryGetValue(infoDict, CFSTR("CFBundleURLTypes"));
		if(URLTypesArray)
		{
			CFDictionaryRef URLTypesDict = (CFDictionaryRef)CFArrayGetValueAtIndex(URLTypesArray, 1);
			if(URLTypesDict)
			{
				CFDictionarySetValue((CFMutableDictionaryRef)URLTypesDict, CFSTR("CFBundleURLName"), bundleIdentifier);
			}
		}
		*/
	}

	return infoDict;
	#endif
}

LS_STATIC CFDictionaryRef (*orig_CFBundleGetLocalInfoDictionary)(CFBundleRef bundle);
LS_STATIC CFDictionaryRef new_CFBundleGetLocalInfoDictionary(CFBundleRef bundle)
{
	CFDictionaryRef infoDict = orig_CFBundleGetLocalInfoDictionary(bundle);
	if (isCallerTweak() || !infoDict)
		return infoDict;

	// tempoary solution
	return (__bridge CFDictionaryRef)getAdjustedDictionary((__bridge NSBundle *)bundle, (__bridge NSDictionary *)infoDict, NO);

/*
    const void* bundleIdentifierKey = CFSTR("CFBundleIdentifier");
	CFStringRef bundleIdentifier = (__bridge CFStringRef)(getBundleIdentifier());
    if(CFDictionaryGetValue(infoDict, bundleIdentifierKey) != nil)
	    CFDictionarySetValue((CFMutableDictionaryRef)infoDict, bundleIdentifierKey, bundleIdentifier);
	
	const void* altBundleIdentifierKey = CFSTR("ALTBundleIdentifier");
	if(CFDictionaryGetValue(infoDict, altBundleIdentifierKey) != nil)
		CFDictionaryRemoveValue((CFMutableDictionaryRef)infoDict, altBundleIdentifierKey);
	
    return infoDict;
	*/
}

LS_STATIC CFDictionaryRef (*orig_CFBundleCopyInfoDictionaryInDirectory)(CFURLRef bundleURL);
LS_STATIC CFDictionaryRef new_CFBundleCopyInfoDictionaryInDirectory(CFURLRef bundleURL)
{
	CFDictionaryRef infoDict = orig_CFBundleCopyInfoDictionaryInDirectory(bundleURL);
	if(!isCallerTweak() && infoDict)
	{
        const void* bundleIdentifierKey = CFSTR("CFBundleIdentifier");
		CFStringRef bundleIdentifier = (__bridge CFStringRef)(getBundleIdentifier());
        if(CFDictionaryGetValue(infoDict, bundleIdentifierKey) != nil)
		    CFDictionarySetValue((CFMutableDictionaryRef)infoDict, bundleIdentifierKey, bundleIdentifier);

		const void* altBundleIdentifierKey = CFSTR("ALTBundleIdentifier");
		if(CFDictionaryGetValue(infoDict, altBundleIdentifierKey) != nil)
			CFDictionaryRemoveValue((CFMutableDictionaryRef)infoDict, altBundleIdentifierKey);
		
        return infoDict;
	}

	return infoDict;
}

LS_STATIC CFStringRef (*orig_CFBundleGetIdentifier)(CFBundleRef bundle);
LS_STATIC CFStringRef new_CFBundleGetIdentifier(CFBundleRef bundle)
{
	CFStringRef result = orig_CFBundleGetIdentifier(bundle);
	# if 0
	if(!isCallerTweak() && result)
	{
		CFStringRef bundleIdentifier = (__bridge CFStringRef)(getBundleIdentifier());
		if(CFStringHasPrefix(result, bundleIdentifier))
		{
			return bundleIdentifier;
		}
	}
	#endif

	return result;
}

LS_STATIC CFTypeRef (*orig_CFBundleGetValueForInfoDictionaryKey)(CFBundleRef bundle, CFStringRef key);
LS_STATIC CFTypeRef new_CFBundleGetValueForInfoDictionaryKey(CFBundleRef bundle, CFStringRef key)
{
	CFTypeRef result = orig_CFBundleGetValueForInfoDictionaryKey(bundle, key);
	# if 0
	if(!isCallerTweak() && result)
	{
        if(CFStringCompare(key, CFSTR("CFBundleIdentifier"), 0) == kCFCompareEqualTo)
        {
            CFTypeRef bundleIdentifier = (__bridge CFTypeRef)(getBundleIdentifier());
            if(CFStringHasPrefix(result, bundleIdentifier))
            {
                return bundleIdentifier;
            }
        }

        if(CFStringCompare(key, CFSTR("ALTBundleIdentifier"), 0) == kCFCompareEqualTo)
        {
            return nil;
        }
	}
	#endif

	return result;
}

// checks to test embedded.mobileprovision file hmm
LS_STATIC CFArrayRef (*orig_CFBundleCopyResourceURLsOfType)(CFBundleRef bundle, CFStringRef resourceType, CFStringRef subDirName);
LS_STATIC CFArrayRef new_CFBundleCopyResourceURLsOfType(CFBundleRef bundle, CFStringRef resourceType, CFStringRef subDirName)
{
	CFArrayRef result = orig_CFBundleCopyResourceURLsOfType(bundle, resourceType, subDirName);
	if(!isCallerTweak() && result)
	{
        CFIndex count = CFArrayGetCount(result);
        for (CFIndex i = 0; i < count; i++)
        {
            CFURLRef url = CFArrayGetValueAtIndex(result, i);
            if(isCFURLRestricted(url))
            {
                CFArrayRemoveValueAtIndex((CFMutableArrayRef)result, i);
            }
        }
	}

	return result;
}

LS_STATIC CFArrayRef (*orig_CFBundleCopyResourceURLsOfTypeInDirectory)(CFURLRef bundleURL, CFStringRef resourceType, CFStringRef subDirName);
LS_STATIC CFArrayRef new_CFBundleCopyResourceURLsOfTypeInDirectory(CFURLRef bundleURL, CFStringRef resourceType, CFStringRef subDirName)
{
	CFArrayRef result = orig_CFBundleCopyResourceURLsOfTypeInDirectory(bundleURL, resourceType, subDirName);
	if(!isCallerTweak() && result)
	{
        CFIndex count = CFArrayGetCount(result);
        for (CFIndex i = 0; i < count; i++)
        {
            CFURLRef url = CFArrayGetValueAtIndex(result, i);
            if(isCFURLRestricted(url))
            {
                CFArrayRemoveValueAtIndex((CFMutableArrayRef)result, i);
            }
        }
	}

	return result;
}

// hmm
LS_STATIC CFURLRef (*orig_CFBundleCopyResourceURLForLocalization)(CFBundleRef bundle, CFStringRef resourceName, CFStringRef resourceType, CFStringRef subDirName, CFStringRef localizationName);
LS_STATIC CFURLRef new_CFBundleCopyResourceURLForLocalization(CFBundleRef bundle, CFStringRef resourceName, CFStringRef resourceType, CFStringRef subDirName, CFStringRef localizationName)
{
	CFURLRef result = orig_CFBundleCopyResourceURLForLocalization(bundle, resourceName, resourceType, subDirName, localizationName);
	if(!isCallerTweak() && result)
	{
		if(isCFURLRestricted(result))
		{
			return nil;
		}
	}

	return result;
}

LS_STATIC CFArrayRef (*orig_CFBundleCopyResourceURLsOfTypeForLocalization)(CFBundleRef bundle, CFStringRef resourceType, CFStringRef subDirName, CFStringRef localizationName);
LS_STATIC CFArrayRef new_CFBundleCopyResourceURLsOfTypeForLocalization(CFBundleRef bundle, CFStringRef resourceType, CFStringRef subDirName, CFStringRef localizationName)
{
	CFArrayRef result = orig_CFBundleCopyResourceURLsOfTypeForLocalization(bundle, resourceType, subDirName, localizationName);
	if(!isCallerTweak() && result)
	{
        CFIndex count = CFArrayGetCount(result);
        for (CFIndex i = 0; i < count; i++)
        {
            CFURLRef url = CFArrayGetValueAtIndex(result, i);
            if(isCFURLRestricted(url))
            {
                CFArrayRemoveValueAtIndex((CFMutableArrayRef)result, i);
            }
        }
	}

	return result;
}

LS_STATIC CFBundleRef (*orig_CFBundleGetBundleWithIdentifier)(CFBundleRef bundle);
LS_STATIC CFBundleRef new_CFBundleGetBundleWithIdentifier(CFBundleRef bundle)
{
	CFBundleRef result = orig_CFBundleGetBundleWithIdentifier(bundle);
	if(!isCallerTweak() && result)
	{
		if(isCFURLRestricted(CFBundleCopyBundleURL(result)))
		{
			return nil;
		}
	}

	return result;
}

//MARK: - Unfinished 
LS_STATIC const void * (*orig_CFDictionaryGetValue)(CFDictionaryRef theDict, const void *key);
LS_STATIC const void * new_CFDictionaryGetValue(CFDictionaryRef theDict, const void *key) 
{
	const void* result = orig_CFDictionaryGetValue(theDict, key);
	# if 0
	if(!isCallerTweak() && result) 
	{
        const void* bundleIdentifier = (__bridge const void*)(getBundleIdentifier());
		if(CFStringCompare(key, CFSTR("CFBundleIdentifier"), 0) == kCFCompareEqualTo)
        {
            return bundleIdentifier;
		}

        if(CFStringCompare(key, CFSTR("ALTBundleIdentifier"), 0) == kCFCompareEqualTo)
        {
            return nil;
        }

		if(CFStringCompare(key, CFSTR("application-identifier"), 0) == kCFCompareEqualTo)
        {
            
        }

		if(CFStringCompare(key, CFSTR("com.apple.developer.team-identifier"), 0) == kCFCompareEqualTo)
        {
            
        }
	}
	#endif

	return result;
}

LS_STATIC Boolean (*orig_CFDictionaryGetValueIfPresent)(CFDictionaryRef theDict, const void *key, const void **value);
LS_STATIC Boolean new_CFDictionaryGetValueIfPresent(CFDictionaryRef theDict, const void *key, const void **value)
{
	Boolean result = orig_CFDictionaryGetValueIfPresent(theDict, key, value);
	/*
	if(!isCallerTweak() && result)
	{
        CFStringRef bundleIdentifier = (__bridge CFStringRef)(getBundleIdentifier());
		if(CFStringCompare(key, CFSTR("CFBundleIdentifier"), 0) == kCFCompareEqualTo)
        {
            *value = bundleIdentifier;
		}

        if(CFStringCompare(key, CFSTR("ALTBundleIdentifier"), 0) == kCFCompareEqualTo)
        {
            *value = nil;
            return 0;
        }
	}
	*/
	return result;
}

LS_STATIC bool (*orig_CFDictionaryGetKeyIfPresent)(CFDictionaryRef dict, const void *key, const void **actualkey);
LS_STATIC bool new_CFDictionaryGetKeyIfPresent(CFDictionaryRef dict, const void *key, const void **actualkey)
{
	bool result = orig_CFDictionaryGetKeyIfPresent(dict, key, actualkey);
	/*
	if(!isCallerTweak() && result)
	{
        if(CFStringCompare(key, CFSTR("ALTBundleIdentifier"), 0) == kCFCompareEqualTo)
        {
            *actualkey = NULL;
            return 0;
        }
	}
	*/
	return result;
}

void _supporthook_CFBundle(void)
{
	LS_AutoHookSymbol(CFBundleGetIdentifier);
    LS_AutoHookSymbol(CFBundleGetInfoDictionary);
    LS_AutoHookSymbol(CFBundleGetLocalInfoDictionary);
    LS_AutoHookSymbol(CFBundleCopyInfoDictionaryInDirectory);
    LS_AutoHookSymbol(CFBundleCopyBundleURL);
    LS_AutoHookSymbol(CFBundleGetBundleWithIdentifier);
    LS_AutoHookSymbol(CFBundleCopyResourceURLsOfTypeForLocalization);
    LS_AutoHookSymbol(CFBundleCopyResourceURLForLocalization);
    LS_AutoHookSymbol(CFBundleCopyResourceURLsOfTypeInDirectory);
    LS_AutoHookSymbol(CFBundleCopyResourceURLsOfType);
    LS_AutoHookSymbol(CFBundleCopyResourceURLInDirectory);
    LS_AutoHookSymbol(CFBundleCopyResourceURL);
    LS_AutoHookSymbol(CFBundleGetValueForInfoDictionaryKey);
	LS_AutoHookSymbol(CFDictionaryGetValue);
	LS_AutoHookSymbol(CFDictionaryGetValueIfPresent);
    LS_AutoHookSymbol(CFDictionaryGetKeyIfPresent);
}