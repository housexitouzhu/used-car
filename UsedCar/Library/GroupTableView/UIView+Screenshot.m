//
//  UIView+Screenshot.m
//  CarPrice
//
//  Created by 王俊 on 13-11-11.
//  Copyright (c) 2013年 ATHM. All rights reserved.
//

#import "UIView+Screenshot.h"

@implementation UIView (Screenshot)

- (UIImage *)rn_screenshot
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // helps w/ our colors when blurring
    // feel free to adjust jpeg quality (lower = higher perf)
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    image = [UIImage imageWithData:imageData];
    
    return image;
}

- (UIImage *)rn_screenshotOfSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // helps w/ our colors when blurring
    // feel free to adjust jpeg quality (lower = higher perf)
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    image = [UIImage imageWithData:imageData];
    
    return image;
}

- (UIImage *)screenshotWithOffset:(CGFloat)deltaY
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //  KEY: need to translate the context down to the current visible portion of the tablview
    CGContextTranslateCTM(ctx, 0, deltaY);
    [self.layer renderInContext:ctx];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenshot;
}

/**
 *  @method
 *  @abstract  获取当前view的截图，如果是iOS7，使用新的函数
 *              据说性能提升15倍
 *  @return
 */
- (UIImage *)ah_capture
{
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    {
        if (IOS7_OR_LATER)
        {
            [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
        }
        else
        {
            [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        }
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)ah_captureScrollView
{
    // 如果确实是scrollView
    if ([self isKindOfClass:[UIScrollView class]])
    {
        UIImage *image = nil;
        UIScrollView *scrollView = (UIScrollView *)self;
        UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, NO, 0.0);
        {
            CGPoint savedContentOffset = scrollView.contentOffset;
            CGRect savedFrame = scrollView.frame;
            scrollView.contentOffset = CGPointZero;
            scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
            [self.layer renderInContext:UIGraphicsGetCurrentContext()];
            image = UIGraphicsGetImageFromCurrentImageContext();
            scrollView.contentOffset = savedContentOffset;
            scrollView.frame = savedFrame;
        }
        UIGraphicsEndImageContext();
        return image;
    }
    else
    {
        // 不是的话，当做普通的View处理
        return [self ah_capture];
    }
}

@end
