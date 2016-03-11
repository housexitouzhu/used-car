//
//  UCChangeScrollView.h
//  UsedCar
//
//  Created by 张鑫 on 14-6-6.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UCChangeScrollViewPullTypeUp = 100,
    UCChangeScrollViewPullTypeDown,
} UCChangeScrollViewPullType;

typedef enum {
    UCChangeScrollViewPositionTop = 200,
    UCChangeScrollViewPositionBottom,
} UCChangeScrollViewPosition;

@protocol UCChangeScrollViewDelegate;

@interface UCChangeScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *vHeader;
@property (nonatomic, strong) UIView *vFooter;
@property (nonatomic, weak) id<UCChangeScrollViewDelegate> delegateChange;

/**
 *  初始化方法
 *
 *  @param frame         大小
 *  @param isOpenTurning 是否开启上下翻页
 *
 *  @return id
 */
- (id)initWithFrame:(CGRect)frame isOpenTurning:(BOOL)isOpenTurning;

/**
 *  设置文字 - 居中显示
 *
 *  @param head           头部的文字
 *  @param isTopHidden    是否隐藏顶部圆形加载进度
 *  @param foot           底部的文字
 *  @param isBottomHidden 是否隐藏底部圆形加载进度
 */
- (void)setHeaderText:(NSString *)head topCircleHidden:(BOOL)isTopHidden footerText:(NSString *)foot topCircleHidden:(BOOL)isBottomHidden;

@end

@protocol UCChangeScrollViewDelegate <NSObject>
@optional

- (void)UCChangeScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)UCChangeScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)UCChangeScrollViewDidPull:(UIScrollView *)scrollView pullType:(UCChangeScrollViewPullType)pullType;

@end
