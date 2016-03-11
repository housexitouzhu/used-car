//
//  UCInputCodeView.h
//  UsedCar
//
//  Created by 张鑫 on 14/11/20.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

@protocol UCInputCodeViewDelegate;

@class SalesPersonModel;

@interface UCInputCodeView : UCView <UITextFieldDelegate>

@property (nonatomic, weak) id<UCInputCodeViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame salesPersonModel:(SalesPersonModel *)mSalesPerson;

@end

@protocol UCInputCodeViewDelegate <NSObject>

- (void)didVerifyDealerSuccessed:(UCInputCodeView *)vInputCode;

@end

