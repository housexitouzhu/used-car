//
//  AMRadioButton.h
//  UsedCar
//
//  Created by Alan on 13-11-22.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMRadioButtonDelegate;

@interface AMRadioButton : UIView

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic) id<AMRadioButtonDelegate> delegate;

- (id)initWithFrame:(CGRect)frame groupId:(NSString*)groupId;
- (void)addButton:(UIButton *)btn;
- (void)selectAtIndex:(NSUInteger)index;

@end

@protocol AMRadioButtonDelegate <NSObject>

- (void)radioButton:(AMRadioButton *)radioButton atIndex:(NSUInteger)index inGroup:(NSString*)groupId;

@end
