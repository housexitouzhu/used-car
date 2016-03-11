//
//  CustomStatusBar.h
//  CustomStatusBar
//
//  Created by Jason Lee on 12-3-12.
//  Copyright (c) 2012年 Taobao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^StatueBarBlock)(void);

@interface CustomStatusBar : UIWindow

@property (nonatomic, strong) UIButton *btnStatusMsg;
@property (nonatomic, copy) StatueBarBlock block;
@property (nonatomic) NSInteger animationTime;

- (void)showStatusMessage:(NSString *)message onClickStatueBar:(StatueBarBlock)block;
- (void)hideStatusMessage;
/** 对齐方式 */
- (void)setTextAlignment:(NSTextAlignment)textAlignment;

@end

