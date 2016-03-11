//
//  UCSaleCarView.m
//  UsedCar
//
//  Created by Alan on 13-11-20.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCSaleCarView.h"
#import "UCTopBar.h"
#import "UCCarInfoEditModel.h"
#import "UserInfoModel.h"
#import "UCReferencePriceModel.h"
#import "KLSwitch.h"
#import "APIHelper.h"
#import "AreaProvinceItem.h"
#import "UIImage+Util.h"
#import "UITextField+Util.h"
#import "NSString+Util.h"
#import "AMCacheManage.h"
#import "UCPriceModel.h"
#import "OMG.h"
#import "UCLoginDealerView.h"
#import "UCLoginClientView.h"
#import "UCReleaseSucceedView.h"

#define kCarBasicItemStartTag       10000
#define kCarBasicDepositTag         10001       // PIN码
#define kCarBasicCarInfoTag         10002       // 车辆信息
#define kCarBasicBookingPriceTag    10003       // 预售价格
#define kCarBasicSwitchTransferfee  10004       // 过户费用
#define kCarBasicLocationTag        10005       // 所在地
#define kCarBasicDriveMileageTag    10006       // 行驶里程
#define kCarBasicCarColorTag        10007       // 颜色
#define kCarBasicCarPurposesTag     10008       // 车辆用途

#define kCarContactFirstTag         10009       // 联系信息第一栏
#define kCarContactSecondTag        10010       // 联系信息第二栏
#define kCarContactThirdTag         10011       // 联系信息第三栏 （卖家附言title和输入框）

/* 屏蔽一口价
 #define kCarBasicSwitchFixprice     10006
 */

#define kCarLicenseItemOffsetTag        1000

#define kCarDescribeTextTag             65849114
#define kCarDescribeTextCountTag        21988869

#define kCarDrivingLicenseViewTag       20000           // 行驶证view
#define kCarTestReportViewTag           30000           // 检测报告view
#define kCarExtendedrepairViewTag       40000           // 延长质保view
#define kCarChangeStartValueTag         900             // 延长质保和检测报告的差值

#define kCarRepairNotMandatory          21000           // 延长质保的非必填说明

#define kAlertCloseReleaseTag           21496582
#define kAlertNoValidDataTag            51833344
#define kAlertReleaseFailTag            58230209

#define kChoosePhotoViewHeight          365
#define kChoosePhotoViewHeight_small    200
#define kChoosePhotoBtnViewHeight       140

#define kShowExampleBtnTag              38594843
#define kBlackBgViewTag                 12908765

#define kContentSize @"contentSize"
#define kContentOffset @"contentOffset"

//数字和字母
#define CAPITAL @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

@interface UCSaleCarView ()

@property (nonatomic) BOOL isBusiness; // 是否商家卖车
@property (nonatomic) BOOL isEditMode; // 是否编辑模式
@property (nonatomic) CGFloat keyboardHeight; // 键盘高度

@property (nonatomic, strong) UserInfoModel *mUserInfo;
@property (nonatomic, strong) UCCarInfoEditModel *mCarInfoEditOrigin; // 发车源数据
@property (nonatomic, strong) UCCarInfoEditModel *mCarInfoEdit; // 发车当前数据
@property (nonatomic, strong) UCPriceModel *mPrice;             // 发车参考价

@property (nonatomic, strong) NSArray *provinces; // 省市
@property (nonatomic, strong) NSArray *carColors; // 车辆颜色
@property (nonatomic, strong) NSArray *carPurposes; // 车辆用途

@property (nonatomic, strong) UIScrollView *svMain;
@property (nonatomic, strong) UIView *vCarPhoto; // 车辆照片
@property (nonatomic, strong) UIView *vCarBasic; // 基本信息
@property (nonatomic, strong) UIView *vCarLicense; // 牌照信息
@property (nonatomic, strong) UIView *vCarPrice; // 价格信息
@property (nonatomic, strong) UIView *vCarConect; // 联系信息
@property (nonatomic, strong) UCUploadPhotosView *vUploadDrivingLicense;  // 行驶证
@property (nonatomic, strong) UCUploadPhotosView *vUploadTextReportPhoto; // 检测报告照片上传
@property (nonatomic, strong) UIView *vLicenseBottomLine; // 牌照信息底线

@property (nonatomic) BOOL isVINUser;           // 是否保障金商家
@property (nonatomic) BOOL isShowTestReportView;// 是否显示检测报告

@property (nonatomic, strong) UCUploadPhotosView *vUploadPhotos; // 照片上传
@property (nonatomic, strong) UIWebView *wvReferencePrice; // 参考价
@property (nonatomic, strong) UIImageView *vShowColor;           // 显示选中颜色

@property (nonatomic, strong) UIButton *btnCloseKeyboard; // 关闭键盘
@property (nonatomic, strong) UISelectorView *vSelector; // 选择器

@property (nonatomic, strong) APIHelper *apiReleaseCar;
@property (nonatomic, strong) APIHelper *apiHelperPrice;

@property (nonatomic, strong) UIView *vChoosePhoto;
@property (nonatomic, strong) UIView *vChoosePhotoBtn;
@property (nonatomic, strong) UIView *vChoosePhotoPrompt;
@property (nonatomic) BOOL isShowChooseView;
@property (nonatomic) BOOL isShowExamplePhoto;
@property (nonatomic) NSInteger clickUploadPhotosTag;
@property (nonatomic, strong) NSArray *carColorValues;          // 颜色色值
@property (nonatomic, strong) NSArray *keys;                    // 参考价监听对象

@end

@implementation UCSaleCarView

//- (id)initWithFrame:(CGRect)frame carInfoEdit:(UCCarInfoEditModel *)mCarInfoEdit userInfo:(UserInfoModel *)mUserInfo
- (id)initWithFrame:(CGRect)frame carInfoEdit:(UCCarInfoEditModel *)mCarInfoEdit
{
    self = [super initWithFrame:frame];
    if (self) {
        _keys = [NSArray arrayWithObjects:@"brandid", @"seriesid", @"productid", @"firstregtime", @"drivemileage", @"provinceid", @"cityid", nil];
        _mPrice = [[UCPriceModel alloc] init];
        _isVINUser = [[AMCacheManage currentUserInfo].isbailcar integerValue] == 1;
        _isShowTestReportView = [[AMCacheManage currentUserInfo].bdpmstatue integerValue] == 1;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FilterValues" ofType:@"plist"];
        NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
        // 颜色色值
        _carColorValues = [NSArray arrayWithArray:values[@"FilterColors"]];
        
        // 设置发车模式 (商家 or 个人)
        if ([AMCacheManage currentUserType] == UserStyleBusiness)
            _isBusiness = YES;// Test
        
        [UMStatistics event:_isBusiness ? pv_3_1_businesssellingcar : pv_3_1_personalsellingcar];
        if (_isBusiness) {
        } else {
            [UMSAgent postEvent:usersellcar_pv page_name:(NSStringFromClass(self.class))];
        }
        
        // 初始化发车实体
        if (mCarInfoEdit) {
            _isEditMode = YES;
            
            // 未填完进入才需要保存源数据以便关闭时候对比
            if (mCarInfoEdit.carid.doubleValue < 0)
                self.mCarInfoEditOrigin = mCarInfoEdit;
            
            self.mCarInfoEdit = [mCarInfoEdit copy];
        }
        else {
            _isEditMode = NO;
            self.mCarInfoEdit = [[UCCarInfoEditModel alloc] init];
        }
        
        // 键盘监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        if (DEVICE_IS_IPHONE5)
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [self initValue];
        [self initView];
        
//#warning 测试
//        [OMG setKVOWithModel:_mCarInfoEdit isOpen:YES delegate:self];
        // 注册监听
        [self setKVOPrice:YES keys:_keys];
    }
    return self;
}

/** 初始化相关数值 */
- (void)initValue
{
    // 省市
    self.provinces = [OMG areaProvinces];
    // 读取配置文件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"FilterValues" ofType:@"plist"];
    NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
    // 车辆颜色
    self.carColors = values[@"CarColors"];
    // 车辆用途
    self.carPurposes = values[@"CarPurposes"];

}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    
    // 初始化选择器
    _vSelector = [[UISelectorView alloc] initWithFrame:CGRectMake(0, 0, self.width, 216)];
    _vSelector.delegate = self;
    _vSelector.backgroundColor = kColorGrey5;
    _vSelector.colorSelector = kColorBlue1;
    
    // 导航头
    UCTopBar *tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [tbTop.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    [tbTop.btnRight setTitle:@"发布" forState:UIControlStateNormal];
    [tbTop.btnTitle setTitle:_isBusiness ? @"商家卖车" : @"个人卖车" forState:UIControlStateNormal];
    [tbTop.btnLeft addTarget:self action:@selector(onClickCancel:) forControlEvents:UIControlEventTouchUpInside];
    [tbTop.btnRight addTarget:self action:@selector(onClickRelease:) forControlEvents:UIControlEventTouchUpInside];
    
    // 初始化主滚动布局
    _svMain = [[UIScrollView alloc] initWithFrame:self.bounds];
    _svMain.contentInset = UIEdgeInsetsMake(tbTop.height, 0, 0, 0);
    _svMain.scrollIndicatorInsets = _svMain.contentInset;
    _svMain.clipsToBounds = YES;
    _svMain.backgroundColor = kColorNewBackground;
    
    [self addSubview:_svMain];
    [self addSubview:tbTop];
    
    [self initCarInfoView];
    
    // 键盘关闭按钮
    UIImage *imgClose = [UIImage imageNamed:@"keboard_off_btn"];
    _btnCloseKeyboard = [[UIButton alloc] initWithFrame:CGRectMake(self.width - imgClose.width, self.height, imgClose.width + 10, imgClose.height + 10)];
    [_btnCloseKeyboard setImage:imgClose forState:UIControlStateNormal];
    [_btnCloseKeyboard addTarget:self action:@selector(onClickCloseKeyboard) forControlEvents:UIControlEventTouchUpInside];
    _btnCloseKeyboard.alpha = 0;
    [self addSubview:_btnCloseKeyboard];
    
    // 修改车加载参考价
    if (_isEditMode) {
        [self getReferencePrice];
    }
}

- (void)initCarInfoView
{
    // 初始化车辆照片布局
    [self initCarPhotoView];
    // 初始化基本信息布局
    [self initCarBasicView];
    // 初始化牌照信息布局
    [self initCarLicenseView];
    // 初始化价格
    [self initCarPriceView];
    // 初始化联系信息布局
    [self initCarConect];
    
    _svMain.contentSize = CGSizeMake(_svMain.width, _vCarConect.maxY + 20);
}

/* 车辆照片 */
- (void)initCarPhotoView
{
    // 基本信息布局
    if (!_vCarPhoto) {
        _vCarPhoto = [[UIView alloc] initWithFrame:CGRectMake(0, 20, _svMain.width, 97)];
        _vCarPhoto.backgroundColor = kColorWhite;
        [_svMain addSubview:_vCarPhoto];
    } else {
        [_vCarPhoto removeAllSubviews];
    }
    _vUploadPhotos = [[UCUploadPhotosView alloc] initWithFrame:_vCarPhoto.bounds stringImageUrls:self.mCarInfoEdit.imgurls isBusiness:_isBusiness];
    _vUploadPhotos.tag = UCCarPhotoViewStyleCarPhoto;
    _vUploadPhotos.delegate = self;
    _vUploadPhotos.backgroundColor = kColorWhite;
    
    [_vCarPhoto addSubview:_vUploadPhotos];
    [_vCarPhoto addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, _vCarPhoto.width, kLinePixel) color:kColorNewLine]];
    [_vCarPhoto addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, _vCarPhoto.height - kLinePixel, _vCarPhoto.width, kLinePixel) color:kColorNewLine]];
}

