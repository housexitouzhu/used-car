//
//  UCLoginDealerView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-9-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCLoginDealerView.h"
#import "UCTopBar.h"
#import "UCRegisterDealerView.h"
#import "UCContactUsView.h"
#import "UserLogInOutHelper.h"
#import "NSString+Util.h"

@interface UCLoginDealerView ()<UITextFieldDelegate>
{
    UITextField *currentField;
}

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UIScrollView *vScroll;
@property (nonatomic, strong) UIView *vField;
@property (nonatomic, strong) UITextField *tfAccount;
@property (nonatomic, strong) UITextField *tfPassword;
@property (nonatomic, strong) UserLogInOutHelper *loginHelper;

@end

@implementation UCLoginDealerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
        
    }
    return self;
}


- (void)initView{
    
    self.backgroundColor = kColorNewBackground;
    self.tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    self.vScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.tbTop.maxY, self.width, self.height - 64)];
    [self.vScroll setBackgroundColor:kColorClear];
    
    UIButton *btnDismiss = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDismiss setFrame:self.vScroll.bounds];
    [btnDismiss addTarget:self action:@selector(dismissKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    
    self.vField = [self createFieldView:CGRectMake(0, 20, self.width, 50*2+kLinePixel*3)];
    
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogin setFrame:CGRectMake(10, self.vField.maxY+20, self.width - 20, 44)];
    [btnLogin setTitle:@"马上登录" forState:UIControlStateNormal];
    [btnLogin setTitleColor:kColorWhite forState:UIControlStateNormal];
    [btnLogin setBackgroundImage:[OMG imageWithColor:kColorBlue andSize:btnLogin.bounds.size] forState:UIControlStateNormal];
    [btnLogin setBackgroundImage:[OMG imageWithColor:kColorBlueH andSize:btnLogin.bounds.size] forState:UIControlStateSelected];
    [btnLogin setBackgroundImage:[OMG imageWithColor:kColorBlueH andSize:btnLogin.bounds.size] forState:UIControlStateHighlighted];
    [btnLogin.titleLabel setFont:kFontLarge1_b];
    [btnLogin.layer setCornerRadius:3.0];
    [btnLogin.layer setMasksToBounds:YES];
    [btnLogin addTarget:self action:@selector(onClickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *btnReg = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnReg setFrame:CGRectMake(self.width-85-10, btnLogin.maxY+20, 85, 14)];
    [btnReg setTitle:@"商家免费注册" forState:UIControlStateNormal];
    [btnReg setTitleColor:kColorBlue forState:UIControlStateNormal];
    [btnReg setTitleColor:kColorBlueH forState:UIControlStateSelected];
    [btnReg setTitleColor:kColorBlueH forState:UIControlStateHighlighted];
    [btnReg.titleLabel setFont:kFontNormal];
    [btnReg addTarget:self action:@selector(onClickRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.vScroll setContentSize:CGSizeMake(self.width, btnReg.maxY)];
    
    UCContactUsView *vContactUS = [[UCContactUsView alloc] initWithFrame:CGRectMake(0, self.height - 80, self.width, 80) withStatementArray:@[@"车源没有发布成功或找回密码请致电", @"二手车之家服务电话：010-56857661"] andPhoneNumber:@"01056857661"];
    
    //add subviews
    [self addSubview:self.tbTop];
    [self addSubview:self.vScroll];
    [self.vScroll addSubview:btnDismiss];
    [self.vScroll addSubview:self.vField];
    [self.vScroll addSubview:btnLogin];
    [self.vScroll addSubview:btnReg];
    [self addSubview:vContactUS];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"商家登录" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"取消"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

- (UIView *)createFieldView:(CGRect)frame{
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = kColorWhite;
    
    UIView *hLine1 = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, frame.size.width, kLinePixel) color:kColorNewLine];
    
    UILabel *labAcc = [[UILabel alloc] initWithFrame:CGRectMake(10, hLine1.maxY, 45, 50)];
    [labAcc setText:@"账号："];
    [labAcc setTextColor:kColorNewGray1];
    [labAcc setFont:kFontLarge];
    
    self.tfAccount = [[UITextField alloc] initWithFrame:CGRectMake(labAcc.maxX, hLine1.maxY, self.width-labAcc.maxX-10, 50)];
    [self.tfAccount setBorderStyle:UITextBorderStyleNone];
    [self.tfAccount setTextColor:kColorNewGray1];
    [self.tfAccount setFont:kFontLarge];
    [self.tfAccount setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.tfAccount setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.tfAccount setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.tfAccount setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.tfAccount setReturnKeyType:UIReturnKeyNext];
    [self.tfAccount setDelegate:self];
//#warning 打包前删除 test商家登录
//    self.tfAccount.text =  @"顾问经纪公司测试";
//    self.tfAccount.text = @"保证金测试66";
//    self.tfAccount.text = @"保证金测试";
    
    /******* 线上 *******/
//    self.tfAccount.text = @"运营经纪公司测试";
//    self.tfAccount.text = @"运营经销商测试";
//    self.tfAccount.text = @"移动经销商测试";
//    self.tfAccount.text = @"二手车之家";
//    self.tfAccount.text = @"超级跑车代购";
//    self.tfAccount.text = @"保证金测试66";
//    self.tfAccount.text = @"移动经销商测试";
//    self.tfAccount.text =  @"顾问经纪公司测试";

    
    UIView *hLine2 = [[UIView alloc] initLineWithFrame:CGRectMake(10, labAcc.maxY, self.width-10, kLinePixel) color:kColorNewLine];
    
    UILabel *labPwd = [[UILabel alloc] initWithFrame:CGRectMake(10, hLine2.maxY, 45, 50)];
    [labPwd setText:@"密码："];
    [labPwd setTextColor:kColorNewGray1];
    [labPwd setFont:kFontLarge];
    
    self.tfPassword = [[UITextField alloc] initWithFrame:CGRectMake(labPwd.maxX, hLine2.maxY, self.width-labPwd.maxX-10, 50)];
    [self.tfPassword setBorderStyle:UITextBorderStyleNone];
    [self.tfPassword setTextColor:kColorNewGray1];
    [self.tfPassword setFont:kFontLarge];
    [self.tfPassword setSecureTextEntry:YES];
    [self.tfPassword setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.tfPassword setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.tfPassword setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.tfPassword setDelegate:self];

//#warning 打包前删除 test商家登录
//    self.tfPassword.text = @"qqq111";
//    self.tfPassword.text = @"123qwe";

    
    UIView *hLine3 = [[UIView alloc] initLineWithFrame:CGRectMake(0, labPwd.maxY, self.width, kLinePixel) color:kColorNewLine];
    
    [view addSubview:hLine1];
    [view addSubview:labAcc];
    [view addSubview:self.tfAccount];
    [view addSubview:hLine2];
    [view addSubview:labPwd];
    [view addSubview:self.tfPassword];
    [view addSubview:hLine3];
    
    
    return view;
}



#pragma mark - onClickButton
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [self endEditing:YES];
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveUp];
}

