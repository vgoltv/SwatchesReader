//
//  BSColorCollectionFileHandler.m
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 19.12.2019.
//  Copyright © 2019 FWKit. All rights reserved.
//








#import "SRColorCollectionFileHandler.h"
#import "BSFileChunkReader.h"
@import os.log;

#define BS_COLOR_REMOVE_NSBLOCKQUEUE_SAFELY(__POINTER) { if( __POINTER ){ [__POINTER cancelAllOperations]; [__POINTER waitUntilAllOperationsAreFinished]; } __POINTER = nil; }

#define BS_CLOSE_FILE_HANDLER(__FILE_HANDLE, __URL, __SCOPED) {if( __FILE_HANDLE ){ [__FILE_HANDLE closeFile];} __FILE_HANDLE = nil; if(__URL && __SCOPED){[__URL stopAccessingSecurityScopedResource];}}

#define BS_COLOR_DELETE_ARRAY_SAFELY(__POINTER) { if( __POINTER ){ [__POINTER removeAllObjects]; __POINTER = nil; } }

@interface SRColorCollectionFileHandler()<NSFilePresenter>
{
    NSOperationQueue            *_operationQueue;
    NSOperationQueue            *_presentedItemOperationQueue;
    
    NSFileCoordinator           *_fileCoordinator;
    
    NSURL                       *_url;
    
    os_log_t                    _logger;
}

@end

@implementation SRColorCollectionFileHandler

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [NSFileCoordinator removeFilePresenter:self];
    
    BS_COLOR_REMOVE_NSBLOCKQUEUE_SAFELY(_operationQueue);
    BS_COLOR_REMOVE_NSBLOCKQUEUE_SAFELY(_presentedItemOperationQueue);
    
    if(_fileCoordinator)
    {
        [_fileCoordinator cancel];
    }
    _fileCoordinator = nil;
    
    
    _url = nil;
    
    _logger = NULL;
}

- (id)init
{
    if(self = [super init])
    {
        [self _commonInitWithURL:nil];
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url
{
    if(self = [super init])
    {
        [self _commonInitWithURL:url];
    }
    
    return self;
}

- (NSFileCoordinator *)fileCoordinator
{
    return _fileCoordinator;
}

- (void)close
{
    if(_operationQueue)
    {
        [_operationQueue cancelAllOperations];
        
        [_operationQueue waitUntilAllOperationsAreFinished];
    }
    
    if(_presentedItemOperationQueue)
    {
        [_presentedItemOperationQueue cancelAllOperations];
        
        [_presentedItemOperationQueue waitUntilAllOperationsAreFinished];
    }
    
    if(_fileCoordinator)
    {
        [_fileCoordinator cancel];
    }
}

- (void)readColorCollectionWithCompletionHandler:(void (^)(BOOL success, NSURL *url, SRColorCollection *collection ))handler
{
    if(!_url)
    {
        os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "File url is null" );
        
        if(handler)
        {
            handler(NO, _url, nil);
        }
        
        return;
    }
    
    NSString *ext = [[_url pathExtension] uppercaseString];
    if( ![ext isEqualToString:@"GPL"] )
    {
        os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "File extension is not acceptable: %@, path: %@ ", ext,  _url.path );
        
        if(handler)
        {
            handler(NO, _url, nil);
        }
        
        return;
    }
    
    NSBlockOperation *loadingOperation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakLoadingOperation = loadingOperation;
    __weak typeof(self) weakSelf = self;
    [loadingOperation addExecutionBlock:^{
        
        if ( !weakLoadingOperation.isCancelled && weakSelf )
        {
            __strong typeof(self) strongSelf = weakSelf;
            
            NSURL *url = strongSelf.presentedItemURL;
            NSError *coordinatorError;
            [[strongSelf fileCoordinator] coordinateReadingItemAtURL:url
                                                             options:NSFileCoordinatorReadingWithoutChanges | NSFileCoordinatorReadingResolvesSymbolicLink
                                                               error:&coordinatorError
                                                          byAccessor:^(NSURL *newURL) {
                os_log_t logger = os_log_create("com.fwkit.swatches", "color");
                if(coordinatorError)
                {
                    os_log_with_type(logger, OS_LOG_TYPE_ERROR, "File coordinator error: %@", coordinatorError );
                    if(handler)
                    {
                        handler(NO, url, nil);
                    }
                }
                else
                {
                    BOOL securityScoped = [url startAccessingSecurityScopedResource];
                    
                    NSError *error = nil;
                    NSFileHandle *collectionFileHandle = [NSFileHandle fileHandleForReadingFromURL:newURL error:&error];
                    if( error )
                    {
                        os_log_with_type(logger, OS_LOG_TYPE_ERROR, "%@", error.localizedDescription );
                        
                        if(handler)
                        {
                            handler(NO, url, nil);
                        }
                        
                        BS_CLOSE_FILE_HANDLER(collectionFileHandle, newURL, securityScoped);
                        
                        return;
                    }
                    
                    if( !collectionFileHandle )
                    {
                        os_log_with_type(logger, OS_LOG_TYPE_ERROR, "NSFileHandle opening error for url: %@", newURL.absoluteURL );
                        
                        if(handler)
                        {
                            handler(NO, url, nil);
                        }
                        
                        collectionFileHandle = nil;
                        
                        if(securityScoped)
                        {
                            [newURL stopAccessingSecurityScopedResource];
                        }
                        
                        return;
                    }
                    
                    SInt16 majV = 0;
                    SInt16 minV = 0;
                    
                    NSMutableArray<SRColorGroup *> *swatchesGroupArr = [NSMutableArray array];
                    NSMutableArray<SRBaseColor *> *swatchesUngroupedArr = [NSMutableArray array];
                    
                    NSMutableCharacterSet *safeCharacterSet = [NSMutableCharacterSet illegalCharacterSet];
                    [safeCharacterSet formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
                    [safeCharacterSet formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
                    [safeCharacterSet formUnionWithCharacterSet:[NSCharacterSet nonBaseCharacterSet]];
                    
                    if( [ext isEqualToString:@"GPL"] )
                    {
                        BSFileChunkReader *chunkReader = [[BSFileChunkReader alloc] initWithFileHandle:collectionFileHandle];
                        if( !chunkReader )
                        {
                            os_log_with_type(logger, OS_LOG_TYPE_ERROR, "File %@ is not readable", newURL.path );
                            if(handler)
                            {
                                handler(NO, url, nil);
                            }
                            
                            BS_CLOSE_FILE_HANDLER(collectionFileHandle, newURL, securityScoped);
                            
                            BS_COLOR_DELETE_ARRAY_SAFELY(swatchesGroupArr);
                            BS_COLOR_DELETE_ARRAY_SAFELY(swatchesUngroupedArr);
                        }
                        
                        SRColorCollection *collection = [chunkReader readAsGIMPPaletteFromFileHandle:collectionFileHandle];
                        BOOL success = !(collection == nil);
                        if(handler)
                        {
                            handler(success, url, collection);
                        }
                        
                        BS_CLOSE_FILE_HANDLER(collectionFileHandle, newURL, securityScoped);
                        
                        BS_COLOR_DELETE_ARRAY_SAFELY(swatchesGroupArr);
                        BS_COLOR_DELETE_ARRAY_SAFELY(swatchesUngroupedArr);
                        
                        return;
                    }
                    
                    if(handler)
                    {
                        SRColorCollection *collection = [[SRColorCollection alloc] initWithMajVersion:majV
                                                                                                 minVersion:minV
                                                                                                     groups:swatchesGroupArr
                                                                                                     colors:swatchesUngroupedArr];
                        handler(YES, url, collection);
                    }
                    
                    BS_CLOSE_FILE_HANDLER(collectionFileHandle, url, securityScoped);
                    
                    BS_COLOR_DELETE_ARRAY_SAFELY(swatchesGroupArr);
                    BS_COLOR_DELETE_ARRAY_SAFELY(swatchesUngroupedArr);
                    
                }
                
            }];
        }
        else if(handler)
        {
            NSURL *currentURL = nil;
            if(weakSelf)
            {
                currentURL = weakSelf.presentedItemURL;
            }
            handler(NO, currentURL, nil);
        }
    }];
    
    [_operationQueue addOperation:loadingOperation];
}

- (void)stopWithCompletionHandler:(void (^)(BOOL success))handler
{
    [self _cancelAllOperations];
    
    if(handler)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(YES);
        });
    }
}

