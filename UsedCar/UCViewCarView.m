//
//  UCReserVationCarView.m
//  UsedCar
//
//  Created by wangfaquan on 14-4-16.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCViewCarView.h"
#import "UCTopBar.h"
#import "UIImageView+WebCache.h"
#import "UCCarInfoModel.h"
#import "UCViewCarModel.h"
#import "UIImage+Util.h"
#import "APIHelper.h"
#import "AMCacheManage.h"

#define kCarTitleStarTag            200000
#define KMessageStartTag            100000
#define kCarBasicLocationTag        100001
#define kCarBasicDriveMileageTag    100002
#define KlabTag                     500

static NSString *tfName;     // 姓名
static NSString *tfPhone;    // 电话

@interface UCViewCarView()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCCarDetailInfoModel *mCarInfo;
@property (nonatomic, strong) NSMutableArray *mDataItems;
@property (nonatomic, strong) UCViewCarModel *mViewCar;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIView *view;
@property (nonatomic) NSInteger num;
@property (nonatomic, strong) APIHelper *apiHelper;

@end

@implementation UCViewCarView

- (id)initWithFrame:(CGRect)frame mCarDetailInfo:(UCCarDetailInfoModel *)mCarDetailInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _mCarInfo = [[UCCarDetailInfoModel alloc] init];
        _mViewCar = [[UCViewCarModel alloc] init];
        _mCarInfo = mCarDetailInfo;
        
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorGrey5;
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [_tbTop.btnTitle setTitle:@"预约看车" forState:(UIControlStateNormal)];
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnRight setTitle:@"提交" forState:UIControlStateNormal];
   
    [_tbTop.btnRight setTitleColor:kColorGreen2 forState:UIControlStateHighlighted];
    [_tbTop.btnRight setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_tbTop.btnRight addTarget:self action:@selector(onClickTopBar:) forControlEvents: UIControlEventTouchUpInside];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents: UIControlEventTouchUpInside];
    
    _view = [self setPhoneView:CGRectMake(0, 94, self.width, 319)];
    
    UIView *labelLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine];
    // 触摸关闭键盘
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(closeKeyboard)];
    singleFingerOne.numberOfTapsRequired = 1;
    singleFingerOne.delegate = self;
    [self addGestureRecognizer:singleFingerOne];
    _view.backgroundColor = kColorGrey5;
    [_view addSubview:labelLine];
    [self addSubview:_view];
    [self addSubview:_tbTop];
}

