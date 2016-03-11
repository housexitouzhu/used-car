//
//  UCIMRootEntry.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCClientVerifyView.h"

@class UCCarDetailInfoModel;

typedef enum : NSUInteger {
    OpenViewTypeNone,
    OpenViewTypeChatRoot,
    OpenViewTypeChatRootHisroty,
    OpenViewTypeChatHistory,
} OpenViewType;

@interface UCIMRootEntry : NSObject <UCClientVerifyViewDelegate>

/**
 *  新建聊天页面
 *
 *  @param mCarInfo 车源实体
 */
- (void)openChatRootByVerified:(UCCarDetailInfoModel *)mCarInfo;

/**
 *  打开IM历史记录页
 */
- (void)openChatHistoryByVerified;

/**
 *  打开商家验证
 */
- (void)openVerifyDealerPermissionView;

@end
