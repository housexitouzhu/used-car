//
//  UCRegisterClientSuccessView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-9-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCRegisterClientSuccessView.h"
#import "UCTopBar.h"
#import "UCContactUsView.h"
#import "AMCacheManage.h"

@interface UCRegisterClientSuccessView ()
{
    
}

@property (nonatomic, strong) UCTopBar *tbTop;

@end

@implementation UCRegisterClientSuccessView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [UMStatistics event:pv_4_0__login_personregistration_successful];
        UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
        [UMSAgent postEvent:login_personregistration_successful_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:mUserInfo.userid, @"userid#4", nil]];
        // Initialization code
        [self initView];
    }
    return self;
}

- (void)initView{
    
    self.backgroundColor = kColorNewBackground;
    self.tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:self.tbTop];
    
    UIImageView *ivSuccess = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"log_inregistration"]];
    [ivSuccess setOrigin:CGPointMake((self.width-47)/2, self.tbTop.maxY + 50)];
    [self addSubview:ivSuccess];
    
    UILabel *labSuccess = [[UILabel alloc] initWithFrame:CGRectMake(0, ivSuccess.maxY+10, self.width, 15)];
    labSuccess.backgroundColor = kColorClear;
    labSuccess.text = @"恭喜您，注册成功！";
    labSuccess.font = kFontLarge;
    labSuccess.textColor = kColorBlue;
    labSuccess.textAlignment = NSTextAlignmentCenter;
    [self addSubview:labSuccess];
    
    
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLogin.frame = CGRectMake(10, self.tbTop.maxY + 160, self.width - 20, 44);
    [btnLogin setTitle:@"马上登录" forState:UIControlStateNormal];
    [btnLogin setTitleColor:kColorWhite forState:UIControlStateNormal];
    [btnLogin setBackgroundImage:[OMG imageWithColor:kColorBlue andSize:btnLogin.bounds.size] forState:UIControlStateNormal];
    [btnLogin setBackgroundImage:[OMG imageWithColor:kColorBlueH andSize:btnLogin.bounds.size] forState:UIControlStateSelected];
    [btnLogin setBackgroundImage:[OMG imageWithColor:kColorBlueH andSize:btnLogin.bounds.size] forState:UIControlStateHighlighted];
    [btnLogin.titleLabel setFont:kFontLarge1_b];
    [btnLogin.layer setCornerRadius:3.0];
    [btnLogin.layer setMasksToBounds:YES];
    [btnLogin addTarget:self action:@selector(onClickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btnLogin];
    
    UCContactUsView *vContactUS = [[UCContactUsView alloc] initWithFrame:CGRectMake(0, self.height - 80, self.width, 80) withStatementArray:@[@"您注册过程中遇到任何问题",@"请拨打客服电话：4000-111-168"] andPhoneNumber:@"4000111168"];
    [self addSubview:vContactUS];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"个人注册" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}


#pragma mark - onClickButton
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

- (void)onClickLoginButton:(id)sender{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}


@end
