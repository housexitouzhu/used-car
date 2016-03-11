//
//  UIView+Screenshot.h
//  CarPrice
//
//  Created by 王俊 on 13-11-11.
//  Copyright (c) 2013年 ATHM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Screenshot)


- (UIImage *)rn_screenshot;
- (UIImage *)rn_screenshotOfSize:(CGSize)size;
- (UIImage *)screenshotWithOffset:(CGFloat)deltaY;


/**
 *  @method
 *  @abstract  获取当前view的截图，如果是iOS7，使用新的函数
 *              据说性能提升15倍
 *  @return
 */
- (UIImage *)ah_capture;

/**
 *  @method
 *  @abstract  获取当前scrollView的截图
 *  @return
 */
- (UIImage *)ah_captureScrollView;

@end
