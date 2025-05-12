#import "hooks.h"

LS_STATIC const char* (*orig_class_getImageName)(Class cls);
LS_STATIC const char* new_class_getImageName(Class cls) 
{
    const char* result = orig_class_getImageName(cls);

    if(isCallerTweak() || !isCPathRestricted(result)) 
    {
        return result;
    }

    return [getExecutablePath() fileSystemRepresentation];
}

// run time filtering
LS_STATIC const char * _Nonnull * (*orig_objc_copyImageNames)(unsigned int *outCount);
LS_STATIC const char * _Nonnull * new_objc_copyImageNames(unsigned int *outCount)
{
    const char * _Nonnull *ret = orig_objc_copyImageNames(outCount);

    if(isCallerTweak() || !ret || !outCount) 
    {
        return ret;
    }

    const char *exec_name = _dyld_get_image_name(0);
    unsigned int i;

    for(i = 0; i < *outCount; i++) 
	{
        if(strcmp(ret[i], exec_name) == 0) 
		{
            // Stop after app executable.
            *outCount = (i + 1);
            break;
        }
    }

    return ret;
}

LS_STATIC const char * _Nonnull * (*orig_objc_copyClassNamesForImage)(const char *image, unsigned int *outCount);
LS_STATIC const char * _Nonnull * new_objc_copyClassNamesForImage(const char *image, unsigned int *outCount) 
{
    if(isCallerTweak() || !isCPathRestricted(image)) 
    {
        return orig_objc_copyClassNamesForImage(image, outCount);
    }

    return NULL;
}

LS_STATIC Class (*orig_NSClassFromString)(NSString* aClassName);
LS_STATIC Class new_NSClassFromString(NSString* aClassName) {
    Class result = orig_NSClassFromString(aClassName);

    if(isCallerTweak() || !isAddrRestricted((__bridge const void *)result)) 
    {
        return result;
    }

    return nil;
}

typedef struct _NXMapTable NXMapTable;
typedef struct _NXHashTable NXHashTable;

extern void* NXMapGet(NXMapTable *table, const char *name);
extern void* NXHashGet(NXHashTable *table, const void *data);

LS_STATIC void* (*orig_NXMapGet)(NXMapTable *table, const char *name);
LS_STATIC void* new_NXMapGet(NXMapTable *table, const char *name) {
    void* result = orig_NXMapGet(table, name);

    if(isCallerTweak() || !isAddrRestricted(result)) {
        return result;
    }

    return nil;
}

LS_STATIC void* (*orig_NXHashGet)(NXHashTable *table, const void *data);
LS_STATIC void* new_NXHashGet(NXHashTable *table, const void *data) {
    void* result = orig_NXHashGet(table, data);

    if(isCallerTweak() || !isAddrRestricted(result)) {
        return result;
    }

    return nil;
}

LS_STATIC IMP (*orig_method_getImplementation)(Method m);
LS_STATIC IMP new_method_getImplementation(Method m) 
{
	IMP result = orig_method_getImplementation(m);
	if(result) 
	{
        if(!isCallerTweak() && isAddrRestricted((void *)result)) 
        {
            return nil;
        }
	}
	return result;
}

LS_STATIC Method (*orig_class_getInstanceMethod)(Class cls, SEL sel);
LS_STATIC Method new_class_getInstanceMethod(Class cls, SEL sel) 
{
    Method result = orig_class_getInstanceMethod(cls, sel);
    if(result) 
	{
		IMP imp = method_getImplementation(result);
		if(imp)
		{
            if(!isCallerTweak() && isAddrRestricted((void *)imp)) 
            {
                return nil;
            }
		}
    }
    return result;
}

// denie class look up

LS_STATIC Class (*orig_objc_lookUpClass)(const char* name);
LS_STATIC Class new_objc_lookUpClass(const char* name) 
{
    Class result = orig_objc_lookUpClass(name);
    if(result) 
    {
        if(!isCallerTweak() && isAddrRestricted((__bridge const void *)result)) 
        {
            return nil;
        }
    }
    return result;
}

LS_STATIC Class (*orig_objc_getClass)(const char* name);
LS_STATIC Class new_objc_getClass(const char* name)
{
    Class result = orig_objc_getClass(name);
    if(result) 
	{
        if(!isCallerTweak() && isAddrRestricted((__bridge const void *)result)) 
        {
            return nil;
        }
    }
    return result;
}

LS_STATIC Class (*orig_objc_getMetaClass)(const char* name);
LS_STATIC Class new_objc_getMetaClass(const char* name) 
{
    Class result = orig_objc_getMetaClass(name);
    if(result) 
	{
        if(!isCallerTweak() && isAddrRestricted((__bridge const void *)result)) 
        {
            return nil;
        }
    }
    return result;
}

LS_STATIC Class (*orig_objc_getRequiredClass)(const char* name);
LS_STATIC Class new_objc_getRequiredClass(const char* name)
{
    Class result = orig_objc_getRequiredClass(name);
    if(result) 
	{
        if(!isCallerTweak() && isAddrRestricted((__bridge const void *)result)) 
        {
            return nil;
        }
    }
    return result;
}

void _supporthook_objc_runtime(void)
{
    SupportHookSymbolEx("class_getImageName", new_class_getImageName, (void **) &orig_class_getImageName);
	SupportHookSymbolEx("objc_copyClassNamesForImage", new_objc_copyClassNamesForImage, (void **)&orig_objc_copyClassNamesForImage);
	SupportHookSymbolEx("objc_copyImageNames", new_objc_copyImageNames, (void **)&orig_objc_copyImageNames);
	SupportHookSymbolEx("objc_lookUpClass", new_objc_lookUpClass, (void **)&orig_objc_lookUpClass);
    SupportHookSymbolEx("objc_getClass", new_objc_getClass, (void**)&orig_objc_getClass);
	SupportHookSymbolEx("objc_getMetaClass", new_objc_getMetaClass, (void**)&orig_objc_getMetaClass);
	SupportHookSymbolEx("method_getImplementation", new_method_getImplementation, (void**)&orig_method_getImplementation);
	SupportHookSymbolEx("class_getInstanceMethod", new_class_getInstanceMethod, (void**)&orig_class_getInstanceMethod);
	SupportHookSymbolEx("NSClassFromString", new_NSClassFromString, (void**)&orig_NSClassFromString);
    SupportHookSymbolEx("NXMapGet", (void *)new_NXMapGet, (void **)&orig_NXMapGet);
    SupportHookSymbolEx("NXHashGet", (void *)new_NXHashGet, (void **)&orig_NXHashGet);

    SupportHookSymbolEx("objc_getRequiredClass", new_objc_getRequiredClass, (void**)&orig_objc_getRequiredClass);
}