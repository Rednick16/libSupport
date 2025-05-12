#import "support.h"

#if 0
static Method MSFindMethod(Class _class, SEL sel) {
    for (; _class != nil; _class = class_getSuperclass(_class)) {
        unsigned int size;
        Method *methods = class_copyMethodList(_class, &size);
        if (methods == NULL)
            continue;

        for (unsigned int j = 0; j != size; ++j) {
            Method method = methods[j];
            if (!sel_isEqual(method_getName(methods[j]), sel))
                continue;

            free(methods);
            return method;
        }

        free(methods);
    }

    return nil;
}
#endif

LS_EXPORT 
void SupportHookMessageEx(Class _class, SEL sel, IMP imp, IMP *result) 
{
    Method original = class_getInstanceMethod(_class, sel);
    const char *typeEncoding = method_getTypeEncoding(original);
    if(!class_addMethod(_class, sel, imp, typeEncoding)) 
    {
        // Replace implementation and return old implementation
        if(result)
            *result = method_getImplementation(original);
        method_setImplementation(original, imp);
    } 
    else 
    {
        // Add implementation and return super implementation
        Class superClass = class_getSuperclass(_class);
        original = class_getInstanceMethod(superClass, sel);
        if(result)
            *result = method_getImplementation(original);
    }
}

LS_EXPORT
void SupportAddMessageEx(Class _class, SEL sel, IMP imp, const char *typeEncoding, IMP *result) 
{
    if (class_addMethod(_class, sel, imp, typeEncoding)) 
    {
        Class superClass = class_getSuperclass(_class);
        Method original = class_getInstanceMethod(superClass, sel);
        if(result)
            *result = original ? method_getImplementation(original) : NULL;
    }
    else 
    {
        Method original = class_getInstanceMethod(_class, sel);
        if(result)
            *result = method_getImplementation(original);
        method_setImplementation(original, imp);
    }
}