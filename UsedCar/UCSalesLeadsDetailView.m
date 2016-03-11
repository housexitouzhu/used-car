//
//  UCSalesLeadsDetailView.m
//  UsedCar
//
//  Created by 张鑫 on 14-4-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSalesLeadsDetailView.h"
#import "UCTopBar.h"
#import "AMCacheManage.h"
#import "APIHelper.h"
#import "AMConfigManage.h"
#import "UIImage+Util.h"

#define kOptionBarButtonStartTag        38598736
#define kMaxNumberOfDescriptionChars    200

@interface UCSalesLeadsDetailView ()

@property (nonatomic, strong) UCTopBar *tbTop;

@property (nonatomic, strong) UCCarListView *vCarList;
@property (nonatomic, weak) UCSalesLeadsModel *mSaleLead;
@property (nonatomic) UCSalesLeadsDetailViewStyle viewStyle;
@property (nonatomic, strong) UIView *vAlert;
@property (nonatomic, strong) UILabel *labCallSum;
@property (nonatomic, strong) UILabel *labRemainNum;
@property (nonatomic, strong) UITextView *tvRecord;
@property (nonatomic, strong) APIHelper *apiMark;
@property (nonatomic, strong) APIHelper *apiIgnore;
@property (nonatomic) BOOL isShowRecordAlert;

@end

@implementation UCSalesLeadsDetailView

- (id)initWithFrame:(CGRect)frame viewStyle:(UCSalesLeadsDetailViewStyle)viewStyle saleLeadModel:(UCSalesLeadsModel *)mSaleLead
{
    self = [super initWithFrame:frame];
    if (self) {
        _mSaleLead = mSaleLead;
        _isShowRecordAlert = NO;
        _viewStyle = viewStyle;
        // 导航栏
        [self initTitleView];
        [self initView];
    }
    return self;
}

#pragma mark - initView
/** 初始化导航栏 */
- (void)initTitleView
{
    NSArray *titles = @[@"未处理线索", @"已处理线索", @"无效线索"];
    
    self.backgroundColor = kColorWhite;
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [_tbTop.btnTitle setTitle:[titles objectAtIndex:_viewStyle] forState:UIControlStateNormal];
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_tbTop];
}

/** 创建视图 */
- (void)initView
{
    //监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 用户信息
    UIView *vUserInfoView = [self addUserInfoView:CGRectMake(0, _tbTop.maxY, self.width, 46)];
    // 操作栏
    UIView *vOptionBar = [self addOptionBar:CGRectMake(0, vUserInfoView.maxY, self.width, 46)];
    // 列表
    UIView *vCarList = [self addCarListView:CGRectMake(0, vOptionBar.maxY, self.width, self.height - vOptionBar.maxY)];
    
    [self addSubview:vUserInfoView];
    [self addSubview:vOptionBar];
    [self addSubview:vCarList];
    
    // 加载数据
    [self reloadData];
}

/** 添加用户信息 */
- (UIView *)addUserInfoView:(CGRect)frame
{
    // 用户信息
    UIView *vUserInfo = [[UIView alloc] initWithFrame:frame];
    vUserInfo.backgroundColor = [UIColor whiteColor];
    
    //姓名
    UILabel *labName = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 80, vUserInfo.height)];
    labName.text = _mSaleLead.name;
    labName.backgroundColor = [UIColor clearColor];
    labName.font = kFontLarge;
    labName.textColor = kColorGray1;
    
    // 电话
    UILabel *labTel = [[UILabel alloc] init];
    labTel.backgroundColor = [UIColor clearColor];
    labTel.font = kFontLarge;
    labTel.textColor = kColorGray1;
    labTel.text = _mSaleLead.mobile;
    [labTel sizeToFit];
    labTel.origin = CGPointMake(103, (vUserInfo.height - labTel.height) / 2);
    
    // 辆意向车
    UILabel *labUnit = [[UILabel alloc] init];
    labUnit.backgroundColor = [UIColor clearColor];
    labUnit.font = kFontSmall;
    labUnit.textColor = kColorGrey3;
    labUnit.text = @"辆意向车";
    [labUnit sizeToFit];
    labUnit.origin = CGPointMake(vUserInfo.width - labUnit.width - 15, (vUserInfo.height - labUnit.height) / 2);
    
    // 数量
    UILabel *labNum = [[UILabel alloc] init];
    labNum.backgroundColor = [UIColor clearColor];
    labNum.font = kFontSmall;
    labNum.textColor = kColorOrange;
    labNum.text = [_mSaleLead.carcount stringValue];
    [labNum sizeToFit];
    labNum.origin = CGPointMake(labUnit.minX - labNum.width - 2, (vUserInfo.height - labNum.height) / 2);
    
    [vUserInfo addSubview:labName];
    [vUserInfo addSubview:labTel];
    [vUserInfo addSubview:labNum];
    [vUserInfo addSubview:labUnit];
    [self addSubview:vUserInfo];
    
    return vUserInfo;
}

