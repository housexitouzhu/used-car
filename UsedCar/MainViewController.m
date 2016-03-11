//
//  MainViewController.m
//  UsedCar
//
//  Created by Alan on 13-10-25.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "MainViewController.h"
#import "UCMainView.h"
#import "UCView.h"
#import "AMConfigManage.h"

#import "APIHelper.h"
#import "AMCacheManage.h"
#import "DatabaseHelper1.h"
#import "UCWelcome.h"
#import "UCHelpPromptView.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialData.h"
#import "WXApi.h"

#define kTransformScale 0.95
#define kTransformAlpha 0.5

@interface MainViewController ()

@property (nonatomic, strong) APIHelper *apiRegistDevice;
@property (nonatomic, strong) APIHelper *apiRegistPush;
@property (nonatomic, strong) APIHelper *apiLogout;
@property (nonatomic, strong) NSDictionary *wxsessionContent;

@end

@implementation MainViewController

static MainViewController *vcMain = nil;
+ (MainViewController *)sharedVCMain
{
    return vcMain;
}

#pragma mark - initView
- (id)init
{
    self = [super init];
    if (self) {
        vcMain = self;
        // 设置用户信息
        [AMConfigManage setUserInfo];
        // 导入旧版本收藏
        [AMConfigManage importOldFavourates];
        // 同步通话记录
        [AMConfigManage updateCallRecords];
        // 设置友盟分享
        [self setUMSocia];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    _vMain = [[UIView alloc] initWithFrame:frame];
    _vMain.backgroundColor = kColorWhite;
    [self.view addSubview:_vMain];
    
    UCMainView *vMain = [[UCMainView alloc] initWithFrame:_vMain.bounds];
    [self openView:vMain animateOption:AnimateOptionMoveNone removeOption:RemoveOptionNone];
    
    // 当前应用版本号
    if (![APP_VERSION isEqual:[AMCacheManage currentConfigVersion]]) {
        // 删除车型库
        NSString *fileName = [NSString stringWithFormat:@"Cars.sqlite"];
        [AMCacheManage clearCacheWithDirName:kCacheDataDir fileName:fileName];
        // 重置当前版本的启动次数
        [AMCacheManage setCurrentVersionStartNumber:0];
        // 展示新版本动画
        [AMCacheManage setCurrentIsUsed:NO];
        // 设置配置版本号与应用一致
        [AMCacheManage setConfigVersion:APP_VERSION];
    }
    
    /*
     #warning 是否显示夜间模式提醒
     // 是否显示夜间模式提醒
     if (![[NSUserDefaults standardUserDefaults] boolForKey:kConfigIsShowNightPrompt]) {
     // 当前时间
     NSDate *date = [NSDate date];
     NSTimeZone *zone = [NSTimeZone systemTimeZone];
     NSInteger interval = [zone secondsFromGMTForDate: date];
     NSDate *dateNow = [date dateByAddingTimeInterval: interval];
     // 9点
     NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
     NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
     [gregorian setTimeZone:gmt];
     NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: dateNow];
     [components setHour: 21];
     [components setMinute:0];
     [components setSecond: 0];
     NSDate *dateNight = [gregorian dateFromComponents: components];
     BOOL isNight = [dateNow laterDate:dateNight] == dateNow;
     
     if (isNight) {
     UCHelpPromptView *vHelpPrompt = [[UCHelpPromptView alloc] initWithFrame:_vMain.bounds UCHelpPromptViewTag:UCHelpPromptViewTagNightMode];
     [_vMain addSubview:vHelpPrompt];
     }
     }
     */
    
    // 有引导页
    if (IntroGuide) {
        if (![AMCacheManage currentIsUsed]) {
            // 隐藏状态栏
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            
            UCWelcome *vWelcome = [[UCWelcome alloc] initWithFrame:[UIScreen mainScreen].bounds];
            vWelcome.delegate = _welcomeDelegate;
            [_vMain addSubview:vWelcome];
        }
    }
    // 无引导页
    else {
        if (![AMCacheManage currentIsUsed]) {
            // 打开定位 & 开启定时器
            [[UCMainView sharedMainView].vHome didCloseWelcomeView:nil];
            
            [AMCacheManage setCurrentIsUsed:YES];
        }
    }
    
    // 打开蒙层
    [vMain.vHome openMaskView];
    // 求赞
    [self requestPraise];
    // 手势方法
    [self addPanGestureRecognizer];
    // 增量更新车型
    [AMConfigManage updateCar];
    
}

#pragma mark - method public
- (void)openView:(UCView *)view animateOption:(AnimateOption)animateOption removeOption:(RemoveOption)removeOption
{
    view.showViewAnimated = animateOption;
    // 顶层视图
    _vTop = view;
    // 添加视图到根视图
    [_vMain addSubview:view];
    // 次层视图(位于顶层下面)
    UCView *vSecond = nil;
    NSUInteger index = [_vMain.subviews indexOfObject:view];
    if (index > 0 && index != NSNotFound) {
        vSecond = [_vMain.subviews objectAtIndex:index - 1];
        if ([vSecond isKindOfClass:[UCView class]])
            // 次层视图即将隐藏
            [vSecond viewWillHide:YES];
        else
            vSecond = nil;
    }
    
    // 顶层视图即将显示
    [view viewWillShow:YES];
    
    switch (animateOption) {
        case AnimateOptionMoveNone:
            break;
        case AnimateOptionMoveLeft:
            view.minX = _vMain.width;
            view.minY = 0;
            break;
        case AnimateOptionMoveRight:
            view.maxX = 0;
            break;
        case AnimateOptionMoveDown:
            view.maxY = 0;
            break;
        case AnimateOptionMoveUp:
            view.minY = _vMain.height;
            break;
        default:
            break;
    }
    
    // 执行动画
    NSTimeInterval animateSpeed = (animateOption == AnimateOptionMoveLeft || animateOption == AnimateOptionMoveRight) ? 0.2 : 0.3;
    [UIView animateWithDuration:animateSpeed animations:^{
        if (animateOption == AnimateOptionMoveLeft || animateOption == AnimateOptionMoveRight) {
            if (vSecond)
                vSecond.minX = view.minX / -2;
            view.minX = 0;
        } else if (animateOption == AnimateOptionMoveDown || animateOption == AnimateOptionMoveUp) {
            view.minY = 0;
        }
        //        if (subview) {
        //            subview.transform = CGAffineTransformMakeScale(kTransformScale, kTransformScale);
        //            //subview.alpha = kTransformAlpha;
        //        }
    } completion:^(BOOL finished) {
        // 顶层视图已显示
        [view viewDidShow:YES];
        
        if (removeOption == RemoveOptionNone) {
            //            subview.hidden = YES;
            // 次层视图已隐藏
            [vSecond viewDidHide:YES];
        } else {
            NSInteger target = removeOption == RemoveOptionPrevious ? index - 1 : 0;
            for (NSInteger i = index - 1; i >= target; i--) {
                UCView *ucv = [_vMain.subviews objectAtIndex:i];
                // 次层视图已隐藏
                [ucv viewWillHide:YES];
                [ucv viewDidHide:YES];
                [ucv viewWillClose:YES];
                [ucv removeFromSuperview];
            }
        }
    }];
}

- (void)closeView:(UCView *)view animateOption:(AnimateOption)animateOption
{
    
    AnimateOption animateTemp = animateOption == AnimateOptionMoveAuto ? view.showViewAnimated : animateOption;
    
    NSUInteger index = [_vMain.subviews indexOfObject:view];
    if (index > 0 && index != NSNotFound) {
        _vTop = [_vMain.subviews objectAtIndex:index - 1];
        //        _vTop.hidden = NO;
        // 顶层视图即将显示
        [_vTop viewWillShow:YES];
        
        // 次层视图即将隐藏
        view = _vMain.subviews.lastObject;
        [view viewWillHide:YES];
        
        // 移除中间夹层, 留最上层视图做动画
        while (_vMain.subviews.count - 2 >= index) {
            UCView *ucv = [_vMain.subviews objectAtIndex:_vMain.subviews.count - 2];
            // 中间夹层视图即将隐藏
            [ucv viewWillHide:YES];
            [ucv viewDidHide:YES];
            [ucv viewWillClose:YES];
            [ucv removeFromSuperview];
        }
    } else {
        _vTop = nil;
    }
    
    NSTimeInterval animateSpeed = (animateTemp == AnimateOptionMoveLeft || animateTemp == AnimateOptionMoveRight) ? 0.2 : 0.3;
    [UIView animateWithDuration:animateSpeed animations:^{
        if (_vTop) {
            _vTop.transform = CGAffineTransformMakeScale(1, 1);
            _vTop.minX = 0;
        }
        
        switch (animateTemp) {
            case AnimateOptionMoveNone:
                break;
            case AnimateOptionMoveLeft:
                view.minX = _vMain.width;
                break;
            case AnimateOptionMoveRight:
                view.maxX = 0;
                break;
            case AnimateOptionMoveDown:
                view.maxY = 0;
                break;
            case AnimateOptionMoveUp:
                view.minY = _vMain.height;
                break;
            default:
                break;
        }
    } completion:^(BOOL finished) {
        // 顶层视图已显示
        [_vTop viewDidShow:YES];
        // 次层视图即将隐藏
        [view viewDidHide:YES];
        [view viewWillClose:YES];
        [view removeFromSuperview];
    }];
}

/** 替换视图 */
- (void)replaceView:(UCView *)view1 withView:(UCView *)view2 superview:(UIView *)superview
{
    // 优先使用view1.superview, 为nil时使用superview
    if (view1.superview || superview) {
        if (view1.superview)
            [view1 viewWillHide:YES];
        
        [view2 viewWillShow:YES];
        
        if (view1.superview)
            [view1.superview insertSubview:view2 aboveSubview:view1];
        else if (superview)
            [superview addSubview:view2];
        
        [view2 viewDidShow:YES];
        
        if (view1.superview) {
            [view1 viewDidHide:YES];
            [view1 viewWillClose:YES];
            [view1 removeFromSuperview];
        }
    }
}

/** 获取view下层布局 */
- (UIView *)aboveSubview:(UIView *)view
{
    UIView *aboveSubview = nil;
    NSUInteger index = [_vMain.subviews indexOfObject:view];
    if (index > 0)
        aboveSubview = [_vMain.subviews objectAtIndex:index - 1];
    return aboveSubview;
}

/** 获取view上层布局 */
- (UIView *)belowSubview:(UIView *)view
{
    UIView *belowSubview = nil;
    NSUInteger index = [_vMain.subviews indexOfObject:view];
    if (_vMain.subviews.count > index + 1)
        belowSubview = [_vMain.subviews objectAtIndex:index + 1];
    return belowSubview;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

/** 求赞 */
- (void)requestPraise
{
    NSInteger startNumer = [AMCacheManage currentVersionStartNumber];
    if (startNumer > 1) {
        // 求赞提示框
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"看在我们兢兢业业为您找好车的份上，给个好评吧，亲！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"稍后再去", @"残忍拒绝", @"马上给好评", nil];
        [alertView show];
    }
    // 值为-1时代表已评或残忍拒绝
    else if (startNumer >= 0){
        [AMCacheManage setCurrentVersionStartNumber:++startNumer];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 || buttonIndex == 2) {
        [AMCacheManage setCurrentVersionStartNumber:-1];
        if (buttonIndex == 2) {
            [[MainViewController sharedVCMain] showAppStore:@"455177952" type:1];
        }
    }
}

- (void)showShareList:(NSString *)text imageUrl:(NSString *)imageUrl url:(NSString *)url wxsessionContent:(NSDictionary *)wxsessionContent
{
    //     NSString *shareText = @"Test share...";
    //    UIImage *shareImage = [UIImage imageNamed:@"aboutus_icon"];
    
    if (!_wxsessionContent)
        _wxsessionContent = [NSDictionary dictionaryWithDictionary:wxsessionContent];
    else
        _wxsessionContent = wxsessionContent;
    
    NSString *title = @"二手车之家精品车源";
    
    // 设置分享标题
    [UMSocialData defaultData].extConfig.qzoneData.title = title;
    [UMSocialData defaultData].extConfig.qzoneData.url = url;
    [UMSocialData defaultData].extConfig.renrenData.url = url;
    [UMSocialData defaultData].extConfig.emailData.title = title;
    [UMSocialData defaultData].extConfig.wechatSessionData.title = [wxsessionContent objectForKey:@"title"];
    if (imageUrl.length > 0)
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
    else
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeDefault];
    
    // 分享到微信设置url
    [UMSocialWechatHandler setWXAppId:@"wx7ea3320364626402" appSecret:@"82a1f7a4f98d61c103a37d17fc0b298d" url:url];
    
    
    NSMutableArray *names = [NSMutableArray array];
    [names addObject:UMShareToSina];
    
    if ([QQApi isQQInstalled])
        [names addObject:UMShareToQzone];
    
    [names addObject:UMShareToTencent];
    
    if ([WXApi isWXAppInstalled]) {
        [names addObject:UMShareToWechatSession];
        [names addObject:UMShareToWechatTimeline];
    }
    
    [names addObject:UMShareToRenren];
    [names addObject:UMShareToEmail];
    [names addObject:UMShareToSms];
    
    //如果得到分享完成回调，需要设置delegate为self
    [UMSocialSnsService presentSnsIconSheetView:self appKey:UM_APP_KEY shareText:text shareImage:nil shareToSnsNames:names delegate:self];
}

#pragma mark - method private
- (void)setUMSocia
{
    //    //打开调试log的开关
    //    #warning 测试
    //    [UMSocialData openLog:YES];
    
    //如果你要支持不同的屏幕方向，需要这样设置，否则在iPhone只支持一个竖屏方向
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
    
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:UM_APP_KEY];
    
    //设置微信AppId
    [UMSocialWechatHandler setWXAppId:@"wx7ea3320364626402" appSecret:@"82a1f7a4f98d61c103a37d17fc0b298d" url:@"http://www.che168.com"];
    //设置手机QQ的AppId 二手车之家ID:100588656(无权限,暂用友盟大号100424468分享)
    //[UMSocialConfig setQQAppId:@"100424468" url:@"http://www.che168.com" importClasses:@[[QQApiInterface class],[TencentOAuth class]]];
    
    //打开新浪微博的SSO开关
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:@"100424468" appKey:UM_APP_KEY url:@"http://www.che168.com"];
    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    [UMSocialConfig setFinishToastIsHidden:YES position:UMSocialiToastPositionCenter];
}

