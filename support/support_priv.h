#if __has_feature(modules)
@import UIKit;
@import Foundation;
#else
#import "UIKit/UIKit.h"
#import "Foundation/Foundation.h"
#endif

#import <stdio.h>
#import <errno.h>
#import <fcntl.h>
#import <sandbox.h>
#import <bootstrap.h>
#import <spawn.h>
#import <dlfcn.h>
#import <dirent.h>
#import <sys/stat.h>
#import <sys/ioctl.h>
#import <sys/statvfs.h>
#import <sys/mount.h>
#import <sys/syscall.h>
#import <sys/utsname.h>
#import <sys/syslimits.h>
#import <sys/time.h>
#import <sys/sysctl.h>
#import <mach-o/dyld.h>
#import <mach-o/dyld_images.h>
#import <mach-o/getsect.h>
#import <mach-o/nlist.h>
#import <mach/mach.h>
#import <mach/task_info.h>
#import <mach/mach_traps.h>
#import <mach/host_special_ports.h>
#import <mach/task_special_ports.h>

#import "dyld_priv.h"
#import "codesign.h"
#import "ptrace.h"
#import "support.h"

#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) (void)0
#endif

#ifndef CS_DEBUGGED
#define CS_DEBUGGED 0x10000000
#endif

#define LS_AutoHookSymbol(func) SupportHookSymbolEx(LS_STRINGIFY(func), (void *)new_##func, (void **)&orig_##func)

#if defined(__LP64__)
typedef struct mach_header_64 mach_header_t;
#else
typedef struct mach_header mach_header_t;
#endif

typedef struct __SecTask * SecTaskRef;

LS_PRIVATE BOOL isURLRestricted(NSURL* url);
LS_PRIVATE BOOL isCFURLRestricted(CFURLRef path);
LS_PRIVATE BOOL isPathRestricted(NSString* var);
LS_PRIVATE BOOL isCFPathRestricted(CFStringRef path);
LS_PRIVATE BOOL isCPathRestricted(const char* path);
LS_PRIVATE BOOL isSchemeRestricted(NSString * scheme);
LS_PRIVATE BOOL isAddrExternal(const void* addr);
LS_PRIVATE BOOL isAddrRestricted(const void* addr);

LS_PRIVATE NSString* getBundlePath();
LS_PRIVATE NSString* getBundleIdentifier();
LS_PRIVATE NSString* getTeamIdentifier();
LS_PRIVATE NSArray*  getRestrictedFiles();
LS_PRIVATE NSString* getExecutablePath();
LS_PRIVATE NSString* getStandardizedPath(NSString *path);
LS_PRIVATE id getAdjustedDictionary(NSBundle *bundle, id dictionary, BOOL mutable);

#define isCallerTweak() !isAddrExternal(LS_CALLER_ADDRESS())
#define isSupportCaller() !isAddrExternal(LS_CALLER_ADDRESS())