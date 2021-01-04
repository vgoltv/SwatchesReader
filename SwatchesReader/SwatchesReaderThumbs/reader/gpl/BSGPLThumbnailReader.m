//
//  BSGPLThumbnailReader.m
//  SwatchesReaderThumbs
//
//  Created by Viktor Goltvyanytsya on 19.12.2019.
//  Copyright © 2019 FWKit. All rights reserved.
//








#import "BSGPLThumbnailReader.h"
#import "BSFileChunkReader.h"
@import os.log;


@interface BSGPLThumbnailReader()


@end

@implementation BSGPLThumbnailReader

- (void)readThumbnailColorsWithCompletionHandler:(void (^)(BOOL success, NSArray<UIColor *> *colors))handler
{
    NSBlockOperation *loadingOperation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakLoadingOperation = loadingOperation;
    __weak typeof(self) weakSelf = self;
    [loadingOperation addExecutionBlock:^{
        
        if ( !weakLoadingOperation.isCancelled && weakSelf )
        {
            __strong typeof(self) strongSelf = weakSelf;
            
            NSURL *url = strongSelf.presentedItemURL;
            
            os_log_t logger = os_log_create("com.fwkit.swatchesreader", "thumbs");
            
            if(!url || url.path.length==0)
            {
                os_log_with_type(logger, OS_LOG_TYPE_ERROR, "Not a GPL file (invalid url)" );
            }
            else
            {
                NSError *coordinatorError;
                [[strongSelf fileCoordinator] coordinateReadingItemAtURL:url
                                                                 options:NSFileCoordinatorReadingWithoutChanges | NSFileCoordinatorReadingResolvesSymbolicLink
                                                                   error:&coordinatorError
                                                              byAccessor:^(NSURL *newURL) {
                    if(coordinatorError)
                    {
                        os_log_with_type(logger, OS_LOG_TYPE_ERROR, "File coordinator error: %@", coordinatorError );
                        
                        if(handler)
                        {
                            handler(NO, nil);
                        }
                    }
                    else
                    {
                        BOOL securityScoped = [newURL startAccessingSecurityScopedResource];
                        
                        NSError *error = nil;
                        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:newURL error:&error];
                        if( error )
                        {
                            os_log_with_type(logger, OS_LOG_TYPE_ERROR, "%@", error.localizedDescription );
                            
                            if(handler)
                            {
                                handler(NO, nil);
                            }
                            
                            BS_CLOSE_FILE_HANDLER(fileHandle, newURL, securityScoped);
                            
                            return;
                        }
                        
                        BSFileChunkReader *chunkReader = [[BSFileChunkReader alloc] initWithFileHandle:fileHandle];
                        if( !chunkReader )
                        {
                            os_log_with_type(logger, OS_LOG_TYPE_ERROR, "File %@ is not readable", newURL.path );
                            
                            if(handler)
                            {
                                handler(NO, nil);
                            }
                            
                            BS_CLOSE_FILE_HANDLER(fileHandle, newURL, securityScoped);
                        }
                        
                        NSArray<UIColor *> *colors = [chunkReader readThumbnailOfGIMPPaletteFromFileHandle:fileHandle];
                        if(!colors)
                        {
                            colors = @[];
                        }
                        
                        if(handler)
                        {
                            handler( YES, colors);
                        }
                        
                        BS_CLOSE_FILE_HANDLER(fileHandle, newURL, securityScoped);
                    }
                    
                }];
            }
        }
        
        if(handler)
        {
            handler(NO, nil);
        }
        
        
  
    }];
    
    [_operationQueue addOperation:loadingOperation];
}



#pragma mak -Helper methods



@end
