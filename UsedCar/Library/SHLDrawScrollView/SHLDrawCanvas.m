//
//  SHLDrawCanvas.m
//
//  Created by Sun Honglin on 14-11-5.
//  Copyright (c) 2014年 Pavan Itagi. All rights reserved.
//

#import "SHLDrawCanvas.h"

@interface SHLDrawCanvas ()
{
    CGPoint previousPoint;
    CGPoint currentPoint;
}
@end

@implementation SHLDrawCanvas


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

-(void)awakeFromNib{
    [self initView];
}

-(void)initView{
    self.backgroundColor = [UIColor clearColor];
    
    currentPoint = CGPointMake(0, 0);
    previousPoint = currentPoint;
    
    self.drawMode = SHLDrawModeNone;
    
    self.selectedColor = [UIColor blackColor];
    
}

#pragma mark - draw

- (void)drawRect:(CGRect)rect
{
    [self.drawImage drawInRect:self.bounds];
}

- (void)eraseLine
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.drawImage drawInRect:self.bounds];
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 8.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), previousPoint.x, previousPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.drawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    previousPoint = currentPoint;
    
    [self setNeedsDisplay];
}


- (void)drawLine
{
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.drawImage drawInRect:self.bounds];
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.selectedColor.CGColor);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 8.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), previousPoint.x, previousPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.drawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    previousPoint = currentPoint;
    
    if (!self.imageDrawed) {
        self.imageDrawed = YES;
    }
    if ([self.delegate respondsToSelector:@selector(imageDrawedOnCanvas:)]) {
        [self.delegate imageDrawedOnCanvas:self];
    }
    
    [self setNeedsDisplay];
}

- (void)handleTouches
{
    if (self.drawMode == SHLDrawModeNone) {
        // do nothing
    }
    else if (self.drawMode == SHLDrawModePaint) {
        [self drawLine];
    }
    else
    {
        [self eraseLine];
    }
}

- (void)setDrawImage:(UIImage *)drawImage{
    _drawImage = drawImage;
    
    if (drawImage == nil) {
        self.imageDrawed = NO;
        [self setNeedsDisplay];
    }
}

- (void)removeImageDrawed{
    [self setDrawImage:nil];
}

#pragma mark - Touches methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    previousPoint = p;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentPoint = [[touches anyObject] locationInView:self];
    
    [self handleTouches];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentPoint = [[touches anyObject] locationInView:self];
    
    [self handleTouches];
}


@end
