//
//  UCHomeOrderList.h
//  UsedCar
//
//  Created by Sun Honglin on 14-8-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UCFilterOrderListDelegate;

@interface UCFilterOrderList : UIView

@property (retain, nonatomic) id<UCFilterOrderListDelegate> delegate;

- (id)initWithFrame:(CGRect)frame orderID:(NSString *)orderID;

- (void)setSelectedCellWithValue:(NSString*)value;

@end

@protocol UCFilterOrderListDelegate <NSObject>

- (void)UCFilterOrderList:(UCFilterOrderList *)vFilterOrder didSelectedWithName:(NSString *)name value:(NSString *)value isChanged:(BOOL)isChanged;

@end