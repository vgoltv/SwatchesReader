//
//  ThumbnailProvider.m
//  SwatchesReaderThumbs
//
//  Created by Viktor Goltvyanytsya on 30.12.2020.
//








#import "ThumbnailProvider.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "BSBaseThumbnailReader.h"
#import "BSGPLThumbnailReader.h"


@implementation ThumbnailProvider

- (void)provideThumbnailForFileRequest:(QLFileThumbnailRequest *)request completionHandler:(void (^)(QLThumbnailReply * _Nullable, NSError * _Nullable))handler {
    
    NSURL *fileURL = request.fileURL;
    
    if( !fileURL || !(fileURL.isFileURL || fileURL.isFileReferenceURL) )
    {
        return;
    }
    
    CGSize maximumSize = request.maximumSize;
    CGFloat scale = request.scale;
    
    CGSize contextSize = [self contextSizeForFile:fileURL maximumSize:maximumSize scale:scale];
    
    NSString *pathExt = fileURL.pathExtension.uppercaseString;
    
    Class readerClass = nil;
    if( [pathExt isEqualToString:@"GPL"] )
    {
        readerClass = [BSGPLThumbnailReader class];
    }
    
    handler([QLThumbnailReply replyWithContextSize:request.maximumSize currentContextDrawingBlock:^BOOL {
        
        dispatch_semaphore_t openingSemaphore = dispatch_semaphore_create(0);
        __block BOOL openingSuccess = NO;
        __block NSArray <UIColor *> *colorsArray = nil;
        
        BSBaseThumbnailReader *reader = [[readerClass alloc] initWithURL:fileURL];
        [reader readThumbnailColorsWithCompletionHandler:^(BOOL success, NSArray<UIColor *> *colors) {
            if(success && colors)
            {
                openingSuccess = YES;
                colorsArray = colors;
            }

            dispatch_semaphore_signal(openingSemaphore);
        }];
        
        dispatch_time_t timeUp = dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(8.f * NSEC_PER_SEC));
        dispatch_semaphore_wait(openingSemaphore, timeUp);
        
        if( openingSuccess && colorsArray )
        {
            NSUInteger total = colorsArray.count;
            CGContextRef contextRef = UIGraphicsGetCurrentContext();

            int w = contextSize.width / total;

            UIColor *bgColor = [UIColor colorWithWhite:0.3f alpha:1.f];
            CGContextSetFillColorWithColor(contextRef, bgColor.CGColor);
            CGContextFillRect(contextRef, (CGRect){CGPointZero, contextSize});
            
            int h = contextSize.height;
            
            for (int i = 0; i < total; i++)
            {
                UIColor *color = [colorsArray objectAtIndex:i];
                
                CGRect rectangle = CGRectMake(w*i, 0.0, w, h);
                
                CGContextSetFillColorWithColor(contextRef, color.CGColor);
                CGContextAddRect(contextRef, rectangle);
                CGContextDrawPath(contextRef, kCGPathFill);
            }
        }
        
        colorsArray = nil;
        
        dispatch_semaphore_t closingSemaphore = dispatch_semaphore_create(0);
        
        [reader stopReadingThumbnailWithCompletionHandler:^(BOOL success) {
            dispatch_semaphore_signal(closingSemaphore);
        }];
        dispatch_semaphore_wait(closingSemaphore, DISPATCH_TIME_FOREVER);
        
        reader = nil;
        
        // Return YES if the thumbnail was successfully drawn inside this block.
        return openingSuccess;
    }], nil);
    

}

#pragma mark -Helpers

- (CGSize)contextSizeForFile:(NSURL *)url maximumSize:(CGSize)maximumSize scale:(CGFloat)scale
{
    return maximumSize;
}

@end
