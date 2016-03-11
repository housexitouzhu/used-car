//
//  UCRaiderView.h
//  UsedCar
//
//  Created by wangfaquan on 13-12-18.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCOptionBar.h"
#import "UCFilterView.h"

@interface UCRaiderView : UCView<UCFilterViewDelegate,UCOptionBarDelegate>

@property (nonatomic, strong) UCFilterView *vFilter;
@property (nonatomic) BOOL isRecord;

- (void)recordMustSeeEvent;

@end
