//
//  HomeOptListCell.h
//  UsedCar
//
//  Created by Sun Honglin on 14-8-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeOptListCell : UITableViewCell

@property (retain, nonatomic) UILabel *labTitle;
@property (nonatomic, retain) UIView *vLeftSelectBar;
@property (nonatomic, retain) UIView *vHighlight;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;

@end
