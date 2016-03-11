//
//  UCGuessLikeCell.m
//  UsedCar
//
//  Created by wangfaquan on 13-12-18.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCRaiderCell.h"
#import "UCRaiderModel.h"

@implementation UCRaiderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.width = self.contentView.width = cellWidth;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // 标题
        _labTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(20, 15, self.width - 40, 14)];
        _labTitle.font = [UIFont systemFontOfSize:14];
        
        // 时间
        _labDate = [[UILabel alloc] initWithClearFrame:CGRectMake(20, _labTitle.maxY + 7, self.width - 40, 12)];
        _labDate.font = [UIFont systemFontOfSize:12];
        _labDate.textColor = kColorGrey3;
        
        // 内容
        _labContent = [[UILabel alloc] initWithClearFrame:CGRectMake(20, _labDate.maxY + 8, self.width - 40, 30)];
        _labContent.font = [UIFont systemFontOfSize:12];
        _labContent.textColor = kColorGrey3;
        _labContent.numberOfLines = 2;
        
        // 分割线 Y
        _vLine = [[UIView alloc] initLineWithFrame:CGRectMake(15, _labContent.maxY + 15, self.width - 15, kLinePixel) color:kColorNewLine];
        
        [self addSubview:_labContent];
        [self addSubview:_labDate];
        [self addSubview:_labTitle];
        [self addSubview:_vLine];
    }
    return self;
}

- (void)makeView:(UCRaiderModel *)mCarInfo isLocal:(BOOL)isLocal
{
    _labContent.text = [NSString stringWithFormat:@"%@...", mCarInfo.articleintroduce];
    _labTitle.text = mCarInfo.articletitle;
    _labDate.text = mCarInfo.articlepublishdate;
    
    if (isLocal) {
        _labDate.hidden = YES;
        _labContent.minY = _labTitle.maxY + 8;
        _vLine.minY = _labContent.maxY + 14.5;
    } else {
        _labDate.hidden = NO;
    }
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

@end