- (void)dismissKeyboard:(id)sender{
    [self endEditing:YES];
}

- (void)onClickLoginButton:(id)sender{
    if (![OMG isValidClick])
        return;
    
    [self endEditing:YES];
    
    if ([self.tfAccount.text trim].length == 0 || self.tfPassword.text.length == 0) {
        [[AMToastView toastView] showMessage:@"请输入用户名或密码" icon:kImageRequestError duration:AMToastDurationNormal];
    }
    else{
        
        if(!self.loginHelper){
            self.loginHelper = [[UserLogInOutHelper alloc] init];
        }
        
        [self.loginHelper dealerLoginWithUserName:[self.tfAccount.text trim] password:self.tfPassword.text returnBlock:^(BOOL success, NSInteger returnCode, NSString *message, UserInfoModel *userInfoModel) {
            
            if (returnCode == 0) {
                [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveUp];
                
                if ([self.delegate respondsToSelector:@selector(UCLoginDealerView:loginSuccess:)]){
                    [self.delegate UCLoginDealerView:self loginSuccess:YES];
                }
            }
            else{
                if ([self.delegate respondsToSelector:@selector(UCLoginDealerView:loginSuccess:)]){
                    [self.delegate UCLoginDealerView:self loginSuccess:NO];
                }
            }
            
        }];
        
    }
    
}

- (void)onClickRegisterButton:(id)sender{
    if (![OMG isValidClick])
        return;
    
    UCRegisterDealerView *vRegister = [[UCRegisterDealerView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds];
    [[MainViewController sharedVCMain] openView:vRegister animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}


#pragma mark - uitextfield delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    currentField = textField;
    
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == self.tfAccount) {
        [self.tfPassword becomeFirstResponder];
    }
    else if(textField == self.tfPassword){
        [self onClickLoginButton:nil];
    }
    
    
    return true;
}



@end
