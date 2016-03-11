//
//  UCAddSalesPerson.h
//  UsedCar
//
//  Created by 张鑫 on 14-5-22.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

@protocol UCAddSalesPersonDelegate;

@interface UCAddSalesPerson : UCView <UITextFieldDelegate>

@property (nonatomic) BOOL isFromSalesListView;     // 是否由销售列表页创建的
@property (nonatomic, weak) id<UCAddSalesPersonDelegate> delegate;

@end

@protocol UCAddSalesPersonDelegate <NSObject>

- (void)UCAddSalesPerson:(UCAddSalesPerson *)vAddSalesPerson isSuccess:(BOOL)isSuccess;

@end