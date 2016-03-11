//
//  ShareHistoryViewCell.m
//  UsedCar
//
//  Created by 张鑫 on 14-10-14.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "ShareHistoryViewCarCell.h"
#import "UCShareHistoryModel.h"
#import "UIImageView+WebCacheAnimation.h"

#define topMinY 22

@interface ShareHistoryViewCarCell ()

@property (nonatomic, strong) UIImageView *ivCircle;
@property (nonatomic, strong) UILabel *labTime;
@property (nonatomic, strong) UILabel *labType;
@property (nonatomic, strong) UIView *vContent;
@property (nonatomic, strong) UIImageView *ivImage1;
@property (nonatomic, strong) UIImageView *ivImage2;
@property (nonatomic, strong) UIImageView *ivImage3;
@property (nonatomic, strong) UILabel *labContent;

@end

@implementation ShareHistoryViewCarCell

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
        _ivCircle.origin = CGPointMake(5, 4 + topMinY);
        
        // 时间
        _labTime = [[UILabel alloc] init];
        _labTime.backgroundColor = kColorClear;
        _labTime.origin = CGPointMake(25,  + topMinY);
        _labTime.textColor = kColorNewGray1;
        _labTime.font = kFontLarge;
        
        // 类别
        _labType = [[UILabel alloc] initWithFrame:CGRectMake(_labTime.maxX + 10, 1 + topMinY, 58, 17)];
        _labType.textColor = kColorWhite;
        _labType.font = kFontTiny;
        _labType.textAlignment = NSTextAlignmentCenter;
        _labType.layer.masksToBounds = YES;
        _labType.layer.cornerRadius = 3;
        _labType.text = @"车源分享";
        _labType.backgroundColor = kColorNewBlue3;
        
        // 内容视图
        _vContent = [[UIView alloc] initLineWithFrame:CGRectMake(25, 48, self.contentView.width - 38, 54) color:kColorWhite];
        
        _ivImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, (_vContent.height - 44) / 2, 44, 44)];
        _ivImage1.contentMode = UIViewContentModeScaleAspectFit;
        _ivImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(_ivImage1.maxX + 5, _ivImage1.minY, 44, 44)];
        _ivImage2.contentMode = UIViewContentModeScaleAspectFit;
        _ivImage3 = [[UIImageView alloc] initWithFrame:CGRectMake(_ivImage2.maxX + 5, _ivImage1.minY, 44, 44)];
        _ivImage3.contentMode = UIViewContentModeScaleAspectFit;
        _ivImage1.hidden = _ivImage2.hidden = _ivImage3.hidden = YES;
        _ivImage1.backgroundColor =_ivImage2.backgroundColor = _ivImage3.backgroundColor = kColorClear;
        
        // 内容
        _labContent = [[UILabel alloc] init];
        _labContent.font = kFontSmall;
        _labContent.textColor = kColorNewGray2;
        _labContent.origin = CGPointMake(_ivImage3.maxX + 27, (54 - 15) / 2);
        
        [self.contentView addSubview:_ivCircle];
        [self.contentView addSubview:_labTime];
        [self.contentView addSubview:_labType];
        [self.contentView addSubview:_vContent];
        [_vContent addSubview:_ivImage1];
        [_vContent addSubview:_ivImage2];
        [_vContent addSubview:_ivImage3];
        [_vContent addSubview:_labContent];
    }
    return self;
}

- (void)makeViewWithModel:(UCShareHistoryModel *)mShare
{
    NSArray *images = [mShare.thumbnailurls componentsSeparatedByString:@","];
    _labTime.text = mShare.createtimeshow;
    [_labTime sizeToFit];
    _labType.minX = _labTime.maxX + 10;
    
    _labContent.text = [NSString stringWithFormat:@"本次共分享%d辆", mShare.carcount.integerValue];
    [_labContent sizeToFit];
    
    _ivImage1.hidden = _ivImage2.hidden = _ivImage3.hidden = YES;
    
    UIImageView *minXOfImage = _ivImage1;
    
    if (images.count > 0) {
        _ivImage1.hidden = NO;
        [_ivImage1 sd_setImageWithURL:[NSURL URLWithString:[images objectAtIndex:0]]  placeholderImage:[UIImage imageNamed:@"home_default"] animate:YES];
    }
    if (images.count > 1) {
        _ivImage2.hidden = NO;
        [_ivImage2 sd_setImageWithURL:[NSURL URLWithString:[images objectAtIndex:1]]  placeholderImage:[UIImage imageNamed:@"home_default"] animate:YES];
        minXOfImage = _ivImage2;
    }
    if (images.count > 2) {
        _ivImage3.hidden = NO;
        [_ivImage3 sd_setImageWithURL:[NSURL URLWithString:[images objectAtIndex:2]]  placeholderImage:[UIImage imageNamed:@"home_default"] animate:YES];
        minXOfImage = _ivImage3;
    }
    
    _labContent.minX = minXOfImage.maxX + 27;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