#pragma mark -NSNotificationCenter observers

-(void)applicationMovedToForeground:(NSNotification *)notification
{

}

- (void)applicationMovedToBackground:(NSNotification *)notification
{

}

#pragma mark -NSFilePresenter methods

- (NSOperationQueue *)presentedItemOperationQueue
{
    NSOperationQueue *queue = nil;
    if(!_presentedItemOperationQueue)
    {
        _presentedItemOperationQueue = [NSOperationQueue new];
        _presentedItemOperationQueue.maxConcurrentOperationCount = 5;
        _presentedItemOperationQueue.qualityOfService = NSQualityOfServiceUtility;
    }
    queue = _presentedItemOperationQueue;
    return queue;
}

- (NSURL *)presentedItemURL
{
    NSURL *url = nil;
    url = _url;
    return url;
}

- (void)accommodatePresentedItemDeletionWithCompletionHandler:(void (^)(NSError * _Nullable errorOrNil))completionHandler
{
    [self _cancelAllOperations];
    
    if(completionHandler)
    {
        completionHandler(nil);
    }
}

- (void)presentedItemDidMoveToURL:(NSURL *)newURL
{
    [self _cancelAllOperations];
    
    _url = newURL? [newURL copy]:nil;
}

- (void)accommodatePresentedSubitemDeletionAtURL:(NSURL *)url completionHandler:(void (^)(NSError * _Nullable errorOrNil))completionHandler
{
    [self _cancelAllOperations];
    
    if(completionHandler)
    {
        completionHandler(nil);
    }
}

- (void)presentedItemDidChange
{
    [self _cancelAllOperations];
}

#pragma mak -Helper methods

- (void)_commonInitWithURL:(NSURL *)url
{
    _logger = os_log_create("com.fwkit.swatches", "color");
    
    _url = nil;
    
    if(url)
    {
        _url = [url copy];
    }
    
    _operationQueue = [NSOperationQueue new];
    _operationQueue.maxConcurrentOperationCount = 1;
    _operationQueue.qualityOfService = NSQualityOfServiceUtility;
    
    _fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
    
    [NSFileCoordinator addFilePresenter:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationMovedToBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationMovedToForeground:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)_cancelAllOperations
{
    if( _operationQueue )
    {
        [_operationQueue cancelAllOperations];
        [_operationQueue waitUntilAllOperationsAreFinished];
    }
}

@end
