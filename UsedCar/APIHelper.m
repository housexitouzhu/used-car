//
//  APIHelper.m
//  UsedCar
//
//  Created by Alan on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "ApiHelper.h"
#import "NSString+Util.h"
#import "UCEvaluationModel.h"
#import "AMCacheManage.h"
#import "UCRegisterDealerModel.h"
#import "AppDelegate.h"
#import "UCCarAttenModel.h"
#import "UCPriceModel.h"
#import "UCRegisterClientModel.h"

@implementation APIHelper

static int indicatorNum = 0;

static NSString *hostApp   = @"http://app.api.che168.com";
static NSString *hostApps  = @"http://apps.api.che168.com";
static NSString *hostShare = @"http://m.app.che168.com";

static NSString *pathApp    = @"/phone/v34";
static NSString *pathApps   = @"/phone/v34";
static NSString *pathAppV35 = @"/phone/v35";
static NSString *pathAppV37 = @"/phone/v37";
static NSString *pathAppV38 = @"/phone/v38";
static NSString *pathAppV40 = @"/phone/v40";
static NSString *pathAppV41 = @"/phone/v41";
static NSString *public = @"/public";

static NSString *hostAppTest = @"http://10.168.0.194"; // @"http://app6.api.che168.com";//221.192.136.97"; //@"http://10.168.100.83" //@"http://10.168.0.194";
static NSString *hostAppsTest = @"http://10.168.0.194:81";

#define kClaimURL @"m/deposit/claim/?_appid=app.iphone" //索赔页面
#define kClaimHelpURL @"m/pages/deposit/claimhelp.html" //索赔帮助页
#define kExchangeURL @"m/deposit/gift/?_appid=app.iphone" //换礼活动页
#define kExchangeHelpURL @"m/pages/deposit/gifthelp.html" //换礼帮助页
#define kSaleHelpURL @"/help/dealer/index.html" //卖车帮助

#define kShareURL_EmissionResult @"/guobiao/searchresult/?cid=" //排放结果分享
/**
 排放标准的地区列表 App 内打开要加上&isapp=1
 Type值：{1,"国2"},{2,"国3"},{3,"国4"},{4,"京5"}
 */
#define kShareURL_EmissionArea @"/guobiao/arealist/?type="
#define kShareURL_DealerStore @"/dealershare/list/?dealerid=" //店铺分享链接
#define kShareURL_DealerCar @"/dealershare/list/?shareid=" //车源分享链接

#pragma mark - 固定 URL
/** 成交还礼 **/
+ (NSString*)getToolExchangeWebURL{
    return [NSString stringWithFormat:@"%@/%@", hostApps,kExchangeURL];
}

/** 成交还礼帮助 **/
+ (NSString*)getToolExchangeHelpWebURL{
    return [NSString stringWithFormat:@"%@/%@", hostApps,kExchangeHelpURL];
}

/** 索赔陪还礼 **/
+ (NSString*)getToolClaimWebURL{
    return [NSString stringWithFormat:@"%@/%@", hostApps,kClaimURL];
}

/** 索赔还礼帮助 **/
+ (NSString*)getToolClaimHelpWebURL{
    return [NSString stringWithFormat:@"%@/%@", hostApps,kClaimHelpURL];
}

/** 国标结果 */
+ (NSString*)getShareEmissionResult{
    return [hostShare stringByAppendingString:kShareURL_EmissionResult];
}

/** 国标地区页 */
+(NSString*)getShareEmissionArea{
    return [hostShare stringByAppendingString:kShareURL_EmissionArea];
}

/** 店铺分享 */
+(NSString*)getShareDealerStore{
    return [hostShare stringByAppendingString:kShareURL_DealerStore];
}

/** 车源分享 */
+(NSString*)getShareDealerCar{
    return [hostShare stringByAppendingString:kShareURL_DealerCar];
}

/** 商家帮助 */
+(NSString *)getSaleHelp{
    return [hostShare stringByAppendingString:kSaleHelpURL];
}

#pragma mark -
- (id)init
{
    self = [super init];
    if (self) {
        [APIHelper setHostType:HostStatus == 1 ? HostTypeTest : HostTypeRelease];
    }
    return self;
}

/** 设置环境 */
+ (void)setHostType:(HostType)hostType {
    switch (hostType) {
        case HostTypeRelease: // 发布环境
            hostApp = hostApp;
            hostApps = hostApps;
            break;
        case HostTypeTest: // 线下测试环境
            hostApp = hostAppTest;
            hostApps = hostAppsTest;
            break;
    }
}

/** 是否有可用网络 */
+ (BOOL)isNetworkAvailable
{
    if([self currentNetworkStatus] == NotReachable)
        return NO;
    return YES;
}

/** 当前网络状态 */
+ (NetworkStatus)currentNetworkStatus
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return [reachability currentReachabilityStatus];
}

/** 当前网络状态名称 */
+ (NSString *)currentNetworkStatusName
{
    switch ([self currentNetworkStatus]) {
        case NotReachable:
            return @"NotNetwork";
        case ReachableViaWiFi:
            return @"Wifi";
        case ReachableViaWWAN:
            return @"3G";
    }
}

/** 请求完成执行代码块 */
- (void)setFinishBlock:(APIFinishBlock)blockFinish
{
    _blockFinish = blockFinish;
}

/** 请求中执行代码块 */
- (void)setReceiveBlock:(APIReceiveBlock)blockReceive
{
    _blockReceive = blockReceive;
}

/** 发送数据中执行代码块 */
- (void)setSendBlock:(APISendBlock)blockSend
{
    _blockSend = blockSend;
}

/** 初始化网络连接 */
- (BOOL)initUrlConnection{
    // 连接已存在
    if (_connection) {
        [self cancel:NO];
        //[self noticeFinished:[NSError errorWithDomain:ConnectionTextRepeat code:ConnectionStatusRepeat userInfo:nil]];
    }
    
    BOOL isNetwork = [APIHelper isNetworkAvailable];
    if (!isNetwork)
        [self noticeFinished:[NSError errorWithDomain:ConnectionTextNot code:ConnectionStatusNot userInfo:nil]];
    else {
        // 初始化数据流
        _data = [[NSMutableData alloc] init];
    }
    
    return isNetwork;
}

/** 生成请求的url */
- (NSString *)urlWithHost:(NSString *)host path:(NSString *)path file:(NSString *)file
{
    return [NSString stringWithFormat:@"%@%@%@", host, path, file];
}

#pragma mark Push
/** 提交 Push Token */
- (void)submitToken:(NSString *)token
{
    NSString *urlString = [NSString stringWithFormat:@"http://push.app.autohome.com.cn/usedcarv3.0/CollectSnToken.ashx"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[OMG openUDID] forKey:@"sn"];
    [params setValue:token forKey:@"t"];
    [params setValue:@"1" forKey:@"p"];
    [params setValue:@"3" forKey:@"a"];
    
    [self requestWithUrlString:urlString params:params method:HTTPMethodGet];
}

/** 注册用户设备 */
- (void)registDeviceWithPid:(NSNumber *)pid cid:(NSNumber *)cid;
{
    NSString *token = [AMCacheManage currentToken];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (pid) [params setValue:pid forKey:@"pid"];
    if (cid) [params setValue:cid forKey:@"cid"];
    if (token.length > 0) [params setValue:token forKey:@"devicetoken"];
    [params setValue:[[UIDevice currentDevice] model] forKey:@"syssn"]; // 系统型号
    [params setValue:[[UIDevice currentDevice] systemVersion] forKey:@"sysversion"]; // 系统版本
    [params setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] forKey:@"appname"]; // 软件名称
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathApp file:@"/Push/regUser.ashx"] params:params method:HTTPMethodPost];
}

/** 根据用户id注册push */
- (void)registPush
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV38 file:@"/Push/regPush.ashx"] params:params method:HTTPMethodPost3];
}

/** 设置推送的时间段 */
- (void)setPushTime:(BOOL)isOn starttime:(NSInteger)starttime endtime:(NSInteger)endtime allowperson:(NSString *)allowperson allowsystem:(NSString *)allowsystem
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSNumber numberWithInteger:isOn ? 10 : 20] forKey:@"state"];
    if (starttime) [params setValue:[NSNumber numberWithInteger:starttime] forKey:@"starttime"];
    if (endtime) [params setValue:[NSNumber numberWithInteger:endtime] forKey:@"endtime"];
    if (allowperson) [params setValue:allowperson forKey:@"allowperson"];
    if (allowsystem) [params setValue:allowsystem forKey:@"allowsystem"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathApp file:@"/push/setpushtime.ashx"] params:params method:HTTPMethodPost1];
}

/** 根据用户id注销push服务 */
- (void)logoutPush
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathApp file:@"/Push/UnRegPush.ashx"] params:params method:HTTPMethodPost1];
}

/** 获得订阅总数 */
- (void)getAttentionCount
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/Push/GetConcernCount.ashx"] params:params method:HTTPMethodGet2];
}

/** 获取订阅列表 */
- (void)getAttentionCars
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/Push/GetConcernCars.ashx"] params:params method:HTTPMethodGet2];
}

