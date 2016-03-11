//
//  InputMorePanel.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    InputMoreFunctionImage = 0,
    InputMoreFunctionCamera = 1,
    InputMoreFunctionCarPhoto = 2,
    InputMoreFunctionRecommend = 3,
    InputMoreFunctionLocation = 4
} InputMoreFunction;

@protocol InputMorePanelDelegate;

@interface InputMorePanel : UIView

@property (nonatomic, strong) NSArray *arrIconName;
@property (nonatomic, strong) NSArray *arrTitle;
@property (nonatomic, assign) id<InputMorePanelDelegate> delegate;

- (id)initWithFrame:(CGRect)frame iconNameArray:(NSArray*)iconNames titleArray:(NSArray*)titles;

@end

@protocol InputMorePanelDelegate <NSObject>

- (void)InputMorePanelDelegate:(InputMorePanel*)panel didSelectFunction:(InputMoreFunction)function;

@end


@interface GridButtonCell : UIView

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *titleLabel;

- (id)initWithOrigin:(CGPoint)origin icon:(NSString*)iconName iconPress:(NSString*)iconPressName title:(NSString*)title;

@end