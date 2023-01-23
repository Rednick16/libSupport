#ifndef wrapper_h
#define wrapper_h

#include <assert.h>
#include <unistd.h>

#define SUPPORT_STATIC static
#define SUPPORT_ASSERT(x) assert (x)

/* custom ctor */
#define SUPPORT_COUNTER_INTERNAL(n, c) n ## c
#define SUPPORT_COUNTER_INTERNAL_0(c) SUPPORT_COUNTER_INTERNAL(support_entry_, c)
#define __SUPPORT_COUNTER__ SUPPORT_COUNTER_INTERNAL_0(__COUNTER__)
#define SUPPORT_CTOR __attribute__((constructor)) SUPPORT_STATIC void __SUPPORT_COUNTER__()

#define SUPPORT_DISPATCH_ASYNC_START dispatch_async(dispatch_get_main_queue(), ^{
#define SUPPORT_DISPATCH_ASYNC_CLOSE });

#define SUPPORT_DISPATCH_TIME_START(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
#define SUPPORT_DISPATCH_TIME_CLOSE });

#define SUPPORT_DISPATCH_TIME_START_BACKGROUND(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#define SUPPORT_DISPATCH_TIME_CLOSE_BACKGROUND });

# if 0
#define DLOG(format, ...){ \
    SUPPORT_DISPATCH_TIME_START(0.5) \
		UIWindow* mainWindow = [[UIApplication sharedApplication] windows].lastObject; \
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DEBUG" \
																	   message:[NSString stringWithFormat:@"\n %s [Line %d] \n %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:format, ##__VA_ARGS__]] \
																preferredStyle:UIAlertControllerStyleAlert]; \
		[alert addAction:[UIAlertAction actionWithTitle:@"ok!" \
												  style:UIAlertActionStyleDefault \
												handler:nil]]; \
		[mainWindow.rootViewController presentViewController:alert \
													animated:true \
												  completion:nil]; \
    SUPPORT_DISPATCH_TIME_CLOSE \
}
#endif

#define WRAPPER_HOOK_TRUE ((IMP)wrapper_true_objc_func)
#define WRAPPER_HOOK_FALSE ((IMP)wrapper_false_objc_func)

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

bool wrapper_false_objc_func(id self, SEL sel);
bool wrapper_true_objc_func(id self, SEL sel);

#ifdef __cplusplus
}
#endif //__cplusplus

#endif //wrapper_h