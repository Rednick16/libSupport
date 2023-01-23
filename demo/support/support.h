#ifndef support_h
#define support_h

#include "wrapper.h"
#include "swizzling.h"

#if !defined(SUPPORT_EXPORT)
#define SUPPORT_VISIBILITY __attribute__((visibility("hidden")))
#else
#define SUPPORT_VISIBILITY __attribute__((visibility("default")))
#endif

#define MAX_SIZE 1024

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

typedef enum
{
    PATCH_FAILURE,
    PATCH_SUCCESS,
    PATCH_INVALID_BUFFER,
    PATCH_MAP_FAILURE,
    PATCH_INVALID_ADDRESS,
    PATCH_INVALID_LENGTH,
    PATCH_PROTECTION_FAILURE
} patch_return_t;

// debug mode only
SUPPORT_VISIBILITY 
patch_return_t SupportCodePatchEx(void* addr, const void* buffer, size_t size);

SUPPORT_VISIBILITY
void* SupportSymbolResolverEx(const char* image_name, const char* symbol);

typedef struct _SupportEntryInfo 
{
    const char *teamIdentifier;
    const char *bundleIdentifier;
    const char *files[MAX_SIZE];
    
    union 
    {
        struct 
        {
            bool hookSymbols;
            bool hookMessages;
            bool hookExpierimental;
            bool allowDebugging;
        } settings;
        bool options[4];
    } general;

} SupportEntryInfo;

SUPPORT_VISIBILITY
void SupportInitilize(SupportEntryInfo info);

// Can't add the (replacment function yet) but you can get the original address with it.
SUPPORT_VISIBILITY
void SupportHookFunctionEx(void*address, void* replacement, void**original);

SUPPORT_VISIBILITY
void SupportHookSymbolEx(const char* symbol, void* replacement, void** replaced);

SUPPORT_VISIBILITY
uint32_t SupportGetImageCount(void);

SUPPORT_VISIBILITY
const char* SupportGetDyldImageName(uint32_t image_index);

SUPPORT_VISIBILITY
const struct mach_header* SupportGetImageHeader(uint32_t image_index);

SUPPORT_VISIBILITY
intptr_t SupportGetImageVmaddrSlide(uint32_t image_index);

SUPPORT_VISIBILITY
const char* SupportGeVersion();

#ifdef __cplusplus
}
#endif //__cplusplus

#endif //support_h