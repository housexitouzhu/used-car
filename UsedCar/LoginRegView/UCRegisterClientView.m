//
//  UCRegisterClientView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-9-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCRegisterClientView.h"
#import "UCTopBar.h"
#import "UCContactUsView.h"
#import "CoreTextView.h"
#import "SHLUnderLineButton.h"
#import "NSString+Util.h"
#import "UCRegisterClientAgreementView.h"
#import "UCRegisterClientSuccessView.h"
#import "APIHelper.h"
#import "UserLogInOutHelper.h"
#import "UCRegisterClientModel.h"
#import "AMCacheManage.h"

#define kTopBarHeight 64
#define kOffset 75

@interface UCRegisterClientView ()<UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    BOOL agreed;
    UITextField *currentField;
    CGRect keyboardRect;
    CGFloat keyboardRectY;
    NSInteger showAnimationCurve;
    NSInteger hideAnimationCurve;
    CGFloat animationDuration;
    NSInteger count60;
    BOOL isKeyboardShowing;
}

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UIScrollView *vScroll;
@property (nonatomic, strong) UILabel *labUserName;
@property (nonatomic, strong) UILabel *labMobile;
@property (nonatomic, strong) UILabel *labCode;
@property (nonatomic, strong) UILabel *labPwd;
@property (nonatomic, strong) UILabel *labPwd2;
@property (nonatomic, strong) UITextField *tfUserName;
@property (nonatomic, strong) UITextField *tfMobile;
@property (nonatomic, strong) UITextField *tfPwd;
@property (nonatomic, strong) UITextField *tfPwd2;
@property (nonatomic, strong) UITextField *tfCode;
@property (nonatomic, strong) UIButton *btnGetCode;
@property (nonatomic, strong) UIButton *btnAgree;
@property (nonatomic, strong) UIButton *btnSubmit;
@property (nonatomic, strong) UCContactUsView *vContactUS;
@property (nonatomic, assign, readonly) CGSize orignalContentSize;

@property (nonatomic, strong) NSTimer *timerCount60;
@property (nonatomic, strong) APIHelper *apiHelper;
@property (nonatomic, strong) UserLogInOutHelper *registerHelper;
@end

@implementation UCRegisterClientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [UMStatistics event:pv_4_0__login_personregistration];
        UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
        [UMSAgent postEvent:login_personregistration_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:mUserInfo.userid, @"userid#4", nil]];
        // Initialization code
        [self initView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
        
    }
    return self;
}


