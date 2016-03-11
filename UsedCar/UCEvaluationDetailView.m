//
//  UCEvaluationDetailView.m
//  UsedCar
//
//  Created by 张鑫 on 14-1-1.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCEvaluationDetailView.h"
#import "APIHelper.h"
#import "UCTopBar.h"
#import "UIImageView+WebCache.h"
#import "UCEvaluationModel.h"
#import "UIImage+Util.h"
#import "UCEvaluationPriceModel.h"
#import "UCBusinessInfoView.h"
#import "UserInfoModel.h"
#import "AMCacheManage.h"
#import "UCSaleCarView.h"
#import "UCCarInfoEditModel.h"
#import "UCEvaluationSimilarView.h"

#define kNameLabelStartTag              10000
#define kSaledNumLabelStartTag          20000
#define kSaledUnitLabelStartTag         30000
#define kSalingNumLabelStartTag         40000
#define kSalingUnitLabelStartTag        50000

#define kBtnBusinessItemTag             64573657
#define kBtnSharesTag                   1001

@interface UCEvaluationDetailView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) APIHelper *apiHelperBusinessCity;
@property (nonatomic, strong) APIHelper *apiHelperBusinessProvince;
@property (nonatomic, strong) APIHelper *apiHelperBusinessCountry;
@property (nonatomic, strong) UIScrollView *svMain;
@property (nonatomic, strong) UIView *vCarInfo;
@property (nonatomic, strong) UIView *vPrice;
@property (nonatomic, strong) UIView *vBusinessInfo;
@property (nonatomic, strong) UIImageView *ivCar;
@property (nonatomic, strong) UIWebView *wvSalePerson;
@property (nonatomic, strong) NSMutableArray *businesses;
@property (nonatomic, strong) UCEvaluationModel *mEvaluationBusinessInfo;  //获取推荐商家所用的model
@property (nonatomic) UCEvaluationDetailViewType viewType;
@property (nonatomic, strong) UCCarInfoEditModel *mCarInfoEdit;
@property (nonatomic, strong) UIButton *btnMoreCar;

@end

@implementation UCEvaluationDetailView

- (id)initWithFrame:(CGRect)frame evaluationModel:(UCEvaluationModel *)mEvaluation carInfoEditModel:(UCCarInfoEditModel *)mCarInfoEdit viewType:(UCEvaluationDetailViewType)viewType
{
    self = [super initWithFrame:frame];
    if (self) {
        _viewType = viewType;
        _mCarInfoEdit = mCarInfoEdit;
        [UMStatistics event:viewType == UCEvaluationDetailViewTypeBuyCar ? pv_4_1_tool_evaluation_buycar_result : pv_4_1_tool_evaluation_sellcar_result];
        UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
        NSNumber *userid = nil;
        NSNumber *dealerid = nil;
        switch ([AMCacheManage currentUserType]) {
            case UserStyleBusiness:
                dealerid = mUserInfo.userid;
                break;
            case UserStylePersonal:
                userid = mUserInfo.userid;;
                break;
                
            default:
                break;
        }
        [UMSAgent postEvent:viewType == UCEvaluationDetailViewTypeBuyCar ? tool_evaluation_buycar_result_pv : tool_evaluation_sellcar_result_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:mEvaluation.seriesid.stringValue, @"seriesid#2", mEvaluation.specid.stringValue, @"specid#3", userid, @"userid#4", dealerid, @"dealerid#5", nil]];
        
        self.apiHelperBusinessCity = [[APIHelper alloc] init];
        self.mEvaluationBusinessInfo = [[UCEvaluationModel alloc] init];
        _mEvaluationBusinessInfo.pid = mEvaluation.pid;
        _mEvaluationBusinessInfo.cid = mEvaluation.cid;
        _businesses = [NSMutableArray array];
        [self initView:mEvaluation];
    }
    return self;
}

