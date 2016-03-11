//
//  AMCacheManage.m
//  UsedCar
//
//  Created by Alan on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "AMCacheManage.h"
#import "NSString+Util.h"
#import "DatabaseHelper1.h"
#import "UCCarBrandModel.h"
#import "UCCarSeriesModel.h"
#import "UCCarSpecModel.h"
#import "IMCacheManage.h"

static UCAreaMode *_mArea;
static NSMutableArray *_carIds;

@implementation AMCacheManage

/* 当前版本号 */
+ (NSString *)currentConfigVersion{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:kConfigVersion];
}

+ (void)setConfigVersion:(NSString *)version{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:version forKey:kConfigVersion];
    [userDefaults synchronize];
}

/* 是否已经使用过本应用(开机引导) */
+ (BOOL)currentIsUsed{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kConfigIsUsed];
}

+ (void)setCurrentIsUsed:(BOOL)isUsed{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isUsed forKey:kConfigIsUsed];
    [userDefaults synchronize];
}

/** 设置token */
+ (void)setToken:(NSString *)token
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:token forKeyPath:kToken];
}

+ (NSString *)currentToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:kToken];
    return token;
}

/** 设置Push deviceid */
+ (void)setDeviceid:(NSInteger)deviceid
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:deviceid forKey:kPushDeviceid];
}

+ (NSInteger)currentDeviceid
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger deviceid = [userDefaults integerForKey:kPushDeviceid];
    return deviceid;
}

/** 是否已显示过对比滑动引导 */
+ (BOOL)currentIsShowComparSlidingTips
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kConfigIsShowComparSlidingTips];
}

+ (void)setCurrentIsShowComparSlidingTips:(BOOL)isShowComparSlidingTips
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isShowComparSlidingTips forKey:kConfigIsShowComparSlidingTips];
    [userDefaults synchronize];
}

/** 获取缓存数据库路径 */
+ (NSString *)cacheDbPathForResource:(NSString *)dbName
{
    
    NSString *fileName = [NSString stringWithFormat:@"%@.sqlite", dbName];
    NSString *filePath = [self getCacheFilePath:kCacheDataDir fileName:fileName];

    // 已存在缓存数据库
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return filePath;
    }
    // 生成缓存数据库
    else {
        NSString *sourceDbPath = [[NSBundle mainBundle] pathForResource:dbName ofType:@"sqlite"];
        NSData *sourceDb = [NSData dataWithContentsOfFile:sourceDbPath];
        
        if ([AMCacheManage saveCacheWithDirName:kCacheDataDir fileName:fileName data:sourceDb])
            return filePath;
    }
    return nil;
}


/** 销售线索拨打记录 */
+ (NSMutableArray *)currentCallRecord
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *callRecords = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:kCallRecord]];
    
    return callRecords;
}

/** 清空销售线索拨打记录 */
+ (void)deleteCallRecord
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:nil] forKey:kCallRecord];
    [userDefaults synchronize];
}

