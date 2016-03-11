//
//  UCLoginClientView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-9-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCLoginClientView.h"
#import "UCTopBar.h"
#import "UCRegisterClientView.h"
#import "UCContactUsView.h"
#import "APIHelper.h"
#import "UserLogInOutHelper.h"
#import "NSString+Util.h"
#import "AMCacheManage.h"

@interface UCLoginClientView ()<UITextFieldDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    NSInteger errorCount;
    UITextField *currentField;
    CGRect keyboardRect;
    CGFloat keyboardRectY;
    NSInteger animationCurve;
    CGFloat animationDuration;
}

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UIScrollView *vScroll;
@property (nonatomic, strong) UIView *vField;
@property (nonatomic, strong) UIView *vVerify;
@property (nonatomic, strong) UIImageView *ivVerify;
@property (nonatomic, strong) UITextField *tfAccount;
@property (nonatomic, strong) UITextField *tfPassword;
@property (nonatomic, strong) UITextField *tfVerify;
@property (nonatomic, strong) UIButton *btnLogin;
@property (nonatomic, strong) UIButton *btnReg;
@property (nonatomic, strong) UIButton *btnSaleCar;
@property (nonatomic, assign, readonly) CGSize orignalContentSize;

@property (nonatomic, strong) APIHelper *apiGetCode;


@end

@implementation UCLoginClientView

- (id)initWithFrame:(CGRect)frame loginType:(UCLoginClientType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        [UMStatistics event:pv_4_0_login_personlogin];
        [UMSAgent postEvent:login_personlogin_pv page_name:NSStringFromClass(self.class)];
        // Initialization code
        self.loginType = type;
        
        [self initView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}


- (void)initView{
    
    self.backgroundColor = kColorNewBackground;
    
    self.tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    self.vScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.tbTop.maxY, self.width, self.height - 64)];
    [self.vScroll setBackgroundColor:kColorClear];
    
    UITapGestureRecognizer *tapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapOne.numberOfTapsRequired = 1;
    tapOne.numberOfTouchesRequired = 1;
    tapOne.delegate = self;
    [self.vScroll addGestureRecognizer:tapOne];
    
    UILabel *labHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 45)];
    [labHeader setBackgroundColor:[UIColor clearColor]];
    [labHeader setTextColor:kColorBlue];
    [labHeader setFont:kFontSmall];
    [labHeader setTextAlignment:NSTextAlignmentCenter];
    [labHeader setText:@"汽车之家出品，支持汽车之家账号登录"];
    [self.vScroll addSubview:labHeader];
    
    self.vField = [self createFieldView:CGRectMake(0, labHeader.maxY, self.width, 50*2+kLinePixel*3)];
    [self.vScroll addSubview:self.vField];
    
    self.vVerify = [self createVerifyView:CGRectMake(0, self.vField.maxY+20, self.width, 50+kLinePixel*2)];
    self.vVerify.hidden = YES;
    [self.vScroll addSubview:self.vVerify];
    
    self.btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnLogin setFrame:CGRectMake(10, self.vField.maxY+20, self.width-20, 44)];
    [self.btnLogin setTitle:@"登录" forState:UIControlStateNormal];
    [self.btnLogin setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self.btnLogin setBackgroundImage:[OMG imageWithColor:kColorBlue andSize:self.btnLogin.bounds.size] forState:UIControlStateNormal];
    [self.btnLogin setBackgroundImage:[OMG imageWithColor:kColorBlueH andSize:self.btnLogin.bounds.size] forState:UIControlStateSelected];
    [self.btnLogin setBackgroundImage:[OMG imageWithColor:kColorBlueH andSize:self.btnLogin.bounds.size] forState:UIControlStateHighlighted];
    [self.btnLogin.titleLabel setFont:kFontLarge1_b];
    [self.btnLogin.layer setCornerRadius:3.0];
    [self.btnLogin.layer setMasksToBounds:YES];
    [self.btnLogin addTarget:self action:@selector(onClickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.vScroll addSubview:self.btnLogin];
    
    self.btnReg = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnReg setFrame:CGRectMake(self.width-85-10, self.btnLogin.maxY+12, 85, 30)];
    [self.btnReg setTitle:@"个人免费注册" forState:UIControlStateNormal];
    [self.btnReg setTitleColor:kColorBlue forState:UIControlStateNormal];
    [self.btnReg setTitleColor:kColorBlueH forState:UIControlStateSelected];
    [self.btnReg setTitleColor:kColorBlueH forState:UIControlStateHighlighted];
    [self.btnReg.titleLabel setFont:kFontNormal];