/* 车辆信息 */
- (void)initCarBasicView
{
    // 基本信息布局
    if (!_vCarBasic) {
        _vCarBasic = [[UIView alloc] initWithFrame:CGRectMake(0, _vCarPhoto.maxY + 20, _svMain.width, kUnkown)];
        _vCarBasic.backgroundColor = kColorWhite;
        [_svMain addSubview:_vCarBasic];
    } else {
        [_vCarBasic removeAllSubviews];
    }
    
    // 顶部分割线
    UIView *vTopLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, _vCarBasic.width, kLinePixel) color:kColorNewLine];
    [_vCarBasic addSubview:vTopLine];
    
    NSArray *basicTitles = nil;
    if (_isBusiness)
        basicTitles = @[@"输入VIN码", @"车辆信息", @"所  在  地", @"行驶里程", @"车辆颜色", @"车辆用途"];
    else
        basicTitles = @[@"车辆信息", @"所  在  地", @"行驶里程", @"车辆颜色"];
    
    CGFloat basicMinY = 0;
    for (int i = 0; i < basicTitles.count; i++) {
        
        CGFloat height = 51;
        UITextField *tfItem = [[UITextField alloc] initWithFrame:CGRectMake(17, basicMinY, _vCarBasic.width - 20, height)];
        tfItem.textAlignment = NSTextAlignmentRight;
        tfItem.keyboardType = UIKeyboardTypeDecimalPad;
        tfItem.font = kFontNormal;
        tfItem.delegate = self;
        tfItem.textColor = kColorNewGray1;
        
        // 左视图
        UILabel *labLeft = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 0, 95, tfItem.height)];
        labLeft.textColor = kColorNewGray2;
        labLeft.font = kFontNormal;
        labLeft.text = [basicTitles objectAtIndex:i];
        
        // 竖分割线
        CGFloat minxLine = 95 - 17;
        // VIN码竖线右移
        if ([labLeft.text hasPrefix:@"输入VIN码"])
            minxLine = 110;
        UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(minxLine, (tfItem.height - 24) / 2, kLinePixel, 24) color:kColorNewLine];
        [tfItem addSubview:vLine];
        
        // 右视图
        UIView *vRight = nil;
        
        UIView *vLeft = [[UIView alloc] initWithFrame:labLeft.frame];
        if ([labLeft.text hasPrefix:@"输入VIN码"]) {
            tfItem.keyboardType = UIKeyboardTypeASCIICapable;
            tfItem.tag = kCarBasicDepositTag;
            tfItem.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            
            [labLeft sizeToFit];
            labLeft.origin = CGPointMake(0, 9);
            [vLeft addSubview:labLeft];
            vLeft.width = 111;
            
            // 解决小写自动变大写问题
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:tfItem];
            
            // 非保证金商家选填
            UILabel *labText = [[UILabel alloc] init];
            labText.text = @"非保证金商家选项";
            labText.textColor = labLeft.textColor;
            labText.font = kFontTiny;
            [labText sizeToFit];
            labText.origin = CGPointMake(0, 27);
            [vLeft addSubview:labText];
            
            // 右视图
            UIImage *iPencil = [UIImage imageNamed:@"sellcar_publish_butten"];
            vRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPencil.width + 23, tfItem.height)];
            // 铅笔图标
            UIImageView *ivPencil = [[UIImageView alloc] initWithImage:iPencil];
            ivPencil.origin = CGPointMake(8, (vRight.height - ivPencil.height) / 2);
            [vRight addSubview:ivPencil];
            
            // 设置VIN码
            if (_mCarInfoEdit.vincode.length > 0) {
                tfItem.text = _mCarInfoEdit.vincode;
            }
        }
        // 车辆信息 使用 TextView代替
        else if ([labLeft.text hasPrefix:@"车辆信息"]) {
            tfItem.tag = kCarBasicCarInfoTag;
            // 设置车辆信息
            if (_mCarInfoEdit.seriesname.length > 0 && _mCarInfoEdit.productname.length > 0)
                [self setCarInfoTextField:tfItem FirstText:_mCarInfoEdit.seriesname secondText:_mCarInfoEdit.productname isCustomCar:NO];
            else if (_mCarInfoEdit.carname.length > 0 && _mCarInfoEdit.displacement.length > 0 && _mCarInfoEdit.gearbox.length > 0)
                [self setCarInfoTextField:tfItem FirstText:_mCarInfoEdit.carname secondText:[NSString stringWithFormat:@"%@ %@L", _mCarInfoEdit.gearbox, _mCarInfoEdit.displacement] isCustomCar:YES];
        }
        // 预售价格 行驶里程
        else if ([labLeft.text hasPrefix:@"预售价格"] || [labLeft.text hasPrefix:@"行驶里程"]) {
            if ([labLeft.text hasPrefix:@"预售价格"]) {
                tfItem.tag = kCarBasicBookingPriceTag;
                if (_mCarInfoEdit.bookprice.doubleValue > 0)
                    tfItem.text = [NSString stringWithFormat:@"%.2f", _mCarInfoEdit.bookprice.doubleValue];
            } else {
                tfItem.tag = kCarBasicDriveMileageTag;
                if (_mCarInfoEdit.drivemileage.doubleValue > 0)
                    tfItem.text = [NSString stringWithFormat:@"%.2f", _mCarInfoEdit.drivemileage.doubleValue];
            }
        }
        else if ([labLeft.text hasPrefix:@"过户费用"]) {
            vRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 82, tfItem.height)];
            
            // 开关
            KLSwitch *swc = [[KLSwitch alloc] initWithFrame:CGRectMake(0, (vRight.height - 32) / 2, 75, 32)];
            [swc addTarget:self action:@selector(onClickSwitch:) forControlEvents:UIControlEventValueChanged];
            tfItem.tag = kCarBasicSwitchTransferfee;
            swc.on = _mCarInfoEdit.isincludetransferfee.boolValue;
            swc.tag = tfItem.tag;
            [swc setContrastLabelText:@"不含"];
            [swc setOnLabelText:@"包含"];
            
            /* 屏蔽一口价
             else {
             tfItem.tag = kCarBasicSwitchFixprice;
             swc.on = _mCarInfoEdit.isfixprice.boolValue;
             swc.tag = tfItem.tag;
             [swc setContrastLabelText:@"关闭"];
             [swc setOnLabelText:@"开启"];
             // 一口价帮助说明
             UIImage *imgBtnHelp = [UIImage imageNamed:@"release_help_btn_icon"];
             UIButton *btnHelp = [[UIButton alloc] initWithFrame:CGRectMake(50, 13, imgBtnHelp.width, imgBtnHelp.height)];
             [btnHelp setImage:imgBtnHelp forState:UIControlStateNormal];
             [btnHelp addTarget:self action:@selector(onClickHelp:) forControlEvents:UIControlEventTouchUpInside];
             [tfItem addSubview:btnHelp];
             }
             */
            
            [vRight addSubview:swc];
        }
        // 所在城市
        else if ([labLeft.text hasPrefix:@"所  在  地"]) {
            tfItem.tag = kCarBasicLocationTag;
            tfItem.inputView = _vSelector;
            // 设置选中的城市
            if (_mCarInfoEdit.provinceid.stringValue.length > 0 && _mCarInfoEdit.cityid.stringValue.length > 0) {
                NSString *strProvince = nil;
                NSString *strCity = nil;
                
                for (AreaProvinceItem *apItem in _provinces) {
                    if (apItem.PI.integerValue == self.mCarInfoEdit.provinceid.integerValue) {
                        // 设置省名称
                        strProvince = apItem.PN;
                        
                        for (AreaCityItem *acItem in apItem.CL) {
                            if (acItem.CI.integerValue == self.mCarInfoEdit.cityid.integerValue) {
                                // 设置城市名称
                                strCity = acItem.CN;
                                break;
                            }
                        }
                        break;
                    }
                }
                if (strProvince.length > 0 && strCity.length > 0)
                    tfItem.text = [NSString stringWithFormat:@"%@ %@", strProvince, strCity];
            }
            // 默认使用当前地区
            else {
                // 当前地区
                UCAreaMode *mArea = [AMCacheManage currentArea];
                
                if (mArea.pName.length > 0 && mArea.cName.length > 0) {
                    tfItem.text = [NSString stringWithFormat:@"%@ %@",mArea.pName, mArea.cName];
                    self.mCarInfoEdit.provinceid = [NSNumber numberWithInteger:[mArea.pid integerValue]];
                    self.mCarInfoEdit.cityid = [NSNumber numberWithInteger:[mArea.cid integerValue]];
                }
                
                // 特殊控制：有省且市为不限
                if (mArea.pName.length > 0 && mArea.cName.length == 0) {
                    // (北京、天津、重庆、上海) 的不限
                    if (mArea.cName.length == 0 && ([mArea.pid isEqualToString:@"110000"] || [mArea.pid isEqualToString:@"310000"] || [mArea.pid isEqualToString:@"500000"] || [mArea.pid isEqualToString:@"120000"])) {
                        tfItem.text = [NSString stringWithFormat:@"%@ %@",mArea.pName, mArea.pName];
                        self.mCarInfoEdit.provinceid = [NSNumber numberWithInteger:[mArea.pid integerValue]];
                        self.mCarInfoEdit.cityid = [NSNumber numberWithInteger:[mArea.pid integerValue] + 100];
                    }
                }
                // 特殊控制：广深下的广州或深圳
                if ([mArea.areaid isEqualToString:@"300000"] && ([mArea.cid isEqualToString:@"440100"] ||[mArea.cid isEqualToString:@"440300"])) {
                    self.mCarInfoEdit.provinceid = [NSNumber numberWithInteger:440000];
                    self.mCarInfoEdit.cityid = [NSNumber numberWithInteger:[mArea.cid integerValue]];
                    tfItem.text = [NSString stringWithFormat:@"%@ %@",@"广东", mArea.cName];
                }
            }
        }
        // 车辆颜色
        else if ([labLeft.text hasPrefix:@"车辆颜色"]) {
            // 色块
            _vShowColor = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 120, (tfItem.height - 13) / 2, 13, 13)];
            _vShowColor.backgroundColor = kColorClear;
            _vShowColor.layer.borderColor = kColorNewGray2.CGColor;
            [tfItem addSubview:_vShowColor];
            
            tfItem.tag = kCarBasicCarColorTag;
            tfItem.inputView = _vSelector;
            if (_mCarInfoEdit.colorid.integerValue > 0) {
                tfItem.text = [_carColors objectAtIndex:_mCarInfoEdit.colorid.integerValue - 1];
                
                // 更改色值
                NSArray *colors = [[[_carColorValues objectAtIndex:_mCarInfoEdit.colorid.integerValue - 1] objectForKey:@"Value"] componentsSeparatedByString:@","];
                _vShowColor.backgroundColor = ((_mCarInfoEdit.colorid.integerValue - 1) == _carColors.count - 1) ? kColorClear : [UIColor colorWithRed:[[colors objectAtIndex:0] floatValue]/255.0f green:[[colors objectAtIndex:1] floatValue]/255.0f blue:[[colors objectAtIndex:2] floatValue]/255.0f alpha:1];
                _vShowColor.minX = tfItem.text.length == 2 ? (self.width - 106) : (self.width - 120);
                // 是否为其他
                _vShowColor.image = ((_mCarInfoEdit.colorid.integerValue - 1) == _carColors.count - 1) ? [UIImage imageNamed:@"color_other"] : nil;
                // 白色加边框
                _vShowColor.layer.borderWidth = (_mCarInfoEdit.colorid.integerValue - 1) == 1 ? 0.5 : 0;
            }
        }
        // 车辆用途
        else if ([labLeft.text hasPrefix:@"车辆用途"]) {
            tfItem.tag = kCarBasicCarPurposesTag;
            tfItem.inputView = _vSelector;
            if (_mCarInfoEdit.purposeid.integerValue > 0)
                tfItem.text = [_carPurposes objectAtIndex:_mCarInfoEdit.purposeid.integerValue - 1];
        }
        
        if ([labLeft.text hasPrefix:@"车辆信息"] || [labLeft.text hasPrefix:@"所  在  地"] ||[labLeft.text hasPrefix:@"车辆颜色"] || [labLeft.text hasPrefix:@"车辆用途"]) {
            // 箭头图标
            UIImage *iArrow = [UIImage imageNamed:@"sellcar_information_butten"];
            vRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iArrow.width + 26, tfItem.height)];
            UIImageView *ivArrow = [[UIImageView alloc] initWithImage:iArrow];
            ivArrow.origin = CGPointMake(vRight.width - iArrow.width - 14, (vRight.height - iArrow.height) / 2);
            [vRight addSubview:ivArrow];
        }
        
        if ([labLeft.text hasPrefix:@"预售价格"] || [labLeft.text hasPrefix:@"行驶里程"]) {
            
            vRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGFLOAT_MIN, tfItem.height)];
            
            // 单位
            UILabel *labUnit = [[UILabel alloc] init];
            labUnit.textAlignment = NSTextAlignmentRight;
            labUnit.font = kFontNormal;
            labUnit.textColor = kColorNewGray2;
            if ([labLeft.text hasPrefix:@"预售价格"])
                labUnit.text = @"万元";
            else
                labUnit.text = @"万公里";
            [labUnit sizeToFit];
            labUnit.origin = CGPointMake(10, (vRight.height - labUnit.height) / 2);
            
            // 铅笔图标
            UIImage *iPencil = [UIImage imageNamed:@"sellcar_publish_butten"];
            UIImageView *ivPencil = [[UIImageView alloc] initWithImage:iPencil];
            ivPencil.origin = CGPointMake(labUnit.maxX + 8, (vRight.height - ivPencil.height) / 2);
            
            [vRight addSubview:ivPencil];
            [vRight addSubview:labUnit];
            vRight.width = ivPencil.width + labUnit.width + 31;
        }
        
        tfItem.leftView = [labLeft.text hasPrefix:@"输入VIN码"] ? vLeft : labLeft;
        tfItem.rightView = vRight;
        tfItem.leftViewMode = UITextFieldViewModeAlways;
        tfItem.rightViewMode = UITextFieldViewModeAlways;
        tfItem.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        basicMinY += tfItem.height;
        
        if (i < basicTitles.count) {
            // 分割线
            UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, basicMinY - kLinePixel, _vCarBasic.width, kLinePixel) color:kColorNewLine];
            [_vCarBasic addSubview:vLine];
        }
        
        [_vCarBasic addSubview:tfItem];
    }
    _vCarBasic.height = basicMinY;
}

