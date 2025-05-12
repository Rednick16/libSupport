#import "hooks.h"

LS_STATIC char** (*orig_NSGetEnviron)(void);
LS_STATIC char** new_NSGetEnviron(void)
{
	char **result = orig_NSGetEnviron();
	# if 0
	if(!isCallerTweak() && result)
	{
		return environ;
	}
	#endif

	return result;
}

/* expirenmental features */
LS_STATIC int (*orig_access)(const char*pathname, int mode);
LS_STATIC int new_access(const char*pathname, int mode)
{
	int result = orig_access(pathname, mode);

	if(result != -1 && !isCallerTweak() && isCPathRestricted(pathname))
	{
        errno = ENOENT;
		return -1;
	}

	return result;
}

LS_STATIC ssize_t (*orig_readlink)(const char* pathname, char* buf, size_t bufsize);
LS_STATIC ssize_t new_readlink(const char* pathname, char* buf, size_t bufsize) {
    ssize_t result = orig_readlink(pathname, buf, bufsize);

    if(result != -1 && !isCallerTweak() && isCPathRestricted(pathname)) {
        errno = ENOENT;
        return -1;
    }

    return result;
}

LS_STATIC ssize_t (*orig_readlinkat)(int dirfd, const char* pathname, char* buf, size_t bufsize);
LS_STATIC ssize_t new_readlinkat(int dirfd, const char* pathname, char* buf, size_t bufsize) {
    if(isCallerTweak()) {
        return orig_readlinkat(dirfd, pathname, buf, bufsize);
    }

    if(pathname
    && dirfd != fileno(stderr)
    && dirfd != fileno(stdout)
    && dirfd != fileno(stdin)) {
        NSString* path = [NSString stringWithUTF8String:pathname];

        // Get file descriptor path.
		# if 0
        char pathnameParent[PATH_MAX];
        NSString* pathParent = nil;

        if(dirfd == AT_FDCWD) {
            pathParent = [[NSFileManager defaultManager] currentDirectoryPath];
        } else if(fcntl(dirfd, F_GETPATH, pathnameParent) != -1) {
            pathParent = [NSString stringWithUTF8String:pathnameParent];
        }
		#endif

        if(isPathRestricted(path)) {
            errno = [path isAbsolutePath] ? ENOENT : EBADF;
            return -1;
        }
    }

    return orig_readlinkat(dirfd, pathname, buf, bufsize);
}

static int (*orig_chdir)(const char* pathname);
static int new_chdir(const char* pathname) {
    if(isCallerTweak() || !isCPathRestricted(pathname)) {
        return orig_chdir(pathname);
    }

    errno = ENOENT;
    return -1;
}

static int (*orig_fchdir)(int fd);
static int new_fchdir(int fd) {
    if(isCallerTweak()) {
        return orig_fchdir(fd);
    }

    // Get file descriptor path.
    if(fd != fileno(stderr)
    && fd != fileno(stdout)
    && fd != fileno(stdin)) {
        char pathname[PATH_MAX];

        if(fcntl(fd, F_GETPATH, pathname) != -1 && isCPathRestricted(pathname)) {
            errno = EBADF;
            return -1;
        }
    }

    return orig_fchdir(fd);
}

static int (*orig_chroot)(const char* pathname);
static int new_chroot(const char* pathname) {
    if(isCallerTweak() || !isCPathRestricted(pathname)) {
        return orig_chroot(pathname);
    }

    errno = ENOENT;
    return -1;
}

static int (*orig_creat)(const char* pathname, mode_t mode);
static int new_creat(const char* pathname, mode_t mode) {
    if(isCallerTweak() || !isCPathRestricted(pathname)) {
        return orig_creat(pathname, mode);
    }

    errno = ENOENT;
    return -1;
}

