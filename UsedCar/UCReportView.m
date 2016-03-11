//
//  UCReportView.m
//  UsedCar
//
//  Created by wangfaquan on 14-6-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCReportView.h"
#import "UCTopBar.h"
#import "UCChooseCarView.h"
#import "UIImage+Util.h"
#import "UCFilterBrandView.h"
#import "UCFilterModel.h"
#import "APIHelper.h"
#import "UCContactUsView.h"

#define KPhoneStartTag     10000000
#define KTextViewStartTag  10000001
#define KlabelStartTag     10000002
#define KbuttenStartTag    20000000
#define KlabPhoneTag       30000000

@interface UCReportView ()

@property (nonatomic, retain) UIScrollView *svReport;
@property (nonatomic, retain) UIView *vReport;
@property (nonatomic, retain) UIView *vDetailDes;
@property (nonatomic, retain) UIView *vPhone;
@property (nonatomic, strong) UILabel *labCarName;
@property (nonatomic, strong) UIButton *btnRepots ;
@property (nonatomic, strong) UCFilterModel *mFilter;
@property (nonatomic, strong) NSMutableArray *arrRtports;
@property (nonatomic, strong) UILabel *labRequire;
@property (nonatomic, strong) UILabel *labRequire1;
@property (nonatomic, strong) UIImageView * arrowImage;
@property (nonatomic, strong) UIButton *btnErrReport;
@property (nonatomic, strong) UIButton *btnErrDescrpt;
@property (nonatomic, strong) UIButton *btnErrPhone;
@property (nonatomic, strong) UILabel *labPhone;
@property (nonatomic, strong) UILabel *labDetailDes;
@property (nonatomic, strong) UILabel *labReport;
@property (nonatomic, strong) APIHelper *apiHelper;
@property (nonatomic, strong) NSString *carBrind;

@end

@implementation UCReportView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    _arrRtports = [[NSMutableArray alloc] init];
    _mFilter = [[UCFilterModel alloc] init];
    UCTopBar *vTopBar = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    // 创建一个UIScrollView
    _svReport = [[UIScrollView alloc] initWithFrame:CGRectMake(0, vTopBar.maxY, self.width, self.height - vTopBar.height)];
    
    // 垂直方向的滚动指示
    _svReport.showsVerticalScrollIndicator =YES;
    _svReport.showsHorizontalScrollIndicator = NO;
    _svReport.scrollEnabled = YES;
    _svReport.delegate = self;
    _svReport.backgroundColor = kColorNewBackground;
    _labReport = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 50, 20)];
    _labReport.backgroundColor = [UIColor clearColor];
    _labReport.text = @"举报类型";
    _labReport.font = kFontSmall;
    _labReport.textColor = kColorNewGray2;
    
    // 图片
    UIImage *iSelect = [UIImage imageNamed:@"report_attention_icon"];
    // 创建提交报错提示语
    _btnErrReport = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 120, 20)];
    [_btnErrReport setTitle:@"请选择举报类型" forState:UIControlStateNormal];
    _btnErrReport.titleLabel.font = kFontSmall;
    _btnErrReport.backgroundColor = [UIColor clearColor];
    _btnErrReport.hidden = YES;
    [_btnErrReport setImage:iSelect forState:UIControlStateNormal];
    [_btnErrReport setImage:[UIImage imageNamed:@"contrast_choose_btn_h"] forState:UIControlStateSelected];
    [_btnErrReport setTitleColor:kColorNeWRed forState:UIControlStateNormal];
    
    // 设置图片和标题位置
    _btnErrReport.titleEdgeInsets = UIEdgeInsetsMake(17, 0, 18,0);
    _btnErrReport.imageEdgeInsets = UIEdgeInsetsMake(0, -100, 0, -_btnErrReport.titleLabel.bounds.size.width); //{top, left, bottom, right}
    
     _vReport = [self creatRepotView:CGRectMake(0, 36, self.width, 202)];
    // 分割线
    UIView *vLines = [[UIView alloc] initLineWithFrame:CGRectMake(0, 35, self.width, kLinePixel) color:kColorNewLine];
    [_svReport addSubview:vLines];
    
    _vDetailDes = [self creatDetailDescriptionView:CGRectMake(0, _vReport.maxY, self.width, 105)];
    _vDetailDes.backgroundColor = kColorNewBackground;

    _vPhone = [self creatPhoneView:CGRectMake(0, _vDetailDes.maxY, self.width, 70)];
    _vPhone.backgroundColor = kColorNewBackground;
    
    UCContactUsView *vContactUs = [[UCContactUsView alloc] initWithFrame:CGRectMake(0, (_svReport.height - (_vPhone.maxY + 86) > 0) ? _svReport.height - 86 : _vPhone.maxY, self.width, 86)
                                                      withStatementArray:@[@"举报咨询电话：010-59857692", @"您在举报中有任何疑问请致电"] andPhoneNumber:@"01059857692"];
    
    _svReport.contentSize = CGSizeMake(self.width, vContactUs.maxY);
   
    // 触摸关闭键盘
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(closeKeyboard)];
    singleFingerOne.numberOfTapsRequired = 1;
    singleFingerOne.numberOfTouchesRequired = 1;
    singleFingerOne.delegate = self;
    [self addGestureRecognizer:singleFingerOne];
    
    
    [_svReport addSubview:_btnErrReport];
    [_svReport addSubview:_labReport];
    [_svReport addSubview:_vReport];
    [_svReport addSubview:_vDetailDes];
    [_svReport addSubview:_vPhone];
    [_svReport addSubview:vContactUs];
    [self addSubview:_svReport];
    [self addSubview:vTopBar];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    [vTopBar.btnTitle setTitle:@"车源举报" forState:UIControlStateNormal];
    [vTopBar.btnRight setTitle:@"提交" forState:UIControlStateNormal];
    [vTopBar.btnRight addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    return vTopBar;
}

