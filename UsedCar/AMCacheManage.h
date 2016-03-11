//
//  AMCacheManage.h
//  UsedCar
//
//  Created by Alan on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCAreaMode.h"
#import "UCFilterModel.h"
#import "UserInfoModel.h"
#import "UCCarInfoEditModel.h"
#import "UCFavoritesModel.h"

// cache
#define kCacheImageDir                 @"Image"
#define kCacheDataDir                  @"Data"

#define kCacheArea                     @"kCacheArea"
#define kCacheHistoryFilter            @"kCacheHistoryFilter"
#define kCacheUserInfo                 @"kCacheUserInfo"
#define kCachePersonalUserInfo         @"kCachePersonalUserInfo"
#define kCacheCarDetailInfoModel       @"kCacheCarDetailInfoModel"

#define kCacheCarInfoEditDrafts        @"kCacheCarInfoEditDrafts"
#define kCacheCompareInfo              @"kCacheCompareInfo"
#define kCallRecord                    @"kCallRecord"
#define kBuyCarListHaveReadArray       @"kBuyCarListHaveReadArray"      // 买车车源列表
#define kSearchHistory                 @"kSearchHistory"                //搜索历史

#define kConfigIsUsed                  @"kConfigIsUsed"
#define kConfigVersion                 @"kConfigVersion"
#define kConfigIsImportOldFavourates   @"kConfigIsImportOldFavourates"
#define kConfigOrder                   @"kConfigOrder"
#define kConfigUserType                @"kConfigUserType"
#define kConfigIsShowComparSlidingTips @"kConfigIsShowComparSlidingTips"
#define kConfigPushStatus              @"kConfigPushStatus"             //0关闭 1打开
#define kConfigVersionStartNumber      @"kConfigVersionStartNumber"     //当前版本启动次数, 用于求赞提示框出现逻辑
#define kConfigAppState                @"kConfigAppState"               //app 是否从进入后台的标记 0 没有 1 进入过

#define kGuideHomeView                 @"kGuideHomeView"                //首页引导图 key
#define kGuideHomeLastViewVersion      @"kGuideHomeLastViewVersion"
#define kGuideFilterView               @"kConfigFilterViewGuide"        //筛选也引导图 key
#define kGuideFilterLastViewVersion    @"kGuideHomeLastViewVersion"
#define kGuideStartIMView              @"kConfigStartIMViewGuide"       //详情页 Start IM 的蒙层引导

#define kPushDeviceid                  @"kPushDeviceid"
#define kToken                         @"kToken"

#define kLastRefreshUserInfoDate        @"kLastRefreshUserInfoDate"

/** 个人同步 */
#define kSYNCclientCar                  @"kSYNCclientCar"
#define kSYNCclientCarNeeded            @"kSYNCclientCarNeeded"
#define kSYNCclientSubsription          @"kSYNCclientSubsription"
#define kSYNCclientSubsriptionNeeded    @"kSYNCclientSubsriptionNeeded"
#define kSYNCclientFavorites            @"kSYNCclientFavorites"
#define kSYNCclientFavoritesNeeded      @"kSYNCclientFavoritesNeeded"

@class UCCarDetailInfoModel;

typedef NS_ENUM(NSInteger, ConfigPushStatus) {
    ConfigPushStatusNOTSET = 0,
    ConfigPushStatusON     = 1,
    ConfigPushStatusOFF    = 2,
};

@interface AMCacheManage : NSObject

/** 当前版本号 */
+ (NSString *)currentConfigVersion;
+ (void)setConfigVersion:(NSString *)version;

/** 是否已经使用过本应用(开机引导) */
+ (BOOL)currentIsUsed;
+ (void)setCurrentIsUsed:(BOOL)isUsed;

/** 是否已显示过对比滑动引导 */
+ (BOOL)currentIsShowComparSlidingTips;
+ (void)setCurrentIsShowComparSlidingTips:(BOOL)isShowComparSlidingTips;

/** 设置token */
+ (void)setToken:(NSString *)token;
+ (NSString *)currentToken;

/** 设置Push deviceid */
+ (void)setDeviceid:(NSInteger)deviceid;
+ (NSInteger)currentDeviceid;