+ (void)addCurrentCallRecord:(NSString *)mobile
{
    // 本地所有用户的拨打记录
    NSMutableArray *callRecords = [[NSMutableArray alloc] initWithArray:[self currentCallRecord]];
    
    // 此条拨打时间
    NSString *callRecordTime = [NSString stringWithString:[OMG stringFromDateWithFormat:@"yyyy-MM-dd HH:mm:ss" date:[NSDate date]]];
    
    // 是否存在此商家
    BOOL isExistDealer = NO;
    
    // 存在商家
    for (NSMutableDictionary *dicDealer in callRecords) {
        if ([[dicDealer objectForKey:@"dealerid"] integerValue] == [[AMCacheManage currentUserInfo].userid integerValue]) {
            isExistDealer = YES;
            
            // 本商家所有号码拨打记录
            NSMutableArray *contacts = [[NSMutableArray alloc] initWithArray:[dicDealer objectForKey:@"contacts"]];
            
            // 是否存在此号码
            BOOL isExistPhone = NO;
            // 存在此号码
            for (NSMutableDictionary *dicContact in contacts) {
                if ([[dicContact objectForKey:@"phonenumber"] isEqualToString:mobile]) {
                    isExistPhone = YES;
                    // 插入此条拨打记录
                    NSMutableArray *calltimes = [[NSMutableArray alloc] initWithArray:[dicContact objectForKey:@"calltimes"]];
                    [calltimes addObject:callRecordTime];
                    
                    // 更新此号码的拨打记录
                    [dicContact setValue:calltimes forKey:@"calltimes"];
                    
                    NSMutableDictionary *dicTemp = [[NSMutableDictionary alloc] initWithDictionary:dicDealer];
                    [dicTemp setValue:contacts forKey:@"contacts"];
                    [callRecords replaceObjectAtIndex:[callRecords indexOfObject:dicDealer] withObject:dicTemp];
                    
                    break;
                }
            }
            // 不存在此号码
            if (!isExistPhone) {
                // 拨打数组
                NSMutableArray *calltimes = [NSMutableArray arrayWithObjects:callRecordTime, nil];
                // 此号码的拨打记录
                NSMutableDictionary *dicContacts = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:mobile, calltimes, nil] forKeys:@[@"phonenumber", @"calltimes"]];
                // 添加此商家此号码的所有拨打记录
                [contacts addObject:dicContacts];
                // 更新此商家记录
                NSMutableDictionary *dicTemp = [[NSMutableDictionary alloc] initWithDictionary:dicDealer];
                [dicTemp setValue:contacts forKey:@"contacts"];
                [callRecords replaceObjectAtIndex:[callRecords indexOfObject:dicDealer] withObject:dicTemp];
            }
            
            break;
        }
    }
    // 不存在商家
    if (!isExistDealer) {
        // 拨打数组
        NSMutableArray *calltimes = [NSMutableArray arrayWithObjects:callRecordTime, nil];
        // 联系人的拨打数据
        NSMutableDictionary *dicContact = [NSMutableDictionary dictionaryWithObjectsAndKeys:mobile, @"phonenumber", calltimes, @"calltimes", nil];
        NSMutableArray *contacts = [NSMutableArray arrayWithObjects:dicContact, nil];
        // 添加商家
        [callRecords addObject:[NSDictionary dictionaryWithObjectsAndKeys:[AMCacheManage currentUserInfo].userid, @"dealerid", contacts, @"contacts", nil]];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:callRecords] forKey:kCallRecord];
    [userDefaults synchronize];
}

/** 是否已经导入旧收藏数据 */
+ (BOOL)currentIsImportOldFavourates
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kConfigIsImportOldFavourates];
}

+ (void)setCurrentIsImportOldFavourates:(BOOL)isImportOldFavourates
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isImportOldFavourates forKey:kConfigIsImportOldFavourates];
    [userDefaults synchronize];
}

/** 最后浏览 */
+ (UCCarDetailInfoModel *)currentCarDetailInfoModel
{
    NSData *data = [AMCacheManage loadCacheWithDirName:kCacheDataDir fileName:kCacheCarDetailInfoModel];
    UCCarDetailInfoModel *mCarDetailInfo = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    return mCarDetailInfo;
}

+ (BOOL)setCurrentCarDetailInfoModel:(UCCarDetailInfoModel *)mCarDetailInfo
{
    BOOL isSucceed = NO;
    
    if (mCarDetailInfo) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mCarDetailInfo];
        isSucceed = [AMCacheManage saveCacheWithDirName:kCacheDataDir fileName:kCacheCarDetailInfoModel data:data];
    } else {
        [AMCacheManage clearCacheWithDirName:kCacheDataDir fileName:kCacheCarDetailInfoModel];
        isSucceed = YES;
    }
    
    return isSucceed;
}

/** 当前地区 */
+ (UCAreaMode *)currentArea
{
    if (!_mArea) {
        NSData *data = [AMCacheManage loadCacheWithDirName:kCacheDataDir fileName:kCacheArea];
        _mArea = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    }
    return _mArea;
}

+ (BOOL)setCurrentArea:(UCAreaMode *)mArea
{
    BOOL isSucceed = NO;
    _mArea = nil;
    if (mArea) {
        _mArea = mArea;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_mArea];
        isSucceed = [AMCacheManage saveCacheWithDirName:kCacheDataDir fileName:kCacheArea data:data];
    } else {
        [AMCacheManage clearCacheWithDirName:kCacheDataDir fileName:kCacheArea];
        isSucceed = YES;
    }
    return isSucceed;
}

/** 当前排序 */
+ (NSString *)currentOrder
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:kConfigOrder];
}

+ (void)setCurrentOrder:(NSString *)order
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:order forKey:kConfigOrder];
    [userDefaults synchronize];
}

/** 当前用户类别 0未选择 1商家 2个人 */
+ (UserStyle)currentUserType
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:kConfigUserType];
}

