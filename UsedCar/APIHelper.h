//
//  APIHelper.h
//  UsedCar
//
//  Created by Alan on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

#import "BaseModel.h"
#import "UCFilterModel.h"
#import "UCCarInfoEditModel.h"

#if NS_BLOCKS_AVAILABLE
@class APIHelper;
@class UCEvaluationModel;
@class UCRegisterDealerModel;
@class UCRegisterClientModel;
@class UCCarAttenModel;
@class UCPriceModel;

typedef void (^APIFinishBlock)(APIHelper *apiHelper, NSError *error);
typedef void (^APIReceiveBlock)(unsigned long long size, unsigned long long total);
typedef void (^APISendBlock)(NSInteger written, NSInteger size, NSInteger total);
typedef void (^APITestBlock)(void);
#endif


#define ConnectionTextNot @"网络连接失败，请稍后重试"
#define ConnectionTextError @"服务器连接失败，请稍后重试"
#define ConnectionTextCancel @"取消连接"
#define ConnectionTextRepeat @"网络请求取消"
#define ConnectionTextTimeout @"网络请求超时"
#define ConnectionTextDeviceidError @"网络连接错误，请稍后重试…"

typedef enum {
    HTTPMethodGet = 0,
    HTTPMethodGet1,     // 只有 "deviceid"
    HTTPMethodGet2,     // 包括“deviceid” 或 "userkey"
    HTTPMethodGet3,     // 只需要 "userkey"
    HTTPMethodPost,     // 只有 "deviceid"
    HTTPMethodPost1,    // 包括“deviceid” 或 "userkey"
    HTTPMethodPost2,    // 退出登录，不需要deviceid
    HTTPMethodPost3,    // 只需要"deviceid"，不需要"userkey"
    HTTPMethodPost4,    // 只需要 "userkey"
    HTTPMethodDown,
    HTTPMethodDown1,
} HTTPMethod;

typedef enum {
    HostTypeRelease = 0,    //线上发布环境
    HostTypeTest,           //线下测试环境
} HostType;

typedef enum {
    ConnectionStatusNot = -100,     //连接不可用
    ConnectionStatusCancel = -101,  //连接已取消
    ConnectionStatusRepeat = -102,  //连接重复
    ConnectionStatusTimeout = -103, //连接超时
    ConnectionStatusError = -104,  //服务器错误
} ConnectionStatus;

typedef enum {
    CarOperateSaled = 1990, // 标记已售
    CarOperateDeleted, // 删除
    CarOperateUpdate, // 更新
    CarOperateRelease,//重新发车
} CarOperate;

typedef enum : NSUInteger {
    DealerShareTypeStore = 10,  // 10 店铺分享
    DealerShareTypeCar = 20,    // 20 车源分享
} DealerShareType; //商家分享

typedef enum : NSUInteger {
    SNSChannelTypeNone          = 0, 
    SNSChannelTypeWeibo         = 1, //微博
    SNSChannelTypeQZone         = 2, //QZone
    SNSChannelTypeTencentWeibo  = 3, //腾讯微博
    SNSChannelTypeWeChat        = 4, //微信好友
    SNSChannelTypeWeChatMoments = 5, //微信朋友圈
    SNSChannelTypeRenRen        = 6, //人人
    SNSChannelTypeEmail         = 7, //邮件
    SNSChannelTypeSMS           = 8, //短信
} SNSChannelType;

@interface APIHelper : NSObject <NSURLConnectionDelegate> {
    unsigned long long _total;
#if NS_BLOCKS_AVAILABLE
    APIFinishBlock _blockFinish;     // 请求完成执行代码块
    APIReceiveBlock _blockReceive;   // 请求中执行代码块
    APISendBlock _blockSend;         // 发送数据中执行代码块
#endif
}

@property (nonatomic, retain) id tag;
@property (nonatomic, readonly) NSURLConnection *connection;
@property (nonatomic, readonly) NSMutableData *data;
//#if NS_BLOCKS_AVAILABLE
//@property (nonatomic, copy) APIFinishBlock blockFinish;     // 请求完成执行代码块
//@property (nonatomic, copy) APIReceiveBlock blockReceive;   // 请求中执行代码块
//@property (nonatomic, copy) APISendBlock blockSend;        // 发送数据中执行代码块
//#endif

/** 设置服务器类型 */
+ (void)setHostType:(HostType)hostType;
/** 网络是否正常 */
+ (BOOL)isNetworkAvailable;
/** 当前网络状态 */
+ (NetworkStatus)currentNetworkStatus;
/** 当前网络名称 */
+ (NSString *)currentNetworkStatusName;

