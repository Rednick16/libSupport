#ifndef memory_h
#define memory_h

#include <sys/mman.h>
#include <mach/mach.h>
#include "wrapper.h"

#define _LSM_PAGE_START(address) ((uintptr_t)(address) & ~(PAGE_SIZE - 1))
#define _LSM_PAGE_END(address) (_LSM_PAGE_START((uintptr_t)(address) + PAGE_SIZE - 1))
#define _LSM_PAGE_OFFSET(address) ((uintptr_t)(address) & (PAGE_SIZE - 1))
#define _LSM_PAGE_SIZE(address, size) (_LSM_PAGE_END((uintptr_t)(address) + size) - _LSM_PAGE_START(address))

LS_PRIVATE void * _supportmem_copy(void *dest, const void *src, size_t len);
LS_PRIVATE int _supportmem_protect(void *addr, size_t size, int protection);
LS_PRIVATE int _supportmem_code_patch(void* addr, const uint8_t* buffer, size_t size);
LS_PRIVATE int _supportmem_hookfunction_64(void* function, void* replacement, void** original);

LS_PRIVATE uintptr_t _supportmem_getpagesize(void);
LS_PRIVATE uintptr_t _supportmem_pagestart(void* address);
LS_PRIVATE uintptr_t _supportmem_pagesize(void* address, size_t size);
LS_PRIVATE uintptr_t _supportmem_pageoffset(void* address);

LS_PRIVATE void _supportmem_clearcache(void* start, size_t size);

// SYS
LS_PRIVATE void *  __mmap(void *, size_t, int, int, int, off_t);

#endif //memory_h