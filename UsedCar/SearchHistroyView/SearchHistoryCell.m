//
//  SearchHistoryCell.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-11.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "SearchHistoryCell.h"

@implementation SearchHistoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.width = self.contentView.width = cellWidth;
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 15, self.width - 18 * 2, 20)];
        [self.nameLabel setFont:kFontLarge];
        [self.nameLabel setTextColor:kColorNewGray1];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.nameLabel];
        
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
