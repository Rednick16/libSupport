/* libSupport - Powerful app modification library
 * Copyright (c) 2022-2025 Rednick16 (Red16)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef support_h
#define support_h

#include "wrapper.h"

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

// Provides compatibility for Just-In-Time (JIT) compilation and debug mode.
LS_EXPORT
int SupportCodePatchEx(void* addr, const uint8_t* buffer, size_t size);

LS_EXPORT
const char* SupportGetLibraryPath(void);

typedef enum _SupportHookFlags
{
    SupportHookFlagNone             = 0,
    SupportHookFlagObjCRuntime      = 1 << 0,
    SupportHookFlagDynamicLibraries = 1 << 1,
    SupportHookFlagFilesystem       = 1 << 2,
    SupportHookFlagCoreFoundation   = 1 << 3,
    SupportHookFlagFoundation       = 1 << 4,
    SupportHookFlagURLScheme        = 1 << 5,
    SupportHookFlagSyscall          = 1 << 6,
    SupportHookFlagSymLookup        = 1 << 7,
    SupportHookFlagDeviceCheck      = 1 << 8,
    SupportHookFlagAntiDebugging    = 1 << 9,
    SupportHookFlagAntiProxyAndVPN  = 1 << 10,
    SupportHookFlagSecurity         = 1 << 11,
    /* 1<<12 (anti exit) */

    // Enable all hooking options :)
    SupportHookFlagEnableAll        = ~SupportHookFlagNone
} SupportHookFlags;

typedef struct _SupportEntryInfo
{
    const char *teamIdentifier;
    const char *bundleIdentifier;
    SupportHookFlags hookFlags;
    const char **restrictedFiles;
    size_t restrictedFileCount;
    const char **restrictedURLSchemes;
    size_t restrictedURLSchemeCount;
} SupportEntryInfo;

LS_EXPORT
void SupportInitialize(SupportEntryInfo* info);

LS_EXPORT
int SupportMemoryProtectEx(void* addr, size_t size, int protection);

typedef struct _SupportHookInfo
{
    void *address;
    void *replacement;
    void **original;
} SupportHookInfo;

// Provides compatibility for Just-In-Time (JIT) compilation.
LS_EXPORT
int LS_DEPRECATED(SupportHookFunctionEx(SupportHookInfo hookInfo),
    "Please use Dobby instead.");

LS_EXPORT
int LS_DEPRECATED(SupportDestroy(SupportHookInfo hookInfo),
    "Please use Dobby instead.");

#define SupportHookFunction(_address, _replacement, _original)  \
    SupportHookFunctionEx((SupportHookInfo){                    \
        .address = (_address),                                  \
        .replacement = (_replacement),                          \
        .original = (_original)                                 \
    })

LS_EXPORT
void SupportHookSymbolEx(const char* symbol, void* replacement, void** replaced);

typedef struct _SupportDetectionInfo
{
    int isJailbroken;       // ret: 0 || 1
    int isDebuggerPresent;  // ret: 0 || 1
} SupportDetectionInfo;

LS_EXPORT
void SupportGetDetectionInfo(SupportDetectionInfo* detectionInfo);

LS_EXPORT
const char* SupportGetVersion(void);

LS_EXPORT
void SupportRunOnMainQueueWithoutDeadlocking(void (*)(void*), void*);

#if 0
typedef struct _SupportApplicationWindowInfo
{
    const void *window;
    const void *rootViewController;
    const void *currentRootViewController;
} SupportApplicationWindowInfo;

LS_EXPORT
void SupportGetApplicationWindowInfo(SupportApplicationWindowInfo* info);
#endif

LS_EXPORT
void SupportHookMessageEx(Class _class, SEL sel, IMP imp, IMP *result);

LS_EXPORT
void SupportAddMessageEx(Class _class, SEL sel, IMP imp, const char *typeEncoding, IMP *result);

#define SupportHookInstanceMessage(_class, _sel, _imp, _result) \
    SupportHookMessageEx(                                       \
        objc_getClass((_class)),                                \
        sel_registerName((_sel)),                               \
        (IMP)(_imp),                                            \
        (IMP*)(&_result)                                        \
    )

#define SupportHookClassMessage(_class, _sel, _imp, _result)    \
    SupportHookMessageEx(                                       \
        objc_getMetaClass((_class)),                            \
        sel_registerName((_sel)),                               \
        (IMP)(_imp),                                            \
        (IMP*)(&_result)                                        \
    )

#ifdef __cplusplus
}
#endif //__cplusplus

#endif //support_h