+ (void)setCurrentUserType:(UserStyle)userType
{
    // 清除IM信息
    if (userType != UserStylePhone && userType != [AMCacheManage currentUserType]) {
        [IMCacheManage setCurrentIMUserInfo:nil];
        [IMCacheManage setCurrentInputboxMode:0];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:userType forKey:kConfigUserType];
    [userDefaults synchronize];
}

/** 历史筛选 */
+ (NSMutableArray *)currentHistoryFilter
{
    NSData *data = [AMCacheManage loadCacheWithDirName:kCacheDataDir fileName:kCacheHistoryFilter];
    NSMutableArray * mFilters = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    return mFilters;
}

+ (BOOL)setCurrentHistoryFilter:(NSMutableArray *)mFilters
{
    BOOL isSucceed = NO;
    if (mFilters) {
        if (mFilters.count > 20) {
            [mFilters removeObjectsInRange:NSMakeRange(20, mFilters.count - 20)];
        }
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mFilters];
        isSucceed = [AMCacheManage saveCacheWithDirName:kCacheDataDir fileName:kCacheHistoryFilter data:data];
    } else {
        [AMCacheManage clearCacheWithDirName:kCacheDataDir fileName:kCacheHistoryFilter];
        isSucceed = YES;
    }
    return isSucceed;
}

/** 当前用户信息 */
+ (UserInfoModel *)currentUserInfo
{
    NSData *data = [AMCacheManage loadCacheWithDirName:kCacheDataDir fileName:kCacheUserInfo];
    UserInfoModel *mUserInfo = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    return mUserInfo;
}

+ (BOOL)setCurrentUserInfo:(UserInfoModel *)mUserInfo
{
    BOOL isSucceed = NO;

    if (mUserInfo) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mUserInfo];
        isSucceed = [AMCacheManage saveCacheWithDirName:kCacheDataDir fileName:kCacheUserInfo data:data];
        if (isSucceed) {
            UserStyle userStyle = UserStyleNone;
            if (mUserInfo.type.integerValue == 1) {
                userStyle = UserStyleBusiness;
            } else if (mUserInfo.type.integerValue == 2) {
                userStyle = UserStylePersonal;
            } else if (mUserInfo.type.integerValue == 3) {
                userStyle = UserStylePhone;
            }
            [AMCacheManage setCurrentUserType:userStyle];
        }
    } else {
        if (![AMCacheManage currentUserInfo]) {
            [AMCacheManage setCurrentUserType:UserStyleNone];
            isSucceed = YES;
        } else if ([AMCacheManage clearCacheWithDirName:kCacheDataDir fileName:kCacheUserInfo]){
            [AMCacheManage setCurrentUserType:UserStyleNone];
            isSucceed = YES;
        }
    }
    return isSucceed;
}

///** 当前个人用户信息 */
//+ (UserInfoModel *)currentPersonalUserInfo
//{
//    NSData *data = [AMCacheManage loadCacheWithDirName:kCacheDataDir fileName:kCacheDeviceInfo];
//    UserInfoModel *mUserInfo = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
//    return mUserInfo;
//}
//
//+ (BOOL)setCurrentPersonalUserInfo:(UserInfoModel *)mUserInfo
//{
//    BOOL isSucceed = NO;
//    
//    if (mUserInfo) {
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mUserInfo];
//        isSucceed = [AMCacheManage saveCacheWithDirName:kCacheDataDir fileName:kCacheDeviceInfo data:data];
//    } else {
//        [AMCacheManage clearCacheWithDirName:kCacheDataDir fileName:kCacheDeviceInfo];
//        isSucceed = YES;
//    }
//    return isSucceed;
//
//}

/** 当前发车未填完数据 */
+ (NSMutableArray *)currentCarInfoEditDrafts
{
    // 未填完数据和用户ID关联
    NSString *userId = [AMCacheManage currentUserInfo].userid.stringValue;
    if (!userId)
        // 没有用户ID使用设备ID
        userId = [OMG openUDID];
    
    NSString *fileName = [NSString stringWithFormat:@"%@-%@", kCacheCarInfoEditDrafts, userId];
    NSData *data = [AMCacheManage loadCacheWithDirName:kCacheDataDir fileName:fileName];
    NSMutableArray *mCarInfoEditDrafts = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    return mCarInfoEditDrafts;
}

