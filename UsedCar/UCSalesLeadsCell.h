//
//  UCSaleLeadCell.h
//  UsedCar
//
//  Created by wangfaquan on 14-4-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCSalesLeadsModel;

@interface UCSalesLeadsCell : UITableViewCell

@property (nonatomic, strong) UILabel *labName;        // 姓名
@property (nonatomic, strong) UILabel *labPhone;       // 电话
@property (nonatomic, strong) UILabel *labCount;       // 意向车个数
@property (nonatomic, strong) UILabel *labData;        // 数据
@property (nonatomic, strong) UIImageView *ivArrow;    // 箭头

- (void)makeView:(UCSalesLeadsModel *)mSaleLead markReads:(NSMutableArray *)markReads;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;

@end