/** 顶部以下视图创建 */
- (UIView *)setPhoneView:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 94, self.width, 319)];
    //车视图
    UIView *vTops = [self setTopCar:CGRectMake(0, 94, self.width, 85)];
    
    vTops.backgroundColor = kColorWhite;
    
    UILabel *labMessage = [[UILabel alloc] initWithFrame:CGRectMake(15, vTops.maxY + 30, self.width - 40 , 20)];
    labMessage.text = @"预约信息提交后卖家会主动联系您，请慎重提交。";
    labMessage.textColor = kColorGrey3;
    labMessage.font = [UIFont systemFontOfSize:11];
    labMessage.backgroundColor = [UIColor clearColor];
    UIView *labelLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, labMessage.maxY + 10, self.width, kLinePixel) color:kColorNewLine];
    
    NSArray *arrText = [[NSArray alloc] initWithObjects:@"我的姓名:", @"我的手机:", @"手机验证:", nil];
    NSArray *arr = [[NSArray alloc] initWithObjects:@"填写真实姓名以便准确沟通", @"填写真实手机号以便准确沟通", @"填写发送到手机的验证码，该条短信免费", nil];
    CGFloat height = 40;
    CGFloat minY = 0;
    for (int i = 0; i < arrText.count; i++) {

        UIButton *btnMessage = [[UIButton alloc] initWithFrame:CGRectMake(0, labelLine.maxY +minY , self.width, 57)];
        btnMessage.backgroundColor = kColorWhite;
        UIView *labelLine1 = [[UIView alloc] initLineWithFrame:CGRectMake(0, btnMessage.maxY - 1, self.width, kLinePixel) color:kColorNewLine];
        
        // leftView
        UILabel *labLeft = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 8, 75, height)];
        
        // 标题
        UILabel *labTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(7, 8, 75, height)];
        labTitle.backgroundColor = [UIColor clearColor];
        labTitle.textColor = kColorGrey2;
        labTitle.textAlignment = NSTextAlignmentCenter;
        labTitle.font = [UIFont systemFontOfSize:14];
        labTitle.text = [arrText objectAtIndex:i];
        labTitle.tag = kCarTitleStarTag + i;
        [btnMessage addSubview:labTitle];
        NSInteger  width = 30;
        // 内容
        if (i == 1) {
            width = 90;
            UIButton *btnIdentify = [[UIButton alloc] initWithFrame:CGRectMake(self.width - width + 7, 10, 73, height)];
            [btnIdentify setBackgroundImage:[UIImage imageWithColor:kColorGrey4 size:btnIdentify.bounds.size] forState:UIControlStateDisabled];
            [btnIdentify setBackgroundImage:[UIImage imageWithColor:kColorGreen2 size:btnIdentify.bounds.size] forState:UIControlStateNormal];
            btnIdentify.layer.cornerRadius = 5;
            btnIdentify.tag = 10;
            btnIdentify.layer.masksToBounds = YES;
            btnIdentify.titleLabel.font = [UIFont systemFontOfSize:12];
            [btnIdentify addTarget:self action:@selector(onClickGetIdentify:) forControlEvents:UIControlEventTouchUpInside];
            [btnIdentify setTitle:@"获取验证码" forState:UIControlStateNormal];
            [btnMessage addSubview:btnIdentify];

        }
        UITextField *tfContent = [[UITextField alloc] initWithFrame:CGRectMake(5, 9, self.width - width, height)];
        
        // 特殊处理键盘
        if (i == 1 || i == 2) {
            tfContent.keyboardType = UIKeyboardTypeNumberPad;
        }
        tfContent.delegate = self;
        tfContent.tag = i + KMessageStartTag;
        tfContent.layer.borderWidth = kLinePixel;
        tfContent.layer.cornerRadius = 5;
        tfContent.font = [UIFont boldSystemFontOfSize:15];
        tfContent.layer.borderColor = [UIColor clearColor].CGColor;
        tfContent.textColor = kColorGrey2;
       
        UILabel *labMidel = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, self.width - width, height)];
        labMidel.text = [arr objectAtIndex:i];
        labMidel.font = [UIFont systemFontOfSize:11];
        labMidel.tag = KlabTag + i;
        labMidel.textColor = kColorGrey3;
        [tfContent addSubview:labMidel];
        
        // 给text信息自动填充
        if (tfName.length > 0 && i == 0) {
            tfContent.text = tfName;
            labMidel.hidden = YES;
        }
        if (tfPhone.length > 0 && i == 1) {
            tfContent.text = tfPhone;
            labMidel.hidden = YES;
        }
       

        // 车辆信息 使用 TextView代替
        if ([labTitle.text hasPrefix:@"填写真实姓名以便准确沟通"]) {
            tfContent.tag = KMessageStartTag;
    
        } else if ([labTitle.text hasPrefix:@"填写真实手机号以便准确沟通"]) {
            tfContent.tag = kCarBasicLocationTag;
            tfContent.keyboardType = UIKeyboardTypeDecimalPad;

           
        } else if ([labTitle.text hasPrefix:@"填写发送到手机的验证码,该条短信免费"] ) {
            
            tfContent.tag = kCarBasicDriveMileageTag;
        }
        
        tfContent.leftView = labLeft;
        tfContent.leftViewMode = UITextFieldViewModeAlways;
        tfContent.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        minY += 57;
        
        [btnMessage addSubview:tfContent];
        [view addSubview:btnMessage];
        [view addSubview:labelLine1];
}
    
    [view addSubview:labelLine];
    [view addSubview:labMessage];
    [view addSubview:vTops];
    return view;
}