static int (*orig_getfsstat)(struct statfs* buf, int bufsize, int flags);
static int new_getfsstat(struct statfs* buf, int bufsize, int flags) {
    if(isCallerTweak()) {
        return orig_getfsstat(buf, bufsize, flags);
    }

    int result = orig_getfsstat(buf, bufsize, flags);

    if(result != -1 && buf) {
        struct statfs* buf_ptr = buf;
        struct statfs* buf_end = buf + sizeof(struct statfs) * result;

        while(buf_ptr < buf_end) {
            if(isCPathRestricted(buf_ptr->f_mntonname)) {
                // handle bindfs/chroot
                strcpy(buf_ptr->f_mntonname, "/");
            }

            if(strcmp(buf_ptr->f_mntonname, "/") == 0) {
                // Mark rootfs read-only
                buf_ptr->f_flags |= MNT_RDONLY | MNT_ROOTFS | MNT_SNAPSHOT;
                break;
            }

            buf_ptr++;
        }
    }

    return result;
}

static int (*orig_getmntinfo)(struct statfs** mntbufp, int flags);
static int new_getmntinfo(struct statfs** mntbufp, int flags) {
    if(isCallerTweak()) {
        return orig_getmntinfo(mntbufp, flags);
    }

    int result = orig_getmntinfo(mntbufp, flags);

    if(result > 0) {
        struct statfs** buf_ptr = mntbufp;
        struct statfs** buf_end = mntbufp + sizeof(struct statfs *) * result;

        while(buf_ptr < buf_end) {
            if(isCPathRestricted((*buf_ptr)->f_mntonname)) {
                // handle bindfs/chroot
                strcpy((*buf_ptr)->f_mntonname, "/");
            }

            if(strcmp((*buf_ptr)->f_mntonname, "/") == 0) {
                // Mark rootfs read-only
                (*buf_ptr)->f_flags |= MNT_RDONLY | MNT_ROOTFS | MNT_SNAPSHOT;
                break;
            }

            buf_ptr++;
        }
    }

    return result;
}

static int (*orig_statfs)(const char* pathname, struct statfs* buf);
static int new_statfs(const char* pathname, struct statfs* buf) {
    if(isCallerTweak()) {
        return orig_statfs(pathname, buf);
    }

    if(isCPathRestricted(pathname)) {
        errno = ENOENT;
        return -1;
    }

    int result = orig_statfs(pathname, buf);

    if(result == 0) {
        // Modify flags
        if(buf) {
            if(isCPathRestricted(buf->f_mntonname)) {
                // handle bindfs/chroot
                strcpy(buf->f_mntonname, "/");
            }

            if(strcmp(buf->f_mntonname, "/") == 0) {
                // Mark rootfs read-only
                buf->f_flags |= MNT_RDONLY | MNT_ROOTFS | MNT_SNAPSHOT;
            }
        }
    }

    return result;
}

static int (*orig_fstatfs)(int fd, struct statfs* buf);
static int new_fstatfs(int fd, struct statfs* buf) {
    if(isCallerTweak()) {
        return orig_fstatfs(fd, buf);
    }

    if(fd != fileno(stderr)
    && fd != fileno(stdout)
    && fd != fileno(stdin)) {
        // Get file descriptor path.
        char pathname[PATH_MAX];

        if(fcntl(fd, F_GETPATH, pathname) != -1 && isCPathRestricted(pathname)) {
            errno = EBADF;
            return -1;
        }
    }

    int result = orig_fstatfs(fd, buf);

    if(result == 0) {
        // Modify flags
        if(buf) {
            if(isCPathRestricted(buf->f_mntonname)) {
                // handle bindfs/chroot
                strcpy(buf->f_mntonname, "/");
            }

            if(strcmp(buf->f_mntonname, "/") == 0) {
                // Mark rootfs read-only
                buf->f_flags |= MNT_RDONLY | MNT_ROOTFS | MNT_SNAPSHOT;
            }
        }
    }

    return result;
}

