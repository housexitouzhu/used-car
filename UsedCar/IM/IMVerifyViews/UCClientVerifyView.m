//
//  UCClictVerifyView.m
//  UsedCar
//
//  Created by 张鑫 on 14/11/18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCClientVerifyView.h"
#import "UCTopBar.h"
#import "NSString+Util.h"
#import "APIHelper.h"
#import "UIImage+Util.h"
#import "IMUserInfoModel.h"
#import "IMCacheManage.h"

#define kInputItemTag       32938561

@interface UCClientVerifyView () {
    NSInteger showAnimationCurve;
    CGFloat animationDuration;
    NSInteger timeLeft;
}

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UIScrollView *svMain;
@property (nonatomic, weak) UITextField *tfCurrent;
@property (nonatomic) CGSize keyboardSize;
@property (nonatomic, strong) UIButton *btnCode;
@property (nonatomic, strong) NSTimer *timeDown;
@property (nonatomic, strong) UIButton *btnDone;
@property (nonatomic, strong) APIHelper *apiCode;
@property (nonatomic, strong) APIHelper *apiVerify;

@end

@implementation UCClientVerifyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initView];
        
        // 监听键盘高度
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)initView{
    
    self.backgroundColor =  kColorNewBackground;
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    
    //
    _svMain = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.height)];
    
    // 说明文字
    UILabel *labTitle = [[UILabel alloc] init];
    labTitle.text = @"手机号用来查找咨询记录，不会泄漏给商家";
    labTitle.font = kFontSmall;
    labTitle.textColor = kColorBlue;
    labTitle.backgroundColor = kColorClear;
    [labTitle sizeToFit];
    labTitle.origin = CGPointMake((_svMain.width - labTitle.width) / 2, 10);

    // 输入框
    UIView *vInput = [self creatInputView:CGRectMake(0, labTitle.maxY + 10, _svMain.width, CGFLOAT_MIN)];
    
    // 完成
    _btnDone = [[UIButton alloc] initWithFrame:CGRectMake(15, vInput.maxY + 20, _svMain.width - 15*2, 42)];
    _btnDone.backgroundColor = kColorBlue;
    [_btnDone setTitle:@"完成" forState:UIControlStateNormal];
    _btnDone.titleLabel.textColor = kColorWhite;
    _btnDone.titleLabel.font = kFontLarge1;
    _btnDone.enabled = NO;
    
    _btnDone.layer.masksToBounds = YES;
    _btnDone.layer.cornerRadius = 3;
    [_btnDone addTarget:self action:@selector(onClickDoneBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_btnDone setBackgroundImage:[UIImage imageWithColor:kColorBlueD size:_btnDone.size] forState:UIControlStateDisabled];
    
    [_svMain addSubview:labTitle];
    [_svMain addSubview:vInput];
    [_svMain addSubview:_btnDone];
    [self addSubview:_svMain];
    
    // 打开键盘
    UITextField *tfName = (UITextField *)[vInput viewWithTag:kInputItemTag + 0];
    [tfName becomeFirstResponder];
    
    UITapGestureRecognizer *tapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapOne.numberOfTapsRequired = 1;
    tapOne.numberOfTouchesRequired = 1;
    tapOne.delegate = self;
    [self addGestureRecognizer:tapOne];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"验证身份" forState:UIControlStateNormal];
    [vTopBar.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

/** 输入框 */
- (UIView *)creatInputView:(CGRect)frame
{
    UIView *vInput = [[UIView alloc] initWithFrame:frame];
    vInput.backgroundColor = kColorWhite;
    
    NSArray *titles = @[@"姓名：", @"手机号：", @"验证码："];
    CGFloat height = 50;
    vInput.height = height * titles.count;

    for (NSInteger i = 0; i < titles.count; i++) {
        // 左视图
        UILabel *labLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, height)];
        labLeft.text = [titles objectAtIndex:i];
        labLeft.font = kFontLarge;
        labLeft.textColor = kColorNewGray1;
        labLeft.backgroundColor = kColorClear;
        
        // 输入框
        UITextField *tfItem = [[UITextField alloc] initWithFrame:CGRectMake(15, height * i, frame.size.width - 15, height)];
        tfItem.backgroundColor = kColorWhite;
        tfItem.font = kFontLarge;
        tfItem.leftViewMode = UITextFieldViewModeAlways;
        tfItem.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tfItem.leftView = labLeft;
        tfItem.tag = kInputItemTag + i;
        tfItem.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:tfItem];
        
        NSString *strLeft = labLeft.text;
        if ([strLeft hasPrefix:@"姓名"]) {
            tfItem.clearButtonMode = UITextFieldViewModeWhileEditing;
            tfItem.keyboardType = UIKeyboardTypeDefault;
        } else if ([strLeft hasPrefix:@"手机号"]) {
            tfItem.clearButtonMode = UITextFieldViewModeWhileEditing;
            tfItem.keyboardType = UIKeyboardTypeNumberPad;
        } else if ([strLeft hasPrefix:@"验证码"]) {
            tfItem.keyboardType = UIKeyboardTypeNumberPad;
            tfItem.clearButtonMode = UITextFieldViewModeWhileEditing;
            tfItem.returnKeyType = UIReturnKeyDone;
            tfItem.width = frame.size.width - 15 - 70;
        }
        
        // 分割线
        if (i != 2)
            [tfItem addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, tfItem.height - kLinePixel, frame.size.width - 15, kLinePixel) color:kColorNewLine]];
        [vInput addSubview:tfItem];
        if (i == 2) {
            // 获取
            _btnCode = [[UIButton alloc] initWithFrame:CGRectMake(vInput.width - 60 - 10, vInput.height - 40, 60, 30)];
            [_btnCode setTitle:@"获取" forState:UIControlStateNormal];
            _btnCode.titleLabel.font = kFontLarge;
            _btnCode.backgroundColor = kColorBlue;
            _btnCode.layer.masksToBounds = YES;
            _btnCode.userInteractionEnabled = YES;
            _btnCode.layer.cornerRadius = 3;
            [_btnCode addTarget:self action:@selector(onClickCodeBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            [vInput addSubview:_btnCode];
        }
    }
    
    [vInput addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, vInput.width, kLinePixel) color:kColorNewLine]];
    [vInput addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, vInput.height - kLinePixel, vInput.width, kLinePixel) color:kColorNewLine]];
    
    return vInput;
}

