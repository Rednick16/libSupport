#ifndef swizzling_h
#define swizzling_h

#import <objc/runtime.h>
#import <objc/message.h>

#if !defined(SUPPORT_EXPORT)
#define SUPPORT_VISIBILITY __attribute__((visibility("hidden")))
#else
#define SUPPORT_VISIBILITY __attribute__((visibility("default")))
#endif

#define SupportHookInstanceMessage(clazz, sel, imp , result) \
SupportHookMessageEx( objc_getClass(clazz), sel_registerName(sel), (IMP)(&imp), (IMP*)(&result) )
#define SupportHookClassMessage(clazz, sel, imp , result) \
SupportHookMessageEx( objc_getMetaClass(clazz), sel_registerName(sel), (IMP)(&imp), (IMP*)(&result) )

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

SUPPORT_VISIBILITY 
void SupportHookMessageEx(Class _class, SEL sel, IMP imp, IMP *result);
SUPPORT_VISIBILITY 
void SupportAddMessageEx(Class _class, SEL sel, IMP imp, const char *typeEncoding, IMP *result);

#ifdef __cplusplus
}
#endif //__cplusplus

#endif //swizzling_h