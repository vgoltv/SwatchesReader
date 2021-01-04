//
//  BSColorCollectionFileHandler.h
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 19.12.2019.
//  Copyright © 2019 FWKit. All rights reserved.
//









#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SRColorCollection.h"




@interface SRColorCollectionFileHandler : NSObject

NS_ASSUME_NONNULL_BEGIN

- (id)initWithURL:(NSURL *)url;

- (void)readColorCollectionWithCompletionHandler:(void (^)(BOOL success, NSURL *url, SRColorCollection *collection))handler;

- (void)stopWithCompletionHandler:(void (^)(BOOL success))handler;

- (void)close;

NS_ASSUME_NONNULL_END

@end

