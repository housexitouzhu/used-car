//
//  UCLoginDealerView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-9-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

@protocol UCLoginDealerViewDelegate;

@interface UCLoginDealerView : UCView

@property (nonatomic, weak) id<UCLoginDealerViewDelegate> delegate;

@end


@protocol UCLoginDealerViewDelegate <NSObject>

@optional
- (void)UCLoginDealerView:(UCLoginDealerView*)vLoginDealer loginSuccess:(BOOL)success;

@end