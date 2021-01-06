//
//  SRBaseColor.m
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 30.12.2020.
//








#import "SRBaseColor.h"
@import os.log;


@interface SRBaseColor ()
{
    UIColor                     *_uiColor;
    NSString                    *_name;
    NSString                    *_rawValuesString;
    
    Float32                     _rawValues[4];
    NSUInteger                  _rawValuesCount;
    
    BSBaseColorMode             _colorMode;
    BSBaseColorType             _colorType;
    
    NSInteger                   _tag;
    
    os_log_t                    _logger;
}

@end

@implementation SRBaseColor

- (void)dealloc
{
    _uiColor = nil;
    _name = nil;
    _rawValuesString = nil;
    
    _logger = NULL;
}

- (id)init
{
    if(self = [super init])
    {
        _logger = os_log_create("com.fwkit.swatches", "colors");
        
        _tag = -1;
        
        _rawValues[0] = 0.f;
        _rawValues[1] = 0.f;
        _rawValues[2] = 0.f;
        _rawValues[3] = 0.f;

        _rawValuesCount = 1;
        
        _colorMode = [self colorModeByDeafult];
        _colorType = [self colorTypeByDeafult];
        
        _uiColor = [UIColor blackColor];
        _name = @"";
        _rawValuesString = nil;
    }
    
    return self;
}

- (BOOL)setRawValue0:(Float32)val0
           rawValue1:(Float32)val1
           rawValue2:(Float32)val2
           rawValue3:(Float32)val3
           colorMode:(BSBaseColorMode)colorMode
{
    if( ![self isColorModeSupported:colorMode] )
    {
        os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "ColorMode: %li is not supported", colorMode );
        return NO;
    }
    
    _rawValuesString = nil;
    
    _rawValues[0] = 0.f;
    _rawValues[1] = 0.f;
    _rawValues[2] = 0.f;
    _rawValues[3] = 0.f;
    
    if(colorMode == BSBaseColorModeRGB)
    {
        Float32 r = [self trim:val0 minValue:0.f maxValue:1.f];
        Float32 g = [self trim:val1 minValue:0.f maxValue:1.f];
        Float32 b = [self trim:val2 minValue:0.f maxValue:1.f];
        
        _rawValues[0] = r;
        _rawValues[1] = g;
        _rawValues[2] = b;
        
        _rawValuesCount = 3;
        
        _uiColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        
        _colorMode = colorMode;
    }
    else
    {
        os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "ColorMode: %li can not be processed", colorMode );
        return NO;
    }
    
    
    return YES;
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex
{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

- (void)setColorType:(BSBaseColorType)colorType
{
    if( ![self isColorTypeSupported:colorType] )
    {
        os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "ColorType: %li can not be processed", colorType );
        colorType = [self _supportedColorType:colorType];
    }
    
    _colorType = colorType;
}

- (BSBaseColorType)colorType
{
    return _colorType;
}

- (BSBaseColorType)colorTypeByDeafult
{
    return BSBaseColorTypeGlobal;
}

- (NSString *)colorTypeString
{
    NSString *str = @"Undefined";
    
    if(_colorType == BSBaseColorTypeGlobal)
    {
        str = @"Global";
    }
    
    return str;
}


- (NSString *)colorModeString
{
    NSString *str = @"Undefined";
    
    if(_colorMode == BSBaseColorModeRGB)
    {
        str = @"RGB";
    }
    
    return str;
}

- (BSBaseColorMode)colorModeByDeafult
{
    return BSBaseColorModeRGB;
}

- (BOOL)isColorModeSupported:(BSBaseColorMode)colorMode
{
    return YES;
}

- (BOOL)isColorTypeSupported:(BSBaseColorType)colorType
{
    return YES;
}

- (NSInteger)tag
{
    return _tag;
}

- (void)setTag:(NSInteger)tag
{
    _tag = tag;
}

- (UIColor *)uiColor
{
    return _uiColor;
}

- (void)setUIColor:(UIColor *)uicolor colorMode:(BSBaseColorMode)colorMode
{
    if( ![self isColorModeSupported:colorMode] )
    {
        os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "ColorMode: %li is not supported", colorMode );
        colorMode = [self _supportedColorMode:colorMode];
    }
    
    [self _setUIColor:uicolor colorMode:colorMode];
}

- (void)setName:(NSString *)name
{
    _name = name?[NSString stringWithFormat:@"%@",name]:nil;
}

- (NSString *)name
{
    return _name;
}

- (BSBaseColorMode)colorMode
{
    return _colorMode;
}

- (Float32)getRawValueAt:(NSUInteger)position
{
    position = MIN(position,4);
    return _rawValues[position];
}

- (NSUInteger)rawValuesCount
{
    return _rawValuesCount;
}

- (NSString *)rawValuesString
{
    if( _rawValuesString )
    {
        return _rawValuesString;
    }
    
    NSString *str = @"";
    if(_colorMode == BSBaseColorModeRGB)
    {
        CGFloat r = _rawValues[0]*100.f;
        CGFloat g = _rawValues[1]*100.f;
        CGFloat b = _rawValues[2]*100.f;
        str = [NSString stringWithFormat:@"R:%.0f  G:%.0f  B:%.0f", r, g, b];
    }
    else
    {
        CGFloat v0 = _rawValues[0];
        CGFloat v1 = _rawValues[1];
        CGFloat v2 = _rawValues[2];
        CGFloat v3 = _rawValues[3];
        str = [NSString stringWithFormat:@"0:%.2f  1:%.2f  2:%.2f  3:%.2f", v0, v1, v2, v3 ];
    }
    
    _rawValuesString = str;
    
    return str;
}

- (Float32)trim:(Float32)val minValue:(Float32)minValue maxValue:(Float32)maxValue
{
    if(minValue>maxValue)
    {
        Float32 tmp = minValue;
        minValue = maxValue;
        maxValue = tmp;
    }
    
    if(val<minValue)
    {
        return minValue;
    }
    else if(val>maxValue)
    {
        return maxValue;
    }
    
    return val;
}

- (void)_setUIColor:(UIColor *)uicolor colorMode:(BSBaseColorMode)colorMode
{
    _rawValues[0] = 0.f;
    _rawValues[1] = 0.f;
    _rawValues[2] = 0.f;
    _rawValues[3] = 0.f;
    
    _rawValuesString = nil;
    
    if(!uicolor)
    {
        uicolor = [UIColor blackColor];
    }
    
    CIColor *ciColor = [CIColor colorWithCGColor:uicolor.CGColor];
    
    colorMode = [self _supportedColorMode:colorMode];
    
    if(colorMode == BSBaseColorModeRGB)
    {
        _rawValues[0] = ciColor.red;
        _rawValues[1] = ciColor.green;
        _rawValues[2] = ciColor.blue;
        
        _colorMode = colorMode;
        _rawValuesCount = 3;
        
        _uiColor = [UIColor colorWithRed:ciColor.red green:ciColor.green blue:ciColor.blue alpha:1.f];
    }
    else
    {
        os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "ColorMode: %li is not supported", colorMode );
    }
}

- (BSBaseColorMode)_supportedColorMode:(BSBaseColorMode)colorMode
{
    if( ![self isColorModeSupported:colorMode] )
    {
        return [self colorModeByDeafult];
    }
    
    return colorMode;
}

- (BSBaseColorType)_supportedColorType:(BSBaseColorType)colorType
{
    if( ![self isColorTypeSupported:colorType] )
    {
        return [self colorTypeByDeafult];
    }
    
    return colorType;
}


@end
