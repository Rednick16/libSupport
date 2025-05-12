#import "hooks.h"

@class UIImage;

LS_STATIC UIImage* (*UIImage$$orig_initWithContentsOfFile)(id self, SEL _cmd, NSString *path);
LS_STATIC UIImage* UIImage$$new_initWithContentsOfFile(id self, SEL _cmd, NSString *path)
{
    if(!isCallerTweak() && isPathRestricted(path))
    {
        return nil;
    }
    return UIImage$$orig_initWithContentsOfFile(self, _cmd, path);
}

LS_STATIC UIImage* (*UIImage$$orig_imageWithContentsOfFile)(id self, SEL _cmd, NSString *path);
LS_STATIC UIImage* UIImage$$new_imageWithContentsOfFile(id self, SEL _cmd, NSString *path)
{
    if(!isCallerTweak() && isPathRestricted(path))
    {
        return nil;
    }
    return UIImage$$orig_imageWithContentsOfFile(self, _cmd, path);
}

void _supporthook_UIImage(void)
{
    SupportHookInstanceMessage("UIImage", "initWithContentsOfFile:", UIImage$$new_initWithContentsOfFile, UIImage$$orig_initWithContentsOfFile);
    SupportHookClassMessage("UIImage", "imageWithContentsOfFile:", UIImage$$new_imageWithContentsOfFile, UIImage$$orig_imageWithContentsOfFile);
}