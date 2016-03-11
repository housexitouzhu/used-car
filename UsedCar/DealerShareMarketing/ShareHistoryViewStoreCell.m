//
//  ShareHistoryViewCell.m
//  UsedCar
//
//  Created by 张鑫 on 14-10-14.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "ShareHistoryViewStoreCell.h"
#import "UCShareHistoryModel.h"
#import "UIImageView+WebCacheAnimation.h"

#define minY 22

@interface ShareHistoryViewStoreCell ()

@property (nonatomic, strong) UIImageView *ivCircle;
@property (nonatomic, strong) UILabel *labTime;
@property (nonatomic, strong) UILabel *labType;
@property (nonatomic, strong) UIView *vContent;
@property (nonatomic, strong) UIImageView *ivImage;
@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) UILabel *labContent;

@end

@implementation ShareHistoryViewStoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.width = self.contentView.width = cellWidth;
        self.backgroundColor = kColorClear;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 时间线圆
        UIImage *iCircle = [UIImage imageNamed:@"sharehistory_time"];
        _ivCircle = [[UIImageView alloc] initWithImage:iCircle];
        _ivCircle.origin = CGPointMake(5, 4 + minY);
        
        // 时间
        _labTime = [[UILabel alloc] init];
        _labTime.backgroundColor = kColorClear;
        _labTime.origin = CGPointMake(25,  + minY);
        _labTime.textColor = kColorNewGray1;
        _labTime.font = kFontLarge;
        
        // 类别
        _labType = [[UILabel alloc] initWithFrame:CGRectMake(_labTime.maxX + 10, 1 + minY, 58, 17)];
        _labType.textColor = kColorWhite;
        _labType.font = kFontTiny;
        _labType.textAlignment = NSTextAlignmentCenter;
        _labType.layer.masksToBounds = YES;
        _labType.layer.cornerRadius = 3;
        _labType.backgroundColor = kColorNewGreen2;
        _labType.text = @"店铺分享";
        
        // 内容视图
        _vContent = [[UIView alloc] initLineWithFrame:CGRectMake(25, 48, self.contentView.width - 38, 54) color:kColorWhite];
        
        _ivImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, (_vContent.height - 44) / 2, 44, 44)];
        _ivImage.contentMode = UIViewContentModeScaleAspectFit;
        
        // 标题
        _labTitle = [[UILabel alloc] initWithFrame:CGRectMake(_ivImage.maxX + 5, 10, _vContent.width - _ivImage.width - 5 * 3, 15)];
        _labTitle.font = kFontLarge;
        _labTitle.textColor = kColorNewGray1;
        
        // 内容
        _labContent = [[UILabel alloc] initWithFrame:CGRectMake(_labTitle.minX, _labTitle.maxY + 6, _labTitle.width, 15)];
        _labContent.font = kFontSmall;
        _labContent.textColor = kColorNewGray2;
        
        [self.contentView addSubview:_ivCircle];
        [self.contentView addSubview:_labTime];
        [self.contentView addSubview:_labType];
        [self.contentView addSubview:_vContent];
        [_vContent addSubview:_ivImage];
        [_vContent addSubview:_labTitle];
        [_vContent addSubview:_labContent];
    }
    return self;
}

- (void)makeViewWithModel:(UCShareHistoryModel *)mShare
{
    _labTime.text = mShare.createtimeshow;
    [_labTime sizeToFit];
    _labType.minX = _labTime.maxX + 10;
    _labTitle.text = mShare.dealername;
    _labContent.text = mShare.content;
    if (mShare.dealerlogo.length > 0) {
        [_ivImage sd_setImageWithURL:[NSURL URLWithString:mShare.dealerlogo]  placeholderImage:[UIImage imageNamed:@"home_default"] animate:YES];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
