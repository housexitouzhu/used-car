//
//  UCSearchCell.m
//  UsedCar
//
//  Created by wangfaquan on 14-5-14.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSearchCell.h"

@implementation UCSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _labName = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.width, 30)];
        _labName.backgroundColor = [UIColor clearColor];
        _labName.font = kFontLarge;
        [self.contentView addSubview:_labName];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted)
        self.contentView.backgroundColor = kColorGrey5;
    else
        self.contentView.backgroundColor = kColorWhite;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)makeView:(UCCarBrandModel *)mBrind isShowSelect:(BOOL)isShowSelect
{
    _labName.text = mBrind.name;
}
@end