#pragma mark - initView
- (void)initView:(UCEvaluationModel *)mEvaluation
{
    self.backgroundColor = kColorNewBackground;
    
    // 导航头
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    // 主视图
    _svMain = [[UIScrollView alloc] initWithClearFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY)];
    _svMain.hidden = NO;
    
    // 车辆信息视图
    _vCarInfo = [self creatCarInfoView:CGRectMake(0, 0, _svMain.width, 98) :mEvaluation];
    
    // 价格视图
    _vPrice = [[UIView alloc] initWithFrame:CGRectMake(0, _vCarInfo.maxY + 20 , self.width, 46)];
    _vPrice.backgroundColor = kColorWhite;
    _vPrice.hidden = YES;
    
    // 车主卖价
    _wvSalePerson = [[UIWebView alloc] initWithClearFrame:CGRectMake(7, 5, _vPrice.width, 30)];
    _wvSalePerson.scrollView.scrollEnabled = NO;
    _wvSalePerson.scrollView.backgroundColor = [UIColor clearColor];
    
    // 按钮
    _btnMoreCar = [[UIButton alloc] initWithFrame:CGRectMake((self.width - (self.width - 20)) / 2, _vPrice.maxY + 20, self.width - 20, 44)];
    [_btnMoreCar setTitle:_viewType == UCEvaluationDetailViewTypeBuyCar ? @"查看同款车源" : @"发布车源" forState:UIControlStateNormal];
    _btnMoreCar.titleLabel.font = kFontLarge;
    _btnMoreCar.backgroundColor = kColorBlue;
    [_btnMoreCar addTarget:self action:@selector(onClickFunctionBtn:) forControlEvents:UIControlEventTouchUpInside];
    _btnMoreCar.layer.masksToBounds = YES;
    _btnMoreCar.layer.cornerRadius = 3;
    
    
    [self addSubview:_svMain];
    [_svMain addSubview:_vCarInfo];
    [_svMain addSubview:_vPrice];
    [_svMain addSubview:_btnMoreCar];
    [_vPrice addSubview:_wvSalePerson];
    
    [self addSubview:_tbTop];
    
    // 获取 推荐商家
    [[AMToastView toastView:YES] showLoading:@"正在加载中..." cancel:^{
        [_apiHelperBusinessCity cancel];
        if (_apiHelperBusinessProvince) [_apiHelperBusinessProvince cancel];
        if (_apiHelperBusinessCountry) [_apiHelperBusinessCountry cancel];
        [[AMToastView toastView] hide];
    }];
    [self getRecommendedBusinesses:self.mEvaluationBusinessInfo apiHelper:_apiHelperBusinessCity];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    
    // 标题
    [vTopBar.btnTitle setTitle:@"估价结果" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    return vTopBar;
}

/** 创建车辆信息视图 */
-(UIView *)creatCarInfoView:(CGRect)frame :(UCEvaluationModel *)mEvaluation
{
    UIView *vCarInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _svMain.width, 98)];
    vCarInfo.backgroundColor = kColorWhite;
    _vCarInfo.hidden = YES;
    // 图片
    UIImageView *ivImageBag = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 90, 67.5)];
    ivImageBag.image = [UIImage imageNamed:@"home_default.png"];
    
    _ivCar = [[UIImageView alloc] initWithFrame:ivImageBag.bounds];
    _ivCar.contentMode = UIViewContentModeScaleAspectFit;
    _ivCar.image = [UIImage imageNamed:@"home_default.png"];
    
    // 车型车系
    UILabel *labCarName = [[UILabel alloc] initWithFrame:CGRectMake(ivImageBag.maxX + 14, 15, vCarInfo.width - ivImageBag.maxX - 30, 40)];
    labCarName.text = [NSString stringWithFormat:@"%@ %@",mEvaluation.seriesidText,mEvaluation.specidText];
    labCarName.numberOfLines = 2;
    labCarName.font = [UIFont boldSystemFontOfSize:16];
    
    // 城市
    UILabel *labArea = [[UILabel alloc] initWithFrame:CGRectMake(labCarName.minX, labCarName.maxY, labCarName.width, 12)];
    labArea.font = [UIFont systemFontOfSize:12];
    labArea.text = [NSString stringWithFormat:@"%@ %@",mEvaluation.pidText,mEvaluation.cidText];
    labArea.textColor = kColorGrey3;
    [labArea sizeToFit];
    
    // 里程 上牌时间
    UILabel *labMileageTime = [[UILabel alloc] initWithFrame:CGRectMake(labArea.minX, labArea.maxY, labArea.width, 12)];
    labMileageTime.font = [UIFont systemFontOfSize:12];
    labMileageTime.text = [NSString stringWithFormat:@"%@/%@",mEvaluation.mileageText,mEvaluation.firstregtimeText];
    labMileageTime.textColor = kColorGrey3;
    [labMileageTime sizeToFit];
    
    // 分享按钮
    UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake(249, 58, 56, 25)];
    [btnShare setTitle:@"分享" forState:UIControlStateNormal];
    [btnShare setBackgroundImage:[UIImage imageWithColor:kColorLightGreen size:btnShare.size] forState:UIControlStateNormal];
    [btnShare setBackgroundImage:[UIImage imageWithColor:kColorGreen2 size:btnShare.size] forState:UIControlStateHighlighted];
    btnShare.titleLabel.font = [UIFont systemFontOfSize:14];
    btnShare.layer.cornerRadius = 5;
    btnShare.layer.masksToBounds = YES;
    btnShare.enabled = NO;
    btnShare.tag = kBtnSharesTag;
    btnShare.hidden = YES;
    [btnShare addTarget:self action:@selector(onClickShareBtn:) forControlEvents:UIControlEventTouchUpInside];
    [vCarInfo addSubview:labCarName];
    [vCarInfo addSubview:ivImageBag];
    [ivImageBag addSubview:_ivCar];
    [vCarInfo addSubview:labArea];
    [vCarInfo addSubview:labMileageTime];
    [vCarInfo addSubview:btnShare];
    return vCarInfo;
}