/** 获取缓存数据库路径 */
+ (NSString *)cacheDbPathForResource:(NSString *)dbName;

/** 销售线索拨打记录 */
+ (NSMutableArray *)currentCallRecord;
/** 清空销售线索拨打记录 */
+ (void)deleteCallRecord;
+ (void)addCurrentCallRecord:(NSString *)mobile;
/** 是否已经导入旧收藏数据 */
+ (BOOL)currentIsImportOldFavourates;
+ (void)setCurrentIsImportOldFavourates:(BOOL)isImportOldFavourates;
/** 最后浏览 */
+ (UCCarDetailInfoModel *)currentCarDetailInfoModel;
+ (BOOL)setCurrentCarDetailInfoModel:(UCCarDetailInfoModel *)mCarDetailInfo;
/** 当前地区 */
+ (UCAreaMode *)currentArea;
+ (BOOL)setCurrentArea:(UCAreaMode *)mArea;
/** 当前排序 */
+ (NSString *)currentOrder;
+ (void)setCurrentOrder:(NSString *)order;
/** 当前用户类别 */
+ (UserStyle)currentUserType;
+ (void)setCurrentUserType:(UserStyle)userType;
/** 当前历史筛选 */
+ (NSMutableArray *)currentHistoryFilter;
+ (BOOL)setCurrentHistoryFilter:(NSMutableArray *)mFilters;
/** 当前用户信息 */
+ (UserInfoModel *)currentUserInfo;
+ (BOOL)setCurrentUserInfo:(UserInfoModel *)mUserInfo;
///** 当前个人用户信息 */
//+ (UserInfoModel *)currentPersonalUserInfo;
//+ (BOOL)setCurrentPersonalUserInfo:(UserInfoModel *)mUserInfo;
/** 当前发车未填完数据 */
+ (NSMutableArray *)currentCarInfoEditDrafts;
+ (BOOL)setCurrentCarInfoEditDrafts:(NSMutableArray *)mCarInfoEdit;
/** 收藏 */
+ (BOOL)saveCarToFavourite:(UCFavoritesModel *)mFavorite;
+ (BOOL)deleteCarFromFavourite:(NSString *)carid;
+ (NSArray *)currentFavourites;
+ (BOOL)existInFavourites:(NSString *)carid;
/** 对比 */
+ (BOOL)setCurrentCompareInfo:(NSMutableArray *)mFilters;
+ (NSMutableArray *)currentCompareInfo;
/** 添加买车车源列表已读痕迹 */
+ (BOOL)addBuyCarListArray:(NSString *)addCarID;
+ (NSMutableArray *)currentBuyCarListArray;
/** 当前版本启动次数 */
+ (NSInteger)currentVersionStartNumber;
+ (void)setCurrentVersionStartNumber:(NSInteger)number;

/* 车辆概况数量操作 */
+ (void)reduceCarListState:(NSInteger)reduceState plusCarListState:(NSInteger)plusState;

/**
 *  保存搜索记录列表
 *
 *  @param array 记录列表
 *
 *  @return  YES 成功保存 NO 保存失败
 */
+(BOOL)setSearchHistory:(NSArray*)array;

/**
 *  读取搜索记录列表
 *
 *  @return 搜索记录列表 NSArray
 */
+(NSArray *)getSearchHistory;

/**
 *  清除搜索记录
 *
 *  @return  YES 清除成功 NO 清除失败
 */
+(BOOL)removeSearchHistory;

/**
 *  获取当前 PUSH 保存的状态
 *
 *  @return 0 关闭 1 打开
 */
+(NSInteger)currentPushStatus;

/**
 *  更新 Push 的状态
 *
 *  @param status ConfigPushStatusON(0) 关闭 ConfigPushStatusON(1) 打开
 *
 *  @return 保存是否成功的标识
 */
+(BOOL)setPushStatus:(NSInteger)status;

/**
 *  软件是否进如果后台的标记位
 *
 *  @return 0 没有 1 有
 */
+(NSInteger)currentAppState;

/**
 *  软件进入后台后置1, 在唤醒以后更新的数据置0
 *
 *  @param status 0 没有 1 有
 */
