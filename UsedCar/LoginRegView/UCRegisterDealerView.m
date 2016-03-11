//
//  UCRegisterDealerView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-9-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCRegisterDealerView.h"
#import "UCTopBar.h"
#import "AreaProvinceItem.h"
#import "UCProtocolView.h"
#import "UCRegisterSuccessView.h"
#import "UCRegisterDealerModel.h"
#import "NSString+Util.h"
#import "APIHelper.h"
#import "UCContactUsView.h"

#define kRegisterInputItemStartTag       200000

@interface UCRegisterDealerView ()

@property (nonatomic, strong) UIScrollView *svMain;
@property (nonatomic, strong) UIImageView *ivSelected;
@property (nonatomic, strong) NSArray *provinces;           // 省市
@property (nonatomic, strong) UISelectorView *vSelector;    // 选择器
@property (nonatomic, strong) UIButton *btnCloseKeyboard;   // 关闭键盘
@property (nonatomic) CGFloat keyboardHeight;               // 键盘高度
@property (nonatomic, strong) UIButton *btnAgree;
@property (nonatomic, strong) UCRegisterDealerModel *mRegister;
@property (nonatomic, strong) NSArray *companyTypes;         // 公司类型
@property (nonatomic, strong) NSMutableArray *companyTypeNames;     // 公司类型名称
@property (nonatomic, strong) NSArray *titles;              // 输入框标题
@property (nonatomic, strong) UILabel *labRead;             // 我已阅读并同意
@property (nonatomic, strong) APIHelper *apiCheckDealerInfo;
@property (nonatomic, strong) APIHelper *apiRegister;       // 注册
@property (nonatomic, strong) UCProtocolView *vProtocol;

@end

@implementation UCRegisterDealerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [UMStatistics event:pv_3_6_businessregistration];
        
        _apiCheckDealerInfo = [[APIHelper alloc] init];
        _apiRegister = [[APIHelper alloc] init];
        
        // 筛选条件
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FilterValues" ofType:@"plist"];
        NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
        // 省市
        self.provinces = [OMG areaProvinces];
        // 公司类型
        _companyTypes = [NSArray arrayWithArray:values[@"CompanyType"]];
        _companyTypeNames = [NSMutableArray array];
        for (int i = 0; i < _companyTypes.count; i++) {
            [_companyTypeNames addObject:[[_companyTypes objectAtIndex:i] objectForKey:@"Name"]];
        }
        
        _titles = [NSArray arrayWithObjects:@"网店名称：", @"公司类型：", @"所在城市：", @"联系人：", @"联系手机：", nil];
        
        _mRegister = [[UCRegisterDealerModel alloc] init];
        
        // 键盘监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        if (DEVICE_IS_IPHONE5)
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [self initView];
    }
    return self;
}

