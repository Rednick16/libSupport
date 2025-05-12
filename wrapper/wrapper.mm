#include "wrapper.h"
#include "support.h"

LS_IGNORE LS_STATIC void (*orig_abort)(void);
LS_IGNORE LS_STATIC void new_abort(void) 
{
    return;
}

LS_IGNORE LS_STATIC void (*orig_exit)(int status);
LS_IGNORE LS_STATIC void new_exit(int status) 
{
    return;
}

LS_CTOR {
    // some tests, seems to work well on some apps lol,
    // there is absolutely no reason any ios app should call any of these, unless they are a bad behaved app, ie. checking for the presence of jailbreak, sideloading etc  
    //SupportHookSymbolEx("exit", (void *)new_exit, NULL);
    //SupportHookSymbolEx("abort", (void *)new_abort, NULL);
}