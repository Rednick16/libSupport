#import "hooks.h"

// NSURL -> start
LS_STATIC BOOL (*NSURL$$orig_checkResourceIsReachableAndReturnError)(id self, SEL selector, NSError * _Nullable *error );
LS_STATIC BOOL NSURL$$new_checkResourceIsReachableAndReturnError(id self, SEL selector, NSError * _Nullable *error )
{
    NSString* path = [self absoluteString];
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return NSURL$$orig_checkResourceIsReachableAndReturnError(self, selector, error);
}

LS_STATIC BOOL (*NSURL$$orig_checkPromisedItemIsReachableAndReturnError)(id self, SEL selector, NSError * _Nullable *error);
LS_STATIC BOOL NSURL$$new_checkPromisedItemIsReachableAndReturnError(id self, SEL selector, NSError * _Nullable *error)
{
    NSString* path = [self absoluteString];
    if(!isCallerTweak() && isPathRestricted(path))  
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return NSURL$$orig_checkPromisedItemIsReachableAndReturnError(self, selector, error);
}

LS_STATIC NSURL* (*NSURL$$orig_fileReferenceURL)(id self, SEL selector);
LS_STATIC NSURL* NSURL$$new_fileReferenceURL(id self, SEL selector)
{
    NSString* path = [self absoluteString];
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSURL$$orig_fileReferenceURL(self, selector);
}

LS_STATIC NSData* (*NSURL$$orig_bookmarkDataWithContentsOfURL$error)(id self, SEL selector, NSURL *bookmarkFileURL, NSError * _Nullable *error);
LS_STATIC NSData* NSURL$$new_bookmarkDataWithContentsOfURL$error(id self, SEL selector, NSURL *bookmarkFileURL, NSError * _Nullable *error)
{
    NSString* path = bookmarkFileURL.absoluteString;
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return nil;
    }

    return NSURL$$orig_bookmarkDataWithContentsOfURL$error(self, selector, bookmarkFileURL, error);
}
// NSURL -> end

// NSURLSession -> start

LS_STATIC NSURLSessionDataTask * (*NSURLSession$$orig_dataTaskWithURL)(id self, SEL selector, NSURL *url);
LS_STATIC NSURLSessionDataTask * NSURLSession$$new_dataTaskWithURL(id self, SEL selector, NSURL *url) 
{
    NSString* path = url.absoluteString;
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSURLSession$$orig_dataTaskWithURL(self, selector, url);
}

LS_STATIC NSURLSessionDataTask * (*NSURLSession$$orig_dataTaskWithURL$completionHandler)(id self, SEL selector, NSURL *url, void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) );
LS_STATIC NSURLSessionDataTask * NSURLSession$$new_dataTaskWithURL$completionHandler(id self, SEL selector, NSURL *url, void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) )
{
    NSString* path = url.absoluteString;
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSURLSession$$orig_dataTaskWithURL$completionHandler(self, selector, url, completionHandler);
}

LS_STATIC NSURLSessionDownloadTask * (*NSURLSession$$orig_downloadTaskWithURL)(id self, SEL selector, NSURL * url);
LS_STATIC NSURLSessionDownloadTask * NSURLSession$$new_downloadTaskWithURL(id self, SEL selector, NSURL * url)
{
    NSString* path = url.absoluteString;
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSURLSession$$orig_downloadTaskWithURL(self, selector, url);
}

LS_STATIC NSURLSessionDownloadTask * (*NSURLSession$$orig_downloadTaskWithURL$completionHandler)(id self, SEL selector, NSURL *url, void (^completionHandler)(NSURL *location, NSURLResponse *response, NSError *error) );
LS_STATIC NSURLSessionDownloadTask * NSURLSession$$new_downloadTaskWithURL$completionHandler(id self, SEL selector, NSURL *url, void (^completionHandler)(NSURL *location, NSURLResponse *response, NSError *error) ) 
{
    NSString* path = url.absoluteString;
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSURLSession$$orig_downloadTaskWithURL$completionHandler(self, selector, url, completionHandler);
}

LS_STATIC NSURLSessionUploadTask * (*NSURLSession$$orig_uploadTaskWithRequest$fromFile)(id self, SEL selector, NSURLRequest *request, NSURL *fileURL);
LS_STATIC NSURLSessionUploadTask * NSURLSession$$new_uploadTaskWithRequest$fromFile(id self, SEL selector, NSURLRequest *request, NSURL *fileURL) 
{
    NSString* path = fileURL.absoluteString;
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSURLSession$$orig_uploadTaskWithRequest$fromFile(self, selector, request, fileURL);
}

LS_STATIC NSURLSessionUploadTask * (*NSURLSession$$orig_uploadTaskWithRequest$fromFile$completionHandler)(id self, SEL selector, NSURLRequest *request, NSURL *fileURL, void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) );
LS_STATIC NSURLSessionUploadTask * NSURLSession$$new_uploadTaskWithRequest$fromFile$completionHandler(id self, SEL selector, NSURLRequest *request, NSURL *fileURL, void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) ) 
{
    NSString* path = fileURL.absoluteString;
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSURLSession$$orig_uploadTaskWithRequest$fromFile$completionHandler(self, selector, request, fileURL, completionHandler);
}
// NSURLSession -> end

// NSURLRequest -> start

