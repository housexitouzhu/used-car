//
//  DepositDetailCell.m
//  UsedCar
//
//  Created by Sun Honglin on 14-8-8.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "DepositDetailCell.h"

@implementation DepositDetailCell

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
//{
////    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    
//    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        // Initialization code
//        self = [[[NSBundle mainBundle] loadNibNamed:@"DepositDetailCell" owner:self options:nil] firstObject];
//        
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
//        [self setBackgroundColor:kColorWhite];
//        
//        self.width = self.contentView.width = cellWidth;
//        
//        _typeNameLabel.textColor = kColorNewGray2;
//        _reasonNameLabel.textColor = kColorNewGray2;
//        _paymentNameLabel.textColor = kColorNewGray2;
//        _balanceNameLabel.textColor = kColorNewGray2;
//        
//        _typeValueLabel.textColor = kColorNewGray1;
//        _reasonValueLabel.textColor = kColorNewGray1;
//        _paymentValueLabel.textColor = kColorNewGray1;
//        _balanceValueLabel.textColor = kColorNewGray1;
//        
//        _balanceNameLabel.minX = self.width / 2;
//        _balanceValueLabel.minX = _balanceNameLabel.maxX + 9;
//        
//        UIView *hLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 84 - kLinePixel, self.width, kLinePixel) color:kColorNewLine];
//        [self.contentView addSubview:hLine];
//        
//    }
//    return self;
//}

+ (DepositDetailCell *)newCellWithCellWidth:(CGFloat)cellWidth{
    DepositDetailCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"DepositDetailCell" owner:self options:nil] firstObject];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:kColorWhite];
    
    cell.width = cell.contentView.width = cellWidth;
    
    cell.typeNameLabel.textColor = kColorNewGray2;
    cell.reasonNameLabel.textColor = kColorNewGray2;
    cell.paymentNameLabel.textColor = kColorNewGray2;
    cell.balanceNameLabel.textColor = kColorNewGray2;
    
    cell.typeValueLabel.textColor = kColorNewGray1;
    cell.reasonValueLabel.textColor = kColorNewGray1;
    cell.paymentValueLabel.textColor = kColorNewGray1;
    cell.balanceValueLabel.textColor = kColorNewGray1;
    
    cell.balanceNameLabel.minX = cell.width / 2;
    cell.balanceValueLabel.minX = cell.balanceNameLabel.maxX + 9;
    
    UIView *hLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 84 - kLinePixel, cell.width, kLinePixel) color:kColorNewLine];
    [cell.contentView addSubview:hLine];
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)makeView:(MoneyDetailItem *)itemModel{
    
    //状态:1 入款; 5 扣款; 10 补款; 15 退款
    if (itemModel.State.integerValue == 1 || itemModel.State.integerValue == 10) {
        _typeValueLabel.textColor = kColorNewGray1;
    }
    else{
        _typeValueLabel.textColor = kColorNewOrange;
    }
    
    _typeValueLabel.text = itemModel.StateName;
    _reasonValueLabel.text = itemModel.Reason;
    _paymentValueLabel.text = itemModel.Money.stringValue;
    _balanceValueLabel.text = itemModel.Overage.stringValue;
    
    _balanceNameLabel.minX = self.width / 2;
    _balanceValueLabel.minX = _balanceNameLabel.maxX + 10;
}


@end
