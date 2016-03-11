//
//  UCBusinessInfoView.m
//  UsedCar
//
//  Created by 张鑫 on 13-12-2.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCBusinessInfoView.h"
#import "UCTopBar.h"
#import "AMCacheManage.h"
#import "UIImage+Util.h"
#import "APIHelper.h"
#import "UCBusinessInfoModel.h"
#import <CoreLocation/CoreLocation.h>

#define marginLeft                  16
#define kButtonNavigationTag        48573434

@interface UCBusinessInfoView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UILabel *labName;
@property (nonatomic, strong) UCCarListView *vCarList;
@property (nonatomic, strong) APIHelper *apiHelper;
@property (nonatomic, strong) UCBusinessInfoModel *mBusinessInfo;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D lc2DStart;
@property (nonatomic) CLLocationCoordinate2D lc2DEnd;
@property (nonatomic) BOOL isPositioning;
@property (nonatomic, strong) NSTimer *positionTimer;
@property (nonatomic, strong) NSNumber *userid;
@property (nonatomic, strong) UIButton *btnNavigation;

@end

@implementation UCBusinessInfoView

- (id)initWithFrame:(CGRect)frame userid:(NSNumber *)userid
{
    self = [super initWithFrame:frame];
    if (self) {
        _userid = userid;
        // 标题
        [self initTitleView];
        // 获取数据
        [self getBusinessInfo:userid];
    }
    return self;
}

