//
//  UIImage+Util.m
//  UsedCar
//
//  Created by Alan on 13-11-10.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UIImage+Util.h"
#import "objc/runtime.h"

@implementation UIImage (Util)

//CGFloat DEGREES_TO_RADIANS(CGFloat degrees) {return degrees * M_PI / 180;};
//CGFloat RADIANS_TO_DERREES(CGFloat radians) {return radians * 180/M_PI;};

- (CGFloat)width {
	return self.size.width;
}

- (CGFloat)height {
	return self.size.height;
}

//+ (void)load {
//    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && ([UIScreen mainScreen].bounds.size.height > 480.0f)) {
////        //Exchange XIB loading implementation
////        Method m1 = class_getInstanceMethod(NSClassFromString(@"UIImageNibPlaceholder"), @selector(initWithCoder:));
////        Method m2 = class_getInstanceMethod(self, @selector(initWithCoderH568:));
////        method_exchangeImplementations(m1, m2);
//        
//        //Exchange imageNamed: implementation
//        method_exchangeImplementations(class_getClassMethod(self, @selector(imageNamed:)), class_getClassMethod(self, @selector(imageAutoNamed:)));
//    }
//}

+ (UIImage *)imageAutoNamed:(NSString *)imageName {
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && ([UIScreen mainScreen].bounds.size.height > 480.0f))
        return [UIImage imageNamed:[self autoRenameImageName:imageName]];
    else
        return [UIImage imageNamed:imageName];
}

+ (NSString *)autoRenameImageName:(NSString *)imageName {
    
    NSMutableString *imageNameMutable = [imageName mutableCopy];
    
    BOOL isJPG = NO;
    
    //Delete png extension
    NSRange extension = [imageName rangeOfString:@".png" options:NSBackwardsSearch | NSAnchoredSearch];
    if (extension.location != NSNotFound) {
        [imageNameMutable deleteCharactersInRange:extension];
    } else {
        //Delete jpg extension
        extension = [imageName rangeOfString:@".jpg" options:NSBackwardsSearch | NSAnchoredSearch];
        if (extension.location != NSNotFound) {
            [imageNameMutable deleteCharactersInRange:extension];
            isJPG = YES;
        }
    }
    
    //Look for @2x to introduce -568h string
    NSRange retinaAtSymbol = [imageName rangeOfString:@"@2x"];
    if (retinaAtSymbol.location != NSNotFound) {
        [imageNameMutable insertString:@"-568h" atIndex:retinaAtSymbol.location];
    } else {
        [imageNameMutable appendString:@"-568h@2x"];
    }
    
    //Check if the image exists and load the new 568 if so or the original name if not
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageNameMutable ofType:isJPG ? @"jpg" : @"png"];
    if (imagePath) {
        if (isJPG) {
            [imageNameMutable appendString:@".jpg"];
            return imageNameMutable;
        } else {
            //Remove the @2x to load with the correct scale 2.0
            [imageNameMutable replaceOccurrencesOfString:@"@2x" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, [imageNameMutable length])];
            return imageNameMutable;
        }
    } else {
        return imageName;
    }
}

//- (id)initWithCoderH568:(NSCoder *)aDecoder {
//	NSString *resourceName = [aDecoder decodeObjectForKey:@"UIResourceName"];
//    NSString *resourceH568 = [UIImage renameImageNameForH568:resourceName];
//    
//    //If no 568h version, load as default
//    if ([resourceName isEqualToString:resourceH568]) {
//        return [self initWithCoderH568:aDecoder];
//    }
//    //If 568h exists, load with [UIImage imageNamed:]
//    else {
//        return [UIImage imageNamedH568:resourceH568];
//    }
//}

//- (UIImage *)scaleToSize:(CGSize)size{
//    // 创建一个bitmap的context
//    // 并把它设置成为当前正在使用的context
//    //UIGraphicsBeginImageContext(size);
//    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
//    // 绘制改变大小的图片
//    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    // 从当前context中创建一个改变大小后的图片
//    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//    // 使当前的context出堆栈
//    UIGraphicsEndImageContext();
//    // 返回新的改变大小后的图片
//    return scaledImage;
//}

