//
//  UCClictVerifyView.h
//  UsedCar
//
//  Created by 张鑫 on 14/11/18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

@class UCClientVerifyView;

@protocol UCClientVerifyViewDelegate;

typedef void(^RegisterCliectIM)(UCClientVerifyView *vClientIM, BOOL isSuccess, NSError *error);

@interface UCClientVerifyView : UCView <UITextFieldDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic ,copy) RegisterCliectIM blockClient;
@property (nonatomic, weak) id<UCClientVerifyViewDelegate> delegate;

- (void)verifyClientIM:(RegisterCliectIM)block;

@end

@protocol UCClientVerifyViewDelegate <NSObject>

- (void)clientVerifyViewDidClickCancel:(UCClientVerifyView *)vClientVerify;

@end