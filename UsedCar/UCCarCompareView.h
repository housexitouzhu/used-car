//
//  UCCarCompareView.h
//  UsedCar
//
//  Created by wangfaquan on 14-1-27.
//  Copyright (c) 2014年 Alan. All rights reserved.
//
#import <UIKit/UIKit.h>

@class UCCarCompareView;

@protocol UCCarCompareViewDelegate;

@interface UCCarCompareView : UIView

@property (nonatomic, strong) NSMutableArray *compareItems;
@property (nonatomic, weak) id<UCCarCompareViewDelegate> delegate;

- (void)reloadData;
+ (UCCarCompareView *)shareCompare;

@end

@protocol UCCarCompareViewDelegate <NSObject>

@optional

- (void)closeCompareView:(NSMutableArray *)compareItems;

@end
