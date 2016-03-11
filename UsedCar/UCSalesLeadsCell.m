//
//  UCSaleLeadCell.m
//  UsedCar
//
//  Created by wangfaquan on 14-4-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSalesLeadsCell.h"
#import "UCSalesLeadsModel.h"

#define kCellforRowHeight    50

@implementation UCSalesLeadsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.width = self.contentView.width = cellWidth;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 姓名
        _labName = [[UILabel alloc] initWithFrame:CGRectMake(10, kCellforRowHeight / 2 - 14, 80, 30)];
        _labName.backgroundColor = [UIColor clearColor];
        _labName.font = kFontLarge;
        
        // 电话
        _labPhone = [[UILabel alloc] initWithFrame:CGRectMake(_labName.maxX + 10, kCellforRowHeight / 2 - 14, 100, 30)];
        _labPhone.backgroundColor = [UIColor clearColor];
        _labPhone.font = kFontLarge;
        
        // 车辆意向个数
        _labCount = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.width - 117, kCellforRowHeight / 2 - 14, 35, 30)];
        _labCount.backgroundColor = kColorClear;
        _labCount.textColor = kColorOrange;
        _labCount.font = kFontSmall;
        _labCount.textAlignment = UITextAlignmentRight;
        
        _labData = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.width - 80, kCellforRowHeight / 2 - 14, 70, 30)];
        _labData.backgroundColor = [UIColor clearColor];
        _labData.font = kFontSmall;
        _labData.textColor = kColorGrey3;
        
        // 箭头
        _ivArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 30, 16.5, 18, 18)];
        _ivArrow.image = [UIImage imageNamed:@"set_arrow_right"];
        
        // 分割线 Y
       UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, kCellforRowHeight - 1, self.width, kLinePixel) color:kColorNewLine];
        
        [self.contentView addSubview:_labName];
        [self.contentView addSubview:_labPhone];
        [self.contentView addSubview:_labCount];
        [self.contentView addSubview:_labData];
        [self.contentView addSubview:_ivArrow];
        [self.contentView addSubview:vLine];
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

}

- (void)makeView:(UCSalesLeadsModel *)mSaleLead markReads:(NSMutableArray *)markReads
{
    _labCount.text = [NSString stringWithFormat:@"%@",[mSaleLead.carcount stringValue]];
    _labData.text = @"辆意向车";
    _labName.text = mSaleLead.name;
    _labPhone.text = mSaleLead.mobile;
    
    if([markReads containsObject:mSaleLead.mobile]) {
        _labName.textColor = kColorGrey3;
        _labPhone.textColor = kColorGrey3;
        _labCount.textColor = kColorGrey3;
    } else {
        _labName.textColor = kColorGray1;
        _labPhone.textColor = kColorGray1;
        _labCount.textColor = kColorOrange;
    }
    
}

@end
