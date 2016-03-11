//
//  UCWebView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-8-27.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

@protocol UCWebViewDelegate;

@interface UCWebView : UCView

@property (nonatomic, strong) NSString *webURL;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, weak) id delegate;

- (id)initWithFrame:(CGRect)frame withWebURL:(NSString*)url;

- (void)cancelLoading;

@end

@protocol UCWebViewDelegate <NSObject>
@optional
- (BOOL)UCWebView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)UCWebViewDidFinishLoad:(UIWebView *)webView;

@end