#if NS_BLOCKS_AVAILABLE
/** 请求完成执行代码块 */
- (void)setFinishBlock:(APIFinishBlock)blockFinish;
/** 请求中执行代码块 */
- (void)setReceiveBlock:(APIReceiveBlock)blockReceive;
/** 发送数据中执行代码块 */
- (void)setSendBlock:(APISendBlock)blockSend;
#endif

/** 取消链接 */
- (void)cancel;
/** 是否正在请求中 */
- (BOOL)isConnecting;

/** 提交 Push Token */
- (void)submitToken:(NSString *)token;
/** 注册Push User */
- (void)registDeviceWithPid:(NSNumber *)pid cid:(NSNumber *)cid;
/** 根据用户id注册push */
- (void)registPush;
/** 注销push */
- (void)logoutPush;
/** 获得订阅总数 */
- (void)getAttentionCount;
/** 获取个人订阅列表 */
- (void)getAttentionCars;
/** 更新查看订阅列表时间 */
- (void)updatecarsLastdateWithAttentionid:(NSNumber *)attentionid;
/** 添加订阅列表 */
- (void)addAttentionWithAttenModel:(UCCarAttenModel *)mAttention;
/** 修改订阅 */
- (void)editAttentionWithID:(NSNumber *)ID attenModel:(UCCarAttenModel *)mAttention;
/** 删除订阅车源 */
- (void)deleteConcernCars:(NSNumber *)attentionID;
/** 设置推送的时间段 */
- (void)setPushTime:(BOOL)isOn starttime:(NSInteger)starttime endtime:(NSInteger)endtime allowperson:(NSString *)allowperson allowsystem:(NSString *)allowsystem;
/** 获取验证码 */
- (void)getTheVerificationCode:(NSString *)mobile type:(NSNumber *)type;
/** 提交车源状态 */
- (void)postTheSourceState:(NSNumber *)carId price:(NSString *)price userName:(NSString *)userName userMobile:(NSString *)userMobile mcode:(NSString *)mcode;
/** 根据（手机识别码或者商家id）和上次截止时间获取当前时间之后所有车源的所有报价信息的总数 */
- (void)getSaleTotalNumber:(NSString *)lastDate;

/** 搜索车源信息 */
- (void)searchCarWithKeyword:(NSString *)keyword pagesize:(NSNumber *)pagesize pageindex:(NSNumber *)pageindex areaid:(NSString *)areaid pid:(NSString *)pid cid:(NSString *)cid dealerid:(NSNumber *)dealerid filter:(UCFilterModel *)mFilter orderby:(NSString *)orderby lastUpdate:(NSString*)lastupdate;

/** 搜索车源信息 没有 last update */
- (void)searchCarWithKeyword:(NSString *)keyword pagesize:(NSNumber *)pagesize pageindex:(NSNumber *)pageindex areaid:(NSString *)areaid pid:(NSString *)pid cid:(NSString *)cid dealerid:(NSNumber *)dealerid filter:(UCFilterModel *)mFilter orderby:(NSString *)orderby;
/** 公共车辆详情 */
- (void)getCarInfo:(NSNumber *)carid;
/** 获取详情pv */
- (void)getCarPVWithCarID:(NSNumber *)carID;
/** 增加详情pv */
- (void)setCarPVWithCarID:(NSNumber *)carID;
/** 详情页参考价 */
- (void)getCarDetailPriceWithPriceModel:(UCPriceModel *)mPrice;
/** 卖车参考价 */
- (void)getCarSalePriceWithPriceModel:(UCPriceModel *)mPrice;

/** 商家名称是否有效 */
- (void)checkDealerInfo:(NSInteger)checktype checkvalue:(NSString *)checkvalue;
/** 商家用户注册 */
- (void)registerDealer:(UCRegisterDealerModel *)mRegister;
/** 个人用户注册 */
- (void)registerClient:(UCRegisterClientModel*)mRegister;
/** 个人注册发送手机验证码 */
- (void)registerClientSendVerifyCodeByUserName:(NSString*)username mobile:(NSString*)mobile;

/** 用户登录 */
- (void)userLogin:(NSString *)user pass:(NSString *)pass;
/** 个人登录 */
- (void)clientLogin:(NSString *)user pass:(NSString *)pass code:(NSString *)code;
/** 个人登录刷新验证码 **/
- (void)getLoginVerifyCode;
/** 手机找回车源 获取验证码 */
- (void)getValidateCodeByMobile:(NSString*)mobile;
/** 手机找回车源 */
- (void)carRetrieveByMobile:(NSString*)mobile validateCode:(NSString*)code;
/** 用户退出 */
- (void)userLogout;

