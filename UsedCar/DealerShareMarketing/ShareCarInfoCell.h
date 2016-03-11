//
//  ShareCarInfoCell.h
//  UsedCar
//
//  Created by Sun Honglin on 14-10-15.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCCarInfoCell.h"

@interface ShareCarInfoCell : UCCarInfoCell

@property (nonatomic, strong) UIImageView *vShareCount; //左上角分享数字的 view
@property (nonatomic, strong) UILabel *labCount; //分享数字 label
@property (nonatomic, strong) UIView *vMask; //白色透明蒙版

@property (nonatomic, strong) UIImageView *ivChecked; //对勾
@property (nonatomic, assign) BOOL checked;

- (void)setCellToEditingMode:(BOOL)inEditing Animated:(BOOL)animated;
-(void)setCheckedImageChecked:(BOOL)checked;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;

@end
