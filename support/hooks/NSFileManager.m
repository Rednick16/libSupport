#import "hooks.h"

LS_STATIC BOOL (*orig_fileExistsAtPath)(id self, SEL selector, NSString* path);
LS_STATIC BOOL new_fileExistsAtPath(id self, SEL selector, NSString* path) 
{
	if(!isCallerTweak() && isPathRestricted(path))
	{
		// LSLog(@"%@", path);
		return NO;
	}
	return orig_fileExistsAtPath(self, selector, path);
}

LS_STATIC BOOL (*orig_fileExistsAtPath$isDirectory)(id self, SEL selector, NSString* path, BOOL* isDirectory);
LS_STATIC BOOL new_fileExistsAtPath$isDirectory(id self, SEL selector, NSString* path, BOOL* isDirectory) 
{
	if(!isCallerTweak() && isPathRestricted(path))
	{
		// LSLog(@"%@", path);
		*isDirectory = NO;
		return NO;
	}
	return orig_fileExistsAtPath$isDirectory(self, selector, path, isDirectory);
}

void _supporthook_NSFileManager(void)
{
    SupportHookInstanceMessage("NSFileManager", "fileExistsAtPath:", new_fileExistsAtPath, orig_fileExistsAtPath);
	SupportHookInstanceMessage("NSFileManager", "fileExistsAtPath:isDirectory:", new_fileExistsAtPath$isDirectory, orig_fileExistsAtPath$isDirectory);
}