+ (BOOL)setCurrentCarInfoEditDrafts:(NSMutableArray *)mCarInfoEdit
{
    BOOL isSucceed = NO;
    
    // 未填完数据和用户ID关联
    NSString *userId = [AMCacheManage currentUserInfo].userid.stringValue;
    if (!userId)
        // 没有用户ID使用设备ID
        userId = [OMG openUDID];
    
    NSString *fileName = [NSString stringWithFormat:@"%@-%@", kCacheCarInfoEditDrafts, userId];
    if (mCarInfoEdit) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mCarInfoEdit];
        isSucceed = [AMCacheManage saveCacheWithDirName:kCacheDataDir fileName:fileName data:data];
    } else {
        [AMCacheManage clearCacheWithDirName:kCacheDataDir fileName:fileName];
        isSucceed = YES;
    }
    return isSucceed;
}

/** 收藏 */
+ (BOOL)saveCarToFavourite:(UCFavoritesModel *)mFavorite
{
    BOOL isSuccess;
    
    NSString *path = [AMCacheManage cacheDbPathForResource:@"Cache"];
    DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:path];
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO Favorite(ID, Name, CompleteSale, Price, [Image], Mileage, SeriesId, RegistrationDate, IsDealer, PublishDate, HasCard, LevelId, IsNewCar, Invoice) VALUES('%@','%@','%d','%@','%@','%@','%d','%@','%d','%@','%d','%d','%d','%d')" ,
                           mFavorite.quoteID,
                           mFavorite.name,
                           [mFavorite.completeSale integerValue],
                           mFavorite.price,
                           mFavorite.image,
                           mFavorite.mileage,
                           [mFavorite.seriesId integerValue],
                           mFavorite.registrationDate,
                           [mFavorite.isDealer integerValue],
                           mFavorite.publishDate,
                           [mFavorite.hasCard integerValue],
                           [mFavorite.levelId integerValue],
                           [mFavorite.isnewcar integerValue],
                           [mFavorite.invoice integerValue]];
    
    isSuccess = [dbHelper insertTable:insertSql];
    
    return isSuccess;
}

/** 查询表 */
+ (NSArray *)selectFrome:(NSString *)tableName where:(NSString *)where equalValue:(NSString *)value
{
    NSString *path = [AMCacheManage cacheDbPathForResource:@"Cars"];
    DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:path];
    if (tableName.length > 0 && where.length > 0 && value.length > 0) {
        NSString *resultSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'", tableName, where, value];
        NSMutableArray  *result = [dbHelper querryTable:resultSql];
        return result;
    } else
        return nil;
}

/** 查询要的品牌数据 */
+ (NSArray *)fuzzySearchCar:(NSString *)name
{
    // 搜索结果
    NSMutableArray *searchResults = [NSMutableArray array];
    // 打开数据库
    NSString *path = [AMCacheManage cacheDbPathForResource:@"Cars"];
    DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:path];
    if (name.trim.length > 0) {
        
        // 模糊匹配品牌
        NSString *likeKey = [[@"%" stringByAppendingString:name] stringByAppendingString:@"%"];
        
        NSString *brandFuzzySql = [NSString stringWithFormat:@"SELECT * FROM CarBrand WHERE Name LIKE '%%%@%%'", likeKey];
        NSMutableArray *brandFuzzyResults = [dbHelper querryTable:brandFuzzySql];
        NSString *seriesFuzzySql = [NSString stringWithFormat:@"SELECT * FROM CarSeries WHERE Name LIKE '%%%@%%'", likeKey];
        NSMutableArray *seriesFuzzyResults = [dbHelper querryTable:seriesFuzzySql];
        // 品牌
        if (brandFuzzyResults.count > 0) {
            for (NSDictionary *dic in brandFuzzyResults) {
                [searchResults addObject:[[UCCarBrandModel alloc] initWithJson:dic]];
            }
        }
        // 车系
        if (seriesFuzzyResults.count > 0) {
            for (NSDictionary *dic in seriesFuzzyResults) {
                [searchResults addObject:[[UCCarSeriesModel alloc] initWithJson:dic]];
            }
        }
        
        // 全匹配查询
        NSString *brandFullSql = [NSString stringWithFormat:@"SELECT * FROM CarBrand WHERE Name = '%@' order by BrandId", name];
        NSMutableArray *brandFullResults = [dbHelper querryTable:brandFullSql];
        NSString *seriesFullSql = [NSString stringWithFormat:@"SELECT * FROM CarSeries WHERE Name = '%@' order by Orderby", name];
        NSMutableArray *seriesFullResults = [dbHelper querryTable:seriesFullSql];
        // 全匹配品牌、车系
        if (brandFullResults.count > 0 || seriesFullResults.count > 0) {
            // 品牌
            for (NSDictionary *dic in brandFullResults) {
                UCCarBrandModel *mCarBrand = [[UCCarBrandModel alloc] initWithJson:dic];
//                [searchResults insertObject:mCarBrand atIndex:0];
                // 找出品牌对应的车系
                NSString *findSeriesSql = [NSString stringWithFormat:@"SELECT * FROM CarSeries WHERE FatherId = %d order by Orderby", mCarBrand.brandId.integerValue];
                NSMutableArray *findSeriesResults = [dbHelper querryTable:findSeriesSql];
                
                // 对应的车系
                for (NSDictionary *dic in findSeriesResults) {
                    BOOL isExist = NO;
                    UCCarSeriesModel *mCarSeries = [[UCCarSeriesModel alloc] initWithJson:dic];
                    for (id model in searchResults) {
                        if ([model isKindOfClass:[UCCarSeriesModel class]]) {
                            if ([[(UCCarSeriesModel *)model name] isEqualToString:mCarSeries.name]) {
                                isExist = YES;
                                break;
                            }
                        }
                    }
                    if (!isExist)
                        [searchResults addObject:mCarSeries];
                }
            }
            // 车系
            for (NSDictionary *dic in seriesFullResults) {
                UCCarSeriesModel *mCarSeries = [[UCCarSeriesModel alloc] initWithJson:dic];
//                [searchResults insertObject:mCarSeries atIndex:0];
                // 找出车型对应的车型
                NSString *findSpecSql = [NSString stringWithFormat:@"SELECT * FROM CarSpec WHERE FatherId = %d order by SpecId", mCarSeries.seriesId.integerValue];
                NSMutableArray *findSpecResults = [dbHelper querryTable:findSpecSql];
                // 对应的车型
                for (NSDictionary *dic in findSpecResults) {
                    [searchResults addObject:[[UCCarSpecModel alloc] initWithJson:dic]];
                }
            }
        }
    }
    [dbHelper closeDatabase];
    if (searchResults.count > 0) {
        return searchResults;
    }
    else
        return nil;
}