static int (*orig_statvfs)(const char* pathname, struct statvfs* buf);
static int new_statvfs(const char* pathname, struct statvfs* buf) {
    if(isCallerTweak()) {
        return orig_statvfs(pathname, buf);
    }

    if(isCPathRestricted(pathname)) {
        errno = ENOENT;
        return -1;
    }

    // use statfs to get f_mntonname
    struct statfs st;
    if(statfs(pathname, &st) == -1) {
        memset(buf, 0, sizeof(struct statvfs));
        errno = ENOENT;
        return -1;
    }

    int result = orig_statvfs(pathname, buf);

    if(result == 0) {
        if(isCPathRestricted(st.f_mntonname)) {
            // handle bindfs/chroot
            strcpy(st.f_mntonname, "/");
        }
        
        if(strcmp(st.f_mntonname, "/") == 0) {
            // Mark rootfs read-only
            buf->f_flag |= MNT_RDONLY | MNT_ROOTFS | MNT_SNAPSHOT;
        }
    }

    return result;
}

static int (*orig_fstatvfs)(int fd, struct statvfs* buf);
static int new_fstatvfs(int fd, struct statvfs* buf) {
    if(isCallerTweak()) {
        return orig_fstatvfs(fd, buf);
    }

    // use fstatfs to get f_mntonname, replaced version for path checking
    struct statfs st;
    if(new_fstatfs(fd, &st) == -1) {
        memset(buf, 0, sizeof(struct statvfs));
        errno = EBADF;
        return -1;
    }

    int result = orig_fstatvfs(fd, buf);

    if(result == 0) {
        if(isCPathRestricted(st.f_mntonname)) {
            // handle bindfs/chroot
            strcpy(st.f_mntonname, "/");
        }

        if(strcmp(st.f_mntonname, "/") == 0) {
            // Mark rootfs read-only
            buf->f_flag |= MNT_RDONLY | MNT_ROOTFS | MNT_SNAPSHOT;
        }
    }

    return result;
}

static int (*orig_stat)(const char* pathname, struct stat* buf);
static int new_stat(const char* pathname, struct stat* buf) {
    int result = orig_stat(pathname, buf);

    if(result != -1 && !isCallerTweak() && isCPathRestricted(pathname)) {
        if(buf) {
            memset(buf, 0, sizeof(struct stat));
        }
        
        errno = ENOENT;
        return -1;
    }

    return result;
}

static int (*orig_lstat)(const char* pathname, struct stat* buf);
static int new_lstat(const char* pathname, struct stat* buf) {
    if(isCallerTweak()) {
        return orig_lstat(pathname, buf);
    }

    struct stat _buf;
    int result = orig_lstat(pathname, &_buf);

    if(result == 0) {
        NSString* path = [NSString stringWithUTF8String:pathname];

        // Only use resolve flag if target is not a symlink.
        if(isPathRestricted(path)) {
            errno = ENOENT;
            return -1;
        }
    }

    if(buf) {
        memcpy(buf, &_buf, sizeof(struct stat));
    }

    return result;
}

static int (*orig_fstat)(int fd, struct stat* buf);
static int new_fstat(int fd, struct stat* buf) {
    if(isCallerTweak()) {
        return orig_fstat(fd, buf);
    }

    if(fd != fileno(stderr)
    && fd != fileno(stdout)
    && fd != fileno(stdin)) {
        // Get file descriptor path.
        char pathname[PATH_MAX];

        if(fcntl(fd, F_GETPATH, pathname) != -1 && isCPathRestricted(pathname)) {
            errno = EBADF;
            return -1;
        }
    }

    return orig_fstat(fd, buf);
}

