//
//  UCSetUpView.m
//  UsedCar
//
//  Created by wangfaquan on 13-12-5.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCSetUpView.h"
#import "UCMainView.h"
#import "AMCacheManage.h"
#import "UCTopBar.h"
#import "AppDelegate.h"
#import "AMToastView.h"
#import "AMCacheManage.h"
#import "UCFeedbackView.h"
#import "UCAboutUs.h"
#import "UCAppsView.h"
#import "UIImage+Util.h"
#import "UCPushSettingView.h"
#import "UserLogInOutHelper.h"

#define buttonTagBase   1000

@interface UCSetUpView ()

@property (nonatomic, strong) UCTopBar * tbTop;
@property (nonatomic, strong) UIScrollView *svbig;
@property (nonatomic, strong) UILabel *labCache;

@end

@implementation UCSetUpView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    
    // 导航头
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    // ScrollView
    _svbig = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.height)];
    _svbig.scrollEnabled = YES;
    _svbig.backgroundColor = kColorNewBackground;
    
    // 设置选项
    UIView *setupView = [self creatUpView:CGRectMake(0, 10, _svbig.width, 45 * 6)];
    // 退出登录
    CGFloat minY = setupView.maxY;
    if ([AMCacheManage currentUserType] != UserStyleNone) {
        UIView *vLogOut = [self creatLogOutView:CGRectMake(0, minY + 10, self.width, 44)];
        [_svbig addSubview:vLogOut];
        
        minY = vLogOut.maxY;
    }
    
    // 推荐应用
    UIView *appsView = [self creatAppsView:CGRectMake(0, minY + 20, _svbig.width, 220)];

    _svbig.contentSize = CGSizeMake(self.width, appsView.maxY + 33 > _svbig.height ? appsView.maxY + 33 : _svbig.height + 1);
    
    [_svbig addSubview:setupView];
    [_svbig addSubview:appsView];
    
    [self addSubview:_tbTop];
    [self addSubview:_svbig];
    
    // 检查更新
    if ([AppDelegate sharedAppDelegate].update > 0) {
        UIButton * button = (UIButton *)[self viewWithTag:(buttonTagBase + 2)];
        UILabel * labImage = [[UILabel alloc] initWithFrame:CGRectMake(122, 23, 5, 5)];
        [button addSubview:labImage];
        labImage.backgroundColor = kColorOrange;
    }
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"设置" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    return vTopBar;
}

