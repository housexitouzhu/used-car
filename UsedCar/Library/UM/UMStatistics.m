//
//  UMStatistics.m
//  UsedCar
//
//  Created by Alan on 14-1-4.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UMStatistics.h"
#import "MobClick.h"

@implementation UMStatistics

/* 友盟事件统计 */
+ (void)event:(NSString *)eventId{
    AMLog(@"eventId:%@", eventId);
    [MobClick event:eventId];
}

+ (void)event:(NSString *)eventId label:(NSString *)label
{
    AMLog(@"eventId:%@ label:%@", eventId, label);
    [MobClick event:eventId label:label];
}

+ (void)beginEvent:(NSString *)eventId{
    [MobClick beginEvent:eventId];
}

+ (void)endEvent:(NSString *)eventId{
    [MobClick endEvent:eventId];
}

+ (void)beginPageName:(NSString *)name{
    [MobClick beginLogPageView:name];
}

+ (void)endPageName:(NSString *)name{
    [MobClick endLogPageView:name];
}

+ (void)beginPageView:(UIView *)view{
    [MobClick beginLogPageView:NSStringFromClass(view.class)];
}

+ (void)endPageView:(UIView *)view{
    [MobClick endLogPageView:NSStringFromClass(view.class)];
}

@end
