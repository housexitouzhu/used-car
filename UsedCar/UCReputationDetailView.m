//
//  UCReputationDetailView.m
//  UsedCar
//
//  Created by wangfaquan on 14-6-20.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCReputationDetailView.h"
#import "APIHelper.h"
#import "UCTopBar.h"
#import "AMCacheManage.h"

@interface UCReputationDetailView ()
@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *btnShare;
@property (nonatomic, strong) UIButton *btnReload;
@property (nonatomic, strong) APIHelper *apiHelper;
@property (nonatomic, strong) NSURL *strUrl;
@property (nonatomic, strong) UIActivityIndicatorView *aiActivity;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) APIHelper *apiDownImage;

@end

@implementation UCReputationDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

/** 创建视图 */
- (void)initView
{
    self.backgroundColor = kColorWhite;
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnTitle setTitle:@"口碑详情" forState:UIControlStateNormal];

    [self.tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];

    // 菊花
    _aiActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _aiActivity.center = CGPointMake(self.width/2, self.height/2);
    _aiActivity.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    [_aiActivity startAnimating];
//    
//    // 分享按钮
//    _btnShare = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _tbTop.btnRight.width / 2, _tbTop.btnRight.height)];
//    _btnShare.enabled = NO;
//    [_btnShare setImage:[UIImage imageNamed:@"detail_share_btn"] forState:UIControlStateNormal];
//    [_btnShare addTarget:self action:@selector(onClickShareBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [_tbTop.btnRight addSubview:_btnShare];

    // 自定义webView
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height + 35)];
    _webView.scrollView.backgroundColor = kColorWhite;
    _webView.delegate = self;
    [self addSubview:_tbTop];
    [self addSubview:_webView];
    [_webView addSubview:_aiActivity];
}

/** 刷新页面 */
- (void)setReloadBtnHidden:(BOOL)isShow message:(NSString *)message enable:(BOOL)enable
{
    if (!_btnReload) {
        _btnReload = [[UIButton alloc] initWithFrame:CGRectMake(0, 64, self.width, self.height)];
        _btnReload.backgroundColor = [UIColor clearColor];
        _btnReload.titleLabel.numberOfLines = 2;
        _btnReload.titleLabel.font = kFontLarge;
        _btnReload.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_btnReload setTitleColor:kColorGrey2 forState:UIControlStateNormal];
        [_btnReload addTarget:self action:@selector(onClickReloadViewBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (!isShow) {
        [self addSubview:_btnReload];
    } else {
        [_btnReload removeFromSuperview];
        _btnReload = nil;
    }
    
    [_btnReload setTitle:message forState:UIControlStateNormal];
    _btnReload.enabled = enable;
}

/** 刷新页面 */
- (void)onClickReloadViewBtn:(UIButton *)btn
{
    // 隐藏刷新按钮
    [self setReloadBtnHidden:YES message:@"网络连接失败\n点击屏幕重新尝试" enable:YES];
    // 重新获取数据
    [_apiHelper cancel];
    [self loadWebWithString:_strUrl];
}

/** 顶栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (btn.tag == UCTopBarButtonLeft) {
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
}

///** 分享 */
//- (void)onClickShareBtn:(UIButton *)btn
//{
//    NSArray *thumbimgurls = [_thumbimgurls componentsSeparatedByString:@","];
//    if (thumbimgurls.count > 0)
//        [self getImage:[thumbimgurls objectAtIndex:0]];
//}

///** 分享照片 */
//- (void)getImage:(NSString *)url
//{
//    // 判断有无缓存
//    UIImage *image = [UIImage imageWithData:[AMCacheManage loadImageWhitName:url]];
//    if (!image)
//        image = [UIImage imageNamed:@"icon"];
//    
//    if ([AMCacheManage isExistsImage:url] && image) {
//        [self shareCarImageInfo:image];
//    }
//    else {
//        if (!_apiDownImage)
//            _apiDownImage = [[APIHelper alloc] init];
//        __weak UCReputationDetailView *vReputation = self;
//        [_apiDownImage setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
//            if (error) {
//                // 重复请求(取消上次请求)
//                if (error.code == ConnectionStatusRepeat || error.code == ConnectionStatusCancel) {
//                }
//                // 取消请求
//                else if (error.code == ConnectionStatusTimeout || error.code == ConnectionStatusError || error.code == ConnectionStatusNot) {
//                    [[AMToastView toastView] showMessage:@"分享失败" icon:kImageRequestError duration:AMToastDurationNormal];
//                }
//                return;
//            }
//            UIImage *image = [UIImage imageWithData:apiHelper.data];
//            if (image)
//                [vReputation shareCarImageInfo:image];
//            else{
//                // 获取到连接地址，但拿不到有效图片
//                [[AMToastView toastView] showMessage:@"图片获取失败，请稍后尝试" icon:kImageRequestError duration:AMToastDurationNormal];
//                return;
//            }
//        }];
//        [_apiDownImage downloadImage:url];
//    }
//}

///** 分享 */
//- (void)shareCarImageInfo:(UIImage *)image
//{
////    NSString *url = _isBusiness ? [NSString stringWithFormat:@"http://m.che168.com/dealer/%@/%@.html", _mCarDetailInfo.userid, _mCarDetailInfo.carid] : [NSString stringWithFormat:@"http://m.che168.com/personal/%@.html", _mCarDetailInfo.carid];
////    /*
////     // 上牌时间
////     NSString *strRegistrationTime = ((UILabel *)[self viewWithTag:KlabLicenseContenTag]).text;
////     // 行驶里程
////     NSString *strDrivemileage = [NSString stringWithFormat:@"%@万公里",_mCarDetailInfo.drivemileageText];
////     
////     // 分享文字
////     NSString *shareText = [NSString stringWithFormat:@"小伙伴们，别说有好东西不想着你们，这辆%@上牌的%@行驶了%@，售价%@确实不错，详情点击%@ #二手车之家#", strRegistrationTime, _labCarName.text, strDrivemileage, strPrice, url];
////     */
////    // 售价
////    NSString *strPrice = [NSString stringWithFormat:@"%@万",_mCarDetailInfo.bookpriceText];
////    // 分享文字
////    NSString *shareText = [NSString stringWithFormat:@"%@，%@ #二手车之家# %@", strPrice, _labCarName.text, url];
////    
////    NSDictionary *wxsessionContent = [[NSDictionary alloc] initWithObjectsAndKeys:[_labCarName.text dNull:@"-"], @"title", [NSString stringWithFormat:@"价格：%@万\n上牌：%@\n里程：%@万公里", [_mCarDetailInfo.bookpriceText dNull:@"-"], [_mCarDetailInfo.firstregtimeText dNull:@"-"], [_mCarDetailInfo.drivemileageText dNull:@"-"]], @"shareText", nil];
//    
////    [[MainViewController sharedVCMain] showShareList:shareText image:image url:url wxsessionContent:wxsessionContent];
//}

#pragma mark - Public Method
/** 加载Url */
- (void)loadWebWithString:(NSURL*)urlString
{
    _strUrl = urlString;
    NSURLRequest *request =[NSURLRequest requestWithURL:urlString];
   [_webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    _aiActivity.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _aiActivity.hidden = YES;
    _title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _aiActivity.hidden = YES;
    [self setReloadBtnHidden:NO message:@"网络连接失败\n点击屏幕重新尝试" enable:YES];
}

@end