/** 操作栏 */
- (UIView *)addOptionBar:(CGRect)frame
{
    UIView *vOptionBar = [[UIView alloc] initWithFrame:frame];
    vOptionBar.backgroundColor = kColorWhite;
    
    // 上分割线
    UIImage *iLine = [UIImage imageNamed:@"salesleads_dottedline"];
    UIImageView *ivTopLine = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, vOptionBar.width - 15 * 2, iLine.size.height)];
    ivTopLine.image = iLine;
    // 按钮
    NSInteger btnNum = (_viewStyle == UCSalesLeadsDetailViewStyleProcessed || _viewStyle == UCSalesLeadsDetailViewStyleUntreated) ? 3 : 2;
    NSArray *titles = (_viewStyle == UCSalesLeadsDetailViewStyleProcessed || _viewStyle == UCSalesLeadsDetailViewStyleUntreated) ? @[@"联系他", (_mSaleLead.remark.length > 0 ? @"查看" : @"标注"), @"忽略"] : @[@"联系他", (_mSaleLead.remark.length> 0 ? @"查看" : @"标注")];
    
    CGFloat minY = 0;
    for (int i = 0; i < btnNum; i++) {
        // 按钮
        CGFloat width = (vOptionBar.width / btnNum);
        UIButton *btnItem = [[UIButton alloc] initWithFrame:CGRectMake(minY, 0, width, vOptionBar.height)];
        btnItem.tag = kOptionBarButtonStartTag + i;
        btnItem.titleLabel.font = kFontLarge;
        [btnItem setTitleColor:kColorBlue forState:UIControlStateNormal];
        [btnItem setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [btnItem setBackgroundImage:[UIImage imageWithColor:kColorNewBackground size:btnItem.size] forState:UIControlStateHighlighted];
        [btnItem addTarget:self action:@selector(onClickOptionBarBtn:) forControlEvents:UIControlEventTouchUpInside];
        // 拨打电话
        if (i == 0) {
            UIImage *image = [UIImage imageNamed:@"salesleads_phone"];
            [btnItem setImage:image forState:UIControlStateNormal];
            [btnItem setImage:[UIImage imageNamed:@"salesleads_phone_pre"] forState:UIControlStateHighlighted];
            [btnItem setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -image.size.width + 30, 0.0, 0)];
            [btnItem setImageEdgeInsets:UIEdgeInsetsMake(0.0, -50, 0.0, -[btnItem.titleLabel.text sizeWithFont:btnItem.titleLabel.font].width)];
        }
        [vOptionBar addSubview:btnItem];
        
        minY += width;
    }
    
    // 按钮分割线
    
    // 下分割线
    UIView *vBottomLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, vOptionBar.height - kLinePixel, vOptionBar.width, kLinePixel) color:kColorNewLine];
    
    [vOptionBar addSubview:ivTopLine];
    [vOptionBar addSubview:vBottomLine];

    return vOptionBar;
}

/** 添加列表视图 */
- (UIView *)addCarListView:(CGRect)frame
{
    UIView *vContainer = [[UIView alloc] initWithFrame:frame];
    
    // 列表
    _vCarList = [[UCCarListView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _vCarList.isAllowsSelection = NO;
    _vCarList.isShowSelectedMark = NO;
    
    UIView *vHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _vCarList.width, 20)];
    vHead.backgroundColor = kColorClear;
    [vHead addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, vHead.height - kLinePixel, vHead.width, kLinePixel) color:kColorNewLine]];
    _vCarList.tvCarList.tableHeaderView = vHead;
    
    switch (_viewStyle) {
        case UCSalesLeadsDetailViewStyleUntreated:
            _vCarList.state = 2;
            break;
        case UCSalesLeadsDetailViewStyleProcessed:
            _vCarList.state = 1;
            break;
        case UCSalesLeadsDetailViewStyleInvalidClues:
            _vCarList.state = 3;
            break;
            
        default:
            break;
    }
    
    _vCarList.delegate = self;
    [vContainer addSubview:_vCarList];
    
    return vContainer;
}