#pragma mark - private method
- (void)showGiveUpAlert
{
    BOOL isShowAlert = NO;
    for (NSInteger i = 0; i < 3; i++) {
        UITextField *tfItem = (UITextField *)[_svMain viewWithTag:kInputItemTag + i];
        if ([tfItem.text trim].length > 0) {
            isShowAlert = YES;
        }
    }
    
    if (isShowAlert) {
        UIAlertView *avGiveUP = [[UIAlertView alloc] initWithTitle:@"放弃本次编辑？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [avGiveUP show];
    } else {
        [self closeSelf];
    }
}

- (void)closeSelf
{
    [self endEditing:YES];
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

#pragma mark - button actions
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    
    if ([self.delegate respondsToSelector:@selector(clientVerifyViewDidClickCancel:)]) {
        [self.delegate clientVerifyViewDidClickCancel:self];
    }
    
    [self showGiveUpAlert];
}

/** 验证码 */
- (void)onClickCodeBtn:(UIButton *)btn
{
    UITextField *tfPhone = (UITextField *)[_svMain viewWithTag:kInputItemTag + 1];

    if (tfPhone.text.length != 11) {
        [[AMToastView toastView] showMessage:@"手机号格式不正确" icon:kImageRequestError duration:AMToastDurationNormal];
    } else {
        // 屏蔽重复点击
        if (![OMG isValidClick:0.5])
            return;
        [self getCodeAPI:tfPhone.text];
    }
}

/** 完成 */
- (void)onClickDoneBtn:(UIButton *)btn
{
    [self toVerify];
}

/** 判断是否填充正确数据 */
- (void)toVerify
{
    BOOL isFillOK = NO;
    
    UITextField *tfName = (UITextField *)[_svMain viewWithTag:kInputItemTag + 0];
    UITextField *tfMobile = (UITextField *)[_svMain viewWithTag:kInputItemTag + 1];
    UITextField *tfCode = (UITextField *)[_svMain viewWithTag:kInputItemTag + 2];
    
    if ([tfMobile.text trim].length != 11) {
        [[AMToastView toastView] showMessage:@"手机号格式不正确" icon:kImageRequestError duration:AMToastDurationNormal];
    } else if ([tfCode.text trim].length !=6) {
        [[AMToastView toastView] showMessage:@"验证码格式不正确" icon:kImageRequestError duration:AMToastDurationNormal];
    } else if ([tfName.text trim] > 0){
        isFillOK = YES;
    }
    if (isFillOK)
        [self getVerifyIM:[tfName.text trim] mobile:[tfMobile.text trim] code:[tfCode.text trim]];
}

- (void)beginCountdown
{
    timeLeft = 30;
    _timeDown = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCountDown) userInfo:nil repeats:YES];
}

