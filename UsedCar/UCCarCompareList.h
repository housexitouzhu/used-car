//
//  UCCarCompareList.h
//  UsedCar
//
//  Created by wangfaquan on 14-1-27.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCCarDetailInfoModel.h"

@class UCTopBar;

@interface UCCarCompareList : UIView <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *compareItems;
@property (nonatomic, strong) UCTopBar *tbTop;

- (id)initWithFrame:(CGRect)frame compareItems:(NSMutableArray *)compareItems;
- (void)reloadData;

@end

