//
//  UCBusinessInfoView.h
//  UsedCar
//
//  Created by 张鑫 on 13-12-2.
//  Copyright (c) 2013年 Alan. All rights reserved.
//  商家信息

#import "UCView.h"
#import <MapKit/MapKit.h>
#import "UCCarListView.h"

typedef enum {
    NavigateStyleGaode = 0,
    NavigateStyleBaidu = 1,
    NavigateStyleDefault = 2,
} NavigateStyle;

@class UCCarDetailInfoModel;

@interface UCBusinessInfoView : UCView <CLLocationManagerDelegate, UCCarListViewDelegate>

- (id)initWithFrame:(CGRect)frame userid:(NSNumber *)userid;

@end
