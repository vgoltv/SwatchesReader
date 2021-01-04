//
//  SRColorGroup.m
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 30.12.2020.
//








#import "SRColorGroup.h"

@import os.log;

#define BS_COLOR_DELETE_ARRAY_SAFELY(__POINTER) { if( __POINTER ){ [__POINTER removeAllObjects]; __POINTER = nil; } }

@interface SRColorGroup ()
{
    NSString                              *_name;
    NSMutableArray<SRBaseColor *>         *_colors;
    
    os_log_t                              _logger;
}

@end

@implementation SRColorGroup

- (void)dealloc
{
    _name = nil;
    BS_COLOR_DELETE_ARRAY_SAFELY(_colors);
    
    _logger = NULL;
}

- (id)init
{
    if(self = [super init])
    {
        _logger = os_log_create("com.fwkit.swatchesreader", "colors");
        _colors = [NSMutableArray array];
    }
    
    return self;
}

- (NSUInteger)count
{
    return _colors.count;
}

- (BOOL)setName:(NSString *)name
{
    if(!_name && !name)
    {
        return NO;
    }
    
    if(_name && name && [_name isEqualToString:name])
    {
        return NO;
    }
    
    _name = name?[NSString stringWithFormat:@"%@",name]:nil;
    return YES;
}

- (NSString *)name
{
    NSString *str = _name;
    if( !str )
    {
        str = @"";
    }
    
    return str;
}

- (BOOL)setColors:(NSArray <SRBaseColor *> *)array
{
    if(!array && _colors.count==0)
    {
        return NO;
    }
    
    if(array && array.count==0 && _colors.count==0)
    {
        return NO;
    }

    BS_COLOR_DELETE_ARRAY_SAFELY(_colors);
    
    if(array)
    {
        _colors = [array mutableCopy];
    }
    else
    {
        _colors = [NSMutableArray array];
    }
    
    return YES;
}

- (BOOL)addColor:(SRBaseColor *)color
{
    if(!color)
    {
        return NO;
    }
    
    [_colors addObject:color];
    return (_colors.lastObject==color);
}

- (nullable SRBaseColor *)colorAtIndex:(NSUInteger)indx
{
    SRBaseColor *color = nil;
    
    if (_colors && indx < [_colors count])
    {
        color = [_colors objectAtIndex:indx];
    }
    
    return color;
}

- (BOOL)replaceColor:(SRBaseColor *)color atIndex:(NSUInteger)index
{
    if(!_colors)
    {
        return NO;
    }
    
    if(!color || index>=_colors.count)
    {
        return NO;
    }
    
    [_colors replaceObjectAtIndex:index withObject:color];
    
    return YES;
}

- (BOOL)removeColorAt:(NSUInteger)index
{
    if(!_colors || index>=_colors.count)
    {
        return NO;
    }
    
    NSUInteger count = _colors.count;
    
    [_colors removeObjectAtIndex:index];
    
    return (count>_colors.count);
}

- (BOOL)removeLastColor
{
    if(!_colors || _colors.count==0)
    {
        return NO;
    }
    
    NSUInteger count = _colors.count;
    
    SRBaseColor *clr = [_colors lastObject];
    if(clr)
    {
        [_colors removeObject:clr];
    }
    
    return (count>_colors.count);
}

- (NSArray<UIColor *> *)uiColors
{
    NSUInteger total = _colors.count;
    NSMutableArray *arr = [NSMutableArray array];
    for (NSUInteger i = 0; i<total; i++)
    {
        SRBaseColor *color = [_colors objectAtIndex:i];
        [arr addObject:color.uiColor];
    }
    
    return arr;
}


@end
