#include "hooks.h"

// NSDictionary
LS_STATIC id (*NSDictionary$$orig_initWithContentsOfFile$)(id self, SEL selector, NSString* path);
LS_STATIC id NSDictionary$$new_initWithContentsOfFile$(id self, SEL selector, NSString* path)
{
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return getAdjustedDictionary(self, NSDictionary$$orig_initWithContentsOfFile$(self, selector, path), NO);
}

LS_STATIC id (*NSDictionary$$orig_initWithContentsOfURL$)(id self, SEL selector, NSURL* url);
LS_STATIC id NSDictionary$$new_initWithContentsOfURL$(id self, SEL selector, NSURL* url)
{
    if(!isCallerTweak() && isURLRestricted(url)) 
    {
        return nil;
    }

    return getAdjustedDictionary(self, NSDictionary$$orig_initWithContentsOfURL$(self, selector, url), NO);

}

LS_STATIC id (*NSDictionary$$orig_initWithContentsOfURL$error$)(id self, SEL selector, NSURL* url, NSError * _Nullable *error);
LS_STATIC id NSDictionary$$new_initWithContentsOfURL$error$(id self, SEL selector, NSURL* url, NSError * _Nullable *error)
{
    if(!isCallerTweak() && isURLRestricted(url)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        return nil;
    }

    return getAdjustedDictionary(self, NSDictionary$$orig_initWithContentsOfURL$error$(self, selector, url, error), NO);

}

LS_STATIC id (*NSDictionary$$orig_dictionaryWithContentsOfFile$)(id self, SEL selector, NSString* path);
LS_STATIC id NSDictionary$$new_dictionaryWithContentsOfFile$(id self, SEL selector, NSString* path)
{
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return getAdjustedDictionary(self, NSDictionary$$orig_dictionaryWithContentsOfFile$(self, selector, path), NO);

}

LS_STATIC id (*NSDictionary$$orig_dictionaryWithContentsOfURL$)(id self, SEL selector, NSURL* url);
LS_STATIC id NSDictionary$$new_dictionaryWithContentsOfURL$(id self, SEL selector, NSURL* url)
{
    if(!isCallerTweak() && isURLRestricted(url)) 
    {
        return nil;
    }

    return getAdjustedDictionary(self, NSDictionary$$orig_dictionaryWithContentsOfURL$(self, selector, url), NO);

}

LS_STATIC id (*NSDictionary$$orig_dictionaryWithContentsOfURL$error$)(id self, SEL selector, NSURL* url, NSError * _Nullable *error);
LS_STATIC id NSDictionary$$new_dictionaryWithContentsOfURL$error$(id self, SEL selector, NSURL* url, NSError * _Nullable *error)
{
    if(!isCallerTweak() && isURLRestricted(url)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        return nil;
    }

    return getAdjustedDictionary(self, NSDictionary$$orig_dictionaryWithContentsOfURL$error$(self, selector, url, error), NO);
}

# if 0
LS_STATIC id (*NSDictionary$$orig_allKeysForObject$)(id self, SEL selector, id anObject);
LS_STATIC id NSDictionary$$new_allKeysForObject$(id self, SEL selector, id anObject)
{
    NSMutableArray* result = [NSDictionary$$orig_allKeysForObject$(self, selector, anObject) mutableCopy];
    if(result)
    {
        for(NSString* key in result)
        {
            if([key isEqualToString:@"ALTBundleIdentifier"])
            {
                [result removeObject:key];
            }
        }
    }

    return result;
}

LS_STATIC id (*NSDictionary$$orig_allKeys)(id self, SEL selector);
LS_STATIC id NSDictionary$$new_allKeys(id self, SEL selector)
{
    NSMutableArray* result = [NSDictionary$$orig_allKeys(self, selector) mutableCopy];
    if(result)
    {
        for(NSString* key in result)
        {
            if([key isEqualToString:@"ALTBundleIdentifier"])
            {
                [result removeObject:key];
            }
        }
    }

    return result;
}

LS_STATIC id (*NSDictionary$$orig_allValues)(id self, SEL selector);
LS_STATIC id NSDictionary$$new_allValues(id self, SEL selector)
{
    NSMutableArray* result = [NSDictionary$$orig_allValues(self, selector) mutableCopy];
    if(result)
    {
        for(id value in result)
        {
            if([value isKindOfClass:[NSString class]]) {
                NSString* stringValue = (NSString *)value;

                NSString* bundleIdentifier = getBundleIdentifier();
                if([stringValue hasPrefix:bundleIdentifier])
                {
                    [result replaceObjectAtIndex:[result indexOfObject:value] 
                    withObject:bundleIdentifier];
                }
            }
        }
    }

    return result;
}
#endif

LS_STATIC id (*NSDictionary$$orig_objectForKey$)(id self, SEL selector, id aKey);
LS_STATIC id NSDictionary$$new_objectForKey$(id self, SEL selector, id aKey)
{
    return NSDictionary$$orig_objectForKey$(self, selector, aKey);
}

LS_STATIC id (*NSDictionary$$orig_objectForKeyedSubscript$)(id self, SEL selector, id key);
LS_STATIC id NSDictionary$$new_objectForKeyedSubscript$(id self, SEL selector, id key)
{
    return NSDictionary$$orig_objectForKeyedSubscript$(self, selector, key);
}

