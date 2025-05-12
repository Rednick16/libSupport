#import "hooks.h"

LS_STATIC id (*orig_objectForInfoDictionaryKey)(id self, SEL selector, NSString* key);
LS_STATIC id new_objectForInfoDictionaryKey(id self, SEL selector, NSString* key) 
{
    // sanitized by infoDictionary.
	return orig_objectForInfoDictionaryKey(self, selector, key);
}

LS_STATIC NSString *(*orig_bundleIdentifier)(id self, SEL selector);
LS_STATIC NSString *new_bundleIdentifier(id self, SEL selector) 
{
    // sanitized by infoDictionary.
    return orig_bundleIdentifier(self, selector);
}

LS_STATIC NSURL *(*orig_URLForResource)(id self, SEL selector, NSString *name, NSString *ext);
LS_STATIC NSURL *new_URLForResource(id self, SEL selector, NSString *name, NSString *ext) 
{
	NSURL* result = orig_URLForResource(self, selector, name, ext);
	if(!isCallerTweak() && isURLRestricted(result))
    {
		return nil;
	}
	
	return result;
}

LS_STATIC NSURL *(*orig_URLForResource_withExtension_subdirectory)(id self, SEL selector, NSString *name, NSString *ex, NSString* subpath);
LS_STATIC NSURL *new_URLForResource_withExtension_subdirectory(id self, SEL selector, NSString *name, NSString *ext, NSString* subpath) 
{
	NSURL* result = orig_URLForResource_withExtension_subdirectory(self, selector, name, ext, subpath);
	if(!isCallerTweak() && isURLRestricted(result))
    {
		return nil;
	}
	
	return result;
}

LS_STATIC NSURL *(*orig_URLForResource_withExtension_subdirectory_localization)(id self, SEL selector, NSString *name, NSString *ex, NSString* subpath, NSString *localizationName);
LS_STATIC NSURL *new_URLForResource_withExtension_subdirectory_localization(id self, SEL selector, NSString *name, NSString *ext, NSString* subpath, NSString *localizationName) 
{
	NSURL* result = orig_URLForResource_withExtension_subdirectory_localization(self, selector, name, ext, subpath, localizationName);
	if(!isCallerTweak() && isURLRestricted(result))
    {
		return nil;
	}
	
	return result;
}

LS_STATIC NSURL *(*orig_URLForResource_withExtension_subdirectory_inBundleWithURL)(id self, SEL selector, NSString *name, NSString *ex, NSString* subpath, NSURL *bundleURL);
LS_STATIC NSURL *new_URLForResource_withExtension_subdirectory_inBundleWithURL(id self, SEL selector, NSString *name, NSString *ext, NSString* subpath, NSURL *bundleURL) 
{
    NSURL* result = orig_URLForResource_withExtension_subdirectory_inBundleWithURL(self, selector, name, ext, subpath, bundleURL);
	if(!isCallerTweak() && isURLRestricted(result))
    {
		return nil;
	}
	
	return result;
}

LS_STATIC id (*orig_URLsForResourcesWithExtension$subdirectory)(id self, SEL selector, NSString *ext, NSString *subpath);
LS_STATIC id new_URLsForResourcesWithExtension$subdirectory(id self, SEL selector, NSString *ext, NSString *subpath) 
{
    NSMutableArray* result = [orig_URLsForResourcesWithExtension$subdirectory(self, selector, ext, subpath) mutableCopy];

    if(!isCallerTweak() && result)
    {
        for(NSURL* url in result) 
        {
            if(isURLRestricted(url)) 
            {
                [result removeObject:url];
            }
        }
    }

    return result;
}

LS_STATIC id (*orig_URLsForResourcesWithExtension$subdirectory$localization)(id self, SEL selector, NSString *ext, NSString *subpath, NSString* localizationName);
LS_STATIC id new_URLsForResourcesWithExtension$subdirectory$localization(id self, SEL selector, NSString *ext, NSString *subpath, NSString* localizationName) 
{
    NSMutableArray* result = [orig_URLsForResourcesWithExtension$subdirectory$localization(self, selector, ext, subpath, localizationName) mutableCopy];

    if(!isCallerTweak() && result)
    {
        for(NSURL* url in result) 
        {
            if(isURLRestricted(url)) 
            {
                [result removeObject:url];
            }
        }
    }

    return result;
}