/** 设置顶部视图 */
- (UIView *)setTopCar:(CGRect)frame
{
    UIView *vTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 85)];
    UIView *labelLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, vTop.maxY - 1, self.width, kLinePixel) color:kColorNewLine];
    
    // 预约信息填写页统计
    [UMStatistics event:pv_3_5_appointment];
    
    // 图片
    UIImageView *ivCarPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(7, 8, 90, 67.5)];
    // 图片urls
    NSArray *thumbimgurls = [[NSArray alloc] initWithArray:[_mCarInfo.thumbimgurlsText componentsSeparatedByString:@","]];
    
    [ivCarPhoto sd_setImageWithURL:[thumbimgurls objectAtIndex:0] placeholderImage:[UIImage imageNamed:@"home_default"]];
    
    // 标题
    UILabel *labTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(ivCarPhoto.maxX + 10, 11, vTop.width - ivCarPhoto.maxX - 25, 15)];
    labTitle.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    labTitle.numberOfLines = 1;
    labTitle.font = [UIFont systemFontOfSize:labTitle.height - 1];
    labTitle.text = _mCarInfo.carnameText;
    
    // 来源图标
    UIImageView *ivSource = [[UIImageView alloc] initWithFrame:CGRectMake(labTitle.minX, labTitle.maxY + 10, 14.5, 14.5)];
    
    // 1.个人，2.商家，
    if (_mCarInfo.sourceid.integerValue == 1)
        ivSource.image = [UIImage imageNamed:@"home_personage_btn"];
    else
        ivSource.image = [UIImage imageNamed:@"home_merchant_btn"];
    // 价格
    UILabel *labPrice = [[UILabel alloc] initWithClearFrame:CGRectMake(ivSource.maxX + 5, ivSource.minY, 170, 16)];
    labPrice.font = [UIFont boldSystemFontOfSize:labPrice.height];
    labPrice.textColor = kColorOrange;
    labPrice.text = [NSString stringWithFormat:@"￥%@万",_mCarInfo.bookpriceText];
    
    // 公里数/年份
    UILabel *labText = [[UILabel alloc] initWithClearFrame:CGRectMake(ivSource.minX, labPrice.maxY + 10, 110, 11)];
    labText.font = [UIFont systemFontOfSize:labText.height];
    labText.textColor = kColorGrey3;
    labText.text = [NSString stringWithFormat:@"%@万公里/%@年", _mCarInfo.drivemileageText, [_mCarInfo.firstregtimeText substringToIndex:4]];
    
    // 时间
    UILabel *labTime = [[UILabel alloc] initWithClearFrame:CGRectMake(vTop.width - 90 - 15, labText.minY, 90, 11)];
    labTime.font = [UIFont systemFontOfSize:labTime.height];
    labTime.textAlignment = NSTextAlignmentRight;
    labTime.textColor = kColorGrey3;
    labTime.text = _mCarInfo.publicdateText;
    
    // 近似新车
    UIImageView *ivNewCar = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 25, labTitle.maxY + 10, 14.5, 14.5)];
    ivNewCar.image = [UIImage imageNamed:@"new_car"];
    // 延长质保
    UIImageView *ivWarrantly = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 45, labTitle.maxY + 10, 14.5, 14.5)];
    ivWarrantly.image = [UIImage imageNamed:@"ext_warrant"];
    ivNewCar.hidden = ([_mCarInfo.isnewcar integerValue] == 0);
    ivWarrantly.hidden = ([_mCarInfo.extendedrepair integerValue] == 0);
    ivWarrantly.minX = ivNewCar.hidden ? ivNewCar.minX : self.width - 50;
    
    [vTop addSubview:ivCarPhoto];
    [vTop addSubview:labTitle];
    [vTop addSubview:ivSource];
    [vTop addSubview:labPrice];
    [vTop addSubview:labText];
    [vTop addSubview:labTime];
    [vTop addSubview:labelLine];
    [vTop addSubview:ivNewCar];
    [vTop addSubview:ivWarrantly];
    return vTop;
}

#pragma mark - private Method
/** 收键盘 */
- (void)closeKeyboard
{
    [UIView animateWithDuration:0.25 animations:^{
        _view.minY = 100;
    }];

    UITextField *tfItem1 = (UITextField *)[self viewWithTag:KMessageStartTag];
    UITextField *tfItem2 = (UITextField *)[self viewWithTag:KMessageStartTag + 1];
    UITextField *tfItem3 = (UITextField *)[self viewWithTag:KMessageStartTag + 2];
    [tfItem1 resignFirstResponder];
    [tfItem2 resignFirstResponder];
    [tfItem3 resignFirstResponder];
}