- (UIImage *)imageTo4b3
{
    // 倍数
    CGFloat widthMultiple = self.size.width / 4.0;
    CGFloat heightMultiple = self.size.height / 3.0;
    
    CGRect rect = CGRectNull;
    // 倍数大的裁剪
    if (widthMultiple > heightMultiple) {
        CGFloat newWidth = heightMultiple * 4.0;
        rect = CGRectMake((self.size.width - newWidth) / 2, 0, newWidth, self.size.height);
    } else if (heightMultiple > widthMultiple) {
        CGFloat newHeight = widthMultiple * 3.0;
        rect = CGRectMake(0, (self.size.height - newHeight) / 2, self.size.width, newHeight);
    }
    
    if (CGRectIsNull(rect)) {
        return self;
    } else {
        UIImage *image4b3 = [self imageAtRect:rect];
        return image4b3;
    }
}

- (UIImage *)imageTo4b3AtSize:(CGSize)size
{
    if (size.height / size.width != 3.0 / 4.0)
        return nil;
    
    // 倍数
    CGFloat widthMultiple = self.size.width / 4.0;
    CGFloat heightMultiple = self.size.height / 3.0;
    
    // 宽高先缩放到4:3
    CGFloat scale = 0;
    // 缩放已倍数小的为准
    if (widthMultiple < heightMultiple) {
        // 图片比目标大小大时才缩放
        if (self.size.width > size.width)
            scale = size.width / self.size.width;
    }
    // 高的倍数小 or 高宽倍数相等
    else {
        // 图片比目标大小大时才缩放
        if (self.size.height > size.height)
            scale = size.height / self.size.height;
    }
    
    UIImage *img = self;
    
    // 需要缩放
    if (scale != 0) {
        img = [self imageToScale:scale];
    }
    
    // 需要裁剪
    if (widthMultiple != heightMultiple) {
        img = [img imageTo4b3];
    }
    
    return img;
}

// 图片裁剪
- (UIImage *)imageAtRect:(CGRect)rect
{
    rect = CGRectMake(rect.origin.x * self.scale, rect.origin.y * self.scale, rect.size.width * self.scale, rect.size.height * self.scale);
    
    CGImageRef imgref = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *img = [UIImage imageWithCGImage:imgref];
    CGImageRelease(imgref);
    return img;
}

//// 图片裁剪
//- (UIImage *)imageAtRect:(CGRect)rect
//{
//    UIImage *imageRotated = [self imageToRotated];
//
//    CGImageRef croppedImage = CGImageCreateWithImageInRect(imageRotated.CGImage, rect);
//    UIImage *image = [UIImage imageWithCGImage:croppedImage scale:1.0f orientation:imageRotated.imageOrientation];
//    CGImageRelease(croppedImage);
//
//    return image;
//}

//// 图像旋转及处理
//- (UIImage *)imageToRotated
//{
//    CGSize size = self.size;
//    UIGraphicsBeginImageContext(size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
//    //CGContextConcatCTM(context, transform);
//    CGContextTranslateCTM(context, size.width / -2, size.height / -2);
//    [self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
//    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    return rotatedImage;
//}


- (UIImage *)imageToScale:(float)scale
{
    CGSize size = CGSizeMake(self.size.width * scale, self.size.height * scale);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)imageToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *sizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return sizeImage;
}


//- (UIImage *)croppedImage:(CGRect)cropRect
//{
//    UIImage *rotatedImage = [self rotatedImageWithImage:self];
//
//    CGImageRef croppedImage = CGImageCreateWithImageInRect(self.CGImage, cropRect);
//    UIImage *image = [UIImage imageWithCGImage:croppedImage scale:1.0f orientation:self.imageOrientation];
//    CGImageRelease(croppedImage);
//
//    return image;
//}

////等比例缩放
//- (UIImage *)scaleToSize:(CGSize)size
//{
//    CGFloat width = CGImageGetWidth(self.CGImage);
//    CGFloat height = CGImageGetHeight(self.CGImage);
//
//    float verticalRadio = size.height * 1.0 / height;
//    float horizontalRadio = size.width * 1.0 / width;
//
//    float radio = 1;
//    if(verticalRadio > 1 && horizontalRadio > 1) {
//        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
//    }
//    else {
//        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
//    }
//
//    width = width * radio;
//    height = height * radio;
//
//    int xPos = (size.width - width)/2;
//    int yPos = (size.height-height)/2;
//
//    // 创建一个bitmap的context
//    // 并把它设置成为当前正在使用的context
//    UIGraphicsBeginImageContext(size);
//
//    // 绘制改变大小的图片
//    [self drawInRect:CGRectMake(xPos, yPos, width, height)];
//
//    // 从当前context中创建一个改变大小后的图片
//    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//
//    // 使当前的context出堆栈
//    UIGraphicsEndImageContext();
//
//    // 返回新的改变大小后的图片
//    return scaledImage;
//}


