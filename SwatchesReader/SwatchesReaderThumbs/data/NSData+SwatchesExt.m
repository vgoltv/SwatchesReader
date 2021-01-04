//
//  NSData+SwatchesExt.m
//  SwatchesReaderThumbs
//
//  Created by Viktor Goltvyanytsya on 09.05.2020.
//  Copyright © 2020 FWKit. All rights reserved.
//






#import "NSData+SwatchesExt.h"

@implementation NSData (SwatchesExt)



- (NSRange)rangeOfData:(NSData *)dataToFind
{
    const void *bytes = [self bytes];
    NSUInteger length = [self length];

    const void * searchBytes = [dataToFind bytes];
    NSUInteger searchLength = [dataToFind length];
    NSUInteger searchIndex = 0;

    NSRange foundRange = {NSNotFound, searchLength};
    
    for (NSUInteger index = 0; index < length; index++)
    {
        if (((char *)bytes)[index] == ((char *)searchBytes)[searchIndex])
        {
            //the current character matches
            if (foundRange.location == NSNotFound)
            {
                foundRange.location = index;
            }
            
            searchIndex++;
            
            if (searchIndex >= searchLength)
            {
                return foundRange;
            }
        }
        else
        {
            searchIndex = 0;
            foundRange.location = NSNotFound;
        }
    }

    if (foundRange.location != NSNotFound &&
        length < (foundRange.location + foundRange.length) )
    {
        // if the dataToFind is partially found at the end of [self bytes],
        // then the loop above would end, and indicate the dataToFind is found
        // when it only partially was.
        foundRange.location = NSNotFound;
    }

    return foundRange;
}


@end
