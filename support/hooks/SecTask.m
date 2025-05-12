#include "hooks.h"

LS_STATIC CFDictionaryRef (*orig_SecTaskCopyValuesForEntitlements)(SecTaskRef task, CFArrayRef entitlements, CFErrorRef  _Nullable *error);
LS_STATIC CFDictionaryRef new_SecTaskCopyValuesForEntitlements(SecTaskRef task, CFArrayRef entitlements, CFErrorRef  _Nullable *error)
{
	NSLog(@"new_SecTaskCopyValuesForEntitlements");
	CFDictionaryRef result = orig_SecTaskCopyValuesForEntitlements(task, entitlements, error);
	if(!isCallerTweak() && result)
	{
		static CFStringRef applicationIdentifierKey = CFSTR("application-identifier");
		static CFStringRef teamIdentifierKey = CFSTR("com.apple.developer.team-identifier");

        CFStringRef bundleIdentifier = (__bridge CFStringRef)(getBundleIdentifier());
        
		CFStringRef _applicationIdentifier = CFDictionaryGetValue(result, applicationIdentifierKey);
        CFStringRef _teamIdentifier = CFDictionaryGetValue(result, teamIdentifierKey);

		if(_applicationIdentifier != NULL && _teamIdentifier != NULL)
		{
			if(CFStringHasPrefix(_applicationIdentifier, bundleIdentifier))
			{
				NSLog(@"result: _teamIdentifier --> %@", _teamIdentifier);
				CFMutableStringRef applicationIdentifier = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(_teamIdentifier), _teamIdentifier);
				CFStringAppend(applicationIdentifier, CFSTR("."));
				CFStringAppend(applicationIdentifier, bundleIdentifier);

				NSLog(@"result: applicationIdentifier --> %@", applicationIdentifier);
				CFDictionarySetValue((CFMutableDictionaryRef)result, applicationIdentifierKey, applicationIdentifier);
			}
		}
	}

	return result;
}

LS_STATIC CFStringRef (*orig_SecTaskCopySigningIdentifier)(SecTaskRef task, CFErrorRef  _Nullable *error);
LS_STATIC CFStringRef new_SecTaskCopySigningIdentifier(SecTaskRef task, CFErrorRef  _Nullable *error)
{
	CFStringRef result = orig_SecTaskCopySigningIdentifier(task, error);
	if(result)
	{
		CFStringRef bundleIdentifier = (__bridge CFStringRef)(getBundleIdentifier());
		if(CFStringHasPrefix(result, bundleIdentifier))
		{
			return bundleIdentifier;
		}
	}

	return result;
}

/*
OSStatus (*orig_SecCodeCopySigningInformation)(SecStaticCodeRef code, SecCSFlags flags, CFDictionaryRef  _Nullable *information);
OSStatus new_SecCodeCopySigningInformation(SecStaticCodeRef code, SecCSFlags flags, CFDictionaryRef  _Nullable *information) {
	return 0;
}
*/

void _supporthook_SecTask(void)
{
	SupportHookSymbolEx("SecTaskCopyValuesForEntitlements", new_SecTaskCopyValuesForEntitlements, (void **)&orig_SecTaskCopyValuesForEntitlements);
	SupportHookSymbolEx("SecTaskCopySigningIdentifier", new_SecTaskCopySigningIdentifier, (void **)&orig_SecTaskCopySigningIdentifier);
	// SupportHookSymbolEx("SecCodeCopySigningInformation", new_SecCodeCopySigningInformation, (void **)&orig_SecCodeCopySigningInformation);
}