//
//  AppDelegate.h
//  UsedCar
//
//  Created by Alan on 13-10-25.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIHelper.h"

@class APIHelper;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) NSInteger update;
@property (nonatomic, strong) NSString * strCarPriceSearchUrl;
@property (nonatomic) HostType hostType;
@property (nonatomic, strong) APIHelper *apiUserInfo;
@property (nonatomic, strong) NSString *strChannel;
@property (nonatomic) BOOL showSTHonSaleVersion; //是否显示状态栏通知和分享按钮
// 外部跳转到二手车App
@property (nonatomic, strong) NSMutableDictionary *dicLaunchingUsedCar;

+ (AppDelegate *)sharedAppDelegate;

- (void)checkUpdate:(BOOL)isShowToast;

@end
