//
//  DepositDetailCell.h
//  UsedCar
//
//  Created by Sun Honglin on 14-8-8.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoneyDetailItem.h"

@interface DepositDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *typeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceValueLabel;

- (void)makeView:(MoneyDetailItem *)itemModel;
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;
+ (DepositDetailCell *)newCellWithCellWidth:(CGFloat)cellWidth;

@end
