//
//  UIImageView+Util.m
//  UsedCar
//
//  Created by Alan on 13-11-11.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UIImageView+Util.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationKey @"rotate"

@implementation UIImageView (Util)

- (void)startCoreAnimating
{
    
    //    CGAffineTransform  transform = CGAffineTransformRotate(self.transform, M_PI);
    //    [UIView beginAnimations:kAnimationKey context:nil];
    //    [UIView setAnimationDuration:1];
    //    [UIView setAnimationRepeatCount:MAXFLOAT];
    //    [self setTransform:transform];
    //    [UIView commitAnimations];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2 , 0, 0, 1.0)];
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    [self.layer addAnimation:animation forKey:kAnimationKey];
    
    
    //    [self startAnimating];
    //    CATransform3D rotationTransform  = CATransform3DRotate(self.transform, 0, 0, 0, M_PI);
    //    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    //    animation.toValue= [NSValue valueWithCATransform3D:rotationTransform];
    ////    animation.duration= dur;
    //    animation.autoreverses= NO;
    //    animation.cumulative= YES;
    //    animation.removedOnCompletion=NO;
    //    animation.fillMode=kCAFillModeForwards;
    ////    animation.repeatCount= repeatCount;
    //    animation.delegate= self;
}

- (void)stopCoreAnimating
{
    [self.layer removeAllAnimations];
}

- (BOOL)isCoreAnimating
{
    return [self.layer animationForKey:kAnimationKey] ? YES : NO;
}

@end