- (void)timerCountDown
{
    _btnCode.enabled = NO;
    timeLeft--;
    
    UITextField *tfCode = (UITextField *)[_svMain viewWithTag:kInputItemTag + 2];
    CGFloat width = 60;
    
    if (timeLeft == 0) {
        tfCode.width = _svMain.width - 15 - 10 - width;
        _btnCode.enabled = YES;
        [_timeDown invalidate];
        [_btnCode setTitle:@"获取" forState:UIControlStateDisabled];
        [_btnCode setTitle:@"重发" forState:UIControlStateNormal];
    }
    else{
        width = 110;
        tfCode.width = _svMain.width - 15 - 10 - width;
        NSString *title = [NSString stringWithFormat:@"%d秒后可重发", timeLeft];
        [_btnCode setTitle:title forState:UIControlStateDisabled];
    }
    _btnCode.minX = _svMain.width - width - 10;
    _btnCode.width = width;
}

/**收键盘 */
- (void)dismissKeyboard:(id)sender{
    [self endEditing:YES];
}

- (void)verifyClientIM:(RegisterCliectIM)block
{
    self.blockClient = block;
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isMemberOfClass:[UIButton class]] || [touch.view isMemberOfClass:[UITextField class]]) {
        //放过button点击拦截
        return NO;
    }else{
        return YES;
    }
    
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self closeSelf];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _tfCurrent = textField;
    
    [self scrollOrginToFit];
    
    return YES;
}

