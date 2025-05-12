#include "hooks.h"

# if 0
int (*orig_csops)(pid_t, unsigned int, void*, size_t);
int new_csops(pid_t pid, unsigned int  ops, void * useraddr, size_t usersize) {
    int result = orig_csops(pid, ops, useraddr, usersize);
    if(result == 0)
    {
        if(pid == getpid()) {
            if(ops == CS_OPS_IDENTITY) {
                const char* bundleIdentifier = getBundleIdentifier().UTF8String;
                memcpy(useraddr + 8, bundleIdentifier, strlen(bundleIdentifier) + 1);
            }
        }
    }

    return result;
}
#endif

void _supporthook_sandbox()
{
	// SupportHookSymbolEx("csops", new_csops, (void **)&orig_csops);
}