//
//  UCLocationView.m
//  UsedCar
//
//  Created by 张鑫 on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCLocationView.h"
#import "DatabaseHelper1.h"
#import "MainViewController.h"
#import "AMToastView.h"
#import "AMCacheManage.h"
#import "MultiCell.h"
#import "UCMainView.h"
#import "UCHomeView.h"
#import "AreaProvinceItem.h"
#import "UIImage+Util.h"
#import "APIHelper.h"
#import "UCHotAreaModel.h"

#define kProvincesSectionIndexs @"kProvincesSectionIndexs"
#define kLocationViewHeight     85

@interface UCLocationView ()

@property (nonatomic, strong) MultiTablesView *mtvCity;
@property (nonatomic, strong) UILabel *labTittle;
@property (nonatomic, strong) NSMutableDictionary *dicProvinces;
@property (nonatomic, strong) NSMutableArray *arrCitys;     // 第二级数据源
@property (nonatomic, strong) NSMutableArray *arrThirdDatas;// 第三级数据源
//@property (nonatomic, strong) UCAreaMode *mArea;            // 选择的省市
@property (nonatomic, strong) UCAreaMode *mAreaLocation;    // 定位的省市
@property (nonatomic, strong) UCAreaMode *mTempArea;        // 临时修改的model
@property (nonatomic, strong) UCAreaMode *mOriginalArea;    // 原始的地点model
@property (nonatomic, strong) NSMutableArray *selectedIndexPaths;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) UIButton *btnRelocation;
@property (nonatomic, strong) UILabel *labLocation;
@property (nonatomic, strong) UIView *vSelected;
@property (nonatomic, strong) CLLocationManager* locationmanager;
@property (nonatomic) UCLocationViewFrom viewFrom;

@end

@implementation UCLocationView
/** 首页选择城市 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _viewFrom = UCLocationViewFromFilterView;
        // 默认设置为全国(空对象)
        self.mTempArea = [[UCAreaMode alloc] init];
        if (![AMCacheManage currentArea])
            [AMCacheManage setCurrentArea:self.mTempArea];
        [self initData];
    }
    return self;
}

/** 关注选车城市 */
- (id)initWithFrame:(CGRect)frame areaModel:(UCAreaMode *)mArea
{
    self = [super initWithFrame:frame];
    if (self) {
        _viewFrom = UCLocationViewFromAttentionView;
        _mOriginalArea = mArea;
        _mTempArea = [mArea copy];
        [self initData];
    }
    return self;
}

- (void)initData
{
    self.dicProvinces = [[NSMutableDictionary alloc] init];
    self.arrCitys = [[NSMutableArray alloc] init];
    _arrThirdDatas = [NSMutableArray array];
    self.mAreaLocation = [[UCAreaMode alloc] init];
    self.selectedIndexPaths = [[NSMutableArray alloc] init];
    
    [self initView];
}

#pragma mark - InitView
/** 初始化视图 */
-(void)initView
{
    self.backgroundColor = kColorNewBackground;
    self.clipsToBounds = YES;
    
    // 创建定位视图
    [self initLocationView];
    // 创建选择栏
    [self initSelectCity];
    // 开启定位
    [self startLocation];
}

