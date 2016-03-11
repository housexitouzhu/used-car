//
//  UIIndexControl.h
//  GasHome
//
//  Created by Alan on 12-11-9.
//  Copyright (c) 2012年 AutoHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIIndexControl : UIPageControl

@property (nonatomic, retain) UIImage *imageStateNormal;
@property (nonatomic, retain) UIImage *imageStateSelected;
- (id)initWithFrame:(CGRect)frame currentImageName:(NSString *)current commonImageName:(NSString *)common;
@end