/* textFieldDidEndEditing 中文上屏监听不响应, 使用通知监听 */
- (void)textFieldTextDidChange:(NSNotification *)notification
{
    UITextField *tfName = (UITextField *)[_svMain viewWithTag:kInputItemTag + 0];
    UITextField *tfMobile = (UITextField *)[_svMain viewWithTag:kInputItemTag + 1];
    UITextField *tfCode = (UITextField *)[_svMain viewWithTag:kInputItemTag + 2];
    _btnDone.enabled = ([tfName.text trim].length > 0 && [tfMobile.text trim].length > 0 && [tfCode.text trim].length > 0) ? YES : NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UILabel *labLeft = (UILabel *)textField.leftView;
    NSInteger maxLenght = NSIntegerMax;
    
    if ([labLeft.text hasPrefix:@"手机号"]) {
        maxLenght = 11;
    } else if ([labLeft.text hasPrefix:@"验证码"]) {
        maxLenght = 6;
    }
    
    if (textField.text.length >= maxLenght && string.length != 0) {
        return NO;
    }

    // 切换输入框
    if ([string isEqualToString:@"\n"]) {
        if (![labLeft.text hasPrefix:@"验证码"]) {
            UITextField *tfNext = (UITextField *)[_svMain viewWithTag:textField.tag + 1];
            [tfNext becomeFirstResponder];
        } else {
            [self toVerify];
        }
    }
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary*info=[notification userInfo];
    _keyboardSize=[[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    showAnimationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //在这里调整UI位置
    [self scrollOrginToFit];
    
}

- (void)scrollOrginToFit
{
    // 键盘Y
    CGFloat keyBoardY = self.height - _tbTop.height - _keyboardSize.height;
    CGRect tfFrame = [_tfCurrent convertRect:_tfCurrent.frame toView:_svMain];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:showAnimationCurve];
    [UIView setAnimationDuration:animationDuration];
    if (keyBoardY - (tfFrame.origin.y + tfFrame.size.height) < 0) {
        _svMain.contentOffset = CGPointMake(0, 50);
    } else
        _svMain.contentOffset = CGPointMake(0, 0);
    [UIView commitAnimations];

}

#pragma mark - APIHelter
/** 验证码 */
- (void)getCodeAPI:(NSString *)mobile
{
    if (!self.apiCode) {
        self.apiCode = [[APIHelper alloc] init];
    } else {
        [self.apiCode cancel];
    }
    
    [[AMToastView toastView] showLoading:@"验证码获取中..." cancel:^{
        [self.apiCode cancel];
        [[AMToastView toastView] hide];
    }];
    
    __weak UCClientVerifyView *vSelf = self;
    [self.apiCode setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    [vSelf beginCountdown];
                    [[AMToastView toastView] hide];
                }
                else {
                    if (mBase.message) {
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                    } else {
                        [[AMToastView toastView] hide];
                    }
                }
            } else {
                [[AMToastView toastView] showMessage:@"服务连接失败，请重试" icon:kImageRequestError duration:AMToastDurationNormal];
            }
        } else {
            [[AMToastView toastView] showMessage:@"服务连接失败，请重试" icon:kImageRequestError duration:AMToastDurationNormal];
        }
    }];
    [self.apiCode getVerifyCode:mobile type:[NSNumber numberWithInteger:4]];
    
}

- (void)getVerifyIM:(NSString *)name mobile:(NSString *)mobile code:(NSString *)code
{
    if (!self.apiVerify) {
        self.apiVerify = [[APIHelper alloc] init];
    } else {
        [self.apiVerify cancel];
    }
    
    [[AMToastView toastView:YES] showLoading:@"验证中，请稍候..." cancel:^{
        [self.apiVerify cancel];
        [[AMToastView toastView] hide];
    }];
    
    __weak UCClientVerifyView *vSelf = self;
    [self.apiVerify setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    IMUserInfoModel *mIMUserInfo = [[IMUserInfoModel alloc] initWithJson:mBase.result];
                    [IMCacheManage setCurrentIMUserInfo:mIMUserInfo];
                    [[AMToastView toastView] hide];
                    if (vSelf.blockClient) {
                        vSelf.blockClient(vSelf, YES, nil);
                        vSelf.blockClient = nil;
                    }
                }
                else {
                    if (mBase.message) {
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                    } else {
                        [[AMToastView toastView] hide];
                    }
                }
            } else {
                [[AMToastView toastView] showMessage:@"服务连接失败，请重试" icon:kImageRequestError duration:AMToastDurationNormal];
            }
        } else {
            [[AMToastView toastView] showMessage:@"服务连接失败，请重试" icon:kImageRequestError duration:AMToastDurationNormal];
        }
    }];
    [self.apiVerify verifyIMWithName:name mobile:mobile code:code salesid:nil];
    
}

#pragma mark - dealloc
-(void)dealloc{
    [self endEditing:YES];
    if (_timeDown) {
        [_timeDown invalidate];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

@end
