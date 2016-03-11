//
//  UCAutonomyAddView.h
//  UsedCar
//
//  Created by wangfaquan on 14-5-13.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UISelectorView.h"
#import "UCFilterBrandView.h"

@protocol UCAutonomyViewDelegate;

@interface UCAutonomyAddView : UCView<UITextFieldDelegate, UISelectorViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<UCAutonomyViewDelegate> delegate;

@end

@protocol UCAutonomyViewDelegate <NSObject>

- (void)UCAutonomyAddView:(UCAutonomyAddView *)mAutonomyAdd didFinishEditCarInfo:(NSDictionary *)carInfo;

@end
