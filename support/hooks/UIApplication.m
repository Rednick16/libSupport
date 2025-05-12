#import "hooks.h"

BOOL (*orig_canOpenURL)(id self, SEL _cmd, NSURL *url);
BOOL new_canOpenURL(id self, SEL _cmd, NSURL *url)
{
    if(!isCallerTweak() && isURLRestricted(url))
    {
        return NO;
    }

    return orig_canOpenURL(self, _cmd, url);
}

void _supporthook_UIApplication(void) 
{
    SupportHookInstanceMessage("UIApplication", "canOpenURL:", new_canOpenURL, orig_canOpenURL);
}