/** 计时器开始计时 */
- (void)onTimer
{
    _num = 60;
    // 获取验证码按钮置灰
    UIButton *btn = (UIButton *)[self viewWithTag:10];
    btn.enabled = NO;
    if (!_timer)
        _timer = [[NSTimer alloc] init];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getIdentifys:) userInfo:nil repeats:YES];
    [_timer fire];
}

/** 短信倒计时 */
- (void)getIdentifys:(NSTimer *)timer
{
    _num -= 1;
    UIButton *btnIentify = (UIButton *)[self viewWithTag:10];
    [btnIentify setTitle:[NSString stringWithFormat:@"%d秒后获取", _num] forState:UIControlStateDisabled];
    if (_num == 0) {
        [_timer invalidate];
        btnIentify.enabled = YES;
        [btnIentify setTitle:@"59秒后获取" forState:UIControlStateDisabled];
    }
}

#pragma mark - onClickButton
/** 导航栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (btn.tag == UCTopBarButtonLeft) {
        UITextField *tfItem1 = (UITextField *)[self viewWithTag:KMessageStartTag];
        tfName = tfItem1.text;
        UITextField *tfItem2 = (UITextField *)[self viewWithTag:KMessageStartTag + 1];
        tfPhone = tfItem2.text;
        [UMStatistics event:c_3_5_appointmentback];
        
        [[MainViewController sharedVCMain] closeView:self animateOption: AnimateOptionMoveLeft];
    } else if (btn.tag == UCTopBarButtonRight) {
        
        // 预约看车填写页面提交按钮
        [UMStatistics event:c_3_5_appointmentsubmit];
        
        UITextField *tfItem1 = (UITextField *)[self viewWithTag:KMessageStartTag];
        _mViewCar.name = tfItem1.text;
        UITextField *tfItem2 = (UITextField *)[self viewWithTag:KMessageStartTag + 1];
        _mViewCar.telePhone = tfItem2.text;
        UITextField *tfItem3 = (UITextField *)[self viewWithTag:KMessageStartTag + 2];
        _mViewCar.phoneId = tfItem3.text;
        
        NSMutableArray *errors = [NSMutableArray arrayWithCapacity:3];
        if (_mViewCar.name.length == 0)
            [errors addObject:[NSNumber numberWithInt:KMessageStartTag]];
        if (_mViewCar.telePhone.length == 0)
            [errors addObject:[NSNumber numberWithInt:KMessageStartTag + 1]];
        if ( _mViewCar.phoneId.length == 0) {
            [errors addObject:[NSNumber numberWithInt:KMessageStartTag + 2]];
        }
        // 未填完提示
        if (errors.count > 0) {
            [[AMToastView toastView] showMessage:[NSString stringWithFormat:@"还有%d项未填写", errors.count] icon:kImageRequestError duration:AMToastDurationNormal];
            for (NSNumber *num in errors) {
                UILabel *labTitle = (UILabel *)[self viewWithTag:num.integerValue + KMessageStartTag];
                labTitle.textColor = kColorRed; //font 16
            }
        }
        else if ( 0 < tfItem2.text.length && tfItem2.text.length < 11) {
            [[AMToastView toastView] showMessage:@"请输入正确的手机号" icon:kImageRequestError duration:AMToastDurationNormal];
        }
        // 预约看车填写页面提交
        else {
            tfName = _mViewCar.name;
            tfPhone = _mViewCar.telePhone;
            [self postTheSourceState:_mCarInfo.carid price:_mCarInfo.bookpriceText userName:tfItem1.text userMobile:tfItem2.text mcode:tfItem3.text];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return self == touch.view;
}

- (void)onClickGetIdentify:(UIButton *)btn
{
    [UMStatistics event:c_3_5_appointmentcode];
    
   // 开启验证码倒计时
    UITextView *text = (UITextView *)[self viewWithTag:KMessageStartTag + 1];
    if (text.text.length == 11) {
        [self getTheVerificationCode:text.text type: [NSNumber numberWithInt:1]];
    } else {
        [[AMToastView toastView] showMessage:@"请输入正确的手机号" icon:kImageRequestError duration:AMToastDurationNormal];
    }
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{

    [UIView animateWithDuration:0.25 animations:^{
        _view.maxY = _view.height - 80;
    }];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if (textField.tag == KMessageStartTag) {
        UILabel *labItem1 = (UILabel *)[self viewWithTag:KlabTag];
        
        labItem1.hidden = (textField.text.length + string.length) > 0 ? YES : NO;
        if (textField.text.length == 1 && string.length == 0) {
            labItem1.hidden = NO;
        }
        // 限制字数
        if (textField.text.length + string.length > 20 && string.length != 0)
            return NO;
        
    } else if (textField.tag == kCarBasicLocationTag) {
        textField.font = [UIFont systemFontOfSize:15];
        UILabel *labItem2 = (UILabel *)[self viewWithTag:KlabTag + 1];
        labItem2.hidden = (textField.text.length + string.length) > 0 ? YES : NO;
        if (textField.text.length == 1 && string.length == 0) {
            labItem2.hidden = NO;
        }
        NSMutableString *str = [NSMutableString stringWithString:textField.text];
        // 限制字数
        NSInteger surplus = 11 - textField.text.length;
        if (string.length > surplus)
            return NO;
        
        // 行驶里程 数据保存到实体
        _mViewCar.phoneId = str;
    } else if (textField.tag == kCarBasicDriveMileageTag) {
        
        textField.font = [UIFont systemFontOfSize:15];
        UILabel *labItem3 = (UILabel *)[self viewWithTag:KlabTag + 2];
        labItem3.hidden = (textField.text.length + string.length) > 0 ? YES : NO;
        if (textField.text.length == 1 && string.length == 0)
            labItem3.hidden = NO;
        // 限制字数
        NSInteger surplus = 6 - textField.text.length;
        textField.font = [UIFont systemFontOfSize:15];
        if (string.length > surplus)
            return NO;

    }
    // 设置标题为正常颜色
    UILabel *labTitle = (UILabel *)[self viewWithTag:textField.tag + 100000];
    [labTitle setTextColor:kColorGrey2];
     return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

#pragma mark - APIHelper
/** 验证码发送请求 */
- (void)getTheVerificationCode:(NSString *)mobile type:(NSNumber *)type
{
    if (!_apiHelper)
        _apiHelper = [[APIHelper alloc] init];
    else
        [_apiHelper cancel];
    
    // 状态提示框
    [[AMToastView toastView:YES] showLoading:@"正在获取验证码..." cancel:^{
        [_apiHelper cancel];
        [[AMToastView toastView] hide];
    }];
    __weak UCViewCarView *temp = self;

    // 设置请求完成后回调方法
    [_apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        // 发生错误
        if (error) {
            // 非取消请求
            if (error.code != ConnectionStatusCancel)
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            return;
        }
        // 正常返回
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    [[AMToastView toastView] hide];
                    [temp onTimer];
                } else {
                    if(mBase.message)
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                    else
                        [[AMToastView toastView] hide];
                }
            } else
                [[AMToastView toastView] hide];
            
        }
    }];
    [_apiHelper getTheVerificationCode:mobile type:type];
}