// 分享完毕
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if (response.responseCode == UMSResponseCodeSuccess)
        [[AMToastView toastView] showMessage:@"分享成功" icon:kImageRequestSuccess duration:AMToastDurationNormal];
    else if (response.responseCode == UMSResponseCodeNetworkError)
        [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
    else if (response.responseCode == UMSResponseCodeShareRepeated)
        [[AMToastView toastView] showMessage:@"分享内容重复" icon:kImageRequestError duration:AMToastDurationNormal];
    else if (response.responseCode != UMSResponseCodeCancel)
        [[AMToastView toastView] showMessage:@"分享失败" icon:kImageRequestError duration:AMToastDurationNormal];
}

/** 截获分享渠道 */
-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    // 微信好友特殊处理
    if ([platformName isEqualToString:@"wxsession"]) {
        socialData.shareText = [_wxsessionContent objectForKey:@"shareText"];
    }
}

#pragma mark - APIHelper
///** 注册推送设备 */
//- (void)registDeviceAndRegistPush:(BOOL)isNeedRegistPush
//{
//    if (!_apiRegistDevice)
//        _apiRegistDevice = [[APIHelper alloc] init];
//
//    __weak MainViewController *vcMain = self;
//    // 设置请求完成后回调方法
//    [_apiRegistDevice setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
//        if (error) {
//            AMLog(@"%@",error.domain);
//            return;
//        }
//
//        if (apiHelper.data.length > 0) {
//            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
//            if (mBase) {
//                if (mBase.returncode == 0) {
//                    NSInteger deviceid = [[mBase.result objectForKey:@"deviceid"] integerValue];
//                    if (deviceid > 0 && [AMCacheManage currentDeviceid] != deviceid) {
//                        // 存储deviceid
//                        [AMCacheManage setDeviceid:deviceid];
//                        AMLog(@"新添加或修改设备id成功");
//                        // 注册push
//                        if (isNeedRegistPush)
//                            [vcMain registPush];
//                    }
//                    AMLog(@"注册设备成功");
//                }
//            }
//        }
//    }];
//    // 注册设备id
//    [_apiRegistDevice registDeviceWithPid:nil cid:nil];
//}

