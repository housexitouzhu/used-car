//
//  AMToastView.h
//  UsedCar
//
//  Created by Alan on 13-11-11.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#if NS_BLOCKS_AVAILABLE
typedef void (^ToastCancel)(void);
#endif


typedef enum {
    AMToastDurationNormal = 2,
    AMToastDurationShort = 1,
    AMToastDurationLong = 5,
} AMToastDuration;

@interface AMToastView : UIView {
    UIWindow *_window;
    
    UIView *_vMain;
    UIView *_vPanel;
    UIImageView *_ivImage;
	UILabel *_labTitle;
    UIImageView *_ivLoading;
    UIImageView *_ivClose;
}


@property (nonatomic, weak) UIView *rootView;
@property (nonatomic, readonly) BOOL isShow;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) CGFloat fromScale;

/** 通用提示框 */
+ (AMToastView *)toastView;
+ (AMToastView *)toastView:(BOOL)isIntercept;

- (id)initWithWindow;
- (id)initWithView:(UIView *)view;
- (void)setTouchIntercept:(BOOL)isIntercept;
- (void)showLoading:(NSString *)title cancel:(ToastCancel)blockCancel;
- (void)showMessage:(NSString *)title icon:(UIImage *)icon duration:(AMToastDuration)duration;
- (void)hide;

@end
