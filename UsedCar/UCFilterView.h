//
//  UCSelectedView.h
//  UsedCar
//
//  Created by 张鑫 on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCLocationView.h"
#import "UCExpandBrandView.h"
#import "UCFilterOrderList.h"
#import "UCFilterPriceList.h"

typedef enum UCFilterViewStyle{
    UCFilterViewStyleLocation = -1,
    UCFilterViewStyleBrand = 0,
    UCFilterViewStylePrice = 1,
    UCFilterViewStyleMileage = 2,
} UCFilterViewStyle;

@class UCHomeView;

@protocol UCFilterViewDelegate;

@interface UCFilterView : UIView <UCExpandBrandViewDelegate, UCFilterOrderListDelegate, UCFilterPriceListDelegate>

@property(nonatomic, weak) id<UCFilterViewDelegate> delegate;

@property (nonatomic, strong) UCFilterModel *mFilter;
@property (nonatomic, strong) NSString *strOrderID;

- (void)makeViewWithTag:(NSInteger)viewTag;
- (void)closeFilter:(BOOL)isValid;

@end


@protocol UCFilterViewDelegate <NSObject>
@optional

- (void)filterView:(UCFilterView *)filterView filterMode:(UCFilterModel *)mFilter orderID:(NSString *)orderID isValid:(BOOL)isValid;

@end
