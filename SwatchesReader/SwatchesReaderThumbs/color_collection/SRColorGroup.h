//
//  SRColorGroup.h
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 30.12.2020.
//









#import <Foundation/Foundation.h>
#import "SRBaseColor.h"


@interface SRColorGroup : NSObject

- (NSUInteger)count;

- (BOOL)setName:(NSString *_Nullable)name;
- (NSString *_Nonnull)name;

- (BOOL)setColors:(NSArray <SRBaseColor *> *_Nullable)array;
- (BOOL)addColor:(SRBaseColor *_Nullable)color;

- (nullable SRBaseColor *)colorAtIndex:(NSUInteger)indx;
- (BOOL)replaceColor:(SRBaseColor *_Nullable)color atIndex:(NSUInteger)index;
- (BOOL)removeColorAt:(NSUInteger)index;
- (BOOL)removeLastColor;

- (NSArray<UIColor *> *_Nonnull)uiColors;


@end


