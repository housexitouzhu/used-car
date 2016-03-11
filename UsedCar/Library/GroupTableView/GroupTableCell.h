//
//  GroupTableCell.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-9.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MultiCell.h"
#import "UIImageView+WebCache.h"

@interface GroupTableCell : UITableViewCell

@property (nonatomic, strong) UIView *ivLeftSelectedBar;
@property (nonatomic, strong) UITableView *tvTableView;
@property (nonatomic, strong) UIImageView *ivLogoImg;
@property (nonatomic, strong) UIView *vLine;
@property (nonatomic, strong) UILabel *labText;
@property (nonatomic, strong) UIImageView *closeIconView;

/** 有品牌logo */
- (id)initWithBrandLogoStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier level:(NSInteger)level marginLeftOfLine:(CGFloat)marginLeftOfLine cellWidth:(CGFloat)cellWidth;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier level:(NSInteger)level marginLeftOfLine:(CGFloat)marginLeftOfLine cellWidth:(CGFloat)cellWidth;

- (void)makeView:(CGFloat)cellHeight;

@end