- (void)initView{
    
    self.backgroundColor = kColorNewBackground;
    self.tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    self.vScroll = [self createRegisterScrollViewWithFrame:CGRectMake(0, self.tbTop.maxY, self.width, self.height-64)];
    [self.vScroll setBackgroundColor:kColorClear];
    
    UITapGestureRecognizer *tapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapOne.numberOfTapsRequired = 1;
    tapOne.numberOfTouchesRequired = 1;
    tapOne.delegate = self;
    [self.vScroll addGestureRecognizer:tapOne];
    
    [self addSubview:self.tbTop];
    [self addSubview:self.vScroll];
    
    self.vContactUS = [[UCContactUsView alloc] initWithFrame:CGRectMake(0, self.vScroll.contentSize.height > self.vScroll.height ? self.btnSubmit.maxY+20 : _vScroll.height - 80, self.width, 80) withStatementArray:@[@"您注册过程中遇到任何问题",@"请拨打客服电话：4000-111-168"] andPhoneNumber:@"4000111168"];
    [self.vScroll addSubview:self.vContactUS];
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

- (UIScrollView *)createRegisterScrollViewWithFrame:(CGRect)frame{
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:frame];
    
    //-------//
    UIView *hLine1 = [[UIView alloc] initLineWithFrame:CGRectMake(0, 20, self.width, kLinePixel) color:kColorNewLine];
    [scroll addSubview:hLine1];
    
    //用户名行
    UIView *accView = [[UIView alloc] initWithFrame:CGRectMake(0, hLine1.maxY, self.width, 50)];
    accView.backgroundColor = kColorWhite;
    
    self.labUserName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 50)];
    self.labUserName.text = @"用户名：";
    self.labUserName.textColor = kColorNewGray1;
    self.labUserName.font = kFontLarge;
    
    self.tfUserName = [[UITextField alloc] initWithFrame:CGRectMake(self.labUserName.maxX, 0, self.width-self.labUserName.maxX-10, 50)];
    [self.tfUserName setPlaceholder:@"4-20个字符,汉字/字母/数字/下划线"];
    [self.tfUserName setTextColor:kColorNewGray1];
    [self.tfUserName setFont:kFontLarge];
    [self.tfUserName setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.tfUserName setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.tfUserName setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.tfUserName setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.tfUserName setDelegate:self];
    [self.tfUserName setReturnKeyType:UIReturnKeyNext];
    [self.tfUserName setTag:100];
    
    [accView addSubview:self.labUserName];
    [accView addSubview:self.tfUserName];
    [scroll addSubview:accView];
    
    UIView *hLine2 = [[UIView alloc] initLineWithFrame:CGRectMake(0, accView.maxY, self.width, kLinePixel) color:kColorNewLine];
    [scroll addSubview:hLine2];
    //-------//
    
    //-------//
    UIView *hLine3 = [[UIView alloc] initLineWithFrame:CGRectMake(0, hLine2.maxY+20, self.width, kLinePixel) color:kColorNewLine];
    [scroll addSubview:hLine3];
    
    //手机号行
    UIView *mobileView = [[UIView alloc] init];
    self.labMobile = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 50)];
    self.labMobile.text = @"手机号：";
    self.labMobile.textColor = kColorNewGray1;
    self.labMobile.font = kFontLarge;
    [mobileView addSubview:self.labMobile];
    
    self.tfMobile = [[UITextField alloc] initWithFrame:CGRectMake(self.labMobile.maxX, 0, self.width-self.labMobile.maxX-10, 50)];
    [self.tfMobile setTextColor:kColorNewGray1];
    [self.tfMobile setFont:kFontLarge];
    [self.tfMobile setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.tfMobile setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.tfMobile setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.tfMobile setKeyboardType:UIKeyboardTypeNumberPad];
    [self.tfMobile setDelegate:self];
    [self.tfMobile setReturnKeyType:UIReturnKeyNext];
    [self.tfMobile setTag:101];
    [mobileView addSubview:self.tfMobile];
    
    UIView *hLine4 = [[UIView alloc] initLineWithFrame:CGRectMake(10, self.labMobile.maxY, self.width-10, kLinePixel) color:kColorNewLine];
    [mobileView addSubview:hLine4];
    
    self.labCode = [[UILabel alloc] initWithFrame:CGRectMake(10, hLine4.maxY, 60, 50)];
    self.labCode.text= @"验证码：";
    self.labCode.textColor = kColorNewGray1;
    self.labCode.font = kFontLarge;
    [mobileView addSubview:self.labCode];
    
    self.btnGetCode = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnGetCode setFrame:CGRectMake(self.width - 10 - 75 , hLine4.maxY + 10, 75, 30)];
    [self.btnGetCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.btnGetCode setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self.btnGetCode setBackgroundImage:[OMG imageWithColor:kColorBlue andSize:self.btnGetCode.bounds.size] forState:UIControlStateNormal];
    [self.btnGetCode setBackgroundImage:[OMG imageWithColor:kColorBlueH andSize:self.btnGetCode.bounds.size] forState:UIControlStateSelected];
    [self.btnGetCode setBackgroundImage:[OMG imageWithColor:kColorBlueH andSize:self.btnGetCode.bounds.size] forState:UIControlStateHighlighted];
    [self.btnGetCode.titleLabel setFont:kFontSmall];
    [self.btnGetCode.layer setCornerRadius:3.0];
    [self.btnGetCode.layer setMasksToBounds:YES];
    [self.btnGetCode addTarget:self action:@selector(onClickGetCodeButton:) forControlEvents:UIControlEventTouchUpInside];
    [mobileView addSubview:self.btnGetCode];
    
    self.tfCode = [[UITextField alloc] initWithFrame:CGRectMake(self.labCode.maxX, hLine4.maxY, self.width - self.labCode.maxX - self.btnGetCode.width - 10, 50)];
    [self.tfCode setTextColor:kColorNewGray1];
    [self.tfCode setFont:kFontLarge];
    [self.tfCode setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.tfCode setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.tfCode setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.tfCode setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.tfCode setReturnKeyType:UIReturnKeyNext];
    [self.tfCode setKeyboardType:UIKeyboardTypeNumberPad];
    [self.tfCode setDelegate:self];
    [self.tfCode setTag:102];
    [mobileView addSubview:self.tfCode];
    
    [mobileView setFrame:CGRectMake(0, hLine3.maxY, self.width, self.labCode.maxY)];
    mobileView.backgroundColor = kColorWhite;

    [scroll addSubview:mobileView];
    
    UIView *hLine5 = [[UIView alloc] initLineWithFrame:CGRectMake(0, mobileView.maxY, self.width, kLinePixel) color:kColorNewLine];
    [scroll addSubview:hLine5];
    //-------//
    
    //-------//
    UIView *hLine6 = [[UIView alloc] initLineWithFrame:CGRectMake(0, hLine5.maxY+20, self.width, kLinePixel) color:kColorNewLine];
    [scroll addSubview:hLine6];
    
    //密码行 确认密码行
    UIView *pwdView = [[UIView alloc] initWithFrame:CGRectMake(0, hLine6.maxY, self.width, 100+kLinePixel)];
    pwdView.backgroundColor = kColorWhite;
    
    self.labPwd = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 50)];
    self.labPwd.text = @"密   码：";
    self.labPwd.textColor = kColorNewGray1;
    self.labPwd.font = kFontLarge;
    
    self.tfPwd = [[UITextField alloc] initWithFrame:CGRectMake(self.labPwd.maxX, 0, self.width-self.labPwd.maxX-10, 50)];
    [self.tfPwd setTextColor:kColorNewGray1];
    [self.tfPwd setFont:kFontLarge];
    [self.tfPwd setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.tfPwd setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.tfPwd setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.tfPwd setSecureTextEntry:YES];
    [self.tfPwd setDelegate:self];
    [self.tfPwd setReturnKeyType:UIReturnKeyNext];
    [self.tfPwd setTag:103];
    
    [pwdView addSubview:self.labPwd];
    [pwdView addSubview:self.tfPwd];
    
    UIView *hLine7 = [[UIView alloc] initLineWithFrame:CGRectMake(10, self.labPwd.maxY, self.width - 10, kLinePixel) color:kColorNewLine];
    [pwdView addSubview:hLine7];
    
    
    self.labPwd2 = [[UILabel alloc] initWithFrame:CGRectMake(10, hLine7.maxY, 75, 50)];
    self.labPwd2.text = @"确认密码：";
    self.labPwd2.textColor = kColorNewGray1;
    self.labPwd2.font = kFontLarge;
    
    self.tfPwd2 = [[UITextField alloc] initWithFrame:CGRectMake(self.labPwd2.maxX, hLine7.maxY, self.width-self.labPwd2.maxX-10, 50)];
    [self.tfPwd2 setTextColor:kColorNewGray1];
    [self.tfPwd2 setFont:kFontLarge];
    [self.tfPwd2 setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.tfPwd2 setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.tfPwd2 setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.tfPwd2 setSecureTextEntry:YES];
    [self.tfPwd2 setDelegate:self];
    [self.tfPwd2 setReturnKeyType:UIReturnKeyDone];
    [self.tfPwd2 setTag:104];
    
    [pwdView addSubview:self.labPwd2];
    [pwdView addSubview:self.tfPwd2];
    
    [scroll addSubview:pwdView];
    
    UIView *hLine8 = [[UIView alloc] initLineWithFrame:CGRectMake(0, pwdView.maxY, self.width, kLinePixel) color:kColorNewLine];
    [scroll addSubview:hLine8];
    
    agreed = YES;
    self.btnAgree = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnAgree setFrame:CGRectMake(5, hLine8.maxY+15, 25, 25)];
    [self.btnAgree setImage:[UIImage imageNamed:@"registration_agree"] forState:UIControlStateNormal];
    [self.btnAgree addTarget:self action:@selector(onClickAgreeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [scroll addSubview:self.btnAgree];
    
    UILabel *labDesc = [[UILabel alloc] initWithFrame:CGRectMake(self.btnAgree.maxX+5, hLine8.maxY+20+2, 12*7, 12)];
    labDesc.text = @"我已阅读并同意";
    labDesc.backgroundColor = kColorClear;
    labDesc.textColor = [UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
    labDesc.font = kFontSmall;
    
    [scroll addSubview:labDesc];
    
    
    SHLUnderLineButton *btnAgreement = [SHLUnderLineButton buttonWithType:UIButtonTypeCustom];
    [btnAgreement setFrame:CGRectMake(labDesc.maxX, hLine8.maxY+12.5, 12*9, 30)];
    [btnAgreement.titleLabel setFont:kFontSmall];
    [btnAgreement setTitle:@"二手车之家用户协议" forState:UIControlStateNormal];
    [btnAgreement setTitleColor:kColorBlue forState:UIControlStateNormal];
    [btnAgreement setTitleColor:kColorBlueH forState:UIControlStateHighlighted];
    [btnAgreement setTitleColor:kColorBlueH forState:UIControlStateSelected];
    [btnAgreement addTarget:self action:@selector(onClickAgreementButton:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:btnAgreement];
    
    
    self.btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnSubmit setFrame:CGRectMake(10, labDesc.maxY+20, scroll.width - 10 * 2, 44)];
    [self.btnSubmit setTitle:@"确认并提交" forState:UIControlStateNormal];
    [self.btnSubmit setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self.btnSubmit setBackgroundImage:[OMG imageWithColor:kColorBlue andSize:self.btnSubmit.bounds.size] forState:UIControlStateNormal];
    [self.btnSubmit setBackgroundImage:[OMG imageWithColor:kColorBlueH andSize:self.btnSubmit.bounds.size] forState:UIControlStateSelected];
    [self.btnSubmit setBackgroundImage:[OMG imageWithColor:kColorBlueH andSize:self.btnSubmit.bounds.size] forState:UIControlStateHighlighted];
    [self.btnSubmit.titleLabel setFont:kFontLarge1_b];
    [self.btnSubmit.layer setCornerRadius:3.0];
    [self.btnSubmit.layer setMasksToBounds:YES];
    [self.btnSubmit addTarget:self action:@selector(onClickSubmitButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [scroll addSubview:self.btnSubmit];
    
    
    //根据屏幕高度不同, 小于480的屏幕, 最下方的电话栏是加在 scrollview 里的.所以要对 scrollview 的 content size height 做处理, 能滑出拨打电话的提示内容
    CGFloat contentSizeH = self.btnSubmit.maxY+80;
    
    if (SCREEN_HEIGHT <= 480)
        contentSizeH += 20;
    
    _orignalContentSize = CGSizeMake(self.width, contentSizeH);
    [scroll setContentSize:self.orignalContentSize];
    
    return scroll;
}

#pragma mark - keyboard did show & hide
- (void)keyboardWillShow:(NSNotification *)notification {
    AMLog(@"keyboardWillShow");
    
    // 获取键盘高度 和 动画速度
    keyboardRect = [self getKeyboardRect:notification];
    keyboardRectY = self.height - keyboardRect.size.height;
    
    showAnimationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGSize vScrollSize = self.orignalContentSize;
    vScrollSize.height += keyboardRect.size.height;
    [self.vScroll setContentSize:vScrollSize];
    
    if(currentField.superview.maxY + 64 + kOffset > keyboardRectY){
        CGFloat offset = currentField.superview.maxY + 64 + kOffset -  keyboardRectY;
        
        if (currentField.tag == 103) {
            offset -= 50;
        }
        else if (currentField.tag == 104) {
            offset += 25;
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:showAnimationCurve];
        [UIView setAnimationDuration:animationDuration];
        [self.vScroll setContentOffset:CGPointMake(0, offset)];
        [UIView commitAnimations];
    }
    
    
    isKeyboardShowing = YES;
}


- (void)keyboardWillHide:(NSNotification *)notification{
    
    keyboardRect = [self getKeyboardRect:notification];
    keyboardRectY = self.height - keyboardRect.size.height;
    hideAnimationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGSize vScrollSize = self.orignalContentSize;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:hideAnimationCurve];
    [UIView setAnimationDuration:animationDuration];
    [self.vScroll setContentSize:vScrollSize];
    [UIView commitAnimations];
    
    isKeyboardShowing = NO;
    
}



- (CGRect)getKeyboardRect:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    return [value CGRectValue];
}

#pragma mark - uitextfield delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (isKeyboardShowing && textField.tag > 101 && textField.superview.maxY+64+kOffset > keyboardRectY)
    {
        AMLog(@"%@ %f", textField.superview, textField.superview.maxY);
        CGFloat offset = textField.superview.maxY + 64 + kOffset - keyboardRect.origin.y;
        
        if(textField.tag > 102){
            if (textField.tag == 103) {
                offset -= 50;
            }
            else if(textField.tag == 104){
                offset += 25;
            }
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            self.vScroll.contentOffset = CGPointMake(0, offset);
        }];
        
    }
    else if(isKeyboardShowing){
        [UIView animateWithDuration:0.25 animations:^{
            self.vScroll.contentOffset = CGPointMake(0, 0);
        }];
    }
    currentField = textField;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:animationDuration];
