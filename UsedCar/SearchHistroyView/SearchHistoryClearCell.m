//
//  SearchHistoryClearCell.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-11.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "SearchHistoryClearCell.h"

@implementation SearchHistoryClearCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.width = self.contentView.width = cellWidth;
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = self.bounds;
        frame.size.height = 50;
        [clearButton setFrame:frame];
        [clearButton setBackgroundColor:[UIColor clearColor]];
        [clearButton setUserInteractionEnabled:NO];
        [clearButton setImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
        [clearButton setAdjustsImageWhenHighlighted:NO];
        [clearButton setTitleColor:kColorBlue forState:UIControlStateNormal];
        [clearButton.titleLabel setFont:kFontLarge];
        [clearButton setTitle:@"清除搜索历史" forState:UIControlStateNormal];
        [clearButton setImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
        [clearButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
        [clearButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 6)];
        
        [self.contentView addSubview:clearButton];
        
        [self.contentView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 50 - kLinePixel, self.contentView.width, kLinePixel) color:kColorNewLine]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