+ (BOOL)deleteCarFromFavourite:(NSString *)carid
{
    BOOL isSuccess;
    NSString *path = [AMCacheManage cacheDbPathForResource:@"Cache"];
    DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:path];
    NSString *deletetSql = [NSString stringWithFormat:@"DELETE FROM Favorite WHERE `ID` = '%@'", carid];
    isSuccess = [dbHelper updataTable:deletetSql];
    return isSuccess;
}

+ (NSArray *)currentFavourites
{
    NSString *path = [AMCacheManage cacheDbPathForResource:@"Cache"];
    DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:path];
    NSArray *favoriteList = [dbHelper querryTable:[NSString stringWithFormat:@"SELECT * FROM Favorite ORDER BY hid DESC"]];
    
    NSMutableArray *favorites = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [favoriteList count]; i++) {
        NSDictionary *dicFavorite = (NSDictionary *)[favoriteList objectAtIndex:i];
        UCFavoritesModel *mFavorite = [[UCFavoritesModel alloc] initWithJson:dicFavorite];
        // 保留两位小数
        mFavorite.price = [NSString stringWithFormat:@"%.2f", [mFavorite.price doubleValue]];
        mFavorite.mileage = [NSString stringWithFormat:@"%.2f", [mFavorite.mileage doubleValue]];
        [favorites addObject:mFavorite];
    }
    return favorites;
}

+ (BOOL)existInFavourites:(NSString *)carid
{
    BOOL isExist = NO;
    NSString *path = [AMCacheManage cacheDbPathForResource:@"Cache"];
    DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:path];
    NSArray *favoriteList = [dbHelper querryTable:[NSString stringWithFormat:@"SELECT * FROM Favorite WHERE `ID` = '%@'", carid]];
    
    if ([favoriteList count] > 0) {
        isExist = YES;
    }
    return isExist;
}

/** 对比 */
+ (BOOL)setCurrentCompareInfo:(NSMutableArray *)mFilters
{
    BOOL isSucceed = NO;
    if (mFilters) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mFilters];
        isSucceed = [AMCacheManage saveCacheWithDirName:kCacheDataDir fileName:kCacheCompareInfo data:data];
    } else {
        [AMCacheManage clearCacheWithDirName:kCacheDataDir fileName:kCacheCompareInfo];
        isSucceed = YES;
    }
    return isSucceed;
}

+ (NSMutableArray *)currentCompareInfo
{
    NSData *data = [AMCacheManage loadCacheWithDirName:kCacheDataDir fileName:kCacheCompareInfo];
    NSMutableArray * mFilters = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    return mFilters;
}

