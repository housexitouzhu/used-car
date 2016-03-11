//
//  UCVerifyMobileView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-9-19.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCRetrieveCarValidateView.h"
#import "UCTopBar.h"
#import "UCContactUsView.h"
#import "NSString+Util.h"
#import "APIHelper.h"
#import "UserLogInOutHelper.h"

#define timerValue  60

@interface UCRetrieveCarValidateView ()<UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    UITextField *currentField;
    CGRect keyboardRect;
    CGFloat keyboardRectY;
    NSInteger animationCurve;
    CGFloat animationDuration;
    NSInteger count60;
}

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCContactUsView *vContactUS;

@property (nonatomic, strong) UIScrollView *vScroll;
@property (nonatomic, strong) UILabel *labMobile;
@property (nonatomic, strong) UILabel *labCode;
@property (nonatomic, strong) UITextField *tfMobile;
@property (nonatomic, strong) UITextField *tfCode;
@property (nonatomic, strong) UIButton *btnGetCode;
@property (nonatomic, strong) UIButton *btnSubmit;
@property (nonatomic, assign, readonly) CGSize orignalContentSize;

@property (nonatomic, strong) NSTimer *timerCount60;
@property (nonatomic, strong) APIHelper *codeHelper;
@property (nonatomic, strong) UserLogInOutHelper *retrieveHelper;

@end

@implementation UCRetrieveCarValidateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [UMStatistics event:pv_4_0_my_person_phone_login];
        [UMSAgent postEvent:my_person_phone_pv page_name:NSStringFromClass(self.class)];
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
    self.vScroll = [self createScrollViewWithFrame:CGRectMake(0, self.tbTop.maxY, self.width, self.height-64)];
    [self.vScroll setBackgroundColor:kColorClear];
    
    UITapGestureRecognizer *tapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapOne.numberOfTapsRequired = 1;
    tapOne.numberOfTouchesRequired = 1;
    tapOne.delegate = self;
    [self.vScroll addGestureRecognizer:tapOne];
    
    [self addSubview:self.tbTop];
    [self addSubview:self.vScroll];
    
    
    self.vContactUS = [[UCContactUsView alloc] initWithFrame:CGRectMake(0, self.height - 80, self.width, 80) withStatementArray:@[@"您注册过程中遇到任何问题",@"请拨打客服电话：010-56851369"] andPhoneNumber:@"01056851369"];
    [self addSubview:self.vContactUS];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"手机号查找车辆" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"取消"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

- (UIScrollView *)createScrollViewWithFrame:(CGRect)frame{
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:frame];
    
    //-------//
    UIView *hLine1 = [[UIView alloc] initLineWithFrame:CGRectMake(0, 20, self.width, kLinePixel) color:kColorNewLine];
    [scroll addSubview:hLine1];
    
    //用户名行
    UIView *fieldView = [[UIView alloc] initWithFrame:CGRectMake(0, hLine1.maxY, self.width, 100+kLinePixel)];
    fieldView.backgroundColor = kColorWhite;
    
    self.labMobile = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 50)];
    self.labMobile.text = @"手机号：";
    self.labMobile.textColor = kColorNewGray1;
    self.labMobile.font = kFontLarge;
    [fieldView addSubview:self.labMobile];
    
    self. tfMobile = [[UITextField alloc] initWithFrame:CGRectMake(self.labMobile.maxX, 0, self.width-self.labMobile.maxX-10, 50)];
    [self.tfMobile setTextColor:kColorNewGray1];
    [self.tfMobile setFont:kFontLarge];
    [self.tfMobile setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.tfMobile setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.tfMobile setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.tfMobile setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.tfMobile setKeyboardType:UIKeyboardTypeNumberPad];
    [self.tfMobile setDelegate:self];
    [self.tfMobile setTag:100];
    [fieldView addSubview:self.tfMobile];
