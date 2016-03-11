//
//  AMConfigManage.m
//  UsedCar
//
//  Created by Alan on 14-5-21.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "AMConfigManage.h"

#import "APIHelper.h"
#import "AMCacheManage.h"
#import "DatabaseHelper1.h"
#import "UCBusinessInfoView.h"
#import "AppDelegate.h"
#import "UCCarDetailView.h"
#import "UCCarInfoModel.h"

@implementation AMConfigManage

static AMConfigManage *vcMain = nil;
+ (AMConfigManage *)sharedConfigManage
{
    if (!vcMain)
        vcMain = [[AMConfigManage alloc] init];
    return vcMain;
}

+ (void)setUserInfo
{
    UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
    
    // 4.0之前 处理之前版本usertype为商家时错写成了3的问题。
    if (mUserInfo.userkey && mUserInfo.userkey.length > 0) {
        if (mUserInfo.type.integerValue == 1)
            [AMCacheManage setCurrentUserType:UserStyleBusiness];
        else if (mUserInfo.type.integerValue == 2)
            [AMCacheManage setCurrentUserType:UserStylePersonal];
        else if (mUserInfo.type.integerValue == 3)
            [AMCacheManage setCurrentUserType:UserStylePhone];
    } else {
        [AMCacheManage setCurrentUserInfo:nil];
    }
}

/** 导入旧版本收藏数据 */
+ (void)importOldFavourates
{
    // 读取二手车3.0版本的收藏
    if (![AMCacheManage currentIsImportOldFavourates]) {
        
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [docPath stringByAppendingPathComponent:@"usedcar.sqlite"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:filePath];
            NSArray *favoriteList = [dbHelper querryTable:[NSString stringWithFormat:@"SELECT * FROM History ORDER BY hid DESC"]];
            
            for (int i = 0; i < [favoriteList count]; i++) {
                NSDictionary *dicFavorite = (NSDictionary *)[favoriteList objectAtIndex:i];
                UCFavoritesModel *mFavorite = [[UCFavoritesModel alloc] initWithJson:dicFavorite];
                if (![AMCacheManage existInFavourites:mFavorite.quoteID]) {
                    [AMCacheManage saveCarToFavourite:mFavorite];
                }
            }
            [AMCacheManage setCurrentIsImportOldFavourates:YES];
        }
    }
    
    // 查询是否已经插入“新车&延长质保”字段，——兼容3.4之前版本，数据库版本从 0 升级到 1
    NSString *dbPath = [AMCacheManage cacheDbPathForResource:@"Cache"];
    DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:dbPath];
    [dbHelper openOrCreateDatabase];
    
    NSMutableArray *datas = [dbHelper querryTable:@"PRAGMA user_version"];
    if (datas.count > 0) {
        NSInteger dbVersion = [[(NSDictionary *)datas[0] objectForKey:@"user_version"] integerValue];
        if (dbVersion == 0) {
            // 打开数据库
            [dbHelper openOrCreateDatabase];
            [dbHelper beginTransaction];
            
            NSString *addIsNewCarSql = [NSString stringWithFormat:@"alter table Favorite add IsNewCar INTEGER"];
            BOOL isAddedIsNewCar = [dbHelper insertTable:addIsNewCarSql isOpenAndClose:NO];
            
            NSString *addInvoiceSql = [NSString stringWithFormat:@"alter table Favorite add Invoice INTEGER"];
            BOOL isAddedInvoice = [dbHelper insertTable:addInvoiceSql isOpenAndClose:NO];
            
            if (isAddedIsNewCar && isAddedInvoice) {
                [dbHelper insertTable:@"PRAGMA user_version = 1" isOpenAndClose:NO];
                [dbHelper commitTransaction];
            } else {
                [dbHelper rollbackTransaction];
            }
            
            // 关闭数据库
            [dbHelper closeDatabase];
        }
    }
}

