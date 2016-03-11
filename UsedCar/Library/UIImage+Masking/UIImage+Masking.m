//
//  UIImage+Masking.m
//  NYXImagesKit
//
//  Created by @Nyx0uf on 02/06/11.
//  Copyright 2012 Nyx0uf. All rights reserved.
//  www.cocoaintheshell.com
//


#import "UIImage+Masking.h"


@implementation UIImage (NYX_Masking)

- (UIImage*)maskWithImage:(UIImage*)maskImage
{
	/// Create a bitmap context with valid alpha
	const size_t originalWidth = (size_t)(self.size.width * self.scale);
	const size_t originalHeight = (size_t)(self.size.height * self.scale);
	CGContextRef bmContext = NYXCreateARGBBitmapContext(originalWidth, originalHeight, 0, YES);
	if (!bmContext)
		return nil;

	/// Image quality
	CGContextSetShouldAntialias(bmContext, true);
	CGContextSetAllowsAntialiasing(bmContext, true);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);

	/// Image mask
	CGImageRef cgMaskImage = maskImage.CGImage; 
	CGImageRef mask = CGImageMaskCreate((size_t)maskImage.size.width, (size_t)maskImage.size.height, CGImageGetBitsPerComponent(cgMaskImage), CGImageGetBitsPerPixel(cgMaskImage), CGImageGetBytesPerRow(cgMaskImage), CGImageGetDataProvider(cgMaskImage), NULL, false);

	/// Draw the original image in the bitmap context
	const CGRect r = (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = originalWidth, .size.height = originalHeight};
	CGContextClipToMask(bmContext, r, cgMaskImage);
	CGContextDrawImage(bmContext, r, self.CGImage);

	/// Get the CGImage object
	CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(bmContext);
	/// Apply the mask
	CGImageRef maskedImageRef = CGImageCreateWithMask(imageRefWithAlpha, mask);

	UIImage* result = [UIImage imageWithCGImage:maskedImageRef scale:self.scale orientation:self.imageOrientation];

	/// Cleanup
	CGImageRelease(maskedImageRef);
	CGImageRelease(imageRefWithAlpha);
	CGContextRelease(bmContext);
	CGImageRelease(mask);

    return result;
}

CGContextRef NYXCreateARGBBitmapContext(const size_t width, const size_t height, const size_t bytesPerRow, BOOL withAlpha)
{
    /// Use the generic RGB color space
    /// We avoid the NULL check because CGColorSpaceRelease() NULL check the value anyway, and worst case scenario = fail to create context
    /// Create the bitmap context, we want pre-multiplied ARGB, 8-bits per component
    CGImageAlphaInfo alphaInfo = (withAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst);
    CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8/*Bits per component*/, bytesPerRow, NYXGetRGBColorSpace(), kCGBitmapByteOrderDefault | alphaInfo);
    
    return bmContext;
}

static CGColorSpaceRef __rgbColorSpace = NULL;

CGColorSpaceRef NYXGetRGBColorSpace(void)
{
    if (!__rgbColorSpace)
    {
        __rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    }
    return __rgbColorSpace;
}

@end