/* 牌照信息 */
- (void)initCarLicenseView
{
    // 车牌信息布局
    if (!_vCarLicense) {
        _vCarLicense = [[UIView alloc] initWithFrame:CGRectMake(0, _vCarBasic.maxY + 21, _svMain.width, kUnkown)];
        _vCarLicense.backgroundColor = kColorWhite;
        
        // 顶分割线
        UIView *vTopLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, _vCarLicense.width, kLinePixel) color:kColorNewLine];
        
        // 底分割线
        _vLicenseBottomLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, kUnkown, _vCarLicense.width, kLinePixel) color:kColorNewLine];
        
        [_vCarLicense addSubview:vTopLine];
        [_vCarLicense addSubview:_vLicenseBottomLine];
        [_svMain addSubview:_vCarLicense];
    } else {
        [_vCarLicense removeAllSubviews];
    }
    
    NSArray *licenseTitles = nil;
    NSArray *cerState = nil;
    
    if (_isBusiness)
        licenseTitles = @[@"上牌日期", @"年检到期", @"保险到期", @"车船税到期"];
    else {
        licenseTitles = @[@"上牌日期", @"年检到期", @"保险到期", @"车船税到期", @"行  驶  证", @"登  记  证", @"购车发票"];
        cerState = @[@"有", @"丢失", @"补办中"];
    }
    
    BOOL isShowAllLicenseOptions = NO;
    if (_mCarInfoEdit.firstregtime.length > 0 || _mCarInfoEdit.verifytime.length > 0 || _mCarInfoEdit.veticaltaxtime.length > 0 || _mCarInfoEdit.insurancedate.length > 0)
        isShowAllLicenseOptions = YES;
    
    CGFloat licenseMinY = 0;
    CGFloat itemHeight = 50;
    for (int i = 0; i < licenseTitles.count; i++) {
        // 标题
        UILabel *labLeft = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 14, 165, 18)];
        labLeft.textColor = kColorNewGray2;
        labLeft.font = kFontNormal;
        labLeft.text = [licenseTitles objectAtIndex:i];
        [labLeft sizeToFit];
        
        // 右视图
        UIView *vRight = nil;
        
        UITextField *tfItem = [[UITextField alloc] initWithFrame:CGRectMake(17, licenseMinY, _vCarLicense.width - 17, itemHeight)];
        tfItem.textAlignment = NSTextAlignmentRight;
        tfItem.tag = kCarBasicItemStartTag + i + kCarLicenseItemOffsetTag;
        tfItem.inputView = _vSelector;
        tfItem.delegate = self;
        tfItem.font = kFontNormal;
        tfItem.textColor = kColorNewGray1;
        
        // 竖分割线
        UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(95 - 17, (tfItem.height - 24) / 2, kLinePixel, 24) color:kColorNewLine];
        [tfItem addSubview:vLine];
        
        // 个人发车增加三个单选
        if (!_isBusiness && i > 3) {
            if (!isShowAllLicenseOptions)
                tfItem.minY -= itemHeight * 3;
            // 单选
            AMRadioButton *rbBar = [[AMRadioButton alloc] initWithFrame:CGRectMake(0, 0, 220, tfItem.height) groupId:labLeft.text];
            rbBar.tag = kCarLicenseItemOffsetTag + i;
            rbBar.delegate = self;
            
            CGFloat minX = 13;
            for (NSInteger i = 0; i < cerState.count; i++) {
                UIButton *btnRadioItem = [[UIButton alloc] initWithFrame:CGRectMake(minX, 0, rbBar.width / 3.31, rbBar.height)];
                btnRadioItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                btnRadioItem.titleLabel.font = kFontMini;
                [btnRadioItem setTitle:cerState[i] forState:UIControlStateNormal];
                [btnRadioItem setTitleColor:kColorNewGray2 forState:UIControlStateNormal];
                [btnRadioItem setImage:[UIImage imageNamed:@"individual_publish_circle"] forState:UIControlStateNormal];
                [btnRadioItem setImage:[UIImage imageNamed:@"individual_publish_circle_h"] forState:UIControlStateSelected];
                [btnRadioItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
                
                [rbBar addButton:btnRadioItem];
                
                minX += btnRadioItem.width;
            }
            
            if ([rbBar.groupId isEqualToString:@"行  驶  证"]) {
                if (self.mCarInfoEdit.drivingpermit.integerValue > 0) {
                    NSInteger number;
                    if (self.mCarInfoEdit.drivingpermit.integerValue == 1)
                        number = 0;
                    if (self.mCarInfoEdit.drivingpermit.integerValue == 2)
                        number = 2;
                    if (self.mCarInfoEdit.drivingpermit.integerValue == 3)
                        number = 1;
                    [rbBar selectAtIndex:number];
                } else {
                    [rbBar selectAtIndex:0];
                    self.mCarInfoEdit.drivingpermit = [NSNumber numberWithInteger:1];
                }
            }
            else if ([rbBar.groupId isEqualToString:@"登  记  证"]) {
                if (self.mCarInfoEdit.registration.integerValue > 0) {
                    NSInteger number;
                    if (self.mCarInfoEdit.registration.integerValue == 1)
                        number = 0;
                    if (self.mCarInfoEdit.registration.integerValue == 2)
                        number = 2;
                    if (self.mCarInfoEdit.registration.integerValue == 3)
                        number = 1;
                    [rbBar selectAtIndex:number];
                } else {
                    [rbBar selectAtIndex:0];
                    self.mCarInfoEdit.registration = [NSNumber numberWithInteger:1];
                }
            }
            else if ([rbBar.groupId isEqualToString:@"购车发票"]) {
                if (self.mCarInfoEdit.invoice.integerValue > 0) {
                    NSInteger number;
                    if (self.mCarInfoEdit.invoice.integerValue == 1)
                        number = 0;
                    if (self.mCarInfoEdit.invoice.integerValue == 2)
                        number = 2;
                    if (self.mCarInfoEdit.invoice.integerValue == 3)
                        number = 1;
                    [rbBar selectAtIndex:number];
                } else {
                    [rbBar selectAtIndex:0];
                    self.mCarInfoEdit.invoice = [NSNumber numberWithInteger:1];
                }
            }
            
            vRight = rbBar;
        } else {
            UIImage *iArrow = [UIImage imageNamed:@"sellcar_information_butten"];
            // 箭头图标
            vRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iArrow.width + 26, tfItem.height)];
            UIImageView *ivArrow = [[UIImageView alloc] initWithImage:iArrow];
            ivArrow.origin = CGPointMake(vRight.width - iArrow.width - 14, (vRight.height - iArrow.height) / 2);
            [vRight addSubview:ivArrow];
        }
        
        tfItem.leftView = labLeft;
        tfItem.leftViewMode = UITextFieldViewModeAlways;
        tfItem.rightView = vRight;
        tfItem.rightViewMode = UITextFieldViewModeAlways;
        tfItem.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tfItem.textAlignment = NSTextAlignmentRight;
        // 上牌日期
        if (i == 0) {
            if (_mCarInfoEdit.firstregtime.length > 0)
                tfItem.text = [self carLicenseDateFormat:_mCarInfoEdit.firstregtime];
        }
        // 年检到期
        else if (i == 1) {
            if (_mCarInfoEdit.verifytime.length > 0)
                tfItem.text = [self carLicenseDateFormat:_mCarInfoEdit.verifytime];
            tfItem.alpha = isShowAllLicenseOptions;
        }
        // 保险到期
        else if (i == 2) {
            if (_mCarInfoEdit.insurancedate.length > 0)
                tfItem.text = [self carLicenseDateFormat:_mCarInfoEdit.insurancedate];
            tfItem.alpha = isShowAllLicenseOptions;
        }
        // 车船税到期
        else if (i == 3) {
            if (_mCarInfoEdit.veticaltaxtime.length > 0)
                tfItem.text = [self carLicenseDateFormat:_mCarInfoEdit.veticaltaxtime];
            tfItem.alpha = isShowAllLicenseOptions;
        }
        
        licenseMinY += 50;
        
        if (i < licenseTitles.count) {
            // 分割线
            UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, licenseMinY - kLinePixel, _vCarLicense.width, kLinePixel) color:kColorNewLine];
            [_vCarLicense addSubview:vLine];
        }
        
        [_vCarLicense addSubview:tfItem];
    }
    
    if (_isBusiness) {
        // 上牌日期
        UITextField *tfItem = (UITextField *)[self viewWithTag:kCarBasicItemStartTag + 0 + kCarLicenseItemOffsetTag];
        CGFloat vTempViewMinY = tfItem.maxY + (isShowAllLicenseOptions ? itemHeight * 3 : 0);
        
        NSArray *titles = @[@"上传行驶证", @"上传检测报告", @"延长质保"];
        
        for (int i = 0; i < titles.count; i++) {
            
            NSString *currentTitle = [titles objectAtIndex:i];
            if (!_isShowTestReportView && [currentTitle hasPrefix:@"上传检测报告"])
                continue;
            
            // 检验报告 延长质保
            CGFloat vCurrentHeight = 0;
            if ([currentTitle hasPrefix:@"上传行驶证"]) {
                vCurrentHeight = 140;
            }
            if ([currentTitle hasPrefix:@"上传检测报告"]) {
                vCurrentHeight = ((_mCarInfoEdit.isTextReport.boolValue || (_mCarInfoEdit.certificatetype.integerValue == 10 || _mCarInfoEdit.certificatetype.integerValue == 30)) ? 140 : 50);
            }
            if ([currentTitle hasPrefix:@"延长质保"]) {
                vCurrentHeight = ((_mCarInfoEdit.isExtendedrepair.boolValue || _mCarInfoEdit.extendedrepair.boolValue) ? 140 : 50);
            }
            
            // 检测报告和延长质保
            UIView *vCurrent = [[UIView alloc] initWithFrame:CGRectMake(0, vTempViewMinY, _vCarLicense.width, vCurrentHeight)];
            vCurrent.backgroundColor = kColorWhite;
            vCurrent.layer.masksToBounds = YES;
            if ([currentTitle hasPrefix:@"上传行驶证"])
                vCurrent.tag = kCarDrivingLicenseViewTag;
            else if ([currentTitle hasPrefix:@"上传检测报告"])
                vCurrent.tag = kCarTestReportViewTag;
            else if ([currentTitle hasPrefix:@"延长质保"])
                vCurrent.tag = kCarExtendedrepairViewTag;
            
            // 标题
            UILabel *labTitle = [[UILabel alloc] init];
            labTitle.backgroundColor = [UIColor clearColor];
            labTitle.font = kFontNormal;
            labTitle.textColor = kColorNewGray2;
            labTitle.text = [titles objectAtIndex:i];
            [labTitle sizeToFit];
            labTitle.origin = CGPointMake(tfItem.minX, (tfItem.height - labTitle.height) / 2 - 8);
            
            // 非必填
            UILabel *labTitle2;
            if ([currentTitle hasPrefix:@"延长质保"]) {
                labTitle2 = [[UILabel alloc] init];
                labTitle2.tag = kCarRepairNotMandatory;
                labTitle2.backgroundColor = [UIColor clearColor];
                labTitle2.font = kFontTiny;
                labTitle2.textColor = kColorNewGray2;
                labTitle2.text =@"（非必填）";
                [labTitle2 sizeToFit];
                labTitle2.origin = CGPointMake(labTitle.maxX + 2, labTitle.minY + 4);
            }
            // 标题说明
            UILabel *labPrompt = [[UILabel alloc] init];
            labPrompt.backgroundColor = [UIColor clearColor];
            labPrompt.font = kFontMini;
            labPrompt.textColor = kColorNewGray2;
            if ([currentTitle hasPrefix:@"上传行驶证"])
                labPrompt.text = @"请上传真实行驶证件并确保证件内容清晰可见";
            else if ([currentTitle hasPrefix:@"上传检测报告"])
                labPrompt.text = @"1-3张车辆状况图片，可获得真实车况图标";
            else if ([currentTitle hasPrefix:@"延长质保"])
                labPrompt.text = @"一定时间范围的质量保证，可获得延保服务图标";
            [labPrompt sizeToFit];
            labPrompt.origin = CGPointMake(labTitle.minX, (tfItem.height - labPrompt.height) / 2 + 8);
            
            // 开关
            KLSwitch *klwSwit;
            if ([currentTitle hasPrefix:@"上传检测报告"] || [currentTitle hasPrefix:@"延长质保"]) {
                klwSwit = [[KLSwitch alloc] initWithFrame:CGRectMake(_vCarLicense.width - 75 - 10, (tfItem.height - 32) / 2, 75, 32)];
                if ([currentTitle hasPrefix:@"上传检测报告"]) {
                    klwSwit.tag = kCarTestReportViewTag + kCarChangeStartValueTag + 1;
                    [klwSwit setOnLabelText:@"是"];
                    [klwSwit setContrastLabelText:@"否"];
                    klwSwit.on = (_mCarInfoEdit.isTextReport.boolValue || (_mCarInfoEdit.certificatetype.integerValue == 10 || _mCarInfoEdit.certificatetype.integerValue == 30));
                }
                else if ([currentTitle hasPrefix:@"延长质保"]) {
                    klwSwit.tag = kCarExtendedrepairViewTag + kCarChangeStartValueTag + 1;
                    [klwSwit setOnLabelText:@"是"];
                    [klwSwit setContrastLabelText:@"否"];
                    klwSwit.on = (_mCarInfoEdit.isExtendedrepair.boolValue || _mCarInfoEdit.extendedrepair.boolValue);
                }
                [klwSwit addTarget:self action:@selector(onClickSwitch:) forControlEvents:UIControlEventValueChanged];
            }
            
            // 是否显示检测报告
            // 检测报告
            if ([[titles objectAtIndex:i] hasPrefix:@"上传行驶证"]) {
                _vUploadDrivingLicense = [[UCUploadPhotosView alloc] initDrivingLicenseViewWithFrame:CGRectMake(0, 50 + 6, vCurrent.width, 80) stringImageUrls:self.mCarInfoEdit.driverlicenseimage];
                _vUploadDrivingLicense.tag = UCCarPhotoViewStyleDrivingLicense;
                _vUploadDrivingLicense.delegate = self;
                
                [vCurrent addSubview:_vUploadDrivingLicense];
                [vCurrent addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(17, tfItem.height, vCurrent.width - 17 * 2, kLinePixel) color:kColorNewLine]];
                [vCurrent addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, vCurrent.height - kLinePixel, vCurrent.width, kLinePixel) color:kColorNewLine]];
                _vCarLicense.height = vCurrent.maxY;
                _vCarConect.minY = _vCarLicense.maxY;
                _svMain.contentSize = CGSizeMake(_svMain.width, _vCarConect.maxY + 20);
            }
            else if (_isShowTestReportView && [[titles objectAtIndex:i] hasPrefix:@"上传检测报告"]) {
                _vUploadTextReportPhoto = [[UCUploadPhotosView alloc] initWithFrame:CGRectMake(0, 50 + 6, vCurrent.width, 80) stringImageUrls:self.mCarInfoEdit.dctionimg];
                _vUploadTextReportPhoto.tag = UCCarPhotoViewStyleTextReport;
                _vUploadTextReportPhoto.delegate = self;
                
                [vCurrent addSubview:_vUploadTextReportPhoto];
                [vCurrent addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(17, tfItem.height, vCurrent.width - 17 * 2, kLinePixel) color:kColorNewLine]];
                if (_mCarInfoEdit.dctionimg.length > 0 ) {
                    _vCarLicense.height = vCurrent.maxY;
                    _vCarConect.minY = _vCarLicense.maxY;
                    _svMain.contentSize = CGSizeMake(_svMain.width, _vCarConect.maxY + 20);
                }
            }
            
            // 延长质保
            else if ([[titles objectAtIndex:i] hasPrefix:@"延长质保"]) {
                NSArray *units = @[@"月",@"万公里"];
                CGFloat tfItemMinY = 50;
                
                for (int i = 0 ; i < units.count; i++) {
                    UITextField *tfItem = [[UITextField alloc] initWithClearFrame:CGRectMake(17, tfItemMinY, _vCarLicense.width - 20, 50)];
                    tfItem.keyboardType = i == 0 ? UIKeyboardTypeNumberPad :UIKeyboardTypeDecimalPad;
                    tfItem.delegate = self;
                    tfItem.textColor = kColorNewGray1;
                    tfItem.tag = kCarExtendedrepairViewTag + kCarChangeStartValueTag + 3 + i;
                    tfItem.textAlignment = NSTextAlignmentRight;
                    tfItem.placeholder = i == 0 ? @"最多输入24个月" : @"最多输入9.9万公里";
                    // 延长质保 月
                    if (i == 0) {
                        if ([_mCarInfoEdit.qualityassdate integerValue] > 0) {
                            tfItem.text = [_mCarInfoEdit.qualityassdate stringValue];
                        } else {
                            tfItem.text = @"";
                        }
                    }
                    // 延长质保 公里
                    else {
                        if ([_mCarInfoEdit.qualityassmile floatValue] > 0) {
                            tfItem.text = [_mCarInfoEdit.qualityassmile stringValue];
                            _vCarLicense.height = vCurrent.maxY;
                            _vCarConect.minY = _vCarLicense.maxY;
                            _svMain.contentSize = CGSizeMake(_svMain.width, _vCarConect.maxY + 20);
                        } else {
                            tfItem.text = @"";
                        }
                    }
                    tfItem.font = tfItem.text.length > 0 ? kFontNormal : kFontMini;
                    
                    // 左视图
                    UILabel *labLeft = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 0, 95, 18)];
                    labLeft.textColor = kColorNewGray2;
                    labLeft.font = kFontNormal;
                    labLeft.text = i == 0 ? @"延长时间" : @"延长里程";
                    
                    // 竖分割线
                    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(95 - 17, (tfItem.height - 24) / 2, kLinePixel, 24) color:kColorNewLine];
                    [tfItem addSubview:vLine];
                    
                    // 单位
                    UILabel *labUnit = [[UILabel alloc] initWithClearFrame:CGRectMake(8, 0, i == 0 ? 13 : 43, tfItem.height)];
                    labUnit.textColor = kColorNewGray2;
                    labUnit.textAlignment = NSTextAlignmentRight;
                    labUnit.font = kFontNormal;
                    labUnit.text = [units objectAtIndex:i];
                    
                    UIImage *iPencil = [UIImage imageNamed:@"sellcar_publish_butten"];
                    // 铅笔图标
                    UIImageView *ivPencil = [[UIImageView alloc] initWithImage:iPencil];
                    ivPencil.origin = CGPointMake(labUnit.maxX + 9, (tfItem.height - ivPencil.height) / 2);
                    
                    // 右视图
                    UIView *vRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ivPencil.maxX + 8, tfItem.height)];
                    
                    tfItem.leftView = labLeft;
                    tfItem.rightView = vRight;
                    tfItem.leftViewMode = UITextFieldViewModeAlways;
                    tfItem.rightViewMode = UITextFieldViewModeAlways;
                    tfItem.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    
                    [vRight addSubview:ivPencil];
                    [vRight addSubview:labUnit];
                    [vCurrent addSubview:tfItem];
                    
                    // 分割线
                    UIView *vMiddleLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, vCurrent.width - 17 * 2, kLinePixel) color:kColorNewLine];
                    [tfItem addSubview:vMiddleLine];
                    [vCurrent addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, vCurrent.width, kLinePixel) color:kColorNewLine]];
                    
                    tfItemMinY += tfItem.height;
                }
            }
            
            
            [vCurrent addSubview:labTitle];
            if ([[titles objectAtIndex:i] hasPrefix:@"延长质保"])
                [vCurrent addSubview:labTitle2];
            [vCurrent addSubview:labPrompt];
            if ([currentTitle hasPrefix:@"上传检测报告"] || [currentTitle hasPrefix:@"延长质保"])
                [vCurrent addSubview:klwSwit];
            [_vCarLicense addSubview:vCurrent];
            
            vTempViewMinY += vCurrent.height;
            licenseMinY += vCurrent.height;
        }
    }
    
    if (isShowAllLicenseOptions)
        _vCarLicense.height = licenseMinY;
    else
        _vCarLicense.height = licenseMinY - itemHeight * 3;
    
    _vLicenseBottomLine.minY = _vCarLicense.height - kLinePixel;
}

/** 初始化价格信息 */
-(void)initCarPriceView
{
    // 基本信息布局
    if (!_vCarPrice) {
        _vCarPrice = [[UIView alloc] initWithFrame:CGRectMake(0, _vCarLicense.maxY + 20, _svMain.width, kUnkown)];
        _vCarPrice.backgroundColor = kColorWhite;
        [_svMain addSubview:_vCarPrice];
    } else {
        [_vCarPrice removeAllSubviews];
    }
    
    // 顶部分割线
    UIView *vTopLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, _vCarPrice.width, kLinePixel) color:kColorNewLine];
    [_vCarPrice addSubview:vTopLine];
    
    NSArray *basicTitles = @[@"预售价格", @"过户费用"];
    
    CGFloat basicMinY = 0;
    for (int i = 0; i < basicTitles.count; i++) {
        CGFloat height = 51;
        UITextField *tfItem = [[UITextField alloc] initWithFrame:CGRectMake(17, basicMinY, _vCarPrice.width - 20, height)];
        tfItem.textAlignment = NSTextAlignmentRight;
        tfItem.keyboardType = UIKeyboardTypeDecimalPad;
        tfItem.font = kFontNormal;
        tfItem.delegate = self;
        tfItem.textColor = kColorNewGray1;
        
        // 左视图
        UILabel *labLeft = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 0, 95, tfItem.height)];
        labLeft.textColor = kColorNewGray2;
        labLeft.font = kFontNormal;
        labLeft.text = [basicTitles objectAtIndex:i];
        
        // 竖分割线
        UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(95 - 17, (tfItem.height - 24) / 2, kLinePixel, 24) color:kColorNewLine];
        [tfItem addSubview:vLine];
        
        // 右视图
        UIView *vRight = nil;
        
        // 预售价格 行驶里程
        if ([labLeft.text hasPrefix:@"预售价格"]) {
            tfItem.tag = kCarBasicBookingPriceTag;
            if (_mCarInfoEdit.bookprice.doubleValue > 0)
                tfItem.text = [NSString stringWithFormat:@"%.2f", _mCarInfoEdit.bookprice.doubleValue];
            
            // 添加参考价
            _wvReferencePrice = [[UIWebView alloc] initWithClearFrame:CGRectMake(9, tfItem.maxY + 4, tfItem.width + 10, tfItem.height - 10)];
            _wvReferencePrice.opaque = NO;
            _wvReferencePrice.scrollView.scrollEnabled = NO;
            [_vCarPrice addSubview:_wvReferencePrice];
            [self loadReferencePrice:nil];
            
            // 分割线
            UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(17, tfItem.maxY, _vCarPrice.width - 34, kLinePixel) color:kColorNewLine];
            [_vCarPrice addSubview:vLine];
        }
        else if ([labLeft.text hasPrefix:@"过户费用"]) {
            vRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 82, tfItem.height)];
            
            // 开关
            KLSwitch *swc = [[KLSwitch alloc] initWithFrame:CGRectMake(0, (vRight.height - 32) / 2, 75, 32)];
            [swc addTarget:self action:@selector(onClickSwitch:) forControlEvents:UIControlEventValueChanged];
            tfItem.tag = kCarBasicSwitchTransferfee;
            swc.on = _mCarInfoEdit.isincludetransferfee.boolValue;
            swc.tag = tfItem.tag;
            [swc setContrastLabelText:@"不含"];
            [swc setOnLabelText:@"包含"];
            
            [vRight addSubview:swc];
        }
        
        if ([labLeft.text hasPrefix:@"预售价格"]) {
            vRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGFLOAT_MIN, tfItem.height)];
            
            // 单位
            UILabel *labUnit = [[UILabel alloc] init];
            labUnit.textAlignment = NSTextAlignmentRight;
            labUnit.font = kFontNormal;
            labUnit.textColor = kColorNewGray2;
            labUnit.text = @"万元";
            [labUnit sizeToFit];
            labUnit.origin = CGPointMake(10, (vRight.height - labUnit.height) / 2);
            
            // 铅笔图标
            UIImage *iPencil = [UIImage imageNamed:@"sellcar_publish_butten"];
            UIImageView *ivPencil = [[UIImageView alloc] initWithImage:iPencil];
            ivPencil.origin = CGPointMake(labUnit.maxX + 8, (vRight.height - ivPencil.height) / 2);
            
            [vRight addSubview:ivPencil];
            [vRight addSubview:labUnit];
            vRight.width = ivPencil.width + labUnit.width + 31;
        }
        
        tfItem.leftView = labLeft;
        tfItem.rightView = vRight;
        tfItem.leftViewMode = UITextFieldViewModeAlways;
        tfItem.rightViewMode = UITextFieldViewModeAlways;
        tfItem.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        basicMinY += tfItem.height;
        // 留出参考价位置
        if (i == 0)
            basicMinY += tfItem.height;
        
        if (i < basicTitles.count) {
            // 分割线
            UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, basicMinY - kLinePixel, _vCarPrice.width, kLinePixel) color:kColorNewLine];
            [_vCarPrice addSubview:vLine];
        }
        
        [_vCarPrice addSubview:tfItem];
    }
    _vCarPrice.height = basicMinY;
}

