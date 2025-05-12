#import "hooks.h"

LS_STATIC id (*NSData$$orig_dataWithContentsOfFile)(id self, SEL selector, NSString *path);
LS_STATIC id NSData$$new_dataWithContentsOfFile(id self, SEL selector, NSString *path) 
{
    if(!isCallerTweak() && isPathRestricted(path))
	{
        return nil;
    }

    return NSData$$orig_dataWithContentsOfFile(self, selector, path);
}

LS_STATIC id (*NSData$$orig_dataWithContentsOfFile$options$error)(id self, SEL selector, NSString *path, NSDataReadingOptions readOptionsMask, NSError * _Nullable * errorPtr);
LS_STATIC id NSData$$new_dataWithContentsOfFile$options$error(id self, SEL selector, NSString *path, NSDataReadingOptions readOptionsMask, NSError * _Nullable * errorPtr) 
{
    if(!isCallerTweak() && isPathRestricted(path)) 
	{
        if(errorPtr) 
		{
            *errorPtr = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        }

        return nil;
    }

    return NSData$$orig_dataWithContentsOfFile$options$error(self, selector, path, readOptionsMask, errorPtr);
}

LS_STATIC id (*NSData$$orig_dataWithContentsOfURL)(id self, SEL selector, NSURL *url);
LS_STATIC id NSData$$new_dataWithContentsOfURL(id self, SEL selector, NSURL *url) 
{
	NSString* path = url.absoluteString;
    if(!isCallerTweak() && isPathRestricted(path)) 
	{
        return nil;
    }

    return NSData$$orig_dataWithContentsOfURL(self, selector, url);
}

LS_STATIC id (*NSData$$orig_initWithContentsOfURL$options$error)(id self, SEL selector, NSURL *url, NSDataReadingOptions readOptionsMask, NSError * _Nullable *errorPtr);
LS_STATIC id NSData$$new_initWithContentsOfURL$options$error(id self, SEL selector, NSURL *url, NSDataReadingOptions readOptionsMask, NSError * _Nullable *errorPtr){
	NSString *path = url.absoluteString;
	if(!isCallerTweak() && isPathRestricted(path))
    {
		if(errorPtr) 
		{
            *errorPtr = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

		// DLOG(@"%@", path);
		return nil;
	}

	return NSData$$orig_initWithContentsOfURL$options$error(self, selector, url, readOptionsMask, errorPtr);
}

void _supporthook_NSData(void)
{
    SupportHookClassMessage("NSData", "dataWithContentsOfFile:", NSData$$new_dataWithContentsOfFile, NSData$$orig_dataWithContentsOfFile);
	SupportHookClassMessage("NSData", "dataWithContentsOfURL:", NSData$$new_dataWithContentsOfURL, NSData$$orig_dataWithContentsOfURL);
	SupportHookClassMessage("NSData", "dataWithContentsOfFile:options:error:", NSData$$new_dataWithContentsOfFile$options$error, NSData$$orig_dataWithContentsOfFile$options$error);
	SupportHookInstanceMessage("NSData", "initWithContentsOfURL:options:error:", NSData$$new_initWithContentsOfURL$options$error, NSData$$orig_initWithContentsOfURL$options$error);
}