LS_STATIC id (*NSDictionary$$orig_valueForKey$)(id self, SEL selector, id aKey);
LS_STATIC id NSDictionary$$new_valueForKey$(id self, SEL selector, id aKey)
{
    return NSDictionary$$orig_valueForKey$(self, selector, aKey);
}

// NSMutableDictionary
LS_STATIC id (*NSMutableDictionary$$orig_initWithContentsOfFile$)(id self, SEL selector, NSString* path);
LS_STATIC id NSMutableDictionary$$new_initWithContentsOfFile$(id self, SEL selector, NSString* path)
{
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return getAdjustedDictionary(self, NSMutableDictionary$$orig_initWithContentsOfFile$(self, selector, path), YES);
}

LS_STATIC id (*NSMutableDictionary$$orig_initWithContentsOfURL$)(id self, SEL selector, NSURL* url);
LS_STATIC id NSMutableDictionary$$new_initWithContentsOfURL$(id self, SEL selector, NSURL* url)
{
    if(!isCallerTweak() && isURLRestricted(url)) 
    {
        return nil;
    }

    return getAdjustedDictionary(self, NSMutableDictionary$$orig_initWithContentsOfURL$(self, selector, url), YES);
}

LS_STATIC id (*NSMutableDictionary$$orig_dictionaryWithContentsOfFile$)(id self, SEL selector, NSString* path);
LS_STATIC id NSMutableDictionary$$new_dictionaryWithContentsOfFile$(id self, SEL selector, NSString* path)
{
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return getAdjustedDictionary(self, NSMutableDictionary$$orig_dictionaryWithContentsOfFile$(self, selector, path), YES);
}

LS_STATIC id (*NSMutableDictionary$$orig_dictionaryWithContentsOfURL$)(id self, SEL selector, NSURL* url);
LS_STATIC id NSMutableDictionary$$new_dictionaryWithContentsOfURL$(id self, SEL selector, NSURL* url)
{
    if(!isCallerTweak() && isURLRestricted(url)) 
    {
        return nil;
    }

    return getAdjustedDictionary(self, NSMutableDictionary$$orig_dictionaryWithContentsOfURL$(self, selector, url), YES);
}

void _supporthook_NSDictionary()
{
    // NSDictionary
    SupportHookInstanceMessage("NSDictionary", "initWithContentsOfFile:", NSDictionary$$new_initWithContentsOfFile$, NSDictionary$$orig_initWithContentsOfFile$);
    SupportHookInstanceMessage("NSDictionary", "initWithContentsOfURL:", NSDictionary$$new_initWithContentsOfURL$, NSDictionary$$orig_initWithContentsOfURL$);
    SupportHookInstanceMessage("NSDictionary", "initWithContentsOfURL:error:", NSDictionary$$new_initWithContentsOfURL$error$, NSDictionary$$orig_initWithContentsOfURL$error$);
    SupportHookClassMessage("NSDictionary", "dictionaryWithContentsOfFile:", NSDictionary$$new_dictionaryWithContentsOfFile$, NSDictionary$$orig_dictionaryWithContentsOfFile$);
    SupportHookClassMessage("NSDictionary", "dictionaryWithContentsOfURL:", NSDictionary$$new_dictionaryWithContentsOfURL$, NSDictionary$$orig_dictionaryWithContentsOfURL$);
    SupportHookClassMessage("NSDictionary", "dictionaryWithContentsOfURL:error:", NSDictionary$$new_dictionaryWithContentsOfURL$error$, NSDictionary$$orig_dictionaryWithContentsOfURL$error$);

    // SupportHookInstanceMessage("NSDictionary", "allKeysForObject:", NSDictionary$$new_allKeysForObject$, NSDictionary$$orig_allKeysForObject$);
    // SupportHookInstanceMessage("NSDictionary", "allKeys", NSDictionary$$new_allKeys, NSDictionary$$orig_allKeys);
    // SupportHookInstanceMessage("NSDictionary", "allValues", NSDictionary$$new_allValues, NSDictionary$$orig_allValues);
    SupportHookInstanceMessage("NSDictionary", "valueForKey:", NSDictionary$$new_valueForKey$, NSDictionary$$orig_valueForKey$);
    SupportHookInstanceMessage("NSDictionary", "objectForKey:", NSDictionary$$new_objectForKey$, NSDictionary$$orig_objectForKey$);
    SupportHookInstanceMessage("NSDictionary", "objectForKeyedSubscript:", NSDictionary$$new_objectForKeyedSubscript$, NSDictionary$$orig_objectForKeyedSubscript$);

    // NSMutableDictionary
    SupportHookInstanceMessage("NSMutableDictionary", "initWithContentsOfFile:", NSMutableDictionary$$new_initWithContentsOfFile$, NSMutableDictionary$$orig_initWithContentsOfFile$);
    SupportHookInstanceMessage("NSMutableDictionary", "initWithContentsOfURL:", NSMutableDictionary$$new_initWithContentsOfURL$, NSMutableDictionary$$orig_initWithContentsOfURL$);
    SupportHookClassMessage("NSMutableDictionary", "dictionaryWithContentsOfFile:", NSMutableDictionary$$new_dictionaryWithContentsOfFile$, NSMutableDictionary$$orig_dictionaryWithContentsOfFile$);
    SupportHookClassMessage("NSMutableDictionary", "dictionaryWithContentsOfURL:", NSMutableDictionary$$new_dictionaryWithContentsOfURL$, NSMutableDictionary$$orig_dictionaryWithContentsOfURL$);
}