#pragma mark - private Method
/** 标记文字 */
- (void)switchRecordAlertView
{
    _isShowRecordAlert = !_isShowRecordAlert;
    NSInteger alertBgTag = 63542657;
    
    UIView *vAlertBg= nil;
    
    if (_isShowRecordAlert) {
        // 初始化
        vAlertBg = [[UIView alloc] initWithFrame:self.bounds];
        vAlertBg.tag = alertBgTag;
        vAlertBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        vAlertBg.alpha = 0.0;
        
        // 提示框
        _vAlert = [[UIView alloc] initWithFrame:CGRectMake((self.width - 260) / 2, (self.height - 145) / 2, 260, 145)];
        _vAlert.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        _vAlert.layer.cornerRadius = 5.0;
        _vAlert.layer.masksToBounds = YES;
        
        // 取消按钮
        for (int i = 0; i < 2; i++) {
            UIButton *btnAlert = [[UIButton alloc] initWithFrame:CGRectMake(_vAlert.width / 2 * i, _vAlert.height - 37, _vAlert.width / 2, 37)];
            btnAlert.backgroundColor = [UIColor clearColor];
            [btnAlert setTitle:i == 0 ? @"取消" : (_mSaleLead.remark.length > 0 ? @"修改":@"添加") forState:UIControlStateNormal];
            btnAlert.tag = i;
            btnAlert.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btnAlert addTarget:self action:@selector(onClickedButtonAtIndex:) forControlEvents:UIControlEventTouchUpInside];
            [btnAlert setTitleColor:kColorBlue1 forState:UIControlStateNormal];
            [_vAlert addSubview:btnAlert];
            
            if (i == 1) {
                // 分割线
                UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, (btnAlert.height - 15) / 2, kLinePixel, 15) color:kColorNewLine];
                [btnAlert addSubview:vLine];
            }
        }
        
        // 分割线
        UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, _vAlert.height - 37, _vAlert.width, kLinePixel) color:kColorNewLine];
        [_vAlert addSubview:vLine];
        
        // 剩余字数
        _labRemainNum = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, _vAlert.width - 6, 15)];
        _labRemainNum.backgroundColor = [UIColor clearColor];
        _labRemainNum.font = kFontSmall;
        _labRemainNum.textColor = kColorGrey3;
        _labRemainNum.textAlignment = NSTextAlignmentRight;
        _labRemainNum.text = [NSString stringWithFormat:@"%d", 200 - _mSaleLead.remark.length];
        [_vAlert addSubview:_labRemainNum];
        
        // 输入栏
        _tvRecord = [[UITextView alloc] initWithFrame:CGRectMake(25, 20, _vAlert.width - 50, _vAlert.height - 37 - 40)];
        _tvRecord.font = kFontLarge;
        _tvRecord.textColor = kColorGrey2;
        _tvRecord.backgroundColor = [UIColor clearColor];
        _tvRecord.textAlignment = NSTextAlignmentLeft;
        _tvRecord.showsVerticalScrollIndicator = YES;
        _tvRecord.delegate = self;
        [_vAlert addSubview:_tvRecord];
        // 标注内容
        _tvRecord.text = _mSaleLead.remark;
        
        if (_tvRecord.text.length == 0)
            [_tvRecord becomeFirstResponder];
        
        // 关闭当前页
        UIControl *vBack = [[UIControl alloc] initWithFrame:vAlertBg.bounds];
        
        [vAlertBg addSubview:vBack];
        [vAlertBg addSubview:_vAlert];
        [self addSubview:vAlertBg];
    }
    else
        vAlertBg = (UIView *)[self viewWithTag:alertBgTag];
    
    [UIView animateWithDuration:kAnimateSpeedFast animations:^{
        vAlertBg.alpha = _isShowRecordAlert == YES ? 1.0 :0.0;
    } completion:^(BOOL finished) {
        if (!_isShowRecordAlert)
            [vAlertBg removeFromSuperview];
    }];
}

