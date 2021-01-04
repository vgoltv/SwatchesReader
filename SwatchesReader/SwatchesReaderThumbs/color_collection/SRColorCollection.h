//
//  SRColorCollection.h
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 30.12.2020.
//









#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SRColorGroup.h"





@interface SRColorCollection : NSObject

- (id)initWithMajVersion:(NSUInteger)majVersion
              minVersion:(NSUInteger)minVersion
                  groups:(NSArray<SRColorGroup *> *)groups
                  colors:(NSArray<SRBaseColor *> *)colors;

- (NSArray<SRColorGroup *> *)groups;
- (void)setGroups:(NSArray<SRColorGroup *> *)groups;

- (NSArray<SRBaseColor *> *)colors;
- (NSUInteger)colorsCount;

- (SRColorGroup *)ungroupedColors;

@end


