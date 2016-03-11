//
//  UCAddSalesPerson.m
//  UsedCar
//
//  Created by 张鑫 on 14-5-22.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCAddSalesPerson.h"
#import "UCTopBar.h"
#import "NSString+Util.h"
#import "SalesPersonModel.h"
#import "APIHelper.h"
#import "AMCacheManage.h"

#define kSalesPersonStartTag            2000
#define kSalesPersonName                2000
#define kSalesPersonPhone               2001
#define kSalesPersonQQ                  2002

#define kSalesPersonMarkStartTag        3000 // textField提示文字的索引

@interface UCAddSalesPerson ()

@property (nonatomic, strong) UIScrollView *svMain;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) SalesPersonModel *mSalesPerson;
@property (nonatomic, strong) APIHelper *apiAddSalesPerson;

@end

@implementation UCAddSalesPerson

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [UMStatistics event:pv_3_6_salesadded];
        
        _titles = [NSArray arrayWithObjects:@"姓名：", @"联系电话：", @"QQ：", nil];
        _mSalesPerson = [[SalesPersonModel alloc] init];
        _apiAddSalesPerson = [[APIHelper alloc] init];
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorWhite;
    // 导航栏
    UCTopBar *vTopBar = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    // 滑动栏
    _svMain = [[UIScrollView alloc] initWithFrame:CGRectMake(0, vTopBar.maxY, self.width, self.height - vTopBar.height)];
    // 输入栏
    UIView *vInput = [self addInputView:CGRectMake(0, 0, _svMain.width, 0)];
    
    _svMain.contentSize = CGSizeMake(_svMain.width, vInput.height);
    
    [_svMain addSubview:vInput];
    [self addSubview:vTopBar];
    [self addSubview:_svMain];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    [vTopBar.btnTitle setTitle:@"添加销售代表" forState:UIControlStateNormal];
    [vTopBar.btnRight setTitle:@"提交" forState:UIControlStateNormal];
    [vTopBar.btnRight addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

/** 输入栏 */
- (UIView *)addInputView:(CGRect)frame
{
    UIView *vInput = [[UIView alloc] initWithFrame:frame];
    
    CGFloat inputMinY = 0;
    CGFloat itemHeight = 50;
    
    // 姓名、联系电话、QQ
    for (int i = 0; i < _titles.count; i++) {
        // 输入框
        UITextField *tfItem = [[UITextField alloc] initWithFrame:CGRectMake(20, inputMinY, vInput.width - 20, itemHeight)];
        tfItem.tag = kSalesPersonStartTag + i;
        tfItem.keyboardType = UIKeyboardTypeNumberPad;
        tfItem.delegate = self;
        tfItem.leftViewMode = UITextFieldViewModeAlways;
        tfItem.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        // 左视图
        UILabel *labLeft = [[UILabel alloc] init];
        labLeft.backgroundColor = [UIColor clearColor];
        labLeft.textColor = kColorGray1;
        labLeft.font = kFontLarge;
        labLeft.font = [UIFont systemFontOfSize:16];
        labLeft.text = [_titles objectAtIndex:i];
        [labLeft sizeToFit];
        labLeft.origin = CGPointMake(0, (tfItem.height - labLeft.height) / 2);
        
        if ([labLeft.text hasPrefix:@"姓名"]) {
            tfItem.keyboardType = UIKeyboardTypeDefault;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:tfItem];
        } else if ([labLeft.text hasPrefix:@"QQ"]) {
            UILabel *labMark = [[UILabel alloc] init];
            labMark.text = @"（非必填项）";
            labMark.font = kFontTiny;
            labMark.textColor = kColorGrey3;
            labMark.tag = kSalesPersonMarkStartTag + i;
            [labMark sizeToFit];
            labMark.origin = CGPointMake(37, (tfItem.height - labMark.height) / 2);
            [tfItem addSubview:labMark];
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

#pragma mark - method
- (BOOL)checkAddSalesPersonData
{
    BOOL isContinue = YES;
    
    NSMutableArray *errors = [NSMutableArray array];
    
    // 2项填写内容
    for (int i = 0; i < _titles.count - 1; i++) {
        UITextField *tfItem = (UITextField *)[self viewWithTag:kSalesPersonStartTag + i];
        if ([tfItem.text trim].length == 0) {
            [errors addObject:[NSNumber numberWithInteger:tfItem.tag]];
            // 标题红色
            UILabel *labItem = (UILabel *)tfItem.leftView;
            labItem.textColor = kColorRed;
        }
    }
    
    if (errors.count > 0) {
        [[AMToastView toastView] showMessage:[NSString stringWithFormat:@"您还有%d项未填写", errors.count] icon:kImageRequestError duration:AMToastDurationNormal];
        return NO;
    }
    
    // 联系人正确性
    UITextField *tfPeople = (UITextField *)[self viewWithTag:kSalesPersonName];
    if ([tfPeople.text trim].length < 2 || [tfPeople.text trim].length > 4) {
        [[AMToastView toastView] showMessage:@"输入错误，请填写2-4个汉字" icon:kImageRequestError duration:AMToastDurationNormal];
        return NO;
    }
    
    // 联系手机正确性
    UITextField *tfPhone = (UITextField *)[self viewWithTag:kSalesPersonPhone];
    if ([tfPhone.text trim].length != 11) {
        [[AMToastView toastView] showMessage:@"输入错误，请正确填写手机号" icon:kImageRequestError duration:AMToastDurationNormal];
        return NO;
    }
    
    return isContinue;
}

#pragma mark - onClickButton
- (void)onClickTopBar:(UIButton *)btn
{
    // 返回
    if (btn.tag == UCTopBarButtonLeft) {
        if ([_delegate respondsToSelector:@selector(UCAddSalesPerson:isSuccess:)]) {
            [_delegate UCAddSalesPerson:self isSuccess:NO];
        }
    }
    // 提交
    else if (btn.tag == UCTopBarButtonRight) {
        
        [UMStatistics event:c_3_6_salesadded_submit];
        
        // 检验数据正确性
        BOOL isContinue = [self checkAddSalesPersonData];
        
        // 注册
        if (isContinue) {
            [self addSalesPerson];
        }
    }
}

#pragma mark - UITextFieldDelegate
/* textFieldDidEndEditing 中文上屏监听不响应, 使用通知监听 */
- (void)textFieldTextDidChange:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UITextField class]]) {
        UITextField *textField = notification.object;
        if (textField.markedTextRange == nil) {
            // 姓名
            if (textField.tag == kSalesPersonName) {
                if (textField.text.length > 4)
                    textField.text = [textField.text substringToIndex:4];
                _mSalesPerson.salesname = textField.text;
            }
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // 去除前后空格
    textField.text = [textField.text trim];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *str = [NSMutableString stringWithString:textField.text];
    if (string.length > 0)
        [str insertString:string atIndex:range.location];
    else
        [str deleteCharactersInRange:range];
    
    // 联系电话
    if (textField.tag == kSalesPersonPhone) {
        // 禁止空格
        unichar uc = [string characterAtIndex: [string length]-1];
        //禁止输入空格 ASCII ==32
        if (uc == 32)
            return NO;
        
        // 限制字数
        NSInteger surplus = 11 - textField.text.length;
        if (string.length > surplus)
            return NO;
        // 保存联系人model
        _mSalesPerson.salesphone = str.length > 0 ? str : nil;
    }
    else if (textField.tag == kSalesPersonQQ) {
        // 禁止空格
        unichar uc = [string characterAtIndex: [string length]-1];
        //禁止输入空格 ASCII ==32
        if (uc == 32)
            return NO;
        
        // 限制字数
        NSInteger surplus = 20 - textField.text.length;
        if (string.length > surplus)
            return NO;
        // 联系QQ 数据保存到实体
        _mSalesPerson.salesqq = str.length > 0 ? str : nil;
        
        // 显示隐藏说明文字
        UILabel *labMark = (UILabel *)[self viewWithTag:kSalesPersonMarkStartTag + (textField.tag - kSalesPersonStartTag)];
        labMark.hidden = str.length > 0 ? YES : NO;
    }
    
    // 设置标题为正常颜色
    [(UILabel *)textField.leftView setTextColor:kColorGrey2];
    
    return YES;
}

#pragma mark - APIHelper
- (void)addSalesPerson
{
    [[AMToastView toastView:YES] showLoading:@"正在操作..." cancel:^{
        [_apiAddSalesPerson cancel];
        [[AMToastView toastView] hide];
    }];
    
    __weak UCAddSalesPerson *vAddSalesPerson = self;
    
    // 设置请求完成后回调方法
    [_apiAddSalesPerson setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
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
                    // 关闭键盘
                    [vAddSalesPerson endEditing:NO];
                    // 更新本地数据
                    UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
                    SalesPersonModel *mSalesPerson = [[SalesPersonModel alloc] initWithJson:mBase.result];
                    if (mUserInfo.salespersonlist.count > 0)
                        [mUserInfo.salespersonlist insertObject:mSalesPerson atIndex:0];
                    else
                        [mUserInfo.salespersonlist addObject:mSalesPerson];
                    [AMCacheManage setCurrentUserInfo:mUserInfo];
                    // 关闭页面
                    [[MainViewController sharedVCMain] closeView:vAddSalesPerson animateOption:AnimateOptionMoveLeft];
                    if ([vAddSalesPerson.delegate respondsToSelector:@selector(UCAddSalesPerson:isSuccess:)]) {
                        [vAddSalesPerson.delegate UCAddSalesPerson:vAddSalesPerson isSuccess:YES];
                    }
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
    
    [_apiAddSalesPerson addSalesPerson:_mSalesPerson];
}

- (void)dealloc
{
    AMLog(@"dealloc...");
    [[AMToastView toastView] hide];
    [_apiAddSalesPerson cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
