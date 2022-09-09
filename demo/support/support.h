#ifndef support_h
#define support_h

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
#define hookedf_add G526354701963547283646

#define MAX_SIZE 1024

typedef void (*SUPPORT_IMP)(void /* id, selector, ... */);

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

struct support_bypass  {
    const char *uniqueIdentifier; /* spoof id */
    const char *bundleIdentifier;
    const char *files[MAX_SIZE];
    const char *symbols[MAX_SIZE];
};

SUPPORT_VISIBILITY void initilize(struct support_bypass bypass);
SUPPORT_VISIBILITY void objc_hook(const char *class_name, const char *method_name, SUPPORT_IMP replacement, SUPPORT_IMP *original);

SUPPORT_VISIBILITY void func_hook(void*address, void* replacement, void**original); /* not ready */
SUPPORT_VISIBILITY void symbol_hook(const char *symbol, void* replacement, void**original); /* utilizes fishhook */
SUPPORT_VISIBILITY void hookedf_add(void* replacement, void* original, int* outIndex); /* hooked functions to bypass */

#ifdef __cplusplus
}
#endif //__cplusplus

#endif //support_h