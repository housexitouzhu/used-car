//
//  UCView.m
//  UsedCar
//
//  Created by Alan on 13-10-25.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
//#import "UMSAgent.h"

@implementation UCView

- (void)viewWillShow:(BOOL)animated
{
//    AMLog(@"viewWillShow: %@", self);
    // 支持手势返回
    _isSupportGesturesToBack = YES;
    [self notifySubviewState:self sel:@"viewWillShow:"];
    
    if ([self excludeRecordList]) {
//        [UMSAgent startTracPage:NSStringFromClass(self.class)];
        // 页面开始访问统计
        [UMStatistics beginPageView:self];
    }
    // 给视图添加阴影效果
    [self addLayer];
}

- (void)viewDidShow:(BOOL)animated
{
//    AMLog(@"viewDidShow: %@", self);
    
    [self notifySubviewState:self sel:@"viewDidShow:"];
}

- (void)viewWillHide:(BOOL)animated
{
//    AMLog(@"viewWillHide: %@", self);
    
    [self notifySubviewState:self sel:@"viewWillHide:"];
    
    if ([self excludeRecordList]) {
//        [UMSAgent endTracPage:NSStringFromClass(self.class)];
        // 页面结束访问统计
        [UMStatistics endPageView:self];
    }
}

- (void)viewDidHide:(BOOL)animated
{
//    AMLog(@"viewDidHide: %@", self);
    
    [self notifySubviewState:self sel:@"viewDidHide:"];
}

- (void)viewWillClose:(BOOL)animated
{
    [self notifySubviewState:self sel:@"viewWillClose"];
}

/** 给视图添加阴影效果 */
- (void)addLayer
{
    [self.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.layer setShadowOpacity:0.1];
    [self.layer setShadowOffset:CGSizeMake(-5, 0)];
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)notifySubviewState:(UIView *)view sel:(NSString *)func
{
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UCView class]]) {
            if ([func isEqualToString:@"viewWillShow:"]) {
                [(UCView *)subview viewWillShow:YES];
            } else if ([func isEqualToString:@"viewDidShow:"]) {
                [(UCView *)subview viewDidShow:YES];
            } else if ([func isEqualToString:@"viewWillHide:"]) {
                [(UCView *)subview viewWillHide:YES];
            } else if ([func isEqualToString:@"viewDidHide:"]) {
                [(UCView *)subview viewDidHide:YES];
            } else if ([func isEqualToString:@"viewWillClose"]) {
                [(UCView *)subview viewWillClose:YES];
            }
//            [subview performSelector:NSSelectorFromString(func)];
        }
        if (subview.subviews > 0) {
            [self notifySubviewState:subview sel:func];
        }
    }
}

/** 排出记录类 */
- (BOOL)excludeRecordList
{
    BOOL isRecord;
    if (![self isKindOfClass:NSClassFromString(@"UCMainView")] && ![self isKindOfClass:NSClassFromString(@"UCSaleCarRootView")])
        isRecord = YES;
    else
        isRecord = NO;
    return isRecord;
}

@end