/** 设置选项 */
- (UIView *)creatUpView:(CGRect)frame
{
    UIView *vSet = [[UIView alloc] init];
    vSet.origin = CGPointMake(frame.origin.x, frame.origin.y);
    
    UIView *vPush = [[UIView alloc] init];
    vPush.backgroundColor = [UIColor clearColor];
    vPush.userInteractionEnabled = YES;
    vPush.origin = CGPointMake(0, 0);
    
    /* 此版本暂时不启用
    // 消息推送
    UIView *vLineTop1 = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine];
    
    UIButton *btnTitle = [[UIButton alloc] initWithFrame:CGRectMake(0, vLineTop1.maxY, self.width, 50)];
    btnTitle.backgroundColor = kColorWhite;
    btnTitle.titleLabel.font = [UIFont systemFontOfSize:15];
    btnTitle.titleEdgeInsets = UIEdgeInsetsMake(21, -170, 18,0);
    btnTitle.imageEdgeInsets = UIEdgeInsetsMake(12, -210, 10, 0);
    btnTitle.adjustsImageWhenHighlighted = NO;
    [btnTitle setTitle:@"消息推送" forState:UIControlStateNormal];
    [btnTitle setTitleColor:kColorGray1 forState:UIControlStateNormal];
    [btnTitle setImage:[UIImage imageNamed:@"set_push_icon"] forState:UIControlStateNormal];
    [btnTitle setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnTitle.size] forState:UIControlStateHighlighted];
    
    // 开启状态
    UILabel *labAttentionStatue = [[UILabel alloc] initWithFrame:CGRectMake(btnTitle.width - 70, 0, 70, btnTitle.height)];
    labAttentionStatue.backgroundColor = [UIColor clearColor];
    labAttentionStatue.textAlignment = NSTextAlignmentCenter;
    labAttentionStatue.textColor = kColorNewLine;
    labAttentionStatue.font = [UIFont systemFontOfSize:16];
    UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    labAttentionStatue.text = type == UIRemoteNotificationTypeNone ? @"已关闭" : @"已开启";
    
    UIView *vLineBottom1 = [[UIView alloc] initLineWithFrame:CGRectMake(0, btnTitle.maxY, self.width, kLinePixel) color:kColorNewLine];
    
    // 说明文字
    UILabel *labContent = [[UILabel alloc] initWithFrame:CGRectMake(53, vLineBottom1.maxY + 3, 178, 30)];
    labContent.backgroundColor = [UIColor clearColor];
    labContent.font = [UIFont systemFontOfSize:10];
    labContent.text = @"请在iPhone的“设置”-“通知”-“二手车”\n中进行修改。";
    labContent.lineBreakMode = NSLineBreakByCharWrapping;
    labContent.numberOfLines = 2;
    labContent.textColor = kColorGrey3;
    
    vPush.size = CGSizeMake(self.width, labContent.maxY + 13);
    
    [vPush addSubview:vLineTop1];
    [vPush addSubview:btnTitle];
     
    [btnTitle addSubview:labAttentionStatue];
    [vPush addSubview:vLineBottom1];
    [vPush addSubview:labContent];
    [vSet addSubview:vPush];
     */
    
    // 清理缓存、检查更新、用户反馈、关于我们
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, (int)vPush.maxY, frame.size.width, frame.size.height)];
    contentView.backgroundColor = kColorWhite;
    
    UIView *labelLineUP = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine];
    UIView *labelLineDown = [[UIView alloc] initLineWithFrame:CGRectMake(0, contentView.height - kLinePixel, self.width, kLinePixel) color:kColorNewLine];
    
    NSArray *arrPic = [[NSArray alloc] initWithObjects:@"set_push_icon", @"set_trash_btn", @"set_shuffle_btn", @"set_good_btn", @"set_mail_btn", @"set_bookmark_btn", nil];
    NSArray *arrText = [[NSArray alloc] initWithObjects:@"消息通知",@"清理缓存",@"检查更新",@"给个好评",@"用户反馈",@"关于我们", nil];
    
    CGFloat minY = 0;
    for (int i = 0; i < arrText.count; i++) {
        UIButton * btnText = [[UIButton alloc] initWithFrame:CGRectMake(0, minY, self.width, 45)];
        btnText.tag = buttonTagBase + i;
        btnText.titleLabel.font = [UIFont systemFontOfSize:15];
        btnText.adjustsImageWhenHighlighted = NO;
        [btnText setTitle:[arrText objectAtIndex:i] forState:UIControlStateNormal];
        [btnText setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
        [btnText setImage:[UIImage imageNamed:[arrPic objectAtIndex:i]] forState:UIControlStateNormal];
        [btnText setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnText.size] forState:UIControlStateHighlighted];
        [btnText addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
        btnText.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btnText.titleEdgeInsets = UIEdgeInsetsMake(0, 35, 0, 0);
        btnText.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        
        // 缓存
        if (i == 1) {
            _labCache = [[UILabel alloc] initWithClearFrame:CGRectMake(btnText.width - 115, 16, 100, 20)];
            _labCache.font = [UIFont systemFontOfSize:15];
            _labCache.textAlignment = NSTextAlignmentRight;
            _labCache.text = @"···";
            _labCache.textColor =  kColorGrey3;
            [btnText addSubview:_labCache];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                float imageSize = [AMCacheManage imageCacheSize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (imageSize > 0)
                    _labCache.text = [NSString stringWithFormat:@"%0.2fMB", imageSize];
                    else
                    _labCache.text = @"0.00MB";
                });
            });
        }
        // 箭头
        else {
            UIImageView * arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 28, (btnText.height - 16) / 2, 16, 16)];
            arrowImage.image = [UIImage imageNamed:@"set_arrow_right"];
            [btnText addSubview:arrowImage];
            
        }
        
        // 短分割线
        UIView * vLine = [[UIView alloc] initLineWithFrame:CGRectMake(50, 0, self.width - 45, kLinePixel) color:kColorNewLine];
        [btnText addSubview:vLine];
        
        [contentView addSubview:btnText];
        
        minY += 45;
    }
    
    [contentView addSubview:labelLineUP];
    [contentView addSubview:labelLineDown];
    [vSet addSubview:contentView];
    
    vSet.size = CGSizeMake(self.width, contentView.maxY);

    return vSet;
}