+(void)setAppState:(NSInteger)status;

+(BOOL)setLastRefreshUserInfoTime:(NSDate *)date;
+(NSDate *)currentLastRefreshUserInfoTime;

/** IM 聊天页引导状态标识 **/
+(NSInteger)currentConfigStartIMGuideStatus;
+(BOOL)setConfigStartIMGuideStatus:(NSInteger)status;

/** 首页筛选页的引导状态标识 **/
+(NSInteger)currentConfigFilterGuideStatus;
+(BOOL)setConfigFilterGuideStatus:(NSInteger)status;

/** 首页引导状态标识 **/
+(NSInteger)currentConfigHomeGuideStatus;
+(BOOL)setConfigHomeGuideStatus:(NSInteger)status;

/** 记录筛选页引导的上次查看版本 **/
+(NSInteger)currentConfigFilterGuideLastViewVersion;
+(BOOL)setConfigFilterGuideLastViewVersion:(NSInteger)version;
/** 记录首页引导的上次查看版本 **/
+(NSInteger)currentConfigHomeGuideLastViewVersion;
+(BOOL)setConfigHomeGuideLastViewVersion:(NSInteger)version;


/** 图片缓存 */
+ (BOOL)saveImageWhitName:(NSString *)name data:(NSData *)data;
+ (NSData *)loadImageWhitName:(NSString *)imageName;
+ (BOOL)replaceImageName:(NSString *)target withString:(NSString *)replacement;
+ (BOOL)isExistsImage:(NSString *)name;
+ (CGFloat)imageCacheSize;

/** 清除指定目录下的全部缓存 */
+ (BOOL)clearAllCacheWhitDirName:(NSString *)dirName;

///** 读取缓存 */
//+ (NSData *)loadCacheWithDirName:(NSString *)dirName fileName:(NSString *)fileName;
///** 保存缓存 */
//+ (BOOL)saveCacheWithDirName:(NSString *)dirName fileName:(NSString *)fileName data:(NSData *)data;
///** 清除全部缓存 */
//+ (BOOL)clearAllCacheWhitDirName:(NSString *)dirName;
/** 清楚指定类型的缓存 */
+ (BOOL)clearCacheWithDirName:(NSString *)dirName fileName:(NSString *)fileName;
///** 获取缓存文件路径 */
//+ (NSString *)getCacheFilePath:(NSString *)dirName fileName:(NSString *)fileName;
///** 获取缓存目录路径 */
//+ (NSString *)getCacheDirPath:(NSString *)dirName;
///** 单个文件的大小 */
//+ (long long)fileSizeAtPath:(NSString*)filePath;
///** 遍历文件夹获得文件夹大小，单位M */
//+ (float)dirSizeAtPath:(NSString*)dirPath;

/** 查询表 */
+ (NSArray *)selectFrome:(NSString *)tableName where:(NSString *)where equalValue:(NSString *)value;

+ (NSArray *)fuzzySearchCar:(NSString *)name;

#pragma mark - 个人同步
/** 同步个人车车源 */
+ (BOOL)SYNCclientCarSuccess;
+ (void)setSYNCclientCarSuccess:(BOOL)success;
+ (BOOL)SYNCclientCarNeeded;
+ (void)setSYNCclientCarNeeded:(BOOL)needed;

/** 同步个人订阅 */
+ (BOOL)SYNCclientSubscriptionSuccess;
+ (void)setSYNCclientSubscriptionSuccess:(BOOL)success;
+ (BOOL)SYNCclientSubscriptionNeeded;
+ (void)setSYNCclientSubscriptionNeeded:(BOOL)needed;

/** 同步个人收藏夹 */
+ (BOOL)SYNCclientFavoritesSuccess;
+ (void)setSYNCclientFavoritesSuccess:(BOOL)success;

/** 是否需要同步个人收藏夹 */
+ (BOOL)SYNCclientFavoritesNeeded;
+ (void)setSYNCclientFavoritesNeeded:(BOOL)needed;

/** 获取缓存文件路径 */
+ (NSString *)getCacheFilePath:(NSString *)dirName fileName:(NSString *)fileName;

@end