- (void)initLocationView
{
    // 定位视图
    UIView *vLocation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, kLocationViewHeight)];
    vLocation.backgroundColor = kColorNewBackground;
    
    // 当前位置
    UIView *vNowLocation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, vLocation.width, 35)];
    vNowLocation.backgroundColor = kColorNewBackground;
    vNowLocation.userInteractionEnabled = NO;
    
    UILabel *labNowLocation = [[UILabel alloc] initWithFrame:CGRectMake(21, 0, NSNotFound, NSNotFound)];
    labNowLocation.backgroundColor = [UIColor clearColor];
    labNowLocation.font = kFontSmall;
    labNowLocation.textColor = kColorNewGray2;
    labNowLocation.text = @"当前位置";
    labNowLocation.userInteractionEnabled = NO;
    [labNowLocation sizeToFit];
    labNowLocation.origin = CGPointMake(21, 15);
    
    // 当前城市
    UIView *vNowCity = [[UIView alloc] initWithFrame:CGRectMake(0, vNowLocation.maxY, vLocation.width, vLocation.height - vNowLocation.height)];
    vNowCity.backgroundColor = kColorWhite;
    UIImage *iLocation = [UIImage imageNamed:@"merchant message_locationl_btn"];
    UIImageView *ivLocation = [[UIImageView alloc] initWithFrame:CGRectMake(20, (vNowCity.height - iLocation.size.height * 0.7) / 2, iLocation.size.width * 0.7, iLocation.size.height * 0.7)];
    ivLocation.image = iLocation;
    vNowCity.userInteractionEnabled = NO;
    
    // 当前位置
    _labLocation = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, vNowCity.width - 50, vNowCity.height)];
    _labLocation.backgroundColor = kColorWhite;
    _labLocation.font = kFontLarge;
    _labLocation.text = @"正在定位...";
    _labLocation.textColor = kColorNewGray1;
    _labLocation.userInteractionEnabled = NO;
    
    // 重新定位
    UIButton *btnReLocation = [[UIButton alloc] initWithFrame:vLocation.bounds];
    btnReLocation.backgroundColor = [UIColor clearColor];
    [btnReLocation setBackgroundImage:[UIImage imageWithColor:kColorWhite size:btnReLocation.size] forState:UIControlStateHighlighted];
    [btnReLocation addTarget:self action:@selector(onClickLocationBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    // 选中标记
    _vSelected = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, vNowCity.height)];
    _vSelected.backgroundColor = kColorNewOrange;
    _vSelected.hidden = YES;
    
   // 加上分割线
    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, vLocation.maxY - kLinePixel, self.width, kLinePixel) color:kColorNewLine];
    
    [vNowLocation addSubview:labNowLocation];
    [vNowCity addSubview:_labLocation];
    [vNowCity addSubview:ivLocation];
    [vNowCity addSubview:_vSelected];
    [vLocation addSubview:btnReLocation];
    [vLocation addSubview:vNowLocation];
    [vLocation addSubview:vNowCity];
    [vLocation addSubview:vLine];
    [self addSubview:vLocation];
    
}

/** 创建选择城市View */
-(void)initSelectCity
{
    [self initAllProvince];
    
    // 城市多级列表
    _mtvCity = [[MultiTablesView alloc] initWithFrame:CGRectMake(0, kLocationViewHeight, self.width, self.height - kLocationViewHeight)];
    _mtvCity.delegate = self;
    _mtvCity.dataSource = self;
    _mtvCity.marginLeft = 45;
    _mtvCity.backgroundColor = kColorNewBackground;
    
    [self addSubview:_mtvCity];
    
    // 添加自定义索引栏
    MJNIndexView *ivIndexBar = [[MJNIndexView alloc] initWithFrame:_mtvCity.bounds];
    ivIndexBar.fontColor = kColorNewGray2;
    ivIndexBar.dataSource = self;
    UITableView *tableView = [_mtvCity tableViewAtIndex:0];
    [_mtvCity insertSubview:ivIndexBar aboveSubview:tableView];
}

#pragma mark - Method
/** 是否开启网络和开启定位权限 */
- (NSString *)isCanNotLocationingMessage
{
    NSString *message = nil;
    // 检测网络
    if ([APIHelper currentNetworkStatus] == NotReachable)
        message = @"定位失败，请检查网络";
    // 检测定位是否开启
    else if (![CLLocationManager locationServicesEnabled])
        message = @"打开“定位服务”来允许\n“二手车”确定您的位置";
    
    return message;
}