#pragma mark - private Method
/** 加载估价 */
- (void)reloadPriceView:(UCEvaluationPriceModel *)mEPrice
{
    if (mEPrice.url.length > 0 && ![mEPrice.url isEqualToString:@"http://www.autoimg.cn/2scimg/web/pic/nocar_240_180.jpg"])
        [_ivCar sd_setImageWithURL:[NSURL URLWithString:mEPrice.url]];
    else
        _ivCar.image = [UIImage imageNamed:@"home_default.png"];
    
    NSString *strSalePersonHtml = _viewType == UCEvaluationDetailViewTypeSellCar ? @"<span style=\"font-size:15px;color:#4a576c;font-family:Helvetica;\">卖给商家参考价:%@</span>" : @"<span style=\"font-size:15px;color:#4a576c;font-family:Helvetica;\">买车参考价:%@</span>";
    NSString *strSalePersonrice = @"<span style=\"color:#4a576c;\"> 暂无数据</span>";
    if (mEPrice) {
        if (mEPrice.referenceprice.length > 0) {
            strSalePersonrice = [NSString stringWithFormat:@"<span style=\"font-size:15px;color:#ff8000;\"> %@</span><span style=\"font-size:15px;color:#4a576c;font-family:Helvetica;\">万元</span>", mEPrice.referenceprice];
        }
    }
    [_wvSalePerson loadHTMLString:[NSString stringWithFormat:strSalePersonHtml, strSalePersonrice] baseURL:nil];
    
    // 恢复分享按钮
    ((UIButton *)[self viewWithTag:kBtnSharesTag]).enabled = YES;
    _vPrice.hidden = NO;
    _vCarInfo.hidden = NO;
}