/* 联系信息 */
- (void)initCarConect
{
    // 联系信息
    if (!_vCarConect) {
        _vCarConect = [[UIView alloc] initWithFrame:CGRectMake(0, _vCarPrice.maxY + 21, _svMain.width, kUnkown)];
        _vCarConect.backgroundColor = kColorWhite;
        
        // 上分割线
        UIView *vTopLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, _vCarConect.width, kLinePixel) color:kColorNewLine];
        
        [_vCarConect addSubview:vTopLine];
        [_svMain addSubview:_vCarConect];
    } else {
        [_vCarConect removeAllSubviews];
    }
    
    NSArray *contactTitles = nil;
    
    if (_isBusiness) {
        contactTitles = @[@"销售代表", @"Q Q号码"];
        UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
        NSArray *salesList = mUserInfo.salespersonlist;
        for (int i = 0; i < salesList.count; i++) {
            SalesPersonModel *itemModel = [salesList objectAtIndex:i];
            if (_mCarInfoEdit.salesPerson.salesid.integerValue == itemModel.salesid.integerValue) {
                _mCarInfoEdit.salesPerson.salesname = itemModel.salesname;
                _mCarInfoEdit.salesPerson.salesqq = itemModel.salesqq;
                _mCarInfoEdit.salesPerson.salesphone = itemModel.salesphone;
            }
        }
    }
    else
        contactTitles = @[@"联  系  人", @"手机号码"];
    
    CGFloat connectMinY = 0;
    CGFloat itemHeight = 50;
    for (int i = 0; i < contactTitles.count; i++) {
        // 标题
        UILabel *labLeft = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 14, 100, 18)];
        labLeft.textColor = kColorNewGray2;
        labLeft.font = kFontNormal;
        labLeft.text = [contactTitles objectAtIndex:i];
        
        UITextField *tfItem = [[UITextField alloc] initWithFrame:CGRectMake(17, connectMinY, _vCarLicense.width - 17, itemHeight)];
        tfItem.textAlignment = NSTextAlignmentRight;
        tfItem.delegate = self;
        tfItem.font = kFontNormal;
        tfItem.textColor = kColorNewGray1;
        tfItem.keyboardType = UIKeyboardTypeDefault;
        
        NSString *strName = nil;
        NSString *strPhone = nil;
        NSString *strQQ = nil;
        if (_mCarInfoEdit.salesPerson.salesname.length > 0)
            strName = [[NSString stringWithFormat:@"%@", _mCarInfoEdit.salesPerson.salesname] dNull];
        if (_mCarInfoEdit.salesPerson.salesphone.length > 0)
            strPhone =[[NSString stringWithFormat:@"%@", _mCarInfoEdit.salesPerson.salesphone] dNull];
        if (_isBusiness && _mCarInfoEdit.salesPerson.salesqq.length > 0) {
            strQQ = [[NSString stringWithFormat:@"%@", _mCarInfoEdit.salesPerson.salesqq] dNull];
        }
        
        // 销售代表 联系人
        if ([labLeft.text hasPrefix:@"销售代表"] || [labLeft.text hasPrefix:@"联  系  人"]) {
            tfItem.tag = kCarContactFirstTag;
            if (_isBusiness) {
                // 商家卖车使用选择器选销售代表
                tfItem.inputView = _vSelector;
                if (strName.length > 0 && strPhone.length > 0)
                    tfItem.text = [NSString stringWithFormat:@"%@ %@", strName, strPhone];
            } else {
                // 解决中文联想监听不响应问题
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:tfItem];
                if (strName.length > 0)
                    tfItem.text = [NSString stringWithFormat:@"%@", strName];
            }
        }
        
        // QQ号码 手机号码
        if ([labLeft.text hasPrefix:@"Q Q号码"] || [labLeft.text hasPrefix:@"手机号码"]) {
            tfItem.tag = kCarContactSecondTag;
            tfItem.keyboardType = UIKeyboardTypeNumberPad;
            if (_isBusiness) {
                labLeft.enabled = NO;
                if (strQQ.length > 0)
                    tfItem.text = [NSString stringWithFormat:@"%@", strQQ];
            } else {
                if (strPhone.length > 0)
                    tfItem.text = [NSString stringWithFormat:@"%@", strPhone];
            }
        }
        
        // 竖分割线
        UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(95 - 17, (tfItem.height - 24) / 2, kLinePixel, 24) color:kColorNewLine];
        [tfItem addSubview:vLine];
        
        // 右视图
        UIImage *iPencil = [UIImage imageNamed:@"sellcar_publish_butten"];
        UIView *vRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPencil.width + 23, tfItem.height)];
        // 铅笔图标
        if (![labLeft.text hasPrefix:@"Q Q号码"]) {
            UIImageView *ivPencil = [[UIImageView alloc] initWithImage:iPencil];
            ivPencil.origin = CGPointMake(8, (vRight.height - ivPencil.height) / 2);
            [vRight addSubview:ivPencil];
        }
        
        tfItem.leftView = labLeft;
        tfItem.leftViewMode = UITextFieldViewModeAlways;
        tfItem.rightView = vRight;
        tfItem.rightViewMode = UITextFieldViewModeAlways;
        tfItem.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tfItem.textAlignment = NSTextAlignmentRight;
        
        // 分割线
        if (i > 0) {
            UIView *vCellLine = [[UIView alloc] initLineWithFrame:CGRectMake(([labLeft.text hasPrefix:@"Q Q号码"] ? 17 : 0), connectMinY + 1 - kLinePixel, _vCarConect.width - ([labLeft.text hasPrefix:@"Q Q号码"] ? 17 * 2 : 0), kLinePixel) color:kColorNewLine];
            [_vCarConect addSubview:vCellLine];
        }
        
        connectMinY += tfItem.height;
        
        [_vCarConect addSubview:tfItem];
    }
    
    /** 卖家附言标题 */
    UIView *vComment = [[UIView alloc] initWithFrame:CGRectMake(0, connectMinY, _svMain.width , 50)];
    vComment.backgroundColor = kColorWhite;
    vComment.tag = kCarContactThirdTag;
    
    // 卖家附言
    UILabel *labCommentTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(18, 0, 0, 0)];
    labCommentTitle.textColor = kColorNewGray2;
    labCommentTitle.font = kFontNormal;
    labCommentTitle.text = @"卖家附言";
    [labCommentTitle sizeToFit];
    labCommentTitle.origin = CGPointMake(18, (vComment.height - labCommentTitle.height) / 2);
    
    // 提示非必填
    UILabel *labTips = [[UILabel alloc] initWithFrame:CGRectMake(78, 19, 0, 0)];
    labTips.textColor =  kColorNewGray2;
    labTips.font = kFontTiny;
    labTips.text = @"(非必填)";
    [labTips sizeToFit];
    
    // 竖分割线
    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(labTips.maxX + 21, (vComment.height - 24) / 2, kLinePixel, 24) color:kColorNewLine];
    
    // 字数
    UILabel *labCount = [[UILabel alloc] initWithClearFrame:CGRectMake(vComment.width - 60, 19, 0, 0)];
    labCount.tag = kCarDescribeTextCountTag;
    labCount.textColor =  kColorNewGray2;
    labCount.font = kFontTiny;
    labCount.text = @"1000";
    [labCount sizeToFit];
    
    if (self.mCarInfoEdit.usercomment.length>0) {
        labCount.text = [NSString stringWithFormat:@"%d", 1000 - self.mCarInfoEdit.usercomment.length];
    }
    
    // 铅笔图片
    UIImage *image = [UIImage imageNamed:@"sellcar_publish_butten"];
    UIImageView *ivPencil = [[UIImageView alloc] initWithImage:image];
    ivPencil.origin = CGPointMake(vComment.width - 29, (vComment.height - image.height) / 2);
    
    // 辅助输入按钮
    UIButton *onInputBtn = [[UIButton alloc] initWithClearFrame:CGRectMake(0, 0, vComment.width, itemHeight)];
    [onInputBtn addTarget:self action:@selector(onClickOnInputBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    // 底分割线
    UIView *vTopLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, vComment.width, kLinePixel) color:kColorNewLine];
    [vComment addSubview:vTopLine];
    
    
    /** 留言输入框 */
    UITextView *tvText = [[UITextView alloc] initWithFrame:CGRectMake(13, vComment.maxY - 10, _vCarLicense.width - 13 * 2, 110)];
    tvText.tag = kCarDescribeTextTag;
    tvText.delegate = self;
    tvText.backgroundColor = [UIColor clearColor];
    tvText.font = kFontNormal;
    if (_mCarInfoEdit.usercomment)
        tvText.text = _mCarInfoEdit.usercomment;
    
    /** 无qq隐藏 */
    if (_isBusiness && _mCarInfoEdit.salesPerson.salesqq.length == 0) {
        // 销售代表输入框
        UITextField *tfSalesPersonItem = (UITextField *)[_svMain viewWithTag:kCarContactFirstTag];
        vComment.minY = tfSalesPersonItem.maxY;tvText.minY = vComment.maxY;
        _vCarConect.height = tvText.maxY;
        _svMain.contentSize = CGSizeMake(_svMain.width, _vCarConect.maxY + 20);
    }
    
    [vComment addSubview:labCommentTitle];
    [vComment addSubview:labCount];
    [vComment addSubview:labTips];
    [vComment addSubview:ivPencil];
    [vComment addSubview:vLine];
    [vComment addSubview:onInputBtn];
    [_vCarConect addSubview:vComment];
    [_vCarConect addSubview:tvText];
    
    _vCarConect.height = tvText.maxY + 20;
}

#pragma mark - private Method
/** 选择图片方式 */
- (void)setShowChoosePhotoView:(UCUploadPhotosView *)vUploadPhoto
{
    // 创建选择方式视图
    _isShowChooseView = !_isShowChooseView;
    
    UIControl *cBlackBg = nil;
    
    // 是否展开提示图
    NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
    if ([userDefult objectForKey:@"isShowExamplePhoto"]) {
        _isShowExamplePhoto = [userDefult boolForKey:@"isShowExamplePhoto"];
    } else {
        _isShowExamplePhoto = YES;
        [userDefult setBool:_isShowExamplePhoto forKey:@"isShowExamplePhoto"];
    }
    CGFloat vChoosePhotoHetght = vUploadPhoto.tag == UCCarPhotoViewStyleCarPhoto ? (_isShowExamplePhoto ? kChoosePhotoViewHeight : kChoosePhotoViewHeight_small) : kChoosePhotoBtnViewHeight;
    
    if (_isShowChooseView) {
        // 背景视图
        cBlackBg = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        cBlackBg.tag = kBlackBgViewTag;
        [cBlackBg addTarget:self action:@selector(onClickCloseChooseViewControl:) forControlEvents:UIControlEventTouchUpInside];
        cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        [cBlackBg addSubview:_vChoosePhoto];
        [self addSubview:cBlackBg];
        
        // 创建选择图片视图
        if (!_vChoosePhoto) {
            // 选图片视图
            _vChoosePhoto = [[UIView alloc] initWithFrame:CGRectMake(0, cBlackBg.height - vChoosePhotoHetght, cBlackBg.width, vChoosePhotoHetght)];
            _vChoosePhoto.layer.masksToBounds = YES;
            _vChoosePhoto.backgroundColor = kColorWhite;
            [cBlackBg addSubview:_vChoosePhoto];
            
            // 选项视图
            _vChoosePhotoBtn = [[UIView alloc] initWithFrame:CGRectMake(0, _vChoosePhoto.height - kChoosePhotoBtnViewHeight, _vChoosePhoto.width, kChoosePhotoBtnViewHeight)];
            _vChoosePhotoBtn.backgroundColor = kColorWhite;
            
            // 分割线
            UIView *vLineTop = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, _vChoosePhotoBtn.width, kLinePixel) color:kColorNewLine];
            
            // 拍照
            UIButton *btnPhotograph = [[UIButton alloc] initWithFrame:CGRectMake(0, vLineTop.maxY, _vChoosePhotoBtn.width / 2, 95)];
            [btnPhotograph setImage:[UIImage imageNamed:@"releasecar_photograph"] forState:UIControlStateNormal];
            [btnPhotograph setTitle:@"拍照" forState:UIControlStateNormal];
            [btnPhotograph setTitleColor:kColorBlue1 forState:UIControlStateNormal];
            btnPhotograph.titleLabel.font = [UIFont systemFontOfSize:15];
            [btnPhotograph setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnPhotograph.size] forState:UIControlStateHighlighted];
            btnPhotograph.tag = 0;
            [btnPhotograph setTitleEdgeInsets:UIEdgeInsetsMake(36, -btnPhotograph.imageView.width, 0, 0)];
            [btnPhotograph setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 29, -btnPhotograph.titleLabel.width)];
            [btnPhotograph addTarget:self action:@selector(onClickGetPhotoBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            // 分割线
            UIView *vLineMiddle = [[UIView alloc] initLineWithFrame:CGRectMake(btnPhotograph.maxX, (btnPhotograph.height - 55) / 2, kLinePixel, 55) color:kColorNewLine];
            
            // 从相册选择
            UIButton *btnAlbum = [[UIButton alloc] initWithFrame:CGRectMake(vLineMiddle.maxX, btnPhotograph.minY, _vChoosePhotoBtn.width / 2, btnPhotograph.height)];
            btnAlbum.tag = 1;
            [btnAlbum setImage:[UIImage imageNamed:@"releasecar_album"] forState:UIControlStateNormal];
            [btnAlbum setTitle:@"从相册选择" forState:UIControlStateNormal];
            [btnAlbum setTitleColor:kColorBlue1 forState:UIControlStateNormal];
            btnAlbum.titleLabel.font = [UIFont systemFontOfSize:15];
            [btnAlbum setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnAlbum.size] forState:UIControlStateHighlighted];
            [btnAlbum setTitleEdgeInsets:UIEdgeInsetsMake(36, -btnAlbum.imageView.width, 0, 0)];
            [btnAlbum setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 29, -btnAlbum.titleLabel.width)];
            [btnAlbum addTarget:self action:@selector(onClickGetPhotoBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            // 取消按钮
            UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, btnAlbum.maxY, _vChoosePhotoBtn.width, _vChoosePhotoBtn.height - btnAlbum.maxY)];
            [btnCancel addTarget:self action:@selector(onClickCancelUploadBtn:) forControlEvents:UIControlEventTouchUpInside];
            [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
            [btnCancel setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnCancel.size] forState:UIControlStateHighlighted];
            btnCancel.titleLabel.font = [UIFont systemFontOfSize:15];
            [btnCancel setTitleColor:kColorBlue1 forState:UIControlStateNormal];
            
            // 分割线
            UIView *vLineBottom = [[UIView alloc] initLineWithFrame:CGRectMake(0, btnCancel.minY - kLinePixel, _vChoosePhotoBtn.width, kLinePixel) color:kColorNewLine];
            
            [_vChoosePhoto addSubview:_vChoosePhotoBtn];
            [_vChoosePhotoBtn addSubview:vLineTop];
            [_vChoosePhotoBtn addSubview:btnPhotograph];
            [_vChoosePhotoBtn addSubview:vLineMiddle];
            [_vChoosePhotoBtn addSubview:btnAlbum];
            [_vChoosePhotoBtn addSubview:btnCancel];
            [_vChoosePhotoBtn addSubview:vLineBottom];
        }
        
        // 选车图片
        if (vUploadPhoto.tag == UCCarPhotoViewStyleCarPhoto) {
            // 提示view
            if (!_vChoosePhotoPrompt) {
                _vChoosePhotoPrompt = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _vChoosePhoto.width, 225)];
                _vChoosePhotoPrompt.backgroundColor = kColorWhite;
                
                // 文字
                UILabel *labTopPrompt = [[UILabel alloc] init];
                labTopPrompt.backgroundColor = [UIColor clearColor];
                labTopPrompt.text = @"横向拍摄效果更佳\n上传以下全部角度图片可提高列表排名";
                labTopPrompt.font = [UIFont systemFontOfSize:11];
                labTopPrompt.numberOfLines = 2;
                [labTopPrompt sizeToFit];
                labTopPrompt.origin = CGPointMake(14, 17);
                
                // 按钮
                UIButton *btnShow = [[UIButton alloc] initWithFrame:CGRectMake(_vChoosePhoto.width - 64, 0, 64, 64)];
                btnShow.tag = kShowExampleBtnTag;
                [btnShow setImage:[UIImage imageNamed:_isShowExamplePhoto ?  @"releasecar_extend_hide" : @"releasecar_extend_show"] forState:UIControlStateNormal];
                [btnShow addTarget:self action:@selector(onClickSetShowExamplePhotoBtn) forControlEvents:UIControlEventTouchUpInside];
                
                // 示例图片
                UIImage *iExample = [UIImage imageNamed:@"releasecar_referencephoto"];
                UIImageView *ivExample = [[UIImageView alloc] initWithFrame:CGRectMake((_vChoosePhoto.width - iExample.width) / 2, btnShow.height, iExample.width, iExample.height)];
                ivExample.image = iExample;
                
                [_vChoosePhoto addSubview:_vChoosePhotoPrompt];
                [_vChoosePhotoPrompt addSubview:labTopPrompt];
                [_vChoosePhotoPrompt addSubview:btnShow];
                [_vChoosePhotoPrompt addSubview:ivExample];
                
                [_vChoosePhoto sendSubviewToBack:_vChoosePhotoPrompt];
            }
        }
        _vChoosePhoto.height = vChoosePhotoHetght;
        _vChoosePhotoBtn.minY = vUploadPhoto.tag == UCCarPhotoViewStyleCarPhoto ? _vChoosePhoto.height - kChoosePhotoBtnViewHeight : 0;
        
        // 动画开启
        _vChoosePhoto.minY = cBlackBg.height;
        [UIView animateWithDuration:kAnimateSpeedFast animations:^{
            cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
            _vChoosePhoto.minY = cBlackBg.height - vChoosePhotoHetght;
            
        }completion:^(BOOL finished) {
        }];
    } else {
        cBlackBg = (UIControl *)[self viewWithTag:kBlackBgViewTag];
        // 动画关闭
        [UIView animateWithDuration:kAnimateSpeedFlash animations:^{
            _vChoosePhoto.minY = cBlackBg.height;
            cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        }completion:^(BOOL finished) {
            [cBlackBg removeFromSuperview];
            [_vChoosePhoto removeFromSuperview];
        }];
    }
}

