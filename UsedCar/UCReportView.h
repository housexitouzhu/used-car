//
//  UCReportView.h
//  UsedCar
//
//  Created by wangfaquan on 14-6-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCChooseCarView.h"

@interface UCReportView : UCView <UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate,UIGestureRecognizerDelegate, UCChooseCarViewDelegate>

@property (nonatomic, strong) NSString *carName;
@property (nonatomic, strong) NSNumber *carId;
@property (nonatomic, strong) NSNumber *brandid;
@property (nonatomic, strong) NSNumber *seriesid;
@property (nonatomic, strong) NSNumber *specid;

@end