/** 增量更新车型 */
+ (void)updateCar
{
    APIHelper *apiUpdateCar = [[APIHelper alloc] init];
        
    // 设置请求完成后回调方法
    [apiUpdateCar setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                // 获取到增量车型数据
                if (mBase.returncode == 0 && mBase.result) {
//                    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//                    NSLog(@"Time: %f", time);
                    
                    // 获取数据库路径
                    NSString *dbPath = [AMCacheManage cacheDbPathForResource:@"Cars"];
                    // 打开数据库
                    DatabaseHelper1 * dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:dbPath];
                    [dbHelper openOrCreateDatabase];
                    [dbHelper beginTransaction];
                    
                    NSArray *brands = [mBase.result objectForKey:@"brandidlist"];
                    // 品牌
                    for (NSDictionary *dicBrand in brands) {
                        NSInteger brandid = [[dicBrand objectForKey:@"brandid"] integerValue];
                        NSString *brandname = [dicBrand objectForKey:@"brandname"];
                        NSString *firstletter = [dicBrand objectForKey:@"firstletter"];
                        NSString *logourl = [dicBrand objectForKey:@"logourl"];
                        NSArray *serieslist = [dicBrand objectForKey:@"serieslist"];
                        if (brandid > 0 && brandname.length > 0 && firstletter.length > 0 && serieslist.count > 0) {
                            // 车系
                            for (NSDictionary *dicSeries in serieslist) {
                                NSInteger seriesid = [[dicSeries objectForKey:@"seriesid"] integerValue];
                                NSString *seriesname = [dicSeries objectForKey:@"seriesname"];
                                NSInteger factoryid = [[dicSeries objectForKey:@"factoryid"] integerValue];
                                NSString *factoryname = [dicSeries objectForKey:@"factoryname"];
                                NSArray *productlist = [dicSeries objectForKey:@"productlist"];
                                NSInteger orderby = [[dicSeries objectForKey:@"orderby"] integerValue];
                                
                                if (seriesid > 0 && seriesname.length > 0 && productlist.count > 0) {
                                    // 车型
                                    for (NSDictionary *dicSpec in productlist) {
                                        NSInteger productid = [[dicSpec objectForKey:@"productid"] integerValue];
                                        NSString *productname = [dicSpec objectForKey:@"productname"];
                                        NSInteger productyear = [[dicSpec objectForKey:@"productyear"] integerValue];
                                        if (productid > 0 && productname.length > 0) {
                                            // 插入车型
                                            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO CarSpec(SpecId, Name, Year, FatherId) VALUES('%d','%@','%d','%d')", productid, productname, productyear, seriesid];
                                            [dbHelper insertTable:insertSql isOpenAndClose:NO];
                                        }
                                    }
                                    // 插入车系
                                    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO CarSeries(SeriesId, Name, FatherId, FactoryId, FactoryName, Orderby) VALUES('%d','%@','%d','%d','%@','%d')", seriesid, seriesname, brandid, factoryid, factoryname, orderby];
                                    [dbHelper insertTable:insertSql isOpenAndClose:NO];
                                }
                            }
                            // 插入品牌
                            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO CarBrand(BrandId, Name, FirstLetter, LogoUrl) VALUES('%d','%@','%@','%@')", brandid, brandname, firstletter, logourl];
                            [dbHelper insertTable:insertSql isOpenAndClose:NO];
                        }
                    }
                    [dbHelper commitTransaction];
                    [dbHelper closeDatabase];
                    
//                    NSLog(@"Time1: %f", time - [[NSDate date] timeIntervalSince1970]);
                }
            }
        }
    }];
    
    NSString *dbPath = [AMCacheManage cacheDbPathForResource:@"Cars"];
    // 打开数据库
    DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:dbPath];
    NSMutableArray *result = [dbHelper querryTable:@"select max(SpecId) from CarSpec"];
    NSInteger maxSpecId = result.count > 0 ? [[[result objectAtIndex:0] objectForKey:@"max(SpecId)"] integerValue] : 0;
    NSNumber *maxNum = [NSNumber numberWithInteger:maxSpecId == 0 ? 1 : maxSpecId];
    
    // 车型增量
    [apiUpdateCar getNewCars:maxNum];
}

/** 同步通话记录 */
+ (void)updateCallRecords
{
    if (![AMCacheManage currentCallRecord])
        return;
    APIHelper *apiCallRecords = [[APIHelper alloc] init];
    // 设置请求完成后回调方法
    [apiCallRecords setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            AMLog(@"%@",error.domain);
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                NSString *message = nil;
                // 登录成功
                if (mBase.returncode == 0) {
                    AMLog(@"\n*** 同步拨打记录成功^_^ ***\n");
                    [AMCacheManage deleteCallRecord];
                }
                if (message)
                    AMLog(@"同步拨打记录失败-_-：%@", message);
            }
        }
    }];
    // 同步拨打记录
    [apiCallRecords uploadCallRecords];
}

