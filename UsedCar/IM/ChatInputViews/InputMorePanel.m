//
//  InputMorePanel.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "InputMorePanel.h"

@implementation InputMorePanel

- (id)initWithFrame:(CGRect)frame iconNameArray:(NSArray*)iconNames titleArray:(NSArray*)titles{
    if ([self initWithFrame:frame]) {
        _arrIconName = iconNames;
        _arrTitle = titles;
        [self initView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kColorNewGray3;
    }
    return self;
}

- (void)initView{
    
    GridButtonCell *imageCell = [[GridButtonCell alloc] initWithOrigin:CGPointMake(36, 20)
                                                                  icon:[_arrIconName objectAtIndex:0]
                                                             iconPress:[[_arrIconName objectAtIndex:0] stringByAppendingString:@"_pre"]
                                                                 title:[_arrTitle objectAtIndex:0]];
    imageCell.button.tag = InputMoreFunctionImage;
    [imageCell.button addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:imageCell];
    
    GridButtonCell *cameraCell = [[GridButtonCell alloc] initWithOrigin:CGPointMake(36 + 50 + 49, 20)
                                                                  icon:[_arrIconName objectAtIndex:1]
                                                             iconPress:[[_arrIconName objectAtIndex:1] stringByAppendingString:@"_pre"]
                                                                  title:[_arrTitle objectAtIndex:1]];
    cameraCell.button.tag = InputMoreFunctionCamera;
    [cameraCell.button addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cameraCell];
}


#pragma mark - button click actions
- (void)onClickButton:(UIButton*)button{
    
    switch (button.tag) {
        case InputMoreFunctionImage:
        {
            if (![OMG isValidClick]) {
                return;
            }
            if ([self.delegate respondsToSelector:@selector(InputMorePanelDelegate:didSelectFunction:)]) {
                [self.delegate InputMorePanelDelegate:self didSelectFunction:InputMoreFunctionImage];
            }
        }
            break;
        case InputMoreFunctionCamera:
        {
            if (![OMG isValidClick]) {
                return;
            }
            if ([self.delegate respondsToSelector:@selector(InputMorePanelDelegate:didSelectFunction:)]) {
                [self.delegate InputMorePanelDelegate:self didSelectFunction:InputMoreFunctionCamera];
            }
        }
            break;
        default:
            break;
    }
}


@end


@implementation GridButtonCell

- (id)initWithOrigin:(CGPoint)origin icon:(NSString*)iconName iconPress:(NSString*)iconPressName title:(NSString*)title{
    CGRect frame = CGRectZero;
    frame.origin = origin;
    frame.size.width = 50;
    frame.size.height = 71;
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kColorClear;
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setFrame:CGRectMake(0, 0, 50, 50)];
        [_button setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
        [_button setImage:[UIImage imageNamed:iconPressName] forState:UIControlStateSelected];
        [_button setImage:[UIImage imageNamed:iconPressName] forState:UIControlStateHighlighted];
        [self addSubview:_button];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _button.maxY+7, 50, 14)];
        [_titleLabel setFont:kFontNormal];
        [_titleLabel setTextColor:kColorNewGray2];
        [_titleLabel setBackgroundColor:kColorClear];
        [_titleLabel setText:title];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_titleLabel];
        
    }
    return self;
}

@end