static int (*orig_fstatat)(int dirfd, const char* pathname, struct stat* buf, int flags);
static int new_fstatat(int dirfd, const char* pathname, struct stat* buf, int flags) {
    if(isCallerTweak()) {
        return orig_fstatat(dirfd, pathname, buf, flags);
    }

    if(pathname
    && dirfd != fileno(stderr)
    && dirfd != fileno(stdout)
    && dirfd != fileno(stdin)) {
        NSString* path = [NSString stringWithUTF8String:pathname];

        // Get file descriptor path.
		# if 0
        char pathnameParent[PATH_MAX];
        NSString* pathParent = nil;

        if(dirfd == AT_FDCWD) {
            pathParent = [[NSFileManager defaultManager] currentDirectoryPath];
        } else if(fcntl(dirfd, F_GETPATH, pathnameParent) != -1) {
            pathParent = [NSString stringWithUTF8String:pathnameParent];
        }
		#endif

        if(isPathRestricted(path)) {
            errno = [path isAbsolutePath] ? ENOENT : EBADF;
            return -1;
        }
    }

    return orig_fstatat(dirfd, pathname, buf, flags);
}

static int (*orig_faccessat)(int dirfd, const char* pathname, int mode, int flags);
static int new_faccessat(int dirfd, const char* pathname, int mode, int flags) {
    if(isCallerTweak()) {
        return orig_faccessat(dirfd, pathname, mode, flags);
    }

    if(pathname
    && dirfd != fileno(stderr)
    && dirfd != fileno(stdout)
    && dirfd != fileno(stdin)) {
        NSString* path = [NSString stringWithUTF8String:pathname];

        // Get file descriptor path.
		# if 0
        char pathnameParent[PATH_MAX];
        NSString* pathParent = nil;

        if(dirfd == AT_FDCWD) {
            pathParent = [[NSFileManager defaultManager] currentDirectoryPath];
        } else if(fcntl(dirfd, F_GETPATH, pathnameParent) != -1) {
            pathParent = [NSString stringWithUTF8String:pathnameParent];
        }
		#endif

        if(isPathRestricted(path)) {
            errno = [path isAbsolutePath] ? ENOENT : EBADF;
            return -1;
        }
    }

    return orig_faccessat(dirfd, pathname, mode, flags);
}

static int (*orig_readdir_r)(DIR* dirp, struct dirent* entry, struct dirent** oresult);
static int new_readdir_r(DIR* dirp, struct dirent* entry, struct dirent** oresult) {
    if(isCallerTweak()) {
        return orig_readdir_r(dirp, entry, oresult);
    }

    int result = orig_readdir_r(dirp, entry, oresult);
    
    if(result == 0 && *oresult) {
        int fd = dirfd(dirp);

        // Get file descriptor path.
        char pathname[PATH_MAX];

        if(fcntl(fd, F_GETPATH, pathname) != -1) {
            // NSString* pathParent = [NSString stringWithUTF8String:pathname];

            do {
                if(isPathRestricted(@((*oresult)->d_name))) {
                    // call readdir again to skip ahead
                    result = orig_readdir_r(dirp, entry, oresult);
                } else {
                    break;
                }
            } while(result == 0 && *oresult);
        }
    }

    return result;
}

static struct dirent* (*orig_readdir)(DIR* dirp);
static struct dirent* new_readdir(DIR* dirp) {
    if(isCallerTweak()) {
        return orig_readdir(dirp);
    }

    struct dirent* result = orig_readdir(dirp);
    
    if(result) {
        int fd = dirfd(dirp);

        // Get file descriptor path.
        char pathname[PATH_MAX];
        
        if(fcntl(fd, F_GETPATH, pathname) != -1) {
            // NSString* pathParent = [NSString stringWithUTF8String:pathname];

            do {
                if(isPathRestricted(@(result->d_name))) {
                    // call readdir again to skip ahead
                    result = orig_readdir(dirp);
                } else {
                    break;
                }
            } while(result);
        }
    }

    return result;
}

LS_STATIC FILE * (*orig_fopen)(const char *pathname, const char *mode);
LS_STATIC FILE * new_fopen(const char *pathname, const char *mode){
	if(isCallerTweak() && !isCPathRestricted(pathname))
	{
		return orig_fopen(pathname, mode);
	}

	errno = ENOENT;
	return NULL;
}

