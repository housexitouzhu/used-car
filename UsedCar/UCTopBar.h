//
//  UCTopBar.h
//  UsedCar
//
//  Created by Alan on 13-11-7.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AMBlurView.h"

#define kButtonEdgeInsetsLeft               15
#define kBackButtonEdgeInsetsLeft           10

typedef enum {
    UCTopBarButtonLeft = 1,
    UCTopBarButtonRight = 2,
    UCTopBarButtonTitle = 3,
} UCTopBarButton;

@interface UCTopBar : UIView

@property (nonatomic, readonly) UIButton *btnTitle;
@property (nonatomic, readonly) UIButton *btnLeft;
@property (nonatomic, readonly) UIButton *btnRight;

- (void)setLetfTitle:(NSString *)title;
@end