/** 创建举报类型视图 */
- (UIView *)creatRepotView:(CGRect)frame
{
    UIView *vReport = [[UIView alloc] initWithFrame:frame];
    vReport.backgroundColor = kColorWhite;
    
    // 创建纠错按钮
    _btnRepots = [[UIButton alloc] initWithFrame:CGRectMake(10, 15, self.width - 20, 35)];
    [_btnRepots setTitle:@"车型纠错" forState:UIControlStateNormal];
    [_btnRepots addTarget:self action:@selector(onCilckBtnRepot:) forControlEvents:UIControlEventTouchUpInside];
    _btnRepots.tag = 1000;
    [_btnRepots setTitleColor:kColorWhite forState:UIControlStateSelected];
    [_arrRtports addObject:_btnRepots];
    _btnRepots.layer.cornerRadius = 1;
    _btnRepots.layer.masksToBounds = YES;
    _btnRepots.layer.borderWidth = 1.0;
    _btnRepots.layer.borderColor = kColorNewLine.CGColor;
    [_btnRepots setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
    _btnRepots.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _btnRepots.titleEdgeInsets = UIEdgeInsetsMake(0, 32, 0, 0);
    _btnRepots.titleLabel.font = kFontLarge;
    [_btnRepots setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:_btnRepots.size] forState:UIControlStateHighlighted];
    [_btnRepots setBackgroundImage:[UIImage imageWithColor:kColorOrange size:_btnRepots.size] forState:UIControlStateSelected];
    
    // 创建箭头
    _arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 48, 9, 18, 18)];
    _arrowImage.image = [UIImage imageNamed:@"set_arrow_right"];
    
    
    // 创建车名
    _labCarName = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 180, 20)];
    _labCarName.font = kFontTiny;
    _labCarName.backgroundColor = [UIColor clearColor];
    _labCarName.textColor = kColorNewGray1;

    NSArray *arrTitles = @[@"此车已售",@"价格过低",@"无法过户",@"索要定金",@"联系不上",@"其他类型"];
    CGFloat minX = 0;
    CGFloat minY = 0;
    // 遍历数值创建button
    for (int i = 0; i < [arrTitles count]; i++) {
        UIButton *btnRepot = [[UIButton alloc] initWithFrame:CGRectMake(10 + minX, minY + _btnRepots.maxY + 10, (self.width - 10 *2 - 20) / 2, 35)];
        [btnRepot setTitle:[arrTitles objectAtIndex:i] forState:UIControlStateNormal];
        // 设置边框
        btnRepot.layer.cornerRadius = 1.5;
        btnRepot.layer.masksToBounds = YES;
        btnRepot.tag = KbuttenStartTag + i;
        btnRepot.layer.borderWidth = 1.0;
        btnRepot.layer.borderColor = kColorNewLine.CGColor;
        [btnRepot setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
        // 创建文字
        btnRepot.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btnRepot.titleEdgeInsets = UIEdgeInsetsMake(0, 32, 0, 0);
        btnRepot.titleLabel.font = [UIFont systemFontOfSize:15];
        [btnRepot addTarget:self action:@selector(onClickRepotBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnRepot setTitleColor:kColorWhite forState:UIControlStateSelected];
        [btnRepot setBackgroundImage:[UIImage imageWithColor:kColorOrange size:_btnRepots.size] forState:UIControlStateSelected];
        [vReport addSubview:btnRepot];
        minX += (self.width - 10 *2 - 20) / 2 + 20;
        if (i == 1 || i == 3  ) {
            minY += 45 ;
            minX = 0;
        }
        [_arrRtports addObject:btnRepot];
    }
    [_btnRepots addSubview:_arrowImage];
    [_btnRepots addSubview:_labCarName];
    [vReport addSubview:_btnRepots];
    return vReport;
}

/** 创建详细描述视图 */
- (UIView *)creatDetailDescriptionView:(CGRect)frame
{
    // 描述视图
    UIView *vDetailDes = [[UIView alloc] initWithFrame:CGRectMake(0, _vReport.maxY, self.width, 105)];
    _labDetailDes = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 50, 20)];
    _labDetailDes.text = @"详细描述";
    _labDetailDes.font = kFontSmall;
    _labDetailDes.textColor = kColorNewGray2;
    _labDetailDes.backgroundColor = [UIColor clearColor];
    
    // 图片
    UIImage *iSelect = [UIImage imageNamed:@"report_attention_icon"];
    
    
    // 创建提交报错提示语
    _btnErrDescrpt = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 120, 20)];
    [_btnErrDescrpt setTitle:@"请填写描述信息" forState:UIControlStateNormal];
    _btnErrDescrpt.titleLabel.font = [UIFont systemFontOfSize:13];
    _btnErrDescrpt.backgroundColor = [UIColor clearColor];
    [_btnErrDescrpt setImage:iSelect forState:UIControlStateNormal];
    [_btnErrDescrpt setImage:[UIImage imageNamed:@"contrast_choose_btn_h"] forState:UIControlStateSelected];
    [_btnErrDescrpt setTitleColor:kColorNeWRed forState:UIControlStateNormal];
    
    // 设置图片和标题位置
    _btnErrDescrpt.titleEdgeInsets = UIEdgeInsetsMake(17, 0, 18,0);
    _btnErrDescrpt.imageEdgeInsets = UIEdgeInsetsMake(0, -100, 0, -_btnErrDescrpt.titleLabel.bounds.size.width); //{top, left, bottom, right}
    _btnErrDescrpt.hidden = YES;
    
    // Label 必填
    _labRequire = [[UILabel alloc] initWithFrame:CGRectMake(_labDetailDes.maxX, 12, 50, 20)];
    _labRequire.font = kFontSmall;
    _labRequire.textColor = kColorNewGray2;
    _labRequire.text = @"(必填)";
    _labRequire.hidden = YES;
    _labRequire.backgroundColor = [UIColor clearColor];
    
    // 分割线
    UIView *vLines = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine];
    [vDetailDes addSubview:vLines];
    UIView *vLines1 = [[UIView alloc] initLineWithFrame:CGRectMake(0, 35, self.width, kLinePixel) color:kColorNewLine];
  
    // 字数
    UILabel *labCount = [[UILabel alloc] initWithClearFrame:CGRectMake(self.width - 40, 10, 40, 20)];
    labCount.tag = KlabelStartTag;
    labCount.textColor =  kColorNewGray2;
    labCount.font = [UIFont systemFontOfSize:13];
    labCount.text = @"100";
    
    // 创建视图
    UIView *vDes = [[UIView alloc] initWithFrame: CGRectMake(0, 36, 17, 70)];
    vDes.backgroundColor = kColorWhite;
    
    // 创建小笔
    UIImageView *ivPic = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 12, 12)];
    [ivPic setImage:[UIImage imageNamed:@"sellcar_publish_butten"]];
    
    // textView
    UITextView *tvDstailDes = [[UITextView alloc] initWithFrame:CGRectMake(17, 36, self.width - 17, 70)];
    tvDstailDes.delegate = self;
    tvDstailDes.tag = KTextViewStartTag;
    tvDstailDes.font = kFontNormal;
    
    [vDetailDes addSubview:_btnErrDescrpt];
    [vDetailDes addSubview:_labRequire];
    [vDetailDes addSubview:labCount];
    [vDetailDes addSubview:vLines1];
    [vDetailDes addSubview:_labDetailDes];
    [vDetailDes addSubview:tvDstailDes];
    [vDes addSubview:ivPic];
    [vDetailDes addSubview:vDes];
    return vDetailDes;
}

