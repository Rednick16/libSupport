#ifndef support_h
#define support_h

#include "wrapper.h"
#include "swizzling.h"

#if !defined(SUPPORT_EXPORT)
#define SUPPORT_VISIBILITY __attribute__((visibility("hidden")))
#else
#define SUPPORT_VISIBILITY __attribute__((visibility("default")))
#endif

#define MAX_SIZE 127

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

typedef enum {
    SupportLogLevelDebug,
    SupportLogLevelInfo,
    SupportLogLevelWarning,
    SupportLogLevelError
} SupportLogLevel;

SUPPORT_VISIBILITY 
void SupportLog(SupportLogLevel level, const char* file, int line, const char* format, ...);

#define SupportLogDebug(format, ...) SupportLog(SupportLogLevelDebug, __FILE__, __LINE__, format, ##__VA_ARGS__)
#define SupportLogInfo(format, ...) SupportLog(SupportLogLevelInfo, __FILE__, __LINE__, format, ##__VA_ARGS__)
#define SupportLogWarning(format, ...) SupportLog(SupportLogLevelWarning, __FILE__, __LINE__, format, ##__VA_ARGS__)
#define SupportLogError(format, ...) SupportLog(SupportLogLevelError, __FILE__, __LINE__, format, ##__VA_ARGS__)

// Provides compatibility for Just-In-Time (JIT) compilation and debug mode.
SUPPORT_VISIBILITY 
int SupportCodePatchEx(void* addr, const uint8_t* buffer, size_t size);

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
void SupportInitilize(SupportEntryInfo *info);

typedef enum {
    SupportHookTypeR,
    SupportHookTypeE
} SupportHookType;

typedef struct _SupportHookInfo
{
    SupportHookType type;
    void *address;
    void *replacement;
    void **original;
} SupportHookInfo;

SUPPORT_VISIBILITY 
int SupportHookFunctionEx(SupportHookInfo hookInfo);

#define SupportHookFunction(_address, _replacement, _original)  \
    SupportHookFunctionEx((SupportHookInfo){                    \
        .type = (SupportHookTypeE),                             \
        .address = (_address),                                  \
        .replacement = (_replacement),                          \
        .original = (_original)                                 \
    })

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

typedef struct _SupportDetectionInfo
{
    bool isJailbroken; // W.I.P
    bool isDebuggerPresent;
} SupportDetectionInfo;

SUPPORT_VISIBILITY 
SupportDetectionInfo SupportGetDetectionInfo(void);

SUPPORT_VISIBILITY
const char* SupportGetVersion(void);

SUPPORT_VISIBILITY 
void SupportRunOnMainQueueWithoutDeadlocking(void (*)(void*), void*);

# if 0
typedef struct _SupportApplicationWindowInfo
{
    const void *window;
    const void *rootViewController;
    const void *currentRootViewController;
} SupportApplicationWindowInfo;

SUPPORT_VISIBILITY 
void SupportGetApplicationWindowInfo(SupportApplicationWindowInfo *info);
#endif

#ifdef __cplusplus
}
#endif //__cplusplus

#endif //support_h