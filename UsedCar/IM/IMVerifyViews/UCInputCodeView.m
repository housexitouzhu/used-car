//
//  UCInputCodeView.m
//  UsedCar
//
//  Created by 张鑫 on 14/11/20.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCInputCodeView.h"
#import "IMCacheManage.h"
#import "UCTopBar.h"
#import "SalesPersonModel.h"
#import "UIImage+Util.h"
#import "NSString+Util.h"
#import "APIHelper.h"
#import "IMUserInfoModel.h"

#define  kTextFieldHeight           60

@interface UCInputCodeView () {
    NSInteger timeLeft;
}

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) SalesPersonModel *mSalePerson;
@property (nonatomic, strong) UITextField *tfCode;
@property (nonatomic, strong) UIButton *btnCode;
@property (nonatomic, strong) UIButton *btnDone;
@property (nonatomic, strong) APIHelper *apiCode;
@property (nonatomic, strong) NSTimer *timeDown;
@property (nonatomic, strong) APIHelper *apiVerify;

@end


@implementation UCInputCodeView

- (id)initWithFrame:(CGRect)frame salesPersonModel:(SalesPersonModel *)mSalesPerson
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [UMStatistics event:pv_4_3_IM_Saler_Indentify_TypeCode];
        self.mSalePerson = mSalesPerson;
        [self initView];
    }
    return self;
}

-(APIHelper *)apiCode
{
    if (!_apiCode) {
        _apiCode = [[APIHelper alloc] init];
    }
    return _apiCode;
}

- (void)initView{
    
    self.backgroundColor =  kColorNewBackground;
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    
    // title
    UILabel *labTitle = [[UILabel alloc] init];
    labTitle.text = [NSString stringWithFormat:@"验证码已下发到 %@****%@", [self.mSalePerson.salesphone substringToIndex:3], [self.mSalePerson.salesphone substringFromIndex:7]];
    labTitle.font = kFontSmall;
    labTitle.textColor = kColorBlue;
    labTitle.backgroundColor = kColorClear;
    [labTitle sizeToFit];
    labTitle.origin = CGPointMake((self.width - labTitle.width) / 2, _tbTop.maxY + 10);
    
    UIView *vInput = [self creatInputView:CGRectMake(0, labTitle.maxY + 10, self.width, kTextFieldHeight)];
    
    // 完成
    _btnDone = [[UIButton alloc] initWithFrame:CGRectMake(15, vInput.maxY + 20, self.width - 15*2, 42)];
    _btnDone.backgroundColor = kColorBlue;
    [_btnDone setTitle:@"完成" forState:UIControlStateNormal];
    _btnDone.titleLabel.textColor = kColorWhite;
    _btnDone.titleLabel.font = kFontLarge1;
//    _btnDone.enabled = NO;
    _btnDone.layer.masksToBounds = YES;
    _btnDone.layer.cornerRadius = 3;
    [_btnDone addTarget:self action:@selector(onClickDoneBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_btnDone setBackgroundImage:[UIImage imageWithColor:kColorBlueD size:_btnDone.size] forState:UIControlStateDisabled];
    
    [self addSubview:labTitle];
    [self addSubview:vInput];
    [self addSubview:_btnDone];
    
    [self.tfCode becomeFirstResponder];
    
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"输入验证码" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

/** 输入框 */
- (UIView *)creatInputView:(CGRect)frame
{
    UIView *vInput = [[UIView alloc] initWithFrame:frame];
    vInput.backgroundColor = kColorWhite;
    
    NSArray *titles = @[@"验证码："];
    CGFloat height = 50;
    vInput.height = height * titles.count;
    
    for (NSInteger i = 0; i < titles.count; i++) {
        // 左视图
        UILabel *labLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kTextFieldHeight, height)];
        labLeft.text = [titles objectAtIndex:i];
        labLeft.font = kFontLarge;
        labLeft.textColor = kColorNewGray1;
        
        // 输入框
        UITextField *tfItem = [[UITextField alloc] initWithFrame:CGRectMake(15, height * i, frame.size.width - 15, height)];
        tfItem.backgroundColor = kColorWhite;
        tfItem.font = kFontLarge;
        tfItem.leftViewMode = UITextFieldViewModeAlways;
        tfItem.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tfItem.leftView = labLeft;
        tfItem.delegate = self;
        
        NSString *strLeft = labLeft.text;
        if ([strLeft hasPrefix:@"验证码"]) {
            tfItem.keyboardType = UIKeyboardTypeNumberPad;
            tfItem.clearButtonMode = UITextFieldViewModeWhileEditing;
            tfItem.returnKeyType = UIReturnKeyDone;
            tfItem.width = frame.size.width - 15 - 70;
        }
        
        [vInput addSubview:tfItem];
        if (i == 0) {
            _tfCode = tfItem;
            // 获取
            _btnCode = [[UIButton alloc] initWithFrame:CGRectMake(vInput.width - kTextFieldHeight - 10, vInput.height - 40, kTextFieldHeight, 30)];
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
    
    return vInput;
}

#pragma mark - button actions
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/** 验证码 */
- (void)onClickCodeBtn:(UIButton *)btn
{
    // 屏蔽重复点击
    if (![OMG isValidClick:0.5])
        return;
    [UMStatistics event:c_4_3_IM_Saler_Indentify_RetryCode];
    [self getCodeAPI:_mSalePerson.salesphone];
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
    
    if ([_tfCode.text trim].length !=6) {
        [[AMToastView toastView] showMessage:@"验证码格式不正确" icon:kImageRequestError duration:AMToastDurationNormal];
        return;
    } else {
        isFillOK = YES;
    }
    if (isFillOK && _mSalePerson.salesname.length > 0 && _mSalePerson.salesphone.length > 0 && _mSalePerson.salesid)
        [self getVerifyIM:_mSalePerson.salesname mobile:_mSalePerson.salesphone code:[_tfCode.text trim] salesid:_mSalePerson.salesid];
}

- (void)beginCountdown
{
    timeLeft = 30;
    _btnCode.enabled = NO;
    _timeDown = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCountDown) userInfo:nil repeats:YES];
}

