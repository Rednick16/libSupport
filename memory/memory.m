#include <libkern/OSCacheControl.h>
#include "mach/mach_vm.h"
#include "memory.h"
#include "support_priv.h"

// ref: https://github.com/khanhduytran0/LiveContainer/blob/main/dyld_bypass_validation.m
__attribute__((__naked__, __noinline__))
kern_return_t _LSM_vm_protect_trap(vm_map_t target_task, vm_address_t address, vm_size_t size, boolean_t set_maximum, vm_prot_t new_protection) 
{
    __asm__ __volatile__(
        "mov x16, #-0xe\n"
        "svc #0x80\n"
        "ret\n"
    );
}

LS_FORCE_INLINE
void _supportmem_clearcache(void* start, size_t size) 
{
    sys_dcache_flush(start, size);
    sys_icache_invalidate(start, size);
}
 
static kern_return_t _supportmem_vm_protect(vm_map_t target_task, mach_vm_address_t address, mach_vm_size_t size, int protection) { 
    return _LSM_vm_protect_trap(target_task, 
                              (vm_address_t)address, 
                              (vm_size_t)size, 
                              FALSE, 
                              (vm_prot_t)protection);
}

LS_FORCE_INLINE
void * _supportmem_copy(void *dest, const void *src, size_t len) 
{
    uint8_t *d = dest;
    const uint8_t *s = src;
    while (len--)
        *d++ = *s++;
    return dest;
}

static kern_return_t _supportmem_pageinfo(vm_map_t target_task, mach_vm_address_t address, vm_region_submap_info_data_64_t *info) 
{
    mach_vm_size_t size = 0;
    mach_msg_type_number_t count = VM_REGION_SUBMAP_INFO_COUNT_64;
    natural_t depth = 0;
    kern_return_t kr;

    while ((kr = mach_vm_region_recurse(target_task, &address, &size, &depth,
                                        (vm_region_recurse_info_t)info, &count)) == KERN_SUCCESS && info->is_submap)
    {
        depth++;
    }

    return kr;
}

LS_FORCE_INLINE 
int _supportmem_protect(void *address, size_t size, int protection) 
{
    return _supportmem_vm_protect(mach_task_self(), (mach_vm_address_t)address, (mach_vm_size_t)size, (vm_prot_t)protection);
    //return (_SM_vm_protect_trap(mach_task_self(), (vm_address_t)address, (vm_size_t)size, FALSE, (vm_prot_t)protection) == KERN_SUCCESS) 
    //    || (mach_vm_protect(mach_task_self(), (mach_vm_address_t)address, (mach_vm_size_t)size, FALSE, (vm_prot_t)protection) == KERN_SUCCESS);
}