/** 更新查看订阅列表时间 */
- (void)updatecarsLastdateWithAttentionid:(NSNumber *)attentionid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (attentionid) [params setValue:attentionid forKey:@"id"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV38 file:@"/push/updatecarsLastdate.ashx"] params:params method:HTTPMethodPost1];
}

/** 添加订阅 */
- (void)addAttentionWithAttenModel:(UCCarAttenModel *)mAttention
{
    // 特殊控制：北京、上海、重庆、天津 取消cid
    if ((mAttention.pid.integerValue == 110000 || mAttention.pid.integerValue == 310000 || mAttention.pid.integerValue == 500000 || mAttention.pid.integerValue == 120000) && mAttention.cid.integerValue > 0)
        mAttention.cid = nil;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (mAttention) {
        if (mAttention.areaid) [params setValue:mAttention.areaid forKeyPath:@"areaid"];
        if (mAttention.pid) [params setValue:mAttention.pid forKey:@"pid"];
        if (mAttention.cid) [params setValue:mAttention.cid forKey:@"cid"];
        if (mAttention.brandid) [params setValue:mAttention.brandid forKey:@"brandid"];
        if (mAttention.seriesid) [params setValue:mAttention.seriesid forKey:@"seriesid"];
        if (mAttention.specid) [params setValue:mAttention.specid forKey:@"specid"];
        if (mAttention.priceregion) [params setValue:mAttention.priceregion forKey:@"priceregion"];
        if (mAttention.mileageregion) [params setValue:mAttention.mileageregion forKey:@"mileageregion"];
        if (mAttention.registeageregion) [params setValue:mAttention.registeageregion forKey:@"registeageregion"];
        if (mAttention.levelid) [params setValue:mAttention.levelid forKey:@"levelid"];
        if (mAttention.gearboxid) [params setValue:mAttention.gearboxid forKey:@"gearboxid"];
        if (mAttention.color) [params setValue:mAttention.color forKey:@"color"];
        if (mAttention.displacement) [params setValue:mAttention.displacement forKey:@"displacement"];
        if (mAttention.countryid) [params setValue:mAttention.countryid forKey:@"countryid"];
        if (mAttention.countrytype) [params setValue:mAttention.countrytype forKey:@"countrytype"];
        if (mAttention.powertrain) [params setValue:mAttention.powertrain forKey:@"powertrain"];
        if (mAttention.structure) [params setValue:mAttention.structure forKey:@"structure"];
        if (mAttention.sourceid) [params setValue:mAttention.sourceid forKey:@"sourceid"];
        if (mAttention.haswarranty) [params setValue:mAttention.haswarranty forKey:@"haswarranty"];
        if (mAttention.extrepair) [params setValue:mAttention.extrepair forKey:@"extrepair"];
        if (mAttention.isnewcar) [params setValue:mAttention.isnewcar forKey:@"isnewcar"];
        if (mAttention.dealertype) [params setValue:mAttention.dealertype forKey:@"dealertype"];
        if (mAttention.ispic) [params setValue:mAttention.ispic forKey:@"ispic"];
        
    }
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/Push/SetConcernCars.ashx"] params:params method:HTTPMethodPost1];
}

/** 修改订阅 */
- (void)editAttentionWithID:(NSNumber *)ID attenModel:(UCCarAttenModel *)mAttention
{
    // 特殊控制：北京、上海、重庆、天津 取消cid
    if ((mAttention.pid.integerValue == 110000 || mAttention.pid.integerValue == 310000 || mAttention.pid.integerValue == 500000 || mAttention.pid.integerValue == 120000) && mAttention.cid.integerValue > 0)
        mAttention.cid = nil;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (ID) [params setValue:ID forKey:@"id"];
    if (mAttention.areaid) [params setValue:mAttention.areaid forKeyPath:@"areaid"];
    if (mAttention.pid) [params setValue:mAttention.pid forKey:@"pid"];
    if (mAttention.cid) [params setValue:mAttention.cid forKey:@"cid"];
    if (mAttention.brandid) [params setValue:mAttention.brandid forKey:@"brandid"];
    if (mAttention.seriesid) [params setValue:mAttention.seriesid forKey:@"seriesid"];
    if (mAttention.specid) [params setValue:mAttention.specid forKey:@"specid"];
    if (mAttention.priceregion) [params setValue:mAttention.priceregion forKey:@"priceregion"];
    if (mAttention.mileageregion) [params setValue:mAttention.mileageregion forKey:@"mileageregion"];
    if (mAttention.registeageregion) [params setValue:mAttention.registeageregion forKey:@"registeageregion"];
    if (mAttention.levelid) [params setValue:mAttention.levelid forKey:@"levelid"];
    if (mAttention.gearboxid) [params setValue:mAttention.gearboxid forKey:@"gearboxid"];
    if (mAttention.color) [params setValue:mAttention.color forKey:@"color"];
    if (mAttention.displacement) [params setValue:mAttention.displacement forKey:@"displacement"];
    if (mAttention.countryid) [params setValue:mAttention.countryid forKey:@"countryid"];
    if (mAttention.countrytype) [params setValue:mAttention.countrytype forKey:@"countrytype"];
    if (mAttention.powertrain) [params setValue:mAttention.powertrain forKey:@"powertrain"];
    if (mAttention.structure) [params setValue:mAttention.structure forKey:@"structure"];
    if (mAttention.sourceid) [params setValue:mAttention.sourceid forKey:@"sourceid"];
    if (mAttention.haswarranty) [params setValue:mAttention.haswarranty forKey:@"haswarranty"];
    if (mAttention.extrepair) [params setValue:mAttention.extrepair forKey:@"extrepair"];
    if (mAttention.isnewcar) [params setValue:mAttention.isnewcar forKey:@"isnewcar"];
    if (mAttention.dealertype) [params setValue:mAttention.dealertype forKey:@"dealertype"];
    if (mAttention.ispic) [params setValue:mAttention.ispic forKey:@"ispic"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/Push/UpdateConcernCars.ashx"] params:params method:HTTPMethodPost1];
    
}

/** 删除订阅车源 */
- (void)deleteConcernCars:(NSNumber *)attentionID
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (attentionID) [params setValue:attentionID forKey:@"id"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/Push/DeleteConcernCars.ashx"] params:params method:HTTPMethodPost1];
}

#pragma mark Apps(Get)
/** 搜索车源信息 没有 last update */
- (void)searchCarWithKeyword:(NSString *)keyword pagesize:(NSNumber *)pagesize pageindex:(NSNumber *)pageindex areaid:(NSString *)areaid pid:(NSString *)pid cid:(NSString *)cid dealerid:(NSNumber *)dealerid filter:(UCFilterModel *)mFilter orderby:(NSString *)orderby
{
    [self searchCarWithKeyword:keyword pagesize:pagesize pageindex:pageindex areaid:areaid pid:pid cid:cid dealerid:dealerid filter:mFilter orderby:orderby lastUpdate:nil];
}

/** 搜索车源信息 */
- (void)searchCarWithKeyword:(NSString *)keyword pagesize:(NSNumber *)pagesize pageindex:(NSNumber *)pageindex areaid:(NSString *)areaid pid:(NSString *)pid cid:(NSString *)cid dealerid:(NSNumber *)dealerid filter:(UCFilterModel *)mFilter orderby:(NSString *)orderby lastUpdate:(NSString*)lastupdate
{
    // 特殊控制：北京、上海、重庆、天津 取消cid
    if (([pid isEqualToString:@"110000"] || [pid isEqualToString:@"310000"] || [pid isEqualToString:@"500000"] || [pid isEqualToString:@"120000"]) && cid.length > 0)
        cid = nil;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (pagesize) [params setValue:pagesize forKey:@"pagesize"];
    if (pageindex) [params setValue:pageindex forKey:@"pageindex"];
    if (keyword) [params setValue:keyword forKey:@"keyword"];
    if (areaid) [params setValue:areaid forKeyPath:@"areaid"];
    if (pid) [params setValue:pid forKey:@"pid"];
    if (cid) [params setValue:cid forKey:@"cid"];
    if (dealerid) [params setValue:dealerid forKey:@"dealerid"];
    if (orderby) [params setValue:orderby forKey:@"orderby"];
    if (lastupdate) [params setValue:lastupdate forKeyPath:@"lastdate"];
    
    if (mFilter) {
        if (mFilter.brandid) [params setValue:mFilter.brandid forKey:@"brandid"];
        if (mFilter.seriesid) [params setValue:mFilter.seriesid forKey:@"seriesid"];
        if (mFilter.specid) [params setValue:mFilter.specid forKey:@"specid"];
        if (mFilter.priceregion) [params setValue:mFilter.priceregion forKey:@"priceregion"];
        if (mFilter.mileageregion) [params setValue:mFilter.mileageregion forKey:@"mileageregion"];
        if (mFilter.registeageregion) [params setValue:mFilter.registeageregion forKey:@"registeageregion"];
        if (mFilter.levelid) [params setValue:mFilter.levelid forKey:@"levelid"];
        if (mFilter.gearboxid) [params setValue:mFilter.gearboxid forKey:@"gearboxid"];
        if (mFilter.color) [params setValue:mFilter.color forKey:@"color"];
        if (mFilter.displacement) [params setValue:mFilter.displacement forKey:@"displacement"];
        if (mFilter.countryid) [params setValue:mFilter.countryid forKey:@"countryid"];
        if (mFilter.countrytype) [params setValue:mFilter.countrytype forKey:@"countrytype"];
        if (mFilter.powertrain) [params setValue:mFilter.powertrain forKey:@"powertrain"];
        if (mFilter.structure) [params setValue:mFilter.structure forKey:@"structure"];
        if (mFilter.sourceid) [params setValue:mFilter.sourceid forKey:@"sourceid"];
        if (mFilter.haswarranty) [params setValue:mFilter.haswarranty forKey:@"haswarranty"];
        if (mFilter.extrepair) [params setValue:mFilter.extrepair forKey:@"extrepair"];
        if (mFilter.isnewcar) [params setValue:mFilter.isnewcar forKey:@"isnewcar"];
        if (mFilter.dealertype) [params setValue:mFilter.dealertype forKey:@"dealertype"];
        if (mFilter.ispic) [params setValue:mFilter.ispic forKey:@"ispic"];
    }
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathAppV41 file:@"/cars/search.ashx"] params:params method:HTTPMethodGet];
}