LS_STATIC id (*NSURLRequest$$orig_requestWithURL)(id self, SEL selector, NSURL *URL);
LS_STATIC id NSURLRequest$$new_requestWithURL(id self, SEL selector, NSURL *URL) 
{
    NSString* path = URL.absoluteString;
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSURLRequest$$orig_requestWithURL(self, selector, URL);
}

LS_STATIC id (*NSURLRequest$$orig_initWithURL)(id self, SEL selector, NSURL *URL);
LS_STATIC id NSURLRequest$$new_initWithURL(id self, SEL selector, NSURL *URL) 
{
    NSString* path = URL.absoluteString;
    if(!isCallerTweak() && isPathRestricted(path)) 
    {        
        return nil;
    }

    return NSURLRequest$$orig_initWithURL(self, selector, URL);
}

LS_STATIC id (*NSURLRequest$$orig_requestWithURL$cachePolicy$timeoutInterval)(id self, SEL selector, NSURL *URL, NSURLRequestCachePolicy cachePolicy, NSTimeInterval timeoutInterval);
LS_STATIC id NSURLRequest$$new_requestWithURL$cachePolicy$timeoutInterval(id self, SEL selector, NSURL *URL, NSURLRequestCachePolicy cachePolicy, NSTimeInterval timeoutInterval) 
{
    NSString* path = URL.absoluteString;
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSURLRequest$$orig_requestWithURL$cachePolicy$timeoutInterval(self, selector, URL, cachePolicy, timeoutInterval);
}

LS_STATIC id (*NSURLRequest$$orig_initWithURL$cachePolicy$timeoutInterval)(id self, SEL selector, NSURL *URL, NSURLRequestCachePolicy cachePolicy, NSTimeInterval timeoutInterval);
LS_STATIC id NSURLRequest$$new_initWithURL$cachePolicy$timeoutInterval(id self, SEL selector, NSURL *URL, NSURLRequestCachePolicy cachePolicy, NSTimeInterval timeoutInterval) 
{
    NSString* path = URL.absoluteString;
    if(!isCallerTweak() && isPathRestricted(path)) 
    {
        return nil;
    }

    return NSURLRequest$$orig_initWithURL$cachePolicy$timeoutInterval(self, selector, URL, cachePolicy, timeoutInterval);
}
// NSURLRequest -> end

void _supporthook_NSURL(void)
{
    // NSURL
	SupportHookInstanceMessage("NSURL", "checkResourceIsReachableAndReturnError:", NSURL$$new_checkResourceIsReachableAndReturnError, NSURL$$orig_checkResourceIsReachableAndReturnError);
	SupportHookInstanceMessage("NSURL", "checkPromisedItemIsReachableAndReturnError:", NSURL$$new_checkPromisedItemIsReachableAndReturnError, NSURL$$orig_checkPromisedItemIsReachableAndReturnError);
	SupportHookInstanceMessage("NSURL", "fileReferenceURL:", NSURL$$new_fileReferenceURL, NSURL$$orig_fileReferenceURL);
	SupportHookClassMessage("NSURL", "bookmarkDataWithContentsOfURL:error:", NSURL$$new_bookmarkDataWithContentsOfURL$error, NSURL$$orig_bookmarkDataWithContentsOfURL$error);

	// NSURLSession
	SupportHookInstanceMessage("NSURLSession", "dataTaskWithURL:", NSURLSession$$new_dataTaskWithURL, NSURLSession$$orig_dataTaskWithURL);
	SupportHookInstanceMessage("NSURLSession", "dataTaskWithURL:completionHandler:", NSURLSession$$new_dataTaskWithURL$completionHandler, NSURLSession$$orig_dataTaskWithURL$completionHandler);
	SupportHookInstanceMessage("NSURLSession", "downloadTaskWithURL:", NSURLSession$$new_downloadTaskWithURL, NSURLSession$$orig_downloadTaskWithURL);
	SupportHookInstanceMessage("NSURLSession", "downloadTaskWithURL:completionHandler:", NSURLSession$$new_downloadTaskWithURL$completionHandler, NSURLSession$$orig_downloadTaskWithURL$completionHandler);
	SupportHookInstanceMessage("NSURLSession", "uploadTaskWithRequest:fromFile:", NSURLSession$$new_uploadTaskWithRequest$fromFile, NSURLSession$$orig_uploadTaskWithRequest$fromFile);
	SupportHookInstanceMessage("NSURLSession", "uploadTaskWithRequest:fromFile:completionHandler:", NSURLSession$$new_uploadTaskWithRequest$fromFile$completionHandler, NSURLSession$$orig_uploadTaskWithRequest$fromFile$completionHandler);

	// NSURLRequest
	SupportHookClassMessage("NSURLRequest", "requestWithURL:", NSURLRequest$$new_requestWithURL, NSURLRequest$$orig_requestWithURL);
	SupportHookInstanceMessage("NSURLRequest", "initWithURL:", NSURLRequest$$new_initWithURL, NSURLRequest$$orig_initWithURL);
	SupportHookClassMessage("NSURLRequest", "requestWithURL:cachePolicy:timeoutInterval:", NSURLRequest$$new_requestWithURL$cachePolicy$timeoutInterval, NSURLRequest$$orig_requestWithURL$cachePolicy$timeoutInterval);
	SupportHookInstanceMessage("NSURLRequest", "initWithURL:cachePolicy:timeoutInterval:", NSURLRequest$$new_initWithURL$cachePolicy$timeoutInterval, NSURLRequest$$orig_initWithURL$cachePolicy$timeoutInterval);
}