#pragma mark - initView
/** 初始化导航栏 */
- (void)initTitleView
{
    self.backgroundColor = kColorWhite;
    
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    
    // 标题
    [_tbTop setLetfTitle:@"返回"];
    [self.tbTop.btnTitle setTitle:@"商铺信息" forState:UIControlStateNormal];
    
    [self.tbTop.btnLeft addTarget:self action:@selector(onClickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    
}

/** 初始化导航栏 */
- (void)initView
{
    // 商家信息view
    UIView *vBusinessInfo = [[UIView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, 145)];
    vBusinessInfo.backgroundColor = kColorGrey5;
    [self addSubview:vBusinessInfo];
    
    // 商家名
    _labName = [[UILabel alloc] initWithFrame:CGRectMake(marginLeft, 14, vBusinessInfo.width - marginLeft * 2 - 40, 16)];
    _labName.text = _mBusinessInfo.username;
    _labName.font = [UIFont systemFontOfSize:16];
    _labName.textColor = kColorGrey3;
    _labName.backgroundColor = [UIColor clearColor];
    [vBusinessInfo addSubview:_labName];
    
    NSArray *titles = @[@"所在城市：", @"经营性质：", @"联系电话：", @"地理位置："];
    NSArray *contents = @[_mBusinessInfo.pname,_mBusinessInfo.managetype,_mBusinessInfo.phone,_mBusinessInfo.address];
    CGFloat minY  = _labName.maxY + 8;
    
    for (int i = 0; i < [titles count]; i++) {
        // 所在城市
        UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(marginLeft, minY, 60, 13)] ;
        labTitle.text = [titles objectAtIndex:i];
        labTitle.textColor = kColorGrey3;
        labTitle.font = [UIFont systemFontOfSize:12];
        labTitle.backgroundColor = [UIColor clearColor];
        [vBusinessInfo addSubview:labTitle];
        
        UILabel *labContent = [[UILabel alloc] initWithFrame:CGRectMake(labTitle.maxX, minY, 190, 24)];
        labContent.text = [contents objectAtIndex:i];
        labContent.textColor = kColorGrey3;
        labContent.font = [UIFont systemFontOfSize:12];
        labContent.backgroundColor = [UIColor clearColor];
        if (i == 3){
            labContent.numberOfLines = 0;
            CGSize size = [labContent.text sizeWithFont:labContent.font constrainedToSize:CGSizeMake(190, 1000) lineBreakMode:labContent.lineBreakMode];
            labContent.size = size;
            vBusinessInfo.height = labContent.maxY + 44;
        } else {
            [labContent sizeToFit];
        }
        [vBusinessInfo addSubview:labContent];
        
        minY += 13 + 3;
    }
    
    // 分割线
    UIView *vLine1 = [[UIView alloc] initLineWithFrame:CGRectMake(vBusinessInfo.width - 51, 0, kLinePixel, vBusinessInfo.height) color:kColorNewLine];
    [vBusinessInfo addSubview:vLine1];
    
    // 电话按钮
    UIImage *iPhone = [UIImage imageNamed:@"merchant message_phone_btn"];
    UIButton *btnPhone = [[UIButton alloc] initWithFrame:CGRectMake(vBusinessInfo.width - 50, 0, 50, (vBusinessInfo.height - 30) / 2)];
    [btnPhone addTarget:self action:@selector(onClickPhoneBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btnPhone setImage:iPhone forState:UIControlStateNormal];
    [btnPhone setTitle:@"电话" forState:UIControlStateNormal];
    [btnPhone setTitleColor:kColorBlue3 forState:UIControlStateNormal];
    btnPhone.titleLabel.font = [UIFont systemFontOfSize:12];
    [btnPhone setTitleEdgeInsets:UIEdgeInsetsMake(30, -iPhone.size.width, 0, 0)];
    [btnPhone setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnPhone.size] forState:UIControlStateHighlighted];
    [btnPhone setImageEdgeInsets:UIEdgeInsetsMake(-20, 0, 0, -[btnPhone.titleLabel.text sizeWithFont:btnPhone.titleLabel.font].width)];
    [vBusinessInfo addSubview:btnPhone];
    
    // 分割线
    UIView *vLine2 = [[UIView alloc] initLineWithFrame:CGRectMake(vLine1.maxX, (vBusinessInfo.height - 30) / 2, 50, kLinePixel) color:kColorNewLine];
    [vBusinessInfo addSubview:vLine2];
    
    // 导航按钮
    UIImage *iNavigation = [UIImage imageNamed:@"merchant message_locationl_btn"];
    _btnNavigation = [[UIButton alloc] initWithFrame:CGRectMake(vBusinessInfo.width - 50, btnPhone.height, 50, (vBusinessInfo.height - 30) / 2)];
    [_btnNavigation addTarget:self action:@selector(onClickNavigateBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_btnNavigation setImage:iNavigation forState:UIControlStateNormal];
    [_btnNavigation setImage:[UIImage imageNamed:@"merchant-message_locationl_btn_d"] forState:UIControlStateDisabled];
    [_btnNavigation setTitle:@"导航" forState:UIControlStateNormal];
    [_btnNavigation setTitleColor:kColorBlue1 forState:UIControlStateNormal];
    [_btnNavigation setTitleColor:kColorGrey4 forState:UIControlStateDisabled];
    _btnNavigation.titleLabel.font = [UIFont systemFontOfSize:12];
    [_btnNavigation setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnPhone.size] forState:UIControlStateHighlighted];
    _btnNavigation.tag = kButtonNavigationTag;
    double doubleLatitude = [_mBusinessInfo.latitude doubleValue];
    double doubleLongtitude = [_mBusinessInfo.longtitude doubleValue];
    _btnNavigation.enabled = doubleLongtitude > 0 && doubleLatitude > 0;
    [_btnNavigation setTitleEdgeInsets:UIEdgeInsetsMake(30, -iNavigation.size.width, 0, 0)];
    [_btnNavigation setImageEdgeInsets:UIEdgeInsetsMake(-20, 0, 0, -[_btnNavigation.titleLabel.text sizeWithFont:_btnNavigation.titleLabel.font].width)];
    [vBusinessInfo addSubview:_btnNavigation];
    
    CGFloat minYSaleTitle = vBusinessInfo.height - 30;
    if (_mBusinessInfo.money.length > 0) {
        UIView *vBail = [self creatBailView:CGRectMake(0, minYSaleTitle, vBusinessInfo.width, 37)];
        [vBusinessInfo addSubview:vBail];
        minYSaleTitle += vBail.height;
        vBusinessInfo.height += 37;
    }
    
    // 在售二手车
    UILabel *labSaleTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, minYSaleTitle, vBusinessInfo.width, 30)];
    labSaleTitle.backgroundColor = kColorWhite;
    labSaleTitle.text = @"   在售二手车";
    labSaleTitle.textColor = kColorBlue1;
    labSaleTitle.font = [UIFont systemFontOfSize:16];
    [vBusinessInfo addSubview:labSaleTitle];
    
    // 分割线
    UIView *vLine3 = [[UIView alloc] initLineWithFrame:CGRectMake(0, labSaleTitle.minY, vBusinessInfo.width, kLinePixel) color:kColorNewLine];
    [vBusinessInfo addSubview:vLine3];
    
    // 分割线
    UIView *vLine4 = [[UIView alloc] initLineWithFrame:CGRectMake(0, vBusinessInfo.height - kLinePixel, vBusinessInfo.width, kLinePixel) color:kColorNewLine];
    [vBusinessInfo addSubview:vLine4];
    
    // 列表
    _vCarList = [[UCCarListView alloc] initWithFrame:CGRectMake(0, 64 + vBusinessInfo.height, self.width, self.height - 64 - vBusinessInfo.height)];
    _vCarList.delegate = self;
    _vCarList.dealerid = _userid;
    UCFilterModel *mFilter = [[UCFilterModel alloc] init];
    _vCarList.mFilter = mFilter;
    // 刷新
    [_vCarList refreshCarList];
    
    [self insertSubview:_vCarList belowSubview:vBusinessInfo];
}

