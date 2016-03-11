//
//  UCRaiderDetailView.m
//  UsedCar
//
//  Created by wangfaquan on 13-12-19.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCRaiderDetailView.h"
#import "UCTopBar.h"
#import "APIHelper.h"

@interface UCRaiderDetailView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) APIHelper *apiSearchCar;
@property (nonatomic, strong) UIWebView * web;

@end

@implementation UCRaiderDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [UMStatistics event:pv_3_1_paperdetail];
        [UMSAgent postEvent:articledetail_pv page_name:NSStringFromClass(self.class)];
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorWhite;
    
    //导航头
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    //自定义webView
    _web = [self creatWebView:CGRectMake(0, _tbTop.maxY, self.width, self.height)];
    
    self.frame = CGRectMake(0, 0, self.width, _web.height);
    _apiSearchCar = [[APIHelper alloc] init];
    [self addSubview:_web];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnTitle setTitle:_TopTitle forState:UIControlStateNormal];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    return vTopBar;
}

- (UIWebView *)creatWebView:(CGRect)frame
{
    UIWebView *web = [[UIWebView alloc]initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height)];
    web.scalesPageToFit = NO;
    web.scrollView.backgroundColor = kColorWhite;
    return web;
}

#pragma mark - private Method
- (void)openLoadLocalHtml:(NSURL *)url
{
    [_web loadRequest:[NSURLRequest requestWithURL:url]];
}

/** 顶栏标题 */
- (void)setTopTitle:(NSString *)TopTitles
{
    if (_TopTitle != TopTitles) {
        _TopTitle = TopTitles;
        [_tbTop.btnTitle setTitle:_TopTitle forState:UIControlStateNormal];
    }
}

#pragma mark - onClickButton
/** 顶栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (btn.tag == UCTopBarButtonLeft) {
        
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
}

#pragma mark - ApiHelper
- (void)openContent:(NSString *)articleId {
    __weak UCRaiderDetailView *detail = self;
    
    [_apiSearchCar setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 非取消请求, 提示错误信息
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }

        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase && mBase.returncode == 0) {
                NSString *content = [mBase.result objectForKey:@"comtent"];
                [detail.web loadHTMLString:content baseURL:nil];
            }
        }
    }];
    
    [_apiSearchCar getArticleDetail:articleId];
}

- (void)dealloc
{
    AMLog(@"dealloc...");
    [_apiSearchCar cancel];
}

@end
