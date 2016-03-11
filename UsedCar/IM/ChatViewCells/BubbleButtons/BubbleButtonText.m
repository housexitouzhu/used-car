//
//  BubbleButtonText.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-25.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "BubbleButtonText.h"

@implementation BubbleButtonText

- (id)initWithCustomButtonWithType:(BubbleType)type{
    
    self = [super initWithCustomButtonWithType:type];
    
    if (self) {
        
        [self.titleLabel setFont:kFontLarge];
        [self.titleLabel setBackgroundColor:kColorClear];
        [self.titleLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [self.titleLabel setNumberOfLines:0]; //UIButton 设置lines 为0, 它会自动计算适应的行数
        [self setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
        
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    
    CGSize frameSize = self.frame.size;
    
    switch (self.bubbleType) {
        case BubbleTypeLeft:
        {
            if (frameSize.height > kBubbleHeight_MIN) {
                return CGRectMake(kBubbleTailGap, 0, frameSize.width - kBubbleHeadGap - kBubbleTailGap, frameSize.height);
            }
            else{
                return CGRectMake(kBubbleTailGap, 0, frameSize.width, frameSize.height);
            }
        }
            break;
        case BubbleTypeRight:
        {
            if (frameSize.height > kBubbleHeight_MIN) {
                return CGRectMake(kBubbleHeadGap, 0, frameSize.width - kBubbleHeadGap - kBubbleTailGap, frameSize.height);
            }
            else{
                return CGRectMake(kBubbleHeadGap, 0, frameSize.width, frameSize.height);
            }
        }
            break;
        default:
            return  [super titleRectForContentRect:contentRect];
            break;
    }
}

- (void)setTitle:(NSString *)title{
    [super setTitle:title forState:UIControlStateNormal];
}

- (void)setBubbleType:(BubbleType)bubbleType{
    [super setBubbleType:bubbleType];
    [self setBackgroundImage:(bubbleType == BubbleTypeLeft ? self.bubbleLeft : self.bubbleRight) forState:UIControlStateNormal];
    [self setBackgroundImage:(bubbleType == BubbleTypeLeft ? self.bubbleLeftPress : self.bubbleRightPress) forState:UIControlStateHighlighted];
}

@end
