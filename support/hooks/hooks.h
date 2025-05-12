#import "support_priv.h"

LS_PRIVATE void _supporthook_dyld(void);
LS_PRIVATE void _supporthook_dyld_symlookup(void);
LS_PRIVATE void _supporthook_dyld_symaddrlookup(void);
LS_PRIVATE void _supporthook_libc(void);
LS_PRIVATE void _supporthook_libc_antidebug(void);
LS_PRIVATE void _supporthook_objc_runtime(void);
LS_PRIVATE void _supporthook_NSBundle(void);
LS_PRIVATE void _supporthook_NSData(void);
LS_PRIVATE void _supporthook_NSString(void);
LS_PRIVATE void _supporthook_NSFileManager(void);
LS_PRIVATE void _supporthook_NSURL(void);
LS_PRIVATE void _supporthook_NSArray(void);
LS_PRIVATE void _supporthook_NSDictionary(void);
LS_PRIVATE void _supporthook_UIApplication(void); 
LS_PRIVATE void _supporthook_NSProcessInfo_antiemulator(void);
LS_PRIVATE void _supporthook_UIImage(void);
LS_PRIVATE void _supporthook_CFNetwork_antiproxy(void);
LS_PRIVATE void _supporthook_CFBundle(void);
LS_PRIVATE void _supporthook_SecTask(void);
LS_PRIVATE void _supporthook_DeviceCheck(void);
LS_PRIVATE void _supporthook_sandbox(void);
LS_PRIVATE void _supporthook_syscall(void);

LS_EXPORT uint32_t _support_dyld_image_count(void);
LS_EXPORT const char* _support_dyld_get_image_name(uint32_t image_index);
LS_EXPORT const struct mach_header* _support_dyld_get_image_header(uint32_t image_index);
LS_EXPORT intptr_t _support_dyld_get_image_vmaddr_slide(uint32_t image_index);