/** 获取验证码 */
- (void)getTheVerificationCode:(NSString *)mobile type:(NSNumber *)type;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (mobile)[params setValue:mobile forKey:@"mobile"];
    if (type)[params setValue:type forKey:@"type"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathApp file:@"/salesleads/phonecode.ashx"] params:params method:HTTPMethodGet1];
}

/** 根据（手机识别码或者商家id）和上次截止时间获取当前时间之后所有车源的所有报价信息的总数 */
- (void)getSaleTotalNumber:(NSString *)lastDate
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:lastDate forKey:@"lastdate"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathApp file:@"/salesleads/getoffercountbydealer.ashx"] params:params method:HTTPMethodGet2];
}

/** 车辆详情 */
- (void)getCarInfo:(NSNumber *)carid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (carid) [params setValue:carid forKey:@"carid"];
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathAppV41 file:@"/Cars/getcarinfodetail.ashx"] params:params method:HTTPMethodGet2];
}

/** 获取详情pv */
- (void)getCarPVWithCarID:(NSNumber *)carID
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (carID.integerValue > 0) [params setValue:carID forKey:@"id"];
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathAppV38 file:@"/Cars/GetCarPv.ashx"] params:params method:HTTPMethodGet];
}

/** 增加详情pv */
- (void)setCarPVWithCarID:(NSNumber *)carID
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (carID.integerValue > 0) [params setValue:carID forKey:@"carid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/car/setcarpv.ashx"] params:params method:HTTPMethodGet2];
}

/** 详情页参考价 */
- (void)getCarDetailPriceWithPriceModel:(UCPriceModel *)mPrice
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (mPrice.specid) [params setValue:mPrice.specid forKey:@"specid"];
    if (mPrice.pid) [params setValue:mPrice.pid forKey:@"pid"];
    if (mPrice.cid) [params setValue:mPrice.cid forKey:@"cid"];
    if (mPrice.mileage) [params setValue:mPrice.mileage forKey:@"mileage"];
    if (mPrice.firstregtime) [params setValue:mPrice.firstregtime forKey:@"firstregtime"];
    if (mPrice.price) [params setValue:mPrice.price forKey:@"price"];
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathAppV40 file:@"/cars/detailpagereferenceprice.ashx"] params:params method:HTTPMethodGet];
}

/** 卖车参考价 */
- (void)getCarSalePriceWithPriceModel:(UCPriceModel *)mPrice
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (mPrice.specid) [params setValue:mPrice.specid forKey:@"specid"];
    if (mPrice.pid) [params setValue:mPrice.pid forKey:@"pid"];
    if (mPrice.cid) [params setValue:mPrice.cid forKey:@"cid"];
    if (mPrice.mileage) [params setValue:mPrice.mileage forKey:@"mileage"];
    if (mPrice.firstregtime) [params setValue:mPrice.firstregtime forKey:@"firstregtime"];
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathAppV40 file:@"/cars/referenceprice.ashx"] params:params method:HTTPMethodGet];
}

/** 推荐商家 */
- (void)getRecommendedBusinesses:(UCEvaluationModel *)mEvaluation
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (mEvaluation.pid) [params setValue:mEvaluation.pid forKey:@"pid"];
    if (mEvaluation.cid) [params setValue:mEvaluation.cid forKey:@"cid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathApps file:@"/dealer/recommendmerchant.ashx"] params:params method:HTTPMethodGet];
}

/** 估价 */
- (void)getEvaluetionPrice:(UCEvaluationModel *)mEvaluation type:(NSNumber *)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (mEvaluation.pid) [params setValue:mEvaluation.pid forKey:@"pid"];
    if (mEvaluation.cid) [params setValue:mEvaluation.cid forKey:@"cid"];
    if (mEvaluation.mileage) [params setValue:mEvaluation.mileage forKey:@"mileage"];
    if (mEvaluation.firstregtime) [params setValue:mEvaluation.firstregtime forKey:@"firstregtime"];
    if (mEvaluation.specid) [params setValue:mEvaluation.specid forKey:@"specid"];
    if (type) [params setValue:type forKey:@"dir"];
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathAppV41 file:@"/cars/evaluate.ashx"] params:params method:HTTPMethodGet];
}

/** 购车常识文章列表接 */
- (void)buyCarMustLook:(NSNumber *)charactersnum pagesize:(NSNumber *)pagesize pageindex:(NSNumber *)pageindex
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (pagesize) [params setValue:pagesize forKey:@"pagesize"];
    if (pageindex) [params setValue:pageindex forKey:@"pageindex"];
    if (charactersnum) [params setValue:charactersnum forKey:@"charactersnum"];
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathApps file:@"/article/getarticlelist.ashx"] params:params method:HTTPMethodGet];
}

/** 获取文章详情 **/
- (void)getArticleDetail:(NSString *)articleId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (articleId) [params setValue:[NSNumber numberWithInt:[articleId intValue]] forKey:@"articleid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathApps file:@"/article/getarticle.ashx"] params:params method:HTTPMethodGet];
}

/** 获取商家店铺信息接口 */
- (void)getBusinessInfo:(NSNumber *)userid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userid) [params setValue:userid forKey:@"userid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathAppV40 file:@"/dealer/getmerchantinfo.ashx"] params:params method:HTTPMethodGet];
}

/** 车型增量 */
- (void)getNewCars:(NSNumber *)lastproductid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:lastproductid forKey:@"lastproductid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathApps file:@"/product/getnewcars.ashx"] params:params method:HTTPMethodGet];
}

/** 新车配置 */
- (void)getNewCarConfigure:(NSNumber *)productid
{
    //#warning 即将开启的接口
    //    NSMutableDictionary *params = [self buildParams];
    //    [params setValue:productid forKey:@"specid"];
    //    [self requestWithUrlString:[self urlWithHost:hostApps path:pathApps file:@"product/getnewcarsconfigs.ashx"] params:params method:HTTPMethodGet];
    
    [self requestWithUrlString:[NSString stringWithFormat:@"http://baojiac.qichecdn.com/v3.1.0/cars/speccompare-a3-pm1-v3.1.0-t1-s%@.html",productid] params:nil method:HTTPMethodGet];
}

/** 根据商家id获取不同状态下的获取销售线索列表（根据用户最新排序） */
- (void)getSalesLeadsListWithListstate:(NSInteger)state pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (state) [params setValue:[NSNumber numberWithInteger:state] forKeyPath:@"state"];
    if (pageIndex) [params setValue:[NSNumber numberWithInteger:pageIndex] forKeyPath:@"pageindex"];
    if (pageSize) [params setValue:[NSNumber numberWithInteger:pageSize] forKeyPath:@"pagesize"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathApp file:@"/salesleads/carofferbydealerid.ashx"] params:params method:HTTPMethodGet2];
}

/** 根据商家id和用户手机号获取用户订阅的在售、已售、已过期车辆信息 */
- (void)getUserAttentionCarListWithMobile:(NSString *)mobile state:(NSNumber *)state
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (mobile) [params setValue:mobile forKeyPath:@"mobile"];
    if (state) [params setValue:state forKeyPath:@"state"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathApp file:@"/salesleads/userattentioncar.ashx"] params:params method:HTTPMethodGet2];
}

/** 商家名称是否有效 */
- (void)checkDealerInfo:(NSInteger)checktype checkvalue:(NSString *)checkvalue
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (checktype) [params setValue:[NSNumber numberWithInteger:checktype] forKeyPath:@"checktype"];
    if (checkvalue) [params setValue:checkvalue forKeyPath:@"checkvalue"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV35 file:@"/dealer/checkdealerinfo.ashx"] params:params method:HTTPMethodGet2];
}