/** 创建保证金视图 */
-(UIView *)creatBailView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorGrey5;
    
    UIImage *image = [UIImage imageNamed:@"businessInfo_bail"];
    UIImageView *ivBail = [[UIImageView alloc] initWithImage:image];
    
    // 保证金
    UILabel *labText = [[UILabel alloc] init];
    labText.backgroundColor = kColorClear;
    NSString *strMoney = _mBusinessInfo.money.integerValue > 10000 ? [NSString stringWithFormat:@"%d万", _mBusinessInfo.money.integerValue / 10000] : _mBusinessInfo.money;
    labText.text = [NSString stringWithFormat:@"诚信商家，已缴纳%@保证金", strMoney];
    labText.textColor = kColorNewOrange;
    labText.font = kFontNormal;
    [labText sizeToFit];
    labText.origin = CGPointMake((vBody.width - labText.width) / 2 + (image.width + 3) / 2, (vBody.height - labText.height) / 2);
    
    ivBail.origin = CGPointMake(labText.minX - image.width - 3, (frame.size.height - image.height) / 2);
    
    [vBody addSubview:ivBail];
    [vBody addSubview:labText];
    [vBody addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, vBody.width, kLinePixel) color:kColorGrey4]];
    
    return vBody;
}

#pragma mark - private Method
/** 暂无数据 */
- (void)showNoData
{
    // 无数据提示
    UILabel *labNoData = [[UILabel alloc] initWithClearFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.height)];
    labNoData.text = @"暂无数据";
    labNoData.textAlignment = NSTextAlignmentCenter;
    labNoData.font = [UIFont systemFontOfSize:16];
    labNoData.textColor = kColorGrey2;
    [self addSubview:labNoData];
}

