#import <stdio.h>
#import "wrapper.h"

LS_EXPORT
void _support_assertimpl(const char *expression, const char *file, int line, const char *format, ...) 
{
    fprintf(stderr, "%s:%d: assertion %s failed", file, line, expression);

    if(LS_LIKELY(format)) 
    {
        fprintf(stderr, " -> ");
        va_list args;
        va_start(args, format);
        vfprintf(stderr, format, args);
        va_end(args);
    }

    fprintf(stderr, "\n");
    fflush(stderr);
    abort();
}