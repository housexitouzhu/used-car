//
//  UCToolsView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-8-6.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCToolsView.h"
#import "UCTopBar.h"
#import "UCEvaluationView.h"
#import "UCClaimView.h"
#import "UCExchangeView.h"
#import "UCEmissionMainView.h"
#import "UIImage+Util.h"

@interface UCToolsView ()

@property (retain, nonatomic) UCTopBar *tbTop;
@property (retain, nonatomic) UIScrollView *vScroll;
@property (retain, nonatomic) NSArray *imageNames;
@property (retain, nonatomic) NSArray *buttonNames;

@end

@implementation UCToolsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageNames = @[@"tool_evaluation",
                        @"tool_limit",
                        @"tool_claimdemage",
                        @"tool_gift"];
        
        self.buttonNames = @[@"车辆估价",@"限迁标准查询",@"保障车索赔",@"成交换礼"];
        
        [self initView];
    }
    return self;
}

//+ (NSArray *)buttonNames
//{
//    static NSArray *_buttonNames;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _buttonNames = @[@"车辆估价",@"保障车索赔",@"成交换礼"];
//    });
//    return _buttonNames;
//}
//
//+ (NSArray *)imageNames
//{
//    static NSArray *_imageNames;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _imageNames = @[@"",@"",@""];
//    });
//    return _imageNames;
//}

- (void)initView{
    
    self.backgroundColor = kColorNewBackground;
    
    // 导航头
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    [self addSubview:_tbTop];
    
    _vScroll = [[UIScrollView alloc] initWithFrame: CGRectMake(0, _tbTop.maxY, self.width, self.height-_tbTop.maxY- 40)];
    _vScroll.backgroundColor = kColorNewBackground;
    [self addSubview:_vScroll];
    
    UIView *vButtons = [self createButtonsFromPoint:CGPointMake(0, 20)];
    [self.vScroll addSubview:vButtons];
    
//    self.vScroll.contentSize = CGSizeMake(0, vButtons.maxY);
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"工具" forState:UIControlStateNormal];
    
    
    return vTopBar;
}

- (UIView *)createButtonsFromPoint:(CGPoint)origin{
    
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectZero];
    baseView.backgroundColor = kColorWhite;
    
    UIView *hLineT = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine];
    [baseView addSubview:hLineT];
    
    for (int i = 0; i < self.buttonNames.count; i++) {
        
        UIButton *btnItem = [UIButton buttonWithType:UIButtonTypeCustom];
        btnItem.frame = CGRectMake(0, kLinePixel + i*(kLinePixel + 50), self.width, 50);
        btnItem.titleLabel.font = kFontLarge1;
        [btnItem setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
        btnItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btnItem setTitle:[self.buttonNames objectAtIndex:i] forState:UIControlStateNormal];
        [btnItem setImage:[UIImage imageNamed:[self.imageNames objectAtIndex:i]] forState:UIControlStateNormal];
        [btnItem setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnItem.size] forState:UIControlStateHighlighted];
        btnItem.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        btnItem.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
        btnItem.tag = i;
        [btnItem addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [baseView addSubview:btnItem];
        
        //箭头
        UIImageView * arrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 33, 16, 18, 18)];
        arrow.image = [UIImage imageNamed:@"set_arrow_right"];
        [btnItem addSubview:arrow];
        
        if (i != self.buttonNames.count-1) {
            UIView *hLine = [[UIView alloc] initLineWithFrame:CGRectMake(59, btnItem.maxY, self.width, kLinePixel) color:kColorNewLine];
            [baseView addSubview:hLine];
        }
        else{
            UIView *hLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, btnItem.maxY, self.width, kLinePixel) color:kColorNewLine];
            [baseView addSubview:hLine];
        }
        
    }
    
    [baseView setOrigin:origin];
    [baseView setSize:CGSizeMake(self.width, kLinePixel + (50 + kLinePixel)*self.buttonNames.count)];
    
    return baseView;
}


- (void)buttonClicked:(UIButton *)sender{
    MainViewController *vcMain = [MainViewController sharedVCMain];
    
    switch (sender.tag) {
        case 0:
        {
            if (![OMG isValidClick])
                return;
            [UMStatistics event:c_3_9_2_tool_evaluation];
            UCEvaluationView *vEvaluation = [[UCEvaluationView alloc] initWithFrame:vcMain.vMain.bounds];
            [vcMain openView:vEvaluation animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
        case 1:
        {
            if (![OMG isValidClick])
                return;
            [UMStatistics event:c_4_1_tool_displacement];
            UCEmissionMainView *vEmissionView = [[UCEmissionMainView alloc] initWithFrame:vcMain.vMain.bounds];
            [vcMain openView:vEmissionView animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
        case 2:
        {
            if (![OMG isValidClick])
                return;
            [UMStatistics event:c_3_9_2_tool_payment];
            UCClaimView *claimView = [[UCClaimView alloc] initWithFrame:vcMain.vMain.bounds];
            [vcMain openView:claimView animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
        case 3:
        {
            if (![OMG isValidClick])
                return;
            [UMStatistics event:c_3_9_2_tool_dressing];
            UCExchangeView *exchangeView = [[UCExchangeView alloc] initWithFrame:vcMain.vMain.bounds];
            [vcMain openView:exchangeView animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
        default:
            break;
    }
}

@end


//方格布局的实现
//- (void)createButtons{
//
//    int totalRow = ceil(_imageNames.count/2.0f);
//    for (int row = 0; row < totalRow; row++) {
//        
//        for (int i = 0; i < 2; i++) {
//            
//            int imageIndex = row*2 + i;
//            if (imageIndex<_imageNames.count)
//            {
//                NSString *imageName = [_imageNames objectAtIndex:imageIndex];
//                NSString *highlightImageName = [_highlightImageNames objectAtIndex:imageIndex];
//                
//                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//                [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//                [button setImage:[UIImage imageNamed:highlightImageName] forState:UIControlStateSelected];
//                [button setImage:[UIImage imageNamed:highlightImageName] forState:UIControlStateHighlighted];
//                [button setTag:imageIndex];
//                [button setFrame:CGRectMake(160*i, 160*row, 160, 160)];
//                [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [_vScroll addSubview:button];
//            }
//        }
//    }
//    
//    
//    [_vScroll setContentSize:CGSizeMake(self.width, totalRow*160)];
//    
//}