- (void)registDevice
{
    if (!_apiRegistDevice)
        _apiRegistDevice = [[APIHelper alloc] init];
    
    // 设置请求完成后回调方法
    [_apiRegistDevice setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            AMLog(@"%@",error.domain);
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            AMLog(@"registDevice mBase %@", mBase);
            if (mBase) {
                if (mBase.returncode == 0) {
                    NSInteger deviceid = [[mBase.result objectForKey:@"deviceid"] integerValue];
                    if (deviceid > 0 && [AMCacheManage currentDeviceid] != deviceid) {
                        // 存储deviceid
                        [AMCacheManage setDeviceid:deviceid];
                        
                        AMLog(@"新添加或修改设备id成功");
                    }
                    AMLog(@"注册设备成功");
                }
            }
        }
    }];
    // 注册设备id
    [_apiRegistDevice registDeviceWithPid:nil cid:nil];
}

-(void)registerDevicePushWithToken{
    if (!_apiRegistDevice)
        _apiRegistDevice = [[APIHelper alloc] init];
    
    __weak typeof(self) weakSelf = self;
    // 设置请求完成后回调方法
    [_apiRegistDevice setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            AMLog(@"%@",error.domain);
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            AMLog(@"registerDevicePushWithToken mBase %@", mBase);
            if (mBase) {
                if (mBase.returncode == 0) {
                    NSInteger deviceid = [[mBase.result objectForKey:@"deviceid"] integerValue];
                    if (deviceid > 0 && [AMCacheManage currentDeviceid] != deviceid) {
                        // 存储deviceid
                        [AMCacheManage setDeviceid:deviceid];
                        
                        AMLog(@"新添加或修改设备id成功");
                    }
                    AMLog(@"注册设备成功 %d", deviceid);
                    
                    //注册 push
                    [weakSelf registPush];
                }
            }
        }
    }];
    // 注册设备id
    [_apiRegistDevice registDeviceWithPid:nil cid:nil];
}

