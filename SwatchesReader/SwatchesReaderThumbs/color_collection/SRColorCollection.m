//
//  SRColorCollection.m
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 30.12.2020.
//








#import "SRColorCollection.h"
@import os.log;

#define BS_COLOR_DELETE_ARRAY_SAFELY(__POINTER) { if( __POINTER ){ [__POINTER removeAllObjects]; __POINTER = nil; } }

@interface SRColorCollection ()
{
    NSUInteger                              _majorVersion;
    NSUInteger                              _minorVersion;
    NSMutableArray<SRColorGroup *>          *_groups;
    NSMutableArray<SRBaseColor *>            *_colors;
    
    os_log_t                                _logger;
}

@end

@implementation SRColorCollection

- (void)dealloc
{
    BS_COLOR_DELETE_ARRAY_SAFELY(_groups);
    BS_COLOR_DELETE_ARRAY_SAFELY(_colors);
    
    _logger = NULL;
}

- (id)init
{
    if(self = [super init])
    {
        _logger = os_log_create("com.fwkit.swatchesreader", "colors");
        
        _majorVersion = 0;
        _minorVersion = 0;
    }
    
    return self;
}

- (id)initWithMajVersion:(NSUInteger)majVersion
              minVersion:(NSUInteger)minVersion
                  groups:(NSArray<SRColorGroup *> *)groups
                  colors:(NSArray<SRBaseColor *> *)colors
{
    if(self = [super init])
    {
        _logger = os_log_create("com.fwkit.swatchesreader", "colors");
        
        _majorVersion = majVersion;
        _minorVersion = minVersion;
        
        if(groups)
        {
            _groups = [groups mutableCopy];
        }
        
        if(colors)
        {
            _colors = [colors mutableCopy];
        }
    }
    
    return self;
}

- (NSArray<SRColorGroup *> *)groups
{
    return _groups;
}

- (void)setGroups:(NSArray<SRColorGroup *> *)groups
{
    if(!groups)
    {
        BS_COLOR_DELETE_ARRAY_SAFELY(_groups);
        return;
    }
    
    _groups = [groups mutableCopy];
}

- (NSArray<SRBaseColor *> *)colors
{
    return _colors;
}

- (NSUInteger)colorsCount
{
    if(!_colors)
    {
        return 0;
    }
    
    return _colors.count;
}

- (SRColorGroup *)ungroupedColors
{
    SRColorGroup *group = nil;
    if(_colors)
    {
        NSUInteger total = _colors.count;
        if(total>0)
        {
            group = [[SRColorGroup alloc] init];
            for (int i = 0; i < total; i++)
            {
                SRBaseColor *color = [_colors objectAtIndex:i];
                [group addColor:color];
            }
        }
    }
    
    return group;
}

@end
