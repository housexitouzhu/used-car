/*!
 @header    ViewFrameGeometry.h
 @abstract  扩展方法类 （向UIview添加 宽高坐标的简易方法）
 @author    王俊
 @version   2.0.0 2012/07/02 Creation (此文档的版本信息)
 */
#import <UIKit/UIKit.h>

CGPoint CGRectGetCenter(CGRect rect);
CGRect  CGRectMoveToCenter(CGRect rect, CGPoint center);

@interface UIView (ViewFrameGeometry)
@property CGPoint origin;
@property CGSize size;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property (readonly) CGPoint topCenter;
@property (readonly) CGPoint bottomCenter;
@property (readonly) CGPoint leftCenter;
@property (readonly) CGPoint rightCenter;

@property CGFloat height;
@property CGFloat width;

@property CGFloat top;
@property CGFloat left;

@property CGFloat bottom;
@property CGFloat right;

- (void) moveBy: (CGPoint) delta;
- (void) scaleBy: (CGFloat) scaleFactor;
- (void) fitInSize: (CGSize) aSize;

@end