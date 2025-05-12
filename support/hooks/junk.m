#import "hooks.h"

#define OBJC_DEF_FUNCTION(CLS, RETURN_TYPE, FUNCTION_NAME, ...)                                     \
    LS_STATIC RETURN_TYPE (*_##CLS##$$##FUNCTION_NAME)(id self, SEL sel, ##__VA_ARGS__);  \
    LS_STATIC RETURN_TYPE CLS##$$##FUNCTION_NAME (id self, SEL sel, ##__VA_ARGS__)

#define INTERNAL_TEXT_TO_STRING(t) #t

#define OBJC_DEF_INSTANCE_MESSAGE_OVERRIDE(CLS, SEL_NAME, FUNCTION_NAME) \
SupportHookInstanceMessage(INTERNAL_TEXT_TO_STRING(CLS), SEL_NAME, CLS##$$##FUNCTION_NAME, _##CLS##$$##FUNCTION_NAME);

#define OBJC_DEF_CLASS_MESSAGE_OVERRIDE(CLS, SEL_NAME, FUNCTION_NAME) \
SupportHookClassMessage(INTERNAL_TEXT_TO_STRING(CLS), SEL_NAME, CLS##$$##FUNCTION_NAME, _##CLS##$$##FUNCTION_NAME);

# if 0
@class ALUtils;
OBJC_DEF_FUNCTION(ALUtils, BOOL, isOperatingSystemAtLeastVersion$, NSOperatingSystemVersion version) 


OBJC_DEF_FUNCTION(NSProcessInfo, BOOL, isOperatingSystemAtLeastVersion$, NSOperatingSystemVersion version) 
{
    if(isCallerTweak()) 
    {
        return _NSProcessInfo$$isOperatingSystemAtLeastVersion$(self, sel, version);
    }

    // Override version checks that use this method.
    return YES;
}

OBJC_DEF_FUNCTION(NSProcessInfo, BOOL, isiOSAppOnMac) 
{
    if(isCallerTweak()) 
    {
        return _NSProcessInfo$$isiOSAppOnMac(self, sel);
    }

    return NO;
}
#endif

void _supporthook_junk()
{
    //OBJC_DEF_FUNCTION_OVERRIDE(NSProcessInfo, "isOperatingSystemAtLeastVersion:", isOperatingSystemAtLeastVersion$);
    //OBJC_DEF_FUNCTION_OVERRIDE(NSProcessInfo, "isiOSAppOnMac", isiOSAppOnMac);
}