/** 创建拨打电话视图 */
- (UIView *)creatPhoneView:(CGRect)frame
{
    // 创建电话号码视图
    UIView *vPhone = [[UIView alloc] initWithFrame:frame];
    _labPhone = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 220, 20)];
    _labPhone.text = @"请留下您的手机号,以便我们尽快与您联系";
    _labPhone.font = kFontSmall;
    _labPhone.textColor = kColorNewGray2;
    _labPhone.backgroundColor = [UIColor clearColor];
    _labPhone.tag = KlabPhoneTag;
    
    // 图片
    UIImage *iSelect = [UIImage imageNamed:@"report_attention_icon"];
    // 创建提交报错提示语
    _btnErrPhone = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 150, 20)];
    [_btnErrPhone setTitle:@"请填写正确的手机号" forState:UIControlStateNormal];
    _btnErrPhone.titleLabel.font = kFontSmall;
    _btnErrPhone.backgroundColor = [UIColor clearColor];
    [_btnErrPhone setImage:iSelect forState:UIControlStateNormal];
    [_btnErrPhone setImage:[UIImage imageNamed:@"contrast_choose_btn_h"] forState:UIControlStateSelected];
    [_btnErrPhone setTitleColor:kColorNeWRed forState:UIControlStateNormal];
    
    // 设置图片和标题位置
    _btnErrPhone.titleEdgeInsets = UIEdgeInsetsMake(17, 10, 18,0);
    _btnErrPhone.imageEdgeInsets = UIEdgeInsetsMake(0, -128, 0, -_btnErrPhone.titleLabel.bounds.size.width); //{top, left, bottom, right}
    _btnErrPhone.hidden = YES;
    
    // Label 必填
    _labRequire1 = [[UILabel alloc] initWithFrame:CGRectMake(_labPhone.maxX, 10, 50, 20)];
    _labRequire1.font = kFontSmall;
    _labRequire1.textColor = kColorNewGray2;
    _labRequire1.text = @"(必填)";
    _labRequire1.hidden = YES;
    _labRequire1.backgroundColor = [UIColor clearColor];

    // 分割线
    UIView *vLines = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine];
    [vPhone addSubview:vLines];
    UIView *vLines1 = [[UIView alloc] initLineWithFrame:CGRectMake(0, 36, self.width, kLinePixel) color:kColorNewLine];
    [vPhone addSubview:vLines1];
    
    UITextField *tfPhone = [[UITextField alloc] initWithFrame:CGRectMake(24, vLines1.maxY, self.width -24, 35)];
    tfPhone.delegate = self;
    
    // 创建视图
    UIView *vPLeft = [[UIView alloc] initWithFrame: CGRectMake(0, vLines1.maxY, 24, 35)];
    vPLeft.backgroundColor = kColorWhite;
    
    // 设置车源举报的文字出现位置
    UIImageView *ivLeft = [[UIImageView alloc] initWithFrame:CGRectMake(10, 11, 12, 12)];
    [ivLeft setImage:[UIImage imageNamed:@"sellcar_publish_butten"]];
    
   // tfPhone.leftView = ivLeft;

    tfPhone.keyboardType = UIKeyboardTypeNumberPad;
    
    // 设置一键清除功能
    tfPhone.clearButtonMode = UITextFieldViewModeWhileEditing;
    tfPhone.font = kFontNormal;
    tfPhone.backgroundColor = kColorWhite;
    tfPhone.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

    tfPhone.tag = KPhoneStartTag;
    tfPhone.leftViewMode = UITextFieldViewModeAlways;
    [vPhone addSubview:_btnErrPhone];
    [vPhone addSubview:_labRequire1];
    [vPhone addSubview:_labPhone];
    [vPhone addSubview:tfPhone];
    [vPLeft addSubview:ivLeft];
    [vPhone addSubview:vPLeft];
    return vPhone;
}

