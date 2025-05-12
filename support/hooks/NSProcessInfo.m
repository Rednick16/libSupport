#import "hooks.h"

#define OBJC_DEF_FUNCTION(CLS, RETURN_TYPE, FUNCTION_NAME, ...)                                     \
    LS_STATIC RETURN_TYPE (*_##CLS##$$##FUNCTION_NAME)(id self, SEL sel, ##__VA_ARGS__);  \
    LS_STATIC RETURN_TYPE CLS##$$##FUNCTION_NAME (id self, SEL sel, ##__VA_ARGS__)

#define OBJC_DEF_FUNCTION_OVERRIDE(CLS, SEL_NAME, FUNCTION_NAME) \
SupportHookInstanceMessage(LS_TOSTRING(CLS), SEL_NAME, CLS##$$##FUNCTION_NAME, _##CLS##$$##FUNCTION_NAME);

OBJC_DEF_FUNCTION(NSProcessInfo, BOOL, isOperatingSystemAtLeastVersion$, NSOperatingSystemVersion version) 
{
    if(isCallerTweak()) 
    {
        return _NSProcessInfo$$isOperatingSystemAtLeastVersion$(self, sel, version);
    }

    // Override version checks that use this method.
    return YES;
}

# if 1
// dose the developer want the app to run on mac?
OBJC_DEF_FUNCTION(NSProcessInfo, BOOL, macCatalystApp) 
{
    if(isCallerTweak()) 
    {
        return _NSProcessInfo$$macCatalystApp(self, sel);
    }

    return NO;
}
#endif

OBJC_DEF_FUNCTION(NSProcessInfo, BOOL, isiOSAppOnMac) 
{
    if(isCallerTweak()) 
    {
        return _NSProcessInfo$$isiOSAppOnMac(self, sel);
    }

    return NO;
}

OBJC_DEF_FUNCTION(NSProcessInfo, NSDictionary*, environment) 
{
    if(isCallerTweak()) 
    {
        return _NSProcessInfo$$environment(self, sel);
    }

    NSMutableDictionary *environment = [_NSProcessInfo$$environment(self, sel) mutableCopy];
    static NSString *SDN = @"SIMULATOR_DEVICE_NAME";

    if([environment objectForKey:SDN] != nil)
    {
        [environment removeObjectForKey:SDN];
    }

    return [environment copy];
}

void _supporthook_NSProcessInfo_antiemulator(void)
{
    OBJC_DEF_FUNCTION_OVERRIDE(NSProcessInfo, "isOperatingSystemAtLeastVersion:", isOperatingSystemAtLeastVersion$);
    OBJC_DEF_FUNCTION_OVERRIDE(NSProcessInfo, "macCatalystApp", macCatalystApp);
    OBJC_DEF_FUNCTION_OVERRIDE(NSProcessInfo, "isiOSAppOnMac", isiOSAppOnMac);
    OBJC_DEF_FUNCTION_OVERRIDE(NSProcessInfo, "environment", environment);
}