/** 开始定位 */
- (void)startLocation
{
    // 是否可以定位
    NSString *message = [self isCanNotLocationingMessage];
    
    // 不可定位
    if (message.length > 0) {
        _labLocation.text = @"定位失败，点击重试";
        [_mAreaLocation setNull];
        [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
        return;
    }
    
    [_locationmanager stopUpdatingLocation];
    _labLocation.text = @"正在定位...";
    
    if (!_locationmanager)
        _locationmanager = [[CLLocationManager alloc] init];
    if (IOS8_OR_LATER)
        [_locationmanager requestWhenInUseAuthorization];
    [_locationmanager setDesiredAccuracy:kCLLocationAccuracyBest];
    _locationmanager.delegate = self;
    [_locationmanager startUpdatingLocation];
}

/** 关闭定位 */
- (void)stopLocation
{
    [_locationmanager stopUpdatingLocation];
}

/** 初始化所有省 */
- (void)initAllProvince
{
    // 热门一级数据
    NSArray *mHotAreas = [OMG hotArea];
    
    // 热门地区
    NSMutableArray *hotArea = [NSMutableArray array];
    for (int i = 0 ; i < mHotAreas.count; i++) {
        // 热门地区
        UCHotAreaModel *mHotArea = [mHotAreas objectAtIndex:i];
        [hotArea addObject:[[AreaProvinceItem alloc] initWithHotAreaModel:mHotArea]];
    }

    [self.dicProvinces removeAllObjects];
    // 添加热门地区
    [self.dicProvinces setObject:hotArea forKey:@"热"];
    // 添加全国
    [self.dicProvinces setObject:[NSArray arrayWithObject:[[AreaProvinceItem alloc] initWithPN:@"全国" PI:nil]] forKey:@"*"];

    NSMutableArray *orderArray = [NSMutableArray arrayWithObjects:@"热", @"*", nil];
    NSArray *areaProvinces = [OMG areaProvinces];
    // 省份以首字母分组
    for (AreaProvinceItem *apItem in areaProvinces) {
        NSString *firstLetter = apItem.FL;
        NSMutableArray *array = [self.dicProvinces objectForKey:firstLetter];
        if (!array) {
            array = [NSMutableArray array];
            [self.dicProvinces setObject:array forKey:firstLetter];
            [orderArray addObject:firstLetter];
        }
        [array addObject:apItem];
    }
    
    [self.dicProvinces setObject:orderArray forKey:kProvincesSectionIndexs];
}

/** 二级列表 */
- (void)cityWhitPI:(NSNumber *)PI
{
    // 清空数据
    [_arrCitys removeAllObjects];
    
    /** 热门城市二级 */
    if ([PI integerValue] == 100000 || [PI integerValue] == 200000 || [PI integerValue] == 300000 || [PI integerValue] == 400000) {
        // 当前热门地区model
        UCHotAreaModel *mNowHotArea;
        for (UCHotAreaModel *mHotAreaTemp in [OMG hotArea]) {
            if ([PI integerValue] == [mHotAreaTemp.Id integerValue]) {
                mNowHotArea = mHotAreaTemp;
                break;
            }
        }
        
        /** 广州深圳特殊处理，为直辖市 */
        // 市
        if ([PI integerValue] == 300000) {
            // 添加不限
            [_arrCitys addObject:[[AreaCityItem alloc] initWithCN:@"不限" CI:nil]];
            for (int i = 0; i < mNowHotArea.AreaId.count; i++) {
                UCAreaMode *mAreaMode = [OMG areaModelWithCid:[mNowHotArea.AreaId objectAtIndex:i]];
                AreaCityItem *areaCity = [[AreaCityItem alloc] initWithCN:mAreaMode.cName CI:[NSNumber numberWithInteger:[mAreaMode.cid integerValue]]];
                [self.arrCitys addObject:areaCity];
            }
        }
        // 省
        else {
            // 添加不限
            [_arrCitys addObject:[[AreaProvinceItem alloc] initWithPN:@"不限" PI:nil]];
            
            for (int i = 0; i < mNowHotArea.AreaId.count; i++) {
                AreaProvinceItem *apItem = [OMG areaProvince:[[mNowHotArea.AreaId objectAtIndex:i]integerValue]];
                [self.arrCitys addObject:apItem];
            }
        }
        return;
    }
    
    /** 城市二级 */
    [self.arrCitys removeAllObjects];
    [self.arrCitys addObject:[[AreaCityItem alloc] initWithCN:@"不限" CI:nil]];
    if (PI) {
        AreaProvinceItem *apItem = [OMG areaProvince:PI.integerValue];
        [self.arrCitys addObjectsFromArray:apItem.CL];
    }
}

/** 三级数据 */
- (void)initThirdLevelDatasWithRow:(NSUInteger)row{
    // 热门地区
    [_arrThirdDatas removeAllObjects];
    // 二级model
    AreaProvinceItem *apSecondItem = [_arrCitys objectAtIndex:row];
    [_arrThirdDatas addObject:[[AreaCityItem alloc] initWithCN:@"不限" CI:nil]];
    if (apSecondItem.PI) {
        [_arrThirdDatas addObjectsFromArray:apSecondItem.CL];
    }
}

/** 设置选中状态 */
- (void)setSelectedCells:(UCAreaMode *)mSelectedArea
{
    // 选中全国
    if ([mSelectedArea isNull]) {
        [[_mtvCity tableViewAtIndex:0] selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        return;
    }
    
    // 省索引集合
    NSArray *arrProvincesSection = [_dicProvinces objectForKey:kProvincesSectionIndexs];
    
    NSInteger selectedFirstID = NSNotFound;
    NSInteger selectedSecondID = NSNotFound;
    NSInteger selectedThirdID = NSNotFound;
    // 是否是热门地区
    BOOL isHotAre = mSelectedArea.areaid.integerValue > 0 ? YES : NO;
    BOOL isCityOfSecondLevel; // 二级是否是市
    
    /** 第一级索引 */
    
    // 循环一级，得到一级的IndexPath
    // 是否终止
    BOOL isBreakTemp1 = NO;
    for (int i = 0; i < arrProvincesSection.count; i++) {
        NSArray *arrProvincesDatas = [_dicProvinces objectForKey:[arrProvincesSection objectAtIndex:i]];
        for (int j = 0; j < arrProvincesDatas.count; j++) {
            AreaProvinceItem *mProvince = [arrProvincesDatas objectAtIndex:j];
            if (mProvince.PI.integerValue > 0 && mProvince.PI.integerValue == (isHotAre ? mSelectedArea.areaid.integerValue : mSelectedArea.pid.integerValue)) {
                // 记录一级ID
                selectedFirstID = [mProvince.PI integerValue];
                // 记录一级索引
                [_selectedIndexPaths addObject:[NSIndexPath indexPathForRow:j inSection:i]];
                
                // 热门地区
                if (isHotAre) {
                    // 设置一级model
                    _mTempArea.areaid = [mProvince.PI stringValue];
                    _mTempArea.areaName = mProvince.PN;
                    /** 设置二级数据源 */
                    // 添加不限
                    if (mProvince.PI.integerValue == 300000)
                        [_arrCitys addObject:[[AreaCityItem alloc] initWithCN:@"不限" CI:nil]];
                    else
                        [_arrCitys addObject:[[AreaProvinceItem alloc] initWithPN:@"不限" PI:nil]];
                    
                    for (NSString *strID in mProvince.CL) {
                        // 广深
                        if (mProvince.PI.integerValue == 300000) {
                            UCAreaMode *mAreaMode = [OMG areaModelWithCid:strID];
                            AreaCityItem *areaCity = [[AreaCityItem alloc] initWithCN:mAreaMode.cName CI:[NSNumber numberWithInteger:[mAreaMode.cid integerValue]]];
                            [_arrCitys addObject:areaCity];
                        }
                        // 省
                        else {
                            AreaProvinceItem *areaProvince = [OMG areaProvince:[strID integerValue]];
                            [_arrCitys addObject:areaProvince];
                        }
                    }
                }
                // 非热门地区
                else {
                    // 设置一级model
                    _mTempArea.pid = [mProvince.PI stringValue];
                    _mTempArea.pName = mProvince.PN;
                    /** 设置二级数据源 */
                    // 添加不限
                    [_arrCitys addObject:[[AreaCityItem alloc] initWithCN:@"不限" CI:nil]];
                    [_arrCitys addObjectsFromArray:mProvince.CL];
                }
                isBreakTemp1 = YES;
                break;
            }
        }
        if (isBreakTemp1)
            break;
    };
    
    /** 第二级索引 */
    // 二级是否是市
    isCityOfSecondLevel = (isHotAre && selectedFirstID != 300000) ? NO : YES;
    // 是否终止
    BOOL isBreakTemp2 = NO;
    
    for (int i = 0; i < _arrCitys.count; i++) {
        /** 二级是 市 */
        if (isCityOfSecondLevel) {
            for (int j = 0; j < _arrCitys.count; j++) {
                AreaCityItem *mSecondItem = [_arrCitys objectAtIndex:j];
                if (mSecondItem.CI.integerValue > 0 && mSecondItem.CI.integerValue == mSelectedArea.cid.integerValue) {
                    // 记录二级ID
                    selectedSecondID = mSecondItem.CI.integerValue;
                    // 记录二级索引
                    [_selectedIndexPaths addObject:[NSIndexPath indexPathForRow:j inSection:0]];
                    // 设置二级选中model
                    _mTempArea.cid = [mSecondItem.CI stringValue];
                    _mTempArea.cName = mSecondItem.CN;
                    isBreakTemp2 = YES;
                    break;
                }
            }
        }
        /** 二级是 省 */
        else {
            for (int j = 0; j < _arrCitys.count; j++) {
                AreaProvinceItem *mSecondItem = [_arrCitys objectAtIndex:j];
                if (mSecondItem.PI.integerValue > 0 && mSecondItem.PI.integerValue == mSelectedArea.pid.integerValue) {
                    // 记录二级ID
                    selectedSecondID = mSecondItem.PI.integerValue;
                    // 记录二级索引
                    [_selectedIndexPaths addObject:[NSIndexPath indexPathForRow:j inSection:0]];
                    // 设置二级选中model
                    _mTempArea.pid = [mSecondItem.PI stringValue];
                    _mTempArea.pName = mSecondItem.PN;
                    // 设置三级数据源
                    [_arrThirdDatas addObject:[[AreaCityItem alloc] initWithCN:@"不限" CI:nil]];
                    [_arrThirdDatas addObjectsFromArray:mSecondItem.CL];
                    isBreakTemp2 = YES;
                    break;
                }
            }
        }
        if (isBreakTemp2)
            break;
    }
    
    /** 第三级索引 */
    if (!isCityOfSecondLevel) {
        for (int j = 0; j < _arrThirdDatas.count; j++) {
            AreaCityItem *mThirdItem = [_arrThirdDatas objectAtIndex:j];
            if (mThirdItem.CI.integerValue > 0 && mThirdItem.CI.integerValue == mSelectedArea.cid.integerValue) {
                // 记录三级ID
                selectedThirdID = mThirdItem.CI.integerValue;
                // 记录三级索引
                [_selectedIndexPaths addObject:[NSIndexPath indexPathForRow:j inSection:0]];
                // 设置三级选中model
                _mTempArea.cid = [mThirdItem.CI stringValue];
                _mTempArea.cName = mThirdItem.CN;
                break;
            }
        }
    }
    
    /** 展开列表 */
    /** 第一级 */
    UITableView *tvFirst = [_mtvCity tableViewAtIndex:0];
    if (_selectedIndexPaths.count > 0) {
        // 第一级列表
        // 选中cell
        [tvFirst selectRowAtIndexPath:[_selectedIndexPaths objectAtIndex:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
    
    /** 第二级 */
    // 第二级列表
    UITableView *tvSecond = [_mtvCity tableViewAtIndex:1];
    // 推出第二级别
    [_mtvCity pushNextTableView:[_mtvCity tableViewAtIndex:0] animation:NO];
    if (_selectedIndexPaths.count > 1) {
        // 选中cell
        [tvSecond selectRowAtIndexPath:[_selectedIndexPaths objectAtIndex:1] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    } else {
        [tvSecond selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        return;
    }
    
    /** 第三级 */
    if (isHotAre) {
        // 第三级列表
        NSIndexPath *index = _selectedIndexPaths.count > 2 ? [_selectedIndexPaths objectAtIndex:2] : [NSIndexPath indexPathForRow:0 inSection:0];
        if (mSelectedArea.areaid.length > 0 && mSelectedArea.pid.length > 0)
        /** 因控件动画时间问题，此处设置时间延迟，防止推不出三级列表bug */
            [self performSelector:@selector(pushThirdTableView:) withObject:index afterDelay:0];
    }
    
}

/** 推出第三级列表 */
- (void)pushThirdTableView:(NSIndexPath *)indexPath
{
    [_mtvCity pushNextTableView:[_mtvCity tableViewAtIndex:1] animation:NO];
    // 第三级列表
    UITableView *tvThird = [_mtvCity tableViewAtIndex:2];
    // 选中cell
    [tvThird selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - onClickBtn
/** 重新定位 */
- (void)onClickLocationBtn:(UIButton *)btn
{
    if ([_labLocation.text isEqualToString:@"定位失败，点击重试"] || [_labLocation.text isEqualToString:@"正在定位..."] || _labLocation.text.length == 0) {
        [self startLocation];
    } else {
        if (_viewFrom == UCLocationViewFromAttentionView) {
            if ([_delegate respondsToSelector:@selector(UCLocationView:isChanged:areaModel:)]) {
                [_delegate UCLocationView:self isChanged:![_mOriginalArea isEqualToArea:_mAreaLocation] areaModel:_mAreaLocation];
            }
        } else {
            [AMCacheManage setCurrentArea:_mAreaLocation];
            [self.vFilter closeFilter:YES];
        }
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // 测试定位
//    newLocation = [[CLLocation alloc] initWithLatitude:30.62 longitude:116.53];
    if (signbit(newLocation.horizontalAccuracy)) {
        _labLocation.text = @"定位失败，点击重试";
        [_mAreaLocation setNull];
    }
    else {
        // 地理位置
        if (!_geocoder) {
            _geocoder = [[CLGeocoder alloc] init];
        }
        [_geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error) {
            if (array.count > 0) {
                CLPlacemark *placemark = [array objectAtIndex:0];
                NSString *theCity = placemark.locality;
                
                if (theCity == NULL)
                    theCity = placemark.administrativeArea;
                if (theCity != nil && theCity.length > 0)
                    theCity = [theCity substringToIndex:theCity.length - 1];
                if (theCity == NULL)
                    return;
                
                // 获得定位信息
                UCAreaMode *mArea = [OMG areaCityWithCityName:theCity];
                [_mAreaLocation setEqualToArea:mArea];
                if (mArea.pName.length > 0) {
                    // 设置定位信息
                    if ([_mAreaLocation.cid isEqualToString:@"110100"] || [_mAreaLocation.cid isEqualToString:@"310100"] || [_mAreaLocation.cid isEqualToString:@"500100"] || [_mAreaLocation.cid isEqualToString:@"120100"]) {
                        _labLocation.text = _mAreaLocation.pName;
                    } else {
                        _labLocation.text = [NSString stringWithFormat:@"%@ %@", _mAreaLocation.pName, _mAreaLocation.cName];
                    }
                } else {
                    _labLocation.text = @"全国";
                }
                
                
                // 设置是否选中当前定位栏
                BOOL isEqual = NO;
                UCAreaMode *mLocalArea = _viewFrom == UCLocationViewFromAttentionView ? _mOriginalArea : [AMCacheManage currentArea];
                if ([mLocalArea isEqualToArea:_mAreaLocation]) {
                    isEqual = YES;
                }
                _labLocation.textColor = isEqual ? kColorNewOrange : [UIColor blackColor];
                _vSelected.hidden = isEqual ? NO : YES;
                
            } else {
                _labLocation.text = @"定位失败，点击重试";
                [_mAreaLocation setNull];
            }
        }];
    }
    
    [_locationmanager stopUpdatingLocation];
}

/** 定位失败 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // 未打开定位权限
    if ([error code] == kCLErrorDenied)
        [[AMToastView toastView] showMessage:@"打开“定位服务”来允许\n“二手车”确定您的位置" icon:kImageRequestError duration:AMToastDurationNormal];
    
    _labLocation.text = @"定位失败，点击重试";
    [_mAreaLocation setNull];
    [_locationmanager stopUpdatingLocation];
}

#pragma mark - MJNIndexViewDataSource
- (NSArray *)sectionIndexTitlesForMJNIndexView:(MJNIndexView *)indexView
{
    return (NSArray *)[self.dicProvinces objectForKey:kProvincesSectionIndexs];
}

- (void)sectionForSectionMJNIndexTitle:(NSString *)title atIndex:(NSInteger)index;
{
    UITableView *tableView = [_mtvCity tableViewAtIndex:0];
    if ([tableView numberOfSections] > index && index > -1)
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition: UITableViewScrollPositionTop animated:YES];
}

#pragma mark - MultiTablesViewDataSource
/** 页数 */
- (NSInteger)numberOfLevelsInMultiTablesView:(MultiTablesView *)multiTablesView
{
	return 3;
}

/** 控制sections个数 */
- (NSInteger)multiTablesView:(MultiTablesView *)multiTablesView numberOfSectionsAtLevel:(NSInteger)level
{
    NSInteger number = 0;
    if (level == 0)
        number = [[self.dicProvinces objectForKey:kProvincesSectionIndexs] count];
    else
        number = 1;
	return number;
}

/** 每栏的row个数 */
- (NSInteger)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 0;
    if (level == 0)
        number = [[self.dicProvinces objectForKey:[[self.dicProvinces objectForKey:kProvincesSectionIndexs] objectAtIndex:section]] count];
    else if (level == 1)
        number = self.arrCitys.count;
    else
        number = _arrThirdDatas.count;
	return number;
}

/** cell内容 */
- (UITableViewCell *)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    MultiCell *cell = (MultiCell *)[multiTablesView dequeueReusableCellForLevel:level withIdentifier:CellIdentifier];
    
    if (!cell) {
		cell = [[MultiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier level:(NSInteger)level marginLeftOfLine:20.0f cellWidth:multiTablesView.width];
        cell.tag = indexPath.row;
	}
    
    if (level == 0) {
        NSArray *apItems = [_dicProvinces objectForKey:[[_dicProvinces objectForKey:kProvincesSectionIndexs] objectAtIndex:indexPath.section]];
        AreaProvinceItem *apItem = [apItems objectAtIndex:indexPath.row];
        cell.labText.text = apItem.PN;
        cell.vLine.hidden = apItems.count == indexPath.row + 1; // 隐藏每个section最后一根分割线
    } else if (level == 1) {
        // 判断是否是热门城市
        NSIndexPath *firstSelectedIndexPath = [multiTablesView indexPathForSelectedRowAtLevel:0];
        NSArray *apItems = [_dicProvinces objectForKey:[[_dicProvinces objectForKey:kProvincesSectionIndexs] objectAtIndex:firstSelectedIndexPath.section]];
        // 第一级model
        AreaProvinceItem *apItem = [apItems objectAtIndex:firstSelectedIndexPath.row];
        BOOL isHotArea = NO;
        NSArray *hotAreas = [OMG hotArea];
        for (UCHotAreaModel *mHotArea in hotAreas) {
            if ([mHotArea.Id integerValue] == [apItem.PI integerValue]) {
                isHotArea = YES;
                break;
            }
        }
        
        // 热门城市
        if (isHotArea) {
            // 广深特殊处理 为直辖市
            if ([apItem.PI integerValue] == 300000) {
                AreaCityItem *acItem = [_arrCitys objectAtIndex:indexPath.row];
                cell.labText.text = acItem.CN;
            }
            else {
                AreaProvinceItem *apItem = [_arrCitys objectAtIndex:indexPath.row];
                cell.labText.text = apItem.PN;
            }
        }
        else {
            // 城市二级
            AreaCityItem *acItem = [_arrCitys objectAtIndex:indexPath.row];
            cell.labText.text = acItem.CN;
        }
    }
    // 三级
    else if (level == 2) {
        // 城市二级
        AreaCityItem *acItem = [_arrThirdDatas objectAtIndex:indexPath.row];
        cell.labText.text = acItem.CN;

    }

    return cell;
}

- (CGFloat)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level heightForRowAtIndexPath:(NSInteger)indexPath
{
    return 51.0f;
}

#pragma mark - MultiTablesViewDelegate
- (void)multiTablesView:(MultiTablesView *)multiTablesView levelDidChange:(NSInteger)level
{
	if (multiTablesView.currentTableViewIndex == level)
		[multiTablesView.currentTableView deselectRowAtIndexPath:[multiTablesView.currentTableView indexPathForSelectedRow] animated:YES];
}

/** 选择cell */
- (void)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 第一级
    if (level == 0) {
        if (indexPath.section == 1 && indexPath.row == 0) {
            // 选择了全国
            [_mTempArea setNull];
            if (_viewFrom == UCLocationViewFromFilterView) {
                [AMCacheManage setCurrentArea:[[UCAreaMode alloc] init]];
                [self.vFilter closeFilter:YES];
            } else {
                if ([_delegate respondsToSelector:@selector(UCLocationView:isChanged:areaModel:)]) {
                    [_delegate UCLocationView:self isChanged:![_mOriginalArea isEqualToArea:_mTempArea] areaModel:_mTempArea];
                }
            }
            multiTablesView.automaticPush = NO;
        } else {
            NSArray *apItmes = [self.dicProvinces objectForKey:[[self.dicProvinces objectForKey:kProvincesSectionIndexs] objectAtIndex:indexPath.section]];
            AreaProvinceItem *apItem = [apItmes objectAtIndex:indexPath.row];
            
            NSArray *hotAreas = [OMG hotArea];
            BOOL isHotArea = NO;
            for (UCHotAreaModel *mHotAreaTemp in hotAreas) {
                if ([mHotAreaTemp.Id integerValue] == [apItem.PI integerValue]) {
                    isHotArea = YES;
                    break;
                }
            }
            
            // 热门地区
            if (isHotArea) {
                [_mTempArea setNull];
                _mTempArea.areaid = apItem.PI.stringValue;
                _mTempArea.areaName = apItem.PN;
            }
            // 省
            else {
                [_mTempArea setNull];
                _mTempArea.pid = apItem.PI.stringValue;
                _mTempArea.pName = apItem.PN;
            }
            
            // 获取城市列表
            [self cityWhitPI:apItem.PI];
            
        }
    }
    // 第二级
    if (level == 1) {
        // 是否热门地区
        BOOL isHotArea = NO;
        NSArray *hotAreas = [OMG hotArea];
        NSIndexPath *ipFirst = [multiTablesView indexPathForSelectedRowAtLevel:0];
        NSArray *apItmes = [self.dicProvinces objectForKey:[[self.dicProvinces objectForKey:kProvincesSectionIndexs] objectAtIndex:ipFirst.section]];
        AreaProvinceItem *apItem = [apItmes objectAtIndex:ipFirst.row];
        for (UCHotAreaModel *mHotArea in hotAreas) {
            if ([mHotArea.Id integerValue] == [apItem.PI integerValue]) {
                isHotArea = YES;
                break;
            }
        }
        
        /** 热门地区 */
        if (isHotArea) {
            // 二级不限
            if (indexPath.row == 0) {
                // 设置地区信息
                [_mTempArea setNull];
                _mTempArea.areaid = [apItem.PI stringValue];
                _mTempArea.areaName = apItem.PN;
                
                if (_viewFrom == UCLocationViewFromFilterView) {
                    [AMCacheManage setCurrentArea:_mTempArea];
                    [self.vFilter closeFilter:YES];
                } else {
                    if ([_delegate respondsToSelector:@selector(UCLocationView:isChanged:areaModel:)]) {
                        [_delegate UCLocationView:self isChanged:![_mTempArea isEqualToArea:_mOriginalArea] areaModel:_mTempArea];
                    }
                }
            }
            // 二级非不限
            else {
                // 特殊处理 广深为市
                if ([apItem.PI integerValue] == 300000) {
                    // 设置市信息
                    [_mTempArea setNull];
                    _mTempArea.areaid = [apItem.PI stringValue];
                    _mTempArea.areaName = apItem.PN;
                    
                    [self multiTablesView:multiTablesView lastLevel:level didSelectRowAtIndexPath:indexPath];
                }
                // 省
                else {
                    // 设置省信息
                    [_mTempArea setNull];
                    AreaProvinceItem *secondAreaItem = [_arrCitys objectAtIndex:indexPath.row];
                    _mTempArea.areaid = [apItem.PI stringValue];
                    _mTempArea.areaName = apItem.PN;
                    _mTempArea.pid = [secondAreaItem.PI stringValue];
                    _mTempArea.pName = secondAreaItem.PN;
                    [self initThirdLevelDatasWithRow:indexPath.row];
                }
            }
        }
        /** 城市 */
        else {
            [self multiTablesView:multiTablesView lastLevel:level didSelectRowAtIndexPath:indexPath];
        }
    }
}

/** 选择完毕 */
- (void)multiTablesView:(MultiTablesView *)multiTablesView lastLevel:(NSInteger)lastLevel didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 记录二级或热门三级市
    AreaCityItem *acItem = lastLevel == 1 ? [self.arrCitys objectAtIndex:indexPath.row] : [self.arrThirdDatas objectAtIndex:indexPath.row];
    
    if (acItem.CI) {
        _mTempArea.cid = acItem.CI.stringValue;
        _mTempArea.cName = acItem.CN;
    } else {
        _mTempArea.cid = nil;
        _mTempArea.cName = nil;
    }
    
    if (_viewFrom == UCLocationViewFromFilterView) {
        [AMCacheManage setCurrentArea:_mTempArea];
        [self.vFilter closeFilter:YES];
    } else {
        if ([_delegate respondsToSelector:@selector(UCLocationView:isChanged:areaModel:)]) {
            [_delegate UCLocationView:self isChanged:![_mOriginalArea isEqualToArea:_mTempArea] areaModel:_mTempArea];
        }
    }
    
}

#pragma mark - Sections Headers & Footers
/** 设置sections 的 footers 高度 */
- (CGFloat)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level heightForFooterInSection:(NSInteger)section
{
	return 0.0;
}

/** 设置sections 的 Headers 高度 */
- (CGFloat)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level heightForHeaderInSection:(NSInteger)section
{
    return level > 0 ? 0 : (section == 0 ? 35 : 20);
}

- (UITableViewCellSeparatorStyle)multiTablesView:(MultiTablesView *)multiTablesView separatorStyleForLevel:(NSInteger)level
{
    return UITableViewCellSeparatorStyleNone;
}

- (UIView *)multiTablesView:(MultiTablesView *)multiTablesView sliderLevel:(NSInteger)sliderLevel viewForHeaderInSection:(NSInteger)section
{
    UIView *vHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, multiTablesView.frame.size.width,  section == 0 ? 35 : 20)];
    // 背景
    UIView *vHeaderBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, vHeader.frame.size.width, vHeader.height)];
    vHeaderBG.backgroundColor = kColorNewBackground;
    [vHeader addSubview:vHeaderBG];
    
    // 标题
    CGFloat marginLeftText = sliderLevel == 0 ? 21 : 7.0f;
    
    UILabel *labTittle = [[UILabel alloc] initWithFrame:CGRectMake(marginLeftText, 0, NSNotFound, NSNotFound)];
    labTittle.font = kFontSmall;
    labTittle.backgroundColor = [UIColor clearColor];
    labTittle.textColor = section == 0 ? kColorNewGray1 : kColorNewGray2;

    NSString *strSection = [NSString stringWithFormat:@"%@",[[self.dicProvinces objectForKey:kProvincesSectionIndexs] objectAtIndex:section]];
    if (sliderLevel == 0) {
        if (section == 0) {
            strSection = @"热门地区";
        }
        if (section == 1) {
            strSection = @"*";
        }
    }
    labTittle.text = strSection;
    [labTittle sizeToFit];
    labTittle.origin = CGPointMake(marginLeftText, (sliderLevel == 0 && section == 0) ? 15 : ((vHeader.height - labTittle.height) / 2));
    
    [vHeaderBG addSubview:labTittle];
    
    return vHeader;
}

-(void)dealloc
{
    AMLog(@"释放：%@", NSStringFromClass([self class]));
}

@end
