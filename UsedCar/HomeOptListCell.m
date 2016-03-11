//
//  HomeOptListCell.m
//  UsedCar
//
//  Created by Sun Honglin on 14-8-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "HomeOptListCell.h"

#define kCellHeight 50.0

@implementation HomeOptListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.width = self.contentView.width = cellWidth;
        self.height = kCellHeight;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 高亮背景
        _vHighlight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, kCellHeight)];
        _vHighlight.backgroundColor = kColorGrey5;
        
        _labTitle = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, self.width-44, self.height)];
        _labTitle.backgroundColor = [UIColor clearColor];
        _labTitle.textColor = kColorNewGray1;
        _labTitle.font = kFontLarge;
        
        _vLeftSelectBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, self.height)];
        _vLeftSelectBar.backgroundColor = kColorClear;
        
        UIView *hLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, self.height - kLinePixel, self.width, kLinePixel) color:kColorNewLine];
        
        [self.contentView addSubview:_vHighlight];
        [self.contentView addSubview:_labTitle];
        [self.contentView addSubview:_vLeftSelectBar];
        [self.contentView addSubview:hLine];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    if (selected) {
        _labTitle.textColor = kColorBlue;
        _vLeftSelectBar.backgroundColor = kColorBlue;
    }
    else{
        _labTitle.textColor = kColorNewGray1;
        _vLeftSelectBar.backgroundColor = kColorClear;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        _vHighlight.hidden = NO;
    }
    else{
        _vHighlight.hidden = YES;
    }
}

@end
