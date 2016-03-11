//
//  SearchHistoryCell.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-11.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchHistoryCell : UITableViewCell


@property (retain, nonatomic) UILabel *nameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;

@end
