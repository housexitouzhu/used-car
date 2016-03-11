//
//  UCRecommendCarList.h
//  UsedCar
//
//  Created by 张鑫 on 13-11-18.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCCarDetailInfoModel.h"
#import "UCOptionBar.h"
#import "UCCarListView.h"

typedef enum {
    UCRecommendCarListStylePrice = 100,
    UCRecommendCarListStyleLevel,
    UCRecommendCarListStyleSeries,
} UCRecommendCarListStyle;

@interface UCRecommendCarList : UCView<UCOptionBarDelegate, UCCarListViewDelegate>

@property (nonatomic ,strong) UCCarDetailInfoModel *mCarDetailInfo;

- (id)initWithFrame:(CGRect)frame mCarDetailInfo:(UCCarDetailInfoModel *)mCarDetailInfo;

@end