/** 个人同步车源 */
- (void)clientSyncCar;
/** 个人同步订阅 */
- (void)clientSyncSubscription;
/** 个人同步收藏 */
- (void)clientSyncFavoritesWithCarIDs:(NSArray *)carids;

/** 图片下载 */
- (void)downloadImage:(NSString *)url;
/** 上传图片(商家) */
- (void)uploadImage:(NSString *)userKey imageData:(NSData *)data;
/** 上传图片(个人) */
- (void)uploadImageNew:(NSData *)data;

/** 获取商家店铺信息 */
- (void)getBusinessInfo:(NSNumber *)userid;

/** 获取商家信息 */
- (void)getUserInfo;
/** 获取状态列表车辆列表 */
- (void)getCarinfoListWithListState:(NSInteger)listState pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;
/** 同步销售线索通话记录 */
- (void)uploadCallRecords;
/** 发车 */
- (void)releaseCarWithCarInfoEditModel:(UCCarInfoEditModel *)mCarInfoEdit;
/** 修改车 */
- (void)editCarWithCarInfoEditModel:(UCCarInfoEditModel *)mCarInfoEdit;
/** 车辆操作 */
- (void)carOperate:(CarOperate)operate mCarInfo:(UCCarInfoEditModel *)mCarInfo;

/** 获取商家店铺信息接口 **/
- (void)getDealerInfoWithDealerID:(NSString*)dealerid;
/** 获取商家的保证金信息 **/
- (void)getDealerDepositInfoWithUserKey:(NSString*)userKey;

/**
 *  本接口获取的是商家保证金, 未查看的 未完结 & 已完结 的总数
 *
 *  @param userKey 商家的 userkey
 */
- (void)getDealerClaimCountWithUserKey:(NSString*)userKey;
/** 商家保证金明细 **/
- (void)getDealerDepositDetailWithUserKey:(NSString *)userKey;
/** 获取索赔列表 **/
- (void)getDealerClaimListWithUserKey:(NSString*)userKey claimState:(NSInteger)claimState pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;
/** 更新保证金投诉记录已看标志 **/
- (void)updateDealerClaimReadStateWithUserKey:(NSString*)userKey carID:(NSNumber*)carid;
/** 商家标注销售线索（商家） */
- (void)setSalesLeadsMarkWithTel:(NSString *)mobile mark:(NSString *)mark;
/** 修改报价信息标志,设为已阅和忽略 */
- (void)setSalesLeadsState:(NSInteger)state mobile:(NSString *)mobile offerids:(NSArray *)offerids;
/** 商家爱销售代表添加 */
- (void)addSalesPerson:(SalesPersonModel *)mSalesPerson;

/** 车型增量 */
- (void)getNewCars:(NSNumber *)lastproductid;

/*购车常识文章列表接*/
- (void)buyCarMustLook:(NSNumber *)charactersnum pagesize:(NSNumber *)pagesize pageindex:(NSNumber *)pageindex;
/*获取文章详情*/
- (void)getArticleDetail:(NSString *)articleId;

/** 估价 */ //type:0表示买车估价 1表示卖车估价
- (void)getEvaluetionPrice:(UCEvaluationModel *)mEvaluation type:(NSNumber *)type;
/** 推荐商家 */
- (void)getRecommendedBusinesses:(UCEvaluationModel *)mEvaluation;

/** 新车配置 */
- (void)getNewCarConfigure:(NSNumber *)productid;

/** 根据商家id获取不同状态下的获取销售线索列表（根据用户最新排序） */
- (void)getSalesLeadsListWithListstate:(NSInteger)state pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;
/** 根据商家id和用户手机号获取用户订阅的在售、已售、已过期车辆信息 */
- (void)getUserAttentionCarListWithMobile:(NSString *)mobile state:(NSNumber *)state;
/** 获得商家销售代表 */
- (void)getDealerSalesPersonListWithListate:(NSInteger)liststate title:(NSInteger)title;

/** 获取活动信息 */
- (void)getActivityInfo:(NSString *)pid cid:(NSString *)cid;

/** 获取举报信息 */
- (void)getReportInfo:(NSNumber *)carId userName:(NSString *)userName type:(NSNumber *)type brandid:(NSNumber *)brindid seriesid:(NSNumber *)seriesid specid:(NSNumber *)specid context:(NSString *)context mobile:(NSString *)mobile;

- (void)openReputation:(NSString *)specsId;

