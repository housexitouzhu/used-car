//
//  UCGuessLikeCell.h
//  UsedCar
//
//  Created by wangfaquan on 13-12-18.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCRaiderModel;

@interface UCRaiderCell : UITableViewCell

@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) UILabel *labDate;
@property (nonatomic, strong) UILabel *labContent;
@property (nonatomic, strong) UIView *vLine;

- (void)makeView:(UCRaiderModel *)mCarInfo isLocal:(BOOL)isLocal;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;

@end
