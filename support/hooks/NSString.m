#import "hooks.h"

LS_STATIC id (*orig_stringWithContentsOfFile)(id self, SEL selector, NSString *path, NSStringEncoding enc, NSError * _Nullable *error);
LS_STATIC id new_stringWithContentsOfFile(id self, SEL selector, NSString *path, NSStringEncoding enc, NSError * _Nullable *error)
{
	if(!isCallerTweak() && isPathRestricted(path))
	{
		// DLOG(@"%@", path);
		return nil;
	}
    
	return orig_stringWithContentsOfFile(self, selector, path, enc, error);
}

LS_STATIC id (*orig_stringWithContentsOfURL)(id self, SEL selector, NSURL *url, NSStringEncoding enc, NSError * _Nullable *error);
LS_STATIC id new_stringWithContentsOfURL(id self, SEL selector, NSURL *url, NSStringEncoding enc, NSError * _Nullable *error)
{
	if(!isCallerTweak() && isURLRestricted(url))
	{
		// DLOG(@"%@", path);
		return nil;
	}
	return orig_stringWithContentsOfURL(self, selector, url, enc, error);
}

void _supporthook_NSString(void)
{
    SupportHookInstanceMessage("NSString", "stringWithContentsOfFile:encoding:error:", new_stringWithContentsOfFile, orig_stringWithContentsOfFile);
	SupportHookInstanceMessage("NSString", "stringWithContentsOfURL:encoding:error:", new_stringWithContentsOfURL, orig_stringWithContentsOfURL);
}