//    [self.btnReg setBackgroundColor:kColorOrange];
    [self.btnReg addTarget:self action:@selector(onClickRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.vScroll addSubview:self.btnReg];
    
    if (self.loginType == UCLoginClientTypeSaleCar) {
        self.btnSaleCar = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnSaleCar setFrame:CGRectMake(10, self.btnReg.maxY + 10, self.width-20, 44)];
        [self.btnSaleCar setTitle:@"个人手机号快速发车" forState:UIControlStateNormal];
        [self.btnSaleCar setTitleColor:kColorWhite forState:UIControlStateNormal];
        [self.btnSaleCar setBackgroundImage:[OMG imageWithColor:kColorNeWGreen andSize:self.btnSaleCar.bounds.size] forState:UIControlStateNormal];
        [self.btnSaleCar setBackgroundImage:[OMG imageWithColor:kColorNewGreenH andSize:self.btnSaleCar.bounds.size] forState:UIControlStateSelected];
        [self.btnSaleCar setBackgroundImage:[OMG imageWithColor:kColorNewGreenH andSize:self.btnSaleCar.bounds.size] forState:UIControlStateHighlighted];
        [self.btnSaleCar.titleLabel setFont:kFontLarge_b];
        [self.btnSaleCar.layer setCornerRadius:3.0];
        [self.btnSaleCar.layer setMasksToBounds:YES];
        [self.btnSaleCar addTarget:self action:@selector(onClickSaleCarButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.vScroll addSubview:self.btnSaleCar];
        
        //设置 scrollview 的 contentsize
        _orignalContentSize = CGSizeMake(self.width, self.btnSaleCar.maxY);
        [self.vScroll setContentSize:self.orignalContentSize];

    }
    else{
        //设置 scrollview 的 contentsize
        _orignalContentSize = CGSizeMake(self.width, self.btnReg.maxY);
        [self.vScroll setContentSize:self.orignalContentSize];
    }
    
    //add subviews
    [self addSubview:self.tbTop];
    [self addSubview:self.vScroll];
    
    
    //只有在个人中心登录时显示联系电话
    if (self.loginType == UCLoginClientTypeNormal) {
        UCContactUsView *vContactUS = [[UCContactUsView alloc] initWithFrame:CGRectMake(0, self.height - 80, self.width, 80) withStatementArray:@[@"个人登录相关问题请致电", @"二手车之家服务电话：010-56851369"] andPhoneNumber:@"01056851369"];
        [self addSubview:vContactUS];
        
    }
    
    
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    if (self.loginType == UCLoginClientTypeNormal) {
        [vTopBar.btnTitle setTitle:@"个人登录" forState:UIControlStateNormal];
    }
    else{
        [vTopBar.btnTitle setTitle:@"个人卖车" forState:UIControlStateNormal];
    }
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
    [self.tfAccount setPlaceholder:@"手机号／邮箱／用户名"];
    [self.tfAccount setTextColor:kColorNewGray1];
    [self.tfAccount setFont:kFontLarge];
    [self.tfAccount setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.tfAccount setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.tfAccount setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.tfAccount setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.tfAccount setDelegate:self];
    [self.tfAccount setReturnKeyType:UIReturnKeyNext];
//#warning 打包前删除 test个人登录
//    self.tfAccount.text = @"15910552565";
//    self.tfAccount.text = @"超级跑车代购";
    
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
//#warning 打包前删除 test个人登录
//    self.tfPassword.text = @"111qqq";
//    self.tfPassword.text = @"123$qweR";
    
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

/** 验证码 view **/
- (UIView *)createVerifyView:(CGRect)frame{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = kColorWhite;
    
    UIView *hLine1 = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, frame.size.width, kLinePixel) color:kColorNewLine];
    
    UILabel *labVerify = [[UILabel alloc] initWithFrame:CGRectMake(10, kLinePixel, 60, 50)];
    [labVerify setText:@"验证码："];
    [labVerify setFont:kFontLarge];
    [labVerify setTextColor:kColorNewGray1];
    
    self.tfVerify = [[UITextField alloc] initWithFrame:CGRectMake(labVerify.maxX, kLinePixel, self.width - 175, 50)];
    [self.tfVerify setFont:kFontLarge];
    [self.tfVerify setTextColor:kColorNewGray1];
    [self.tfVerify setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.tfVerify setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.tfVerify setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.tfVerify setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.tfVerify setReturnKeyType:UIReturnKeyDone];
    [self.tfVerify setKeyboardType:UIKeyboardTypeASCIICapable];
    [self.tfVerify setBorderStyle:UITextBorderStyleNone];
    [self.tfVerify setClearsOnBeginEditing:YES];
    [self.tfVerify setDelegate:self];
    
    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(self.tfVerify.maxX, kLinePixel+10, kLinePixel, 30) color:kColorNewLine];
    
    self.ivVerify = [[UIImageView alloc] initWithFrame:CGRectMake(vLine.maxX + 15, kLinePixel+10, 42, 30)];
    [self.ivVerify setBackgroundColor:kColorWhite];
    
    UIButton *btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRefresh setFrame:CGRectMake(self.ivVerify.maxX+5, kLinePixel+10, 30, 30)];
    [btnRefresh setImage:[UIImage imageNamed:@"verification_refresh"] forState:UIControlStateNormal];
    [btnRefresh addTarget:self action:@selector(refreshVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *hLine2 = [[UIView alloc] initLineWithFrame:CGRectMake(0, view.height-kLinePixel, frame.size.width, kLinePixel) color:kColorNewLine];
    
    [view addSubview:hLine1];
    [view addSubview:labVerify];
    [view addSubview:self.tfVerify];
    [view addSubview:vLine];
    [view addSubview:self.ivVerify];
    [view addSubview:btnRefresh];
    [view addSubview:hLine2];
    return view;
}

/** 显示验证码框 **/
- (void)showVerifyFieldWithCode:(NSString*)code{
    
    [self decodeBase64ImageFromCode:code];
    
    [self.btnLogin setTitle:@"验证并登录" forState:UIControlStateNormal];
    
    self.vVerify.hidden = NO;
    
    CGRect btnLoginFrame = self.btnLogin.frame;
    btnLoginFrame.origin.y = self.vVerify.maxY+20;
    [self.btnLogin setFrame:btnLoginFrame];
    
    CGRect btnRegFrame = self.btnReg.frame;
    btnRegFrame.origin.y = self.btnLogin.maxY+20;
    [self.btnReg setFrame:btnRegFrame];
    
    if (self.loginType == UCLoginClientTypeNormal) {
        _orignalContentSize = CGSizeMake(self.width, self.btnReg.maxY);
        [self.vScroll setContentSize:self.orignalContentSize];
    }
    else{
        CGRect btnSaleCarFrame = self.btnSaleCar.frame;
        btnSaleCarFrame.origin.y = self.btnReg.maxY+20;
        [self.btnSaleCar setFrame:btnSaleCarFrame];
        
        _orignalContentSize = CGSizeMake(self.width, self.btnSaleCar.maxY);
        [self.vScroll setContentSize:self.orignalContentSize];
    }
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

- (void)refreshVerifyCode:(id)sender{
    self.apiGetCode = [[APIHelper alloc] init];
    __weak typeof(self) weakSelf = self;
    
    [self.apiGetCode setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 取消请求
            if (error.code == ConnectionStatusCancel) {
                [[AMToastView toastView] hide];
            }
            // 其他错误
            else{
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        
        if (apiHelper.data.length > 0) {
            
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                
                NSString *message = nil;
                if (mBase.returncode == 0) {
                    NSString *code = [mBase.result objectForKey:@"code"];
                    if(code.length > 0){
                        [weakSelf decodeBase64ImageFromCode:code];
                    }
                }
                else{
                    message = mBase.message;
                }
                
                if (message)
                    [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                else
                    [[AMToastView toastView] hide];
            }
        }
    }];
    [self.apiGetCode getLoginVerifyCode];
}

- (void)onClickLoginButton:(id)sender{
    
    if (![OMG isValidClick])
        return;
    
    if ([self.delegate respondsToSelector:@selector(UCLoginClientView:onClickLoginButton:)]) {
        [self.delegate UCLoginClientView:self onClickLoginButton:sender];
    }
    
    [self endEditing:YES];
    
    if ([self.tfAccount.text trim].length == 0 || self.tfPassword.text.length == 0) {
        [[AMToastView toastView] showMessage:@"请输入用户名或密码" icon:kImageRequestError duration:AMToastDurationNormal];
    }
    else{
        
        NSString *verifyCode = nil;
        if (self.vVerify.hidden == NO) {
            verifyCode  = self.tfVerify.text;
        }
        
        
        [[UserLogInOutHelper userHelper] clientLoginWithUserName:[self.tfAccount.text trim] password:self.tfPassword.text verifyCode:verifyCode returnBlock:^(BOOL success, NSInteger returnCode, NSString *message, UserInfoModel *userInfoModel) {
            
//            AMLog(@"login return code: %d \nmodel: %@", returnCode, userInfoModel);
            if (returnCode == 0) {
                
                [self showNeedToSYNCfavoritesAlert];
                
            }
            else{
                if (returnCode == 2010202) {
                    if (self.vVerify.hidden == NO) {
                        [self decodeBase64ImageFromCode:userInfoModel.code];
                    }
                    else{
                        [self showVerifyFieldWithCode:userInfoModel.code];
                    }
                }
                
                if ([self.delegate respondsToSelector:@selector(UCLoginClientView:loginSuccess:NeedSNYC:SYNCSuccess:)]){
                    [self.delegate UCLoginClientView:self loginSuccess:NO NeedSNYC:NO SYNCSuccess:NO];
                }
            }
        }];
    }
    
}


- (void)onClickRegisterButton:(id)sender{
    
    if (![OMG isValidClick])
        return;
    
    [UMStatistics event:c_4_0__login_personregistration];
    
    [self endEditing:YES];
    UCRegisterClientView *vRegister = [[UCRegisterClientView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds];
    [[MainViewController sharedVCMain] openView:vRegister animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

- (void)onClickSaleCarButton:(id)sender{
    if (![OMG isValidClick])
        return;
    [UMStatistics event:c_4_0_salecar_peronal_quick];
    [self endEditing:YES];
    
    if ([self.delegate respondsToSelector:@selector(UCLoginClientViewExpressSaleCar:)]) {
        [self.delegate UCLoginClientViewExpressSaleCar:self];
    }
}

#pragma mark - 收藏, 提示
-(void)showNeedToSYNCfavoritesAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"是否同步收藏、订阅及发布的车源信息，同步后收藏车源及订阅车源数据将清除，发布车源不清除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"同步", nil];
    alert.delegate = self;
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [UMStatistics event:c_4_0_my_person_noupload];
        [AMCacheManage setSYNCclientCarNeeded:NO];
        [AMCacheManage setSYNCclientSubscriptionNeeded:NO];
        [AMCacheManage setSYNCclientFavoritesNeeded:NO];
        
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveUp];
        
        if ([self.delegate respondsToSelector:@selector(UCLoginClientView:loginSuccess:NeedSNYC:SYNCSuccess:)]){
            [self.delegate UCLoginClientView:self loginSuccess:YES NeedSNYC:NO SYNCSuccess:NO];
        }
    }
    else{
        [UMStatistics event:c_4_0_my_person_confirmupload];
        [AMCacheManage setSYNCclientCarNeeded:YES];
        [AMCacheManage setSYNCclientSubscriptionNeeded:YES];
        [AMCacheManage setSYNCclientFavoritesNeeded:YES];
        [self startSYNCAll];
    }
}

#pragma mark - 同步收藏方法
- (void)startSYNCAll{
    
    [UserLogInOutHelper clientSyncCar];
    [UserLogInOutHelper clientSyncSubscription];
    
    [[UserLogInOutHelper userHelper] clientSyncFavoritesWithFinishBlock:^(BOOL success) {
        if (success) {
            
            //收藏成功后删掉数据库
            
            NSString *fileName = @"Cache.sqlite";
            NSString *filePath = [AMCacheManage getCacheFilePath:kCacheDataDir fileName:fileName];
            NSFileManager *fileMan = [NSFileManager defaultManager];
            // 已存在缓存数据库
            if ([fileMan fileExistsAtPath:filePath]) {
                NSError *error;
                if ([fileMan removeItemAtPath:filePath error:&error]) {
                    
                    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveUp];
                    
                    if ([self.delegate respondsToSelector:@selector(UCLoginClientView:loginSuccess:NeedSNYC:SYNCSuccess:)]){
                        [self.delegate UCLoginClientView:self loginSuccess:YES NeedSNYC:YES SYNCSuccess:YES];
                    }
                    
                }
            }
        }
        else{
            [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveUp];
            
            if ([self.delegate respondsToSelector:@selector(UCLoginClientView:loginSuccess:NeedSNYC:SYNCSuccess:)]){
                [self.delegate UCLoginClientView:self loginSuccess:YES NeedSNYC:YES SYNCSuccess:NO];
            }
        }
    }];
    
}



#pragma mark - keyboard did show & hide
- (void)keyboardWillShow:(NSNotification *)notification {
    // 获取键盘高度 和 动画速度

    keyboardRect = [self getKeyboardRect:notification];
    keyboardRectY = self.height - keyboardRect.size.height;
    
    animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    
    CGSize vScrollSize = self.orignalContentSize; //先重置为原本的高度再扩展, 防止加多次扩展高度
    vScrollSize.height += (keyboardRect.size.height+10);
    [self.vScroll setContentSize:vScrollSize];
    
    
    if (self.vVerify.hidden == NO && self.tfVerify.isEditing && self.vVerify.maxY+64 > keyboardRectY) {
        
        CGFloat offset = self.vVerify.maxY - keyboardRect.origin.y;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:animationCurve];
        [UIView setAnimationDuration:animationDuration];
        
        [self.vScroll setContentOffset:CGPointMake(0, -offset)];
        
        [UIView commitAnimations];
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification{
    keyboardRect = [self getKeyboardRect:notification];
    keyboardRectY = self.height - keyboardRect.size.height;
    animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGSize vScrollSize = self.orignalContentSize;
    [self.vScroll setContentSize:vScrollSize];
    
    if (self.vVerify.hidden == NO && self.vVerify.maxY+64 > keyboardRectY) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
        [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
        
        [self.vScroll setContentOffset:CGPointMake(0, 0)];
        
        [UIView commitAnimations];
    }
}

- (CGRect)getKeyboardRect:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    return [value CGRectValue];
}

#pragma mark - uitextfield delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    currentField = textField;
    if (self.vVerify.hidden) {
        [self.tfPassword setReturnKeyType:UIReturnKeyDone];
    }
    else{
        [self.tfPassword setReturnKeyType:UIReturnKeyNext];
    }
    
    if (self.tfVerify == textField && keyboardRect.size.height>0) {
        
        AMLog(@"%f %f", self.vVerify.maxY, keyboardRect.origin.y);
        
        
        if (self.vVerify.hidden == NO && self.tfVerify.isEditing && self.vVerify.maxY+64 > keyboardRect.origin.y) {
            
            CGFloat offset = self.vVerify.maxY - keyboardRect.origin.y;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationCurve:animationCurve];
            [UIView setAnimationDuration:animationDuration];
            
            [self.vScroll setContentOffset:CGPointMake(0, -offset)];
            
            [UIView commitAnimations];
        }
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.tfVerify == textField ){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:animationCurve];
        [UIView setAnimationDuration:animationDuration];
        
        [self.vScroll setContentOffset:CGPointMake(0, 0)];
        
        [UIView commitAnimations];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == self.tfAccount) {
        [self.tfPassword becomeFirstResponder];
    }
    else if(textField == self.tfPassword){
        if (self.vVerify.isHidden == NO) {
            [self.tfVerify becomeFirstResponder];
        } else {
            [self onClickLoginButton:nil];
        }
    }
    else{
        [self onClickLoginButton:nil];
    }
    
    return true;
}

#pragma mark - UIGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView *view = [touch view];
    
    if ([view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - 解码 base64 图片
- (void)decodeBase64ImageFromCode:(NSString*)code{
    NSData *decodedImageData;
    if (IOS7_OR_LATER) {
        decodedImageData = [[NSData alloc] initWithBase64EncodedString:code options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    else{
        decodedImageData = [[NSData alloc] initWithBase64Encoding:code];
    }
    
    if (decodedImageData) {
        UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
        [self.ivVerify setImage:decodedImage];
    }
}


#pragma mark - dealloc
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}


@end