LS_FORCE_INLINE
int _supportmem_code_patch(void* address, const uint8_t* buffer, size_t size) 
{
    if (LS_UNLIKELY(!address || !buffer || !size)) 
    {
        LS_LOG("_supportmem_code_patch(): invalid arguments (addr=%p, buffer=%p, size=%zu)", address, buffer, size);
        return !address ? LSM_INVALID_ADDRESS :
               !buffer ? LSM_INVALID_BUFFER : LSM_INVALID_LENGTH;
    }
    
    uintptr_t page_start = _LSM_PAGE_START(address);
    uintptr_t page_offset = _LSM_PAGE_OFFSET(address);
    size_t page_size = _LSM_PAGE_SIZE(address, size);
    
    mach_port_t self_task = mach_task_self();
    kern_return_t kr;

    mach_vm_address_t mach_vm_page_start = LS_CAST(mach_vm_address_t, page_start);
    vm_region_submap_info_data_64_t page_info = {0};
    
    kr = _supportmem_pageinfo(self_task, mach_vm_page_start, &page_info);
    if (LS_UNLIKELY(kr != KERN_SUCCESS))
    {
        LS_LOG("_supportmem_pageinfo(): failed to get page info (kr=%d: %s)", 
                kr, mach_error_string(kr));
        return LSM_FAILURE;
    }
    
    vm_prot_t prot = page_info.protection;
    vm_prot_t max_prot = page_info.max_protection;
    vm_inherit_t inheritance = page_info.inheritance;
    uint8_t share_mode = page_info.share_mode;
    
    char r = (prot & VM_PROT_READ) ? 'r' : '-';
    char w = (prot & VM_PROT_WRITE) ? 'w' : '-';
    char x = (prot & VM_PROT_EXECUTE) ? 'x' : '-';

    char r_max = (max_prot & VM_PROT_READ) ? 'r' : '-';
    char w_max = (max_prot & VM_PROT_WRITE) ? 'w' : '-';
    char x_max = (max_prot & VM_PROT_EXECUTE) ? 'x' : '-';

    LS_UNUSED(r); LS_UNUSED(r_max);
    LS_UNUSED(w); LS_UNUSED(w_max);
    LS_UNUSED(x); LS_UNUSED(x_max);

    LS_LOG("_supportmem_code_patch() region: %016llX, protection: %c%c%c, max protection: %c%c%c, share mode: %d, size: %llu bytes",
       page_start, r, w, x, r_max, w_max, x_max, share_mode, page_size);
    
#if 1
    if(prot & VM_PROT_WRITE)
    {
        if(LS_UNLIKELY(_supportmem_copy(address, buffer, size) == NULL))
        {
            LS_LOG("_supportmem_code_patch() failed to copy patch to address (%p)", address);
            return LSM_FAILURE;
        }
        return LSM_SUCCESS;
    }
#endif
    
#if 0
    if(_supportmem_protect((void *)page_start, page_size, LS_PROT_ALL))
    {
        //LS_LOG("_supportmem_code_patch() page is writable, applying patch.");
        if(_supportmem_copy(address, buffer, size) == NULL)
            //kret = mach_vm_write(self_task, (mach_vm_address_t)address, (vm_offset_t)buffer, (mach_msg_type_number_t)size);
            //if(kret != KERN_SUCCESS)
        {
            LS_LOG("_supportmem_code_patch() error: failed to write patch to address (%p)", address);
            return LS_PATCH_FAILURE;
        }
        
        if (_supportmem_protect((void *)page_start, page_size, protection) == 0)
        {
            LS_LOG("_supportmem_code_patch() error: failed to restore %c%c%c protection(s).",
                   r, w, x);
            return LS_PATCH_FAILURE;
        }
        
        //LS_LOG("_supportmem_code_patch() patch successfully applied via direct write.");
        _supportmem_clearcache(address, size);
        return LS_PATCH_SUCCESS;
    }
#endif
    
    //LS_LOG("_supportmem_code_patch() page is (NOT) writable, remapping required.");
    
    void* remap_page = __mmap(NULL, page_size, (LSM_PROT_READ|LSM_PROT_WRITE),
                             (MAP_ANONYMOUS|MAP_PRIVATE), -1, 0);

    if(LS_UNLIKELY(remap_page == NULL || remap_page == MAP_FAILED))
    {
        LS_LOG("_supportmem_code_patch(): mmap failed (%s)", strerror(errno));
        return LSM_MAP_FAILURE;
    }
    
    LS_LOG("_supportmem_code_patch(): attempting remap from %p to %p (size: %llu)", 
            remap_page, address, page_size);
    int result = LSM_FAILURE;
    
    do
    {
        _supportmem_copy(remap_page, LS_CAST(void*, page_start), page_size);
        
        _supportmem_copy(LS_CAST(void*, LS_CAST(uintptr_t, remap_page) + page_offset), buffer, size);
        
        kr = _supportmem_vm_protect(self_task, LS_CAST(mach_vm_address_t, remap_page), page_size, (LSM_PROT_READ|LSM_PROT_EXEC));
        if (LS_UNLIKELY(kr != KERN_SUCCESS))
        {
            LS_LOG("_supportmem_code_patch(): mach_vm_protect failed at %p (kr=%d: %s)", 
                    remap_page, kr, mach_error_string(kr));
            break;
        }
        
        vm_prot_t cur_protection, max_protection;
        kr = mach_vm_remap(self_task, &mach_vm_page_start, page_size, 0,
                             (VM_FLAGS_OVERWRITE|VM_FLAGS_FIXED),
                             self_task, LS_CAST(mach_vm_address_t, remap_page),
                             TRUE,
                             &cur_protection, &max_protection,
                             inheritance);
        if(LS_UNLIKELY(kr != KERN_SUCCESS)) 
        {
            LS_LOG("_supportmem_code_patch(): mach_vm_remap failed (kr=%d: %s)", 
                    kr, mach_error_string(kr));
            break;
        }
        
        _supportmem_clearcache(address, size);
        result = LSM_SUCCESS;
    } while (0);
    
    munmap(remap_page, page_size);
    return result;
}
