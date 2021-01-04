//
//  PreviewColorTableViewCell.h
//  SwatchesReaderQuickLook
//
//  Created by Viktor Goltvyanytsya on 13.12.2019.
//  Copyright © 2019 FWKit. All rights reserved.
//








#import <UIKit/UIKit.h>
#import "SRBaseColor.h"


NS_ASSUME_NONNULL_BEGIN

@interface PreviewColorTableViewCell : UITableViewCell

- (void)setColor:(SRBaseColor *)color displayColorType:(BOOL)displayColorType;

@end

NS_ASSUME_NONNULL_END