/** 加载数据 */
- (void)reloadData
{
    _vCarList.mobile = _mSaleLead.mobile;
    _vCarList.viewStyle = UCCarListViewStyleAttention;
    [_vCarList refreshCarList];
}

//显示键盘
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRect = [self keyboardRect: notification];
    
    [UIView animateWithDuration: 0.25 animations:^{
        _vAlert.maxY = self.height - keyboardRect.size.height - 10;
    }];
}
//关闭键盘
- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([_tvRecord isFirstResponder]) {
        [UIView animateWithDuration: 0.25 animations:^{
            _vAlert.minY = (self.height - 145) / 2;
        }];
    }
}

- (CGRect)keyboardRect:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    return [value CGRectValue];
}

#pragma mark - onClickButton
/** 返回 */
- (void)onClickBackBtn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/** 操作项按钮 */
- (void)onClickOptionBarBtn:(UIButton *)btn
{
    // 屏蔽连续点击
    if (![OMG isValidClick])
        return;

    // 联系他
    if (btn.tag == kOptionBarButtonStartTag + 0) {
        if (_viewStyle == UCSalesLeadsDetailViewStyleUntreated) {
            [UMStatistics event:c_4_1_buiness_clues_untreatedclues_phone];
        } else if (_viewStyle == UCSalesLeadsDetailViewStyleProcessed) {
            [UMStatistics event:c_4_1_buiness_clues_haveclues_phone];
        }
        
        // 增加拨打字数
        [AMCacheManage addCurrentCallRecord:_mSaleLead.mobile];
        // 拨打
        [OMG callPhone:_mSaleLead.mobile];
         // 设置已处理
        if (_viewStyle == UCSalesLeadsDetailViewStyleUntreated) {
            [self apiSetSalesLeadsState:1 mobile:_mSaleLead.mobile offerids:nil];
        }
        
        // 同步拨打记录
        [AMConfigManage updateCallRecords];
    }
    // 标注
    else if (btn.tag == kOptionBarButtonStartTag + 1) {
        [self switchRecordAlertView];
    }
    // 忽略
    else if (btn.tag == kOptionBarButtonStartTag + 2) {
        
        [UMStatistics event:c_3_5_ignoreclick];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否确认忽略该条线索" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = btn.tag;
        [alert show];
    }
}

/** "取消" or "确定" 按钮 */
- (void)onClickedButtonAtIndex:(UIButton *)button
{
    // 确定
    if (button.tag == 1) {
        if ([_tvRecord.text isEqualToString:_mSaleLead.remark]) {
            [[AMToastView toastView] showMessage:@"标注内容没有变化，请更改后操作" icon:kImageRequestError duration:AMToastDurationNormal];
        } else {
            // 设置标注内容
            [self apiSetSalesLeadsMarkWithTel:_mSaleLead.mobile mark:_tvRecord.text.length > 0 ? _tvRecord.text : @""];
        }
    }
    // 取消
    else {
        [self switchRecordAlertView];
    }
    
}

// 有效和无效
#pragma mark - UCCarListViewDelegate
/** 统计事件 */
- (void)carListViewLoadData:(UCCarListView *)vCarList
{
    // 有效销售线索详情页
    if (_viewStyle == UCSalesLeadsDetailViewStyleInvalidClues) {
        [UMStatistics event:pv_3_5_invalidcueend];
        
        if ([AMCacheManage currentUserType] == UserStyleBusiness) {
            UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
            
            [UMSAgent postEvent:invalidcueend_pv page_name:NSStringFromClass(self.class)
                     eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 mUserInfo.userid, @"userid#4", nil]];
        } else {
            [UMSAgent postEvent:invalidcueend_pv page_name:NSStringFromClass(self.class)];
        }
    }
    
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > kMaxNumberOfDescriptionChars)
        _labRemainNum.text = @"0";
    else
        _labRemainNum.text = [NSString stringWithFormat:@"%d", kMaxNumberOfDescriptionChars - textView.text.length];
    if (textView.text.length > kMaxNumberOfDescriptionChars) {
        textView.text = [textView.text substringToIndex:kMaxNumberOfDescriptionChars];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 忽略
    if (alertView.tag == kOptionBarButtonStartTag + 2 && buttonIndex == 1) {
        // state:1.已阅 2.忽略
        [self apiSetSalesLeadsState:2 mobile:_mSaleLead.mobile offerids:nil];
    }
}