/** 获得商家销售代表 */
- (void)getDealerSalesPersonListWithListate:(NSInteger)liststate title:(NSInteger)title
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSNumber numberWithInteger:liststate] forKeyPath:@"liststate"];
    [params setValue:[NSNumber numberWithInteger:title] forKeyPath:@"title"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV35 file:@"/dealerseller/getList.ashx"] params:params method:HTTPMethodGet2];
}

/** 获取活动信息 */
- (void)getActivityInfo:(NSString *)pid cid:(NSString *)cid;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:pid forKey:@"pid"];
    [params setValue:cid forKey:@"cid"];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat screenScale = [UIScreen mainScreen].scale;
    NSInteger width = screenSize.width;
    if (screenScale > 0)
        width = width * screenScale;
    
    [params setValue:[NSString stringWithFormat:@"%d", width] forKey:@"ratio"];
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:@"/activity" file:@"/ad40.ashx"] params:params method:HTTPMethodGet];
}

/** 获取举报信息 */
- (void)getReportInfo:(NSNumber *)carId userName:(NSString *)userName type:(NSNumber *)type brandid:(NSNumber *)brindid seriesid:(NSNumber *)seriesid specid:(NSNumber *)specid context:(NSString *)context mobile:(NSString *)mobile
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:carId forKeyPath:@"carid"];
    [params setValue:userName forKeyPath:@"uname"];
    [params setValue:type forKeyPath:@"type"];
    [params setValue:brindid forKeyPath:@"brandid"];
    [params setValue:seriesid forKeyPath:@"seriesid"];
    [params setValue:specid forKeyPath:@"specid"];
    [params setValue:context forKeyPath:@"content"];
    [params setValue:mobile forKeyPath:@"mobile"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV37 file:@"/report/cartipoff.ashx"] params:params method:HTTPMethodPost1];
}

/** 口碑列表 */
- (void)openReputation:(NSString *)specsId;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:specsId forKeyPath:@"specid"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV37 file:@"/report/cartipoff.ashx"] params:params method:HTTPMethodGet2];
}

/** 热门品牌 */
- (void)getHotBrands
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[AMCacheManage currentArea].pid forKey:@"pid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathAppV37 file:@"/OfferNews/GetHotBrand.ashx"] params:params method:HTTPMethodGet1];
}

/** 统计-拨打电话或发送短信时统计（GET） */
- (void)callstatisticsEventWithCarID:(NSNumber *)carid type:(NSNumber *)type dealerid:(NSNumber *)dealerid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (carid) [params setValue:carid forKeyPath:@"carid"];
    if (type) [params setValue:type forKeyPath:@"type"];
    if (dealerid) [params setValue:dealerid forKeyPath:@"dealerid"];

    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/statistics/callstatistics.ashx"] params:params method:HTTPMethodGet2];
}

/** 收藏 0删除, 1收藏*/
-(void)addOrDeleteFavorite:(NSNumber *)carID toType:(NSInteger)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:carID.stringValue forKey:@"carid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:(type == 0 ? @"/ucenter/personcollectdelete.ashx" : @"/ucenter/personcollectadd.ashx")] params:params method:HTTPMethodGet3];
}

/** 收藏列表 */
- (void)getFavoritesListPageIndex:(NSInteger)pageIndex size:(NSInteger)size{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSNumber numberWithInt:pageIndex] forKey:@"pageindex"];
    [params setValue:[NSNumber numberWithInt:size] forKey:@"pagesize"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/ucenter/PersonCollectGetList.ashx"] params:params method:HTTPMethodGet3];
}

/** 个人登录时判断车源是否收藏收藏（GET） */
- (void)isFavoriteCar:(NSNumber *)carID
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:carID forKey:@"carid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/ucenter/PersonCollectIsFavorite.ashx"] params:params method:HTTPMethodGet3];
}

/** 获取IM身份验证的验证码 */
- (void)getVerifyCode:(NSString *)mobile type:(NSNumber *)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:mobile forKey:@"mobile"];
    [params setValue:type forKey:@"type"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:public file:@"/GetMobileCode.ashx"] params:params method:HTTPMethodPost1];
}

/** 验证IM身份 */
- (void)verifyIMWithName:(NSString *)name mobile:(NSString *)mobile code:(NSString *)code salesid:(NSNumber *)salesid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:mobile forKey:@"name"];
    [params setValue:name forKey:@"nickname"];
    [params setValue:code forKey:@"validcode"];
    if (salesid) [params setValue:salesid forKey:@"salesid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/im/registerim.ashx"] params:params method:HTTPMethodPost1];
}

/** 获取 IM 服务器信息 */
- (void)getIMServerInfo{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/im/GetService.ashx"] params:params method:HTTPMethodGet2];
}

/** IM-注册在线咨询用户（POST） */
- (void)registerIMwithMobileName:(NSString*)mobile nickname:(NSString*)nickname memberID:(NSString*)memberID dealerID:(NSString*)dealerID salesID:(NSString*)salesID validcode:(NSString*)validCode{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:mobile forKey:@"name"];
    [params setValue:nickname forKey:@"nickname"];
    if (memberID) {
        [params setValue:memberID forKey:@"memberid"];
    }
    if (dealerID) {
        [params setValue:dealerID forKey:@"dealerid"];
    }
    if (salesID) {
        [params setValue:salesID forKey:@"salesid"];
    }
    if (validCode) {
        [params setValue:validCode forKey:@"validcode"];
    }
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/im/registerim.ashx"] params:params method:HTTPMethodPost1];
}

/** IM-第一次对话时增加联系人（POST） */
- (void)addIMLinkerNamefrom:(NSString*)namefrom
                   nickname:(NSString*)nickname
             dealernamefrom:(NSString*)dealernamefrom
                     nameto:(NSString*)nameto
                 nicknameto:(NSString*)nicknameto
                   dealerid:(NSString*)dealerid
                   memberid:(NSString*)memberid
                    salesid:(NSString*)salesid
                    carname:(NSString*)carname
                  carimgurl:(NSString*)carimgurl
                 dealername:(NSString*)dealername
                   objectid:(NSString*)objectid
                     typeid:(NSString*)typeID{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:namefrom forKey:@"namefrom"];
    [params setValue:nickname forKey:@"nickname"];
    [params setValue:nameto forKey:@"nameto"];
    [params setValue:nicknameto forKey:@"nicknameto"];
    if (carname.length > 0) {
        [params setValue:carname forKey:@"carname"];
    }
    if (carimgurl.length > 0) {
        [params setValue:carimgurl forKey:@"carimgurl"];
    }
    [params setValue:objectid forKey:@"objectid"];
    
    if (dealernamefrom) {
        [params setValue:dealernamefrom forKey:@"dealernamefrom"];
    }
    if (dealerid) {
        [params setValue:dealerid forKey:@"dealerid"];
    }
    if (memberid) {
        [params setValue:memberid forKey:@"memberid"];
    }
    if (salesid) {
        [params setValue:salesid forKey:@"salesid"];
    }
    if (dealername) {
        [params setValue:dealername forKey:@"dealername"];
    }
    
    //该字段直接关系字段, 比如，typeid==10,objectid则代表车源id
    [params setValue:@(10) forKey:@"typeid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/im/AddLinker.ashx"] params:params method:HTTPMethodPost1];
}

//<<<<<<< .mine
///** IM-注册在线咨询用户（POST） */
//- (void)registerIMwithMobileName:(NSString*)mobile nickname:(NSString*)nickname dealerID:(NSString *)dealerID salesID:(NSString*)salesID validcode:(NSString*)validCode{
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setValue:mobile forKey:@"name"];
//    [params setValue:nickname forKey:@"nickname"];
//    if (salesID) {
//        [params setValue:salesID forKey:@"salesid"];
//    }
//    if (validCode) {
//        [params setValue:validCode forKey:@"validcode"];
//    }
//    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/im/registerim.ashx"] params:params method:HTTPMethodPost1];
//}
//
//=======
//>>>>>>> .r60347
/** IM-获取联系人信息(Get) */
- (void)getIMLinkByNameFrom:(NSString*)namefrom nameTo:(NSString*)nameTo memberID:(NSString*)memberID dealerID:(NSString*)dealerID salesID:(NSString*)salesID{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:namefrom forKey:@"namefrom"];
    [params setValue:nameTo forKey:@"nameto"];
    
    if (memberID) {
        [params setValue:memberID forKey:@"memberid"];
    }
    if (dealerID) {
        [params setValue:dealerID forKey:@"dealerid"];
    }
    if (salesID) {
        [params setValue:salesID forKey:@"salesid"];
    }
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/im/getlinkerinfo.ashx"] params:params method:HTTPMethodGet2];
}

/** IM-获取联系人列表 */
- (void)getimlinkerlistWithMyName:(NSString *)name page:(NSNumber *)page index:(NSNumber *)index
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:name forKey:@"name"];
    if (page) [params setValue:page forKey:@"pageindex"];
    if (index) [params setValue:index forKey:@"pagesize"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/im/getimlinkerlist.ashx"] params:params method:HTTPMethodGet2];
}