LS_STATIC id (*orig_URLsForResourcesWithExtension$subdirectory$inBundleWithURL)(id self, SEL selector, NSString *ext, NSString *subpath, NSURL* bundleURL);
LS_STATIC id new_URLsForResourcesWithExtension$subdirectory$inBundleWithURL(id self, SEL selector, NSString *ext, NSString *subpath, NSURL* bundleURL) 
{
    NSMutableArray* result = [orig_URLsForResourcesWithExtension$subdirectory$inBundleWithURL(self, selector, ext, subpath, bundleURL) mutableCopy];

    if(!isCallerTweak() && result)
    {
        for(NSURL* url in result) 
        {
            if(isURLRestricted(url)) 
            {
                [result removeObject:url];
            }
        }
    }

    return result;
}

LS_STATIC NSString *(*orig_pathForResource)(id self, SEL selector, NSString *name, NSString *ext);
LS_STATIC NSString *new_pathForResource(id self, SEL selector, NSString *name, NSString *ext) 
{
    NSString* result = orig_pathForResource(self, selector, name, ext);
	if(!isCallerTweak() && isPathRestricted(result))
    {
		return nil;
	}
	
	return result;
}

LS_STATIC NSString *(*origC_pathForResource$ofType$inDirectory)(id self, SEL selector, NSString *name, NSString *ext, NSString* bundlePath);
LS_STATIC NSString *newC_pathForResource$ofType$inDirectory(id self, SEL selector, NSString *name, NSString *ext, NSString* bundlePath) 
{
    NSString* result = origC_pathForResource$ofType$inDirectory(self, selector, name, ext, bundlePath);
	if(!isCallerTweak() && isPathRestricted(result))
    {
		//DLOG(@"name:%@\next:%@", name, ext);
		return nil;
	}
	
	return result;
}

LS_STATIC NSString *(*orig_pathForResource$inDirectory)(id self, SEL selector, NSString *name, NSString *ext, NSString* subpath);
LS_STATIC NSString *new_pathForResource$inDirectory(id self, SEL selector, NSString *name, NSString *ext, NSString* subpath) 
{
    NSString* result = orig_pathForResource$inDirectory(self, selector, name, ext, subpath);
	if(!isCallerTweak() && isPathRestricted(result))
    {
		//DLOG(@"name:%@\next:%@", name, ext);
		return nil;
	}
	
	return result;
}

LS_STATIC NSString *(*orig_pathForResource$inDirectory$forLocalization)(id self, SEL selector, NSString *name, NSString *ext, NSString* subpath, NSString *localizationName);
LS_STATIC NSString *new_pathForResource$inDirectory$forLocalization(id self, SEL selector, NSString *name, NSString *ext, NSString* subpath, NSString *localizationName) 
{
    NSString* result = orig_pathForResource$inDirectory$forLocalization(self, selector, name, ext, subpath, localizationName);
	if(!isCallerTweak() && isPathRestricted(result))
    {
		return nil;
	}
	
	return result;
}

LS_STATIC id (*orig_pathsForResourcesOfType$inDirectory)(id self, SEL selector, NSString *ext, NSString *subpath);
LS_STATIC id new_pathsForResourcesOfType$inDirectory(id self, SEL selector, NSString *ext, NSString *subpath) 
{
    NSMutableArray* result = [orig_pathsForResourcesOfType$inDirectory(self, selector, ext, subpath) mutableCopy];

    if(!isCallerTweak() && result)
    {
        for(NSString* path in result) 
        {
            if(isPathRestricted(path)) 
            {
                [result removeObject:path];
            }
        }
    }

    return result;
}

LS_STATIC id (*orig_pathsForResourcesOfType$inDirectory$forLocalization)(id self, SEL selector, NSString *ext, NSString *subpath, NSString* localizationName);
LS_STATIC id new_pathsForResourcesOfType$inDirectory$forLocalization(id self, SEL selector, NSString *ext, NSString *subpath, NSString* localizationName) 
{
    NSMutableArray* result = [orig_pathsForResourcesOfType$inDirectory$forLocalization(self, selector, ext, subpath, localizationName) mutableCopy];

    if(!isCallerTweak() && result)
    {
        for(NSString* path in result) 
        {
            if(isPathRestricted(path)) 
            {
                [result removeObject:path];
            }
        }
    }

    return result;
}

