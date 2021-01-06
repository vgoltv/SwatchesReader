//
//  BSFileChunkReader.m
//  SwatchesReaderThumbs
//
//  Created by Viktor Goltvyanytsya on 09.05.2020.
//  Copyright © 2020 FWKit. All rights reserved.
//








#import "BSFileChunkReader.h"
#import "NSData+SwatchesExt.h"
@import os.log;

#define BS_COLOR_DELETE_ARRAY_SAFELY(__POINTER) { if( __POINTER ){ [__POINTER removeAllObjects]; __POINTER = nil; } }

@interface BSFileChunkReader()
{
    NSString                *_filePath;

    unsigned long long      _currentOffset;
    unsigned long long      _totalFileLength;

    NSString                *_lineDelimiter;
    NSUInteger              _chunkSize;
    
    NSCharacterSet          *_unsafeCharacterSet;
    
    NSPredicate             *_pred;
    
    os_log_t                _logger;
}

@end


@implementation BSFileChunkReader

- (void)dealloc
{
    _unsafeCharacterSet = nil;
    
    _pred = nil;
    
    _filePath = nil;
    _lineDelimiter = nil;
    
    _currentOffset = 0ULL;
    
    _logger = NULL;
}

- (id)initWithFileHandle:(NSFileHandle *)fileHandle
{
    if (self = [super init])
    {
        if ( !fileHandle )
        {
            return nil;
        }
        
        _logger = os_log_create("com.fwkit.swatches", "thumbs");

        _lineDelimiter = @"\n";
        _currentOffset = 0ULL; // constant - 0 unsigned long long
        _chunkSize = 128;
        
        _pred = [NSPredicate predicateWithFormat:@"length > 0"];
        
        NSMutableCharacterSet *unsafeCharacterSet = [NSMutableCharacterSet illegalCharacterSet];
        [unsafeCharacterSet formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
        [unsafeCharacterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [unsafeCharacterSet formUnionWithCharacterSet:[NSCharacterSet nonBaseCharacterSet]];
        
        _unsafeCharacterSet = [unsafeCharacterSet copy];
        
        unsafeCharacterSet = nil;
        
        [fileHandle seekToEndOfFile];
        _totalFileLength = [fileHandle offsetInFile];
    }
    
    return self;
}

+ (NSString *)extractNumberFromText:(NSString *)text
{
  NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
  return [[text componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""];
}

- (NSString *)readLineFromFileHandle:(NSFileHandle *)fileHandle
{
    if ( !fileHandle || _currentOffset >= _totalFileLength)
    {
        return nil;
    }

    @autoreleasepool
    {
        NSData *newLineData = [_lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
        
        [fileHandle seekToFileOffset:_currentOffset];
        unsigned long long originalOffset = _currentOffset;
        
        NSMutableData *currentData = [[NSMutableData alloc] init];
        NSData *currentLine = [[NSData alloc] init];
        
        BOOL shouldReadMore = YES;

        while (shouldReadMore)
        {
            if (_currentOffset >= _totalFileLength)
            {
                break;
            }

            NSData *chunk = [fileHandle readDataOfLength:_chunkSize];
            [currentData appendData:chunk];

            NSRange newLineRange = [currentData rangeOfData:newLineData];

            if (newLineRange.location != NSNotFound)
            {
                _currentOffset = originalOffset + newLineRange.location + newLineData.length;
                currentLine = [currentData subdataWithRange:NSMakeRange(0, newLineRange.location)];

                shouldReadMore = NO;
            }
            else
            {
                _currentOffset += [chunk length];
            }
        }

        if (currentLine.length == 0 && currentData.length > 0)
        {
            currentLine = currentData;
        }

        return [[NSString alloc] initWithData:currentLine encoding:NSUTF8StringEncoding];
    }
}

- (NSString *)readTrimmedLineFromFileHandle:(NSFileHandle *)fileHandle
{
    NSString *result = nil;
    NSString *str = [self readLineFromFileHandle:fileHandle];
    if( str )
    {
        result = [str stringByTrimmingCharactersInSet:_unsafeCharacterSet];
    }
    
    return result;
}

- (NSArray<UIColor *> *)readThumbnailOfGIMPPaletteFromFileHandle:(NSFileHandle *)fileHandle
{
    NSMutableArray<UIColor *> *colors = nil;
    
    NSString *line = nil;
    NSString *paletteName = nil;
    BOOL isHeaderFound = NO;
    
    BOOL isChannelsFieldFound = NO;
    BOOL isRGBA = NO;
    
    BOOL isColumnsFieldFound = NO;
    BOOL stop = NO;
    
    NSUInteger foundColors = 0;
    NSUInteger totalLines = 0;
    
    while ( stop == NO && (line = [self readTrimmedLineFromFileHandle:fileHandle]) )
    {
        totalLines = totalLines+1;
        if( totalLines > 1000 )
        {
            os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "Too big file to extract thumbnail" );
            stop = YES;
            break;
        }
        
        if(line && line.length>0 && ![[line substringToIndex:1] isEqualToString:@"#"] )
        {
            if(!isHeaderFound && ![line isEqualToString:@"GIMP Palette"] )
            {
                stop = YES;
                break;
            }
            else if( !isHeaderFound )
            {
                isHeaderFound = YES;
                continue;
            }
            
            if( foundColors==0 && !paletteName && [[line substringToIndex:5] isEqualToString:@"Name:"] )
            {
                paletteName = @"";
                continue;
            }
            
            if( foundColors==0 && !isColumnsFieldFound && [[line substringToIndex:8] isEqualToString:@"Columns:"] )
            {
                isColumnsFieldFound = YES;
                continue;
            }
            
            if( foundColors==0 && !isChannelsFieldFound && [[line substringToIndex:9] isEqualToString:@"Channels:"] )
            {
                isChannelsFieldFound = YES;
                NSString *channelsStr = [[line substringFromIndex:9] stringByTrimmingCharactersInSet:_unsafeCharacterSet];
                isRGBA = [channelsStr isEqualToString:@"RGBA"];
                if(!isRGBA)
                {
                    os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "Unsupported color space" );
                    stop = YES;
                    break;
                }
                continue;
            }
            
            NSArray <NSString *>*componentsArr = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if( !componentsArr )
            {
                os_log_with_type(_logger, OS_LOG_TYPE_DEBUG, "Not a color, skipped" );
                continue;
            }

            componentsArr = [componentsArr filteredArrayUsingPredicate:_pred];
            
            if( componentsArr.count < 3 )
            {
                os_log_with_type(_logger, OS_LOG_TYPE_DEBUG, "Not a color, skipped" );
                continue;
            }
            
            NSInteger r = [[componentsArr objectAtIndex:0] integerValue];
            if( r<0 || r>255)
            {
                os_log_with_type(_logger, OS_LOG_TYPE_DEBUG, "Value of the red component %li is wrong, color skipped", (long)r );
                continue;
            }
            
            NSInteger g = [[componentsArr objectAtIndex:1] integerValue];
            if( g<0 || g>255)
            {
                os_log_with_type(_logger, OS_LOG_TYPE_DEBUG, "Value of the green component %li is wrong, color skipped", (long)g );
                continue;
            }
            
            NSInteger b = [[componentsArr objectAtIndex:2] integerValue];
            if( b<0 || b>255)
            {
                os_log_with_type(_logger, OS_LOG_TYPE_DEBUG, "Value of the blue component %li is wrong, color skipped", (long)b );
                continue;
            }
            
            UIColor *color = [UIColor colorWithRed:(r*1.f)/255.f
                                             green:(g*1.f)/255.f
                                              blue:(b*1.f)/255.f
                                             alpha:1.f];
            
            if( !color )
            {
                os_log_with_type(_logger, OS_LOG_TYPE_DEBUG, "Not a color, skipped" );
                continue;
            }
            
            foundColors = foundColors + 1;
            
            if(!colors)
            {
                colors = [NSMutableArray array];
            }
            
            [colors addObject:color];
            
            if( colors.count >= 5 )
            {
                stop = YES;
                break;
            }
            
        }
    }
    
    NSArray<UIColor *> *result = colors?[colors copy]:nil;
    BS_COLOR_DELETE_ARRAY_SAFELY(colors);
    
    return result;
}

- (SRColorCollection *)readAsGIMPPaletteFromFileHandle:(NSFileHandle *)fileHandle
{
    SRColorCollection *collection = nil;
    NSString *line = nil;
    NSString *paletteName = nil;
    BOOL isHeaderFound = NO;
    
    BOOL isChannelsFieldFound = NO;
    BOOL isRGBA = NO;
    
    BOOL isColumnsFieldFound = NO;
    BOOL stop = NO;
    
    NSUInteger foundColors = 0;
    
    NSMutableArray <SRBaseColor *> *swatchesArr = nil;
    
    while ( stop == NO && (line = [self readTrimmedLineFromFileHandle:fileHandle]) )
    {
        if(line && line.length>0 && ![[line substringToIndex:1] isEqualToString:@"#"] )
        {
            if(!isHeaderFound && ![line isEqualToString:@"GIMP Palette"] )
            {
                stop = YES;
                break;
            }
            else if( !isHeaderFound )
            {
                isHeaderFound = YES;
                continue;
            }
            
            if( foundColors==0 && !paletteName && [[line substringToIndex:5] isEqualToString:@"Name:"] )
            {
                paletteName = [[line substringFromIndex:5] stringByTrimmingCharactersInSet:_unsafeCharacterSet];
                continue;
            }
            
            if( foundColors==0 && !isColumnsFieldFound && [[line substringToIndex:8] isEqualToString:@"Columns:"] )
            {
                isColumnsFieldFound = YES;
                continue;
            }
            
            if( foundColors==0 && !isChannelsFieldFound && [[line substringToIndex:9] isEqualToString:@"Channels:"] )
            {
                isChannelsFieldFound = YES;
                NSString *channelsStr = [[line substringFromIndex:9] stringByTrimmingCharactersInSet:_unsafeCharacterSet];
                isRGBA = [channelsStr isEqualToString:@"RGBA"];
                if(!isRGBA)
                {
                    os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "Unsupported color space" );
                    stop = YES;
                    break;
                }
                continue;
            }
            
            NSArray <NSString *>*componentsArr = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if( !componentsArr )
            {
                os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "Not a color, skipped" );
                continue;
            }

            componentsArr = [componentsArr filteredArrayUsingPredicate:_pred];
            
            if( componentsArr.count < 3 )
            {
                os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "Not a color, skipped" );
                continue;
            }
            
            NSInteger r = [[componentsArr objectAtIndex:0] integerValue];
            if( r<0 || r>255)
            {
                os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "Value of the red component %li is wrong, color skipped", (long)r );
                continue;
            }
            
            NSInteger g = [[componentsArr objectAtIndex:1] integerValue];
            if( g<0 || g>255)
            {
                os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "Value of the green component %li is wrong, color skipped", (long)g );
                continue;
            }
            
            NSInteger b = [[componentsArr objectAtIndex:2] integerValue];
            if( b<0 || b>255)
            {
                os_log_with_type(_logger, OS_LOG_TYPE_ERROR, "Value of the blue component %li is wrong, color skipped", (long)b );
                continue;
            }
            
            SRBaseColor *swatch = [[SRBaseColor alloc] init];
            
            [swatch setRawValue0:(r*1.f)/255.f
                       rawValue1:(g*1.f)/255.f
                       rawValue2:(b*1.f)/255.f
                       rawValue3:0.f
                       colorMode:BSBaseColorModeRGB];
            
            NSUInteger totalComponents = componentsArr.count;
            NSUInteger startIndex = isRGBA?4:3;
            NSString *swatchName = nil;
            for(NSUInteger i=0; i<totalComponents; i++)
            {
                if(i>=startIndex)
                {
                    NSString *str = [componentsArr objectAtIndex:i];
                    if(!swatchName)
                    {
                        swatchName = @"";
                    }
                    swatchName = [NSString stringWithFormat:@"%@ %@",swatchName, str];
                }
            }
            
            [swatch setName:swatchName];
            foundColors = foundColors + 1;
            
            if(!swatchesArr)
            {
                swatchesArr = [NSMutableArray array];
            }
            
            [swatchesArr addObject:swatch];
            
        }
    }
    
    if( swatchesArr && swatchesArr.count>0 )
    {
        if(paletteName)
        {
            SRColorGroup *swatchesGroup = [[SRColorGroup alloc] init];
            [swatchesGroup setName:paletteName];
            [swatchesGroup setColors:swatchesArr];
            collection = [[SRColorCollection alloc] initWithMajVersion:1
                                                               minVersion:0
                                                                   groups:@[swatchesGroup]
                                                                   colors:nil];
        }
        else
        {
            collection = [[SRColorCollection alloc] initWithMajVersion:1
                                                               minVersion:0
                                                                   groups:nil
                                                                   colors:swatchesArr];
        }
    }
    
    return collection;
}


#if NS_BLOCKS_AVAILABLE

- (void)enumerateLinesFromFileHandle:(NSFileHandle *)fileHandle usingBlock:(void(^)(NSString *str, BOOL *finish))block
{
    NSString *line = nil;
    BOOL stop = NO;
    while (stop == NO && (line = [self readLineFromFileHandle:fileHandle]))
    {
        block(line, &stop);
    }
}

- (void)enumerateTrimmedLinesFromFileHandle:(NSFileHandle *)fileHandle usingBlock:(void(^)(NSString *str, BOOL *finish))block
{
    NSString *line = nil;
    BOOL stop = NO;
    while (stop == NO && (line = [self readTrimmedLineFromFileHandle:fileHandle]))
    {
        block(line, &stop);
    }
}

#endif

#pragma mark -Private methods





@end
