//
//  UCCarAttentionCell.h
//  UsedCar
//
//  Created by wangfaquan on 14-4-6.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCCarAttenModel.h"
#import "UIImageView+WebCache.h"

#define UCCarInfoCellHeight 84
@interface UCAttentionCell : UITableViewCell

- (void)makeView:(UCCarAttenModel *)mCarInfo isShowSelect:(BOOL)isShowSelect;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;

@end
