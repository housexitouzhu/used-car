//
//  IMCacheManage.m
//  UsedCar
//
//  Created by 张鑫 on 14/11/19.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "IMCacheManage.h"
#import "NSString+Util.h"
#import "FileManager.h"

@implementation IMCacheManage

+ (IMUserInfoModel *)currentIMUserInfo
{
    NSData *data = [IMCacheManage loadCacheWithDirName:kCacheDataDir fileName:kCacheIMUserInfoModel];
    IMUserInfoModel *mCarDetailInfo = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    return mCarDetailInfo;
}

+ (BOOL)setCurrentIMUserInfo:(IMUserInfoModel *)mIMUserInfo
{
    BOOL isSucceed = NO;
    
    if (mIMUserInfo) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mIMUserInfo];
        isSucceed = [IMCacheManage saveCacheWithDirName:kCacheDataDir fileName:kCacheIMUserInfoModel data:data];
    } else {
        [IMCacheManage clearCacheWithDirName:kCacheDataDir fileName:kCacheIMUserInfoModel];
        isSucceed = YES;
    }
    
    return isSucceed;
}

/** 是否进入过商家中心 */
+ (BOOL)currentDealerCeneterIsUsed{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kConfigDealerCenterIsUsed];
}

+ (void)setCurrentDealerCenterIsUsed:(BOOL)isUsed
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isUsed forKey:kConfigDealerCenterIsUsed];
    [userDefaults synchronize];
}

#pragma mark - IM 键盘状态本地保存
+ (NSInteger)currentInputBoxMode{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger inputMode = [userDefaults integerForKey:kIMInputState];
    return inputMode;
}

+ (void)setCurrentInputboxMode:(NSInteger)inputMode{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:inputMode forKey:kIMInputState];
    [userDefaults synchronize];
}

#pragma mark - Cache
/** 读取缓存 */
+ (NSData *)loadCacheWithDirName:(NSString *)dirName fileName:(NSString *)fileName
{
    NSString *filePath = [IMCacheManage isExistsCachePath:dirName fileName:fileName];
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
    NSString *dirPath = [IMCacheManage getCacheDirPath:dirName];
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
    
    filePath = [[IMCacheManage getCacheDirPath:dirName] stringByAppendingPathComponent:fileName.md5];
//#warning 数据库不加密
//    filePath = [[IMCacheManage getCacheDirPath:dirName] stringByAppendingPathComponent:fileName];

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

+ (id)sharedManager
{
    static IMCacheManage *fileCacheManager = nil;
    if (fileCacheManager == nil) {
        fileCacheManager = [[IMCacheManage alloc] init];
    }
    return fileCacheManager;
}

/** 获取缓存数据库路径 */
- (NSString *)currentDBPathByUserID:(NSString *)userid
{
    NSString *fileName = [NSString stringWithFormat:@"%@.sqlite", userid];
    
    NSString *filePath = [IMCacheManage getCacheFilePath:kIMHistoryCacheDataDir fileName:fileName.md5];
//#warning 数据库不加密
//    filePath = [IMCacheManage getCacheFilePath:kIMHistoryCacheDataDir fileName:fileName];
    
    return filePath;
}

- (BOOL)createDBFileIfNessaryByJID:(NSString *)userid
{
    NSString *dbPath = [self currentDBPathByUserID:userid];
    
    if ([FileManager fileExistsAtPath:dbPath]) {
        return YES;
    }
    
    NSString *dbDir = [dbPath stringByDeletingLastPathComponent];
    //如果不存在创建对应的目录，并copy对应的DB文件到相应目录中
    BOOL exists = [FileManager createDirPath:dbDir];
    if (exists) {
        NSString *bundleDBPath = [[NSBundle mainBundle] pathForResource:@"IM" ofType:@"sqlite"];
        return [FileManager copyFilePath:bundleDBPath toFilePath:dbPath];
    }
    return NO;
}

+ (NSString *)getFullJid:(NSString *)jid
{
    return [NSString stringWithFormat:@"%@@%@/%@",jid, [IMCacheManage currentIMUserInfo].domain, kXMPP_USER_RESOURCE];
    
}


@end
