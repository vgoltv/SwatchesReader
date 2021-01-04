//
//  SRBaseColor.h
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 30.12.2020.
//








#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BSBaseColorMode)
{
    BSBaseColorModeUndefined = -1,
    BSBaseColorModeRGB,
    BSBaseColorModeCount
};

typedef NS_ENUM(NSInteger, BSBaseColorType)
{
    BSBaseColorTypeUndefined = -1,
    BSBaseColorTypeGlobal,
    BSBaseColorTypeCounter
};


@interface SRBaseColor : NSObject


- (BSBaseColorType)colorTypeByDeafult;
- (BSBaseColorMode)colorModeByDeafult;
- (BOOL)isColorModeSupported:(BSBaseColorMode)colorMode;
- (BOOL)isColorTypeSupported:(BSBaseColorType)colorType;

- (NSInteger)tag;
- (void)setTag:(NSInteger)tag;

- (BOOL)setRawValue0:(Float32)val0
           rawValue1:(Float32)val1
           rawValue2:(Float32)val2
           rawValue3:(Float32)val3
           colorMode:(BSBaseColorMode)colorMode;

- (void)setName:(NSString *)name;
- (NSString *)name;

- (void)setColorType:(BSBaseColorType)colorType;
- (BSBaseColorType)colorType;

- (NSString *)colorTypeString;

- (BSBaseColorMode)colorMode;
- (NSString *)colorModeString;

- (void)setUIColor:(UIColor *)uicolor colorMode:(BSBaseColorMode)colorMode;
- (UIColor *)uiColor;


- (Float32)getRawValueAt:(NSUInteger)position;
- (NSUInteger)rawValuesCount;
- (NSString *)rawValuesString;

- (Float32)trim:(Float32)val minValue:(Float32)minValue maxValue:(Float32)maxValue;;

@end