/** 创建退出视图 */
- (id)creatLogOutView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    UIButton *btnLogOut = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, self.width - 10*2, vBody.height)];
    btnLogOut.titleLabel.font = kFontLarge1_b;
    btnLogOut.backgroundColor = kColorRed1;
    [btnLogOut setBackgroundImage:[UIImage imageWithColor:kColorRed1H size:btnLogOut.size] forState:UIControlStateHighlighted];
    if ([AMCacheManage currentUserType] == UserStylePhone)
    {
        [btnLogOut setTitle:@"退出当前手机号" forState:UIControlStateNormal];
    }
    else
    {
        [btnLogOut setTitle:@"退出当前账号" forState:UIControlStateNormal];
    }
    btnLogOut.layer.masksToBounds = YES;
    btnLogOut.layer.cornerRadius = 3;
    [btnLogOut addTarget:self action:@selector(onClickLogOutButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [vBody addSubview:btnLogOut];
    
    return vBody;
}

/** 推荐应用 */
- (UIView *)creatAppsView:(CGRect)frame
{
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    // 推荐应用
    UILabel *labUser = [[UILabel alloc] initWithClearFrame:CGRectMake(15, 0, contentView.width, 30)];
    labUser.text = @"推荐应用";
    labUser.font = [UIFont systemFontOfSize:15];
    labUser.textColor = kColorNewGray1;
    
    UCAppsView *appsView = [[UCAppsView alloc] initWithFrame:CGRectMake(0, labUser.maxY, contentView.width, contentView.height - labUser.height)];
    [appsView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine]];
    
    [contentView addSubview:labUser];
    [contentView addSubview:appsView];
    
    return contentView;
}

#pragma mark - onClickBtn
/** 按钮事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (btn.tag == buttonTagBase)
    {
        
        UCPushSettingView *pushSettingView = [[UCPushSettingView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds];
        [[MainViewController sharedVCMain] openView:pushSettingView animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        
    }
    else if (btn.tag == buttonTagBase+1)
    {
        
        if ([_labCache.text floatValue] == 0)
        {
            
            [[AMToastView toastView] showMessage:@"缓存清理成功" icon:kImageRequestSuccess duration:AMToastDurationNormal];
            return;
        }
        [[AMToastView toastView:YES] showLoading:@"缓存清理中..." cancel:nil];
        _labCache.text = @"···";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            BOOL isSuccess = [AMCacheManage clearAllCacheWhitDirName:kCacheImageDir];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (isSuccess) {
                    _labCache.text = @"0.00MB";
                    [[AMToastView toastView] showMessage:@"缓存清理成功" icon:kImageRequestSuccess duration:AMToastDurationNormal];
                    return;
                }
                else {
                    [[AMToastView toastView] showMessage:@"缓存清理失败" icon:kImageRequestError   duration:AMToastDurationNormal];
                }
            });
        });
        
    }
    else if (btn.tag == buttonTagBase + 2)
    {
        [[AppDelegate sharedAppDelegate] checkUpdate:YES];
    }
    else if (btn.tag == buttonTagBase + 3)
    {
        [[MainViewController sharedVCMain] showAppStore:@"455177952" type:1];
    }
    else if (btn.tag == buttonTagBase + 4)
    {
        UCFeedbackView *_vFeedBack = [[UCFeedbackView alloc] initWithFrame:self.bounds];
        [[MainViewController sharedVCMain] openView:_vFeedBack animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        
    }
    else if (btn.tag == buttonTagBase + 5) {UCAboutUs *aboutUs = [[UCAboutUs alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [[MainViewController sharedVCMain] openView:aboutUs animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
    else
    {
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
}

/** 点击退出按钮 */
- (void)onClickLogOutButton:(UIButton *)btn
{
    // 手机号
    if ([AMCacheManage currentUserType] == UserStylePhone) {
        [UMStatistics event:c_4_0_set_out];
        [AMCacheManage setCurrentUserInfo:nil];
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
    // 个人或商家
    else {
        // 解决异常bug
        UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
        // 当前账号异常
        if (mUserInfo.userkey.length == 0 || mUserInfo.userkey == nil) {
            [AMCacheManage setCurrentUserType:UserStyleNone];
            [AMCacheManage setLastRefreshUserInfoTime:[NSDate date]];
            [UMSAgent bindUserIdentifier:@"0"];
            [AMCacheManage setSYNCclientCarNeeded:NO];
            [AMCacheManage setSYNCclientCarSuccess:NO];
            [AMCacheManage setSYNCclientSubscriptionNeeded:NO];
            [AMCacheManage setSYNCclientSubscriptionSuccess:NO];
            [AMCacheManage setSYNCclientFavoritesNeeded:NO];
            [AMCacheManage setSYNCclientFavoritesSuccess:NO];
            [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
        }
        // 正常退出
        else {
            [[UserLogInOutHelper userHelper] userLogoutShowToast:YES logoutBlock:^(BOOL success, NSString *message) {
                if (success) {
                    [UMStatistics event:c_4_0_set_out];
                    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
                }
                //else 错误提示在 block 内处理了.
                
            }];
        }
    }
}


@end