/** 重载商家信息 */
- (void)reloadBusinessInfo
{
    if (_businesses.count > 0) {
        // 商家信息视图
        _vBusinessInfo = [[UIView alloc] initWithFrame:CGRectMake(0, (_svMain.height - _vPrice.maxY - 40 > 0) ? (_svMain.height - 223) : (_vPrice.maxY + 40), _svMain.width, 223)];
        _vBusinessInfo.hidden = YES;
        _vBusinessInfo.backgroundColor = kColorWhite;
        [_svMain addSubview:_vBusinessInfo];
        
        // 推荐商家
        UIView *vTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _vBusinessInfo.width, 30)];
        vTitle.backgroundColor = kColorNewBackground;
        UILabel *labDealer = [[UILabel alloc] initWithClearFrame:CGRectMake(15, 0, vTitle.width - 30, vTitle.height)];
        labDealer.text = @"推荐经销商";
        labDealer.textColor = kColorGray1;
        labDealer.backgroundColor = kColorNewBackground;
        labDealer.font = kFontLarge;
        
        CGFloat height = (223 - labDealer.height) / 3;
        
        for (int i = 0; i < [_businesses count]; i++) {
            UserInfoModel *mUserInfo = (UserInfoModel *)[_businesses objectAtIndex:i];
            
            UIView *vBusinessItem = [[UIView alloc] initWithClearFrame:CGRectMake(0, height * i + labDealer.maxY, _vBusinessInfo.width, height)];
            
            // 商家按钮
            UIButton *btnBusinessItem = [[UIButton alloc] initWithFrame:vBusinessItem.bounds];
            btnBusinessItem.backgroundColor = [UIColor clearColor];
            btnBusinessItem.tag = i + kBtnBusinessItemTag;
            [btnBusinessItem addTarget:self action:@selector(onClickBusinessItemBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            // 名次背景
            NSArray *images = @[@"valuationresults_distributor_1", @"valuationresults_distributor_2", @"valuationresults_distributor_3"];
            UIImage *iRank = [UIImage imageNamed:images[i]];
            UIImageView *ivRank = [[UIImageView alloc] initWithFrame:CGRectMake(4, 0, iRank.width, iRank.height)];
            ivRank.userInteractionEnabled = NO;
            ivRank.image = iRank;
            
            // 商家名
            UILabel *labName = [[UILabel alloc] initWithClearFrame:CGRectMake(30, 14, _vBusinessInfo.width - 30 * 2, 15)];
            labName.userInteractionEnabled = NO;
            labName.textColor = kColorGray1;
            labName.font = kFontLarge;
            [vBusinessItem addSubview:labName];
            labName.tag = kNameLabelStartTag + i;
            labName.text = mUserInfo.username.length > 0 ? mUserInfo.username : @"暂无商家信息";
            
            // 已售
            UILabel *labSaled = [[UILabel alloc] initWithClearFrame:CGRectMake(labName.minX, 37, 40, 13)];
            labSaled.font = kFontMiddle;
            labSaled.userInteractionEnabled = NO;
            labSaled.textColor = kColorGrey2;
            labSaled.text = @"已售：";
            [labSaled sizeToFit];
            
            // 已售数量
            UILabel *labSaledNumber = [[UILabel alloc] initWithClearFrame:CGRectMake(labSaled.maxX, labSaled.minY, 0, 0)];
            labSaledNumber.userInteractionEnabled = NO;
            labSaledNumber.font = kFontMiddle;
            labSaledNumber.textColor = kColorBlue;
            labSaledNumber.tag = kSaledNumLabelStartTag + i;
            labSaledNumber.text = mUserInfo.carsaled.integerValue >= 0 ? [NSString stringWithFormat:@"%d",mUserInfo.carsaled.integerValue] : @"--";
            [labSaledNumber sizeToFit];
            
            // 已售单位
            UILabel *labSaledUnit = [[UILabel alloc] initWithClearFrame:CGRectMake(labSaledNumber.maxX, labSaled.minY, 0, 0)];
            labSaledUnit.userInteractionEnabled = NO;
            labSaledUnit.font = kFontMiddle;
            labSaledUnit.textColor = kColorGrey2;
            labSaledUnit.tag = kSaledUnitLabelStartTag + i;
            labSaledUnit.text = @" 辆";
            [labSaledUnit sizeToFit];
            
            // 在售
            UILabel *labSaling = [[UILabel alloc] initWithClearFrame:CGRectMake(127, 37, 40, 13)];
            labSaling.userInteractionEnabled = NO;
            labSaling.font = kFontMiddle;
            labSaling.textColor = kColorGrey2;
            labSaling.text = @"在售：";
            [labSaling sizeToFit];
            
            // 在售数量
            UILabel *labSalingNumber = [[UILabel alloc] initWithClearFrame:CGRectMake(labSaling.maxX, labSaling.minY, 0, 0)];
            labSalingNumber.userInteractionEnabled = NO;
            labSalingNumber.font = kFontMiddle;
            labSalingNumber.textColor = kColorBlue;
            labSalingNumber.tag = kSalingNumLabelStartTag + i;
            labSalingNumber.text = mUserInfo.carsaleing.integerValue >= 0 ? [NSString stringWithFormat:@"%d",mUserInfo.carsaleing.integerValue] : @"--";
            [labSalingNumber sizeToFit];
            
            // 在售单位
            UILabel *labSalingUnit = [[UILabel alloc] initWithClearFrame:CGRectMake(labSalingNumber.maxX, labSaling.minY, 0, 0)];
            labSalingUnit.userInteractionEnabled = NO;
            labSalingUnit.font = kFontMiddle;
            labSalingUnit.textColor = kColorGrey2;
            labSalingUnit.tag = kSalingUnitLabelStartTag + i;
            labSalingUnit.text = @" 辆";
            [labSalingUnit sizeToFit];
            
            // 添加视图
            [vBusinessItem addSubview:ivRank];
            [vBusinessItem addSubview:labSaled];
            [vBusinessItem addSubview:btnBusinessItem];
            [vBusinessItem addSubview:labSaledNumber];
            [vBusinessItem addSubview:labSaledUnit];
            [vBusinessItem addSubview:labSaling];
            [vBusinessItem addSubview:labSalingNumber];
            [vBusinessItem addSubview:labSalingUnit];
            
            // 分割线
            if (i != 2) {
                UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, vBusinessItem.height, vBusinessItem.width, kLinePixel) color:kColorNewLine];
                [vBusinessItem addSubview:vLine];
            }
            [_vBusinessInfo addSubview:vBusinessItem];
        }
        
        _vBusinessInfo.minY = (_svMain.height - _btnMoreCar.maxY - 40 - _vBusinessInfo.height >= 0) ? (_svMain.height - _vBusinessInfo.height) : (_btnMoreCar.maxY + 40);
        _svMain.contentSize = CGSizeMake(_svMain.width, _vBusinessInfo.maxY);
        
        [_vBusinessInfo addSubview:vTitle];
        [vTitle addSubview:labDealer];
    } else if (_mEvaluationBusinessInfo.cid || _mEvaluationBusinessInfo.pid) {
        if (_mEvaluationBusinessInfo.cid.integerValue > 0) {
            _mEvaluationBusinessInfo.cid = nil;
            if (!_apiHelperBusinessProvince)
                self.apiHelperBusinessProvince = [[APIHelper alloc] init];
            [self getRecommendedBusinesses:_mEvaluationBusinessInfo apiHelper:_apiHelperBusinessProvince];
        }
        else if (_mEvaluationBusinessInfo.pid.integerValue > 0) {
            _mEvaluationBusinessInfo.pid = nil;
            if (!_apiHelperBusinessCountry)
                self.apiHelperBusinessCountry = [[APIHelper alloc] init];
            [self getRecommendedBusinesses:_mEvaluationBusinessInfo apiHelper:_apiHelperBusinessCountry];
        }
    }
}