//#warning 打包前删除
//    self.tfMobile.text = @"15910552565";
    
    UIView *hLine2 = [[UIView alloc] initLineWithFrame:CGRectMake(10, self.labMobile.maxY, self.width - 10, kLinePixel) color:kColorNewLine];
    [fieldView addSubview:hLine2];
    //-------//
    
    self.labCode = [[UILabel alloc] initWithFrame:CGRectMake(10, hLine2.maxY, 60, 50)];
    self.labCode.text= @"验证码：";
    self.labCode.textColor = kColorNewGray1;
    self.labCode.font = kFontLarge;
    [fieldView addSubview:self.labCode];
    
    self.btnGetCode = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnGetCode setFrame:CGRectMake(self.width - 10 - 75 , hLine2.maxY + 10, 75, 30)];
    [self.btnGetCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.btnGetCode setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self.btnGetCode setBackgroundImage:[OMG imageWithColor:kColorBlue andSize:self.btnGetCode.bounds.size] forState:UIControlStateNormal];
    [self.btnGetCode setBackgroundImage:[OMG imageWithColor:kColorBlueH andSize:self.btnGetCode.bounds.size] forState:UIControlStateSelected];
    [self.btnGetCode setBackgroundImage:[OMG imageWithColor:kColorBlueH andSize:self.btnGetCode.bounds.size] forState:UIControlStateHighlighted];
    [self.btnGetCode.titleLabel setFont:kFontSmall];
    [self.btnGetCode.layer setCornerRadius:3.0];
    [self.btnGetCode.layer setMasksToBounds:YES];
    [self.btnGetCode addTarget:self action:@selector(onClickGetCodeButton:) forControlEvents:UIControlEventTouchUpInside];
    [fieldView addSubview:self.btnGetCode];
    
    self.tfCode = [[UITextField alloc] initWithFrame:CGRectMake(self.labCode.maxX, hLine2.maxY, self.width - self.labCode.maxX - self.btnGetCode.width - 10, 50)];
    [self.tfCode setTextColor:kColorNewGray1];
    [self.tfCode setFont:kFontLarge];
    [self.tfCode setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.tfCode setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.tfCode setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.tfCode setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.tfCode setReturnKeyType:UIReturnKeyDone];
    [self.tfCode setKeyboardType:UIKeyboardTypeNumberPad];
    [self.tfCode setDelegate:self];
    [self.tfCode setTag:101];
    [fieldView addSubview:self.tfCode];
//#warning 打包前删除
//    self.tfCode.text = @"286042";
    
    UIView *hLine3 = [[UIView alloc] initLineWithFrame:CGRectMake(0, self.labCode.maxY, self.width, kLinePixel) color:kColorNewLine];
    [fieldView addSubview:hLine3];
    //-------//
    
    
    [scroll addSubview:fieldView];
    
    self.btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnSubmit setFrame:CGRectMake(10, fieldView.maxY+20, scroll.width - 10 * 2, 44)];
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
    
    
    UILabel *labNotice = [[UILabel alloc] initWithFrame:CGRectMake(10, self.btnSubmit.maxY + 20, self.width - 20, 30)];
    labNotice.textColor = kColorNewGray2;
    labNotice.font = kFontSmall;
    labNotice.text = @"快速查找车源为临时使用，关闭二手车App后手机号查找车源将失效。";
    labNotice.backgroundColor = kColorClear;
    labNotice.numberOfLines = 2;
    [scroll addSubview:labNotice];
    
    CGFloat contentSizeH = self.btnSubmit.maxY;
    _orignalContentSize = CGSizeMake(self.width, contentSizeH);
    [scroll setContentSize:self.orignalContentSize];
    
    return scroll;
}


