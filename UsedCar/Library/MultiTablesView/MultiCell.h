//
//  MultiCell.h
//  MultiTablesView
//
//  Created by 张鑫 on 13-11-7.
//  Copyright (c) 2013年 Zedenem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiCell.h"
#import "UIImageView+WebCache.h"

@interface MultiCell : UITableViewCell

@property (nonatomic, strong) UIView *ivLeftSelectedBar;
@property (nonatomic, strong) UITableView *tvTableView;
@property (nonatomic, strong) UIImageView *ivLogoImg;
@property (nonatomic, strong) UIView *vLine;
@property (nonatomic, strong) UILabel *labText;

/** 有品牌logo */
- (id)initWithBrandLogoStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier level:(NSInteger)level marginLeftOfLine:(CGFloat)marginLeftOfLine cellWidth:(CGFloat)cellWidth;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier level:(NSInteger)level marginLeftOfLine:(CGFloat)marginLeftOfLine cellWidth:(CGFloat)cellWidth;

- (void)makeView:(CGFloat)cellHeight;

@end
