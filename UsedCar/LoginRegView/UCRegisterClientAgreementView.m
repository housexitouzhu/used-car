//
//  UCRegClientAgreementView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-9-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCRegisterClientAgreementView.h"
#import "UCTopBar.h"

@interface UCRegisterClientAgreementView ()

@property (nonatomic, strong) UIWebView *vWeb;

@end

@implementation UCRegisterClientAgreementView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}

- (void)initView{
    self.backgroundColor = kColorNewBackground ;
    
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [vTopBar setLetfTitle:@"关闭"];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    [vTopBar.btnTitle setTitle:@"使用许可协议" forState:UIControlStateNormal];
    [self addSubview:vTopBar];
    
    self.vWeb = [[UIWebView alloc]initWithFrame:CGRectMake(0, vTopBar.maxY, self.width, self.height - 64)];
    self.vWeb.scalesPageToFit = NO;
    self.vWeb.scrollView.backgroundColor = kColorWhite;
    [self.vWeb setScalesPageToFit:YES];
    self.frame = CGRectMake(0, 0, self.width, self.vWeb.height);
    
    NSString *filePath = [[[NSBundle mainBundle] pathForResource:@"RegClientAgreement" ofType:@"html"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:filePath];
    
    [self.vWeb loadRequest:[NSURLRequest requestWithURL:url]];
    
    [self addSubview:self.vWeb];
}


#pragma mark - onClickButton
- (void)onClickTopBar:(UIButton *)btn
{
    
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveUp];
}

@end
