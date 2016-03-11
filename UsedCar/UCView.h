//
//  UCView.h
//  UsedCar
//
//  Created by Alan on 13-10-25.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Util.h"
#import "AMBlurView.h"
#import "AMToastView.h"

#define kTopOptionHeight 35
#define kMainOptionBarHeight 40

@interface UCView : UIView

@property (nonatomic) BOOL isSupportGesturesToBack;
@property (nonatomic) AnimateOption showViewAnimated;

- (void)viewWillShow:(BOOL)animated;
- (void)viewDidShow:(BOOL)animated;
- (void)viewWillHide:(BOOL)animated;
- (void)viewDidHide:(BOOL)animated;
- (void)viewWillClose:(BOOL)animated;

@end