/** 添加买车车源列表已读痕迹 */
+ (BOOL)addBuyCarListArray:(NSString *)addCarID
{
    NSUInteger count = 150;
    
    BOOL isSucceed = NO;
    // 当前阅读痕迹
    if (!_carIds) {
        [AMCacheManage currentBuyCarListArray];
    }
    if (addCarID.length > 0) {
        // 最多150条
        if (_carIds.count >= count)
            [_carIds removeObjectsInRange:NSMakeRange(0, _carIds.count - count + 1)];
        [_carIds addObject:addCarID];
        
        if (_carIds.count > 0) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_carIds];
            isSucceed = [AMCacheManage saveCacheWithDirName:kCacheDataDir fileName:kBuyCarListHaveReadArray data:data];
        } else {
            [AMCacheManage clearCacheWithDirName:kCacheDataDir fileName:kBuyCarListHaveReadArray];
            isSucceed = YES;
        }
    }
    return isSucceed;
}

+ (NSMutableArray *)currentBuyCarListArray
{
    if (!_carIds) {
        NSData *data = [AMCacheManage loadCacheWithDirName:kCacheDataDir fileName:kBuyCarListHaveReadArray];
        _carIds = [[NSMutableArray alloc] initWithArray:data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil];
    }
    return _carIds;
}

/** 当前版本启动次数 */
+ (NSInteger)currentVersionStartNumber
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:kConfigVersionStartNumber];
}
+ (void)setCurrentVersionStartNumber:(NSInteger)number
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:number forKey:kConfigVersionStartNumber];
    [userDefaults synchronize];
}

/* 车辆概况数量操作 */
+ (void)reduceCarListState:(NSInteger)reduceState plusCarListState:(NSInteger)plusState
{    
    UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
    
    NSInteger carsaleing = [(NSNumber *)((UserInfoModel *)mUserInfo.carsaleing) integerValue];
    NSInteger carsaled = [(NSNumber *)((UserInfoModel *)mUserInfo.carsaled) integerValue];
    NSInteger carchecking = [(NSNumber *)((UserInfoModel *)mUserInfo.carchecking) integerValue];
    NSInteger carnotpassed = [(NSNumber *)((UserInfoModel *)mUserInfo.carnotpassed) integerValue];
    NSInteger carinvalid = [(NSNumber *)((UserInfoModel *)mUserInfo.carinvalid) integerValue];
    
    //减
    if (reduceState != NSNotFound) {
        switch (reduceState) {
            case 0://在售
                if ([mUserInfo.carsaleing integerValue] > 0)
                    mUserInfo.carsaleing = [NSNumber numberWithInteger:--carsaleing];
                break;
            case 1://已售
                if ([mUserInfo.carsaled integerValue] > 0)
                    mUserInfo.carsaled = [NSNumber numberWithInteger:--carsaled];
                break;
            case 2://审核
                if ([mUserInfo.carchecking integerValue] > 0)
                    mUserInfo.carchecking = [NSNumber numberWithInteger:--carchecking];
                break;
            case 3://未通过
                if ([mUserInfo.carnotpassed integerValue] > 0)
                    mUserInfo.carnotpassed = [NSNumber numberWithInteger:--carnotpassed];
                break;
            case 5://已过期
                if ([mUserInfo.carinvalid integerValue] > 0)
                    mUserInfo.carinvalid = [NSNumber numberWithInteger:--carinvalid];
                break;
            default:
                break;
        }
        
    }
    
    //加
    if (plusState != NSNotFound) {
        switch (plusState) {
            case 0://在售
                mUserInfo.carsaleing = [NSNumber numberWithInteger:++carsaleing];
                break;
            case 1://已售
                mUserInfo.carsaled = [NSNumber numberWithInteger:++carsaled];
                break;
            case 2://审核
                mUserInfo.carchecking = [NSNumber numberWithInteger:++carchecking];
                break;
            case 3://未通过
                mUserInfo.carnotpassed = [NSNumber numberWithInteger:++carnotpassed];
                break;
            case 5://已过期
                mUserInfo.carinvalid = [NSNumber numberWithInteger:++carinvalid];
                break;
            default:
                break;
        }
    }
    
    [AMCacheManage setCurrentUserInfo:mUserInfo];
}


+(BOOL)setSearchHistory:(NSArray*)array{
    BOOL isSucceed = NO;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    isSucceed = [AMCacheManage saveCacheWithDirName:kCacheDataDir fileName:kSearchHistory data:data];
    return isSucceed;
}