/* 执行关闭 */
- (void)doCancel
{
    [self endEditing:YES];
    
    // 停止车辆照片请求
    [self stopCarPhotoRequest];
    
    // 通知发车关闭
    if ([self.delegate respondsToSelector:@selector(releaseCarClose:)])
        [self.delegate releaseCarClose:self.mCarInfoEdit];
    
    if (_isEditMode)
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    else
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/** 修正车辆信息居中 */
- (void)setCarInfoTextField:(UITextField *)tfCarInfo FirstText:(NSString *)firstText secondText:(NSString *)secondText isCustomCar:(BOOL)isCustomCar;
{
    // 设置文字显示
    if (isCustomCar)
        tfCarInfo.text = [NSString stringWithFormat:@"%@ %@ %@L", self.mCarInfoEdit.carname, self.mCarInfoEdit.gearbox, self.mCarInfoEdit.displacement];
    else
        tfCarInfo.text = [NSString stringWithFormat:@"%@ %@", firstText, secondText];
    
    if (isCustomCar)
        // 设置参考价暂无数据
        [self loadReferencePrice:nil];
}

/* 选择车辆信息 */
- (void)switchChooseCarView
{
    if (![[MainViewController sharedVCMain].vTop isKindOfClass:[UCChooseCarView class]]) {
        [self endEditing:YES];
        UCChooseCarView *vChooseCar = [[UCChooseCarView alloc] initWithCustomCarFrame:[MainViewController sharedVCMain].vMain.bounds viewStyle:UCFilterBrandViewStyleModel];
        vChooseCar.delegate = self;
        [[MainViewController sharedVCMain] openView:vChooseCar animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
        
        [UMStatistics event:_isBusiness ? pv_3_1_buinessInformationselect : pv_3_1_personInformationselect];
    }
}

- (void)adjustFirstResponder:(UIView *)vFirstResponder
{
    if (_keyboardHeight > 0) {
        CGRect vFirstResponderRect = [_svMain convertRect:vFirstResponder.frame fromView:vFirstResponder.superview];
        vFirstResponderRect.origin.y = vFirstResponderRect.origin.y - _svMain.contentOffset.y; // 标题栏占位偏移
        // 卖家描述
        if (vFirstResponder.tag == kCarDescribeTextTag) {
            vFirstResponderRect.origin.y += 20;
        }
        else if (vFirstResponder.tag == kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 0) {
            vFirstResponderRect.origin.y += 44 * 3 + 60; // 点击上牌日期多移动 44 * 3 + 60
        } else {
            vFirstResponderRect.origin.y += 88; // 往上多提88像素, 方便点击下一项
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            _svMain.contentInset = UIEdgeInsetsMake(_svMain.contentInset.top, 0, _keyboardHeight, 0);
            _svMain.scrollIndicatorInsets = _svMain.contentInset;
            CGFloat offsetHeight = _svMain.height - _keyboardHeight - (vFirstResponderRect.origin.y + vFirstResponderRect.size.height);
            if(offsetHeight < 0)
                _svMain.contentOffset = CGPointMake(0, _svMain.contentOffset.y - offsetHeight); // 标题栏占位偏移
        }];
    }
}

/** 停止车辆照片请求 */
- (void)stopCarPhotoRequest
{
    if (_clickUploadPhotosTag == 0)
        [_vUploadPhotos stopCarPhotoRequest];
    else if (_clickUploadPhotosTag == 1)
        [_vUploadDrivingLicense stopCarPhotoRequest];
    else if (_clickUploadPhotosTag == 2)
        [_vUploadTextReportPhoto stopCarPhotoRequest];
    
}

/** 参考价KVO */
- (void)setKVOPrice:(BOOL)isOpen keys:(NSArray *)keys
{
    for (NSString *key in keys) {
        if (isOpen) {
            [_mCarInfoEdit addObserver:self forKeyPath:key options:NSKeyValueObservingOptionOld context:nil];
        } else {
            [_mCarInfoEdit removeObserver:self forKeyPath:key];
        }
    }
}

/** 加载参考价 */
-(void)getReferencePrice
{
    if (_mCarInfoEdit.productid.integerValue > 0 && _mCarInfoEdit.provinceid.integerValue > 0 && _mCarInfoEdit.drivemileage.integerValue && _mCarInfoEdit.firstregtime.length > 0) {
        // 获取参考价
        _mPrice.specid = _mCarInfoEdit.productid;
        _mPrice.pid = _mCarInfoEdit.provinceid;
        _mPrice.cid = _mCarInfoEdit.cityid;
        _mPrice.mileage = _mCarInfoEdit.drivemileage;
        _mPrice.firstregtime = _mCarInfoEdit.firstregtime;
        [self getReferencePrice:_mPrice];
    } else {
        [self loadReferencePrice:nil];
    }
}

/** 是否包含字母或者数字 */
- (BOOL)isContainAlphanumeric:(NSString *)str
{
    BOOL isContainAlphanumeric = NO;
    
    NSString *regex = @"^[A-Za-z]+[0-9]+[A-Za-z0-9]*|[0-9]+[A-Za-z]+[A-Za-z0-9]*$";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([predicate evaluateWithObject:str] == YES) {
        isContainAlphanumeric = YES;
    }
    
    return isContainAlphanumeric;
}

#pragma mark - onClickBtn
/* 点击取消按钮 */
- (void)onClickCancel:(UIButton *)btn
{
    // 获取照片路径
    self.mCarInfoEdit.imgurls = [_vUploadPhotos stringImageUrls];
    self.mCarInfoEdit.dctionimg = [_vUploadTextReportPhoto stringImageUrls];
    self.mCarInfoEdit.driverlicenseimage = [_vUploadDrivingLicense stringImageUrls];
    
    // 未填写任何内容、线上数据、数据未做任何修改 直接退出
    if ((self.mCarInfoEditOrigin == nil && [self.mCarInfoEdit isNull]) || self.mCarInfoEdit.carid.integerValue > 0 || [self.mCarInfoEdit isEqualModel:self.mCarInfoEditOrigin]) {
        [self doCancel];
    }
    // 提示 保存到未填完 还是 继续填写
    else {
        NSInteger tag;
        NSString *message = nil;
        if ([self.mCarInfoEdit isNull]) {
            message = @"当前车源无有效信息，关闭后将从列表中清除";
            tag = kAlertNoValidDataTag;
        } else {
            message = @"是否取消发布此车辆，取消后车辆将保存到未填完列表";
            tag = kAlertCloseReleaseTag;
        }
        UIAlertView *vAlert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"继续填写", nil];
        [vAlert show];
        vAlert.tag = tag;
    }
}

/* 点击发布按钮 */
- (void)onClickRelease:(UIButton *)btn
{
    [UMStatistics event:_isBusiness ? c_3_1_salecarreleasebusiness : c_3_1_salecarrelease];
    
    // 先判断未上传
    NSInteger notUploadNum = [_vUploadPhotos notUploadNum];
    if (notUploadNum == NSNotFound) {
        [[AMToastView toastView] showMessage:@"请添加车辆图片" icon:kImageRequestError duration:AMToastDurationNormal];
        return;
    }
    // 判断是否上传行驶证
    if (_isBusiness) {
        NSInteger notUploadNumDriving = [_vUploadDrivingLicense notUploadNum];
        if ((_isVINUser && notUploadNumDriving == NSNotFound) || (!_isVINUser && _mCarInfoEdit.vincode.length > 0 && notUploadNumDriving == NSNotFound)) {
            [[AMToastView toastView] showMessage:@"请添加行驶证图片" icon:kImageRequestError duration:AMToastDurationNormal];
            return;
        } else {
            self.mCarInfoEdit.driverlicenseimage = [_vUploadDrivingLicense stringImageUrls];
        }
    }
    // 是否显示检测报告
    KLSwitch *swTestReport = (KLSwitch *)[self viewWithTag:kCarTestReportViewTag + kCarChangeStartValueTag + 1];
    if (_isShowTestReportView) {
        // 先判断检测报告未上传
        if (swTestReport.isOn) {
            NSInteger notUploadNumTestReport = [_vUploadTextReportPhoto notUploadNum];
            if (notUploadNumTestReport == NSNotFound) {
                [[AMToastView toastView] showMessage:@"请先添加检测报告" icon:kImageRequestError duration:AMToastDurationNormal];
                return;
            } else {
                self.mCarInfoEdit.certificatetype = [NSNumber numberWithInteger:10];
                self.mCarInfoEdit.dctionimg = [_vUploadTextReportPhoto stringImageUrls];
            }
        } else {
            self.mCarInfoEdit.dctionimg = nil;
            self.mCarInfoEdit.certificatetype = [NSNumber numberWithInteger:0];
        }
    }
    
    // 错误个数信息
    NSMutableArray *errors = [NSMutableArray array];
    // VIN码
    if ((_isBusiness && _mCarInfoEdit.vincode.length > 0 && _mCarInfoEdit.vincode.length != 17) || (_isVINUser && _mCarInfoEdit.vincode.length != 17)) [errors addObject:[NSNumber numberWithInt:kCarBasicDepositTag]];
    if ((self.mCarInfoEdit.carname.length == 0 || self.mCarInfoEdit.displacement.length == 0 || self.mCarInfoEdit.gearbox.length == 0) && (self.mCarInfoEdit.brandid.integerValue == 0 || self.mCarInfoEdit.seriesid.integerValue == 0 || self.mCarInfoEdit.productid.integerValue == 0)) [errors addObject:[NSNumber numberWithInt:kCarBasicCarInfoTag]];
    if (self.mCarInfoEdit.bookprice.doubleValue == 0) [errors addObject:[NSNumber numberWithInt:kCarBasicBookingPriceTag]];
    if (self.mCarInfoEdit.drivemileage.doubleValue == 0) [errors addObject:[NSNumber numberWithInt:kCarBasicDriveMileageTag]];
    if (self.mCarInfoEdit.provinceid.integerValue == 0 || self.mCarInfoEdit.cityid.integerValue == 0) [errors addObject:[NSNumber numberWithInt:kCarBasicLocationTag]];
    if (self.mCarInfoEdit.colorid.integerValue == 0) [errors addObject:[NSNumber numberWithInt:kCarBasicCarColorTag]];
    
    if (self.mCarInfoEdit.firstregtime.length == 0) [errors addObject:[NSNumber numberWithInt:kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 0]];
    if (self.mCarInfoEdit.verifytime.length == 0) [errors addObject:[NSNumber numberWithInt:kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 1]];
    if (self.mCarInfoEdit.veticaltaxtime.length == 0) [errors addObject:[NSNumber numberWithInt:kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 2]];
    if (self.mCarInfoEdit.insurancedate.length == 0) [errors addObject:[NSNumber numberWithInt:kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 3]];
    
    // 商家
    if (_isBusiness) {
        if (self.mCarInfoEdit.purposeid.integerValue == 0) [errors addObject:[NSNumber numberWithInt:kCarBasicCarPurposesTag]];
        if (self.mCarInfoEdit.salesPerson.salesname.length == 0 || self.mCarInfoEdit.salesPerson.salesphone.length == 0) [errors addObject:[NSNumber numberWithInt:kCarContactFirstTag]];
        
        // 延长质保
        KLSwitch *swExtendedrepair = (KLSwitch *)[self viewWithTag:kCarExtendedrepairViewTag + kCarChangeStartValueTag + 1];
        
        if (swExtendedrepair.isOn) {
            UITextField *tfExtendedrepairTime = (UITextField *)[self viewWithTag:kCarExtendedrepairViewTag +kCarChangeStartValueTag + 3];
            UITextField *tfExtendedrepairMileage = (UITextField *)[self viewWithTag:kCarExtendedrepairViewTag +kCarChangeStartValueTag + 4];
            
            BOOL isRepairTimeNull = tfExtendedrepairTime.text.length > 0 ? NO : YES;
            BOOL isRepairMileageNull = (tfExtendedrepairMileage.text.length > 0 && [tfExtendedrepairMileage.text floatValue] != 0) ? NO : YES;
            
            // 有一项未填写
            if (isRepairMileageNull + isRepairTimeNull > 0) {
                if (isRepairTimeNull)
                    [errors addObject:[NSNumber numberWithInt:kCarExtendedrepairViewTag + kCarChangeStartValueTag + 3]];
                if (isRepairMileageNull)
                    [errors addObject:[NSNumber numberWithInteger:kCarExtendedrepairViewTag + kCarChangeStartValueTag + 4]];
            }
        }
    }
    // 个人
    else {
        if (self.mCarInfoEdit.salesPerson.salesname.length == 0) [errors addObject:[NSNumber numberWithInt:kCarContactFirstTag]];
        if (self.mCarInfoEdit.salesPerson.salesphone.length != 11) [errors addObject:[NSNumber numberWithInt:kCarContactSecondTag]];
        if (self.mCarInfoEdit.drivingpermit.integerValue == 0) [errors addObject:[NSNumber numberWithInt:kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 4]];
        if (self.mCarInfoEdit.registration.integerValue == 0) [errors addObject:[NSNumber numberWithInt:kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 5]];
        if (self.mCarInfoEdit.invoice.integerValue == 0) [errors addObject:[NSNumber numberWithInt:kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 6]];
    }
    
    // 未填完提示
    if (errors.count > 0) {
        [[AMToastView toastView] showMessage:[NSString stringWithFormat:@"还有%d项未填写", errors.count] icon:kImageRequestError duration:AMToastDurationNormal];
        for (NSNumber *num in errors) {
            UITextField *tfItem = (UITextField *)[_svMain viewWithTag:num.integerValue];
            // VIN码特殊处理
            UILabel *labTitle;
            if (num.integerValue == kCarBasicDepositTag) {
                UIView *vLeft = (UIView *)tfItem.leftView;
                labTitle = (UILabel *)[vLeft.subviews objectAtIndex:0];
            } else {
                labTitle = (UILabel *)tfItem.leftView;
            }
            labTitle.textColor = kColorRed; //font 16
        }
    }
    else if (_mCarInfoEdit.vincode.length == 17 && ![self isContainAlphanumeric:_mCarInfoEdit.vincode]) {
        [[AMToastView toastView] showMessage:@"VIN码不能全部为数字或英文" icon:kImageRequestError duration:AMToastDurationNormal];
        return;
    }
    else {
        NSInteger notUploadNum = [_vUploadPhotos notUploadNum];
        NSInteger notUploadTestReportNum = [_vUploadTextReportPhoto notUploadNum];
        NSInteger notUploadDrivingLicenseNum = [_vUploadDrivingLicense notUploadNum];
        
        if (notUploadNum == NSNotFound) {
            [[AMToastView toastView] showMessage:@"请添加车辆图片" icon:kImageRequestError duration:AMToastDurationNormal];
        } else if (notUploadNum > 0) {
            [[AMToastView toastView] showMessage:[NSString stringWithFormat:@"有%d张图片未上传成功", notUploadNum] icon:kImageRequestError duration:AMToastDurationNormal];
        } else if (notUploadDrivingLicenseNum > 0 && notUploadDrivingLicenseNum != NSNotFound) {
            [[AMToastView toastView] showMessage:@"行驶证未上传成功" icon:kImageRequestError duration:AMToastDurationNormal];
        } else if (swTestReport.isOn && notUploadTestReportNum == NSNotFound) {
            [[AMToastView toastView] showMessage:@"请添加检测报告" icon:kImageRequestError duration:AMToastDurationNormal];
        } else if (swTestReport.isOn && notUploadTestReportNum > 0) {
            [[AMToastView toastView] showMessage:[NSString stringWithFormat:@"有%d张检测报告未上传成功", notUploadTestReportNum] icon:kImageRequestError duration:AMToastDurationNormal];
        } else {
            self.mCarInfoEdit.imgurls = [_vUploadPhotos stringImageUrls];
            [self releaseCar];
        }
    }
}

