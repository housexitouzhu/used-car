//
//  CarStatusView.m
//  UsedCar
//
//  Created by 张鑫 on 14-9-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "CarStatusView.h"
#import "UCMainView.h"
#import "UIImage+Util.h"

@implementation CarStatusView

- (id)initWithUserStyle:(UserStyle)userStyle;
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
    self.backgroundColor = kColorWhite;
    self.width = [UCMainView sharedMainView].width;
    CGFloat height = 0;
    
    UIView *vMyCars = [self creatMyCarsViewWithUserStyle:userStyle];
    [self addSubview:vMyCars];
    height =vMyCars.maxY;
    
    UIView *vCarStatus = [self creatCarStatusCountViewWithSize:CGSizeMake([UCMainView sharedMainView].width, 45 * 3)];
    vCarStatus.origin = CGPointMake(0, vMyCars.maxY);
    [self addSubview:vCarStatus];
    height = vCarStatus.maxY;
    
    self.size = CGSizeMake([UCMainView sharedMainView].width, height);
}

- (UILabel *)getLabelWithCarStatusTag:(CarStatusTag)carStatusTag
{
    return (UILabel *)[self viewWithTag:carStatusTag + 1000];
}

/** 创建我卖的车视图 */
- (UIView *)creatMyCarsViewWithUserStyle:(UserStyle)userStyle
{
    UIView *vBody = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 45)];
    vBody.backgroundColor = kColorWhite;
    
    _btnMyCars = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, vBody.width, vBody.height)];
    _btnMyCars.titleLabel.font = kFontLarge;
    [_btnMyCars setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
    [_btnMyCars setTitle:@"我卖的车" forState:UIControlStateNormal];
    _btnMyCars.userInteractionEnabled = NO;
    [_btnMyCars setImage:[UIImage imageNamed:@"my_list_salecar"] forState:UIControlStateNormal];
    [_btnMyCars setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:_btnMyCars.size] forState:UIControlStateHighlighted];
    _btnMyCars.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_btnMyCars setTitleEdgeInsets:UIEdgeInsetsMake(0, 25, 0, 0)];
    [_btnMyCars setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [_btnMyCars addTarget:self action:@selector(onClickMyCarsBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [vBody addSubview:_btnMyCars];
    
    // 箭头
    if (userStyle == UserStyleNone || userStyle == UserStylePhone) {
        _btnSetPhone = [[UIButton alloc] initWithFrame:CGRectMake(vBody.width - 100, 0, 100, _btnMyCars.height)];
        [_btnSetPhone setTitle:userStyle == UserStylePhone ? @"更换手机" : @"手机找车" forState:UIControlStateNormal];
        [_btnSetPhone setTitleColor:kColorBlue forState:UIControlStateNormal];
        [_btnSetPhone setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:_btnSetPhone.size] forState:UIControlStateHighlighted];
        _btnSetPhone.titleLabel.font = kFontLarge;
        [_btnSetPhone addTarget:self action:@selector(onClickSetPhoneBtn:) forControlEvents:UIControlEventTouchUpInside];
        [vBody addSubview:_btnSetPhone];
        
        [_btnSetPhone addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, (_btnSetPhone.height - 25) / 2, kLinePixel, 25) color:kColorNewLine]];
    }
    else if (userStyle == UserStyleBusiness || userStyle == UserStylePersonal) {
        _labRefreshTime = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, self.width - 150 - 15, _btnMyCars.height - 1)];
        _labRefreshTime.backgroundColor = kColorClear;
        _labRefreshTime.textColor = kColorNewGray2;
        _labRefreshTime.font = kFontTiny;
        _labRefreshTime.textAlignment = NSTextAlignmentRight;
        [vBody addSubview:_labRefreshTime];
    }
    
    [vBody addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, vBody.width, kLinePixel) color:kColorNewLine]];
    [vBody addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, vBody.height - kLinePixel, vBody.width, kLinePixel) color:kColorNewLine]];
    
    return vBody;
}

/** 创建车源状态视图 */
- (UIView *)creatCarStatusCountViewWithSize:(CGSize)size
{
    UIView *vBody = [[UIView alloc] init];
    vBody.size = size;
    
    NSArray *title = @[@"在售车", @"未通过", @"已售车", @"未填完", @"审核中", @"已过期"];
    
    CGFloat minX = 0;
    CGFloat minY = 0;
    
    for (int i = 0; i < title.count; i++) {
        minX = (i % 2 == 0) ? 0 : self.width / 2;
        if (i % 2 == 0 && i!= 0) {
            minY += 45;
        }
        
        UIButton *btnItem = [[UIButton alloc] initWithFrame:CGRectMake(minX, minY, self.width / 2, 45)];
        btnItem.tag = CarStatusTagOnSale + i;
        [btnItem setTitle:title[i] forState:UIControlStateNormal];
        [btnItem setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
        [btnItem setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnItem.size] forState:UIControlStateHighlighted];
        btnItem.titleLabel.font = kFontLarge;
        btnItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btnItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
        [btnItem addTarget:self action:@selector(onClickCarStatusButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *labCount = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, btnItem.width - 75 - 15, btnItem.height)];
        labCount.tag = CarStatusTagOnSale + i + 1000;
        labCount.backgroundColor = kColorClear;
        labCount.text = @"0";
        labCount.font = kFontLarge;
        labCount.textColor = kColorNewGray2;
        labCount.textAlignment = NSTextAlignmentRight;
         
        [vBody addSubview:btnItem];
        [btnItem addSubview:labCount];
    }
    
    [vBody addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 45, vBody.width, kLinePixel) color:kColorNewLine]];
    [vBody addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 45 * 2, vBody.width, kLinePixel) color:kColorNewLine]];
    [vBody addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(self.width / 2, 0, kLinePixel, vBody.height) color:kColorNewLine]];
    
    return vBody;
}

/** 点击我卖的车按钮 */
- (void)onClickMyCarsBtn:(UIButton *)btn
{
    if (![OMG isValidClick])
        return;
    
    if ([self.delegate respondsToSelector:@selector(CarStatusView:onClickMyCarButton:)]) {
        [self.delegate CarStatusView:self onClickMyCarButton:btn];
    }
}

- (void)onClickSetPhoneBtn:(UIButton *)btn
{
    if (![OMG isValidClick])
        return;
    
    if ([self.delegate respondsToSelector:@selector(CarStatusView:onClickSetPhoneButton:)]) {
        [self.delegate CarStatusView:self onClickSetPhoneButton:btn];
    }
}

- (void)onClickCarStatusButton:(UIButton *)btn
{
    if (![OMG isValidClick])
        return;
    
    if ([self.delegate respondsToSelector:@selector(CarStatusView:onClickCarStatusButton:indexOfButton:)]) {
        [self.delegate CarStatusView:self onClickCarStatusButton:btn indexOfButton:btn.tag - CarStatusTagOnSale];
    }
}


@end
