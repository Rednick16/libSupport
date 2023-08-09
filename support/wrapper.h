#ifndef wrapper_h
#define wrapper_h

#include <assert.h>
#include <unistd.h>
#include <dispatch/dispatch.h>

#define SUPPORT_STATIC static
#define SUPPORT_UNUSED __unused
#define SUPPORT_ASSERT(x) assert (x)

/* custom ctor */
#define SUPPORT_COUNTER_INTERNAL(n, c) n ## c
#define SUPPORT_COUNTER_INTERNAL_0(n, c) SUPPORT_COUNTER_INTERNAL(n, c)

#define ENTRY_SUPPORT_CTOR SUPPORT_COUNTER_INTERNAL_0(support_entry_, __COUNTER__)
#define SUPPORT_CTOR __attribute__((constructor)) SUPPORT_STATIC void ENTRY_SUPPORT_CTOR()

#define SUPPORT_DISPATCH_ASYNC_START dispatch_async(dispatch_get_main_queue(), ^{
#define SUPPORT_DISPATCH_ASYNC_CLOSE });

#define SUPPORT_DISPATCH_TIME_START(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
#define SUPPORT_DISPATCH_TIME_CLOSE });

#define SUPPORT_DISPATCH_TIME_START_BACKGROUND(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#define SUPPORT_DISPATCH_TIME_CLOSE_BACKGROUND });

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#define DLOG(format, ...){ \
    SUPPORT_DISPATCH_TIME_START(0.5) \
		UIWindow* mainWindow = [[UIApplication sharedApplication] windows].lastObject; \
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DEBUG" \
																	   message:[NSString stringWithFormat:@"\n %s [Line %d] \n %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:format, ##__VA_ARGS__]] \
																preferredStyle:UIAlertControllerStyleAlert]; \
		[alert addAction:[UIAlertAction actionWithTitle:@"OK!" \
												  style:UIAlertActionStyleDefault \
												handler:nil]]; \
		[mainWindow.rootViewController presentViewController:alert \
													animated:true \
												  completion:nil]; \
    SUPPORT_DISPATCH_TIME_CLOSE \
}
#endif

#define SUPPORT_FAILURE 0
#define SUPPORT_SUCCESS 1
#define SUPPORT_INVALID_BUFFER 2
#define SUPPORT_MAP_FAILURE 3
#define SUPPORT_INVALID_ADDRESS 4
#define SUPPORT_INVALID_LENGTH 5
#define SUPPORT_PROTECTION_FAILURE 6
#define SUPPORT_INVALID_ARGUMENTS 69420

#endif //wrapper_h