+(NSArray *)getSearchHistory{
    NSData *data = [AMCacheManage loadCacheWithDirName:kCacheDataDir fileName:kSearchHistory];
    NSArray *array = [[NSArray alloc] initWithArray:data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil];
    return array;
}

+(BOOL)removeSearchHistory{
    BOOL isSucceed = NO;
    isSucceed = [AMCacheManage clearCacheWithDirName:kCacheDataDir fileName:kSearchHistory];
    return isSucceed;
}

/** 推送 **/
+(NSInteger)currentPushStatus{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:kConfigPushStatus];
}

+(BOOL)setPushStatus:(NSInteger)status{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:status forKey:kConfigPushStatus];
    return [userDefaults synchronize];
}

+(NSInteger)currentAppState{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:kConfigAppState];
}

+(void)setAppState:(NSInteger)status{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:status forKey:kConfigAppState];
    [userDefaults synchronize];
}

#pragma mark - 引导标识
/** IM 聊天页引导状态标识 **/
+(NSInteger)currentConfigStartIMGuideStatus{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:kGuideStartIMView];
}

+(BOOL)setConfigStartIMGuideStatus:(NSInteger)status{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:status forKey:kGuideStartIMView];
    return [userDefaults synchronize];
}

/** 首页筛选页的引导状态标识 **/
+(NSInteger)currentConfigFilterGuideStatus{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:kGuideFilterView];
}

+(BOOL)setConfigFilterGuideStatus:(NSInteger)status{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:status forKey:kGuideFilterView];
    return [userDefaults synchronize];
}

/** 记录筛选页引导的上次查看版本 **/
+(NSInteger)currentConfigFilterGuideLastViewVersion{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:kGuideFilterLastViewVersion];
}

+(BOOL)setConfigFilterGuideLastViewVersion:(NSInteger)version{
    //CFBundleShortVersionString
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:version forKey:kGuideFilterLastViewVersion];
    return [userDefaults synchronize];
}

/** 首页引导状态标识 **/
+(NSInteger)currentConfigHomeGuideStatus{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:kGuideHomeView];
}

+(BOOL)setConfigHomeGuideStatus:(NSInteger)status{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:status forKey:kGuideHomeView];
    return [userDefaults synchronize];
}

/** 记录首页引导的上次查看版本 **/
+(NSInteger)currentConfigHomeGuideLastViewVersion{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:kGuideHomeLastViewVersion];
}

+(BOOL)setConfigHomeGuideLastViewVersion:(NSInteger)version{
    //CFBundleShortVersionString
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:version forKey:kGuideHomeLastViewVersion];
    return [userDefaults synchronize];
}




#pragma mark -
/* 图片缓存 */
+ (NSData *)loadImageWhitName:(NSString *)imageName
{
    NSData *data = [AMCacheManage loadCacheWithDirName:kCacheImageDir fileName:imageName];
    return data;
}

+ (BOOL)saveImageWhitName:(NSString *)name data:(NSData *)data
{
    BOOL isSucceed = NO;
    if (data) {
        isSucceed = [AMCacheManage saveCacheWithDirName:kCacheImageDir fileName:name data:data];
    } else {
        [AMCacheManage clearCacheWithDirName:kCacheImageDir fileName:name];
        isSucceed = YES;
    }
    return isSucceed;
}

+ (BOOL)replaceImageName:(NSString *)target withString:(NSString *)replacement
{
    NSString *targetFilePath = [AMCacheManage getCacheFilePath:kCacheImageDir fileName:target];
    NSString *replaceFilePath = [AMCacheManage getCacheFilePath:kCacheImageDir fileName:replacement];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL isDone = [fileManager moveItemAtPath:targetFilePath toPath:replaceFilePath error:&error];
    return isDone;
}

+ (BOOL)isExistsImage:(NSString *)name
{
    NSString *fileLath = [AMCacheManage isExistsCachePath:kCacheImageDir fileName:name];
    return fileLath ? YES : NO;
}

+ (CGFloat)imageCacheSize
{
    return [AMCacheManage dirSizeAtPath:[AMCacheManage getCacheDirPath:kCacheImageDir]];
}

#pragma mark - Cache
/** 读取缓存 */
+ (NSData *)loadCacheWithDirName:(NSString *)dirName fileName:(NSString *)fileName
{
    NSString *filePath = [AMCacheManage isExistsCachePath:dirName fileName:fileName];
    if (filePath) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        return data;
    }
    return nil;
}

