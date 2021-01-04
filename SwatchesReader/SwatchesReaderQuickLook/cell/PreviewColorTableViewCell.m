//
//  PreviewColorTableViewCell.m
//  SwatchesReaderQuickLook
//
//  Created by Viktor Goltvyanytsya on 13.12.2019.
//  Copyright © 2019 FWKit. All rights reserved.
//








#import "PreviewColorTableViewCell.h"

#define DISPLAY_H 160.f
#define PCOLOR_REMOVE_VIEW_SAFELY(__POINTER) { if( __POINTER && __POINTER.superview ){ [__POINTER removeFromSuperview]; } __POINTER = nil; }

#define COLOR_RAW_VALS_LABEL_NORMAL_Y 30.f
#define COLOR_RAW_VALS_LABEL_UP_Y 12.f

#define COLOR_TYPE_LABEL_NORMAL_Y 53.f
#define COLOR_TYPE_LABEL_UP_Y 50.f

#define LABEL_H 20.f

@interface PreviewColorTableViewCell ()
{
    UIView                          *_colorDisplay;
    UILabel                         *_titleLabel;
    UILabel                         *_colorTypeLabel;
    UILabel                         *_colorRawValuesLabel;
    
    BOOL                            _statusBarHidden;
}

@end

@implementation PreviewColorTableViewCell

- (void)dealloc
{
    PCOLOR_REMOVE_VIEW_SAFELY(_colorDisplay);
    PCOLOR_REMOVE_VIEW_SAFELY(_titleLabel);
    PCOLOR_REMOVE_VIEW_SAFELY(_colorTypeLabel);
    PCOLOR_REMOVE_VIEW_SAFELY(_colorRawValuesLabel);
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        
        CGFloat cw = self.contentView.frame.size.width;
        CGFloat ch = self.contentView.frame.size.height;
        CGFloat startDisplayX = cw-(DISPLAY_H-15.f);
        CGRect displayRect = CGRectMake(startDisplayX, 8.f, (cw-startDisplayX)-5.f, ch-16.f);
        _colorDisplay = [[UIView alloc] initWithFrame:displayRect];
        _colorDisplay.layer.borderWidth = 0.5f;
        _colorDisplay.layer.borderColor = [UIColor colorWithWhite:0.33 alpha:1.f].CGColor;
        _colorDisplay.layer.cornerRadius = 5.f;
        
        [self.contentView addSubview:_colorDisplay];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.f, 8.f, startDisplayX-4.f, LABEL_H)];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor labelColor]];
        [_titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
        [_titleLabel setText:@""];
        [self.contentView addSubview:_titleLabel];
        
        _colorRawValuesLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.f, COLOR_RAW_VALS_LABEL_NORMAL_Y, startDisplayX-4.f, LABEL_H)];
        [_colorRawValuesLabel setTextAlignment:NSTextAlignmentLeft];
        [_colorRawValuesLabel setBackgroundColor:[UIColor clearColor]];
        [_colorRawValuesLabel setTextColor:[UIColor labelColor]];
        [_colorRawValuesLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
        [_colorRawValuesLabel setText:@""];
        [self.contentView addSubview:_colorRawValuesLabel];
        
        _colorTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.f, COLOR_TYPE_LABEL_NORMAL_Y, startDisplayX-4.f, LABEL_H)];
        [_colorTypeLabel setTextAlignment:NSTextAlignmentLeft];
        [_colorTypeLabel setBackgroundColor:[UIColor clearColor]];
        [_colorTypeLabel setTextColor:[UIColor labelColor]];
        [_colorTypeLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
        [_colorTypeLabel setText:@""];
        [self.contentView addSubview:_colorTypeLabel];
        
        
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat cw = self.contentView.frame.size.width;
    CGFloat ch = self.contentView.frame.size.height;
    CGFloat startDisplayX = cw-(DISPLAY_H-15.f);
    CGRect displayRect = CGRectMake(startDisplayX, 8.f, (cw-startDisplayX)-5.f, ch-16.f);
    [_colorDisplay setFrame:displayRect];
    
    CGFloat indentX = 4.f;
    CGFloat labelW = startDisplayX-indentX;
    
    [_titleLabel setFrame:CGRectMake(indentX, _titleLabel.frame.origin.y, labelW, LABEL_H)];
    [_colorRawValuesLabel setFrame:CGRectMake(indentX, _colorRawValuesLabel.frame.origin.y, labelW, LABEL_H)];
    [_colorTypeLabel setFrame:CGRectMake(indentX, _colorTypeLabel.frame.origin.y, labelW, LABEL_H)];
    
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setColor:(SRBaseColor *)color displayColorType:(BOOL)displayColorType
{
    if(!color)
    {
        return;
    }
    
    NSString *nameStr = color.name;
    [_titleLabel setText:nameStr];
    if(!nameStr || nameStr.length==0)
    {
        [_titleLabel setHidden:YES];
        
        CGRect rctRaw = CGRectMake(_colorRawValuesLabel.frame.origin.x,
                                   COLOR_RAW_VALS_LABEL_UP_Y,
                                   _colorRawValuesLabel.frame.size.width,
                                   LABEL_H);
        
        [_colorRawValuesLabel setFrame:rctRaw];
        
        
        CGRect rctType = CGRectMake(_colorTypeLabel.frame.origin.x,
                                    COLOR_TYPE_LABEL_UP_Y,
                                    _colorTypeLabel.frame.size.width,
                                    LABEL_H);
        
        [_colorTypeLabel setFrame:rctType];
    }
    else
    {
        [_titleLabel setHidden:NO];
        
        CGRect rctRaw = CGRectMake(_colorRawValuesLabel.frame.origin.x,
                                   COLOR_RAW_VALS_LABEL_NORMAL_Y,
                                   _colorRawValuesLabel.frame.size.width,
                                   LABEL_H);
        
        [_colorRawValuesLabel setFrame:rctRaw];
        
        CGRect rctType = CGRectMake(_colorTypeLabel.frame.origin.x,
                                    COLOR_TYPE_LABEL_NORMAL_Y,
                                    _colorTypeLabel.frame.size.width,
                                    LABEL_H);
        
        [_colorTypeLabel setFrame:rctType];
    }
    
    NSString *rawVals = [NSString stringWithFormat:@"%@", color.rawValuesString];
    [_colorRawValuesLabel setText:rawVals];
    
    NSString *colorType = nil;
    if(displayColorType)
    {
        colorType = [NSString stringWithFormat:@"[ %@ ]", color.colorTypeString];
    }
    [_colorTypeLabel setText:colorType];
    
    [_colorDisplay setBackgroundColor:color.uiColor];
    
}

@end
