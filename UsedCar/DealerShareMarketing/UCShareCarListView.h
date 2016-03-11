//
//  UCShareCarListView.h
//  UsedCar
//
//  Created by 张鑫 on 14-10-15.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCCarListView.h"

@class UCShareHistoryModel;

@interface UCShareCarListView : UCView <UCCarListViewDelegate>

- (id)initWithFrame:(CGRect)frame shareCarModel:(UCShareHistoryModel *)mShareCar;

@end
