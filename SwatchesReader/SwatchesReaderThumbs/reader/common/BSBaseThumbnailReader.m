//
//  BSBaseThumbnailReader.m
//  SwatchesReaderThumbs
//
//  Created by Viktor Goltvyanytsya on 19.12.2019.
//  Copyright © 2019 FWKit. All rights reserved.
//








#import "BSBaseThumbnailReader.h"

#define BS_COLOR_REMOVE_NSBLOCKQUEUE_SAFELY(__POINTER) { if( __POINTER ){ [__POINTER cancelAllOperations]; [__POINTER waitUntilAllOperationsAreFinished]; } __POINTER = nil; }

@interface BSBaseThumbnailReader()<NSFilePresenter>
{
    
    NSOperationQueue            *_presentedItemOperationQueue;
    
    NSFileCoordinator           *_fileCoordinator;
    
    NSURL                       *_url;
}

@end

@implementation BSBaseThumbnailReader

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
    [self _cancelAllOperations];
    
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

- (void)readThumbnailColorsWithCompletionHandler:(void (^)(BOOL success, NSArray<UIColor *> *colors))handler
{
    NSBlockOperation *loadingOperation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakLoadingOperation = loadingOperation;
    __weak typeof(self) weakSelf = self;
    [loadingOperation addExecutionBlock:^{
        
        if ( !weakLoadingOperation.isCancelled && weakSelf )
        {
            
        }
        
        if(handler)
        {
            handler(NO, nil);
        }
        
        
    }];
    
    [_operationQueue addOperation:loadingOperation];
}

- (void)stopReadingThumbnailWithCompletionHandler:(void (^)(BOOL success))handler
{
    [self _cancelAllOperations];
    
    if(_presentedItemOperationQueue)
    {
        [_presentedItemOperationQueue cancelAllOperations];

        [_presentedItemOperationQueue waitUntilAllOperationsAreFinished];
    }
    
    if(_fileCoordinator)
    {
        [_fileCoordinator cancel];
    }
    
    if(handler)
    {
        handler(YES);
    }
}

#pragma mark -NSNotificationCenter observers

-(void)applicationMovedToForeground:(NSNotification *)notification
{
    [self _cancelAllOperations];
    
    [NSFileCoordinator addFilePresenter:self];
}

- (void)applicationMovedToBackground:(NSNotification *)notification
{
    [self _cancelAllOperations];
    
    [NSFileCoordinator removeFilePresenter:self];
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
    _url = nil;
    
    if(url)
    {
        _url = [url copy];
    }
    
    _operationQueue = [NSOperationQueue new];
    _operationQueue.maxConcurrentOperationCount = 2;
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