//    [self.vScroll setContentOffset:CGPointMake(0, 0)];
//    [UIView commitAnimations];
    
    if(![self.tfPwd.text isEqualToString:self.tfPwd2.text] && textField == self.tfPwd2){
        [[AMToastView toastView] showMessage:@"新密码输入不一致" icon:kImageRequestError duration:AMToastDurationNormal];
        self.labPwd.textColor = kColorNeWRed;
        self.labPwd2.textColor = kColorNeWRed;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == self.tfUserName) {
        [self.tfMobile becomeFirstResponder];
    }
    else if(textField == self.tfMobile){
        [self.tfCode becomeFirstResponder];
    }
    else if (textField == self.tfCode){
        [self.tfPwd becomeFirstResponder];
    }
    else if (textField == self.tfPwd){
        [self.tfPwd2 becomeFirstResponder];
    }
    else{
        [self onClickSubmitButton:nil];
    }
    
    return true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.tag == 101) {
        if (string.length > 0) { //电话号码处限制只能输入数字 用 ascii 码进行限制, 排除 <- 键, backspace 的输入长度是0
            if ([textField.text trim].length == 11 || [string characterAtIndex:0] < 48 || [string characterAtIndex:0] > 57)
            {
                return NO;
            } else {
                return YES;
            }
        }
        else{
            return YES;
        }
    }
    else if(textField.tag == 102){
        if (string.length > 0) {
            if ([textField.text trim].length == 6 || [string characterAtIndex:0] < 48 || [string characterAtIndex:0] > 57)
            {
                return NO;
            } else {
                return YES;
            }
        }
        else{
            return YES;
        }
    }
    else{
        return YES;
    }
    
}