LS_STATIC FILE * (*orig_freopen)(const char *pathname, const char *mode, FILE *stream);
LS_STATIC FILE * new_freopen(const char *pathname, const char *mode, FILE *stream){

	if(isCallerTweak() && !isCPathRestricted(pathname))
	{
		return orig_freopen(pathname, mode, stream);
	}

	errno = ENOENT;
	return NULL;
}

static char* (*orig_realpath)(const char* pathname, char* resolved_path);
static char* new_realpath(const char* pathname, char* resolved_path) {
    char* result = orig_realpath(pathname, resolved_path);

    if(result && !isCallerTweak() && isCPathRestricted(pathname)) {
        errno = ENOENT;
        return NULL;
    }

    return result;
}

static int (*orig_getattrlist)(const char* path, struct attrlist* attrList, void* attrBuf, size_t attrBufSize, unsigned long options);
static int new_getattrlist(const char* path, struct attrlist* attrList, void* attrBuf, size_t attrBufSize, unsigned long options) {
    int result = orig_getattrlist(path, attrList, attrBuf, attrBufSize, options);

    if(result != -1 && !isCallerTweak() && isCPathRestricted(path)) {
        errno = ENOENT;
        return -1;
    }

    return result;
}

static int (*orig_symlink)(const char* path1, const char* path2);
static int new_symlink(const char* path1, const char* path2) {
    if(isCallerTweak() || !isCPathRestricted(path2)) {
        return orig_symlink(path1, path2);
    }

    errno = EACCES;
    return -1;
}

static int (*orig_link)(const char* path1, const char* path2);
static int new_link(const char* path1, const char* path2) {
    if(isCallerTweak() || !(isCPathRestricted(path1) || isCPathRestricted(path2))) {
        return orig_link(path1, path2);
    }

    errno = ENOENT;
    return -1;
}

static int (*orig_rename)(const char* old, const char* new);
static int new_rename(const char* old, const char* new) {
    if(isCallerTweak() || !(isCPathRestricted(old) || isCPathRestricted(new))) {
        return orig_rename(old, new);
    }

    errno = ENOENT;
    return -1;
}

static int (*orig_remove)(const char* pathname);
static int new_remove(const char* pathname) {
    if(isCallerTweak() || !isCPathRestricted(pathname)) {
        return orig_remove(pathname);
    }

    errno = ENOENT;
    return -1;
}

static int (*orig_unlink)(const char* pathname);
static int new_unlink(const char* pathname) {
    if(isCallerTweak() || !isCPathRestricted(pathname)) {
        return orig_unlink(pathname);
    }

    errno = ENOENT;
    return -1;
}

static int (*orig_unlinkat)(int dirfd, const char* pathname, int flags);
static int new_unlinkat(int dirfd, const char* pathname, int flags) {
    if(isCallerTweak()) {
        return orig_unlinkat(dirfd, pathname, flags);
    }

    if(pathname
    && dirfd != fileno(stderr)
    && dirfd != fileno(stdout)
    && dirfd != fileno(stdin)) {
        NSString* path = [NSString stringWithUTF8String:pathname];

        // Get file descriptor path.
		# if 0
        char pathnameParent[PATH_MAX];
        NSString* pathParent = nil;

        if(dirfd == AT_FDCWD) {
            pathParent = [[NSFileManager defaultManager] currentDirectoryPath];
        } else if(fcntl(dirfd, F_GETPATH, pathnameParent) != -1) {
            pathParent = [NSString stringWithUTF8String:pathnameParent];
        }
		#endif

        if(isPathRestricted(path)) {
            errno = [path isAbsolutePath] ? ENOENT : EBADF;
            return -1;
        }
    }

    return orig_unlinkat(dirfd, pathname, flags);
}

static int (*orig_rmdir)(const char* pathname);
static int new_rmdir(const char* pathname) {
    if(isCallerTweak() || !isCPathRestricted(pathname)) {
        return orig_rmdir(pathname);
    }

    errno = ENOENT;
    return -1;
}

