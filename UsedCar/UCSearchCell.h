//
//  UCSearchCell.h
//  UsedCar
//
//  Created by wangfaquan on 14-5-14.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCCarBrandModel.h"

@interface UCSearchCell : UITableViewCell

@property (nonatomic, strong) UILabel *labName;  //车名

- (void)makeView:(UCCarBrandModel *)mCarName isShowSelect:(BOOL)isShowSelect;

@end
