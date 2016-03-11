//
//  InfiniteScrollView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-9-28.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"

@protocol InfiniteScrollViewDelegate;

@interface InfiniteScrollView : UIView


@property (nonatomic, strong) UIScrollView *vScroll;
@property (nonatomic, strong) SMPageControl *ctrlPage;
@property (nonatomic, weak) id<InfiniteScrollViewDelegate> delegate;


- (id)initWithFrame:(CGRect)frame withViewArray:(NSArray *)arrView;

- (id)initWithFrame:(CGRect)frame withImageNameArray:(NSArray *)arrImageName;

@end

@protocol InfiniteScrollViewDelegate <NSObject>

@optional
- (void)InfiniteScrollView:(InfiniteScrollView*)infiniteScrollView didClickItemOnIndex:(NSInteger)index;

@end