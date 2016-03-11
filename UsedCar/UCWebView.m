//
//  UCWebView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-8-27.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCWebView.h"

@interface UCWebView ()<UIWebViewDelegate>

@end

@implementation UCWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withWebURL:(NSString*)url;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
        [self setWebURL:url];
    }
    return self;
}

- (void)setWebURL:(NSString *)webURL{
    _webURL = webURL;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webURL]]];
}

- (void)initView{
    
    _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_refreshButton setTitle:@"正在加载中..." forState:UIControlStateNormal];
    [_refreshButton setTitleColor:kColorNewGray2 forState:UIControlStateNormal];
    [_refreshButton setFrame:self.bounds];
    [_refreshButton addTarget:self action:@selector(refreshButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_refreshButton];
    
    _webView = [[UIWebView alloc] initWithFrame:self.bounds];
    _webView.delegate = self;
    [_webView setDelegate:self];
    [_webView setMultipleTouchEnabled:NO];
    [_webView setClipsToBounds:YES];
    [self addSubview:_webView];
    
    _webView.hidden = NO;
    _refreshButton.hidden = YES;
    
}

- (void)refreshButtonClicked:(id)sender{
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_webURL]]];
    _webView.hidden = NO;
    _refreshButton.hidden = YES;
}

- (void)cancelLoading{
    [_webView stopLoading];
    if ([[AMToastView toastView] isShow])
        [[AMToastView toastView] hide];
}

-(void)repuestPV:(id)code
{
    if ([code isEqualToString:tool_dressing_vin_pv]) {
        [UMSAgent postEvent:tool_dressing_vin_pv page_name:@"UCExchangeView"];
    } else if ([code isEqualToString:tool_dressing_more_pv]) {
        [UMSAgent postEvent:tool_dressing_more_pv page_name:@"UCExchangeView"];
    }else if ([code isEqualToString:tool_dressing_successful_pv]) {
        [UMSAgent postEvent:tool_dressing_successful_pv page_name:@"UCExchangeView"];
    }else if ([code isEqualToString:tool_payment_vin_pv]) {
        [UMSAgent postEvent:tool_payment_vin_pv page_name:@"UCClaimView"];
    }else if ([code isEqualToString:tool_payment_more_pv]) {
        [UMSAgent postEvent:tool_payment_more_pv page_name:@"UCClaimView"];
    }else if ([code isEqualToString:tool_payment_successful_pv]) {
        [UMSAgent postEvent:tool_payment_successful_pv page_name:@"UCClaimView"];
    }
}

#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([_delegate respondsToSelector:@selector(UCWebView:shouldStartLoadWithRequest:navigationType:)]) {
        return [_delegate UCWebView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    NSString *urlString = [[request URL] absoluteString];
    NSArray *urlComps = [urlString componentsSeparatedByString:@"://"];
    if([urlComps count] && [[urlComps objectAtIndex:0] isEqualToString:@"objc"]) {
        NSArray *arrFucnameAndParameter = [(NSString*)[urlComps objectAtIndex:1] componentsSeparatedByString:@"/"];
        NSString *funcStr = [arrFucnameAndParameter objectAtIndex:0];
        if(2 == [arrFucnameAndParameter count]) {
            //有参数的
            if([funcStr isEqualToString:@"repuestPV"] && [arrFucnameAndParameter objectAtIndex:1]) {
                /*调用本地函数1*/
                [self repuestPV:[arrFucnameAndParameter objectAtIndex:1]];
            }
        }
        return NO;
    };
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [[AMToastView toastView] showLoading:@"正在加载中..." cancel:^{
        [_webView stopLoading];
        [_refreshButton setTitle:@"加载失败, 点击屏幕刷新" forState:UIControlStateNormal];
        _webView.hidden = YES;
        _refreshButton.hidden = NO;
        [[AMToastView toastView] hide];
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [[AMToastView toastView] hide];
    
    if ([_delegate respondsToSelector:@selector(UCWebViewDidFinishLoad:)]) {
        [_delegate UCWebViewDidFinishLoad:webView];
    }
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [[AMToastView toastView] hide];
    [_refreshButton setTitle:@"加载失败, 点击屏幕刷新" forState:UIControlStateNormal];
    _webView.hidden = YES;
    _refreshButton.hidden = NO;
}


@end
