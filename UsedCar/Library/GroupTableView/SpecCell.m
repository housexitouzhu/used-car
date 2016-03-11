//
//  SpecCell.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-10.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "SpecCell.h"

@interface SpecCell ()

@property (nonatomic, strong) UIView *vHighlight;
@property (nonatomic) BOOL isShowLogoImg;
@property (nonatomic, strong) UIView *vLeftLine;

@end

@implementation SpecCell

- (id)initWithBrandLogoStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier level:(NSInteger)level marginLeftOfLine:(CGFloat)marginLeftOfLine cellWidth:(CGFloat)cellWidth
{
    _isShowLogoImg = YES;
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier level:level marginLeftOfLine:marginLeftOfLine cellWidth:cellWidth];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier level:(NSInteger)level marginLeftOfLine:(CGFloat)marginLeftOfLine cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = kColorClear;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.width = self.contentView.width = cellWidth;
        
        CGFloat marginLeft = level == 0 ? 0.0f : kLinePixel;
        
        // 高亮背景
        _vHighlight = [[UIView alloc] initWithFrame:CGRectMake(marginLeft, 0, self.width - marginLeft, 50)];
        _vHighlight.backgroundColor = kColorGrey5;
        
        // 选中条
        self.ivLeftSelectedBar = [[UIView alloc] initWithFrame:CGRectMake(marginLeft, 0, 2, 50)];
        self.ivLeftSelectedBar.backgroundColor = kColorOrange;
        
        // logo
        if (_isShowLogoImg && level == 0) {
            UIImage *iLogoImg = [UIImage imageNamed:@"screen_picture"];
            _ivLogoImg = [[UIImageView alloc] initWithImage:iLogoImg];
            _ivLogoImg.size = CGSizeMake(35, 35);
            _ivLogoImg.origin = CGPointMake(13, (50 - _ivLogoImg.size.height) / 2);
        }
        
        // 文本框
        self.labText = [[UILabel alloc] initWithFrame:CGRectMake(20 + marginLeft, 0, self.frame.size.width - 20 - 19, 50)];
        self.labText.font = kFontNormal;
        self.labText.lineBreakMode = NSLineBreakByCharWrapping;
        self.labText.textColor = kColorNewGray1;
        self.labText.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.labText.backgroundColor = [UIColor clearColor];
        
        // 分割线
        self.vLine = [[UIView alloc] initWithFrame:CGRectMake(marginLeftOfLine, 50 - kLinePixel, self.frame.size.width, kLinePixel)];
        self.vLine.backgroundColor = kColorNewLine;
        
        
        // 添加视图
        [self.contentView addSubview:_vHighlight];
        [self.contentView addSubview:self.vLine];
        [self.contentView addSubview:self.ivLeftSelectedBar];
        [self.contentView addSubview:_ivLogoImg];
        [self.contentView addSubview:self.labText];
        
        // 左边灰线
        if (level > 0) {
            _vLeftLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLinePixel, 50)];
            _vLeftLine.backgroundColor = kColorNewLine;
            [self.contentView addSubview:_vLeftLine];
        }
        
    }
    return self;
}

- (void)makeView:(CGFloat)cellHeight
{
    _vLeftLine.height = cellHeight;
}

/** 选中状态 */
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected == YES) {
        self.ivLeftSelectedBar.backgroundColor = kColorBlue;
        self.labText.textColor = kColorBlue;
    } else {
        self.ivLeftSelectedBar.backgroundColor = [UIColor clearColor];
        self.labText.textColor = [UIColor blackColor];
    }
    
}

/** 高亮状态 */
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted == YES) {
        _vHighlight.hidden = NO;
        _vHighlight.height = self.height - kLinePixel;
    }
    else {
        _vHighlight.hidden = YES;
    }
    
}

@end
