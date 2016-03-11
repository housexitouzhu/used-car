//
//  UCHomePriceList.h
//  UsedCar
//
//  Created by Sun Honglin on 14-8-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UCFilterModel;

@protocol UCFilterPriceListDelegate;

@interface UCFilterPriceList : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<UCFilterPriceListDelegate> delegate;

- (id)initWithFrame:(CGRect)frame filter:(UCFilterModel *)mFilter;

- (void)setSelectedCellWithValue:(NSString*)value;

@end

@protocol UCFilterPriceListDelegate <NSObject>

- (void)UCFilterPriceList:(UCFilterPriceList*)vFilterPrice didSelectedWithName:(NSString*)name value:(NSString*)value isChanged:(BOOL)isChanged;

@end