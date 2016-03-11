//
//  BubbleButtonCar.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-25.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "BubbleButtonCar.h"

@implementation BubbleButtonCar

- (id)initWithCustomButtonWithType:(BubbleType)type{
    self = [super initWithCustomButtonWithType:type];
    if (self) {
        
        _labCarName = [[UILabel alloc] initWithFrame:CGRectZero];
        _labCarName.backgroundColor = kColorClear;
        _labCarName.font = kFontLarge;
        _labCarName.textColor = kColorNewGray1;
        [self addSubview:_labCarName];
        
        _imageViewCar = [[UIImageView alloc] initWithFrame:CGRectMake(9, _labCarName.maxY + 7, 60, 45)];
        [_imageViewCar setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:_imageViewCar];
        
        _labPrice = [[UILabel alloc] initWithFrame:CGRectZero];
        _labPrice.backgroundColor = kColorClear;
        _labPrice.font = kFontSmall;
        _labPrice.textColor = kColorNewGray1;
        [self addSubview:_labPrice];
        
        _labRegDate = [[UILabel alloc] initWithFrame:CGRectZero];
        _labRegDate.backgroundColor = kColorClear;
        _labRegDate.font = kFontSmall;
        _labRegDate.textColor = kColorNewGray1;
        [self addSubview:_labRegDate];
        
        _labMileage = [[UILabel alloc] initWithFrame:CGRectZero];
        _labMileage.backgroundColor = kColorClear;
        _labMileage.font = kFontSmall;
        _labMileage.textColor = kColorNewGray1;
        [self addSubview:_labMileage];
        
    }
    return self;
}

- (void)setBubbleType:(BubbleType)bubbleType{
    [super setBubbleType:bubbleType];
    
    [self setBackgroundImage:(bubbleType == BubbleTypeLeft ? self.bubbleInfoLeft : self.bubbleInfoRight) forState:UIControlStateNormal];
    [self setBackgroundImage:(bubbleType == BubbleTypeLeft ? self.bubbleInfoLeftPress : self.bubbleInfoRightPress) forState:UIControlStateHighlighted];
    
    CGFloat smallLabelWidth = kBubbleCarWidth - kBubbleHeadGap - 60 - 6 - kBubbleTailGap;
    if (bubbleType == BubbleTypeLeft) {
        [_labCarName setFrame:CGRectMake(kBubbleTailGap, 9, kBubbleCarWidth - kBubbleHeadGap - kBubbleTailGap, kFontLarge.pointSize)];
        [_imageViewCar setFrame:CGRectMake(kBubbleTailGap, _labCarName.maxY + 7, 60, 45)];
        [_labPrice setFrame:CGRectMake(_imageViewCar.maxX + 6, _imageViewCar.minY, smallLabelWidth, kFontSmall.pointSize)];
        [_labRegDate setFrame:CGRectMake(_imageViewCar.maxX + 6, _labPrice.maxY + 4, smallLabelWidth, kFontSmall.pointSize)];
        [_labMileage setFrame:CGRectMake(_imageViewCar.maxX + 6, _labRegDate.maxY + 4, smallLabelWidth, kFontSmall.pointSize)];
    }
    else{
        [_labCarName setFrame:CGRectMake(kBubbleHeadGap, 9, kBubbleCarWidth - kBubbleHeadGap - kBubbleTailGap, kFontLarge.pointSize)];
        [_imageViewCar setFrame:CGRectMake(kBubbleHeadGap, _labCarName.maxY + 7, 60, 45)];
        [_labPrice setFrame:CGRectMake(_imageViewCar.maxX + 6, _imageViewCar.minY, smallLabelWidth, kFontSmall.pointSize)];
        [_labRegDate setFrame:CGRectMake(_imageViewCar.maxX + 6, _labPrice.maxY + 4, smallLabelWidth, kFontSmall.pointSize)];
        [_labMileage setFrame:CGRectMake(_imageViewCar.maxX + 6, _labRegDate.maxY + 4, smallLabelWidth, kFontSmall.pointSize)];
    }
    
}


@end