/** IM-屏蔽或解除屏蔽联系人（GET） */
- (void)blockIMContactWithBlockType:(BOOL)block namefrom:(NSString*)namefrom nameto:(NSString*)nameto{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:namefrom forKey:@"namefrom"];
    [params setValue:nameto forKey:@"nameto"];
    
    if (block) {
        [params setValue:@"1" forKey:@"type"];
    }
    else{
        [params setValue:@"0" forKey:@"type"];
    }
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/im/updatelinkerstate.ashx"] params:params method:HTTPMethodGet2];
}

#pragma mark App(Post)
/** 商家销售代表添加 */
- (void)addSalesPerson:(SalesPersonModel *)mSalesPerson
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:mSalesPerson.salesname forKey:@"name"];
    [params setValue:mSalesPerson.salesphone forKey:@"phonenumber"];
    [params setValue:mSalesPerson.salesqq forKey:@"qq"];
    [params setValue:[NSNumber numberWithInteger:1] forKey:@"title"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV35 file:@"/dealerseller/selleradd.ashx"] params:params method:HTTPMethodPost1];
}

/** 同步销售线索通话记录 */
- (void)uploadCallRecords
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:[AMCacheManage currentCallRecord] options:kNilOptions error:NULL];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:json forKey:@"dispose"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV35 file:@"/salesleads/collectoffermessage.ashx"] params:params method:HTTPMethodPost3];
}

/** 发车 */
- (void)releaseCarWithCarInfoEditModel:(UCCarInfoEditModel *)mCarInfoEdit
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (mCarInfoEdit.vincode) [params setValue:mCarInfoEdit.vincode forKey:@"vincode"];
    if (mCarInfoEdit.carid) [params setValue:(mCarInfoEdit.carid.doubleValue < 0 ? [NSNumber numberWithInt:0] : mCarInfoEdit.carid) forKey:@"carid"];
    if (mCarInfoEdit.carname) [params setValue:mCarInfoEdit.carname forKey:@"carname"];
    if (mCarInfoEdit.brandid) [params setValue:mCarInfoEdit.brandid forKey:@"brandid"];
    if (mCarInfoEdit.seriesid) [params setValue:mCarInfoEdit.seriesid forKey:@"seriesid"];
    if (mCarInfoEdit.productid) [params setValue:mCarInfoEdit.productid forKey:@"productid"];
    if (mCarInfoEdit.displacement) [params setValue:mCarInfoEdit.displacement forKey:@"displacement"];
    if (mCarInfoEdit.gearbox) [params setValue:mCarInfoEdit.gearbox forKey:@"gearbox"];
    if (mCarInfoEdit.isincludetransferfee) [params setValue:(mCarInfoEdit.isincludetransferfee.boolValue ? @"true" : @"false") forKey:@"isincludetransferfee"];
    if (mCarInfoEdit.bookprice) [params setValue:mCarInfoEdit.bookprice forKey:@"bookprice"];
    if (mCarInfoEdit.isfixprice) [params setValue:(mCarInfoEdit.isfixprice.boolValue ? @"true" : @"false") forKey:@"isfixprice"];
    if (mCarInfoEdit.provinceid) [params setValue:mCarInfoEdit.provinceid forKey:@"provinceid"];
    if (mCarInfoEdit.cityid) [params setValue:mCarInfoEdit.cityid forKey:@"cityid"];
    if (mCarInfoEdit.drivemileage) [params setValue:mCarInfoEdit.drivemileage forKey:@"drivemileage"];
    if (mCarInfoEdit.purposeid) [params setValue:mCarInfoEdit.purposeid forKey:@"purposeid"];
    if (mCarInfoEdit.colorid) [params setValue:mCarInfoEdit.colorid forKey:@"colorid"];
    if (mCarInfoEdit.firstregtime) [params setValue:mCarInfoEdit.firstregtime forKey:@"firstregtime"];
    if (mCarInfoEdit.verifytime) [params setValue:mCarInfoEdit.verifytime forKey:@"verifytime"];
    if (mCarInfoEdit.veticaltaxtime) [params setValue:mCarInfoEdit.veticaltaxtime forKey:@"veticaltaxtime"];
    if (mCarInfoEdit.insurancedate) [params setValue:mCarInfoEdit.insurancedate forKey:@"insurancedate"];
    if (mCarInfoEdit.usercomment) [params setValue:mCarInfoEdit.usercomment forKey:@"usercomment"];
    if (mCarInfoEdit.imgurls) [params setValue:mCarInfoEdit.imgurls forKey:@"imgurls"];
    if (mCarInfoEdit.drivingpermit) [params setValue:mCarInfoEdit.drivingpermit forKey:@"drivingpermit"];
    if (mCarInfoEdit.registration) [params setValue:mCarInfoEdit.registration forKey:@"registration"];
    if (mCarInfoEdit.invoice) [params setValue:mCarInfoEdit.invoice forKey:@"invoice"];
    if (mCarInfoEdit.qualityassdate) [params setValue:mCarInfoEdit.qualityassdate forKey:@"qualityassdate"];
    if (mCarInfoEdit.qualityassmile) [params setValue:mCarInfoEdit.qualityassmile forKey:@"qualityassmile"];
    if (mCarInfoEdit.dctionimg) [params setValue:mCarInfoEdit.dctionimg forKey:@"dctionimg"];
    if (mCarInfoEdit.certificatetype) [params setValue:mCarInfoEdit.certificatetype forKey:@"certificatetype"];
    if (mCarInfoEdit.driverlicenseimage) [params setValue:mCarInfoEdit.driverlicenseimage forKeyPath:@"driverlicenseimage"];
    if (mCarInfoEdit.salesPerson.salesid) [params setValue:mCarInfoEdit.salesPerson.salesid forKey:@"salesid"];
    if (mCarInfoEdit.salesPerson.salesname) [params setValue:mCarInfoEdit.salesPerson.salesname forKey:@"salesname"];
    if (mCarInfoEdit.salesPerson.salesphone) [params setValue:mCarInfoEdit.salesPerson.salesphone forKey:@"salesphone"];
    if (mCarInfoEdit.salesPerson.salesqq) [params setValue:mCarInfoEdit.salesPerson.salesqq forKey:@"salesqq"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/car/releasecarinfo.ashx"] params:params method:HTTPMethodPost1];
}

/** 修改车 */
- (void)editCarWithCarInfoEditModel:(UCCarInfoEditModel *)mCarInfoEdit
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (mCarInfoEdit.vincode) [params setValue:mCarInfoEdit.vincode forKey:@"vincode"];
    if (mCarInfoEdit.carid) [params setValue:mCarInfoEdit.carid forKey:@"carid"];
    if (mCarInfoEdit.carname) [params setValue:mCarInfoEdit.carname forKey:@"carname"];
    if (mCarInfoEdit.brandid) [params setValue:mCarInfoEdit.brandid forKey:@"brandid"];
    if (mCarInfoEdit.seriesid) [params setValue:mCarInfoEdit.seriesid forKey:@"seriesid"];
    if (mCarInfoEdit.productid) [params setValue:mCarInfoEdit.productid forKey:@"productid"];
    if (mCarInfoEdit.displacement) [params setValue:mCarInfoEdit.displacement forKey:@"displacement"];
    if (mCarInfoEdit.gearbox) [params setValue:mCarInfoEdit.gearbox forKey:@"gearbox"];
    if (mCarInfoEdit.isincludetransferfee) [params setValue:(mCarInfoEdit.isincludetransferfee.boolValue ? @"true" : @"false") forKey:@"isincludetransferfee"];
    if (mCarInfoEdit.bookprice) [params setValue:mCarInfoEdit.bookprice forKey:@"bookprice"];
    if (mCarInfoEdit.isfixprice) [params setValue:(mCarInfoEdit.isfixprice.boolValue ? @"true" : @"false") forKey:@"isfixprice"];
    if (mCarInfoEdit.provinceid) [params setValue:mCarInfoEdit.provinceid forKey:@"provinceid"];
    if (mCarInfoEdit.cityid) [params setValue:mCarInfoEdit.cityid forKey:@"cityid"];
    if (mCarInfoEdit.drivemileage) [params setValue:mCarInfoEdit.drivemileage forKey:@"drivemileage"];
    if (mCarInfoEdit.purposeid) [params setValue:mCarInfoEdit.purposeid forKey:@"purposeid"];
    if (mCarInfoEdit.colorid) [params setValue:mCarInfoEdit.colorid forKey:@"colorid"];
    if (mCarInfoEdit.firstregtime) [params setValue:mCarInfoEdit.firstregtime forKey:@"firstregtime"];
    if (mCarInfoEdit.verifytime) [params setValue:mCarInfoEdit.verifytime forKey:@"verifytime"];
    if (mCarInfoEdit.veticaltaxtime) [params setValue:mCarInfoEdit.veticaltaxtime forKey:@"veticaltaxtime"];
    if (mCarInfoEdit.insurancedate) [params setValue:mCarInfoEdit.insurancedate forKey:@"insurancedate"];
    if (mCarInfoEdit.usercomment) [params setValue:mCarInfoEdit.usercomment forKey:@"usercomment"];
    if (mCarInfoEdit.imgurls) [params setValue:mCarInfoEdit.imgurls forKey:@"imgurls"];
    if (mCarInfoEdit.drivingpermit) [params setValue:mCarInfoEdit.drivingpermit forKey:@"drivingpermit"];
    if (mCarInfoEdit.registration) [params setValue:mCarInfoEdit.registration forKey:@"registration"];
    if (mCarInfoEdit.invoice) [params setValue:mCarInfoEdit.invoice forKey:@"invoice"];
    if (mCarInfoEdit.qualityassdate) [params setValue:mCarInfoEdit.qualityassdate forKey:@"qualityassdate"];
    if (mCarInfoEdit.qualityassmile) [params setValue:mCarInfoEdit.qualityassmile forKey:@"qualityassmile"];
    if (mCarInfoEdit.dctionimg) [params setValue:mCarInfoEdit.dctionimg forKey:@"dctionimg"];
    if (mCarInfoEdit.certificatetype) [params setValue:mCarInfoEdit.certificatetype forKey:@"certificatetype"];
    if (mCarInfoEdit.driverlicenseimage) [params setValue:mCarInfoEdit.driverlicenseimage forKeyPath:@"driverlicenseimage"];
    if (mCarInfoEdit.salesPerson.salesid) [params setValue:mCarInfoEdit.salesPerson.salesid forKey:@"salesid"];
    if (mCarInfoEdit.salesPerson.salesname) [params setValue:mCarInfoEdit.salesPerson.salesname forKey:@"salesname"];
    if (mCarInfoEdit.salesPerson.salesphone) [params setValue:mCarInfoEdit.salesPerson.salesphone forKey:@"salesphone"];
    if (mCarInfoEdit.salesPerson.salesqq) [params setValue:mCarInfoEdit.salesPerson.salesqq forKey:@"salesqq"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/car/editCar.ashx"] params:params method:([AMCacheManage currentUserType] == UserStylePhone ? HTTPMethodPost4 : HTTPMethodPost1)];
}

