//
//  UIImage+Util.h
//  UsedCar
//
//  Created by Alan on 13-11-10.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Util)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color triangleSize:(CGSize)size;

//+ (UIImage *)imageWithImage:(UIImage*)image cornerRadius:(NSInteger)radius;

+ (UIImage *)imageAutoNamed:(NSString *)imageName;
+ (UIImage *)mergerImage1:(UIImage *)image1 image2:(UIImage *)image2 toSize:(CGSize)toSize;

- (UIImage *)toGrayImage;

/* size.width */
- (CGFloat)width;
/* size.height */
- (CGFloat)height;

- (UIImage *)imageTo4b3;
- (UIImage *)imageTo4b3AtSize:(CGSize)size;
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageToScale:(float)scale;
- (UIImage *)imageToSize:(CGSize)size;

- (UIImage *)addImage:(UIImage *)image point:(CGPoint)point;

- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end
