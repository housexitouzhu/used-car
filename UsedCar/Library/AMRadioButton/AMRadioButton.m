//
//  AMRadioButton.m
//  UsedCar
//
//  Created by Alan on 13-11-22.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "AMRadioButton.h"

@implementation AMRadioButton

- (id)initWithFrame:(CGRect)frame groupId:(NSString*)groupId
{
    self = [super initWithFrame:frame];
    if (self) {
        _index = NSNotFound;
        self.groupId = groupId;
        self.buttons = [NSMutableArray array];
    }
    return self;
}

- (void)addButton:(UIButton *)btn
{
    [_buttons addObject:btn];
    [btn addTarget:self action:@selector(onClickRadioButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}

- (void)onClickRadioButton:(UIButton *)btn
{
    [self selectAtIndex:[_buttons indexOfObject:btn]];
    if ([self.delegate respondsToSelector:@selector(radioButton:atIndex:inGroup:)]) {
        [self.delegate radioButton:self atIndex:_index inGroup:_groupId];
    }
}

- (void)selectAtIndex:(NSUInteger)index
{
    _index = index;
    for (NSInteger i = 0; i < _buttons.count; i++) {
        UIButton *btn = [_buttons objectAtIndex:i];
        btn.selected = i == index;
    }
}

@end
