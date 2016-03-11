//
//  UCHelpPromptView.m
//  UsedCar
//
//  Created by 张鑫 on 14-3-21.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCHelpPromptView.h"

@interface UCHelpPromptView ()

@property (nonatomic) UCHelpPromptViewTag viewTag;

@end

@implementation UCHelpPromptView

- (id)initWithFrame:(CGRect)frame UCHelpPromptViewTag:(UCHelpPromptViewTag)viewTag
{
    self = [super initWithFrame:frame];
    if (self) {
        _viewTag = viewTag;
        [self initView];
    }
    return self;
}

- (void)initView
{
    switch (_viewTag) {
        // 夜间模式
        case UCHelpPromptViewTagNightMode:
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.98];
            
            // 夜间背景
            UIImage *iNight = [UIImage imageNamed:@"night_stars"];
            UIImageView *ivNight = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - iNight.size.width) / 2, (self.height - iNight.size.height) / 2, iNight.size.width, iNight.size.height)];
            ivNight.image = iNight;
            
            // 夜间提示语
            UILabel *labPrompt = [[UILabel alloc] init];
            labPrompt.backgroundColor = [UIColor clearColor];
            labPrompt.textColor = kColorWhite;
            labPrompt.font = [UIFont systemFontOfSize:15];
            labPrompt.text = @"光线暗啦~切换到夜间模式保护眼睛吧！\nBaby~";
            labPrompt.numberOfLines = 2;
            labPrompt.textAlignment = NSTextAlignmentCenter;
            [labPrompt sizeToFit];
            labPrompt.origin = CGPointMake((self.width - labPrompt.width) / 2, (self.height - labPrompt.height) / 2);
            
            // 上分割线
            UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, self.height - 46, self.width, kLinePixel) color:[UIColor colorWithWhite:1 alpha:0.1]];
            
            NSArray *titles = @[@"我就不",@"好的呢"];
            for (int i = 0; i < titles.count; i++) {
                UIButton *btnItem = [[UIButton alloc] initWithFrame:CGRectMake(i * self.width / 2, self.height - 45, self.width / 2, 45)];
                [btnItem setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
                btnItem.titleLabel.font = [UIFont systemFontOfSize:16];
                [btnItem setTitleColor:kColorGrey2 forState:UIControlStateNormal];
                [btnItem setTitleColor:kColorWhite forState:UIControlStateHighlighted];
                btnItem.tag = i;
                [btnItem addTarget:self action:@selector(onClickBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:btnItem];
                
                if (i == 1) {
                    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, kLinePixel, btnItem.height) color:[UIColor colorWithWhite:1 alpha:0.1]];
                    [btnItem addSubview:vLine];
                }
            }
            
            //添加视图
            [self addSubview:ivNight];
            [self addSubview:labPrompt];
            [self addSubview:vLine];
        }
            break;
            
        default:
            break;
    }
}

/** 关闭页面 */
- (void)closeView
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - onClickButton
- (void)onClickBottomBtn:(UIButton *)btn
{
    if (btn.tag == 0) {
        
    } else if (btn.tag == 1) {
        
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kConfigIsShowNightPrompt];
    [self closeView];
}

@end