/**
 *  统计-拨打电话或发送短信时统计（GET）
 *
 *  @param carid    id
 *  @param type     统计类型（10车源详情处拨打电话，20车源详情处发送短信，30商家店铺时拨打电话）
 *  @param dealerid 商家id,Type=30时必传
 */
- (void)callstatisticsEventWithCarID:(NSNumber *)carid type:(NSNumber *)type dealerid:(NSNumber *)dealerid;

/** 热门品牌 */
- (void)getHotBrands;

/** 收藏 0删除, 1收藏*/
-(void)addOrDeleteFavorite:(NSNumber *)carID toType:(NSInteger)type;
/** 收藏列表 */
- (void)getFavoritesListPageIndex:(NSInteger)pageIndex size:(NSInteger)size;
/** 个人登录时判断车源是否收藏收藏（GET） */
- (void)isFavoriteCar:(NSNumber *)carID;


/** 商家分享 - 添加分享记录 */
- (void)addDealerShare:(DealerShareType)shareType title:(NSString*)title content:(NSString*)content carids:(NSArray*)carids;
/** 商家分享 - 给分享记录添加渠道标识 */
- (void)updateDealerShareWithShareid:(NSNumber *)shareid channelType:(SNSChannelType)channelType;
/** 商家分享 - 获取可分享车源的列表 */
- (void)getDealerStoreCarsPageIndex:(NSInteger)pageIndex PageSize:(NSInteger)pageSize;

/** 分享记录列表 */
- (void)getShareHistoriesWithPageIndex:(NSInteger)pageIndex size:(NSInteger)size;
/** 十一、商家分享-根据分享ID获取车源分享的车源列表（GET） */
- (void)getShareCarListWithShareID:(NSNumber *)shareID page:(NSInteger)page size:(NSInteger)size;

/** 限迁标准查询 */
- (void)getEmissionStandardForPid:(NSString*)pid Cid:(NSString*)cid;

#pragma mark - IM
/** 获取IM身份验证的验证码 */
- (void)getVerifyCode:(NSString *)mobile type:(NSNumber *)type;
/** 验证IM身份 */
- (void)verifyIMWithName:(NSString *)name mobile:(NSString *)mobile code:(NSString *)code salesid:(NSNumber *)salesid;
/** 获取 IM 服务器信息 */
- (void)getIMServerInfo;
/** IM-注册在线咨询用户（POST） */
//<<<<<<< .mine
//- (void)registerIMwithMobileName:(NSString*)mobile nickname:(NSString*)nickname dealerID:(NSString *)dealerID salesID:(NSString*)salesID validcode:(NSString*)validCode;
//=======
- (void)registerIMwithMobileName:(NSString*)mobile nickname:(NSString*)nickname memberID:(NSString*)memberID dealerID:(NSString*)dealerID salesID:(NSString*)salesID validcode:(NSString*)validCode;
//>>>>>>> .r60347
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
                     typeid:(NSString*)typeID;
/** IM-获取联系人信息(Get) */
- (void)getIMLinkByNameFrom:(NSString*)namefrom nameTo:(NSString*)nameTo memberID:(NSString*)memberID dealerID:(NSString*)dealerID salesID:(NSString*)salesID;
/** IM-获取联系人列表 */
- (void)getimlinkerlistWithMyName:(NSString *)name page:(NSNumber *)page index:(NSNumber *)index;
///** IM-屏蔽或解除屏蔽联系人（GET） */
//- (void)blockIMContactBlockType:(BOOL)block namefrom:(NSString*)namefrom nameto:(NSString*)nameto;

#pragma mark - 固定 URL
/** 成交还礼 **/
+ (NSString*)getToolExchangeWebURL;
/** 成交还礼帮助 **/
+ (NSString*)getToolExchangeHelpWebURL;
/** 索赔陪还礼 **/
+ (NSString*)getToolClaimWebURL;
/** 索赔还礼帮助 **/
+ (NSString*)getToolClaimHelpWebURL;

/** 国标查询结果 */
+ (NSString*)getShareEmissionResult;
/** 国标地区页 */
+(NSString*)getShareEmissionArea;
/** 店铺分享 */
+(NSString*)getShareDealerStore;
/** 车源分享 */
+(NSString*)getShareDealerCar;
/** 商家帮助 */
+(NSString *)getSaleHelp;

@end

//typedef enum {
//    ParamsSignModeNoUdid = 0,
//    ParamsSignModeUdidEncrypt,
//} ParamsSignMode;

@interface NSMutableDictionary (HTTP)

- (NSMutableDictionary *)addSignWhitHttpMethod:(HTTPMethod)method;
- (NSString *)toSorted;
- (NSString *)toContent:(BOOL)isEncode;

@end