static long (*orig_pathconf)(const char* pathname, int name);
static long new_pathconf(const char* pathname, int name) {
    if(isCallerTweak() || !isCPathRestricted(pathname)) {
        return orig_pathconf(pathname, name);
    }

    errno = ENOENT;
    return -1;
}

static long (*orig_fpathconf)(int fd, int name);
static long new_fpathconf(int fd, int name) {
    if(isCallerTweak()) {
        return orig_fpathconf(fd, name);
    }
    
    if(fd != fileno(stderr)
    && fd != fileno(stdout)
    && fd != fileno(stdin)) {
        // Get file descriptor path.
        char pathname[PATH_MAX];

        if(fcntl(fd, F_GETPATH, pathname) != -1 && isCPathRestricted(pathname)) {
            errno = EBADF;
            return -1;
        }
    }

    return orig_fpathconf(fd, name);
}

static int (*orig_utimes)(const char* pathname, const struct timeval times[2]);
static int new_utimes(const char* pathname, const struct timeval times[2]) {
    if(isCallerTweak() || !isCPathRestricted(pathname)) {
        return orig_utimes(pathname, times);
    }

    errno = ENOENT;
    return -1;
}

static int (*orig_futimes)(int fd, const struct timeval times[2]);
static int new_futimes(int fd, const struct timeval times[2]) {
    if(isCallerTweak()) {
        return orig_futimes(fd, times);
    }
    
    if(fd != fileno(stderr)
    && fd != fileno(stdout)
    && fd != fileno(stdin)) {
        // Get file descriptor path.
        char pathname[PATH_MAX];

        if(fcntl(fd, F_GETPATH, pathname) != -1 && isCPathRestricted(pathname)) {
            errno = EBADF;
            return -1;
        }
    }

    return orig_futimes(fd, times);
}

LS_STATIC char *(*orig_getenv)(const char *name);
LS_STATIC char *new_getenv(const char *name)
{
	if(isCallerTweak()) {
        return orig_getenv(name);
    }

	char *result = orig_getenv(name);
	if(result && !isCallerTweak() && strcmp(name, "DYLD_INSERT_LIBRARIES") == 0)
	{
		return NULL;
	}

	return result;
}

/* Debugger checks 
https://github.com/vtky/ios-antidebugging/blob/master/antidebugging/main.m#L27
*/
LS_STATIC int (*orig_ptrace)(int request, pid_t pid, caddr_t addr, int data);
LS_STATIC int new_ptrace(int request, pid_t pid, caddr_t addr, int data) {
	if (request == PT_DENY_ATTACH) {
        return 0;
    }
    return orig_ptrace(request, pid, addr, data);
}

static int (*orig_sysctl)(int* name, u_int namelen, void* oldp, size_t* oldlenp, void* newp, size_t newlen);
static int new_sysctl(int* name, u_int namelen, void* oldp, size_t* oldlenp, void* newp, size_t newlen) {
    if(namelen == 4
    && name[0] == CTL_KERN
    && name[1] == KERN_PROC
    && name[2] == KERN_PROC_ALL
    && name[3] == 0) {
        // Running process check.
        *oldlenp = 0;
        return 0;
    }

    int ret = orig_sysctl(name, namelen, oldp, oldlenp, newp, newlen);

    if(ret == 0
    && name[0] == CTL_KERN
    && name[1] == KERN_PROC
    && name[2] == KERN_PROC_PID
    && name[3] == getpid()) {
        // Remove trace flag.
        if(oldp) {
            struct kinfo_proc *p = ((struct kinfo_proc *) oldp);

            if((p->kp_proc.p_flag & P_TRACED) == P_TRACED) {
                p->kp_proc.p_flag &= ~P_TRACED;
            }

			if(p->kp_proc.p_flag & P_SELECT) {
                p->kp_proc.p_flag &= ~P_SELECT;
            }
        }
    }

    return ret;
}