///** 暂无数据 */
//- (void)showNoData
//{
//    // 无数据提示
//    UILabel *labNoData = [[UILabel alloc] initWithClearFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.height)];
//    labNoData.text = @"暂无数据";
//    labNoData.textAlignment = NSTextAlignmentCenter;
//    labNoData.font = [UIFont systemFontOfSize:16];
//    labNoData.textColor = kColorGrey;
//    [self addSubview:labNoData];
//}

#pragma mark - onClickButton
/** 返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/***/
- (void)onClickFunctionBtn:(UIButton *)btn
{
    // 类似车源
    if (_viewType == UCEvaluationDetailViewTypeBuyCar) {
        [UMStatistics event:c_4_1_tool_evaluation_buycar_result_like];
        
        UCEvaluationSimilarView *vSimilar = [[UCEvaluationSimilarView alloc] initWithFrame:self.bounds carInfoDEditModel:_mCarInfoEdit];
        [[MainViewController sharedVCMain] openView:vSimilar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
    // 发布车源
    else if (_viewType == UCEvaluationDetailViewTypeSellCar) {
        UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
        NSNumber *userid = nil;
        NSNumber *dealerid = nil;
        switch ([AMCacheManage currentUserType]) {
            case UserStyleBusiness:
                dealerid = mUserInfo.userid;
                break;
            case UserStylePersonal:
                userid = mUserInfo.userid;;
                break;
                
            default:
                break;
        }
        [UMSAgent postEvent:tool_evaluation_buycar_result_sent_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:userid, @"userid#4", dealerid, @"dealerid#5", nil]];
        [UMStatistics event:c_4_1_tool_evaluation_sellcar_result_sent];
        // 进卖车
        if ([AMCacheManage currentUserType] == UserStyleBusiness || [AMCacheManage currentUserType] == UserStylePersonal) {
            [UMStatistics event:pv_4_1_tool_evaluation_sellcar_result_sent];
            UCSaleCarView *vSaleCar = [[UCSaleCarView alloc] initWithFrame:self.bounds carInfoEdit:_mCarInfoEdit];
            vSaleCar.delegate = self;
            [[MainViewController sharedVCMain] openView:vSaleCar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
        // 进选择身份
        else {
            UCSaleCarRootView *vSaleCarRoot = [[UCSaleCarRootView alloc] initWithFrame:self.bounds fromView:UCSaleCarRootViewFromEvaluationView];
            vSaleCarRoot.delegate = self;
            [[MainViewController sharedVCMain] openView:vSaleCarRoot animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
    }
}

/** 分享 */
- (void)onClickShareBtn:(UIButton *)btn
{
    AMLog(@"分享");
}

/** 商家详情 */
- (void)onClickBusinessItemBtn:(UIButton *)btn
{
    [UMStatistics event:_viewType == UCEvaluationDetailViewTypeBuyCar ?c_4_1_tool_evaluation_buycar_result_buiness : c_4_1_tool_evaluation_sellcar_result_buiness];
    UserInfoModel *mUserInfo = [_businesses objectAtIndex:btn.tag - kBtnBusinessItemTag];
    UCBusinessInfoView *vBusinessInfo = [[UCBusinessInfoView alloc] initWithFrame:self.bounds userid:[NSNumber numberWithInteger:[mUserInfo.userid integerValue]]];
    [[MainViewController sharedVCMain] openView:vBusinessInfo animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

#pragma mark - UCSaleCarRootViewDelegate
-(void)UCSaleCarRootViewDidSelectedUserType:(UCSaleCarRootView *)vSaleCarRoot
{
    [UMStatistics event:pv_4_1_tool_evaluation_sellcar_result_sent];
    [[MainViewController sharedVCMain] closeView:vSaleCarRoot animateOption:AnimateOptionMoveNone];
    // 进卖车
    UCSaleCarView *vSaleCar = [[UCSaleCarView alloc] initWithFrame:self.bounds carInfoEdit:_mCarInfoEdit];
    vSaleCar.delegate = self;
    [[MainViewController sharedVCMain] openView:vSaleCar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

#pragma mark - UCReleaseCarViewDelegate
- (void)releaseCarFinish:(UCCarInfoEditModel *)mCarInfoEdit
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveNone];
    if ([self.delegate respondsToSelector:@selector(didSuccessedReleaseCarWtihUCEvaluationDetailView:)]) {
        [self.delegate didSuccessedReleaseCarWtihUCEvaluationDetailView:self];
    }
}

#pragma mark - apiHelper
/** 推荐商家 */
- (void)getRecommendedBusinesses:(UCEvaluationModel *)mEvaluation apiHelper:(APIHelper *)apiHelper
{
    __weak UCEvaluationDetailView *vEvaluationDetail = self;
    // 设置请求完成后回调方法
    [apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 非取消请求
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    [[AMToastView toastView] hide];
                    // 推荐商家
                    for (NSDictionary *dicBusiness in mBase.result) {
                        if (vEvaluationDetail.businesses.count > 2)
                            break;
                        UserInfoModel *mUserInfo = [[UserInfoModel alloc] initWithJson:dicBusiness];
                        [vEvaluationDetail.businesses addObject:mUserInfo];
                    }
                    // 加载商家信息
                    [vEvaluationDetail reloadBusinessInfo];
                    vEvaluationDetail.vBusinessInfo.hidden = NO;
                    vEvaluationDetail.vCarInfo.hidden = NO;
                } else {
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                }
            } else {
                [[AMToastView toastView] hide];
            }
        }
    }];
    
    [apiHelper getRecommendedBusinesses:mEvaluation];
}

- (void)dealloc
{
    AMLog(@"dealloc...");
    [_apiHelperBusinessCity cancel];
    if (_apiHelperBusinessProvince) [_apiHelperBusinessProvince cancel];
    if (_apiHelperBusinessCountry) [_apiHelperBusinessCountry cancel];
}

@end