#pragma mark - keyboard did show & hide
- (void)keyboardWillShow:(NSNotification *)notification {
    // 获取键盘高度 和 动画速度
    keyboardRect = [self getKeyboardRect:notification];
    keyboardRectY = self.height - keyboardRect.size.height;
    
    animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGSize vScrollSize = self.orignalContentSize;
    vScrollSize.height += keyboardRect.size.height;
    [self.vScroll setContentSize:vScrollSize];
    
    if(currentField.superview.maxY + 64 > keyboardRectY){
        CGFloat offset = currentField.superview.maxY + 64 -  keyboardRectY;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:animationCurve];
        [UIView setAnimationDuration:animationDuration];
        [self.vScroll setContentOffset:CGPointMake(0, offset)];
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
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [self.vScroll setContentOffset:CGPointMake(0, 0)];
    [UIView commitAnimations];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == self.tfMobile) {
        [self.tfCode becomeFirstResponder];
    }
    else{
        
    }
    
    return true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.tag == 100) {
        if (string.length > 0) {
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
    else if(textField.tag == 101){
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
        
        if(textField == self.tfMobile){
            self.labMobile.textColor = kColorNewGray1;
        }
        else{
            self.labCode.textColor = kColorNewGray1;
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
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveUp];
}

- (void)dismissKeyboard:(id)sender{
    [self endEditing:YES];
}

- (void)onClickSubmitButton:(id)sender{
    [self endEditing:YES];
    
    [UMStatistics event:c_4_0_my_person_phone_submit];
    
    if (![OMG isValidateMobile:[self.tfMobile.text trim]]){
        [[AMToastView toastView] showMessage:@"请正确填写手机号" icon:kImageRequestError duration:AMToastDurationNormal];
        self.labMobile.textColor = kColorNeWRed;
    }
    else if ([self.tfCode.text trim].length == 0 ){
        [[AMToastView toastView] showMessage:@"请正确填写验证码" icon:kImageRequestError duration:AMToastDurationNormal];
        self.labCode.textColor = kColorNeWRed;
    }
    else{
        if (!self.retrieveHelper) {
            self.retrieveHelper = [[UserLogInOutHelper alloc] init];
        }
        
        [self.retrieveHelper carRetrieveWithMobile:[self.tfMobile.text trim] validateCode:[self.tfCode.text trim] returnBlock:^(BOOL success, NSInteger returnCode, UserInfoModel *mUserInfo) {
            if ([self.delegate respondsToSelector:@selector(UCRetrieveCarValidateView:validateSuccess:)]) {
                [self.delegate UCRetrieveCarValidateView:self validateSuccess:success];
            }
            if (success) {
                [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveUp];
            }
        }];
    }
}

- (void)onClickGetCodeButton:(id)sender{
    
    if (![OMG isValidateMobile:[self.tfMobile.text trim]]){
        [[AMToastView toastView] showMessage:@"请正确填写手机号" icon:kImageRequestError duration:AMToastDurationNormal];
        self.labMobile.textColor = kColorNeWRed;
    }
    else{
        [self.tfCode becomeFirstResponder];
        [self requestValidateCode];
        [self.btnGetCode setEnabled:NO];
        [self.btnGetCode setTitle:@"60秒后获取" forState:UIControlStateDisabled];
        count60 = timerValue;
        self.timerCount60 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCountDown) userInfo:nil repeats:YES];
    }
}

- (void)timerCountDown{
    count60 --;
    if (count60 == 0) {
        [self.timerCount60 invalidate];
        [self.btnGetCode setEnabled:YES];
        [self.btnGetCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.btnGetCode setTitle:@"60秒后获取" forState:UIControlStateDisabled];
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
    if (!self.codeHelper) {
        self.codeHelper = [[APIHelper alloc] init];
    }
    
    __weak UCRetrieveCarValidateView *weakSelf = self;
    [self.codeHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 取消请求
            if (error.code == ConnectionStatusCancel) {
                //                [[AMToastView toastView] hide];
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
            
            if (mBase) {
                if (mBase.returncode == 0) {
                    [[AMToastView toastView] showMessage:@"验证码已发送" icon:kImageRequestSuccess duration:AMToastDurationNormal];
                }
                else{
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                    [weakSelf resetBtnGetCode];
                }
            }
        }
        
        
    }];
    
    [self.codeHelper getValidateCodeByMobile:self.tfMobile.text];
    
}

#pragma mark - dealloc
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

@end
