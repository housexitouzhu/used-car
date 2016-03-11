//
//  UCEvaluationSimilarView.h
//  UsedCar
//
//  Created by 张鑫 on 14/10/23.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCOrderView.h"
#import "UCCarListView.h"

@class UCCarInfoEditModel;

@interface UCEvaluationSimilarView : UCView <UCOrderViewDelegate, UCCarListViewDelegate>

- (id)initWithFrame:(CGRect)frame carInfoDEditModel:(UCCarInfoEditModel *)mCarInfoEdit;

@end
