// CKRefreshTimeControl.h
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

#import <UIKit/UIKit.h>

@interface CKRefreshTimeControl : UIControl

- (id)initInScrollView:(UIScrollView *)scrollView;

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

// This 'Tint Color' will set the text color and spinner color
@property (nonatomic, retain) UIColor *tintColor UI_APPEARANCE_SELECTOR; // Default = 0.5 gray, 1.0 alpha
//@property (nonatomic, retain) NSString *title UI_APPEARANCE_SELECTOR;123
@property (nonatomic, retain) NSString *titlePulling;
@property (nonatomic, retain) NSString *titleReady;
@property (nonatomic, retain) NSString *titleRefreshing;

@property (nonatomic) CGFloat originalTopContentInset;

// May be used to indicate to the refreshControl that an external event has initiated the refresh action
- (void)beginRefreshing;
// Must be explicitly called when the refreshing has completed
- (void)endRefreshing;

@end