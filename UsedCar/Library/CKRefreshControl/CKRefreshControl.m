// CKRefreshControl.m
// 
// Copyright (c) 2012 Instructure, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CKRefreshControl.h"
#import "CKRefreshArrowView.h"
#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#error Add -fobjc-arc to the compile flags for CKRefreshControl.m
#endif

typedef enum {
    CKRefreshControlStateHidden,
    CKRefreshControlStatePulling,
    CKRefreshControlStateReady,
    CKRefreshControlStateRefreshing
} CKRefreshControlState;

@interface CKRefreshControl ()
@property (nonatomic) CKRefreshControlState refreshControlState;
@end

@implementation CKRefreshControl {
    UILabel *textLabel;
    UIActivityIndicatorView *spinner;
    CKRefreshArrowView *arrow;
    UIColor *defaultTintColor;
    CGFloat decelerationStartOffset;
}

- (id)initInScrollView:(UIScrollView *)scrollView
{
    _originalTopContentInset = scrollView.contentInset.top;
    self = [super initWithFrame:CGRectMake(0, -(60 + _originalTopContentInset), scrollView.frame.size.width, 60)];
    
    if (self) {
        [self populateSubviews];
        [self setRefreshControlState:CKRefreshControlStateHidden];
        defaultTintColor = [UIColor colorWithWhite:0.5 alpha:1];
        self.backgroundColor = [UIColor clearColor];
        
        [scrollView addSubview:self];
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld context:contentOffsetObservingKey];

    }
    return self;
}

- (void)setOriginalTopContentInset:(CGFloat)originalTopContentInset
{
    _originalTopContentInset = originalTopContentInset;
    self.frame = CGRectMake(0, -(60 + _originalTopContentInset), self.frame.size.width, 60);
}

static void *contentOffsetObservingKey = &contentOffsetObservingKey;

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self.superview removeObserver:self forKeyPath:@"contentOffset" context:contentOffsetObservingKey];
}

- (void)didMoveToSuperview {
    UIView *superview = self.superview;
    
    // Reposition ourself in the scrollview
    if ([superview isKindOfClass:[UIScrollView class]]) {
        [self repositionAboveContent];
    }
}

- (void)populateSubviews {
    CGRect frame = CGRectInset(self.bounds, 12, 12);
    arrow = [[CKRefreshArrowView alloc] initWithFrame:frame];
    arrow.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:arrow];
    
    textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    [self addSubview:textLabel];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = (CGPoint){
        .x = CGRectGetMidX(self.bounds),
        .y = CGRectGetMidY(self.bounds)
    };
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                UIViewAutoresizingFlexibleRightMargin |
                                UIViewAutoresizingFlexibleTopMargin |
                                UIViewAutoresizingFlexibleBottomMargin);
    [self addSubview:spinner];
}

- (void)setTintColor: (UIColor *) tintColor
{
    if (!tintColor)
        tintColor = defaultTintColor;

    textLabel.textColor = tintColor;
    arrow.tintColor = tintColor;
    spinner.color = tintColor;
}

- (UIColor *)tintColor {
    return arrow.tintColor;
}

//- (void)setTitle:(NSString *)title {
//    _title = title;
//    textLabel.text = title;
//}

- (void)beginRefreshing {
    _refreshing = YES;
    [self setRefreshControlState:CKRefreshControlStateRefreshing];
}

- (void)endRefreshing {
    _refreshing = NO;
    [self setRefreshControlState:CKRefreshControlStateHidden];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSString *text = _titlePulling;
    CGPoint center =(CGPoint){
        .x = CGRectGetMidX(self.bounds),
        .y = CGRectGetMidY(self.bounds)
    };
    
    if (text.length > 0) {
        CGPoint newArrowCenter = (CGPoint){.x = center.x, .y = center.y - 10};
        arrow.center = spinner.center = newArrowCenter;
        textLabel.frame = (CGRect){
            .origin.x = 0,
            .origin.y = CGRectGetMaxY(self.bounds) - 25,
            .size.width = CGRectGetWidth(self.bounds),
            .size.height = 25
        };
    }
    else {
        arrow.center = spinner.center = center;
        textLabel.frame = CGRectZero;
    }
}

