//
//  UCContactUsView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-9-16.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCContactUsView : UIView

@property (nonatomic, strong) NSArray *arrStatement;
@property (nonatomic, strong) NSString *phoneNumber;

/**
 *  @brief  init 电话联系栏
 *
 *  @param frame    Frame
 *  @param arrState 显示的文字, 每行文字一个 array 的 item. 例如: @[@"个人登录相关问题请致电", @"二手车之家服务电话：010-56851369"]
 *  @param number   拨打电话的电话号码: 例如 01059851661
 *
 *  @return 创建好的联系人的 view
 */
- (id)initWithFrame:(CGRect)frame withStatementArray:(NSArray*)arrState andPhoneNumber:(NSString*)number;


/**
 *  @brief  用新的提示语和电话号码重置 view
 *
 *  @param arrState 显示的文字, 每行文字一个 array 的 item. 例如: @[@"个人登录相关问题请致电", @"二手车之家服务电话：010-56851369"]
 *  @param number   拨打电话的电话号码: 例如 01059851661
 */
- (void)setViewWithStatementArray:(NSArray*)arrState andPhoneNumber:(NSString*)number;

@end