LS_STATIC pid_t (*orig_getppid)(void);
LS_STATIC pid_t new_getppid(void) 
{
    return 1;
}

kern_return_t (*orig_task_get_exception_ports)(task_t task, exception_mask_t exception_mask, exception_mask_array_t masks, mach_msg_type_number_t *masksCnt, exception_handler_array_t old_handlers, exception_behavior_array_t old_behaviors, exception_flavor_array_t old_flavors);
kern_return_t new_task_get_exception_ports(task_t task, exception_mask_t exception_mask, exception_mask_array_t masks, mach_msg_type_number_t *masksCnt, exception_handler_array_t old_handlers, exception_behavior_array_t old_behaviors, exception_flavor_array_t old_flavors) {
	kern_return_t result = orig_task_get_exception_ports(task, exception_mask, masks, masksCnt, old_handlers, old_behaviors, old_flavors);
	if(exception_mask == EXC_MASK_ALL) {
		if(result == KERN_SUCCESS) {
			// Needs some work.
			*masksCnt = 0;
		}
	}

	return result;
}

LS_STATIC int (*orig_isatty)(int fd);
LS_STATIC int new_isatty(int fd) 
{
	int result = orig_isatty(fd);
    if (result && fd == STDOUT_FILENO) {
		errno = ENOENT;
        return 0;
    }
	return result;
}

LS_STATIC int (*orig_ioctl)(int fd, unsigned long request, ...);
LS_STATIC int new_ioctl(int fd, unsigned long request, ...) {
	void* arg;
    va_list args;
    va_start(args, request);
    arg = va_arg(args, void *);
    va_end(args);

	int result = orig_ioctl(fd, request, arg);
	if(!result && request == TIOCGWINSZ) {
		errno = ENOTTY;
		return -1;
	}
	return result;
}

static int (*orig_open)(const char *pathname, int oflag, ...);
static int new_open(const char *pathname, int oflag, ...) {
    void* arg;
    va_list args;
    va_start(args, oflag);
    arg = va_arg(args, void *);
    va_end(args);

    if(isCallerTweak() || !isCPathRestricted(pathname)) {
        return orig_open(pathname, oflag, arg);
    }

    errno = ENOENT;
    return -1;
}

static int (*orig_openat)(int dirfd, const char *pathname, int oflag, ...);
static int new_openat(int dirfd, const char *pathname, int oflag, ...) {
    void* arg;
    va_list args;
    va_start(args, oflag);
    arg = va_arg(args, void *);
    va_end(args);

    if(isCallerTweak()) {
        return orig_openat(dirfd, pathname, oflag, arg);
    }

    if(pathname
    && dirfd != fileno(stderr)
    && dirfd != fileno(stdout)
    && dirfd != fileno(stdin)) {
        NSString* path = [NSString stringWithUTF8String:pathname];

        // Get file descriptor path.
		# if 0
        char pathnameParent[PATH_MAX];
        NSString* pathParent = nil;

        if(dirfd == AT_FDCWD) {
            pathParent = [[NSFileManager defaultManager] currentDirectoryPath];
        } else if(fcntl(dirfd, F_GETPATH, pathnameParent) != -1) {
            pathParent = [NSString stringWithUTF8String:pathnameParent];
        }
		#endif

        if(isPathRestricted(path)) {
            errno = [path isAbsolutePath] ? ENOENT : EBADF;
            return -1;
        }
    }

    return orig_openat(dirfd, pathname, oflag, arg);
}

static DIR* (*orig___opendir2)(const char* pathname, size_t bufsize);
static DIR* new___opendir2(const char* pathname, size_t bufsize) {
    if(isCallerTweak() || !isCPathRestricted(pathname)) {
        return orig___opendir2(pathname, bufsize);
    }

    errno = ENOENT;
    return NULL;
}