#pragma mark - APIHelper
/** 标记 */
- (void)apiSetSalesLeadsMarkWithTel:(NSString *)mobile mark:(NSString *)mark
{
    if (!_apiMark)
        _apiMark = [[APIHelper alloc] init];
    else
        [_apiMark cancel];
    
    [[AMToastView toastView:YES] showLoading:@"正在操作..." cancel:^{
        [_apiMark cancel];
        [[AMToastView toastView] hide];
    }];
    
    __weak UCSalesLeadsDetailView *vSalesLeadsDetail = self;

    // 设置请求完成后回调方法
    [_apiMark setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        // 发生错误
        if (error) {
            // 非取消请求
            if (error.code != ConnectionStatusCancel)
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            else
                [[AMToastView toastView] hide];
        }
        // 正常返回
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                // 标注成功
                if (mBase.returncode == 0) {
                    // 替换新标注
                    vSalesLeadsDetail.mSaleLead.remark = vSalesLeadsDetail.tvRecord.text;
                    // 更新按钮文字
                    UIButton *btnMark = (UIButton *)[vSalesLeadsDetail viewWithTag:kOptionBarButtonStartTag + 1];
                    [btnMark setTitle:vSalesLeadsDetail.mSaleLead.remark.length > 0 ? @"查看" : @"标注" forState:UIControlStateNormal];
                    // 关闭输入框
                    [vSalesLeadsDetail switchRecordAlertView];
                    [[AMToastView toastView] hide];
                } else {
                    NSString *message = mBase.message;
                    if (message)
                        [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                    else
                        [[AMToastView toastView] hide];
                }
            } else {
                [[AMToastView toastView] hide];
            }
        }

    }];
    [_apiMark setSalesLeadsMarkWithTel:mobile mark:mark];
}

/** 忽略 && 处理˚*/
- (void)apiSetSalesLeadsState:(NSInteger)state mobile:(NSString *)mobile offerids:(NSArray *)offerids
{
    if (!_apiIgnore)
        _apiIgnore = [[APIHelper alloc] init];
    else
        [_apiIgnore cancel];
    
    [[AMToastView toastView:YES] showLoading:@"正在操作..." cancel:^{
        [_apiIgnore cancel];
        [[AMToastView toastView] hide];
    }];
    
    __weak UCSalesLeadsDetailView *vSalesLeadsDetail = self;
    
    // 设置请求完成后回调方法
    [_apiIgnore setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        // 发生错误
        if (error) {
            // 非取消请求
            if (error.code != ConnectionStatusCancel)
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            else {
                [[AMToastView toastView] hide];
            }
        }
        // 正常返回
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    // 操作成功
                    if (state == 2) {
                        if ([vSalesLeadsDetail.delegate respondsToSelector:@selector(UCSalesLeadsDetailView:ignoreSuccess:)]) {
                            [vSalesLeadsDetail.delegate UCSalesLeadsDetailView:vSalesLeadsDetail ignoreSuccess:vSalesLeadsDetail.mSaleLead];
                        };
                    }
                    // 处理
                    else if (state == 1) {
                        if ([vSalesLeadsDetail.delegate respondsToSelector:@selector(UCSalesLeadsDetailView:handleSuccess:)]) {
                            [vSalesLeadsDetail.delegate UCSalesLeadsDetailView:vSalesLeadsDetail handleSuccess:vSalesLeadsDetail.mSaleLead];
                        };
                    }
                   
                    [[AMToastView toastView] hide];
                    // 关闭页面
                    [[MainViewController sharedVCMain] closeView:vSalesLeadsDetail animateOption:AnimateOptionMoveLeft];
                } else {
                    NSString *message = mBase.message;
                    if (message)
                        [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                    else
                        [[AMToastView toastView] hide];
                }
            } else
                [[AMToastView toastView] hide];
        }
        
    }];
    [_apiIgnore setSalesLeadsState:state mobile:mobile offerids:offerids];
}

- (void)dealloc
{
    [_apiMark cancel];
    [_apiIgnore cancel];
    [[AMToastView toastView] hide];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
