//
//  AppDelegate.m
//  UsedCar
//
//  Created by Alan on 13-10-25.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "MobClick.h"
#import "AMToastView.h"
#import "APIHelper.h"
#import "AMCacheManage.h"
#import "UCMainView.h"
#import "CustomStatusBar.h"
#import "UCAttentionView.h"
#import "SDImageCache.h"
#import "UserInfoModel.h"
#import "UCClaimRecordView.h"
#import "UCUserCenterView.h"
#import "UCSalesLeadsView.h"
#import "AMConfigManage.h"
#import "UCIMHistoryView.h"


@interface AppDelegate ()

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) BOOL isShowToast;
@property (nonatomic) BOOL isCancelUpdate;
@property (nonatomic) BOOL isFromBackground;
@property (nonatomic, strong) NSDictionary *dicNewVersion;
@property (nonatomic, strong) NSString *updatePath;
@property (nonatomic, strong) CustomStatusBar *csbVerson;
@property (nonatomic) BOOL isAlert;
@property (nonatomic, strong) APIHelper *imServer;

@end

@implementation AppDelegate

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    AMLog(@"launchOptions: %@", launchOptions);

    if (IOS7_OR_LATER) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    }
    
    // 外部调用
    NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (url) {
        if ([[url scheme] isEqualToString:@"usedcar"]) {
            // usedcar://searchcar?brandid=1&seriesid=2&specid=3&mileageregion=0-1
            if (url.description.length > 0) {
                _dicLaunchingUsedCar = [[NSMutableDictionary alloc] init];
                
                NSRange range = [url.description rangeOfString:@"searchcar?"];
                if (range.length > 0) {
                    // 存储url
                    _strCarPriceSearchUrl = [NSString stringWithFormat:@"%@", url.description];
                }
            }
            // 处理调用
            [self handleOpenUrl:url];
        }
    }
        
    // 设置标题显示
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    // 清除通知
    [self clearNotification];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:frame];
    self.window.rootViewController = [[MainViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    // 渠道: App Store, 91 Market, Apple Yuan, PP, Tong Bu Tui, XY, AutoHome, Beta
    // 移植到 OMG 里看 OMG 的 define
    
#if DEBUG
    self.strChannel = kChannel_Beta;
    //如果 app 的版本号高于线上版本 而且 渠道时 appstore 就隐藏顶栏通知和分享功能
    [self setValueOfshowSTHonSaleVersion];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    [MobClick updateOnlineConfig]; //更新友盟参数配置

#else
    //根据 app 的 version 号进行适配渠道号 (^0^)/
    
    NSRange betaRange = [APP_VERSION rangeOfString:kChannel_Beta options:NSCaseInsensitiveSearch];
    NSRange tongceRange = [APP_VERSION rangeOfString:kChannel_TongCe options:NSCaseInsensitiveSearch];
    
    if (betaRange.length != 0) {
        self.strChannel = kChannel_Beta;
    }
    else if (tongceRange.length != 0){
        self.strChannel = kChannel_TongCe;
    }
    else{
        //( ´ ▽ ` )ﾉ 根据 scheme 里的 target 不同使用不同的渠道标识 ↓↓↓↓↓
        self.strChannel = kChannel_AppStore;
    }
    
    // 添加用户登录统计
    if ([AMCacheManage currentUserType] == UserStyleBusiness) {
        [UMSAgent bindUserIdentifier:[NSString stringWithFormat:@"d%@", [AMCacheManage currentUserInfo].userid]];
    } else if ([AMCacheManage currentUserType] == UserStylePersonal){
        [UMSAgent bindUserIdentifier:[NSString stringWithFormat:@"p%@", [AMCacheManage currentUserInfo].userid]];
    } else {
        [UMSAgent bindUserIdentifier:@"0"];
    }
    
    // 内部统计
    [UMSAgent setBaseURL:@"http://app.stats.autohome.com.cn/" debugModel:0];
    //[UMSAgent setBaseURL:@"http://10.168.100.181/razor/web/" debugModel:0];
    [UMSAgent startWithAppKey:@"che_ios" ReportPolicy:LOG_REALTIME ChannelId:self.strChannel];
    
    // 友盟统计
    [MobClick startWithAppkey:UM_APP_KEY reportPolicy:REALTIME channelId:self.strChannel];
    [MobClick setAppVersion:APP_VERSION];
    
    //如果 app 的版本号高于线上版本 而且 渠道时 appstore 就隐藏顶栏通知和分享功能
    [self setValueOfshowSTHonSaleVersion];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    [MobClick updateOnlineConfig]; //更新友盟参数配置
    
    
#endif
    
    // 友盟更新
    [self checkUpdate:NO];
    
    // 请求deviceid
    AMLog(@"currentDeviceid %d", [AMCacheManage currentDeviceid]);
    if ([AMCacheManage currentDeviceid] <= 0)
        [[MainViewController sharedVCMain] registDevice];
    
    
    // 注册推送
    if (IOS8_OR_LATER) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
//        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory  alloc] init] ;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    
    if (IOS8_OR_LATER) {
        //"Please use -[UIApplication isRegisteredForRemoteNotifications], or -[UIApplication currentUserNotificationSettings] to retrieve user-enabled remote notification and user notification settings"
        UIUserNotificationSettings *notiSetting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        UIUserNotificationType type =  notiSetting.types;
        if (type == UIUserNotificationTypeNone) {
            AMLog(@"机器本身关掉了推送");
        }
        AMLog(@"currentUserNotificationSettings: %d", type);
    } else {
        UIRemoteNotificationType notificationType = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (notificationType == UIRemoteNotificationTypeNone) {
            AMLog(@"机器本身关掉了推送");
        }
        AMLog(@"enabledRemoteNotificationTypes: %d", notificationType);
    }
    
    
    // 显示版本号
    if (OnTestStatus) {
        _hostType = HostStatus;
        [self showVersion];
    }
    
    
    //设置图片缓存磁盘占用大小
    [[SDImageCache sharedImageCache] setMaxCacheSize:30000000];
    
    //这里是软件后台关闭，收到推送打开后，启动软件会走这里
    if (launchOptions) {
        NSDictionary* pushNotificationKeyDict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        AMLog(@"pushNotificationKeyDict %@", pushNotificationKeyDict);
        
        if (pushNotificationKeyDict) {
            
            NSInteger type = [[pushNotificationKeyDict objectForKey:@"t"] integerValue];
            [self openViewForNotificationWithType:type];
        }
    }
    
//    [self deviceID];
    return YES;
}

///** 友盟集成测试 */
//- (void)deviceID
//{
//    Class cls = NSClassFromString(@"UMANUtil");
//    SEL deviceIDSelector = NSSelectorFromString(@"openUDIDString");
//    NSString *deviceID = nil;
//    if(cls && [cls respondsToSelector:deviceIDSelector]){
//        deviceID = [cls performSelector:deviceIDSelector];
//    }
//    NSLog(@"{\"oid\": \"%@\"}", deviceID);
//}

/** 显示版本 */
- (void)showVersion{
    // 状态栏
    if (!_csbVerson) {
        _csbVerson = [[CustomStatusBar alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 100)/2, 0, 100, 20)];
        _csbVerson.btnStatusMsg.tag = _hostType;
        _csbVerson.btnStatusMsg.backgroundColor = IOS7_OR_LATER ? kColorBlue : [UIColor blackColor];
        _csbVerson.btnStatusMsg.frame = _csbVerson.bounds;
        _csbVerson.userInteractionEnabled = NO;
    }
    
    NSString *strBar = [NSString stringWithFormat:@"%@%@%@", (HostStatus == 0 ? @"线上" : @"线下") , APP_VERSION, APP_BUILD];
    // 环境
    [_csbVerson showStatusMessage:strBar onClickStatueBar:^{
        if (HostStatus != -1) {
            //            [self onClickVersion:_csbVerson.btnStatusMsg];
        }
    }];
    // 隐藏状态栏
    
    // 注掉这部分显示全屏的 welcome
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

///** 更换环境 */
//- (void)onClickVersion:(UIButton *)btn {
//    btn.tag = btn.tag == 0 ? 1 : 0;
//    NSString *strText = nil;
//    switch (btn.tag) {
//        case HostTypeRelease:
//            strText = @"线上";
//            break;
//        case HostTypeTest:
//            strText = @"线下";
//            break;
//    }
//    [APIHelper setHostType:btn.tag];
//
//    //显示版本号
//    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
//    [btn setTitle:[NSString stringWithFormat:@"%@%@", strText, currentVersion] forState:UIControlStateNormal];
//}

#pragma mark - UMSocial
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    AMLog(@"application %@", application);
    // 处理调用
    [self handleOpenUrl:url];
    // 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    AMLog(@"application %@", application);
    // 处理调用
    [self handleOpenUrl:url];
    // 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

#pragma mark - Application Active 状态
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    XMPPManager *xmpp = [XMPPManager sharedManager];
    if (xmpp.xStream.isConnected) {
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
        [xmpp.xStream sendElement:presence];
    }
    
    if (application.applicationIconBadgeNumber > 0) {
        [application setApplicationIconBadgeNumber:0];
    }
    
    AMLog(@"applicationDidBecomeActive %@", application);
    
    AMLog(@"currentDeviceid %d", [AMCacheManage currentDeviceid]);
    
    if (_isAlert) {
        _isAlert = NO;
    } else {
        [UMStatistics event:c_4_0_all_bootmode label:@"Icon"];
    }
    
    //更新友盟参数配置
    [MobClick updateOnlineConfig];
    
    if (_isFromBackground) {
        _isFromBackground = NO;
        // 视图即将显示
        [[MainViewController sharedVCMain].vTop viewWillShow:YES];
        [[MainViewController sharedVCMain].vTop viewDidShow:YES];
    }
    
    // 这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
    [UMSocialSnsService  applicationDidBecomeActive];
    if (self.update == 2 && self.dicNewVersion) {
        NSString *version = [self.dicNewVersion objectForKey:@"version"];
        NSString *update_log = [self.dicNewVersion objectForKey:@"update_log"];
        UIAlertView *vAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"发现新版本 %@", version] message:update_log delegate:self cancelButtonTitle:nil otherButtonTitles:@"立即更新", nil];
        [vAlert show];
    }
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // 如果是商家用户, 在软件每次 active 的时候去刷新保证金状态
    UserInfoModel *userInfo = [AMCacheManage currentUserInfo];
    id lastView = [UCMainView sharedMainView].vContent.subviews.lastObject; //获取上次关闭后, 本次打开的页面, 看是否是 usercenter
    if ([AMCacheManage currentUserType] == UserStyleBusiness && ![lastView isKindOfClass:[UCUserCenterView class]])  {
        [self getUserInfoByUserKey:userInfo.userkey];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    AMLog(@"applicationWillResignActive %@", application);
    
    XMPPManager *xmpp = [XMPPManager sharedManager];
    if (xmpp.xStream.isConnected) {
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
        [xmpp.xStream sendElement:presence];
    }
    
    //app 进入后台, 把这个标记位置为1, 如果直接是 user center 进入后台, 在唤醒后, 刷新用户中心信息
    [AMCacheManage setAppState:1];
    
    _isFromBackground = YES;
    // 视图即将隐藏
    [[MainViewController sharedVCMain].vTop viewWillHide:YES];
    [[MainViewController sharedVCMain].vTop viewDidHide:YES];
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    AMLog(@"applicationDidEnterBackground %@", application);
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    XMPPManager *xmpp = [XMPPManager sharedManager];
    if (!xmpp.xStream.isDisconnected) {
        [xmpp logout];
    }
    
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)){
        // Acquired additional time
        UIDevice *device = [UIDevice currentDevice];
        BOOL backgroundSupported = NO;
        if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
            backgroundSupported = device.multitaskingSupported;
        }
        if (backgroundSupported) {
            _backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
                [application endBackgroundTask:_backgroundTask];
                _backgroundTask = UIBackgroundTaskInvalid;
            }];
        }
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    AMLog(@"applicationWillEnterForeground %@", application);
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    AMLog(@"applicationWillTerminate %@", application);
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    XMPPManager *xmpp = [XMPPManager sharedManager];
    if (!xmpp.xStream.isDisconnected) {
        [xmpp logout];
    }
}