/** 保存缓存 */
+ (BOOL)saveCacheWithDirName:(NSString *)dirName fileName:(NSString *)fileName data:(NSData *)data
{
    NSString *filePath = [self getCacheFilePath:dirName fileName:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath = [AMCacheManage getCacheDirPath:dirName];
    BOOL isDir;
    BOOL isExists = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if (!(isExists && isDir))
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    return [data writeToFile:filePath atomically:YES];
}

/** 是否存在缓存文件 */
+ (NSString *)isExistsCachePath:(NSString *)dirName fileName:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self getCacheFilePath:dirName fileName:fileName];
    
    BOOL isDir;
    BOOL isExists = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    
    if (isExists && !isDir)
        return filePath;
    return nil;
}

/** 清除指定目录下的全部缓存 */
+ (BOOL)clearAllCacheWhitDirName:(NSString *)dirName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL isDone = [fileManager removeItemAtPath:[AMCacheManage getCacheDirPath:dirName] error:&error];
    return isDone;
}

/** 清楚指定类型的缓存 */
+ (BOOL)clearCacheWithDirName:(NSString *)dirName fileName:(NSString *)fileName
{
    NSString *filePath = [self getCacheFilePath:dirName fileName:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL isDone = [fileManager removeItemAtPath:filePath error:&error];
    return isDone;
}

/** 获取缓存文件路径 */
+ (NSString *)getCacheFilePath:(NSString *)dirName fileName:(NSString *)fileName
{
    NSString *filePath;
    filePath = [[AMCacheManage getCacheDirPath:dirName] stringByAppendingPathComponent:fileName.md5];
    return filePath;
}

/** 获取缓存目录路径 */
+ (NSString *)getCacheDirPath:(NSString *)dirName
{
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //缓存目录路径
    NSString *dirPath = [cachesPath stringByAppendingPathComponent:dirName];
    return dirPath;
}

/** 单个文件的大小 */
+ (long long)fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
/** 遍历文件夹获得文件夹大小，单位M */
+ (float)dirSizeAtPath:(NSString*)dirPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:dirPath])
        return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:dirPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [dirPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize / (1024.0 * 1024.0);
}

+(BOOL)setLastRefreshUserInfoTime:(NSDate *)date
{
    BOOL isSucceed = NO;
    
    if (date) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:date];
        isSucceed = [AMCacheManage saveCacheWithDirName:kCacheDataDir fileName:kLastRefreshUserInfoDate data:data];
    } else {
        [AMCacheManage clearCacheWithDirName:kCacheDataDir fileName:kCacheCarDetailInfoModel];
        isSucceed = YES;
    }
    
    return isSucceed;
}
+(NSDate *)currentLastRefreshUserInfoTime
{
    NSData *data = [AMCacheManage loadCacheWithDirName:kCacheDataDir fileName:kLastRefreshUserInfoDate];
    NSDate *date = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    return date;
}


#pragma mark - 个人同步
/** 同步个人车车源 */
+ (BOOL)SYNCclientCarSuccess{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kSYNCclientCar];
}
+ (void)setSYNCclientCarSuccess:(BOOL)success{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:success forKey:kSYNCclientCar];
    [userDefaults synchronize];
}

+ (BOOL)SYNCclientCarNeeded{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kSYNCclientCarNeeded];
}
+ (void)setSYNCclientCarNeeded:(BOOL)needed{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:needed forKey:kSYNCclientCarNeeded];
    [userDefaults synchronize];
}


/** 同步个人订阅 */
+ (BOOL)SYNCclientSubscriptionSuccess{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kSYNCclientSubsription];
}
+ (void)setSYNCclientSubscriptionSuccess:(BOOL)success{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:success forKey:kSYNCclientSubsription];
    [userDefaults synchronize];
}
+ (BOOL)SYNCclientSubscriptionNeeded{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kSYNCclientSubsriptionNeeded];
}
+ (void)setSYNCclientSubscriptionNeeded:(BOOL)needed{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:needed forKey:kSYNCclientSubsriptionNeeded];
    [userDefaults synchronize];
}

/** 同步个人收藏夹 */
+ (BOOL)SYNCclientFavoritesSuccess{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kSYNCclientFavorites];
}
+ (void)setSYNCclientFavoritesSuccess:(BOOL)success{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:success forKey:kSYNCclientFavorites];
    [userDefaults synchronize];
}

/** 是否需要同步个人收藏夹 */
+ (BOOL)SYNCclientFavoritesNeeded{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kSYNCclientFavoritesNeeded];
}
+ (void)setSYNCclientFavoritesNeeded:(BOOL)needed{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:needed forKey:kSYNCclientFavoritesNeeded];
    [userDefaults synchronize];
}

@end