/** 上传图片(个人) */
- (void)uploadImageNew:(NSData *)data
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"1" forKey:@"serialnum"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathApp file:@"/uploadImage.ashx"] params:params imageData:data];
}

/** 商家用户注册 */
- (void)registerDealer:(UCRegisterDealerModel *)mRegister
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:mRegister.shopname forKey:@"shopname"];
    [params setValue:mRegister.companytype forKey:@"companytype"];
    [params setValue:mRegister.pid forKey:@"pid"];
    [params setValue:mRegister.cid forKey:@"cid"];
    [params setValue:mRegister.contactname forKey:@"contactname"];
    [params setValue:mRegister.phonenumber forKey:@"phonenumber"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV35 file:@"/dealer/dealerregister.ashx"] params:params method:HTTPMethodPost1];
}

/** 个人用户注册 */
- (void)registerClient:(UCRegisterClientModel*)mRegister{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:mRegister.nickname forKey:@"nickname"];
    [params setValue:mRegister.userpwd forKey:@"userpwd"];
    [params setValue:mRegister.mobile forKey:@"mobile"];
    [params setValue:mRegister.validecode forKey:@"validecode"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/ucenter/uregister.ashx"] params:params method:HTTPMethodPost3];
}

/** 个人注册发送手机验证码 */
- (void)registerClientSendVerifyCodeByUserName:(NSString*)username mobile:(NSString*)mobile{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:mobile forKey:@"mobile"];
    [params setValue:username forKey:@"nickname"];
    [params setValue:[NSNumber numberWithInt:1] forKey:@"validcodetype"]; //0 更换手机号 1注册 2升级
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/ucenter/SentCode.ashx"] params:params method:HTTPMethodPost3];
}

/** 用户登录 */
- (void)userLogin:(NSString *)user pass:(NSString *)pass
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:user forKey:@"user"];
    [params setValue:pass.md5.encrypt3DES forKey:@"pass"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/dealer/userlogin.ashx"] params:params method:HTTPMethodPost3];
}

/** 个人登录 */
- (void)clientLogin:(NSString *)user pass:(NSString *)pass code:(NSString *)code
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:user forKey:@"name"];
    [params setValue:pass.md5.encrypt3DES forKey:@"pwd"];
    if (code) [params setValue:code forKey:@"validecode"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/ucenter/login.ashx"] params:params method:HTTPMethodPost3];
}

/** 个人登录刷新验证码 **/
- (void)getLoginVerifyCode{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/ucenter/createLoginCode.ashx"] params:params method:HTTPMethodGet2];
}

/** 手机找回车源 获取验证码 */
- (void)getValidateCodeByMobile:(NSString*)mobile{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:mobile forKey:@"mobile"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/mobilecar/sendcheckcode.ashx"] params:params method:HTTPMethodPost3];
}

/** 手机找回车源 */
- (void)carRetrieveByMobile:(NSString*)mobile validateCode:(NSString*)code{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:mobile forKey:@"mobile"];
    [params setValue:code forKey:@"mcode"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/mobilecar/checkcode.ashx"] params:params method:HTTPMethodPost3];
}

/** 提交商家/个人车源状态 */
- (void)postTheSourceState:(NSNumber *)carId price:(NSString *)price userName:(NSString *)userName userMobile:(NSString *)userMobile mcode:(NSString *)mcode
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (carId) [params setValue:carId forKey:@"carid"];
    if (price) [params setValue:price forKey:@"price"];
    if (userName) [params setValue:userName forKey:@"username"];
    if (userMobile) [params setValue:userMobile forKey:@"usermobile"];
    if (mcode) [params setValue:mcode forKey:@"mcode"];

    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/salesleads/addcaroffer.ashx"] params:params method:HTTPMethodPost1];
}

/** 用户退出 */
- (void)userLogout
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[AMCacheManage currentUserInfo].userkey forKey:@"userkey"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/car/userexit.ashx"] params:params method:HTTPMethodPost2];
    
}


/** 个人同步车源 */
- (void)clientSyncCar{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/ucenter/syncartomemberid.ashx"] params:params method:HTTPMethodPost4];
}

/** 个人同步订阅 */
- (void)clientSyncSubscription{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/ucenter/PersonConcernSync.ashx"] params:params method:HTTPMethodPost4];
}

/** 个人同步收藏 */
- (void)clientSyncFavoritesWithCarIDs:(NSArray *)carids{
    
    NSString *jointStr = [carids componentsJoinedByString:@","];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:jointStr forKey:@"carids"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/ucenter/personcollectaddsync.ashx"] params:params method:HTTPMethodPost4];
}


/** 获取车源数 */
- (void)getUserInfo
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV41 file:@"/car/getuserinfo_new.ashx"] params:params method:([AMCacheManage currentUserType] == UserStylePhone ? HTTPMethodGet3 : HTTPMethodGet2)];
}

/** 上传图片(商家) */
- (void)uploadImage:(NSString *)userKey imageData:(NSData *)data
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:userKey forKey:@"userkey"];
    [params setValue:@"1" forKey:@"serialnum"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathApp file:@"/dealer/uploadimage.ashx"] params:params imageData:data];
}

/** 获取状态列表车辆列表 */
- (void)getCarinfoListWithListState:(NSInteger)listState pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSString stringWithFormat:@"%d", listState] forKey:@"liststate"];
    [params setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageindex"];
    [params setValue:[NSString stringWithFormat:@"%d", pageSize] forKey:@"pagesize"];
    
    // 手机号找回必须只穿userkey
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/car/getcarinfolist_new.ashx"] params:params method:([AMCacheManage currentUserType] == UserStylePhone ? HTTPMethodGet3 : HTTPMethodGet2)];
}

/** 更新车辆（仅商家有此功能） */
- (void)updateCarWithcarID:(NSNumber *)carID
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:carID.stringValue forKey:@"carid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/car/updatecar.ashx"] params:params method:HTTPMethodPost4];
}

/** 删除车辆 */
- (void)deleteCarWithcarID:(NSNumber *)carID
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:carID.stringValue forKey:@"carid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/car/deletecar.ashx"] params:params method:([AMCacheManage currentUserType] == UserStylePhone ? HTTPMethodPost4 : HTTPMethodPost1)];
}

/** 标为已售 */
- (void)markCarSaledWithcarID:(NSNumber *)carID
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:carID.stringValue forKey:@"carid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/car/setcarsaled.ashx"] params:params method:([AMCacheManage currentUserType] == UserStylePhone ? HTTPMethodPost4 : HTTPMethodPost1)];
}

/** 车辆操作 */
- (void)carOperate:(CarOperate)operate mCarInfo:(UCCarInfoEditModel *)mCarInfo
{
    switch (operate) {
        case CarOperateSaled:
            [self markCarSaledWithcarID:mCarInfo.carid];
            break;
        case CarOperateDeleted:
            [self deleteCarWithcarID:mCarInfo.carid];
            break;
        case CarOperateUpdate:
            [self updateCarWithcarID:mCarInfo.carid];
            break;
        case CarOperateRelease:
            [self updateCarWithcarID:mCarInfo.carid];
            break;
    }
}

