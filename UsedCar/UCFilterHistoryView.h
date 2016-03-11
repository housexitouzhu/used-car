//
//  UCFilterHistoryView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
@class UCFilterModel;

@protocol UCFilterHistoryViewDelegate <NSObject>

- (void)filterHistoryDidSelectModel:(UCFilterModel *)model;

@end

@interface UCFilterHistoryView : UCView

@property (retain, nonatomic) id<UCFilterHistoryViewDelegate> delegate;

@end
