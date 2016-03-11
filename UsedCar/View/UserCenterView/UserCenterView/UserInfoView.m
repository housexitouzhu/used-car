//
//  UserCenterView.m
//  UsedCar
//
//  Created by 张鑫 on 14-9-16.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UserInfoView.h"
#import "UCMainView.h"

@implementation UserInfoView

- (id)initWithUserStyle:(UserStyle)userStyle
{
    self = [super init];
    if (self) {
        [self initViewWithUserStyle:userStyle];
    }
    return self;
}

- (void)initViewWithUserStyle:(UserStyle)userSytle
{
    [self creatUserStyleViewWithUserStyle:userSytle];
}

#pragma mark - Public Method
- (void)creatUserStyleViewWithUserStyle:(UserStyle)userStyle
{
    // 无状态
    if (userStyle == UserStyleNone || userStyle == UserStylePhone) {
        [self creatUserStyleNoneView:CGRectMake(0, 0, [UCMainView sharedMainView].width, 166)];
    }
    else if (userStyle == UserStyleBusiness) {
        [self creatUserStyleBusinessView:CGRectMake(0, 0, [UCMainView sharedMainView].width, 100)];
    }
    else if (userStyle == UserStylePersonal) {
        [self creatUserStylePersonalView:CGRectMake(0, 0, [UCMainView sharedMainView].width, 100)];
    }
}

/** 创建UserInfo视图 */
- (void)creatUserStyleNoneView:(CGRect)frame
{
    /** 创建用户身份视图 */
    self.frame = frame;
    self.backgroundColor = kColorClear;
    
    NSArray *titles = @[@"商家登录", @"个人登录"];
    NSArray *image_n = @[@"businesses_notloggedin", @"i_notloggedin"];
    CGFloat minX = 0;
    
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [[UIButton alloc] initWithFrame:CGRectMake(minX, 0, frame.size.width / 2, 120)];
        [btnItem setTitle:titles[i] forState:UIControlStateNormal];
        [btnItem setTitleColor:kColorBlue forState:UIControlStateNormal];
        btnItem.titleLabel.font = kFontLarge;
        [btnItem setImage:[UIImage imageNamed:image_n[i]] forState:UIControlStateNormal];
        [btnItem setTitleEdgeInsets:UIEdgeInsetsMake(80.0,-btnItem.imageView.image.size.width, 0.0,0.0)];
        [btnItem setImageEdgeInsets:UIEdgeInsetsMake(-15, 0.0,0.0, -btnItem.titleLabel.bounds.size.width)];
        [btnItem addTarget:self action:@selector(onClickLoginBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        switch (i) {
            case 0:
                btnItem.tag = LoginButtonTagDealer;
                break;
            case 1:
                btnItem.tag = LoginButtonTagClient;
                break;
            default:
                break;
        }
        
        UILabel *labText = [[UILabel alloc] init];
        labText.text = i == 0 ? @"随时随地管理发布车源\n二手车商家实用工具" : @"收藏、订阅与网站同步\n信息，发布车源不丢失";
        labText.numberOfLines = 2;
        labText.backgroundColor = kColorClear;
        labText.textColor = kColorNewGray2;
        labText.font = kFontMini;
        [labText sizeToFit];
        labText.origin = CGPointMake((self.width / 2 - labText.width) / 2 + i * btnItem.width, 116);
        
        [self addSubview:btnItem];
        [self addSubview:labText];
        
        if (i == 0) {
            [self addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(btnItem.width, 22, kLinePixel, 120) color:kColorNewLine]];
        }
        
        minX += btnItem.width;
    }
    
}

/** 创建UserStyleBusiness视图 */
- (void)creatUserStyleBusinessView:(CGRect)frame
{
    /** 创建用户身份视图 */
    self.frame = frame;
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"my_bg"]];
    // 解决有白条bug
    [self addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, 1) color:kColorBlue]];

    UIImage *iImage = [UIImage imageNamed:@"businesses_loggedin"];
    UIImageView *ivPhoto = [[UIImageView alloc] initWithImage:iImage];
    ivPhoto.origin = CGPointMake(15, 15);
    
    if (!_labName)
        _labName = [[UILabel alloc] init];
    _labName.frame = CGRectMake(94, 0, self.width - 94 - 10, self.height);
    _labName.backgroundColor = kColorClear;
    _labName.font = kFontLarge;
    _labName.textColor = kColorWhite;
    _labName.numberOfLines = 4;
    
    [self addSubview:ivPhoto];
    [self addSubview:_labName];
    
}

/** 创建UserStylePersonal视图 */
- (void)creatUserStylePersonalView:(CGRect)frame
{
    /** 创建用户身份视图 */
    self.frame = frame;
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"my_bg"]];
    // 解决有白条bug
    [self addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, 1) color:kColorBlue]];
    
    UIImage *iImage = [UIImage imageNamed:@"i_loggedin"];
    UIImageView *ivPhoto = [[UIImageView alloc] initWithImage:iImage];
    ivPhoto.origin = CGPointMake(15, 15);
    
    if (!_labName)
        _labName = [[UILabel alloc] init];
    _labName.backgroundColor = kColorClear;
    _labName.font = kFontLarge;
    _labName.textColor = kColorWhite;
    
    if (!_labMobile)
        _labMobile = [[UILabel alloc] init];
    _labMobile.backgroundColor = kColorClear;
    _labMobile.font = kFontLarge;
    _labMobile.textColor = kColorWhite;
    
    [self addSubview:ivPhoto];
    [self addSubview:_labName];
    [self addSubview:_labMobile];
    
}

#pragma mark - onClickButton
- (void)onClickLoginBtn:(UIButton *)btn
{
    if (![OMG isValidClick])
        return;
    
    if ([_delegate respondsToSelector:@selector(UserInfoView:onClickLoginBtn:)]) {
        [_delegate UserInfoView:self onClickLoginBtn:btn];
    }
}

@end
