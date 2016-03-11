//
//  UCRegisterSuccessedView.m
//  UsedCar
//
//  Created by 张鑫 on 14-5-20.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCRegisterSuccessView.h"
#import "UCTopBar.h"
#import "AMCacheManage.h"
#import "UCContactUsView.h"

@implementation UCRegisterSuccessView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [UMStatistics event:pv_3_6_businessregistrationsuccess];

        if ([AMCacheManage currentUserType] == UserStyleBusiness) {
            UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
            [UMSAgent postEvent:businessregistrationsuccess_pv page_name:NSStringFromClass(self.class)
                     eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 mUserInfo.userid, @"userid#4", nil]];
        } else {
            [UMSAgent postEvent:businessregistrationsuccess_pv page_name:NSStringFromClass(self.class)];
        }
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    // 导航栏
    UCTopBar *vTopBar = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    // 联系方式
    UCContactUsView *vContactUs = [[UCContactUsView alloc] initWithFrame:CGRectMake(0, self.height - 77, self.width, 77)
                                                      withStatementArray:@[@"如注册操作遇到问题请联系客服人员", @"客服：010-59857661", @"QQ：1611381677"]
                                                          andPhoneNumber:@"01059857661"];
    
    // 成功
    UIView *vSuccess = [self creatSuccessView:CGRectMake(0, vTopBar.maxY, self.width, self.height - vContactUs.height - vTopBar.height)];
    
    [self addSubview:vTopBar];
    [self addSubview:vContactUs];
    [self addSubview:vSuccess];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    [vTopBar.btnLeft setTitle:@"关闭" forState:UIControlStateNormal];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    [vTopBar.btnTitle setTitle:@"提交成功" forState:UIControlStateNormal];
    
    return vTopBar;
}

/** 提交成功 */
- (UIView *)creatSuccessView:(CGRect)frame
{
    UIView *vSuccess = [[UIView alloc] initWithFrame:frame];
    vSuccess.backgroundColor = kColorWhite;
    
    // 图片
    UIImage *iRegSuccess = [UIImage imageNamed:@"succeed_icon"];
    UIImageView *ivRegSuccess = [[UIImageView alloc] initWithImage:iRegSuccess];
    ivRegSuccess.origin = CGPointMake((vSuccess.width - iRegSuccess.size.width) / 2, 130);
    
    // 已提交
    UILabel *labSubmited = [[UILabel alloc] init];
    labSubmited.text = @"您的申请已提交";
    labSubmited.font = kFontLarge;
    labSubmited.textColor = kColorGrey2;
    [labSubmited sizeToFit];
    labSubmited.origin = CGPointMake((vSuccess.width - labSubmited.width) / 2, ivRegSuccess.maxY + 35);
    
    // 工作人员会尽快与您联系，请保持手机畅通
    UILabel *labCommunicate = [[UILabel alloc] init];
    labCommunicate.text = @"工作人员会尽快与您联系，请保持手机畅通";
    labCommunicate.font = kFontSmall;
    labCommunicate.textColor = kColorGrey3;
    [labCommunicate sizeToFit];
    labCommunicate.origin = CGPointMake((vSuccess.width - labCommunicate.width) / 2, labSubmited.maxY + 12);
    
    [vSuccess addSubview:ivRegSuccess];
    [vSuccess addSubview:labSubmited];
    [vSuccess addSubview:labCommunicate];
    
    return vSuccess;
}

#pragma mark - onClickButton
- (void)onClickTopBar:(UIButton *)btn
{
    // 关闭
    if (btn.tag == UCTopBarButtonLeft) {
        [[MainViewController sharedVCMain] closeView:(UCView *)[[MainViewController sharedVCMain] aboveSubview:self] animateOption:AnimateOptionMoveLeft];
    }
}


@end