- (UIImage *)addImage:(UIImage *)image point:(CGPoint)point{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    // Draw image1
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    // Draw image2
    [image drawInRect:CGRectMake(point.x, point.y, image.size.width, image.size.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    //UIGraphicsBeginImageContext(rect.size);
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color triangleSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
//    CGPoint sPoints[3];//坐标点
//    sPoints[0] =CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));//坐标1
//    sPoints[1] =CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));//坐标2
//    sPoints[2] =CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));//坐标3
//    CGContextAddLines(context, sPoints, 3);//添加线
//    CGContextClosePath(context);//封起来
//    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMidX(rect), CGRectGetMinY(rect)); // top left
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect)); // mid right
    CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect)); // bottom left
    CGContextClosePath(context);
    
    
//    CGContextSetRGBFillColor(context, 1, 1, 0, 1);
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//+ (UIImage *)imageWithImage:(UIImage*)image cornerRadius:(NSInteger)radius {
//    int w = image.size.width - radius;
//    int h = image.size.height - radius;
//    
//    UIImage *img = image;
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
//    CGRect rect = CGRectMake(0, 0, w, h);
//    
//    CGContextBeginPath(context);
//    addRoundedRectToPath(context, rect, radius, radius);
//    CGContextClosePath(context);
//    CGContextClip(context);
//    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
//    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//    UIImage * imageReturn  = [UIImage imageWithCGImage:imageMasked];
//    CGImageRelease(imageMasked);
//    
//    return imageReturn;
//}

//static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight){
//    float fw,fh;
//    if (ovalWidth == 0 || ovalHeight == 0) {
//        CGContextAddRect(context, rect);
//        return;
//    }
//    
//    CGContextSaveGState(context);
//    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
//    CGContextScaleCTM(context, ovalWidth, ovalHeight);
//    fw = CGRectGetWidth(rect) / ovalWidth;
//    fh = CGRectGetHeight(rect) / ovalHeight;
//    
//    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
//    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
//    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
//    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
//    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
//    
//    CGContextClosePath(context);
//    CGContextRestoreGState(context);
//}


+ (UIImage *)mergerImage1:(UIImage *)image1 image2:(UIImage *)image2 toSize:(CGSize)toSize{
    UIGraphicsBeginImageContext(toSize);
    
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    // Draw image2
    [image2 drawInRect:CGRectMake(image1.size.width, 0, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}


//- (UIImage *) toGrayImage
//{
//    CGSize size = self.size;
//    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
//    // Create a mono/gray color space
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
//    CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaNone);
//    CGColorSpaceRelease(colorSpace);
//    // Draw the image into the grayscale context
//    CGContextDrawImage(context, rect, [self CGImage]);
//    CGImageRef grayscale = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    // Recover the image
//    UIImage *img = [UIImage imageWithCGImage:grayscale];
//    CFRelease(grayscale);
//    return img;
//}

//- (UIImage *) toGrayImage
//{
//    int width = self.size.width;
//    int height = self.size.height;
//
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
//    CGContextRef context = CGBitmapContextCreate (nil,width,height,8,0,colorSpace,kCGImageAlphaFirst);
//    CGColorSpaceRelease(colorSpace);
//
//    if (context == NULL) {
//        return nil;
//    }
//
//    CGContextDrawImage(context,CGRectMake(0, 0, width, height), self.CGImage);
//    CGImageRef grayImageRef = CGBitmapContextCreateImage(context);
//    UIImage *grayImage = [UIImage imageWithCGImage:grayImageRef];
//    CGContextRelease(context);
//    CGImageRelease(grayImageRef);
//
//    return grayImage;
//}

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

- (UIImage *)toGrayImage {
    CGSize size = [self size];
    int width = size.width;
    int height = size.height;
	
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
	
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
	
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
	
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
			
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
	
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
	
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
	
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
	
    // we're done with image now too
    CGImageRelease(image);
	
    return resultUIImage;
}

- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    return [self imageRotatedByDegrees:RADIANS_TO_DERREES(radians)];
}
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DEGREES_TO_RADIANS(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end