/** 提交车源状态 */
- (void)postTheSourceState:(NSNumber *)carId price:(NSString *)price userName:(NSString *)userName userMobile:(NSString *)userMobile mcode:(NSString *)mcode
{
    if (!_apiHelper)
        _apiHelper = [[APIHelper alloc] init];
    else
        [_apiHelper cancel];
    
    // 状态提示框
    [[AMToastView toastView:YES] showLoading:@"正在操作..." cancel:^{
        [_apiHelper cancel];
        [[AMToastView toastView] hide];
    }];
    
    __weak UCViewCarView *cViewCar = self;
    
    // 设置请求完成后回调方法
    [_apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        // 发生错误
        if (error) {
            // 非取消请求

            if (error.code != ConnectionStatusCancel)
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            return;
        }
        // 正常返回
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestSuccess duration:AMToastDurationNormal];
                    [[MainViewController sharedVCMain] closeView:cViewCar animateOption: AnimateOptionMoveLeft];
                    
                } else {
                    if(mBase.message)
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                }
            } else
                [[AMToastView toastView] hide];
        }
    }];
    [_apiHelper postTheSourceState:carId price:price userName:userName userMobile:userMobile mcode:mcode];
}

- (void)dealloc
{
    [_timer invalidate];
    [_apiHelper cancel];
    [[AMToastView toastView] hide];
}

@end
