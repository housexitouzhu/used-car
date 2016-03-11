//
//  AMBlurView.m
//  UsedCar
//
//  Created by Alan on 13-8-16.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "AMBlurView.h"
#import "AMToolBar.h"

@interface AMBlurView ()

@property (nonatomic, strong) AMToolBar *blurView;

@end

@implementation AMBlurView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.clipsToBounds = YES;
    _isEnableBlur = YES;
    if (IOS7_OR_LATER) {
        if (!_blurView) {
            _blurView = [[AMToolBar alloc] initWithFrame:self.bounds];
            [self.layer insertSublayer:_blurView.layer atIndex:0];
        }
    } else {
        [self setBlurTintColor:nil];
    }
}

- (void)setIsEnableBlur:(BOOL)isEnableBlur
{
    if (_isEnableBlur != isEnableBlur) {
        _isEnableBlur = isEnableBlur;
        if (isEnableBlur) {
            [self setup];
        } else {
            if (_blurView) {
                [_blurView.layer removeFromSuperlayer];
                self.blurView = nil;
            } else {
                self.backgroundColor = nil;
            }
        }
    }
}

- (void)setBlurTintColor:(UIColor *)blurTintColor
{
    if (_blurView) {
        _blurView.barTintColor = blurTintColor;
    } else {
        if (!blurTintColor)
            blurTintColor = kColorWhite;
//        if (blurTintColor)
//            blurTintColor = [blurTintColor colorWithAlphaComponent:CGColorGetAlpha(blurTintColor.CGColor) - 0.2];
        self.backgroundColor = blurTintColor;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_blurView)
        _blurView.frame = self.bounds;
}

@end
