//
//  UCProtocolView.m
//  UsedCar
//
//  Created by 张鑫 on 14-5-14.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCProtocolView.h"
#import "UCTopBar.h"

@interface UCProtocolView ()

@property (nonatomic, strong) UIWebView *web;

@end
@implementation UCProtocolView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kColorWhite;
        [self initView];
    }
    return self;
}

/** 创建视图 */
- (void)initView
{
    self.backgroundColor = [UIColor whiteColor];
    
    // 导航栏
    UCTopBar *vTopBar = [self addTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:vTopBar];
    
    //自定义webView
    _web = [[UIWebView alloc]initWithFrame:CGRectMake(0, vTopBar.maxY, self.width, self.height - 64)];
    _web.scalesPageToFit = NO;
    _web.scrollView.backgroundColor = kColorWhite;
    self.frame = CGRectMake(0, 0, self.width, _web.height);
    
    NSString *filePath = [[[NSBundle mainBundle] pathForResource:@"protocol" ofType:@"html"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
     NSURL *url = [NSURL URLWithString:filePath];
    
    [_web loadRequest:[NSURLRequest requestWithURL:url]];
    
    [self addSubview:_web];
}

/** 导航栏 */
- (UCTopBar *)addTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    [vTopBar.btnTitle setTitle:@"使用许可协议" forState:UIControlStateNormal];
    [vTopBar.btnRight setTitle:@"同意" forState:UIControlStateNormal];
    [vTopBar.btnRight addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    return vTopBar;
}

#pragma mark - onClickButton
- (void)onClickTopBar:(UIButton *)btn
{
    // 关闭
    if (btn.tag == UCTopBarButtonLeft) {
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
    // 提交
    else if (btn.tag == UCTopBarButtonRight) {
        if ([_delegate respondsToSelector:@selector(didAgreeProtocol)]) {
            [_delegate didAgreeProtocol];
        }
    }
}

@end
