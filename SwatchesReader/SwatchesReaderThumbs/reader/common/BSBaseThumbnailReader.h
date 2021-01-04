//
//  BSBaseThumbnailReader.h
//  SwatchesReaderThumbs
//
//  Created by Viktor Goltvyanytsya on 19.12.2019.
//  Copyright © 2019 FWKit. All rights reserved.
//









#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define BS_CLOSE_FILE_HANDLER(__FILE_HANDLE, __URL, __SCOPED) {if( __FILE_HANDLE ){ [__FILE_HANDLE closeFile];} __FILE_HANDLE = nil; if(__URL && __SCOPED){[__URL stopAccessingSecurityScopedResource];}}




NS_ASSUME_NONNULL_BEGIN

@interface BSBaseThumbnailReader : NSObject
{
    NSOperationQueue            *_operationQueue;
}

- (id)initWithURL:(NSURL *)url;

- (void)readThumbnailColorsWithCompletionHandler:(void (^)(BOOL success, NSArray<UIColor *> *colors))handler;

- (void)stopReadingThumbnailWithCompletionHandler:(void (^)(BOOL success))handler;

- (void)close;

- (NSFileCoordinator *)fileCoordinator;
- (NSURL *)presentedItemURL;

@end

NS_ASSUME_NONNULL_END
