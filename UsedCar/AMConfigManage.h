//
//  AMConfigManage.h
//  UsedCar
//
//  Created by Alan on 14-5-21.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMConfigManage : NSObject

+ (AMConfigManage *)sharedConfigManage;

+ (void)setUserInfo;
/** 导入旧版本收藏数据 */
+ (void)importOldFavourates;
/** 增量更新车型 */
+ (void)updateCar;
/** 同步通话记录 */
+ (void)updateCallRecords;
/** 显示商家中心页面 */
+ (void)showDealerStoreView;
/** 显示车源页面 */
+ (void)showCarDetailView;

@end
