//
//  UCWelcome.h
//  UsedCar
//
//  Created by wangfaquan on 14-2-26.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

@protocol UCWelcomeDelegate;

@interface UCWelcome : UCView <UIScrollViewDelegate> {
    UIScrollView *_svScroll;
    NSUInteger _pageNumber;
    UIPageControl *_pcPhoto;
}

@property (nonatomic, weak) id<UCWelcomeDelegate>delegate;

@end

@protocol UCWelcomeDelegate <NSObject>

- (void)didCloseWelcomeView:(UCWelcome *)vWelcome;

@end
