#ifndef support_load_h
#define support_load_h

#include <dlfcn.h>
#include <assert.h>

#if !defined(SUPPORT_EXPORT)
#define SUPPORT_VISIBILITY __attribute__((visibility("hidden")))
#else
#define SUPPORT_VISIBILITY __attribute__((visibility("default")))
#endif

/* obfuscated interface */
#define initilize   G673549208357581533619
#define objc_hook   G982546284017645282936
#define func_hook   G463829373452628922945
#define symbol_hook G526354701963547283647

#define MAX_SIZE 50

#define SUPPORT_STRING(x) #x
#define SUPPORT_STATIC static
#define SUPPORT_ASSERT(x) assert(x)

#define INIT_API(h, n) n = (n##_t)dlsym(h, SUPPORT_STRING(n))
#define DO_DEF(r, n, p)       \
    SUPPORT_VISIBILITY static r (*n) p; \
    typedef r (*n##_t) p;

typedef void (*SUPPORT_IMP)(void /* id, selector, ... */);

struct support_bypass  {
    const char *uniqueIdentifier;
    const char *bundleIdentifier;
    const char *files[MAX_SIZE];
    const char *symbols[MAX_SIZE];
};

DO_DEF(void, initilize, (struct support_bypass bypass));
DO_DEF(void, objc_hook, (const char *class_name, const char *method_name, SUPPORT_IMP replacement, SUPPORT_IMP *original));
DO_DEF(void, func_hook, (void*address, void* replacement, void**original)); /* not ready */
DO_DEF(void, symbol_hook, (const char *symbol, void* replacement, void**original)); /* utilizes fishhook */

SUPPORT_VISIBILITY SUPPORT_STATIC void support_init()
{
	void* libsupportHandle = dlopen("Frameworks/libsupport.dylib", RTLD_NOW);
	if(libsupportHandle != NULL)
    {
		INIT_API(libsupportHandle, initilize);
		INIT_API(libsupportHandle, objc_hook);
        INIT_API(libsupportHandle, symbol_hook);
		INIT_API(libsupportHandle, func_hook);

		dlclose(libsupportHandle);
	}

    SUPPORT_ASSERT( libsupportHandle && "Can't find libsupport handle" );
}

SUPPORT_VISIBILITY SUPPORT_STATIC bool support_initialized(){
    SUPPORT_ASSERT(initilize != NULL && objc_hook != NULL && symbol_hook != NULL && func_hook != NULL);
    return (initilize != NULL && objc_hook != NULL && symbol_hook != NULL && func_hook != NULL);
}

#endif //support_load_h