- (void)timerCountDown
{
    timeLeft--;
    
    CGFloat width = 60;
    
    if (timeLeft == 0) {
        _btnCode.enabled = YES;
        [_timeDown invalidate];
        [_btnCode setTitle:@"重发" forState:UIControlStateDisabled];
        [_btnCode setTitle:@"重发" forState:UIControlStateNormal];
    }
    else{
        width = 110;
        NSString *title = [NSString stringWithFormat:@"%d秒后可重发", timeLeft];
        [_btnCode setTitle:title forState:UIControlStateDisabled];
    }
    _btnCode.minX = self.width - width - 10;
    _btnCode.width = width;
    _tfCode.width = self.width - 15 - width - 10;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UILabel *labLeft = (UILabel *)textField.leftView;
    NSInteger maxLenght = NSIntegerMax;
    
    if ([labLeft.text hasPrefix:@"验证码"]) {
        maxLenght = 6;
    }
    
    if (textField.text.length >= maxLenght && string.length != 0) {
        return NO;
    }
    
    // 切换输入框
    if ([string isEqualToString:@"\n"]) {
        [self toVerify];
    }
    
    return YES;
}


/** 验证码 */
- (void)getCodeAPI:(NSString *)mobile
{
    if (self.apiCode.isConnecting) {
        [self.apiCode cancel];
    }
    
    [[AMToastView toastView] showLoading:@"验证码获取中..." cancel:^{
        [self.apiCode cancel];
        [[AMToastView toastView] hide];
    }];
    
    __weak UCInputCodeView *vSelf = self;
    [self.apiCode setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] showMessage:@"获取验证码失败，请重试" icon:kImageRequestError duration:AMToastDurationNormal];
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
                [[AMToastView toastView] showMessage:@"获取验证码失败，请重试" icon:kImageRequestError duration:AMToastDurationNormal];
            }
        } else {
            [[AMToastView toastView] showMessage:@"获取验证码失败，请重试" icon:kImageRequestError duration:AMToastDurationNormal];
        }
    }];

    [self.apiCode getVerifyCode:mobile type:[NSNumber numberWithInteger:4]];
    
}

- (void)getVerifyIM:(NSString *)name mobile:(NSString *)mobile code:(NSString *)code salesid:(NSNumber *)salesid
{
    if (!self.apiVerify) {
        self.apiVerify = [[APIHelper alloc] init];
    } else {
        [self.apiVerify cancel];
    }
    
    [[AMToastView toastView:YES] showLoading:@"验证中..." cancel:^{
        [self.apiVerify cancel];
        [[AMToastView toastView] hide];
    }];
    
    __weak UCInputCodeView *vSelf = self;
    [self.apiVerify setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] showMessage:@"验证失败，请重试" icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    IMUserInfoModel *mIMUserInfo = [[IMUserInfoModel alloc] initWithJson:mBase.result];
                    [IMCacheManage setCurrentIMUserInfo:mIMUserInfo];
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestSuccess duration:AMToastDurationNormal];
                    if ([vSelf.delegate respondsToSelector:@selector(didVerifyDealerSuccessed:)]) {
                        [vSelf.delegate didVerifyDealerSuccessed:vSelf];
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
                [[AMToastView toastView] showMessage:@"验证失败，请重试" icon:kImageRequestError duration:AMToastDurationNormal];
            }
        } else {
            [[AMToastView toastView] showMessage:@"验证失败，请重试" icon:kImageRequestError duration:AMToastDurationNormal];
        }
    }];
    [self.apiVerify verifyIMWithName:name mobile:mobile code:code salesid:salesid];
    
}

- (void)dealloc
{
    if (_timeDown) {
        [_timeDown invalidate];
    }
    [self endEditing:YES];
}

@end