#pragma mark - initView
/** 创建视图 */
- (void)initView
{
    self.backgroundColor = [UIColor whiteColor];
    
    // 初始化选择器
    _vSelector = [[UISelectorView alloc] initWithFrame:CGRectMake(0, 0, self.width, 216)];
    _vSelector.delegate = self;
    _vSelector.backgroundColor = kColorGrey5;
    _vSelector.colorSelector = kColorBlue1;
    
    // 导航栏
    UCTopBar *vTopBar = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    // 滚动视图
    _svMain = [[UIScrollView alloc] initWithFrame:CGRectMake(0, vTopBar.maxY, self.width, self.height - vTopBar.maxY)];
    // 输入视图
    UIView *vInput = [self creatInputView:CGRectMake(0, 0, _svMain.width, 0)];
    // 许可协议
    UIView *vUseAgreement = [self creatUseAgreementView:CGRectMake(0, vInput.maxY, _svMain.width, 73)];
//    // 联系方式
//    UIView *vContact = [self creatContactView:CGRectMake(0, self.height - 77, self.width, 77)];
    
    // 键盘关闭按钮
    UIImage *imgClose = [UIImage imageNamed:@"keboard_off_btn"];
    _btnCloseKeyboard = [[UIButton alloc] initWithFrame:CGRectMake(self.width - imgClose.size.width, self.height, imgClose.size.width + 10, imgClose.size.height + 10)];
    [_btnCloseKeyboard setImage:imgClose forState:UIControlStateNormal];
    [_btnCloseKeyboard addTarget:self action:@selector(onClickCloseKeyboard) forControlEvents:UIControlEventTouchUpInside];
    _btnCloseKeyboard.alpha = 0;
    
    [_svMain addSubview:vInput];
    [_svMain addSubview:vUseAgreement];
    
    [self addSubview:vTopBar];
    [self addSubview:_svMain];
//    [self addSubview:vContact];
    [self addSubview:_btnCloseKeyboard];
    
    vInput.height = vUseAgreement.maxY;
    _svMain.contentSize = CGSizeMake(_svMain.width, vInput.height);
    
    
    UCContactUsView *vContactUS = [[UCContactUsView alloc] initWithFrame:CGRectMake(0, self.height - 77, self.width, 77) withStatementArray:@[@"如注册操作遇到问题请联系客服人员", @"客服：010-59857661   QQ：1611381677"] andPhoneNumber:@"01059857661"];
    [self addSubview:vContactUS];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    [vTopBar.btnTitle setTitle:@"商家注册" forState:UIControlStateNormal];
    [vTopBar.btnRight setTitle:@"提交" forState:UIControlStateNormal];
    [vTopBar.btnRight addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    return vTopBar;
}

/** 编写视图 */
- (UIView *)creatInputView:(CGRect)frame
{
    UIView *vInput = [[UIView alloc] initWithFrame:frame];
    
    CGFloat inputMinY = 0;
    CGFloat itemHeight = 50;
    for (int i = 0; i < _titles.count; i++) {
        // 输入框
        UITextField *tfItem = [[UITextField alloc] initWithFrame:CGRectMake(20, inputMinY, vInput.width - 20, itemHeight)];
        tfItem.tag = kRegisterInputItemStartTag + i;
        tfItem.keyboardType = UIKeyboardTypeDecimalPad;
        tfItem.delegate = self;
        tfItem.leftViewMode = UITextFieldViewModeAlways;
        tfItem.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        // 左视图
        UILabel *labLeft = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 14, 80, 18)];
        labLeft.textColor = kColorGray1;
        labLeft.font = kFontLarge;
        labLeft.font = [UIFont systemFontOfSize:16];
        labLeft.text = [_titles objectAtIndex:i];
        
        if ([labLeft.text hasPrefix:@"网店名称"] || [labLeft.text hasPrefix:@"联系人"]) {
            tfItem.keyboardType = UIKeyboardTypeDefault;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:tfItem];
        }
        else if ([labLeft.text hasPrefix:@"公司类型"] || [labLeft.text hasPrefix:@"所在城市"]) {
            tfItem.inputView = _vSelector;
        }
        else if ([labLeft.text hasPrefix:@"联系手机"]) {
            tfItem.keyboardType = UIKeyboardTypeNumberPad;
        }
        
        // 更改inputMinY
        inputMinY += tfItem.height;
        
        // 分割线
        UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(20, inputMinY - kLinePixel, tfItem.width, kLinePixel) color:kColorNewLine];
        [vInput addSubview:vLine];
        
        // 设置输入框左视图
        tfItem.leftView = labLeft;
        // 添加输入框
        [vInput addSubview:tfItem];
        
    }
    
    // 输入视图高度
    vInput.height = inputMinY;
    
    return vInput;
}

