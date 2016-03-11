//
//  SHLUnderLineButton.m
//  UsedCar
//
//  Created by Sun Honglin on 14-9-16.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "SHLUnderLineButton.h"

@implementation SHLUnderLineButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
//    // Get the Render Context
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    // Measure the font size, so the line fits the text.
//    // Could be that "titleLabel" is something else in other classes like UILable, dont know.
//    // So make sure you fix it here if you are enhancing UILabel or something else..
//    CGSize fontSize =[self.titleLabel.text sizeWithFont:self.titleLabel.font
//                                               forWidth:self.bounds.size.width
//                                          lineBreakMode:NSLineBreakByTruncatingTail];
//    // Get the fonts color.
//    const float * colors = CGColorGetComponents(self.titleLabel.textColor.CGColor);
//    // Sets the color to draw the line
//    CGContextSetRGBStrokeColor(ctx, colors[0], colors[1], colors[2], 1.0f); // Format : RGBA
//    
//    // Line Width : make thinner or bigger if you want
//    CGContextSetLineWidth(ctx, 0.5f);
//    
//    // Calculate the starting point (left) and target (right)
//    float fontLeft = self.titleLabel.center.x - fontSize.width/2.0;
//    float fontRight = self.titleLabel.center.x + fontSize.width/2.0;
//    
//    // Add Move Command to point the draw cursor to the starting point
//    CGContextMoveToPoint(ctx, fontLeft, self.bounds.size.height - 1);
//    
//    // Add Command to draw a Line
//    CGContextAddLineToPoint(ctx, fontRight, self.bounds.size.height - 1);
//    
//    // Actually draw the line.
//    CGContextStrokePath(ctx);
//
    
    
    CGRect textRect = self.titleLabel.frame;
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender+1.5;
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGFloat shadowHeight = self.titleLabel.shadowOffset.height;
    descender += shadowHeight;
    // set to same colour as text
    CGContextSetLineWidth(contextRef, 0.5); //设置横线为屏幕上1个像素
    CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender);
    CGContextClosePath(contextRef);
    CGContextDrawPath(contextRef, kCGPathStroke);
    
    // should be nothing, but who knows...
    [super drawRect:rect];
}



@end

/**
 @interface UIUnderlinedButton : UIButton {
 
 }
 
 + (UIUnderlinedButton*) underlinedButton;
 @end
 
 UIUnderlinedButton.m
 
 @implementation UIUnderlinedButton
 
 + (UIUnderlinedButton*) underlinedButton {
 
 UIUnderlinedButton* button = [[UIUnderlinedButton alloc] init];
 return [button autorelease];
 }
 - (void) drawRect:(CGRect)rect {
 CGRect textRect = self.titleLabel.frame;
 // need to put the line at top of descenders (negative value)
 CGFloat descender = self.titleLabel.font.descender;
 CGContextRef contextRef = UIGraphicsGetCurrentContext();
 // set to same colour as text
 CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
 CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
 CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender);
 CGContextClosePath(contextRef);
 CGContextDrawPath(contextRef, kCGPathStroke);
 }
 
 上述代码没有考虑显示文本有阴影的情况，下面的的代码做这个处理：
 
 CGFloat descender = self.titleLabel.font.descender;
 CGContextRef contextRef = UIGraphicsGetCurrentContext();
 CGFloat shadowHeight = self.titleLabel.shadowOffset.height;
 descender += shadowHeight;
 */