/** 关闭键盘事件 */
- (void)onClickCloseKeyboard
{
    [self endEditing:YES];
}


/** 一口价帮助 */
/* 屏蔽一口价
 - (void)onClickHelp:(UIButton *)btn
 {
 // 此价格为最终成交价，如在此基础上还能优惠，经查实后将关闭此功能。
 UIAlertView *vAlert = [[UIAlertView alloc] initWithTitle:nil message:@"此价格为最终成交价，如在此基础上还能优惠，经查实后将关闭此功能。" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
 [vAlert show];
 }
 */

/** 点击切换是否显示上传的示例图片 */
- (void)onClickSetShowExamplePhotoBtn
{
    _isShowExamplePhoto = !_isShowExamplePhoto;
    // 是否展开计入缓存
    NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
    [userDefult setBool:_isShowExamplePhoto forKey:@"isShowExamplePhoto"];
    [userDefult synchronize];
    
    UIControl *cBlackBg = (UIControl *)[self viewWithTag:kBlackBgViewTag];
    
    // 修改按钮
    UIButton *btnShowExample = (UIButton *)[self viewWithTag:kShowExampleBtnTag];
    [btnShowExample setImage:[UIImage imageNamed:_isShowExamplePhoto ?  @"releasecar_extend_hide" : @"releasecar_extend_show"] forState:UIControlStateNormal];
    
    // 移动动画
    _vChoosePhoto.height = kChoosePhotoViewHeight;
    [UIView animateWithDuration:0.2 animations:^{
        _vChoosePhoto.minY = _isShowExamplePhoto ? cBlackBg.height - kChoosePhotoViewHeight : cBlackBg.height - kChoosePhotoViewHeight_small;
        _vChoosePhotoBtn.minY = (_isShowExamplePhoto ? kChoosePhotoViewHeight : kChoosePhotoViewHeight_small) - kChoosePhotoBtnViewHeight;
    } completion:^(BOOL finished) {
        if (!_isShowExamplePhoto)
            _vChoosePhoto.height = kChoosePhotoViewHeight_small;
    }];
}

/** 点击选择上传图片方式按钮 */
- (void)onClickGetPhotoBtn:(UIButton *)btn
{
    // 车辆图片
    if (_clickUploadPhotosTag == 0) {
        if (_vUploadPhotos) {
            [_vUploadPhotos onClickGetPhotoBtn:btn];
            [self onClickChoosePhotoButton:_vUploadPhotos];
        }
    }
    else if (_clickUploadPhotosTag == 1) {
        if (_vUploadDrivingLicense) {
            [_vUploadDrivingLicense onClickGetPhotoBtn:btn];
            [self onClickChoosePhotoButton:_vUploadDrivingLicense];
        }
    }
     // 检测报告
    else if (_clickUploadPhotosTag == 2) {
        if (_vUploadTextReportPhoto) {
            [_vUploadTextReportPhoto onClickGetPhotoBtn:btn];
            [self onClickChoosePhotoButton:_vUploadTextReportPhoto];
        }
    }
}

/** 点击取消上传图片按钮 */
- (void)onClickCancelUploadBtn:(UIButton *)btn
{
    [self onClickChoosePhotoButton:nil];
}

/** 辅助输入按钮 */
- (void)onClickOnInputBtn:(UIButton *)btn
{
    // 弹出键盘
    UITextView *tvComment = (UITextView *)[_vCarConect viewWithTag:kCarDescribeTextTag];
    if (!tvComment.isFirstResponder)
        [tvComment becomeFirstResponder];
}

#pragma mark - KLSwitch
/** 点击开关按钮事件 */
- (void)onClickSwitch:(KLSwitch *)swc
{
    // 过户费用
    if (swc.tag == kCarBasicSwitchTransferfee) {
        self.mCarInfoEdit.isincludetransferfee = [NSNumber numberWithBool:swc.isOn];
    }
    
    // 是否显示检测报告
    if (swc.tag == kCarTestReportViewTag + kCarChangeStartValueTag + 1) {
        if (_isShowTestReportView) {
            // 是否开启存到草稿
            _mCarInfoEdit.isTextReport = [NSNumber numberWithBool:swc.isOn];
            // 赋值
            if (swc.isOn) {
                NSString *url = [_vUploadTextReportPhoto stringImageUrls];
                _mCarInfoEdit.dctionimg = url.length > 0 ? url : nil;
                _mCarInfoEdit.certificatetype = [NSNumber numberWithInteger:10];
            } else {
                _mCarInfoEdit.certificatetype = [NSNumber numberWithInteger:0];
                _mCarInfoEdit.dctionimg = nil;
            }
            // 动画过度
            UIView *vExtendedrepair = (UIView *)[self viewWithTag:kCarExtendedrepairViewTag];
            // 检测报告
            UIView *vTextReport = (UIView *)[self viewWithTag:kCarTestReportViewTag];
            CGFloat vBoxHeight = swc.isOn ? 140 : 50;
            [UIView animateWithDuration:kAnimateSpeedFast animations:^{
                vTextReport.height = vBoxHeight;
                if (_isShowTestReportView) {
                    vExtendedrepair.minY = vTextReport.maxY;
                    _vCarLicense.height = vExtendedrepair.maxY;
                } else {
                    _vCarLicense.height = vTextReport.maxY;
                }
                // 检测报告和延长质保的底线
                _vLicenseBottomLine.minY = _vCarLicense.height - kLinePixel;
                _vCarPrice.minY = _vCarLicense.maxY + 21;
                _vCarConect.minY = _vCarPrice.maxY + 21;
                _svMain.contentSize = CGSizeMake(_svMain.width, _vCarConect.maxY + 20);
            }];
        }
    }
    
    // 延长质保
    if (swc.tag == kCarExtendedrepairViewTag + kCarChangeStartValueTag + 1) {
        UITextField *tfTime = (UITextField *)[self viewWithTag:kCarExtendedrepairViewTag + kCarChangeStartValueTag + 3];
        UITextField *tfMileage = (UITextField *)[self viewWithTag:kCarExtendedrepairViewTag + kCarChangeStartValueTag + 4];
        // 延长质保的非必填说明
        UILabel *labkRepairNotMandatory = (UILabel *)[_vCarLicense viewWithTag:kCarRepairNotMandatory];
        // 隐藏或显示延长质保的（非必填）
        labkRepairNotMandatory.hidden = swc.isOn;
        
        // 是否开启存到草稿
        _mCarInfoEdit.isExtendedrepair = [NSNumber numberWithBool:swc.isOn];
        
        if (swc.isOn) {
            // 赋值
            _mCarInfoEdit.extendedrepair = [NSNumber numberWithInteger:1];
            if (tfTime.text.length > 0)
                _mCarInfoEdit.qualityassdate = [NSNumber numberWithInteger:[tfTime.text integerValue]];
            if (tfMileage.text.length > 0)
                _mCarInfoEdit.qualityassmile = [NSNumber numberWithFloat:[tfMileage.text floatValue]];
        } else {
            // 赋值
            _mCarInfoEdit.qualityassdate = nil;
            _mCarInfoEdit.qualityassmile = nil;
            _mCarInfoEdit.extendedrepair = [NSNumber numberWithInteger:0];
            // 关闭键盘
            [self endEditing:YES];
            // 设置标题为正常颜色
            [(UILabel *)tfTime.leftView setTextColor:kColorNewGray2];
            [(UILabel *)tfMileage.leftView setTextColor:kColorNewGray2];
        }
        
        // 动画过度
        UIView *vExtendedrepair = (UIView *)[self viewWithTag:kCarExtendedrepairViewTag];
        CGFloat vBoxHeight = swc.isOn ? 150 : 50;
        [UIView animateWithDuration:kAnimateSpeedFast animations:^{
            vExtendedrepair.height = vBoxHeight;
            _vCarLicense.height = vExtendedrepair.maxY;
            _vCarPrice.minY = _vCarLicense.maxY + 21;
            _vCarConect.minY = _vCarPrice.maxY + 21;
            _svMain.contentSize = CGSizeMake(_svMain.width, _vCarConect.maxY + 20);
        }];
    }
    /* 屏蔽一口价
     // 一口价
     else if (swc.tag == kCarBasicSwitchFixprice) {
     self.mCarInfoEdit.isfixprice = [NSNumber numberWithBool:swc.isOn];
     }
     */
}

