//
//  AMBlurView.h
//  UsedCar
//
//  Created by Alan on 13-8-16.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMBlurView : UIView

/** 是否启用模糊效果 */
@property (nonatomic) BOOL isEnableBlur;
/** 模糊颜色 */
@property (nonatomic, strong) UIColor *blurTintColor;

@end
