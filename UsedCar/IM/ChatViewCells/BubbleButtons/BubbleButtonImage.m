//
//  BubbleButtonImage.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-25.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "BubbleButtonImage.h"

@implementation BubbleButtonImage

- (id)initWithCustomButtonWithType:(BubbleType)type{
    self = [super initWithCustomButtonWithType:type];
    if (self) {
        
        _vCarImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [_vCarImage setContentMode:UIViewContentModeScaleAspectFill];
        [_vCarImage setBackgroundColor:kColorClear];
        [self addSubview:_vCarImage];
        
        _vProgress = [[DAProgressOverlayView alloc] initWithFrame:self.bounds];
        _vProgress.hidden = YES;
        _vProgress.userInteractionEnabled = NO;
        [self addSubview:_vProgress];
        
    }
    return self;
}

- (void)setBubbleType:(BubbleType)bubbleType{
    [super setBubbleType:bubbleType];
    _maskImage = (bubbleType == BubbleTypeLeft ? self.bubbleImageLeft : self.bubbleImageRight);
    
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.contents = (__bridge id)([_maskImage CGImage]);
    [self.layer setMasksToBounds:YES];
    [self.layer setMask:maskLayer];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _vCarImage.frame = self.bounds;
    _vProgress.frame = self.bounds;
}

@end
