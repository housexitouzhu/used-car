//
//  UCSNHelper.h
//  UsedCar
//
//  Created by Sun Honglin on 14-10-23.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIHelper.h"

@protocol UCSNSHelperDelegate;

@interface UCSNSHelper : NSObject

@property (nonatomic, strong) NSString *title;

/**
 *  @brief  正常的内容, 组织好的 url 和文字
 */
@property (nonatomic, strong) NSString *content;
/**
 *  @brief  没有 url 的纯文字, 主要给 renren 用, renren 平台不自动识别文字里的链接
 */
@property (nonatomic, strong) NSString *contentNoURL;
/**
 *  @brief  微信分享时的内容
 */
@property (nonatomic, strong) NSString *contentWeChat;

/**
 *  @brief  分享用的 URL 链接
 */
@property (nonatomic, strong) NSString *shareURL;
@property (nonatomic, strong) NSString *imageURL;
/**
 *  @brief  如果没有 imageUrl, 用本地的图片替代, 为空也可
 */
@property (nonatomic, strong) UIImage *imageShareIcon;

@property (nonatomic, weak) id<UCSNSHelperDelegate> delegate;

/**
 *  @brief  是否在朋友圈分享时, 使用标题. YES 使用标题, NO 使用内容
 */
@property (nonatomic, assign) BOOL useTitleForWechatTimeLine;

/**
 *  @brief  打开分享功能
 *
 *  @param forAll YES: 默认分享8个平台; NO:默认分享到{微信,朋友圈,新浪微博,短信}
 */
- (void)openShareViewForAllPlatform:(BOOL)forAll;

@end

@protocol UCSNSHelperDelegate <NSObject>

@optional

- (void)UCSNSHelper:(UCSNSHelper*)helper shareSuccessWithChannelType:(SNSChannelType)channelType;
- (void)UCSNSHelper:(UCSNSHelper*)helper shareFailedWithChannelType:(SNSChannelType)channelType;
- (void)UCSNSHelperShareCancelled;

@end