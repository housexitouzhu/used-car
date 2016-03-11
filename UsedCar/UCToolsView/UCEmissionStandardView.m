//
//  UCEmissionStandardView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-10-22.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCEmissionStandardView.h"
#import "UCTopBar.h"
#import "UCWebView.h"
#import "UCSNSHelper.h"


@interface UCEmissionStandardView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCWebView *vWeb;
@property (nonatomic, strong) NSString *emissionCode;
@property (nonatomic, strong) NSDictionary *codesOfEmission;
@property (nonatomic, strong) UCSNSHelper *snsHelper;
@end

@implementation UCEmissionStandardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initViewWithAreaString:@"京5"];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame emissionString:(NSString*)emissionString
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initViewWithAreaString:emissionString];
    }
    return self;
}

- (void)initViewWithAreaString:(NSString*)emissionString{
    
    [UMStatistics event:c_4_1_tool_displacement_standardresult];
    
    self.codesOfEmission = @{@"国2":@"1",
                             @"国3":@"2",
                             @"国4":@"3",
                             @"京5":@"4",};
    
    self.emissionCode = [self.codesOfEmission objectForKey:emissionString];
    
    self.backgroundColor =  kColorNewBackground;
    self.tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:self.tbTop];
    
    self.vWeb = [[UCWebView alloc] initWithFrame:CGRectMake(0, self.tbTop.maxY, self.width, self.height-self.tbTop.maxY) withWebURL:[[APIHelper getShareEmissionArea] stringByAppendingFormat:@"%@&isapp=1",self.emissionCode]];
    [self addSubview:self.vWeb];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"按排放标准查询" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnShare setFrame:CGRectMake(vTopBar.btnRight.width-34-8, 0, 34, vTopBar.btnRight.height)];
    [btnShare setImage:[UIImage imageNamed:@"detail_share_btn"] forState:UIControlStateNormal];
    [btnShare setImage:[UIImage imageNamed:@"detail_share_btn_d"] forState:UIControlStateDisabled];
    [btnShare addTarget:self action:@selector(onClickShareBtn:) forControlEvents:UIControlEventTouchUpInside];
    [vTopBar.btnRight addSubview:btnShare];
    
    return vTopBar;
}

#pragma mark - button actions
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/** 分享 */
- (void)onClickShareBtn:(UIButton *)btn{
    
    if (!self.snsHelper) {
        self.snsHelper = [[UCSNSHelper alloc] init];
    }
    NSString *shareURL = [[APIHelper getShareEmissionArea] stringByAppendingString:@"4"];
    self.snsHelper.shareURL = shareURL;
    self.snsHelper.title = @"全国限迁标准查询结果";
    self.snsHelper.contentWeChat = @"限迁标准查询，帮助您快速了解迁入地排放标准#二手车之家#。";
    self.snsHelper.content = [NSString stringWithFormat:@"全国限迁标准查询结果，%@ #二手车之家#", shareURL];
    self.snsHelper.imageShareIcon = [UIImage imageNamed:@"emissionShare"];
    [self.snsHelper openShareViewForAllPlatform:NO];
    
}

@end
