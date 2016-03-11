//
//  SHLDrawScrollView.m
//
//  Created by Sun Honglin on 14-11-5.
//  Copyright (c) 2014年 Pavan Itagi. All rights reserved.
//

#import "SHLDrawScrollView.h"
#import "SHLDrawCanvas.h"
#import "SHLDrawView.h"

@implementation SHLDrawScrollView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
//        doubleTap.numberOfTapsRequired = 2;
//        doubleTap.numberOfTouchesRequired = 1;
//        [self addGestureRecognizer:doubleTap];
    }
    
    return self;
}

//- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    UIView* result = [super hitTest:point withEvent:event];
//    
//    if ([result.superview isKindOfClass:[EditScrollView class]])
//    {
//        self.scrollEnabled = NO;
//    }
//    else
//    {
//        self.scrollEnabled = YES;
//    }
//    return result;
//}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
//    AMLog(@"touchesShouldBegin touchs:%@ \nevent%@ \nview%@ \n--------------", touches, event, view);
    if (self.isDrawing && [view isKindOfClass:[SHLDrawCanvas class]]) {
        return YES;
    }
    else{
        return NO;
    }
}


//- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
//    // Get the location within the image view where we tapped
//    CGPoint pointInView = [recognizer locationInView:self.subviews.firstObject];
//    
//    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
//    CGFloat newZoomScale = self.zoomScale * 1.5f;
//    newZoomScale = MIN(newZoomScale, self.maximumZoomScale);
//    
//    // Figure out the rect we want to zoom to, then zoom to it
//    CGSize scrollViewSize = self.bounds.size;
//    
//    CGFloat w = scrollViewSize.width / newZoomScale;
//    CGFloat h = scrollViewSize.height / newZoomScale;
//    CGFloat x = pointInView.x - (w / 2.0f);
//    CGFloat y = pointInView.y - (h / 2.0f);
//    
//    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
//    
//    [self zoomToRect:rectToZoomTo animated:YES];
//}

@end