- (void)setRefreshControlState:(CKRefreshControlState)refreshControlState {
    
    _refreshControlState = refreshControlState;
    switch (refreshControlState) {
        case CKRefreshControlStateHidden:
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.alpha = 0.0;
            }];
            break;
        }
            
        case CKRefreshControlStatePulling:
            textLabel.text = _titlePulling;
            self.alpha = 1.0;
            arrow.alpha = 1.0;
            textLabel.alpha = 1.0;
            break;
        case CKRefreshControlStateReady:
            textLabel.text = _titleReady;
            self.alpha = 1.0;
            arrow.alpha = 1.0;
            textLabel.alpha = 1.0;
            break;
            
        case CKRefreshControlStateRefreshing:
            textLabel.text = _titleRefreshing;
            self.alpha = 1.0;
            [UIView animateWithDuration: 0.2
                             animations:^{
                                 arrow.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 [spinner startAnimating];
                             }];
            break;
    };
    
    
    
    UIEdgeInsets contentInset = UIEdgeInsetsMake(_originalTopContentInset, 0, 0, 0);
    if (refreshControlState == CKRefreshControlStateRefreshing) {
        contentInset = UIEdgeInsetsMake(self.frame.size.height + _originalTopContentInset, 0, 0, 0);
    }
    else {
        [spinner stopAnimating];
    }
    
    
    UIScrollView *scrollView = nil;
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        scrollView = (UIScrollView *)self.superview;
    }
    
    if(!UIEdgeInsetsEqualToEdgeInsets(scrollView.contentInset, contentInset)) {
        [UIView animateWithDuration:0.2 animations:^{
            scrollView.contentInset = contentInset;
        }];
    }
    
}

- (void)repositionAboveContent {
    CGRect scrollBounds = self.superview.bounds;
    CGFloat height = self.bounds.size.height;
    CGRect newFrame = (CGRect){
        .origin.x = 0,
        .origin.y = -height,
        .size.width = scrollBounds.size.width,
        .size.height = height
    };
    self.frame = newFrame;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context != contentOffsetObservingKey) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if ([self.superview isKindOfClass:[UIScrollView class]] == NO) {
        return;
    }
    
    UIScrollView *scrollview = (UIScrollView *)self.superview;
    CGFloat pullHeight = -scrollview.contentOffset.y - _originalTopContentInset;
    CGFloat triggerHeight = self.bounds.size.height;
    CGFloat previousPullHeight = -[change[NSKeyValueChangeOldKey] CGPointValue].y - _originalTopContentInset; // Fix bug
    
    // Update the progress arrow
    CGFloat progress = pullHeight / triggerHeight;
    CGFloat deadZone = 0.5;// 0.3
    if (progress > deadZone && self.enabled == YES) {
        CGFloat arrowProgress = ((progress - deadZone) / (1 - deadZone));
        arrow.progress = arrowProgress;
    }
    else {
        arrow.progress = 0.0;
    }
    
    
    // Track when deceleration starts
    if (scrollview.isDecelerating == NO) {
        decelerationStartOffset = 0;
    }
    else if (scrollview.isDecelerating && decelerationStartOffset == 0) {
        decelerationStartOffset = scrollview.contentOffset.y;
    }
    
    // Transition to the next state
    if (self.refreshControlState == CKRefreshControlStateRefreshing) {
//        // Fix bug
//        // Adjust inset to make sure potential header view is shown correctly if user pulls down scroll view while in refreshing state
//        CGFloat offset = MAX(scrollview.contentOffset.y * -1 + self.bounds.size.height, 0);
//		offset = MIN(offset, self.bounds.size.height + originalTopContentInset);
		scrollview.contentInset = UIEdgeInsetsMake(self.bounds.size.height + _originalTopContentInset, 0.0f, 0.0f, 0.0f);
    }
    else if (decelerationStartOffset > 0) {
        // Deceleration started before reaching the header 'rubber band' area; hide the refresh control
        self.refreshControlState = CKRefreshControlStateHidden;
    }
    else if (pullHeight >= triggerHeight || (pullHeight > 0 && previousPullHeight >= triggerHeight)) {
        if (self.enabled) {
            if (scrollview.isDragging) {
                // Just waiting for them to let go, then we'll refresh
                self.refreshControlState = CKRefreshControlStateReady;
            }
            else if (([self allControlEvents] & UIControlEventValueChanged) == 0) {
                AMLog(@"No action configured for UIControlEventValueChanged event, not transitioning to refreshing state");
            }
            else {
                // They let go! Refresh!
                self.refreshControlState = CKRefreshControlStateRefreshing;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }

    }
    else if (scrollview.decelerating == NO && pullHeight > 0) {
        if (self.enabled)
            self.refreshControlState = CKRefreshControlStatePulling;
    }
    else {
        self.refreshControlState = CKRefreshControlStateHidden;
    }
    
    if (pullHeight > self.bounds.size.height) {
//        // Fix bug
//        // Center in the rubberbanding area
//        CGPoint rubberBandCenter = (CGPoint) {
//            .x = CGRectGetMidX(self.superview.bounds),
//            .y = scrollview.contentOffset.y / 2.0
//        };
//        self.center = rubberBandCenter;
    }
    else {
        [self repositionAboveContent];
    }
}

@end