/** 导航 */
- (BOOL)navigateWithStyle:(NavigateStyle)navigateStyle endName:(NSString *)endName startLocationCoordinate2D:(CLLocationCoordinate2D)lc2DStart endLocationCoordinate2D:(CLLocationCoordinate2D)lc2DEnd
{
    BOOL isSucceed = NO;
    
    // 高德导航
    if (navigateStyle == NavigateStyleGaode) {
        NSString *GDStr = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=二手车&backScheme=usedcar&lat=%f&lon=%f&dev=0&style=0", lc2DEnd.latitude, lc2DEnd.longitude];
        GDStr = [GDStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        NSURL *GDUrl = [NSURL URLWithString: GDStr];
        if ([[UIApplication sharedApplication] canOpenURL: GDUrl]) {
            isSucceed = YES;
            [[UIApplication sharedApplication] openURL: GDUrl];
        }
    }
    
    // 百度导航
    else if (navigateStyle == NavigateStyleBaidu) {
        NSString *BDStr = [NSString stringWithFormat: @"baidumap://map/direction?origin=%f,%f&destination=%f,%f&mode=driving&coord_type=wgs84&src=usedcar", lc2DStart.latitude, lc2DStart.longitude, lc2DEnd.latitude,lc2DEnd.longitude];
        
        BDStr = [BDStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        NSURL *BDUrl = [NSURL URLWithString: BDStr];
        if ([[UIApplication sharedApplication] canOpenURL: BDUrl]) {
            isSucceed = YES;
            [[UIApplication sharedApplication] openURL: BDUrl];
        }
    }
    
    else if (navigateStyle == NavigateStyleDefault) {
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        // ios6以下调用google map
        if (version < 6.0) {
            NSString *string = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f", lc2DStart.latitude, lc2DStart.longitude, lc2DEnd.latitude, lc2DEnd.longitude];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
        }
        else{
            // ios6自己带的apple map
            CLLocationCoordinate2D to = CLLocationCoordinate2DMake(lc2DEnd.latitude, lc2DEnd.longitude);
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil] ];
            toLocation.name = endName;
            
            [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                           launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                                     forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
        }
    }
    
    return isSucceed;
}

- (void)closePositionTimer
{
    [self closePositionTimer:YES];
}

- (void)closePositionTimer:(BOOL)isShow
{
    _isPositioning = NO;
    [_positionTimer invalidate];
    [_locationManager stopUpdatingLocation];
    if (isShow)
        [[AMToastView toastView] showMessage:@"获取位置失败，无法导航" icon:kImageRequestError duration:AMToastDurationNormal];
    else
        [[AMToastView toastView] hide];
}

#pragma mark - onClickButton
/** 点击返回 */
- (void)onClickBackBtn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/** 电话 */
- (void)onClickPhoneBtn:(UIButton *)btn
{
    [UMStatistics event:c_3_1_buinesscall];
    
    BOOL success = [OMG callPhone:_mBusinessInfo.phone];
    if (success) {
        // 记录事件
        APIHelper *apiHelperEvent = [[APIHelper alloc] init];
        [apiHelperEvent callstatisticsEventWithCarID:nil type:[NSNumber numberWithInt:30] dealerid:_userid];
    }
}

/** 导航 */
- (void)onClickNavigateBtn:(UIButton *)btn
{
    [UMStatistics event:c_3_1_buinessnavigation];
    
    if (![APIHelper isNetworkAvailable]){
        [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
        return;
    }
    
    if ([_mBusinessInfo.latitude doubleValue] == 0 || [_mBusinessInfo.longtitude doubleValue] == 0)
    {
        [[AMToastView toastView] showMessage:@"获取位置失败，无法导航" icon:kImageRequestError duration:AMToastDurationNormal];
        [_positionTimer invalidate];
        return;
    }
    
    // 提示语
    [[AMToastView toastView] showLoading:@"正在定位中" cancel:nil];
    
    // 高德导航
    BOOL isCanOpenUrl = [self navigateWithStyle:NavigateStyleGaode endName:nil startLocationCoordinate2D:_lc2DStart endLocationCoordinate2D:_lc2DEnd];
    
    if (isCanOpenUrl)
        [[AMToastView toastView] hide];
    
    // 获取本地位置 进百度导航
    else {
        _isPositioning = YES;
        // 开启定时器
        _positionTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(closePositionTimer) userInfo:nil repeats:NO];
        
        // 获取经纬度
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
    }
}

#pragma mark - UCCarListViewDelegate
/** 统计事件 */
- (void)carListViewLoadData:(UCCarListView *)vCarList
{
    // 添加统计
    [UMStatistics event:pv_3_1_buinessdetailbrowse];
    UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
    NSMutableDictionary *dic = [AMCacheManage currentUserType] == UserStyleBusiness ? [NSMutableDictionary dictionaryWithObjectsAndKeys:_userid.stringValue, @"dealerid#5", mUserInfo.userid, @"userid#4", nil] : [NSMutableDictionary dictionaryWithObjectsAndKeys:_userid.stringValue, @"dealerid#5", nil];
    [UMSAgent postEvent:browsedealerdetail_pv page_name:NSStringFromClass(self.class) eventargvs:dic];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (_isPositioning) {
        [self closePositionTimer:NO];
        
        _lc2DStart = newLocation.coordinate;
        if(_lc2DStart.latitude == 0 || _lc2DStart.longitude == 0){
            [[AMToastView toastView] showMessage:@"获取位置失败，无法导航" icon:kImageRequestError duration:AMToastDurationNormal];
            return;
        }
        
        // 百度导航
        BOOL isCanOpenUrl = [self navigateWithStyle:NavigateStyleBaidu endName:nil startLocationCoordinate2D:_lc2DStart endLocationCoordinate2D:_lc2DEnd];
        
        if (!isCanOpenUrl)
            [self navigateWithStyle:NavigateStyleDefault endName:_mBusinessInfo.pname startLocationCoordinate2D:_lc2DStart endLocationCoordinate2D:_lc2DEnd];
    }
}

/** 定位失败 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (_isPositioning) {
        [self closePositionTimer:YES];
    }
}

#pragma mark - apiHelper
/** 获取数据 */
- (void)getBusinessInfo:(NSNumber *)userid
{
    if (!self.apiHelper)
        self.apiHelper = [[APIHelper alloc] init];
    __weak UCBusinessInfoView *vBusinessInfo = self;
    [self.apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            [vBusinessInfo showNoData];
            return;
        }
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                NSString *message = nil;
                if (mBase.returncode == 0) {
                    // 总车数
                    NSDictionary *dicBusinessInfo = mBase.result;
                    
                    if (!vBusinessInfo.mBusinessInfo)
                        vBusinessInfo.mBusinessInfo = [[UCBusinessInfoModel alloc] initWithJson:dicBusinessInfo];
                    // 经纬度
                    double doubleLatitude = [vBusinessInfo.mBusinessInfo.latitude doubleValue];
                    double doubleLongtitude = [vBusinessInfo.mBusinessInfo.longtitude doubleValue];
                    vBusinessInfo.lc2DEnd = CLLocationCoordinate2DMake(doubleLatitude,doubleLongtitude);
                    // 获取基本信息再加载列表
                    [vBusinessInfo initView];
                }
                else {
                    [vBusinessInfo showNoData];
                    message = mBase.message;
                    if (message) {
                        [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                    }
                    else{
                        [[AMToastView toastView] hide];
                    }
                }
//                if(message)
//                    [[AMToastView toastView] showMessage:mBase.message icon:nil duration:AMToastDurationNormal];
            }
        }
    }];
    [_apiHelper getBusinessInfo:userid];
}

- (void)dealloc
{
    AMLog(@"dealloc...");
    [_apiHelper cancel];
    if (_isPositioning)
        [self closePositionTimer:NO];
}

@end
