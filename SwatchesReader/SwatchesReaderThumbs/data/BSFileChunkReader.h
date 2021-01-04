//
//  BSFileChunkReader.h
//  SwatchesReaderThumbs
//
//  Created by Viktor Goltvyanytsya on 09.05.2020.
//  Copyright © 2020 FWKit. All rights reserved.
//








#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SRColorCollection.h"

@interface BSFileChunkReader : NSObject

- (id)initWithFileHandle:(NSFileHandle *)fileHandle;

- (NSString *)readLineFromFileHandle:(NSFileHandle *)fileHandle;
- (NSString *)readTrimmedLineFromFileHandle:(NSFileHandle *)fileHandle;

- (NSArray<UIColor *> *)readThumbnailOfGIMPPaletteFromFileHandle:(NSFileHandle *)fileHandle;
- (SRColorCollection *)readAsGIMPPaletteFromFileHandle:(NSFileHandle *)fileHandle;

#if NS_BLOCKS_AVAILABLE

- (void)enumerateLinesFromFileHandle:(NSFileHandle *)fileHandle
                          usingBlock:(void(^)(NSString *str, BOOL *finish))block;

- (void)enumerateTrimmedLinesFromFileHandle:(NSFileHandle *)fileHandle
                                 usingBlock:(void(^)(NSString *str, BOOL *finish))block;

#endif

@end