/** 使用协议 */
- (UIView *)creatUseAgreementView:(CGRect)frame
{
    UIView *vUseAgreement = [[UIView alloc] initWithFrame:frame];
    
    // 分割线
    UIView *vLine = [[UIView alloc] initWithFrame:CGRectMake(20, vUseAgreement.height - kLinePixel, vUseAgreement.width - 20, kLinePixel)];
    vLine.backgroundColor = kColorNewLine;
    
    // 查看协议按钮
    UIButton *btnViewAgreement = [[UIButton alloc] initWithClearFrame:vUseAgreement.bounds];
    [btnViewAgreement addTarget:self action:@selector(onClickViewAgreementBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *labAgreement = [[UILabel alloc] initWithClearFrame:CGRectMake(20, 14, 0, 0)];
    labAgreement.text = @"二手车之家网站商家系统使用许可协议";
    labAgreement.font = kFontSmall;
    labAgreement.textColor = kColorGray1;
    [labAgreement sizeToFit];
    
    // 选择框
    UIImage *iSelected = [UIImage imageNamed:@"enroll_agree_butten"];
    _ivSelected = [[UIImageView alloc] initWithImage:iSelected];
    _ivSelected.origin = CGPointMake(20, 40);
    
    // 我已阅读并同意
    _labRead = [[UILabel alloc] initWithClearFrame:CGRectMake(_ivSelected.maxX + 5, _ivSelected.minY, 90, _ivSelected.height)];
    _labRead.text = @"我已阅读并同意";
    _labRead.font = kFontSmall;
    _labRead.textColor = kColorGray1;
    
    // 右箭头
    UIImage *iArrow = [UIImage imageNamed:@"set_arrow_right"];
    UIImageView *ivArrow = [[UIImageView alloc] initWithImage:iArrow];
    ivArrow.origin = CGPointMake(vUseAgreement.width - iArrow.size.width - 10, (vUseAgreement.height - iArrow.size.height) / 2);
    
    // 同意协议按钮
    _btnAgree = [[UIButton alloc] initWithFrame:CGRectMake(labAgreement.minX, _ivSelected.minY - 6, _labRead.width + 40, 42)];
    _btnAgree.selected = NO;
    _btnAgree.tag = kRegisterInputItemStartTag + 5;
    [_btnAgree addTarget:self action:@selector(onClickAgreeBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [vUseAgreement addSubview:labAgreement];
    [vUseAgreement addSubview:_ivSelected];
    [vUseAgreement addSubview:_labRead];
    [vUseAgreement addSubview:ivArrow];
    [vUseAgreement addSubview:btnViewAgreement];
    [vUseAgreement addSubview:_btnAgree];
    [vUseAgreement addSubview:vLine];
    
    return vUseAgreement;
}

#pragma mark - private method
- (void)adjustFirstResponder:(UIView *)vFirstResponder
{
    if (_keyboardHeight > 0) {
        CGRect vFirstResponderRect = [_svMain convertRect:vFirstResponder.frame fromView:vFirstResponder.superview];
        vFirstResponderRect.origin.y = vFirstResponderRect.origin.y - _svMain.contentOffset.y + 88; // 标题栏占位偏移
        
        [UIView animateWithDuration:0.2 animations:^{
            _svMain.contentInset = UIEdgeInsetsMake(_svMain.contentInset.top, 0, _keyboardHeight, 0);
            _svMain.scrollIndicatorInsets = _svMain.contentInset;
            CGFloat offsetHeight = _svMain.height - _keyboardHeight - (vFirstResponderRect.origin.y + vFirstResponderRect.size.height);
            if(offsetHeight < 0)
                _svMain.contentOffset = CGPointMake(0, _svMain.contentOffset.y - offsetHeight); // 标题栏占位偏移
        }];
    }
}

/** 检验数据正确性 */
- (BOOL)checkRegisterData
{
    BOOL isContinue = YES;
    
    NSMutableArray *errors = [NSMutableArray array];
    
    // 五项填写内容
    for (int i = 0; i < _titles.count; i++) {
        UITextField *tfItem = (UITextField *)[self viewWithTag:kRegisterInputItemStartTag + i];
        if ([tfItem.text trim].length == 0) {
            [errors addObject:[NSNumber numberWithInteger:tfItem.tag]];
            // 标题红色
            UILabel *labItem = (UILabel *)tfItem.leftView;
            labItem.textColor = kColorRed;
        }
    }
    // 勾选协议
    if (!_btnAgree.selected) {
        [errors addObject:[NSNumber numberWithInteger:_btnAgree.tag]];
        _labRead.textColor = kColorRed;
    }
    
    if (errors.count > 0) {
        [[AMToastView toastView] showMessage:[NSString stringWithFormat:@"您还有%d项未填写", errors.count] icon:kImageRequestError duration:AMToastDurationNormal];
        return NO;
    }
    
    // 联系人正确性
    UITextField *tfPeople = (UITextField *)[self viewWithTag:kRegisterInputItemStartTag + 3];
    if ([tfPeople.text trim].length < 2 || [tfPeople.text trim].length > 5) {
        [[AMToastView toastView] showMessage:@"输入错误，请填写2-5个汉字" icon:kImageRequestError duration:AMToastDurationNormal];
        return NO;
    }
    
    // 联系手机正确性
    UITextField *tfPhone = (UITextField *)[self viewWithTag:kRegisterInputItemStartTag + 4];
    if ([tfPhone.text trim].length != 11) {
        [[AMToastView toastView] showMessage:@"输入错误，请正确填写手机号" icon:kImageRequestError duration:AMToastDurationNormal];
        return NO;
    }
    
    return isContinue;
}

#pragma mark - onClickButton
- (void)onClickTopBar:(UIButton *)btn
{
    // 关闭
    if (btn.tag == UCTopBarButtonLeft) {
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
    // 提交
    else if (btn.tag == UCTopBarButtonRight) {
        [UMStatistics event:c_3_6_businessregistration_submit];
        // 检验数据正确性
        BOOL isContinue = [self checkRegisterData];
        
        // 注册
        if (isContinue) {
            [self registerDealer];
        }
    }
}

/** 关闭键盘事件 */
- (void)onClickCloseKeyboard
{
    [self endEditing:YES];
}

/** 同意协议 */
- (void)onClickAgreeBtn:(UIButton *)btn
{
    btn.selected = !btn.selected;
    // 取消红色
    if (btn.selected)
        _labRead.textColor = [UIColor blackColor];
    _ivSelected.image = [UIImage imageNamed:btn.selected ? @"enroll_agree_butten_h" : @"enroll_agree_butten"];
}

/** 查看协议 */
- (void)onClickViewAgreementBtn:(UIButton *)btn
{
    [self onClickCloseKeyboard];
    
    _vProtocol = [[UCProtocolView alloc] initWithFrame:self.bounds];
    _vProtocol.btn = _btnAgree;
    _vProtocol.delegate = self;
    [[MainViewController sharedVCMain] openView:_vProtocol animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}


#pragma mark - NSNotification
/* textFieldDidEndEditing 中文上屏监听不响应, 使用通知监听 */
- (void)textFieldTextDidChange:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UITextField class]]) {
        UITextField *textField = notification.object;
        
        if (textField.markedTextRange == nil) {
            // 网店名称
            if (textField.tag == kRegisterInputItemStartTag + 0) {
                if (textField.text.length > 30)
                    textField.text = [textField.text substringToIndex:30];
                _mRegister.shopname = textField.text;
            }
            // 联系人
            else if (textField.tag == kRegisterInputItemStartTag + 3) {
                if (textField.text.length > 5)
                    textField.text = [textField.text substringToIndex:5];
                _mRegister.contactname = textField.text;
            }
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // 公司类型
    if (textField.tag == kRegisterInputItemStartTag + 1) {
        _vSelector.tag = 1;
        _vSelector.dataSource = [NSMutableArray arrayWithObjects:_companyTypeNames, nil];
    }
    // 所在城市
    else if (textField.tag == kRegisterInputItemStartTag + 2) {
        _vSelector.tag = 2;
        
        NSInteger row0 = 0;
        // 省市名称
        NSMutableArray *provinceNames = [NSMutableArray array];
        for (int i = 0; i < _provinces.count; i++) {
            AreaProvinceItem *apItem = [_provinces objectAtIndex:i];
            [provinceNames addObject:apItem.PN];
        }
        
        // 城市名称
        NSMutableArray *cityNames = [NSMutableArray array];
        NSArray *citys = [(AreaProvinceItem *)[_provinces objectAtIndex:row0] CL];
        
        for (int i = 0; i < citys.count; i++) {
            AreaCityItem *acItem = [citys objectAtIndex:i];
            [cityNames addObject:acItem.CN];
        }
        _vSelector.dataSource = [NSMutableArray arrayWithObjects:provinceNames, cityNames, nil];
    }
    
    [self adjustFirstResponder:textField];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // 去除前后空格
    textField.text = [textField.text trim];
    // 检查商家名称是否存在
    if (textField.tag == kRegisterInputItemStartTag + 0 && textField.text.length > 0) {
        [self checkDealerInfo:1 checkvalue:textField.text];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField.tag == kRegisterInputItemStartTag + 0 || textField.tag == kRegisterInputItemStartTag + 3 || textField.tag == kRegisterInputItemStartTag + 4) {
        
        NSMutableString *str = [NSMutableString stringWithString:textField.text];
        if (string.length > 0)
            [str insertString:string atIndex:range.location];
        else
            [str deleteCharactersInRange:range];
        // 联系电话
        if (textField.tag == kRegisterInputItemStartTag + 4) {
            // 禁止空格
            unichar uc = [string characterAtIndex: [string length]-1];
            //禁止输入空格 ASCII ==32
            if (uc == 32)
                return NO;
            
            // 限制字数
            NSInteger surplus = 11 - textField.text.length;
            if (string.length > surplus)
                return NO;
            // 联系电话 数据保存到实体
            _mRegister.phonenumber = str.length > 0 ? str : nil;
        }
        // 设置标题为正常颜色
        [(UILabel *)textField.leftView setTextColor:kColorGrey2];
    }
    
    return YES;
}

#pragma mark - UISelectorViewDelegate
- (void)selectorView:(UISelectorView *)selectorView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UITextField *tfItem = (UITextField *)[_svMain viewWithTag:kRegisterInputItemStartTag + selectorView.tag];
    // 设置标题为正常颜色
    [(UILabel *)tfItem.leftView setTextColor:kColorGrey2];
    
    // 公司类型
    if (selectorView.tag == 1) {
        if (_companyTypeNames.count > 0) {
            // 显示选中的
            tfItem.text = [NSString stringWithFormat:@"%@", [_companyTypeNames objectAtIndex:row]];
            // 保存数据到实体
            for (NSDictionary *dicItem in _companyTypes) {
                if ([[dicItem objectForKey:@"Name"] isEqualToString:tfItem.text]) {
                    _mRegister.companytype = [NSNumber numberWithInteger:[[dicItem objectForKey:@"Value"] integerValue]];
                    break;
                }
            }
        } else {
            // 设置标题为异常颜色
            [(UILabel *)tfItem.leftView setTextColor:kColorOrange];
        }
    }
    
    // 所在城市
    else if (selectorView.tag == 2) {
        // 省市联动
        if (component == 0) {
            // 城市名称
            NSMutableArray *cityNames = [NSMutableArray array];
            NSArray *citys = [(AreaProvinceItem *)[_provinces objectAtIndex:row] CL];
            for (AreaCityItem *acItem in citys) {
                [cityNames addObject:acItem.CN];
            }
            [selectorView.dataSource replaceObjectAtIndex:1 withObject:cityNames];
            [selectorView reloadComponent:1];
        }
        //获取选中的 省 市
        NSInteger row0 = [(NSIndexPath *)[selectorView.selectedIndexPaths objectAtIndex:0] row];
        NSInteger row1 = [(NSIndexPath *)[selectorView.selectedIndexPaths objectAtIndex:1] row];
        
        AreaProvinceItem *apItem = [_provinces objectAtIndex:row0];
        // 省
        NSString *provinceId = apItem.PI.stringValue;
        NSString *provinceName = apItem.PN;
        // 市
        AreaCityItem *acItem = [apItem.CL objectAtIndex:row1];
        NSString *cityId = acItem.CI.stringValue;
        NSString *cityName = acItem.CN;
        
        // 设置显示数据
        tfItem.text = [NSString stringWithFormat:@"%@ %@", provinceName, cityName];
        
        // 保存数据到实体
        _mRegister.pid = [NSNumber numberWithInteger:provinceId.integerValue];
        _mRegister.cid = [NSNumber numberWithInteger:cityId.integerValue];
    }
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    // 获取键盘高度 和 动画速度
    NSDictionary *userInfo = [notification userInfo];
    CGFloat keyboardHeight = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat animateSpeed = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 过滤重复
    if (_keyboardHeight == keyboardHeight)
        return;
    _keyboardHeight = keyboardHeight;
    
    UIView *vFirstResponder = [self subviewWithFirstResponder];
    CGRect vFirstResponderRect = [_svMain convertRect:vFirstResponder.frame fromView:vFirstResponder.superview];
    vFirstResponderRect.origin.y = vFirstResponderRect.origin.y - _svMain.contentOffset.y + 88; // 标题栏占位偏移
    
    if (vFirstResponder) {
        [UIView animateWithDuration:animateSpeed animations:^{
            _btnCloseKeyboard.maxY = self.height - keyboardHeight + 5;
            _btnCloseKeyboard.alpha = 1;
            
            _svMain.contentInset = UIEdgeInsetsMake(_svMain.contentInset.top, 0, keyboardHeight, 0);
            _svMain.scrollIndicatorInsets = _svMain.contentInset;
            CGFloat offsetHeight = _svMain.height - keyboardHeight - (vFirstResponderRect.origin.y + vFirstResponderRect.size.height);
            if(offsetHeight < 0)
                _svMain.contentOffset = CGPointMake(0, _svMain.contentOffset.y - offsetHeight); // 标题栏占位偏移
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (_keyboardHeight == 0)
        return;
    
    // 获取键盘高度 和 动画速度
    NSDictionary *userInfo = [notification userInfo];
    CGFloat animateSpeed = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    _keyboardHeight = 0;
    
    [UIView animateWithDuration:animateSpeed animations:^{
        _btnCloseKeyboard.maxY = self.height;
        _btnCloseKeyboard.alpha = 0;
        
        _svMain.contentInset = UIEdgeInsetsMake(_svMain.contentInset.top, 0, 0, 0);
        _svMain.scrollIndicatorInsets = _svMain.contentInset;
    }];
}

/** 同意协议 */
- (void)didAgreeProtocol
{
    _btnAgree.selected = NO;
    [self onClickAgreeBtn:_btnAgree];
    [[MainViewController sharedVCMain] closeView:_vProtocol animateOption:AnimateOptionMoveLeft];
}

#pragma mark - APIHelper
- (void)checkDealerInfo:(NSInteger)checktype checkvalue:(NSString *)checkvalue;
{
    // 设置请求完成后回调方法
    [_apiCheckDealerInfo setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        // 正常返回
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode != 0)
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
            }
        }
    }];
    
    [_apiCheckDealerInfo checkDealerInfo:checktype checkvalue:checkvalue];
}

/** 注册 */
- (void)registerDealer
{
    [[AMToastView toastView:YES] showLoading:@"正在操作..." cancel:^{
        [_apiRegister cancel];
        [_apiCheckDealerInfo cancel];
        [[AMToastView toastView] hide];
    }];
    
    __weak UCRegisterDealerView *vRegister = self;
    
    // 设置请求完成后回调方法
    [_apiRegister setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 非取消请求
            if (error.code != ConnectionStatusCancel)
                [[AMToastView toastView] showMessage:@"提交异常，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            return;
        }
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                NSString *message = nil;
                if (mBase.returncode == 0) {
                    [vRegister endEditing:NO];
                    UCRegisterSuccessView *vRegSuc = [[UCRegisterSuccessView alloc] initWithFrame:vRegister.bounds];
                    [[MainViewController sharedVCMain] openView:vRegSuc animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
                } else {
                    message = mBase.message;
                }
                if (message)
                    [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                else
                    [[AMToastView toastView] hide];
            } else {
                [[AMToastView toastView] hide];
            }
        } else {
            [[AMToastView toastView] hide];
        }
    }];
    
    [_apiRegister registerDealer:_mRegister];
}

- (void)dealloc
{
    [_apiRegister cancel];
    [_apiCheckDealerInfo cancel];
    AMLog(@"dealloc...");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
