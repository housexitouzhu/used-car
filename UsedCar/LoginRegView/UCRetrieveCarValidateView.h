//
//  UCVerifyMobileView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-9-19.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

@protocol UCRetrieveCarValidateViewDelegate;

@interface UCRetrieveCarValidateView : UCView

@property (nonatomic, weak) id<UCRetrieveCarValidateViewDelegate> delegate;

@end

@protocol UCRetrieveCarValidateViewDelegate <NSObject>

- (void)UCRetrieveCarValidateView:(UCRetrieveCarValidateView*)view validateSuccess:(BOOL)success;

@end