//
//  UCIMHistoryCell.m
//  UsedCar
//
//  Created by 张鑫 on 14/11/24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCIMHistoryCell.h"
#import "NSString+Util.h"
#import "StorageContact.h"
#import "UIImageView+WebCacheAnimation.h"
#import "JSBadgeView.h"

@interface UCIMHistoryCell ()

@property (nonatomic, strong) UIView *vCellMain;
@property (nonatomic, strong) UIImageView *ivCarPhoto;
@property (nonatomic, strong) UIView *vUnReadCountSuper;
@property (nonatomic, strong) UILabel *labUserName;
@property (nonatomic, strong) UILabel *labShopName;
@property (nonatomic, strong) UILabel *labCarName;
@property (nonatomic, strong) UILabel *labMessage;
@property (nonatomic, strong) UILabel *labTime;
@property (nonatomic, strong) UIImageView *ivShield;
@property (nonatomic, strong) UILabel *labSaled;
@property (nonatomic, strong) JSBadgeView *jsbCount;

@end

@implementation UCIMHistoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.width = self.contentView.width = cellWidth;
        _vCellMain = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _vCellMain.backgroundColor = kColorClear;
        
        // 图片
        _ivCarPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 80, 59)];
        _ivCarPhoto.layer.masksToBounds = YES;
        
        _vUnReadCountSuper = [[UIView alloc] initWithFrame:_ivCarPhoto.frame];
        _vUnReadCountSuper.backgroundColor = kColorClear;
        _vUnReadCountSuper.userInteractionEnabled = NO;
        
        // 已售
        _labSaled = [[UILabel alloc] initLineWithFrame:_ivCarPhoto.bounds color:[UIColor colorWithWhite:0 alpha:0.4]];
        _labSaled.font = kFontLarge;
        _labSaled.text = @"已售";
        _labSaled.textColor = kColorWhite;
        _labSaled.textAlignment = NSTextAlignmentCenter;
        _labSaled.hidden = YES;
        [_ivCarPhoto addSubview:_labSaled];
        
        // 标题
        _labUserName = [[UILabel alloc] initWithClearFrame:CGRectMake(_ivCarPhoto.maxX + 8, 8, 0, 0)];
        _labUserName.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        _labUserName.numberOfLines = 1;
        _labUserName.font = kFontLarge;
        
        // 未读标记
        _jsbCount = [[JSBadgeView alloc] initWithParentView:_vUnReadCountSuper alignment:JSBadgeViewAlignmentTopRight];
        _jsbCount.badgeTextFont = kFontTiny;
        _jsbCount.badgeStrokeWidth = 0;
        _jsbCount.badgePositionAdjustment = CGPointMake(-2, 3);
        
        // 店名
        _labShopName = [[UILabel alloc] init];
        _labShopName.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingMiddle;
        _labShopName.numberOfLines = 1;
        _labShopName.font = kFontSmall;
        _labShopName.textColor = kColorNewGray2;
        _labShopName.backgroundColor = kColorClear;
        
        // 车名
        _labCarName = [[UILabel alloc] init];
        _labCarName.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        _labCarName.numberOfLines = 1;
        _labCarName.font = kFontSmall;
        _labCarName.textColor = kColorNewGray2;
        _labCarName.backgroundColor = kColorClear;
        
        // 消息
        _labMessage = [[UILabel alloc] init];
        _labMessage.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        _labMessage.numberOfLines = 1;
        _labMessage.font = kFontNormal;
        _labMessage.textColor = kColorNewGray1;
        _labMessage.backgroundColor = kColorClear;
        
        // 时间
        _labTime = [[UILabel alloc] init];
        _labTime.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        _labTime.numberOfLines = 1;
        _labTime.font = kFontTiny;
        _labTime.textColor = kColorNewGray2;
        _labTime.backgroundColor = kColorClear;
        
        // 屏蔽图片
        UIImage *iShield = [UIImage imageNamed:@"consultation_shield"];
        _ivShield = [[UIImageView alloc] initWithImage:iShield];
        _ivShield.origin = CGPointMake(self.width - iShield.size.width - 8, kHistoryCellHeight - iShield.size.height - 11);
        _ivShield.hidden = YES;
        
        // 分割线
        UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, kHistoryCellHeight - kLinePixel, self.contentView.width, kLinePixel) color:kColorNewLine];
        
        [_vCellMain addSubview:_ivCarPhoto];
        [_vCellMain addSubview:_vUnReadCountSuper];
        [_vCellMain addSubview:_labUserName];
        [_vCellMain addSubview:_labShopName];
        [_vCellMain addSubview:_labCarName];
        [_vCellMain addSubview:_labMessage];
        [_vCellMain addSubview:_labTime];
        [_vCellMain addSubview:_ivShield];
        [_vCellMain addSubview:vLine];
        
        [self.contentView addSubview:_vCellMain];
    }
    return self;
}

- (void)makeView:(StorageContact *)mContact
{
    
    if (mContact.photo.length == 0) {
        _ivCarPhoto.image = [UIImage imageNamed:@"home_default"];
    }
    else {
        [_ivCarPhoto sd_setImageWithURL:[NSURL URLWithString:mContact.photo]  placeholderImage:[UIImage imageNamed:@"home_default"] animate:YES];
    }
    
    _labUserName.text = mContact.nickName;
    [_labUserName sizeToFit];
    
    _jsbCount.badgeText = mContact.unReadNum > 0 ? [NSString stringWithFormat:@"%d", mContact.unReadNum] : nil;
    
    NSString *shopName = mContact.dealerName.length > 0 ? [NSString stringWithFormat:@"（%@）", mContact.dealerName] : @"(个人)";
    if (mContact.dealerid.integerValue > 0)
        shopName = @"(商家)";
    _labShopName.text = shopName;
    _labShopName.size = CGSizeMake(self.width - _labUserName.maxX - 55, _labUserName.height);
    if (_labUserName.width > self.width - (188+ 184)/2) {
        _labUserName.width = self.width - (188+184)/2;
    }
    _labShopName.origin = CGPointMake(_labUserName.maxX, 9);
    
    _labCarName.text = [NSString stringWithFormat:@"咨询：%@", mContact.carName];
    [_labCarName sizeToFit];
    _labCarName.width = self.width - 110;
    _labCarName.origin = CGPointMake(_labUserName.minX, _labUserName.maxY + 4);
    
    _labMessage.text = mContact.mostRecentMessage;
    [_labMessage sizeToFit];
    _labMessage.width = self.width - 110;
    _labMessage.origin = CGPointMake(_labUserName.minX, _labCarName.maxY + 4);
    
    _labTime.text =  mContact.mostRecentTime > 0 ? [OMG intervalSinceNow:mContact.mostRecentDate] : @"";
    [_labTime sizeToFit];
    _labTime.origin = CGPointMake(_vCellMain.width - _labTime.width - 8, 11);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted)
        self.contentView.backgroundColor = kColorNewLine;
    else
        self.contentView.backgroundColor = kColorWhite;
}

@end
