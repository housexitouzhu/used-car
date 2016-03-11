//
//  UCCarCompareDetailView.h
//  UsedCar
//
//  Created by wangfaquan on 14-1-28.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

@interface UCCarCompareDetailView : UCView <UIScrollViewDelegate>

/** 车辆详情 */
- (id)initWithFrame:(CGRect)frame twoCar:(NSArray *)twoCompareModel;

@end
