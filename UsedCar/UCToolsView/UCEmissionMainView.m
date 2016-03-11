//
//  UCEmissionMainView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-10-22.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCEmissionMainView.h"
#import "UCTopBar.h"
#import "UIImage+Util.h"
#import "UCEmissionSearchView.h"
#import "UCEmissionStandardView.h"
#import "AMCacheManage.h"

@interface UCEmissionMainView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) NSArray *arrIcon;
@property (nonatomic, strong) NSArray *arrTitle;

@end

@implementation UCEmissionMainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.arrIcon = @[@"limit_area",@"limit_emission"];
        self.arrTitle = @[@"按迁入地区查询",@"按排放标准查询"];
        [self initView];
    }
    return self;
}

- (void)initView{
    
    self.backgroundColor =  kColorNewBackground;
    self.tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:self.tbTop];
    
    UIView *buttonList = [self createListButtonViewAtOriginPoint:CGPointMake(0, self.tbTop.maxY)];
    [self addSubview:buttonList];
    
    UILabel *labNotice = [[UILabel alloc] initWithFrame:CGRectMake(15, buttonList.maxY+8, self.width - 30, 30)];
    labNotice.backgroundColor = kColorClear;
    labNotice.textColor = kColorNewGray2;
    labNotice.font = kFontSmall;
    labNotice.numberOfLines = 2;
    labNotice.text = @"排放标准是汽车尾气排放的环保标准，各城市都有自己排放的标准迁入限制，不满足将不能迁入车辆。";
    [self addSubview:labNotice];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"限迁标准查询" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

- (UIView *)createListButtonViewAtOriginPoint:(CGPoint)origin{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = kColorClear;
    
    for (int i = 0; i < self.arrTitle.count; i++) {
        
        UIView *hLineT = [[UIView alloc] initLineWithFrame:CGRectMake(0, 20+i*(20+46), self.width, kLinePixel) color:kColorNewLine];
        [view addSubview:hLineT];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, hLineT.maxY, self.width, 46);
        [button setBackgroundColor:kColorWhite];
        [button.titleLabel setFont:kFontLarge];
        [button setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
        NSString *iconName = [self.arrIcon objectAtIndex:i];
        [button setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
        [button setTitle:[self.arrTitle objectAtIndex:i] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:button.size] forState:UIControlStateHighlighted];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        button.tag = i;
        [button addTarget:self action:@selector(onClickListBtn:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        UIView *hLineB = [[UIView alloc] initLineWithFrame:CGRectMake(0, button.maxY, self.width, kLinePixel) color:kColorNewLine];
        [view addSubview:hLineB];
        
        UIImageView *ivArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 33, (button.height - 18) / 2, 18, 18)];
        [ivArrow setImage:[UIImage imageNamed:@"set_arrow_right"]];
        [button addSubview:ivArrow];
    }
    
    [view setOrigin:origin];
    [view setSize:CGSizeMake(self.width, (20+46+kLinePixel*2)*self.arrTitle.count)];
    
    
    return view;
}


#pragma mark - button actions
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

- (void)onClickListBtn:(UIButton *)btn{
    switch (btn.tag) {
        case 0:
        {
            if (![OMG isValidClick])
                return;
            [UMStatistics event:c_4_1_tool_displacement_area];
            UCEmissionSearchView *vSearch = [[UCEmissionSearchView alloc] initWithFrame:self.bounds];
            [[MainViewController sharedVCMain] openView:vSearch animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
        case 1:
        {
            if (![OMG isValidClick])
                return;
            [UMStatistics event:c_4_1_tool_displacement_standard];
            UCEmissionStandardView *vStandard = [[UCEmissionStandardView alloc] initWithFrame:self.bounds emissionString:@"京5"];
            [[MainViewController sharedVCMain] openView:vStandard animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
        default:
            break;
    }
}

@end