#pragma mark - NSNotification
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
    vFirstResponderRect.origin.y = vFirstResponderRect.origin.y - _svMain.contentOffset.y; // 标题栏占位偏移
    // 卖家描述
    if (vFirstResponder.tag == kCarDescribeTextTag) {
        vFirstResponderRect.origin.y += 20;
    } else if (vFirstResponder.tag == kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 0) {
        vFirstResponderRect.origin.y += 44 * 3 + 60; // 点击上牌日期多移动 44 * 3 + 60
    } else {
        vFirstResponderRect.origin.y += 88; // 往上多提88像素, 方便点击下一项
    }
    
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 保存到未填完
    if ((alertView.tag == kAlertNoValidDataTag && buttonIndex == alertView.cancelButtonIndex) || (alertView.tag == kAlertCloseReleaseTag && buttonIndex == alertView.cancelButtonIndex) || (alertView.tag == kAlertReleaseFailTag && buttonIndex == alertView.cancelButtonIndex)) {
        
        // 保存延长质保
        UITextField *tfExtendedrepairTime = (UITextField *)[self viewWithTag:kCarExtendedrepairViewTag +kCarChangeStartValueTag + 3];
        UITextField *tfExtendedrepairMileage = (UITextField *)[self viewWithTag:kCarExtendedrepairViewTag +kCarChangeStartValueTag + 4];
        self.mCarInfoEdit.qualityassdate = tfExtendedrepairTime.text.length > 0 ? [NSNumber numberWithInteger:[tfExtendedrepairTime.text integerValue]] : nil;
        self.mCarInfoEdit.qualityassmile = tfExtendedrepairMileage.text.length > 0 ? [NSNumber numberWithFloat:[tfExtendedrepairMileage.text floatValue]] : nil;
        
        // 准备保存到未填完
        NSMutableArray *mCarInfoEditDrafts = [NSMutableArray arrayWithArray:[AMCacheManage currentCarInfoEditDrafts]];
        
        NSInteger index = NSNotFound;
        for (int i = 0; i < mCarInfoEditDrafts.count; i++) {
            UCCarInfoEditModel *mCarInfoEditDraft = [mCarInfoEditDrafts objectAtIndex:i];
            // 找到对应的下标
            if (mCarInfoEditDraft.carid.doubleValue == self.mCarInfoEdit.carid.doubleValue) {
                index = i;
                break;
            }
        }
        
        if (alertView.tag == kAlertNoValidDataTag) {
            if (index != NSNotFound)
                [mCarInfoEditDrafts removeObjectAtIndex:index];
        } else {
            if (index == NSNotFound)
                [mCarInfoEditDrafts insertObject:self.mCarInfoEdit atIndex:0];
            else
                [mCarInfoEditDrafts setObject:self.mCarInfoEdit atIndexedSubscript:index];
        }
        
        // 写入缓存
        [AMCacheManage setCurrentCarInfoEditDrafts:mCarInfoEditDrafts];
        
        [self doCancel];
    }
    // 重新发车
    else if (alertView.tag == kAlertReleaseFailTag && buttonIndex == 1) {
        [self releaseCar];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    // 卖家留言
    if (textView.tag == kCarDescribeTextTag) {
        [self adjustFirstResponder:textView];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger count = 1000;
    // 卖家留言
    if (textView.tag == kCarDescribeTextTag) {
        if (textView.markedTextRange == nil && textView.text.length > count) {
            textView.text = [textView.text substringToIndex:count];
        }
        
        self.mCarInfoEdit.usercomment = textView.text;
        UILabel *labCount = (UILabel *)[_vCarConect viewWithTag:kCarDescribeTextCountTag];
        labCount.text = [NSString stringWithFormat:@"%d", count - textView.text.length];
        labCount.textColor = (count == count - textView.text.length) ? kColorNewGray2 : kColorNewOrange;
    }
}

#pragma mark - UCUploadPhotosViewDelegate
- (void)onClickChoosePhotoButton:(UCUploadPhotosView *)vUploadPhoto
{
    // 设置上传图片tag值
    if (vUploadPhoto)
        _clickUploadPhotosTag = vUploadPhoto.tag;
    
    // 关闭键盘
    [self onClickCloseKeyboard];
    
    // 显示或隐藏选择图片
    [self setShowChoosePhotoView:vUploadPhoto];
    
}

/** 单击背景收回选择图片视图 */
- (void)onClickCloseChooseViewControl:(UITapGestureRecognizer *)sender
{
    [self onClickChoosePhotoButton:nil];
}

#pragma mark - UCChooseCarViewDelegate
- (void)chooseCarView:(UCChooseCarView *)vChooseCar didFinishChooseWithInfo:(NSMutableDictionary *)info
{
    if (info) {
        NSString *brandID = [info objectForKey:@"brandid"];
        NSString *seriesID = [info objectForKey:@"seriesid"];
        NSString *productID = [info objectForKey:@"specid"];
        NSString *brandName = [info objectForKey:@"brandidText"];
        NSString *seriesName = [info objectForKey:@"seriesidText"];
        NSString *productName = [info objectForKey:@"specidText"];
        NSString *carName = [info objectForKey:@"CarName"];
        NSString *displacement = [info objectForKey:@"Displacement"];
        NSString *gearbox = [info objectForKey:@"Gearbox"];
        
        self.mCarInfoEdit.carname = carName;
        self.mCarInfoEdit.displacement = displacement;
        self.mCarInfoEdit.gearbox = gearbox;
        
        self.mCarInfoEdit.brandid = [NSNumber numberWithInteger:brandID.integerValue];
        self.mCarInfoEdit.seriesid = [NSNumber numberWithInteger:seriesID.integerValue];
        self.mCarInfoEdit.productid = [NSNumber numberWithInteger:productID.integerValue];
        self.mCarInfoEdit.brandname = brandName;
        self.mCarInfoEdit.seriesname = seriesName;
        self.mCarInfoEdit.productname = productName;
        
        UITextField *tfItem = (UITextField *)[_vCarBasic viewWithTag:kCarBasicCarInfoTag];
        if (carName && displacement && gearbox) {
            // 设置标题为正常颜色
            [(UILabel *)tfItem.leftView setTextColor:kColorNewGray2];
            // 显示车辆信息
            [self setCarInfoTextField:tfItem FirstText:self.mCarInfoEdit.carname secondText:self.mCarInfoEdit.gearbox isCustomCar:YES];
        } else if (brandID && seriesID && productID) {
            // 设置标题为正常颜色
            [(UILabel *)tfItem.leftView setTextColor:kColorNewGray2];
            // 显示车辆信息
            [self setCarInfoTextField:tfItem FirstText:self.mCarInfoEdit.seriesname secondText:self.mCarInfoEdit.productname isCustomCar:NO];
        } else {
            [[AMToastView toastView] showMessage:@"选择车辆信息异常" icon:kImageRequestError duration:AMToastDurationNormal];
        }
    }
    [[MainViewController sharedVCMain] closeView:vChooseCar animateOption:AnimateOptionMoveUp];
}

- (void)chooseCarViewDidCancel:(UCChooseCarView *)vChooseCar
{
    [[MainViewController sharedVCMain] closeView:vChooseCar animateOption:AnimateOptionMoveUp];
}

#pragma mark - AMRadioButtonDelegate
- (void)radioButton:(AMRadioButton *)radioButton atIndex:(NSUInteger)index inGroup:(NSString *)groupId
{
    [self endEditing:YES];
    UITextField *tfItem = (UITextField *)[_svMain viewWithTag:kCarBasicItemStartTag + radioButton.tag];
    // 设置标题为正常颜色
    [(UILabel *)tfItem.leftView setTextColor:kColorNewGray2];
    
    NSInteger number = NSNotFound;
    if (index == 0)
        number = 1;
    if (index == 1)
        number = 3;
    if (index == 2)
        number = 2;
    
    if ([groupId isEqualToString:@"行  驶  证"]) {
        self.mCarInfoEdit.drivingpermit = [NSNumber numberWithInteger:number];
    }
    else if ([groupId isEqualToString:@"登  记  证"]) {
        self.mCarInfoEdit.registration = [NSNumber numberWithInteger:number];
    }
    else if ([groupId isEqualToString:@"购车发票"]) {
        self.mCarInfoEdit.invoice = [NSNumber numberWithInteger:number];
    }
}

#pragma mark - UISelectorViewDelegate
- (void)selectorView:(UISelectorView *)selectorView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UITextField *tfItem = (UITextField *)[_svMain viewWithTag:kCarBasicItemStartTag + selectorView.tag];
    // 设置标题为正常颜色
    [(UILabel *)tfItem.leftView setTextColor:kColorNewGray2];
    
    // 销售代表
    if (selectorView.tag == kCarContactFirstTag - kCarBasicItemStartTag) {
        NSArray *salesPersonList = [AMCacheManage currentUserInfo].salespersonlist;
        if (salesPersonList.count > 0) {
            SalesPersonModel *mSalesPerson = [salesPersonList objectAtIndex:row];
            // 显示选中的销售代表
            tfItem.text = [NSString stringWithFormat:@"%@ %@", mSalesPerson.salesname, [NSString stringWithFormat:@"%@", mSalesPerson.salesphone]];
            
            // 连带显示qq
            if (_isBusiness) {
                // qq输入框
                UITextField *tfQQItem = (UITextField *)[_svMain viewWithTag:kCarBasicItemStartTag + selectorView.tag + 1];
                // 附言标题
                UIView *vCommentTitle = (UIView *)[_vCarConect viewWithTag:kCarContactThirdTag];
                // 附言输入框
                UITextView *tvComment = (UITextView *)[_vCarConect viewWithTag:kCarDescribeTextTag];
                
                // 有qq显示
                if (mSalesPerson.salesqq.length > 0)
                    tfQQItem.text = mSalesPerson.salesqq;
                [UIView animateWithDuration:kAnimateSpeedFast animations:^{
                    // 自适应显示或隐藏qq后的位置
                    vCommentTitle.minY = mSalesPerson.salesqq.length > 0 ? tfQQItem.maxY : tfItem.maxY;
                    tvComment.minY = vCommentTitle.maxY;
                    _vCarConect.height = tvComment.maxY;
                    _svMain.contentSize = CGSizeMake(_svMain.width, _vCarConect.maxY + 20);
                } completion:^(BOOL finished) {
                    // 无qq隐藏
                    if (mSalesPerson.salesqq.length == 0)
                        tfQQItem.text = @"";
                }];
            }
            
            // 保存数据到实体
            self.mCarInfoEdit.salesPerson = mSalesPerson;
        } else {
            // 设置标题为异常颜色
            [(UILabel *)tfItem.leftView setTextColor:kColorOrange];
        }
    }
    
    // 所在城市
    else if (selectorView.tag == kCarBasicLocationTag - kCarBasicItemStartTag) {
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
        self.mCarInfoEdit.provinceid = [NSNumber numberWithInteger:provinceId.integerValue];
        self.mCarInfoEdit.cityid = [NSNumber numberWithInteger:cityId.integerValue];
    }
    // 车辆用途
    else if (selectorView.tag == kCarBasicCarPurposesTag - kCarBasicItemStartTag) {
        tfItem.text = [_carPurposes objectAtIndex:row];
        // 保存数据到实体
        self.mCarInfoEdit.purposeid = [NSNumber numberWithInteger:row + 1];
    }
    // 车辆颜色
    else if (selectorView.tag == kCarBasicCarColorTag - kCarBasicItemStartTag) {
        tfItem.text = [_carColors objectAtIndex:row];
        
        // 更改色值
        NSArray *colors = [[[_carColorValues objectAtIndex:row] objectForKey:@"Value"] componentsSeparatedByString:@","];
        _vShowColor.backgroundColor = (row == _carColors.count - 1) ? kColorClear : [UIColor colorWithRed:[[colors objectAtIndex:0] floatValue]/255.0f green:[[colors objectAtIndex:1] floatValue]/255.0f blue:[[colors objectAtIndex:2] floatValue]/255.0f alpha:1];
        _vShowColor.minX = tfItem.text.length == 2 ? (self.width - 106) : (self.width - 120);
        
        // 是否为其他
        _vShowColor.image = (row == _carColors.count - 1) ? [UIImage imageNamed:@"color_other"] : nil;
        // 白色加边框
        _vShowColor.layer.borderWidth = row == 1 ? 0.5 : 0;
        
        // 保存数据到实体
        self.mCarInfoEdit.colorid = [NSNumber numberWithInteger:row + 1];
    }
    // 上牌日期
    else if (selectorView.tag == kCarLicenseItemOffsetTag + 0) {
        NSString *year = [[selectorView.dataSource objectAtIndex:0] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:0] row]];
        NSString *month = [[selectorView.dataSource objectAtIndex:1] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:1] row]];
        // 保存数据到实体
        self.mCarInfoEdit.firstregtime = [NSString stringWithFormat:@"%@-%@", year, month];
        // 显示选中的日期
        tfItem.text = [NSString stringWithFormat:@"%@-%@", year, month];
        
        // 车辆年审
        self.mCarInfoEdit.verifytime = [OMG dateCheckForTag:1 year:year.integerValue month:month.integerValue];
        UITextField *tfVerifytime = (UITextField *)[_svMain viewWithTag:kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 1];
        [tfVerifytime setText:[self carLicenseDateFormat:self.mCarInfoEdit.verifytime]];
        [(UILabel *)tfVerifytime.leftView setTextColor:kColorNewGray2];
        // 交强险
        self.mCarInfoEdit.insurancedate = [OMG dateCheckForTag:3 year:year.integerValue month:month.integerValue];
        UITextField *tfInsurancedate = (UITextField *)[_svMain viewWithTag:kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 2];
        [tfInsurancedate setText:[self carLicenseDateFormat:self.mCarInfoEdit.insurancedate]];
        [(UILabel *)tfInsurancedate.leftView setTextColor:kColorNewGray2];
        // 车船使用
        self.mCarInfoEdit.veticaltaxtime = [OMG dateCheckForTag:2 year:year.integerValue month:month.integerValue];
        UITextField *tfVeticaltaxtime = (UITextField *)[_svMain viewWithTag:kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 3];
        [tfVeticaltaxtime setText:[self carLicenseDateFormat:self.mCarInfoEdit.veticaltaxtime]];
        [(UILabel *)tfVeticaltaxtime.leftView setTextColor:kColorNewGray2];
        
        [UIView animateWithDuration:kAnimateSpeedFlash animations:^{
            // 显示隐藏的三项牌照信息
            tfVerifytime.alpha = 1;
            tfVeticaltaxtime.alpha = 1;
            tfInsurancedate.alpha = 1;
            
            CGFloat minY = tfVeticaltaxtime.maxY;
            if (!_isBusiness) {
                for (NSInteger i = 4; i < 7; i++) {
                    UITextField *tfItem = (UITextField *)[_svMain viewWithTag:kCarBasicItemStartTag + kCarLicenseItemOffsetTag + i];
                    if (tfItem) {
                        tfItem.minY = minY;
                        minY = tfItem.maxY;
                    }
                }
            }
            
            // 延长质保 & 检测报告
            if (_isBusiness) {
                UIView *vDrivingLicense = (UIView *)[self viewWithTag:kCarDrivingLicenseViewTag];
                UIView *vTextReport = (UIView *)[self viewWithTag:kCarTestReportViewTag];
                UIView *vEx = (UIView *)[self viewWithTag:kCarExtendedrepairViewTag];
                
                vDrivingLicense.minY = minY;
                if (_isShowTestReportView) {
                    vTextReport.minY = vDrivingLicense.maxY;
                    vEx.minY = vTextReport.maxY;
                } else {
                    vEx.minY = vDrivingLicense.maxY;
                }
                _vCarLicense.height = vEx.maxY;
            } else {
                _vCarLicense.height = minY;
            }
            
            _vLicenseBottomLine.minY = _vCarLicense.height - kLinePixel;
            _vCarPrice.minY = _vCarLicense.maxY + 21;
            _vCarConect.minY = _vCarPrice.maxY + 21;
            _svMain.contentSize = CGSizeMake(_svMain.width, _vCarConect.maxY + 20);
        }];
        
    }
    // 车辆年审日期
    else if (selectorView.tag == kCarLicenseItemOffsetTag + 1) {
        NSString *year = [[selectorView.dataSource objectAtIndex:0] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:0] row]];
        NSString *month = [[selectorView.dataSource objectAtIndex:1] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:1] row]];
        // 保存数据到实体
        self.mCarInfoEdit.verifytime = [NSString stringWithFormat:@"%@-%@", year, month];
        // 显示选中的日期
        tfItem.text = [NSString stringWithFormat:@"%@-%@", year, month];
    }
    // 交强险截止日期
    else if (selectorView.tag == kCarLicenseItemOffsetTag + 2) {
        NSString *year = [[selectorView.dataSource objectAtIndex:0] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:0] row]];
        NSString *month = [[selectorView.dataSource objectAtIndex:1] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:1] row]];
        // 保存数据到实体
        self.mCarInfoEdit.insurancedate = [NSString stringWithFormat:@"%@-%@", year, month];
        // 显示选中的日期
        tfItem.text = [NSString stringWithFormat:@"%@-%@", year, month];;
    }
    // 车船使用税有效期
    else if (selectorView.tag == kCarLicenseItemOffsetTag + 3) {
        NSString *year = [[selectorView.dataSource objectAtIndex:0] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:0] row]];
        // 保存数据到实体
        self.mCarInfoEdit.veticaltaxtime = year;
        // 显示选中的日期
        tfItem.text = [year isEqualToString:@"已过期"] ? year : [NSString stringWithFormat:@"%@", year];
    }
}

/** 牌照信息时间格式化 */
- (NSString *)carLicenseDateFormat:(NSString *)date
{
    if (date.length > 0) {
        NSArray *yearAndMonth = [date componentsSeparatedByString:@"-"];
        if (yearAndMonth.count == 2)
            return [NSString stringWithFormat:@"%@-%@", [yearAndMonth objectAtIndex:0], [yearAndMonth objectAtIndex:1]];
        else {
            return [date isEqualToString:@"已过期"] ? date : [NSString stringWithFormat:@"%@", date];
        }
    }
    return nil;
}

