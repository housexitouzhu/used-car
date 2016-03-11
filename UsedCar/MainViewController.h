//
//  MainViewController.h
//  UsedCar
//
//  Created by Alan on 13-10-25.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UMSocial.h"
#import "UMSocialControllerService.h"

#import <StoreKit/StoreKit.h>

@class UCFilterModel;
@class APIHelper;
@class UCView;

typedef enum {
    RemoveOptionNone = 0,
    RemoveOptionPrevious = 1,
    RemoveOptionAll = 2,
} RemoveOption;

typedef enum {
    AnimateOptionMoveNone = 0,
    AnimateOptionMoveLeft,
    AnimateOptionMoveRight,
    AnimateOptionMoveDown,
    AnimateOptionMoveUp,
    AnimateOptionMoveAuto,
} AnimateOption;

@interface MainViewController : UINavigationController <UMSocialUIDelegate, UIGestureRecognizerDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, readonly) UIView *vMain;
@property (nonatomic, readonly) UCView *vTop;

@property (nonatomic, weak) id welcomeDelegate;
//@property (nonatomic, strong) UCFilterModel *mFilter;

+ (MainViewController *)sharedVCMain;

- (void)openView:(UCView *)view animateOption:(AnimateOption)animateOption removeOption:(RemoveOption)removeOption;
- (void)closeView:(UCView *)view animateOption:(AnimateOption)animateOption;
- (void)replaceView:(UCView *)view1 withView:(UCView *)view2 superview:(UIView *)superview;

/** 获取view下层布局 */
- (UIView *)aboveSubview:(UIView *)view;
/** 获取view上层布局 */
- (UIView *)belowSubview:(UIView *)view;

/** 友盟分享 */
- (void)showShareList:(NSString *)text imageUrl:(NSString *)imageUrl url:(NSString *)url wxsessionContent:(NSDictionary *)wxsessionContent;

/** 注册推送设备 */
//- (void)registDeviceAndRegistPush:(BOOL)isNeedRegistPush;

/** 注册设备 **/ //独立出来
-(void)registDevice;

/** 注册 token 然后注册 push **/
-(void)registerDevicePushWithToken;

/** 注册 PUSH **/
-(void)registPush;

/** 显示商店 */
- (void)showAppStore:(NSString *)appId type:(NSInteger)type;

@end