/** 获取商家店铺信息接口 **/
- (void)getDealerInfoWithDealerID:(NSString*)dealerid{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:dealerid forKey:@"userid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/dealer/getmerchantinfo.ashx"] params:params method:HTTPMethodGet];
}


/** 获取商家的保证金信息 **/
- (void)getDealerDepositInfoWithUserKey:(NSString*)userKey{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:userKey forKey:@"userkey"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/dealer/GetBailDealerInfo.ashx"] params:params method:HTTPMethodGet];
}

/** 商家未查看的保证金记录 **/
- (void)getDealerClaimCountWithUserKey:(NSString*)userKey{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:userKey forKey:@"userkey"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/dealer/getbailcount.ashx"] params:params method:HTTPMethodGet];
}

/** 商家保证金明细 **/
- (void)getDealerDepositDetailWithUserKey:(NSString *)userKey{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:userKey forKey:@"userkey"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/dealer/BailMoneyManage.ashx"] params:params method:HTTPMethodGet];
}

/** 获取索赔列表 **/
- (void)getDealerClaimListWithUserKey:(NSString*)userKey claimState:(NSInteger)claimState pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:userKey forKey:@"userkey"];
    [params setValue:[NSString stringWithFormat:@"%d", claimState] forKey:@"claimstate"];
    [params setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageindex"];
    [params setValue:[NSString stringWithFormat:@"%d", pageSize] forKey:@"pagesize"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/dealer/dealerclaim.ashx"] params:params method:HTTPMethodGet];
}

/** 更新保证金投诉记录已看标志 **/
- (void)updateDealerClaimReadStateWithUserKey:(NSString*)userKey carID:(NSNumber*)carid{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:userKey forKey:@"userkey"];
    [params setValue:carid forKey:@"carid"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV40 file:@"/dealer/setbailread.ashx"] params:params method:HTTPMethodPost];
}

///** 个人车辆操作 */
//- (void)personalCarOperate:(CarOperate)operate mCarInfo:(UCCarInfoEditModel *)mCarInfo salePrice:(NSNumber *)salePrice
//{
//    if (operate == CarOperateSaled) {
//        [self markCarSaledWithCarId:mCarInfo.carid salePrice:salePrice];
//    } else if (operate == CarOperateDeleted) {
//        [self deleteCarWithcarID:mCarInfo.carid];
//    }
//}

/** 商家标注销售线索（商家） */
- (void)setSalesLeadsMarkWithTel:(NSString *)mobile mark:(NSString *)mark
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:mobile forKey:@"mobile"];
    [params setValue:mark forKey:@"memo"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathApp file:@"/salesleads/addremark.ashx"] params:params method:HTTPMethodPost1];
}

/** 修改报价信息标志,设为已阅和忽略 */
- (void)setSalesLeadsState:(NSInteger)state mobile:(NSString *)mobile offerids:(NSArray *)offerids
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:mobile forKey:@"mobile"];
    [params setValue:[NSNumber numberWithInteger:state] forKey:@"state"]; //1已阅2忽略
    if (offerids.count > 0) [params setValue:offerids forKey:@"offerids"];
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathApp file:@"/salesleads/changeofferstatusbydealerid.ashx"] params:params method:HTTPMethodPost1];
}

/** 图片下载 */
- (void)downloadImage:(NSString *)url
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self requestWithUrlString:url params:params method:HTTPMethodDown];
}

/** 商家分享 - 添加分享记录 */
- (void)addDealerShare:(DealerShareType)shareType title:(NSString*)title content:(NSString*)content carids:(NSArray*)carids{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSNumber numberWithInt:shareType] forKey:@"type"];
    [params setValue:title forKey:@"title"];
    [params setValue:content forKey:@"content"];
    
    if (shareType == DealerShareTypeCar) {
        NSString *jointStr = [carids componentsJoinedByString:@","];
        [params setValue:jointStr forKey:@"carids"];
    }
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV41 file:@"/dealer/addshare.ashx"] params:params method:HTTPMethodPost4];
}

/** 分享记录列表 */
- (void)getShareHistoriesWithPageIndex:(NSInteger)pageIndex size:(NSInteger)size
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSNumber numberWithInt:pageIndex] forKey:@"pageindex"];
    [params setValue:[NSNumber numberWithInt:size] forKey:@"pagesize"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV41 file:@"/dealer/getsharehistory.ashx"] params:params method:HTTPMethodGet2];
}

/** 十一、商家分享-根据分享ID获取车源分享的车源列表（GET） */
- (void)getShareCarListWithShareID:(NSNumber *)shareID page:(NSInteger)page size:(NSInteger)size
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:shareID forKey:@"shareid"];
    [params setValue:[NSNumber numberWithInt:page] forKey:@"pageindex"];
    [params setValue:[NSNumber numberWithInt:size] forKey:@"pagesize"];
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathAppV41 file:@"/dealer/getsharecarlist.ashx"] params:params method:HTTPMethodGet];
}

/** 商家分享 - 给分享记录添加渠道标识 */
- (void)updateDealerShareWithShareid:(NSNumber *)shareid channelType:(SNSChannelType)channelType{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:shareid forKey:@"shareid"];
    [params setValue:[NSNumber numberWithInt:channelType] forKey:@"channeltype"];
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV41 file:@"/dealer/UpdateShare.ashx"] params:params method:HTTPMethodPost4];
}

/** 商家分享 - 获取可分享车源的列表 */
- (void)getDealerStoreCarsPageIndex:(NSInteger)pageIndex PageSize:(NSInteger)pageSize{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSNumber numberWithInt:pageIndex] forKey:@"pageindex"];
    [params setValue:[NSNumber numberWithInt:pageSize] forKey:@"pagesize"];
    [params setValue:[NSNumber numberWithInt:1] forKey:@"liststate"]; //1在售车、2已售车、3审核中、4未通过、5已过期（分享时只用在售车，1）
    [params setValue:[NSNumber numberWithInt:1] forKey:@"isshare"]; //分享车源时调用等于1，必传
    
    [self requestWithUrlString:[self urlWithHost:hostApp path:pathAppV41 file:@"/car/getcarinfolist_new.ashx"] params:params method:HTTPMethodGet3];
}


/** 限迁标准查询 */
- (void)getEmissionStandardForPid:(NSString*)pid Cid:(NSString*)cid{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:pid forKey:@"pid"];
    [params setValue:cid forKey:@"cid"];
    
    [self requestWithUrlString:[self urlWithHost:hostApps path:pathAppV40 file:@"/norm/getnorm.ashx"] params:params method:HTTPMethodGet2];
}