LS_STATIC id (*origC_pathsForResourcesOfType$inDirectory)(id self, SEL selector, NSString *ext, NSString *bundlePath);
LS_STATIC id newC_pathsForResourcesOfType$inDirectory(id self, SEL selector, NSString *ext, NSString *bundlePath) 
{
    NSMutableArray* result = [origC_pathsForResourcesOfType$inDirectory(self, selector, ext, bundlePath) mutableCopy];

    if(!isCallerTweak() && result)
    {
        for(NSString* path in result) 
        {
            if(isPathRestricted(path)) 
            {
                [result removeObject:path];
            }
        }
    }

    return result;
}

LS_STATIC id (*orig_bundleWithURL)(id self, SEL selector, NSURL *url);
LS_STATIC id new_bundleWithURL(id self, SEL selector, NSURL *url) 
{
	if(!isCallerTweak() && isURLRestricted(url))
    {
		return nil;
	}
	
	return orig_bundleWithURL(self, selector, url);
}

LS_STATIC id (*orig_bundleWithPath)(id self, SEL selector, NSString *path);
LS_STATIC id new_bundleWithPath(id self, SEL selector, NSString *path) 
{
	if(!isCallerTweak() && isPathRestricted(path))
    {
		return nil;
	}
	
	return orig_bundleWithPath(self, selector, path);
}

LS_STATIC id (*orig_initWithURL)(id self, SEL selector, NSURL *url);
LS_STATIC id new_initWithURL(id self, SEL selector, NSURL *url) 
{
	if(!isCallerTweak() && isURLRestricted(url))
    {
		return nil;
	}
	
	return orig_initWithURL(self, selector, url);
}

LS_STATIC id (*orig_initWithPath)(id self, SEL selector, NSString *path);
LS_STATIC id new_initWithPath(id self, SEL selector, NSString *path) 
{
	if(!isCallerTweak() && isPathRestricted(path))
    {
		return nil;
	}
	
	return orig_initWithPath(self, selector, path);
}

LS_STATIC NSBundle* (*orig_bundleForClass)(id self, SEL selector, Class aClass);
LS_STATIC NSBundle* new_bundleForClass(id self, SEL selector, Class aClass) 
{
	if(!isCallerTweak() && isAddrRestricted((__bridge void *)aClass))
    {
		return nil;
	}
	return orig_bundleForClass(self, selector, aClass);
}

LS_STATIC NSBundle* (*orig_bundleWithIdentifier)(id self, SEL selector, NSString* identifier);
LS_STATIC NSBundle* new_bundleWithIdentifier(id self, SEL selector, NSString* identifier) 
{
	NSBundle* result = orig_bundleWithIdentifier(self, selector, identifier);

	if(!isCallerTweak() && isPathRestricted([result bundlePath]))
    {
		return nil;
	}
	return result;
}

LS_STATIC id (*orig_infoDictionary)(id self, SEL selector);
LS_STATIC id new_infoDictionary(id self, SEL selector) 
{
    id ret = orig_infoDictionary(self, selector);
    if (isCallerTweak() || !ret)
    {
        return ret;
    }

    return getAdjustedDictionary(self, ret, NO);
}

LS_STATIC id (*orig_allBundles)(id self, SEL selector);
LS_STATIC id new_allBundles(id self, SEL selector)
{
    NSMutableArray* result = orig_allBundles(self, selector);
    if(!isCallerTweak() && result)
    {
        for(NSBundle* bundle in result) 
        {
            if(isPathRestricted( [bundle bundlePath] )) 
            {
                [result removeObject:bundle];
            }
        }
    }

    return result;
}

LS_STATIC id (*orig_allFrameworks)(id self, SEL selector);
LS_STATIC id new_allFrameworks(id self, SEL selector)
{
    NSMutableArray* result = orig_allFrameworks(self, selector);
    if(!isCallerTweak() && result)
    {
        for(NSBundle* bundle in result) 
        {
            if(isPathRestricted( [bundle bundlePath] )) 
            {
                [result removeObject:bundle];
            }
        }
    }

    return result;
}

