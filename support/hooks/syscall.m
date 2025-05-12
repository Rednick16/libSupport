#import "hooks.h"

#define CS_DEBUGGED 0x10000000

static int (*orig_syscall)(int number, ...);
static int new_syscall(int number, ...) {
    NSLog(@"%@: %d", @"syscall", number);

	va_list args;
	va_start(args, number);

    void* stack[8];
    memcpy(stack, args, sizeof(stack));

    // Handle single pathname syscalls
    if(!isCallerTweak()) {
        if(number == SYS_open
        || number == SYS_chdir
        || number == SYS_access
        || number == SYS_execve
        || number == SYS_chroot
        || number == SYS_rmdir
        || number == SYS_stat
        || number == SYS_lstat
        || number == SYS_getattrlist
        || number == SYS_open_extended
        || number == SYS_stat_extended
        || number == SYS_lstat_extended
        || number == SYS_access_extended
        || number == SYS_stat64
        || number == SYS_lstat64
        || number == SYS_stat64_extended
        || number == SYS_lstat64_extended
        || number == SYS_readlink
        || number == SYS_pathconf) {
            const char* pathname = va_arg(args, const char *);

            if(isCPathRestricted(pathname)) {
                errno = ENOENT;
                return -1;
            }
        }
    }

    // Handle ptrace (anti debug)
    if(number == SYS_ptrace) {
        int _request = va_arg(args, int);

        if(_request == PT_DENY_ATTACH) {
            return 0;
        }
    }

    va_end(args);

    return orig_syscall(number, stack[0], stack[1], stack[2], stack[3], stack[4], stack[5], stack[6], stack[7]);
}

static int (*orig_csops)(pid_t pid, unsigned int ops, void* useraddr, size_t usersize);
static int new_csops(pid_t pid, unsigned int ops, void* useraddr, size_t usersize) {
    int ret = orig_csops(pid, ops, useraddr, usersize);

    if(!isCallerTweak() && pid == getpid()) {
        if(ops == CS_OPS_STATUS) {
            // (Un)set some flags
            ret &= ~CS_PLATFORM_BINARY;
            ret &= ~CS_GET_TASK_ALLOW;
            ret &= ~CS_INSTALLER;
            ret &= ~CS_ENTITLEMENTS_VALIDATED;
            ret |= 0x0000300; /* CS_JIT_ALLOW */
            ret |= CS_REQUIRE_LV;

            // https://github.com/PojavLauncherTeam/PojavLauncher_iOS/blob/a100785d68fdef2edb36b6439908ac2dde57796c/Natives/utils.m#L25
            int flags = 0;
            orig_csops(pid, ops, &flags, sizeof(flags));
            if(flags & CS_DEBUGGED) {
                *(int*)useraddr &= ~CS_DEBUGGED;
            }
        }

        if(ops == CS_OPS_CDHASH) {
            // Hide CDHASH for trustcache checks
            errno = EBADEXEC;
            return -1;
        }

        if(ops == CS_OPS_MARKKILL) {
            errno = EBADEXEC;
            return -1;
        }
    }

    return ret;
}

void _supporthook_syscall(void) {
    SupportHookSymbolEx("syscall", new_syscall, (void **)&orig_syscall);
    SupportHookSymbolEx("csops", new_csops, (void **)&orig_csops);
}