/** 根据用户id注册push */
- (void)registPush
{
    if (!_apiRegistPush)
        _apiRegistPush = [[APIHelper alloc] init];
    
    ConfigPushStatus pushStatus = [AMCacheManage currentPushStatus];
    __weak typeof(self) weakSelf = self;
    
    // 设置请求完成后回调方法
    [_apiRegistPush setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            AMLog(@"%@",error.domain);
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                AMLog(@"registPush mBase %@", mBase);
                NSString *message = nil;
                // 登录成功
                if (mBase.returncode == 0){
                    if (pushStatus == ConfigPushStatusOFF) {
                        [weakSelf updatePushStatusToOFF];
                    }
                    else{
                        [AMCacheManage setPushStatus:ConfigPushStatusON];
                        AMLog(@"\n*** 注册通知^_^ ***\n");
                    }
                }
                if (message)
                    AMLog(@"注册失败-_-：%@", message);
            }
        }
    }];
    // 注册push
    [_apiRegistPush registPush];
}

-(void)updatePushStatusToOFF{
    if (!_apiRegistPush)
        _apiRegistPush = [[APIHelper alloc] init];
    
    // 设置请求完成后回调方法
    [_apiRegistPush setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            AMLog(@"%@",error.domain);
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                NSString *message = nil;
                
                // 关闭成功
                if (mBase.returncode == 0){
                    [AMCacheManage setPushStatus:ConfigPushStatusOFF];
                    AMLog(@"\n*** 取消通知成功 ***\n");
                }
                if (message){
                    AMLog(@"取消注册失败-_-：%@", message);
                }
            }
        }
    }];
    // 关闭push
    [_apiRegistPush setPushTime:NO starttime:800 endtime:2200 allowperson:0 allowsystem:0];
}