void _supporthook_NSBundle(void)
{
	SupportHookInstanceMessage("NSBundle", "objectForInfoDictionaryKey:", new_objectForInfoDictionaryKey, orig_objectForInfoDictionaryKey);
	SupportHookInstanceMessage("NSBundle", "pathForResource:ofType:", new_pathForResource, orig_pathForResource);
    
    SupportHookInstanceMessage("NSBundle", "pathForResource:ofType:inDirectory:", new_pathForResource$inDirectory, orig_pathForResource$inDirectory);
    SupportHookInstanceMessage("NSBundle", "pathForResource:ofType:inDirectory:forLocalization:", new_pathForResource$inDirectory$forLocalization, orig_pathForResource$inDirectory$forLocalization);
#if 1
	SupportHookInstanceMessage("NSBundle", "pathsForResourcesOfType:inDirectory:", new_pathsForResourcesOfType$inDirectory, orig_pathsForResourcesOfType$inDirectory);
    SupportHookInstanceMessage("NSBundle", "pathsForResourcesOfType:inDirectory:forLocalization:", new_pathsForResourcesOfType$inDirectory$forLocalization, orig_pathsForResourcesOfType$inDirectory$forLocalization);

    SupportHookClassMessage("NSBundle", "pathsForResourcesOfType:inDirectory:", newC_pathsForResourcesOfType$inDirectory, origC_pathsForResourcesOfType$inDirectory);
    SupportHookClassMessage("NSBundle", "pathForResource:ofType:inDirectory:", newC_pathForResource$ofType$inDirectory, origC_pathForResource$ofType$inDirectory);

	SupportHookInstanceMessage("NSBundle", "bundleIdentifier", new_bundleIdentifier, orig_bundleIdentifier);
	SupportHookInstanceMessage("NSBundle", "infoDictionary", new_infoDictionary, orig_infoDictionary);
	
	// highly sensitive hooks
	SupportHookClassMessage("NSBundle", "bundleWithURL:", new_bundleWithURL, orig_bundleWithURL);
	SupportHookClassMessage("NSBundle", "bundleWithPath:", new_bundleWithPath, orig_bundleWithPath);
	SupportHookInstanceMessage("NSBundle", "initWithURL:", new_initWithURL, orig_initWithURL);
	SupportHookInstanceMessage("NSBundle", "initWithPath:", new_initWithPath, orig_initWithPath);
	SupportHookClassMessage("NSBundle", "bundleForClass:", new_bundleForClass, orig_bundleForClass);
	SupportHookClassMessage("NSBundle", "bundleWithIdentifier:", new_bundleWithIdentifier, orig_bundleWithIdentifier);

	SupportHookInstanceMessage("NSBundle", "URLForResource:withExtension:", new_URLForResource, orig_URLForResource);
	SupportHookInstanceMessage("NSBundle", "URLForResource:withExtension:subdirectory:", new_URLForResource_withExtension_subdirectory, orig_URLForResource_withExtension_subdirectory);
	SupportHookInstanceMessage("NSBundle", "URLForResource:withExtension:subdirectory:localization:", new_URLForResource_withExtension_subdirectory_localization, orig_URLForResource_withExtension_subdirectory_localization);
	SupportHookClassMessage("NSBundle", "URLForResource:withExtension:subdirectory:inBundleWithURL:", new_URLForResource_withExtension_subdirectory_inBundleWithURL, orig_URLForResource_withExtension_subdirectory_inBundleWithURL);

	SupportHookInstanceMessage("NSBundle", "URLsForResourcesWithExtension:subdirectory:", new_URLsForResourcesWithExtension$subdirectory, orig_URLsForResourcesWithExtension$subdirectory);
	SupportHookInstanceMessage("NSBundle", "URLsForResourcesWithExtension:subdirectory:localization:", new_URLsForResourcesWithExtension$subdirectory$localization, orig_URLsForResourcesWithExtension$subdirectory$localization);

	SupportHookClassMessage("NSBundle", "URLsForResourcesWithExtension:subdirectory:inBundleWithURL:", new_URLsForResourcesWithExtension$subdirectory$inBundleWithURL, orig_URLsForResourcesWithExtension$subdirectory$inBundleWithURL);

    SupportHookClassMessage("NSBundle", "allBundles", new_allBundles, orig_allBundles);
    SupportHookClassMessage("NSBundle", "allFrameworks", new_allFrameworks, orig_allFrameworks);
#endif
}