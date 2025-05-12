#import "hooks.h"

LS_STATIC  BOOL new_DCAppAttestService$$isSupported$(id self, SEL _cmd)
{ return NO; }

LS_STATIC  BOOL new_DCDevice$$isSupported$(id self, SEL _cmd)
{ return NO; }

void _supporthook_DeviceCheck(void)
{
    SupportHookMessageEx(objc_getClass("DCAppAttestService"), sel_registerName("isSupported"), (IMP)(&new_DCAppAttestService$$isSupported$), (IMP *)(NULL));
    SupportHookMessageEx(objc_getClass("DCDevice"), sel_registerName("isSupported"), (IMP)(&new_DCDevice$$isSupported$), (IMP *)(NULL));
}