#pragma mark - private Method
/** 收键盘 */
- (void)closeKeyboard
{
    [UIView animateWithDuration:0.25 animations:^{
        _svReport.minY = 65;
    }];
    UITextField *tfItem1 = (UITextField *)[self viewWithTag:KPhoneStartTag];
    [tfItem1 resignFirstResponder];
    UITextView *tfItem2 = (UITextView *)[self viewWithTag:KTextViewStartTag];
    [tfItem2 resignFirstResponder];
}

#pragma mark - onClickButton
- (void)onClickTopBar:(UIButton *)btn
{
    if (btn.tag == UCTopBarButtonLeft) {
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    } else if (btn.tag == UCTopBarButtonRight) {
        UITextField *tfTelephone = (UITextField *)[self viewWithTag:KPhoneStartTag];
        UITextView *tfDesrpt = (UITextView *)[self viewWithTag:KTextViewStartTag ];

        // 对手机号做判断
        if ( 0 < tfTelephone.text.length && tfTelephone.text.length < 11) {
            [[AMToastView toastView] showMessage:@"请输入正确的手机号" icon:kImageRequestError duration:AMToastDurationNormal];
        } else {
            // 遍历button
            for (int i = 0; i < [_arrRtports count]; i++) {
                
               // 判断这些button的选中状态
                if (((UIButton *)_arrRtports[0]).selected == NO &&((UIButton *)_arrRtports[1]).selected == NO &&((UIButton *)_arrRtports[2]).selected == NO &&((UIButton *)_arrRtports[3]).selected == NO &&((UIButton *)_arrRtports[4]).selected == NO &&((UIButton *)_arrRtports[5]).selected == NO && ((UIButton *)_arrRtports[6]).selected == NO && _btnRepots.selected == NO  ) {
                    [[AMToastView toastView] showMessage:@"还有1项未填写" icon:kImageRequestError duration:AMToastDurationNormal];

                    _labReport.hidden = YES;
                    _btnErrReport.hidden = NO;
                    
                } else {
                    if (((UIButton *)_arrRtports[i]).selected == YES) {
                        // 获取所有Button
                        UIButton *btns = (UIButton *)[self viewWithTag:KbuttenStartTag];
                        
                        UIButton *btn1 = (UIButton *)[self viewWithTag:KbuttenStartTag + 1];
                        
                        UIButton *btn2 = (UIButton *)[self viewWithTag:KbuttenStartTag + 2];
                        
                        UIButton *btn3 = (UIButton *)[self viewWithTag:KbuttenStartTag + 3];
                        
                        UIButton *btn4 = (UIButton *)[self viewWithTag:KbuttenStartTag + 4];
                        
                        UIButton *btn5 = (UIButton *)[self viewWithTag:KbuttenStartTag + 5];
                         // 对此车已售和联系不上进行处理
                        if ((((UIButton *)_arrRtports[i]) == btns || ((UIButton *)_arrRtports[i]) == btn4) &&  tfTelephone.text.length == 0) {
                            _labPhone.hidden = YES;
                            _btnErrPhone.hidden = NO;
                            _labRequire1.hidden = YES;
                            [[AMToastView toastView] showMessage:@"还有1项未填写" icon:kImageRequestError duration:AMToastDurationNormal];
                        }
                        
                        // 特殊处理提示文字
                        if (((UIButton *)_arrRtports[i]) == _btnRepots && tfDesrpt.text.length == 0) {
                            _labDetailDes.hidden = YES;
                            _btnErrDescrpt.hidden = NO;
                            _labRequire.hidden = YES;
                            [[AMToastView toastView] showMessage:@"还有1项未填写" icon:kImageRequestError duration:AMToastDurationNormal];
                        }
                        // 特殊处理提示文字
                        if (((UIButton *)_arrRtports[i]) == btn1 || ((UIButton *)_arrRtports[i]) == btn2 || ((UIButton *)_arrRtports[i]) == btn3 || ((UIButton *)_arrRtports[i]) == btn5 ) {
                            _btnErrDescrpt.hidden = YES;
                            _btnErrPhone.hidden = YES;
                            _labPhone.hidden = NO;
                            _labDetailDes.hidden = NO;
                            
                            if (((UIButton *)_arrRtports[i]) == btn1) {
                                [self getReportInfo:_carId userName:nil type:[NSNumber numberWithInt:6] brandid:nil seriesid:nil specid:nil context:tfDesrpt.text mobile:tfTelephone.text];
                            } if (((UIButton *)_arrRtports[i]) == btn2) {
                                [self getReportInfo:_carId userName:nil type:[NSNumber numberWithInt:7] brandid:nil seriesid:nil specid:nil context:tfDesrpt.text mobile:tfTelephone.text];
                            } if (((UIButton *)_arrRtports[i]) == btn3) {
                                [self getReportInfo:_carId userName:nil type:[NSNumber numberWithInt:8] brandid:nil seriesid:nil specid:nil context:tfDesrpt.text mobile:tfTelephone.text];
                            } if (((UIButton *)_arrRtports[i]) == btn5) {
                                [self getReportInfo:_carId userName:nil type:[NSNumber numberWithInt:0] brandid:nil seriesid:nil specid:nil context:tfDesrpt.text mobile:tfTelephone.text];
                            }
                            
                        }
                        
                        // 提交做判断
                        if (_btnRepots.selected == YES && tfDesrpt.text.length > 0 ) {
                            
                             [self getReportInfo:_carId userName:nil type:[NSNumber numberWithInt:10] brandid:_brandid seriesid:_seriesid specid:_specid context:tfDesrpt.text mobile:tfTelephone.text];
                        }
                        
                        // 提交做判断
                        if ((((UIButton *)_arrRtports[i]) == btns || ((UIButton *)_arrRtports[i]) == btn4) &&  tfTelephone.text.length > 0) {
                            
                            if (((UIButton *)_arrRtports[i]) == btns) {
                                [self getReportInfo:_carId userName:nil type:[NSNumber numberWithInt:2]brandid:nil seriesid:nil specid:nil context:nil mobile:tfTelephone.text];
                            } else {
                                [self getReportInfo:_carId userName:nil type:[NSNumber numberWithInt:9] brandid:nil seriesid:nil specid:nil context:nil mobile:tfTelephone.text];
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
        }
    }
}

- (void)onCilckBtnRepot:(UIButton *)btn
{
    [UMStatistics event:c_3_7_buycar_buinesssourcedetail_report_error];
    // 屏蔽快速连续点击
    if (![OMG isValidClick])
        return;
    
    _labRequire1 .hidden = YES;
    // 特殊处理提示文字
    if (_btnErrDescrpt.hidden == NO || _btnErrPhone.hidden == NO) {
        _btnErrDescrpt.hidden = YES;
        _labDetailDes.hidden = NO;
        _btnErrPhone.hidden = YES;
        _labPhone.hidden = NO;
    }
    _labReport.hidden = NO;
    _btnErrReport.hidden = YES;
    // 遍历数组
    for (int i = 0; i < [_arrRtports count]; i++) {
        if ( btn == [_arrRtports objectAtIndex:i]) {
            if (_carBrind) {
                btn.selected = YES;
                _labRequire.hidden = NO;
            }

            _labCarName.textColor = kColorWhite;
            _arrowImage.image = [UIImage imageNamed:@"error_more_butten"];
        } else {
            
            ((UIButton *)_arrRtports[i]).selected = NO;
        }
    }
    // 进入选着车页面
     UCChooseCarView *vChooseCar = [[UCChooseCarView alloc] initWithCustomCarFrame:[MainViewController sharedVCMain].vMain.bounds viewStyle:UCFilterBrandViewStyleModel carName:_carName mAFilter:_mFilter];
    vChooseCar.delegate = self;
    [[MainViewController sharedVCMain] openView:vChooseCar animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
}

- (void)onClickRepotBtn:(UIButton *)btn
{
    _labReport.hidden = NO;
    _btnErrReport.hidden = YES;

    // 特殊处理提示文字
    if (_btnErrDescrpt.hidden == NO || _btnErrPhone.hidden == NO) {
        _btnErrDescrpt.hidden = YES;
        _labDetailDes.hidden = NO;
        _btnErrPhone.hidden = YES;
        _labPhone.hidden = NO;
    }
    
    // 给选中按钮来填色
    for (int i = 0; i < [_arrRtports count]; i++) {
        if ( btn == [_arrRtports objectAtIndex:i]) {
            if (i == 1) {
                [UMStatistics event:c_3_7_buycar_buinesssourcedetail_report_sold];
            } else if (i == 2) {
                [UMStatistics event:c_3_7_buycar_buinesssourcedetail_report_lowprice];
            } else if (i == 3) {
                [UMStatistics event:c_3_7_buycar_buinesssourcedetail_report_untransfer];
            } else if (i == 4) {
                [UMStatistics event:c_3_7_buycar_buinesssourcedetail_report_deposit];
            } else if (i == 5) {
                [UMStatistics event:c_3_7_buycar_buinesssourcedetail_report_nocontact];
            } else if (i == 6) {
                [UMStatistics event:c_3_7_buycar_buinesssourcedetail_report_other];
            }
            _labCarName.textColor = kColorNewGray1;
            _arrowImage.image = [UIImage imageNamed:@"set_arrow_right"];
            if (btn.selected == YES) {
                btn.selected = NO;
                _labRequire.hidden = YES;
                _labRequire1.hidden = YES;
            } else {
                btn.selected = YES;
            }
        } else
            ((UIButton *)_arrRtports[i]).selected = NO;
    }
    if ((btn.tag == KbuttenStartTag + 4 && btn.selected == YES)|| (btn.tag == KbuttenStartTag && btn.selected == YES)) {
        _labRequire1.hidden = NO;
        _labRequire.hidden = YES;
    } else {
        _labRequire1.hidden = YES;
        _labRequire.hidden = YES;
    }
}

/** 播放电话 */
+ (void)callPhone:(NSString *)num
{
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"]))
        [[AMToastView toastView] showMessage:@"您的设备不支持拨打电话" icon:kImageRequestError duration:AMToastDurationNormal];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", num]]];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        _svReport.maxY = _svReport.height - 175;
    }];
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.25 animations:^{
        _svReport.maxY = _svReport.height - (DEVICE_IS_IPHONE5 ? 175 : 100);
    }];
    
    return YES;
}

/** textFieldDelegate */
- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger count = 100;
    if (textView.tag == KTextViewStartTag) {
        if (textView.markedTextRange == nil && textView.text.length > count) {
            textView.text = [textView.text substringToIndex:count];
        }
        UILabel *labCount = (UILabel *)[self viewWithTag:KlabelStartTag];
        if (textView.text.length == 0) {
            labCount.textColor = kColorNewGray2;
        } else {
            labCount.textColor = kColorOrange;
            _labDetailDes.hidden = NO;
            _btnErrDescrpt.hidden = YES;
        }
        
        labCount.text = [NSString stringWithFormat:@"%d", count - textView.text.length];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // 限制字数
    if (string.length > 0) {
        _labPhone.hidden = NO;
        _btnErrPhone.hidden = YES;
    }
    NSInteger surplus = 11 - textField.text.length;
    if (string.length > surplus)
        return NO;
    return YES;
}

/** 关闭页面 */
- (void)chooseCarViewDidCancel:(UCChooseCarView *)vChooseCar
{
    [[MainViewController sharedVCMain] closeView:vChooseCar animateOption:AnimateOptionMoveUp];
}

/** 选着车完成后的代理方法 */
- (void)chooseCarView:(UCChooseCarView *)vChooseCar didFinishChooseWithInfo:(NSDictionary *)info
{
    if (info) {
        NSString *brandid = [info objectForKey:@"brandid"];
        NSString *seriesid = [info objectForKey:@"seriesid"];
        NSString *specid = [info objectForKey:@"specid"];
        NSString *brandName = [info objectForKey:@"brandidText"];
        NSString *seriesName = [info objectForKey:@"seriesidText"];
        NSString *productName = [info objectForKey:@"specidText"];
        NSNumber *sourceid = [info objectForKey:@"sourceid"];
        
        _carBrind = productName;
        _mFilter.brandid = brandid;
        _mFilter.specid = specid;
        _mFilter.seriesid = seriesid;
        _mFilter.brandidText = brandName;
        _mFilter.seriesidText = seriesName;
        _mFilter.specidText = productName;
        _mFilter.sourceid = sourceid;
        
        if (seriesName && productName) {
            _labCarName.text = [NSString stringWithFormat:@"%@%@",seriesName,productName];
            _btnRepots.selected = YES;
            _labCarName.textColor = kColorWhite;
            _arrowImage.image = [UIImage imageNamed:@"error_more_butten"];
            
        }
    }
    _labRequire.hidden = NO;

    [[MainViewController sharedVCMain] closeView:vChooseCar animateOption:AnimateOptionMoveUp];
}

/** 提交车源状态 */
- (void)getReportInfo:(NSNumber *)carId userName:(NSString *)userName type:(NSNumber *)type brandid:(NSNumber *)brindid seriesid:(NSNumber *)seriesid specid:(NSNumber *)specid context:(NSString *)context mobile:(NSString *)mobile
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
    
    __weak UCReportView *cReportCar = self;
    
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
                    [[MainViewController sharedVCMain] closeView:cReportCar animateOption: AnimateOptionMoveLeft];
                    
                } else {
                    if(mBase.message)
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                }
            } else
                [[AMToastView toastView] hide];
        }
    }];
    
    [_apiHelper getReportInfo:carId userName:userName type:type brandid:brindid seriesid:seriesid specid:specid context:context mobile:mobile];
}

#pragma mark - UIGestureRecognizerDelegate
/** 处理不响应button */
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
