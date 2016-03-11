//
//  UCActivityView.m
//  UsedCar
//
//  Created by Alan on 14-5-23.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCActivityView.h"
#import "UCTopBar.h"
#import "APIHelper.h"
#import "UIImage+Util.h"
#import "UCHelpPromptView.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialData.h"
#import "WXApi.h"
#import "AppDelegate.h"

@interface UCActivityView ()<UMSocialUIDelegate>

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UIView *vOperaBar;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *btnRefresh;
@property (nonatomic, strong) NSString *strUrl;
@property (nonatomic, strong) APIHelper *apiHelper;
@property (nonatomic, strong) AdlistItemModel *mAdlistModel;
@property (nonatomic, strong) NSDictionary *wxsessionContent;

@end

@implementation UCActivityView

- (id)initWithFrame:(CGRect)frame withActivityModel:(AdlistItemModel*)model
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _mAdlistModel = model;
        [self initView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
    }
    return self;
}

#pragma mark - initView
/** 视图创建 */
- (void)initView
{
    [UMStatistics event:pv_4_1_sellcar_ad];
    self.backgroundColor = kColorWhite;
    self.apiHelper = [[APIHelper alloc] init];
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [_tbTop setLetfTitle:@"关闭"];
    
    [_tbTop.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    // 分享按钮
    _tbTop.btnRight.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
    [_tbTop.btnRight setImage:[UIImage imageNamed:@"detail_share_btn"] forState:UIControlStateNormal];
    [_tbTop.btnRight setImage:[UIImage imageAutoNamed:@"detail_share_btn_d"] forState:UIControlStateDisabled];
    [_tbTop.btnRight addTarget:self action:@selector(onClickShareBtn:) forControlEvents:UIControlEventTouchUpInside];    
    
    // 操作栏
    _vOperaBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 45, self.width, 45)];
    
    UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, _vOperaBar.height)];
    [btnBack setImage:[UIImage imageNamed:@"set_arrow_right"] forState:UIControlStateNormal];
    btnBack.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    btnBack.tag = 1;
    [btnBack addTarget:self action:@selector(onClickOperaBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnGo = [[UIButton alloc] initWithFrame:CGRectMake(50, 0, 50, _vOperaBar.height)];
    [btnGo setImage:[UIImage imageNamed:@"set_arrow_right"] forState:UIControlStateNormal];
    btnGo.tag = 2;
    [btnGo addTarget:self action:@selector(onClickOperaBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    // 创建刷新按钮
    _btnRefresh = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 50, 0, 50, _vOperaBar.height)];
    [_btnRefresh setImage:[UIImage imageNamed:@"merchant_home_shuffle_btns"] forState:UIControlStateNormal];
    _btnRefresh.tag = 3;
    [_btnRefresh addTarget:self action:@selector(onClickOperaBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [_vOperaBar addSubview:btnBack];
    [_vOperaBar addSubview:btnGo];
    [_vOperaBar addSubview:_btnRefresh];
    
    [_vOperaBar addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, _vOperaBar.width, kLinePixel) color:kColorNewLine]];
    
    // 浏览器
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, _vOperaBar.minY - _tbTop.maxY)];
    _webView.backgroundColor = kColorWhite;
    _webView.clipsToBounds = YES;
    [_webView setScalesPageToFit:YES];
    [_webView setMultipleTouchEnabled:YES];
    _webView.delegate = self;
    
    [self addSubview:_tbTop];
    [self addSubview:_webView];
    [self addSubview:_vOperaBar];
}

#pragma mark - Public Method
/** 加载Url */
- (void)loadWebWithString:(NSString*)urlString
{
    NSURL *url =[NSURL URLWithString:urlString];
    _strUrl = urlString;
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    [_webView reload];
}

#pragma mark - onClickButton
/** 返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/** 点击操作事件 */
- (void)onClickOperaBtn:(UIButton *)btn
{
    switch (btn.tag) {
        case 1:
            [_webView goBack];
            break;
        case 2:
            [_webView goForward];
            break;
        case 3:
            if (_webView.isLoading) {
                [_apiHelper cancel];
                [_webView stopLoading];
                [_btnRefresh setImage:[UIImage imageNamed:@"merchant_home_shuffle_btns"] forState:UIControlStateNormal];
                [[AMToastView toastView] hide];
                
            } else {
                [self loadWebWithString:_strUrl];
            }
            break;
    }
}

#pragma mark - UIWebViewDelegate
/** 开始加载 */
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_btnRefresh setImage:[UIImage imageNamed:@"merchant_delete_btn"] forState:UIControlStateNormal];
    [[AMToastView toastView] showLoading:@"正在加载中..." cancel:^{
        [self.webView stopLoading];
    }];
//    [[AMToastView toastView] showMessage:@"正在加载中..."  icon:kImageRequestLoading duration:AMToastDurationNormal];
}

/** 加载完成 */
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_btnRefresh setImage:[UIImage imageNamed:@"merchant_home_shuffle_btns"] forState:UIControlStateNormal];
    [[AMToastView toastView] hide];

}

/** 加载失败 */
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_btnRefresh setImage:[UIImage imageNamed:@"merchant_home_shuffle_btns"] forState:UIControlStateNormal];
    [[AMToastView toastView] showMessage:@"网络连接失败，点击刷新按钮尝试" icon:kImageRequestError duration:AMToastDurationNormal];
}


#pragma mark - Button Click Actions
/** 分享 */
- (void)onClickShareBtn:(UIButton *)btn
{
    [UMStatistics event:c_4_1_sellcar_ad_share];
    NSString *imageUrl = self.mAdlistModel.icon;
    
    NSString *content = [NSString stringWithFormat:@"%@ #二手车之家# %@", self.mAdlistModel.content, self.mAdlistModel.shorturl];
    self.wxsessionContent = @{@"title":self.mAdlistModel.articletitle,
                              @"shareText":content
                              };
    
    NSString *title = self.mAdlistModel.articletitle;
    
    // 设置分享标题
    [UMSocialData defaultData].extConfig.qzoneData.title = title;
    [UMSocialData defaultData].extConfig.qzoneData.url = self.mAdlistModel.shorturl;
    [UMSocialData defaultData].extConfig.renrenData.url = self.mAdlistModel.shorturl;
    [UMSocialData defaultData].extConfig.emailData.title = title;
    [UMSocialData defaultData].extConfig.wechatSessionData.title = [self.wxsessionContent objectForKey:@"title"];
    if (imageUrl.length > 0)
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
    else
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeDefault];
    
    // 分享到微信设置url
    [UMSocialWechatHandler setWXAppId:@"wx7ea3320364626402" appSecret:@"82a1f7a4f98d61c103a37d17fc0b298d" url:self.mAdlistModel.shorturl];
    
    
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
    [UMSocialSnsService presentSnsIconSheetView:[MainViewController sharedVCMain] appKey:UM_APP_KEY shareText:content shareImage:nil shareToSnsNames:names delegate:self];
}
                                      
#pragma mark - method private
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

@end