/** 滑动手势响应 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint translatedPoint = [touch locationInView:self.view];
    
    // 找到手势的位置
    
    if (_vTop.isSupportGesturesToBack && [[self aboveSubview:_vTop] isKindOfClass:[UCView class]] && translatedPoint.x < 80)
        return YES;
    
    return NO;
}

/** 添加全局滑动手势监听 */
- (void)addPanGestureRecognizer
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan1:)];
    
    [recognizer setMaximumNumberOfTouches:1];
    [recognizer setDelaysTouchesBegan:YES];
    [recognizer setDelaysTouchesEnded:YES];
    [recognizer setCancelsTouchesInView:YES];
    recognizer.delegate = self;
    
    [self.view addGestureRecognizer:recognizer];
}

/* 菜单拖拽 */
- (void)handlePan1:(UIPanGestureRecognizer *)gestureRecognizer
{
    // 是否支持手势关闭
    if (_vTop.isSupportGesturesToBack) {
        // 获取第二层视图
        UCView *vSecond = nil;
        UIView *view = [self aboveSubview:_vTop];
        if ([view isKindOfClass:[UCView class]]) {
            vSecond = (UCView *)view;
        }
        // 存在第二层视图才可滑动
        if (vSecond) {
            if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
                CGFloat moveX = [gestureRecognizer translationInView:_vMain].x;
                if (moveX < 0)
                    moveX = 0;
                else if (moveX > _vMain.width)
                    moveX = _vMain.width;
                _vTop.minX = moveX;
                vSecond.minX = vSecond.width / -2 + _vTop.minX / 2;
            } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
                // 划出屏幕1/3关闭页面
                if (_vTop.minX > self.view.width / 3) {
                    [_vTop viewWillClose:YES];
                    [self closeView:_vTop animateOption:AnimateOptionMoveLeft];
                } else {
                    [UIView animateWithDuration:0.1 animations:^{
                        _vTop.minX = 0;
                        vSecond.minX = vSecond.width / -2;
                    }];
                }
            }
        }
    }
}

/** 显示商店 */
- (void)showAppStore:(NSString *)appId type:(NSInteger)type
{
    if (type == 1) {
        // 评论
        NSString *strUrl = nil;
        strUrl = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
    } else {
        Class isAllow = NSClassFromString(@"SKStoreProductViewController");
        if (isAllow != nil) {
            // 初始化商店控件
            SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
            storeProductViewContorller.delegate = self;
            
            // 显示商店
            [self presentViewController:storeProductViewContorller animated:YES completion:nil];
            
            // 加载应用信息
            [storeProductViewContorller loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : appId} completionBlock:^(BOOL result, NSError *error) {
                if (error) {
                    AMLog(@"App Store 加载失败: %@", error);
                } else {
                    AMLog(@"App Store 加载成功...");
                }
            }];
        } else {
            NSString *strUrl = nil;
            switch (type) {
                case 0: // 商店
                    strUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8", appId];
                    break;
                case 1: // 评论
                    strUrl = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appId];
                    break;
                    
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
        }
    }
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


@end

