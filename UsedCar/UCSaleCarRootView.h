//
//  UCSaleCarRootView.h
//  UsedCar
//
//  Created by wangfaquan on 14-3-13.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCSaleCarView.h"
#import "UCReleaseSucceedView.h"

@class UCCarInfoEditModel;

@protocol  UCSaleCarRootViewDelegate;

typedef enum : NSUInteger {
    UCSaleCarRootViewFromRootView,
    UCSaleCarRootViewFromEvaluationView,
} UCSaleCarRootViewFrom;

@interface UCSaleCarRootView : UCView <UCReleaseCarViewDelegate, UCReleaseSucceedViewDelegate>

@property (nonatomic, weak) id delegate;

- (id)initWithFrame:(CGRect)frame fromView:(UCSaleCarRootViewFrom)fromView;

@end

@protocol UCSaleCarRootViewDelegate <NSObject>

- (void)UCSaleCarRootViewDidSelectedUserType:(UCSaleCarRootView *)vSaleCarRoot;

@end
