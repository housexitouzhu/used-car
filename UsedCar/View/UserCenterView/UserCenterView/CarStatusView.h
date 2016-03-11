//
//  CarStatusView.h
//  UsedCar
//
//  Created by 张鑫 on 14-9-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CarStatusTagOnSale = 30000,
    CarStatusTagNotpassed,
    CarStatusTagSold,
    CarStatusTagNotfilled,
    CarStatusTagChecking,
    CarStatusTagInvalid,
} CarStatusTag;

@protocol CarStatusViewDelegate;

@interface CarStatusView : UIView

@property (nonatomic, strong) UIButton *btnMyCars;
@property (nonatomic, strong) UIButton *btnSetPhone;
@property (nonatomic, strong) UILabel *labRefreshTime;
@property (nonatomic, weak) id<CarStatusViewDelegate>delegate;

- (id)initWithUserStyle:(UserStyle)userStyle;
- (void)creatUserStyleViewWithUserStyle:(UserStyle)userStyle;
- (UILabel *)getLabelWithCarStatusTag:(CarStatusTag)carStatusTag;

@end

@protocol CarStatusViewDelegate <NSObject>

- (void)CarStatusView:(CarStatusView *)vCarStatus onClickMyCarButton:(UIButton *)btn;
- (void)CarStatusView:(CarStatusView *)vCarStatus onClickSetPhoneButton:(UIButton *)btn;
- (void)CarStatusView:(CarStatusView *)vCarStatus onClickCarStatusButton:(UIButton *)btn indexOfButton:(NSUInteger)index;

@end