/** 加载参考价 */
- (void)loadReferencePrice:(UCReferencePriceModel *)mReferencePrice
{
    NSString *strHtml = @"<span style=\"font-size:10px;color:#909aab;font-family:Helvetica;\">发车参考价:%@<br>新车4S店最低价:%@</span>";
    NSString *strReferenceprice = @"<span style=\"color:#909aab;\">暂无数据</span>";
    NSString *strNewcarprice = @"<span style=\"color:#909aab;\">暂无数据</span>";
    if (mReferencePrice) {
        if (mReferencePrice.referenceprice.length > 0)
            strReferenceprice = [NSString stringWithFormat:@"<span style=\"color:#fa8c00;\">%@</span>万元", mReferencePrice.referenceprice];
        if (mReferencePrice.newcarprice.length > 0)
            strNewcarprice = [NSString stringWithFormat:@"<span style=\"color:#fa8c00;\">%@</span>万元", mReferencePrice.newcarprice];
    }
    
    [_wvReferencePrice loadHTMLString:[NSString stringWithFormat:strHtml, strReferenceprice, strNewcarprice] baseURL:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // 车辆信息
    if (textField.tag == kCarBasicCarInfoTag ) {
        [self switchChooseCarView];
        return NO;
    }
    // 过户费 一口价
    /* 屏蔽一口价
     else if (textField.tag == kCarBasicSwitchTransferfee || textField.tag == kCarBasicSwitchFixprice
     */
    else if (textField.tag == kCarBasicSwitchTransferfee) {
        return NO;
    }
    // 所在城市
    else if (textField.tag == kCarBasicLocationTag) {
        _vSelector.tag = kCarBasicLocationTag - kCarBasicItemStartTag;
        
        NSInteger row0 = 0;
        NSInteger row1 = 0;
        // 省市名称
        NSMutableArray *provinceNames = [NSMutableArray array];
        for (int i = 0; i < _provinces.count; i++) {
            AreaProvinceItem *apItem = [_provinces objectAtIndex:i];
            [provinceNames addObject:apItem.PN];
            // 已选择省
            if (self.mCarInfoEdit.provinceid.integerValue == apItem.PI.integerValue)
                row0 = i;
        }
        
        // 城市名称
        NSMutableArray *cityNames = [NSMutableArray array];
        NSArray *citys = [(AreaProvinceItem *)[_provinces objectAtIndex:row0] CL];
        
        for (int i = 0; i < citys.count; i++) {
            AreaCityItem *acItem = [citys objectAtIndex:i];
            [cityNames addObject:acItem.CN];
            // 已选择市
            if (self.mCarInfoEdit.cityid.integerValue == acItem.CI.integerValue)
                row1 = i;
        }
        
        _vSelector.dataSource = [NSMutableArray arrayWithObjects:provinceNames, cityNames, nil];
        [_vSelector selectRow:row0 inComponent:0 animated:NO];
        [_vSelector selectRow:row1 inComponent:1 animated:NO];
    }
    // 车辆颜色
    else if (textField.tag == kCarBasicCarColorTag) {
        _vSelector.tag = kCarBasicCarColorTag - kCarBasicItemStartTag;
        NSInteger row = self.mCarInfoEdit.colorid.integerValue > 0 ? self.mCarInfoEdit.colorid.integerValue - 1 : 0;
        _vSelector.dataSource = [NSMutableArray arrayWithObjects:_carColors, nil];
        [_vSelector selectRow:row inComponent:0 animated:NO];
    }
    // 车辆用途
    else if (textField.tag == kCarBasicCarPurposesTag) {
        _vSelector.tag = kCarBasicCarPurposesTag - kCarBasicItemStartTag;
        // 已选择用途
        NSInteger row = self.mCarInfoEdit.purposeid.integerValue > 0 ? self.mCarInfoEdit.purposeid.integerValue - 1 : 0;
        _vSelector.dataSource = [NSMutableArray arrayWithObjects:_carPurposes, nil];
        [_vSelector selectRow:row inComponent:0 animated:NO];
    }
    // 延长质保：月
    else if (textField.tag == kCarExtendedrepairViewTag + kCarChangeStartValueTag + 3) {
        if (textField.text.length == 0)
            textField.font = [UIFont systemFontOfSize:11];
        else
            textField.font = [UIFont systemFontOfSize:16];
        // 设置标题为正常颜色
        if (textField.text.length > 0)
            [(UILabel *)textField.leftView setTextColor:kColorNewGray2];
    }
    // 延长质保：公里
    else if (textField.tag == kCarExtendedrepairViewTag + kCarChangeStartValueTag + 4) {
        if (textField.text.length == 0) {
            _mCarInfoEdit.qualityassmile = [NSNumber numberWithFloat:0.3];
            textField.text = [_mCarInfoEdit.qualityassmile stringValue];
        }
        textField.font = [UIFont systemFontOfSize:textField.text.length == 0 ? 11 : 16];
        
        // 设置标题为正常颜色
        if (textField.text.length > 0)
            [(UILabel *)textField.leftView setTextColor:kColorNewGray2];
    }
    // 首次上牌日期
    else if (textField.tag == kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 0) {
        NSInteger row0 = 0;
        NSInteger row1 = 0;
        NSMutableArray *dateSource = [OMG buildDateSource:0 strDate:self.mCarInfoEdit.firstregtime row0:&row0 row1:&row1];
        
        _vSelector.tag = kCarLicenseItemOffsetTag + 0;
        _vSelector.dataSource = dateSource;
        [_vSelector selectRow:row0 inComponent:0 animated:NO];
        [_vSelector selectRow:row1 inComponent:1 animated:NO];
    }
    // 年检到期
    else if (textField.tag == kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 1) {
        NSInteger row0;
        NSInteger row1;
        NSMutableArray *dateSource = [OMG buildDateSource:2 strDate:self.mCarInfoEdit.verifytime row0:&row0 row1:&row1];
        
        _vSelector.tag = kCarLicenseItemOffsetTag + 1;
        _vSelector.dataSource = dateSource;
        [_vSelector selectRow:row0 inComponent:0 animated:NO];
        [_vSelector selectRow:row1 inComponent:1 animated:NO];
    }
    // 保险到期
    else if (textField.tag == kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 2) {
        NSInteger row0;
        NSInteger row1;
        NSMutableArray *dateSource = [OMG buildDateSource:1 strDate:self.mCarInfoEdit.insurancedate row0:&row0 row1:&row1];
        
        _vSelector.tag = kCarLicenseItemOffsetTag + 2;
        _vSelector.dataSource = dateSource;
        [_vSelector selectRow:row0 inComponent:0 animated:NO];
        [_vSelector selectRow:row1 inComponent:1 animated:NO];
    }
    // 车船税到期
    else if (textField.tag == kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 3) {
        NSInteger row0;
        NSMutableArray *dateSource = [OMG buildDateSource:-1 strDate:self.mCarInfoEdit.veticaltaxtime row0:&row0 row1:NULL];
        
        _vSelector.tag = kCarLicenseItemOffsetTag + 3;
        _vSelector.dataSource = dateSource;
        [_vSelector selectRow:row0 inComponent:0 animated:NO];
    }
    
    // 行驶证 登记证 购车发票
    else if (textField.tag > kCarBasicItemStartTag + kCarLicenseItemOffsetTag + 3) {
        return NO;
    }
    // 销售代表
    if (textField.tag == kCarContactFirstTag) {
        if (_isBusiness) {
            _vSelector.tag = kCarContactFirstTag - kCarBasicItemStartTag;
            
            NSArray *salesPersonList = [AMCacheManage currentUserInfo].salespersonlist;
            if (salesPersonList.count > 0) {
                NSInteger row = 0;
                NSMutableArray *salesPersonNameAndPhone = [NSMutableArray array];
                for (int i = 0; i < salesPersonList.count; i++) {
                    SalesPersonModel *mSalesPerson = [salesPersonList objectAtIndex:i];
                    [salesPersonNameAndPhone addObject:[NSString stringWithFormat:@"%@ %@", mSalesPerson.salesname, mSalesPerson.salesphone]];
                    // 已选择销售代表
                    if (self.mCarInfoEdit.salesPerson && self.mCarInfoEdit.salesPerson.salesid == mSalesPerson.salesid)
                        row = i;
                }
                _vSelector.dataSource = [NSMutableArray arrayWithObjects:salesPersonNameAndPhone, nil];
                [_vSelector selectRow:row inComponent:0 animated:NO];
            } else {
                _vSelector.dataSource = [NSMutableArray arrayWithObjects:[NSArray array], nil];
                // 无销售代表数据
                [[AMToastView toastView] showMessage:@"暂无销售代表" icon:kImageRequestError duration:AMToastDurationNormal];
                return NO;
            }
        }
        // 联系人
        else {
            
        }
    }
    // 联系电话
    else if (textField.tag == kCarContactSecondTag) {
        // 商家卖车禁止填联系方式
        if (_isBusiness)
            return NO;
    }
    [self adjustFirstResponder:textField];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger length = textField.tag == kCarExtendedrepairViewTag + kCarChangeStartValueTag + 4 ? 1 : 2;
    NSRange rDot = [textField.text rangeOfString:@"."];
    if (rDot.location != NSNotFound && [string isEqualToString:@"."])
        return NO;
    
    if (range.location > rDot.location && string.length > 0 && textField.text.length - rDot.location > length)
        return NO;
    
    if (textField.tag == kCarBasicDepositTag || textField.tag == kCarContactFirstTag || textField.tag == kCarContactSecondTag || textField.tag == kCarBasicBookingPriceTag || textField.tag == kCarBasicDriveMileageTag || textField.tag == kCarExtendedrepairViewTag + kCarChangeStartValueTag + 3 || textField.tag == kCarExtendedrepairViewTag + kCarChangeStartValueTag + 4) {
        // 屏蔽以 “.” 和 "0" 开头
        if (([textField.text isEqualToString:@""] && [string isEqualToString:@"."])
            || ([textField.text isEqualToString:@"0"] && ![string isEqualToString:@"."] && string.length > 0))
            return NO;
        //
        NSMutableString *str = [NSMutableString stringWithString:textField.text];
        if (string.length > 0)
            [str insertString:string atIndex:range.location];
        else
            [str deleteCharactersInRange:range];
        
        // VIN码
        if (textField.tag == kCarBasicDepositTag) {
            // 限制17位
            // 限制字数
            NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
            if (str.length > 17)
                return NO;

            // 数字和字母
            NSCharacterSet *capitalNum = [[NSCharacterSet characterSetWithCharactersInString:CAPITAL] invertedSet];
            NSString *strCapitalNum = [[string componentsSeparatedByCharactersInSet:capitalNum] componentsJoinedByString:@""];
            if (![string isEqualToString:strCapitalNum])
                return NO;
            
            _mCarInfoEdit.vincode = [str uppercaseString];
        }
        // 卖家姓名
        else if (textField.tag == kCarContactFirstTag) {
            if (!_isBusiness) {
                // 限制字数
                NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
                if (str.length > 20) {
                    textField.text = [str substringToIndex:20];
                    // 卖家姓名 数据保存到实体
                    self.mCarInfoEdit.salesPerson.salesname = textField.text;
                    return NO;
                }
            }
        }
        // 联系电话
        else if (textField.tag == kCarContactSecondTag) {
            if (!_isBusiness) {
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
                self.mCarInfoEdit.salesPerson.salesphone = str.length > 0 ? str : nil;
            }
        }
        // 预售价格
        else if (textField.tag == kCarBasicBookingPriceTag) {
            // 禁止空格
            unichar uc = [string characterAtIndex: [string length]-1];
            //禁止输入空格 ASCII ==32
            if (uc == 32)
                return NO;
            
            // 限制字数
            NSInteger surplus = 7 - textField.text.length;
            if (string.length > surplus)
                return NO;
            
            if (str.doubleValue >= 10000)
                return NO;
            
            // 预售价格 数据保存到实体
            self.mCarInfoEdit.bookprice = str.length > 0 ? [NSDecimalNumber decimalNumberWithString:str] : nil;
        }
        // 行驶里程
        else if (textField.tag == kCarBasicDriveMileageTag) {
            // 禁止空格
            unichar uc = [string characterAtIndex: [string length]-1];
            //禁止输入空格 ASCII ==32
            if (uc == 32)
                return NO;
            
            // 限制字数
            NSInteger surplus = 5 - textField.text.length;
            if (string.length > surplus)
                return NO;
            
            if (str.doubleValue >= 100)
                return NO;
            
            // 行驶里程 数据保存到实体
            self.mCarInfoEdit.drivemileage = str.length > 0 ? [NSDecimalNumber decimalNumberWithString:str] : nil;
        }
        // 延长质保：月
        else if (textField.tag == kCarExtendedrepairViewTag + kCarChangeStartValueTag + 3) {
            if (string.length > 0) {
                // 屏蔽0开头
                NSString *result = [NSString stringWithFormat:@"%@%@",textField.text, string];
                if ([result integerValue] > 24 || [result isEqualToString:@"0"])
                    return NO;
            }
            // 控制文字大小
            textField.font = [UIFont systemFontOfSize:textField.text.length <= 1 && string.length == 0 ? 11 : 16];
            
            _mCarInfoEdit.qualityassdate = [NSNumber numberWithInteger:[str integerValue]];
        }
        // 延长质保：公里
        else if (textField.tag == kCarExtendedrepairViewTag + kCarChangeStartValueTag + 4) {
            if (string.length > 0) {
                NSString *result = [NSString stringWithFormat:@"%@%@",textField.text, string];
                if ([result floatValue] > 9.9 || [result isEqualToString:@"0.0"])
                    return NO;
            }
            // 控制文字大小
            textField.font = [UIFont systemFontOfSize:textField.text.length <= 1 && string.length == 0 ? 11 : 16];
            
            _mCarInfoEdit.qualityassmile = [NSNumber numberWithFloat:[str floatValue]];
        }
        // 设置标题为正常颜色
        UILabel *labLeft;
        if (textField.tag == kCarBasicDepositTag) {
            UIView *vLeft = (UIView *)textField.leftView;
            labLeft = (UILabel *)[vLeft.subviews objectAtIndex:0];
        }
        if (textField.tag != kCarBasicDepositTag) {
            labLeft = (UILabel *)textField.leftView;
        }
        
        [labLeft setTextColor:kColorNewGray2];
        
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // 延长质保时间
    if (textField.tag == kCarExtendedrepairViewTag + kCarChangeStartValueTag + 3) {
        if (textField.text.length == 0) {
            textField.font = [UIFont systemFontOfSize:11];
        }
    }
    
    // 去除延长质保公里值为 0
    else if (textField.tag == kCarExtendedrepairViewTag + kCarChangeStartValueTag + 4) {
        if ([textField.text floatValue] == 0) {
            textField.text = @"";
            _mCarInfoEdit.qualityassmile = nil;
        }
        if (textField.text.length == 0) {
            textField.font = [UIFont systemFontOfSize:11];
        }
    }
    
}

/* textFieldDidEndEditing 中文上屏监听不响应, 使用通知监听 */
- (void)textFieldTextDidChange:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UITextField class]]) {
        UITextField *textField = notification.object;
        // 卖家姓名
        if (textField.tag == kCarContactFirstTag && !_isBusiness) {
            // 卖家姓名 数据保存到实体
            self.mCarInfoEdit.salesPerson.salesname = textField.text;
        }
        // VIN码转大写
        else if (textField.tag == kCarBasicDepositTag) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:textField];
            if (textField.text.length > 17)
                textField.text = _mCarInfoEdit.vincode = [[textField.text uppercaseString] substringToIndex:17];
            else
                textField.text = _mCarInfoEdit.vincode = [textField.text uppercaseString];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
        }
    }
}

#pragma mark - NSKeyValueObserving
/** 观察者 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self getReferencePrice];
//    NSLog(@"%@",_mPrice);
//    NSLog(@"%@", _mCarInfoEdit);
}

#pragma mark - APIHelper
/** 参考价 */
- (void)getReferencePrice:(UCPriceModel *)mPrice
{
    if (!_apiHelperPrice)
        _apiHelperPrice = [[APIHelper alloc] init];
    else
        [_apiHelperPrice cancel];
    
    __weak UCSaleCarView *vSaleCar = self;
    
    [_apiHelperPrice setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            [vSaleCar loadReferencePrice:nil];
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0 && mBase.result)
                    [vSaleCar loadReferencePrice:[[UCReferencePriceModel alloc] initWithJson:mBase.result]];
                else
                    [vSaleCar loadReferencePrice:nil];
            }
        }
    }];
    
    [self.apiHelperPrice getCarSalePriceWithPriceModel:mPrice];
}

- (void)releaseCar
{
    if (!_apiReleaseCar)
        _apiReleaseCar = [[APIHelper alloc] init];
    
    [self endEditing:YES];
    
    // 状态提示框
    [[AMToastView toastView:YES] showLoading:@"正在发布…" cancel:^{
        [_apiReleaseCar cancel];
    }];
    
    __weak UCSaleCarView *vSaleCar = self;
    // 设置请求完成后回调方法
    [_apiReleaseCar setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            [[AMToastView toastView] hide];
            // 发新车 才有对话框
            if (vSaleCar.mCarInfoEdit.carid.doubleValue < 0) {
                UIAlertView *vAlert = [[UIAlertView alloc] initWithTitle:nil message:@"可能是网络或服务器原因导致发车不成功，请随时关注你的车辆信息" delegate:vSaleCar cancelButtonTitle:@"保存到未填完" otherButtonTitles:@"继续发布", nil];
                vAlert.tag = kAlertReleaseFailTag;
                [vAlert show];
            }
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                // 登录成功
                if (mBase.returncode == 0) {
                    [[AMToastView toastView] hide];
                    // 删除未填完缓存
                    NSMutableArray *mCarInfoEditDrafts = [NSMutableArray arrayWithArray:[AMCacheManage currentCarInfoEditDrafts]];
                    
                    NSInteger index = NSNotFound;
                    for (int i = 0; i < mCarInfoEditDrafts.count; i++) {
                        UCCarInfoEditModel *mCarInfoEditDraft = [mCarInfoEditDrafts objectAtIndex:i];
                        // 找到对应的下标
                        if (mCarInfoEditDraft.carid.doubleValue == vSaleCar.mCarInfoEdit.carid.doubleValue) {
                            index = i;
                            break;
                        }
                    }
                    if (index != NSNotFound) {
                        // 移除对应的未填完车辆信息
                        [mCarInfoEditDrafts removeObjectAtIndex:index];
                        // 写入缓存
                        if (mCarInfoEditDrafts.count > 0)
                            [AMCacheManage setCurrentCarInfoEditDrafts:mCarInfoEditDrafts];
                        else
                            [AMCacheManage setCurrentCarInfoEditDrafts:nil];
                    }
                    
                    // 返回的车辆信息
                    UCCarInfoEditModel *mCarInfoEdit = [[UCCarInfoEditModel alloc] initWithJson:mBase.result];
                    // 通知
                    if ([vSaleCar.delegate respondsToSelector:@selector(releaseCarFinish:)])
                        [vSaleCar.delegate releaseCarFinish:mCarInfoEdit];
                    
                    // 发布完成的车辆信息, 以便浏览使用
                    UCReleaseSucceedView *vReleaseSucceed = [[UCReleaseSucceedView alloc] initWithFrame:vSaleCar.bounds isBusiness:vSaleCar.isBusiness mCarInfoEdit:mCarInfoEdit fromView:vSaleCar.isEditMode ? FromViewTypeEditCar : FromViewTypeSaleCar];
                    vReleaseSucceed.delegate = vSaleCar.delegate;
                    [[MainViewController sharedVCMain] openView:vReleaseSucceed animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionPrevious];
                } else {
                    // 身份失效
                    if (mBase.returncode == 2049005) {
                        [[AMToastView toastView] hide];
                        
                        if ([AMCacheManage currentUserType] == UserStyleBusiness) {
                            UCLoginDealerView *vLoginDealer = [[UCLoginDealerView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds];
                            [[MainViewController sharedVCMain] openView:vLoginDealer animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
                        }
                        else{
                            UCLoginClientView *vLoginClient = [[UCLoginClientView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds loginType:UCLoginClientTypeNormal];
                            [[MainViewController sharedVCMain] openView:vLoginClient animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
                        }
                        [AMCacheManage setCurrentUserInfo:nil];
                        
                    }
                    // 最多发三辆
                    else if (mBase.returncode == 2049041) {
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                    }
                    // 发车失败保存
                    else if (vSaleCar.mCarInfoEdit.carid.doubleValue < 0) {
                        UIAlertView *vAlert = [[UIAlertView alloc] initWithTitle:nil message:mBase.message delegate:vSaleCar cancelButtonTitle:@"保存到未填完" otherButtonTitles:@"继续发布", nil];
                        vAlert.tag = kAlertReleaseFailTag;
                        [vAlert show];
                        
                        [[AMToastView toastView] hide];
                    }
                    else if (mBase.message.length > 0)
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                    else
                        [[AMToastView toastView] hide];
                }

            }
        }
    }];
    
    // 发车
    if (self.mCarInfoEdit.carid.doubleValue < 0) {
        [_apiReleaseCar releaseCarWithCarInfoEditModel:_mCarInfoEdit];
    }
    // 修改车
    else {
        [_apiReleaseCar editCarWithCarInfoEditModel:_mCarInfoEdit];
    }
}

- (void)dealloc
{
    AMLog(@"dealloc...");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setKVOPrice:NO keys:_keys];
    [_apiHelperPrice cancel];
}

@end