#pragma mark - requests
/** 图片上传 */
- (void)requestWithUrlString:(NSString *)urlString params:(NSMutableDictionary *)params imageData:(NSData *)data
{
    [params addSignWhitHttpMethod:HTTPMethodPost];
    AMLog(@"URL: %@ \nParams: %@", urlString, params);
    
    //分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    //分界线 --AaB03x
    NSString *MPboundary =  [NSString stringWithFormat:@"--%@", TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary = [NSString stringWithFormat:@"%@--", MPboundary];
    //http body的字符串
    NSMutableString *body = [NSMutableString string];
    //参数的集合的所有key的集合
    NSArray *allKeys = params.allKeys;
    for (NSString *key in allKeys) {
        //添加分界线，换行
        [body appendFormat:@"%@\r\n", MPboundary];
        //添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
        //添加字段的值
        [body appendFormat:@"%@\r\n", [params objectForKey:key]];
    }
    
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //声明pic字段，文件名为boris.png
    [body appendFormat:@"Content-Disposition: form-data; name=\"imagefile\"; filename=\"release_car.jpg\"\r\n"];
    //声明上传文件的格式
    [body appendFormat:@"Content-Type: image/png\r\n\r\n"];
    
    //声明结束符：--AaB03x--
    NSString *end = [NSString stringWithFormat:@"\r\n%@", endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData = [NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将image的data加入
    [myRequestData appendData:data];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    if ([self initUrlConnection]) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        request.timeoutInterval = 60;
        NSString *content = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", TWITTERFON_FORM_BOUNDARY];
        [request setValue:content forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:myRequestData];
        [request setHTTPMethod:@"POST"];
        
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        indicatorNum++;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
    }
}

- (void)requestWithUrlString:(NSString *)urlString params:(NSMutableDictionary *)params method:(HTTPMethod)method
{
    if (([params objectForKey:@"gearboxid"] && [[params objectForKey:@"gearboxid"] integerValue]==0) || ([params objectForKey:@"levelid"]&&[[params objectForKey:@"levelid"] integerValue] == 0) || [params objectForKey:@"mileageregion"]) {
    }
    
    /** 添加全局渠道标识 **/
    [params setValue:[AppDelegate sharedAppDelegate].strChannel forKey:@"channelid"];
    
    // 有关个人订阅接口没有deviceid时，需要deviceid
    if (((method == HTTPMethodPost1 || method == HTTPMethodGet2) && [AMCacheManage currentUserType] == UserStyleNone && [AMCacheManage currentDeviceid] <= 0) || (method == HTTPMethodPost3 && [AMCacheManage currentDeviceid] <= 0)) {
        
        APIHelper *apiDeviceid = [[APIHelper alloc] init];
        __weak APIHelper *apiDevice = apiDeviceid;
        
        [apiDevice setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
            if (error) {
                [self noticeFinished:[NSError errorWithDomain:ConnectionTextDeviceidError code:ConnectionStatusNot userInfo:nil]];
                return;
            }
            if (apiHelper.data.length > 0) {
                BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
                if (mBase) {
                    NSInteger deviceid = [[mBase.result objectForKey:@"deviceid"] integerValue];
                    if (deviceid > 0 && [AMCacheManage currentDeviceid] != deviceid) {
                        // 存储deviceid
                        [AMCacheManage setDeviceid:deviceid];
                        [self requestWithUrlString:urlString params:params method:method];
                        AMLog(@"二次获取deviceid成功！");
                    }
                    if ([AMCacheManage currentPushStatus] == ConfigPushStatusNOTSET){
                        // 注册推送
                        if (IOS8_OR_LATER) {
                            [[UIApplication sharedApplication] registerForRemoteNotifications];
                            
                        //        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory  alloc] init] ;
                            
                            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
                            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                        }
                        else{
                            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
                        }
                    }
                }
            }
        }];
        [apiDeviceid registDeviceWithPid:nil cid:nil];
    }
    else {
        // Post 和 Get1 模式下加入 UDID
        [params addSignWhitHttpMethod:method];
        AMLog(@"\n\nURL地址:\n%@\n参数:\n%@", urlString, params);
        
        if ([self initUrlConnection]) {
            NSMutableURLRequest *request = nil;
            switch (method) {
                case HTTPMethodGet:
                case HTTPMethodGet1:
                case HTTPMethodGet2:
                case HTTPMethodGet3:
                    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, [params toContent:YES]]]];
                    [request setHTTPMethod:@"GET"];
                    [request addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
                    break;
                case HTTPMethodDown:
                    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                    [request setValue:@"http://club.autohome.com.cn" forHTTPHeaderField:@"Referer"];
                    break;
                case HTTPMethodDown1:
                    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                    [request setValue:@"http://www.che168.com" forHTTPHeaderField:@"Referer"];
                    break;
                case HTTPMethodPost:
                case HTTPMethodPost1:
                case HTTPMethodPost2:
                case HTTPMethodPost3:
                case HTTPMethodPost4:
                    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                    [request setHTTPMethod:@"POST"];
                    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                    NSString *content = [params toContent:YES];
                    [request addValue:[NSString stringWithFormat:@"%d", [content length]] forHTTPHeaderField:@"Content-Length"];
                    [request setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
                    break;
            }
            request.timeoutInterval = 60;
            AMLog(@"\n\nRequest地址:\n%@\n", request);

            _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            indicatorNum++;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
    }
}


#pragma mark - NSURLConnectionDelegate
//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
//{
//    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
//{
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
//        [[challenge sender]  useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//        [[challenge sender]  continueWithoutCredentialForAuthenticationChallenge: challenge];
//    }
//}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    //    AMLog(@"totalBytesWritten: %d totalBytesExpectedToWrite: %d", totalBytesWritten, totalBytesExpectedToWrite);
    [self noticeSend:bytesWritten size:totalBytesWritten total:totalBytesExpectedToWrite];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _total = 0;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if(httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
        _total = [[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue];
        AMLog(@"Content-Length: %lld", _total);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
    [self noticeReceive:_data.length];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    AMLog(@"FailError: %@", error);
    
    NSError *err = nil;
    // 网络请求超时
    if (error.code == -1001)
        err = [NSError errorWithDomain:ConnectionTextTimeout code:ConnectionStatusTimeout userInfo:error.userInfo];
    // 服务器错误
    else
        err = [NSError errorWithDomain:ConnectionTextError code:ConnectionStatusError userInfo:error.userInfo];
    // 检测是否网络不可用
    if (![APIHelper isNetworkAvailable])
        err = [NSError errorWithDomain:ConnectionTextNot code:ConnectionStatusNot userInfo:error.userInfo];
    // 通知请求已完成
    [self noticeFinished:err];
    // 取消请求
    [self cancel:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    AMLog(@"\n\n***请求结果:\n%@\n***结束\n\n", [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding]);
    // 通知已完成
    [self noticeFinished:nil];
    // 取消连接
    [self cancel:NO];
}

/* 取消连接 */
- (void)cancel
{
    [self cancel:YES];
}

/* 取消连接 是否通知 */
- (void)cancel:(BOOL)isNotice{
    // 释放资源
    if(_connection){
        // 执行通知
        if (isNotice)
            [self noticeFinished:[NSError errorWithDomain:ConnectionTextCancel code:ConnectionStatusCancel userInfo:nil]];
        
        // 设置状态菊花状态
        indicatorNum--;
        if(indicatorNum < 1)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        // 取消连接
        [_connection cancel];
        _connection = nil;
    }
    _data = nil;
    _tag = nil;
}

/* 是否正在请求中 */
- (BOOL)isConnecting{
    return _connection ? YES : NO;
}

/* 通知请求已完成 */
- (void)noticeFinished:(NSError *)error
{
#if NS_BLOCKS_AVAILABLE
    if(_blockFinish) {
        _blockFinish(self, error);
        _blockFinish = nil;
    }
    if (_blockReceive)
        _blockReceive = nil;
    if (_blockSend)
        _blockSend = nil;
#endif
}

/* 通知请求中 */
- (void)noticeReceive:(unsigned long long)size
{
#if NS_BLOCKS_AVAILABLE
    if(_blockReceive)
        _blockReceive(size, _total);
#endif
}

/* 通知发送中 */
- (void)noticeSend:(NSInteger)written size:(NSInteger)size total:(NSInteger)total
{
#if NS_BLOCKS_AVAILABLE
    if(_blockSend)
        _blockSend(written, size, total);
#endif
}

- (void)dealloc
{
    AMLog(@"dealloc...");
}

@end

@implementation NSMutableDictionary (HTTP)

/** 添加必填参数 */
- (NSMutableDictionary *)addSignWhitHttpMethod:(HTTPMethod)method
{
    BOOL isNeed = (method == HTTPMethodPost || method == HTTPMethodGet1);
    BOOL isAttention = (method == HTTPMethodPost1 || method == HTTPMethodGet2 || method == HTTPMethodGet3 || method == HTTPMethodPost3 || method == HTTPMethodPost4);
    
    [self setValue:@"app.iphone" forKey:@"_appid"]; //2scapp.ios
    [self setValue:APP_VERSION forKey:@"appversion"];
    
    if (isNeed)
        [self setValue:[[NSString stringWithFormat:@"%@|%f", [OMG openUDID], [[NSDate date] timeIntervalSince1970]] encrypt3DES] forKey:@"udid"];
    if (isAttention) {
        // 商家 & 个人
        UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
        if (method != HTTPMethodPost3 && mUserInfo.userkey.length > 0) {
            [self setValue:mUserInfo.userkey forKey:@"userkey"];
        }
        // 设备
        else if (method != HTTPMethodGet3 && method != HTTPMethodPost4){
            NSString *deviceid = [NSString stringWithFormat:@"%d",[AMCacheManage currentDeviceid]];
            [self setValue:[[NSString stringWithFormat:@"%@|%f|%@", [OMG openUDID], [[NSDate date] timeIntervalSince1970], deviceid] encrypt3DES] forKey:@"udid"];
        }
    }
    
    [self setValue:[self toSorted] forKey:@"_sign"];
    
    return self;
}

/** 参数排序 */
- (NSString *)toSorted
{
    NSString *APPKEY = @"com.che168.www";
    NSMutableString *str = [[NSMutableString alloc]initWithString:APPKEY];
    NSArray *keys = [self allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    for (NSString *key in sortedArray) {
        
        //        if ([key isEqualToString:@"_appid"] || [key isEqualToString:@"udid"] || [key isEqualToString:@"appversion"])
        //            continue;
        
        NSString *value=[self objectForKey:key];
        [str appendFormat:@"%@%@",key,value];
    }
    [str appendString:APPKEY];
    return str.md5;
}

- (NSString *)toContent:(BOOL)isEncode;
{
    if (self.count > 0) {
        NSMutableString *str = [NSMutableString string];
        NSArray *allKeys = self.allKeys;
        for (NSString *key in allKeys) {
            NSString *value = [NSString stringWithFormat:@"%@", [self objectForKey:key]];
            if (key && value) {
                [str appendFormat:@"&%@=%@", isEncode ? [key encodeURL] : key, isEncode ? [value encodeURL] : value];
            }
        }
        if (str.length > 0)
            return [str substringFromIndex:1];
        else
            return nil;
    }
    
    return nil;
}

@end

