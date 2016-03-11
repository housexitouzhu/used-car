//
//  IMCacheManage.h
//  UsedCar
//
//  Created by 张鑫 on 14/11/19.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMUserInfoModel.h"

#define kCacheDataDir             @"Data"
#define kIMHistoryCacheDataDir    @"IM"
#define kCacheIMUserInfoModel     @"kCacheIMUserInfoModel"
#define kConfigDealerCenterIsUsed @"kConfigDealerCenterIsUsed"
/** IM 输入状态 */
#define kIMInputState @"kIMInputState"

@interface IMCacheManage : NSObject

+ (IMUserInfoModel *)currentIMUserInfo;
+ (BOOL)setCurrentIMUserInfo:(IMUserInfoModel *)mIMUserInfo;

/** 是否进入过商家中心 */
+ (BOOL)currentDealerCeneterIsUsed;
+ (void)setCurrentDealerCenterIsUsed:(BOOL)isUsed;

#pragma mark - IM 键盘状态本地保存
+ (NSInteger)currentInputBoxMode;
+ (void)setCurrentInputboxMode:(NSInteger)inputMode;

+ (id)sharedManager;

/*!
 *  @method
 *  @abstract  获取当前登陆用户的数据库DB文件路径
 *  @return DB的路径
 */
- (NSString *)currentDBPathByUserID:(NSString *)userid;

/*!
 *  @method
 *  @abstract  创建对应的数据库文件
 *  @return 是否创建成功
 */
- (BOOL)createDBFileIfNessaryByJID:(NSString *)userid;

+ (NSString *)getFullJid:(NSString *)jid;

@end