/** 显示商家中心页面 */
+ (void)showDealerStoreView
{
    if (![OMG isValidClick])
        return;
    
    NSString *strUrl = [[AppDelegate sharedAppDelegate].dicLaunchingUsedCar objectForKey:@"dealerStore"];
    // 数据字符串
    NSRange range = [strUrl rangeOfString:@"dealerStore?"];
    if (range.length > 0) {
        NSString *strPriceCarData = [strUrl substringFromIndex:range.location + range.length];
        
        if (strPriceCarData.length > 0) {
            NSMutableDictionary *dicCarPriceApp = [[NSMutableDictionary alloc] init];
            
            if (strPriceCarData.length > 0) {
                NSArray *array = [strPriceCarData componentsSeparatedByString:@"&"];
                for (int i = 0; i < array.count; i++) {
                    NSArray *arrayItem = [[array objectAtIndex:i] componentsSeparatedByString:@"="];
                    if (arrayItem.count == 2) {
                        NSString *strKey =[arrayItem objectAtIndex:0];
                        NSString *strValue = [arrayItem objectAtIndex:1];
                        [dicCarPriceApp setValue:strValue forKey:strKey];
                    }
                }
                NSString *strUserid = [dicCarPriceApp objectForKey:@"userid"];
                if (strUserid.length > 0) {
                    UCBusinessInfoView *vBusinessInfo = [[UCBusinessInfoView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds userid:[NSNumber numberWithInteger:strUserid.integerValue]];
                    [[MainViewController sharedVCMain] openView:vBusinessInfo animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
                }
            }
            
        }
        [[AppDelegate sharedAppDelegate].dicLaunchingUsedCar removeObjectForKey:@"dealerStore"];
    }
}

/** 显示车源页面 */
+ (void)showCarDetailView
{
    if (![OMG isValidClick])
        return;
    
    NSString *strUrl = [[AppDelegate sharedAppDelegate].dicLaunchingUsedCar objectForKey:@"cardetail"];
    // 数据字符串
    NSRange range = [strUrl rangeOfString:@"cardetail?"];
    if (range.length > 0) {
        NSString *strPriceCarData = [strUrl substringFromIndex:range.location + range.length];
        
        if (strPriceCarData.length > 0) {
            NSMutableDictionary *dicCarPriceApp = [[NSMutableDictionary alloc] init];
            
            if (strPriceCarData.length > 0) {
                NSArray *array = [strPriceCarData componentsSeparatedByString:@"&"];
                for (int i = 0; i < array.count; i++) {
                    NSArray *arrayItem = [[array objectAtIndex:i] componentsSeparatedByString:@"="];
                    if (arrayItem.count == 2) {
                        NSString *strKey =[arrayItem objectAtIndex:0];
                        NSString *strValue = [arrayItem objectAtIndex:1];
                        [dicCarPriceApp setValue:strValue forKey:strKey];
                    }
                }
                NSString *strCarID = [dicCarPriceApp objectForKey:@"carid"];
                NSString *strSourceID = [dicCarPriceApp objectForKey:@"sourceid"];
                if (strCarID.length > 0 && strSourceID.length > 0) {
                    UCCarInfoModel *mCarInfo = [[UCCarInfoModel alloc] init];
                    mCarInfo.carid = [NSNumber numberWithInteger:[[dicCarPriceApp objectForKey:@"carid"] integerValue]];
                    mCarInfo.sourceid = [NSNumber numberWithInteger:[[dicCarPriceApp objectForKey:@"sourceid"] integerValue]];
                    UCCarDetailView *vCarDetail = [[UCCarDetailView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds mCarInfo:mCarInfo];
                    [[MainViewController sharedVCMain] openView:vCarDetail animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
                }
            }
            
        }
        [[AppDelegate sharedAppDelegate].dicLaunchingUsedCar removeObjectForKey:@"cardetail"];
    }
}

@end