#pragma mark - Application 推送注册
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    AMLog(@"Noti:%@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    //将device token转换为字符串
    NSString *token = [NSString stringWithFormat:@"%@",deviceToken];
    NSCharacterSet *whitespace = [NSCharacterSet  whitespaceAndNewlineCharacterSet];
    token = [token stringByTrimmingCharactersInSet:whitespace];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    AMLog(@"didRegisterForRemoteNotificationsWithDeviceToken:%@", token);
    
    //先获取当前 token 和 当前推送的设置状态
    NSString *currentToken = [AMCacheManage currentToken];
//    AMLog(@"currentToken %@", currentToken);
    // 存储token
    if (token.length > 0 && currentToken == 0){
        [AMCacheManage setToken:token];
        [[MainViewController sharedVCMain] registerDevicePushWithToken];
    }
    /**
     *  这里一定是要分着判断, 上面只是设置 token, 下面是判断是否需要注册 push
     */
    if (![token isEqualToString:currentToken] && currentToken != 0){
        [AMCacheManage setToken:token];
        [[MainViewController sharedVCMain] registPush];
    }
    else if ([AMCacheManage currentPushStatus] == ConfigPushStatusNOTSET){
        [[MainViewController sharedVCMain] registerDevicePushWithToken];
    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    NSLog(@"AAAAAAAAAAAA-%@", userInfo);

    _isAlert = YES;
    [self clearNotification]; //如果 app 在打开的状态下清除系统的提示, 使用下面的软件自己的 statusbar 的提示
    
    AMLog(@"didReceiveRemoteNotification:%@", userInfo);
    
    //如果状态不是 active,也就是 app 没有在前台激活状态(从后台唤起的), 就启动对应的页面来显示
    
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    // 做 app 状态的判断,
    if (state != UIApplicationStateActive) {
        NSInteger type = [[userInfo objectForKey:@"t"] integerValue];
        [self openViewForNotificationWithType:type];
    }
    else{
        // 这里把提示交给 app 自己的提示, 在 mainview 的方法里判断消息的类型, 以及提示的内容
        UCMainView *mainView = [UCMainView sharedMainView];
        [mainView updateStatusBarForPushNotificationWithInfo:userInfo];
    }
}

/** 注销，日后研究
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"BBBBBBBBBBBBBBB-%@", userInfo);
    
    _isAlert = YES;
    [self clearNotification]; //如果 app 在打开的状态下清除系统的提示, 使用下面的软件自己的 statusbar 的提示
    
    //如果状态不是 active,也就是 app 没有在前台激活状态(从后台唤起的), 就启动对应的页面来显示
    
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    // 做 app 状态的判断,
    if (state != UIApplicationStateActive) {
        NSLog(@"state != UIApplicationStateActive");
        NSInteger type = [[userInfo objectForKey:@"t"] integerValue];
        [self openViewForNotificationWithType:type];
    }
    else{
        NSLog(@"state == UIApplicationStateActive");
        // 这里把提示交给 app 自己的提示, 在 mainview 的方法里判断消息的类型, 以及提示的内容
        UCMainView *mainView = [UCMainView sharedMainView];
        [mainView updateStatusBarForPushNotificationWithInfo:userInfo];
    }
    
}
 */

#pragma mark - 其他 actions method
/* 处理外部调用 */
- (BOOL)handleOpenUrl:(NSURL *)url
{
    AMLog(@"###: %@", url);
    
    BOOL isCanLaunch = NO;
    
    // 初次启动时不进入此方法
    if (_strCarPriceSearchUrl.length == 0) {
        if (url.description.length > 0) {
            
            if (!_dicLaunchingUsedCar)
                _dicLaunchingUsedCar = [[NSMutableDictionary alloc] init];
            
            NSRange range = [url.description rangeOfString:@"searchcar?"];
            if (range.length > 0) {
                // 存储url
                _strCarPriceSearchUrl = [NSString stringWithFormat:@"%@", url.description];
                // 根据新车报价条件查询二手车
                isCanLaunch = [[UCMainView sharedMainView] searchCarListFromCarPriceApp];
            }
            // 商家页
            NSRange range2 = [url.description rangeOfString:@"dealerStore?"];
            if (range2.length > 0) {
                [_dicLaunchingUsedCar setValue:url.description forKey:@"dealerStore"];
                [AMConfigManage showDealerStoreView];
            }
            // 车详情页
            NSRange range3 = [url.description rangeOfString:@"cardetail?"];
            if (range3.length > 0) {
                [_dicLaunchingUsedCar setValue:url.description forKey:@"cardetail"];
                [AMConfigManage showCarDetailView];
            }
        }
    }
    
    // 默认可以打开应用
    return YES;
}

// 根据推送打开对应的页面
-(void)openViewForNotificationWithType:(NSInteger)type{
    
    /**
     *  type: 1 车源关注 2 未完结投诉 3 已完结投诉
     */
    switch (type) {
        case 1:
        {
            UCAttentionView *vAttention = [[UCAttentionView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds UCAttentionViewLeftButtonStyle:UCAttentionViewLeftButtonStyleClose];
            [vAttention setViewStyle:UCAttentionViewSytleMainView];
            [vAttention setShouldClearNotifyMarkAfterClose:YES];
            [[MainViewController sharedVCMain] openView:vAttention animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
            [UMStatistics event:c_4_0_all_bootmode label:@"Push-订阅"];
        }
            break;
        case 2:
        {
            UCClaimRecordView *claimView = [[UCClaimRecordView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds withStyle:UCClaimRecordViewStylePopUp ClaimType:ClaimListTypeOnGoing];
            [claimView setShouldClearNotifyMarkAfterClose:YES];
            [[MainViewController sharedVCMain] openView:claimView animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
            [UMStatistics event:c_4_0_all_bootmode label:@"Push-保证金"];
        }
            break;
        case 3:
        {
            UCClaimRecordView *claimView = [[UCClaimRecordView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds withStyle:UCClaimRecordViewStylePopUp ClaimType:ClaimListTypeFinished];
            [claimView setShouldClearNotifyMarkAfterClose:YES];
            [[MainViewController sharedVCMain] openView:claimView animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
            [UMStatistics event:c_4_0_all_bootmode label:@"Push-保证金"];
        }
            break;
        case 4:
        {
            if (![[MainViewController sharedVCMain].vTop isKindOfClass:[UCIMHistoryView class]]) {
                UCIMHistoryView *vIMHistory = [[UCIMHistoryView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds];
                [[MainViewController sharedVCMain] openView:vIMHistory animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
            }
        }
            break;
        case 5:
        {
            UCSalesLeadsView *leadView = [[UCSalesLeadsView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds backButtonType:BackButtonTypeClose];
            [[MainViewController sharedVCMain] openView:leadView animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
            [UMStatistics event:c_4_0_all_bootmode label:@"Push-销售线索"];
        }
            break;
        default:
            
            
            break;
    }
}

/* 清除通知 */
- (void)clearNotification
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

/* 注册push */
- (void)submitToken:(NSString *)token
{
    NSCharacterSet *whitespace = [NSCharacterSet  whitespaceAndNewlineCharacterSet];
    token = [token stringByTrimmingCharactersInSet:whitespace];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    AMLog(@"%@ %@", [OMG openUDID], token);
    
    APIHelper *apiSubmitToken = [[APIHelper alloc] init];
    [apiSubmitToken submitToken:token];
}

/* 友盟检查更新 */
- (void)checkUpdate:(BOOL)isShowToast
{
    if ([APIHelper isNetworkAvailable]) {
        _isCancelUpdate = NO;
        _isShowToast = isShowToast;
        if(isShowToast)
            [[AMToastView toastView:YES] showLoading:@"检查更新中…" cancel:^{
                [self cancelCheckUpdate];
            }];
        [MobClick checkUpdateWithDelegate:self selector:@selector(receiveVersion:)];
    } else if (isShowToast) {
        [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
    }
    
}

#pragma mark - 友盟检查更新
/* 取消友盟检查更新 */
- (void)cancelCheckUpdate
{
    _isCancelUpdate = YES;
    _isShowToast = NO;
    [[AMToastView toastView] hide];
}

- (void)receiveVersion:(NSDictionary *)dic{
    self.dicNewVersion = dic;
    if (_isShowToast || !_isCancelUpdate)
        [self performSelectorOnMainThread:@selector(showNewVersionAlert) withObject:nil waitUntilDone:YES];
}

- (void)showNewVersionAlert{
    //    "current_version" = "1.0 beta5";
    //    path = "http://www.autohome.com.cn";
    //    update = YES;
    //    "update_log" = "\U6d4b\U8bd5\U66f4\U65b0\U7248\U672c";
    //    version = "2.0";
    
    //NSString *current_version = [dic objectForKey:@"current_version"];
    
    //    "current_version" = "1.1 beta8";
    //    path = "http://www.autohome.com.cn";
    
    self.updatePath = [self.dicNewVersion objectForKey:@"path"];
    NSString *version = [self.dicNewVersion objectForKey:@"version"];
    NSString *update_log = [self.dicNewVersion objectForKey:@"update_log"];
    self.update = [[self.dicNewVersion objectForKey:@"update"] boolValue] ? 1 : 0;
    
    //!!!这里做的处理的是为了兼容3.9.3版本错误的使用了 build 号作为版本号 去掉100.4.x 的版本前面的100
    if (version.length > 3) {
        NSString *sub100Str = [version substringWithRange:NSMakeRange(0, 3)];
        if (sub100Str.integerValue == 100) {
            version = [version substringFromIndex:4];
            //100.4.0.1
            //012345678
        }
    }
    
    //为了兼容100.*.*的版本号，这里手动去匹配一下获取到的版本号如果相等就设置 self.update 为 NO。就不会弹出提示了
    if (APP_VERSION_GREATER_THAN_OR_EQUAL_TO(version)) {
        self.update = NO;
    }
    
    //是否有更新
    if (self.update > 0) {
        [[AMToastView toastView] hide];
        
        UIAlertView *vAlert = nil;
        NSString *lastChar = [update_log substringFromIndex:update_log.length - 1];
        if ([lastChar isEqualToString:@" "]) {
            self.update = 2; //强制更新
            vAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"发现新版本 %@", version] message:update_log delegate:self cancelButtonTitle:nil otherButtonTitles:@"立即更新", nil];
        } else {
            vAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"发现新版本 %@", version] message:update_log delegate:self cancelButtonTitle:@"以后再说" otherButtonTitles:@"立即更新", nil];
        }
        
        [vAlert show];
    } else {
        if (_isShowToast)
            [[AMToastView toastView] showMessage:@"当前为最新版本" icon:kImageRequestSuccess duration:AMToastDurationNormal];
    }
    _isCancelUpdate = YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //版本更新
    if (alertView.cancelButtonIndex != buttonIndex) {
        NSURL *url = [NSURL URLWithString:self.updatePath];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - 再次获取商家的基本信息 更新商家的 model 检查是否是保证金商家
// 再次获取商家的基本信息 更新商家的 model 检查是否是保证金商家
- (void)getUserInfoByUserKey:(NSString*)userKey{
    if (!_apiUserInfo) {
        _apiUserInfo = [[APIHelper alloc] init];
    }
    
    [_apiUserInfo setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase) {
                if (mBase.returncode == 0) {
                    UserInfoModel *tempUserInfo = [[UserInfoModel alloc] initWithJson: mBase.result];
                    UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
                    
                    NSDateFormatter *dateFormatter = [OMG defaultDateFormatter];
                    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
                    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];

                    if (mUserInfo) {
                        if (currentDateStr) mUserInfo.updatetime                    = currentDateStr;
                        if (tempUserInfo.userid) mUserInfo.userid                   = tempUserInfo.userid;
                        if (tempUserInfo.username) mUserInfo.username               = tempUserInfo.username;
                        if (tempUserInfo.mobile) mUserInfo.mobile                   = tempUserInfo.mobile;
                        if (tempUserInfo.carnotpassed) mUserInfo.carnotpassed       = tempUserInfo.carnotpassed;
                        if (tempUserInfo.carsaleing) mUserInfo.carsaleing           = tempUserInfo.carsaleing;
                        if (tempUserInfo.type) mUserInfo.type                       = tempUserInfo.type;
                        if (tempUserInfo.salespersonlist) mUserInfo.salespersonlist = tempUserInfo.salespersonlist;
                        if (tempUserInfo.bdpmstatue) mUserInfo.bdpmstatue           = tempUserInfo.bdpmstatue;
                        if (tempUserInfo.carinvalid) mUserInfo.carinvalid           = tempUserInfo.carinvalid;
                        if (tempUserInfo.isbailcar) mUserInfo.isbailcar             = tempUserInfo.isbailcar;
                        if (tempUserInfo.carsaled) mUserInfo.carsaled               = tempUserInfo.carsaled;
                        if (tempUserInfo.carchecking) mUserInfo.carchecking         = tempUserInfo.carchecking;
                        if (tempUserInfo.code) mUserInfo.code                       = tempUserInfo.code;
                        if (tempUserInfo.dealerid) mUserInfo.dealerid               = tempUserInfo.dealerid;
                        [AMCacheManage setCurrentUserInfo:mUserInfo];
                    } else {
                        tempUserInfo.updatetime = currentDateStr;
                        [AMCacheManage setCurrentUserInfo:tempUserInfo];
                    }                   
                }
            }
        }
    }];
    
    [_apiUserInfo getUserInfo];
    
}

#pragma mark - 根据友盟参数设置是否启动通知
- (void)onlineConfigCallBack:(NSNotification*)notification{
    
    [self setValueOfshowSTHonSaleVersion];
}

- (void)setValueOfshowSTHonSaleVersion{
    
//    AMLog(@"APP_VERSION_GREATER_THAN %d", APP_VERSION_GREATER_THAN([MobClick getConfigParams:@"onSaleVersion"]));
    //友盟的更新有点儿延迟
    if (APP_VERSION_GREATER_THAN([MobClick getConfigParams:@"onSaleVersion"]) && [self.strChannel isEqualToString:kChannel_AppStore]) {
        self.showSTHonSaleVersion = NO;
    }
    else{
        self.showSTHonSaleVersion = YES;
    }
//    AMLog(@"showSTHonSaleVersion %d", self.showSTHonSaleVersion);
}


@end