# if 0
LS_STATIC int (*orig_posix_spawn)(pid_t *pid, const char *pathname, const posix_spawn_file_actions_t *file_actions, const posix_spawnattr_t *attrp, char *const argv[], char *const envp[]);
LS_STATIC int new_posix_spawn(pid_t *pid, const char *pathname, const posix_spawn_file_actions_t *file_actions, const posix_spawnattr_t *attrp, char *const argv[], char *const envp[])
{
	if(!isCallerTweak() && isCPathRestricted(pathname))
	{
		return ENOENT;
	}

	return orig_posix_spawn(pid, pathname, file_actions, attrp, argv, envp);
}

LS_STATIC int (*orig_posix_spawnp)(pid_t *pid, const char *pathname, const posix_spawn_file_actions_t *file_actions, const posix_spawnattr_t *attrp, char *const argv[], char *const envp[]);
LS_STATIC int new_posix_spawnp(pid_t *pid, const char *pathname, const posix_spawn_file_actions_t *file_actions, const posix_spawnattr_t *attrp, char *const argv[], char *const envp[])
{
	if(!isCallerTweak() && isCPathRestricted(pathname))
	{
		return ENOENT;
	}

	return orig_posix_spawnp(pid, pathname, file_actions, attrp, argv, envp);
}
#endif

void _supporthook_libc(void)
{
	// unsetenv("DYLD_INSERT_LIBRARIES");
	LS_AutoHookSymbol(NSGetEnviron);

    LS_AutoHookSymbol(access);
    LS_AutoHookSymbol(chdir);
    LS_AutoHookSymbol(chroot);
    LS_AutoHookSymbol(creat);
    LS_AutoHookSymbol(statfs);
    LS_AutoHookSymbol(fstatfs);
    LS_AutoHookSymbol(statvfs);
    LS_AutoHookSymbol(fstatvfs);
    LS_AutoHookSymbol(stat);
    LS_AutoHookSymbol(lstat);
    LS_AutoHookSymbol(faccessat);
    LS_AutoHookSymbol(readdir_r);
    LS_AutoHookSymbol(readdir);
    LS_AutoHookSymbol(fopen);
    LS_AutoHookSymbol(freopen);
    LS_AutoHookSymbol(realpath);
    LS_AutoHookSymbol(readlink);
    LS_AutoHookSymbol(readlinkat);
    LS_AutoHookSymbol(link);
    // LS_AutoHookSymbol(scandir);
    LS_AutoHookSymbol(getmntinfo);
    LS_AutoHookSymbol(getattrlist);
    LS_AutoHookSymbol(symlink);
    LS_AutoHookSymbol(rename);
    LS_AutoHookSymbol(remove);
    LS_AutoHookSymbol(unlink);
    LS_AutoHookSymbol(unlinkat);
    LS_AutoHookSymbol(rmdir);
    LS_AutoHookSymbol(pathconf);
    LS_AutoHookSymbol(fpathconf);
    LS_AutoHookSymbol(utimes);
    LS_AutoHookSymbol(futimes);
    LS_AutoHookSymbol(fchdir);
    LS_AutoHookSymbol(getfsstat);
    LS_AutoHookSymbol(fstat);
    LS_AutoHookSymbol(fstatat);

	LS_AutoHookSymbol(getenv);

	//low level
	LS_AutoHookSymbol(open);
	LS_AutoHookSymbol(openat);
	LS_AutoHookSymbol(__opendir2);
}

void _supporthook_libc_antidebug(void)
{
    SupportHookSymbolEx("sysctl", new_sysctl, (void **)&orig_sysctl);
	SupportHookSymbolEx("ptrace", new_ptrace, (void **)&orig_ptrace);
    SupportHookSymbolEx("getppid", new_getppid, (void **)&orig_getppid);

	SupportHookSymbolEx("isatty", new_isatty, (void **)&orig_isatty);
	SupportHookSymbolEx("ioctl", new_ioctl, (void **)&orig_ioctl);
	SupportHookSymbolEx("task_get_exception_ports", new_task_get_exception_ports, (void **)&orig_task_get_exception_ports);
}