- (void)textFieldDidChanged:(NSNotification*)notification{
    
    if ([notification.object isKindOfClass:[UITextField class]]) {
        UITextField *textField = notification.object;
        
        switch (textField.tag) {
            case 100:
            {
                self.labUserName.textColor = kColorNewGray1;
            }
                break;
            case 101:
            {
                self.labMobile.textColor = kColorNewGray1;
                
            }
                break;
            case 102:
            {
                self.labCode.textColor = kColorNewGray1;
            }
                break;
            case 103:
            {
                self.labPwd.textColor = kColorNewGray1;
                self.labPwd2.textColor = kColorNewGray1;
            }
                break;
            case 104:
            {
                self.labPwd.textColor = kColorNewGray1;
                self.labPwd2.textColor = kColorNewGray1;
            }
                break;
            default:
                break;
        }
        
    }
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

#pragma mark - onClickButton
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [self endEditing:YES];
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

- (void)dismissKeyboard:(id)sender{
    [self endEditing:YES];
}

- (void)onClickAgreeButton:(id)sender{
    if (agreed) {
        [self.btnAgree setImage:[UIImage imageNamed:@"registration_not_agree"] forState:UIControlStateNormal];
        agreed = NO;
    } else {
        [self.btnAgree setImage:[UIImage imageNamed:@"registration_agree"] forState:UIControlStateNormal];
        agreed = YES;
    }
}

- (void)onClickSubmitButton:(id)sender{
    
    if (![OMG isValidClick])
        return;
    
    [UMStatistics event:c_4_0_login_personregistration_submit];
    
    if (![OMG isValidateUserName:[self.tfUserName.text trim]]) {
        [[AMToastView toastView] showMessage:@"请正确填写用户名" icon:kImageRequestError duration:AMToastDurationNormal];
        self.labUserName.textColor = kColorNeWRed;
    }
    else if (![OMG isValidateMobile:[self.tfMobile.text trim]]){
        [[AMToastView toastView] showMessage:@"请正确填写手机号" icon:kImageRequestError duration:AMToastDurationNormal];
        self.labMobile.textColor = kColorNeWRed;
    }
    else if([self.tfCode.text trim].length == 0){
        [[AMToastView toastView] showMessage:@"请获取并填写验证码" icon:kImageRequestError duration:AMToastDurationNormal];
        self.labCode.textColor = kColorNeWRed;
    }
    else if (self.tfPwd.text.length < 6 || self.tfPwd.text.length > 25){
        [[AMToastView toastView] showMessage:@"请正确填写密码" icon:kImageRequestError duration:AMToastDurationNormal];
        self.labPwd.textColor = kColorNeWRed;
    }
    else if(![self.tfPwd.text isEqualToString:self.tfPwd2.text]){
        [[AMToastView toastView] showMessage:@"新密码输入不一致" icon:kImageRequestError duration:AMToastDurationNormal];
        self.labPwd.textColor = kColorNeWRed;
        self.labPwd2.textColor = kColorNeWRed;
    }
    else if (!agreed){
        [[AMToastView toastView] showMessage:@"请先阅读用户协议" icon:kImageRequestError duration:AMToastDurationNormal];
    }
    else {
        
        UCRegisterClientModel *mRegister = [[UCRegisterClientModel alloc] init];
        mRegister.nickname = [self.tfUserName.text trim];
        mRegister.userpwd = self.tfPwd.text;
        mRegister.mobile = self.tfMobile.text;
        mRegister.validecode = [self.tfCode.text trim];
        
        if (!self.registerHelper) {
            self.registerHelper = [[UserLogInOutHelper alloc] init];
        }
        
        [self.registerHelper clientRegisterWithClientModel:mRegister returnBlock:^(BOOL success, NSInteger returnCode) {
            
            if (success) {
                [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveNone];
                UCRegisterClientSuccessView *vRegSuccess = [[UCRegisterClientSuccessView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds];
                [[MainViewController sharedVCMain] openView:vRegSuccess animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
            }
        }];
    }
    
}

- (void)onClickGetCodeButton:(id)sender{
    
    if ([self.tfUserName.text trim].length == 0 || self.tfMobile.text.length == 0) {
        [[AMToastView toastView] showMessage:@"请填写用户名和手机号" icon:kImageRequestError duration:AMToastDurationNormal];
        if ([self.tfUserName.text trim].length == 0) {
            self.labUserName.textColor = kColorNeWRed;
        }
        if (self.tfMobile.text.length == 0) {
            self.labMobile.textColor = kColorNeWRed;
        }
        return;
    }
    
    if (![OMG isValidateUserName:[self.tfUserName.text trim]]) {
        [[AMToastView toastView] showMessage:@"请正确填写用户名" icon:kImageRequestError duration:AMToastDurationNormal];
        self.labUserName.textColor = kColorNeWRed;
    }
    else if (![OMG isValidateMobile:[self.tfMobile.text trim]]){
        [[AMToastView toastView] showMessage:@"请输入正确的手机号" icon:kImageRequestError duration:AMToastDurationNormal];
        self.labMobile.textColor = kColorNeWRed;
    }
    else{
        [self.tfCode becomeFirstResponder];
        [self requestValidateCode];
        [self.btnGetCode setEnabled:NO];
        [self.btnGetCode setTitle:@"60秒后获取" forState:UIControlStateDisabled];
        count60 = 60;
        self.timerCount60 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCountDown) userInfo:nil repeats:YES];
    }
    
}


- (void)onClickAgreementButton:(id)sender{
    
    if (![OMG isValidClick])
        return;
    
    [self endEditing:YES];
    UCRegisterClientAgreementView *vAgreement = [[UCRegisterClientAgreementView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds];
    [[MainViewController sharedVCMain] openView:vAgreement animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
}

- (void)timerCountDown{
    count60 --;
    if (count60 == 0) {
        [self resetBtnGetCode];
    }
    else{
        NSString *title = [NSString stringWithFormat:@"%d秒后获取", count60];
        [self.btnGetCode setTitle:title forState:UIControlStateDisabled];
    }
}

- (void)resetBtnGetCode{
    [self.timerCount60 invalidate];
    [self.btnGetCode setEnabled:YES];
    [self.btnGetCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.btnGetCode setTitle:@"60秒后获取" forState:UIControlStateDisabled];
}

#pragma mark - 获取验证码
- (void)requestValidateCode{
    if (!self.apiHelper) {
        self.apiHelper = [[APIHelper alloc] init];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 取消请求
            if (error.code == ConnectionStatusCancel) {
//                [[AMToastView toastView] hide];验证码发送失败，请稍后重试
                [[AMToastView toastView] showMessage:@"验证码发送失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            }
            // 其他错误
            else{
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            [weakSelf resetBtnGetCode];
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            AMLog(@"mBase.returncode %d", mBase.returncode);
            if (mBase) {
                if (mBase.returncode == 0) {
                    [[AMToastView toastView] showMessage:@"验证码已发送" icon:kImageRequestSuccess duration:AMToastDurationNormal];
                }
                else{
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                    
                    if (mBase.returncode == 2010600) { //已注册的错误码
                        [weakSelf resetBtnGetCode];
                    }
                }
            }
        }
    }];
    
    [self.apiHelper registerClientSendVerifyCodeByUserName:[self.tfUserName.text trim] mobile:self.tfMobile.text];
    
}


#pragma mark - dealloc
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

@end
