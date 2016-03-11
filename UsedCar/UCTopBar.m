//
//  UCTopBar.m
//  UsedCar
//
//  Created by Alan on 13-11-7.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCTopBar.h"

@implementation UCTopBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    //    self.blurTintColor = kColorBlue;
    self.backgroundColor = kColorBlue;
    
    UIView *vBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 44, self.width, 44)];
    vBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    CGFloat segmentWidth = vBar.width / 4;
    
    // 标题
    _btnTitle = [[UIButton alloc] initWithFrame:CGRectMake(segmentWidth, 0, segmentWidth * 2, vBar.height)];
    _btnTitle.titleLabel.font = kFontSuper;
    _btnTitle.tag = UCTopBarButtonTitle;
    _btnTitle.exclusiveTouch = YES;
    //[_btnTitle setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    // 左按钮
    _btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, segmentWidth, vBar.height)];
    _btnLeft.tag = UCTopBarButtonLeft;
    _btnLeft.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _btnLeft.titleLabel.font = kFontLarge;
    _btnLeft.titleEdgeInsets = UIEdgeInsetsMake(0, kButtonEdgeInsetsLeft, 0, 0);
    _btnLeft.imageEdgeInsets = UIEdgeInsetsMake(0, kButtonEdgeInsetsLeft, 0, 0);
    _btnLeft.exclusiveTouch = YES;
    [_btnLeft setTitleColor:kColorGrey3 forState:UIControlStateHighlighted];
    
    // 右按钮
    _btnRight = [[UIButton alloc] initWithFrame:CGRectMake(vBar.width - segmentWidth, 0, segmentWidth, vBar.height)];
    _btnRight.tag = UCTopBarButtonRight;
    _btnRight.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _btnRight.titleLabel.font = kFontLarge;
    _btnRight.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kButtonEdgeInsetsLeft);
    _btnRight.exclusiveTouch = YES;
    [_btnRight setTitleColor:kColorGrey3 forState:UIControlStateHighlighted];
    
    [vBar addSubview:_btnTitle];
    [vBar addSubview:_btnLeft];
    [vBar addSubview:_btnRight];
    
    [self addSubview:vBar];
}

- (void)setLetfTitle:(NSString *)title
{
    if ([title isEqualToString:@"返回"]) {
        [_btnLeft setImage:[UIImage imageNamed:@"topbar_backbtn"] forState:UIControlStateNormal];
        _btnLeft.titleEdgeInsets = UIEdgeInsetsMake(0, kBackButtonEdgeInsetsLeft, 0, 0);
        _btnLeft.imageEdgeInsets = UIEdgeInsetsMake(0, kBackButtonEdgeInsetsLeft, 0, 0);
    }
    [_btnLeft setTitle:title forState:UIControlStateNormal];
}

- (void)setShrink:(BOOL)shrink animated:(BOOL)animated
{
    
}

@end
