#include "hooks.h"

// NSArray
LS_STATIC id (*NSArray$$orig_initWithContentsOfFile$)(id self, SEL selector, NSString* path);
LS_STATIC id NSArray$$new_initWithContentsOfFile$(id self, SEL selector, NSString* path)
{
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSArray$$orig_initWithContentsOfFile$(self, selector, path);
}

LS_STATIC id (*NSArray$$orig_arrayWithContentsOfFile$)(id self, SEL selector, NSString* path);
LS_STATIC id NSArray$$new_arrayWithContentsOfFile$(id self, SEL selector, NSString* path)
{
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSArray$$orig_arrayWithContentsOfFile$(self, selector, path);
}

LS_STATIC id (*NSArray$$orig_arrayWithContentsOfURL$)(id self, SEL selector, NSURL* url);
LS_STATIC id NSArray$$new_arrayWithContentsOfURL$(id self, SEL selector, NSURL* url)
{
    if(!isCallerTweak() && isURLRestricted(url)) 
    {
        return nil;
    }

    return NSArray$$orig_arrayWithContentsOfURL$(self, selector, url);
}

LS_STATIC NSArray * (*NSArray$$orig_initWithContentsOfURL$error$)(id self, SEL selector, NSURL* url, NSError * _Nullable *error);
LS_STATIC NSArray * NSArray$$new_initWithContentsOfURL$error$(id self, SEL selector, NSURL* url, NSError * _Nullable *error)
{
    if(!isCallerTweak() && isURLRestricted(url)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        return nil;
    }

    return NSArray$$orig_initWithContentsOfURL$error$(self, selector, url, error);
}

LS_STATIC NSArray * (*NSArray$$orig_arrayWithContentsOfURL$error$)(id self, SEL selector, NSURL* url, NSError * _Nullable *error);
LS_STATIC NSArray * NSArray$$new_arrayWithContentsOfURL$error$(id self, SEL selector, NSURL* url, NSError * _Nullable *error)
{
    if(!isCallerTweak() && isURLRestricted(url)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        return nil;
    }

    return NSArray$$orig_arrayWithContentsOfURL$error$(self, selector, url, error);
}
// NSArray --> End

// NSMutableArray

LS_STATIC id (*NSMutableArray$$orig_initWithContentsOfFile$)(id self, SEL selector, NSString* path);
LS_STATIC id NSMutableArray$$new_initWithContentsOfFile$(id self, SEL selector, NSString* path)
{
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSMutableArray$$orig_initWithContentsOfFile$(self, selector, path);
}

LS_STATIC id (*NSMutableArray$$orig_initWithContentsOfURL$)(id self, SEL selector, NSURL* url);
LS_STATIC id NSMutableArray$$new_initWithContentsOfURL$(id self, SEL selector, NSURL* url)
{
    if(!isCallerTweak() && isURLRestricted(url)) 
    {
        return nil;
    }

    return NSMutableArray$$orig_initWithContentsOfURL$(self, selector, url);
}

// update here

LS_STATIC id (*NSMutableArray$$orig_arrayWithContentsOfFile$)(id self, SEL selector, NSString* path);
LS_STATIC id NSMutableArray$$new_arrayWithContentsOfFile$(id self, SEL selector, NSString* path)
{
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSMutableArray$$orig_arrayWithContentsOfFile$(self, selector, path);
}

LS_STATIC id (*NSMutableArray$$orig_arrayWithContentsOfURL$)(id self, SEL selector, NSString* path);
LS_STATIC id NSMutableArray$$new_arrayWithContentsOfURL$(id self, SEL selector, NSString* path)
{
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSMutableArray$$orig_arrayWithContentsOfURL$(self, selector, path);
}

void _supporthook_NSArray(void)
{
    // NSArray
	SupportHookInstanceMessage("NSArray", "initWithContentsOfFile:", NSArray$$new_initWithContentsOfFile$, NSArray$$orig_initWithContentsOfFile$);
    SupportHookClassMessage("NSArray", "arrayWithContentsOfFile:", NSArray$$new_arrayWithContentsOfFile$, NSArray$$orig_arrayWithContentsOfFile$);
    SupportHookClassMessage("NSArray", "arrayWithContentsOfURL:", NSArray$$new_arrayWithContentsOfURL$, NSArray$$orig_arrayWithContentsOfURL$);
    SupportHookInstanceMessage("NSArray", "initWithContentsOfURL:error:", NSArray$$new_initWithContentsOfURL$error$, NSArray$$orig_initWithContentsOfURL$error$);
    SupportHookClassMessage("NSArray", "arrayWithContentsOfURL:error:", NSArray$$new_arrayWithContentsOfURL$error$, NSArray$$orig_arrayWithContentsOfURL$error$);

    // NSMutableArray
	SupportHookInstanceMessage("NSMutableArray", "initWithContentsOfFile:", NSMutableArray$$new_initWithContentsOfFile$, NSMutableArray$$orig_initWithContentsOfFile$);
	SupportHookInstanceMessage("NSMutableArray", "initWithContentsOfURL:", NSMutableArray$$new_initWithContentsOfURL$, NSMutableArray$$orig_initWithContentsOfURL$);
    SupportHookClassMessage("NSMutableArray", "arrayWithContentsOfFile:", NSMutableArray$$new_arrayWithContentsOfFile$, NSMutableArray$$orig_arrayWithContentsOfFile$);
    SupportHookClassMessage("NSMutableArray", "arrayWithContentsOfURL:", NSMutableArray$$new_arrayWithContentsOfURL$, NSMutableArray$$orig_arrayWithContentsOfURL$);
}
