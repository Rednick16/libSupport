#import <Foundation/Foundation.h>
#import <os/log.h>
#import "wrapper.h"

LS_EXPORT
void _support_logimpl(const char *format, ...) 
{
    if(LS_UNLIKELY(format == NULL)) 
        return;

    static os_log_t logHandle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logHandle = os_log_create("com.rednick16.libsupport", "default");
    });

    va_list args;
    va_start(args, format);
    NSString *string = [[NSString alloc] initWithFormat:[NSString stringWithUTF8String:format] arguments:args];
    va_end(args);
    
    os_log(logHandle, "[libSupport] %{public}@", string);
}
