//
//  UCSingleSelectionVIew.m
//  UsedCar
//
//  Created by 张鑫 on 14-7-9.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSingleSelectionVIew.h"
#import "UIImage+Util.h"

@interface UCSingleSelectionVIew ()

@property (nonatomic, weak) NSArray *titles;
@property (nonatomic, weak) NSArray *images;
@property (nonatomic) CGFloat marginX;
@property (nonatomic) CGFloat marginY;
@property (nonatomic) NSInteger singleLineCount;
@property (nonatomic) CGSize buttonSize;
@property (nonatomic) UCSingleSelectionViewStyle viewStyle;
@property (nonatomic) CGFloat offset;

@end

@implementation UCSingleSelectionVIew

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithMarginX:(CGFloat)marginX marginY:(CGFloat)marginY buttonSize:(CGSize)buttonSize singleLineCount:(NSInteger)singleLineCount title:(NSArray *)title images:(NSArray *)images UCSingleSelectionViewStyle:(UCSingleSelectionViewStyle)viewStyle offset:(CGFloat)offset
{
    self = [super init];
    if (self) {
        _buttonItems = [[NSMutableArray alloc] init];
        _marginX = marginX;
        _marginY = marginY;
        _singleLineCount = singleLineCount;
        _titles = title;
        _images = images;
        _viewStyle = viewStyle;
        _buttonSize = buttonSize;
        _offset = offset;
        [self initView];
    }
    return self;
}

- (void)initView
{
    NSInteger count = _titles.count > 0 ? _titles.count : _images.count;
    CGFloat minX = -_marginX;
    CGFloat minY = -_marginY;
    
    for (int i = 0; i < count; i++) {
        UIButton *btnItem = [[UIButton alloc] initWithFrame:CGRectMake(minX + _marginX, minY + _marginY, _buttonSize.width, _buttonSize.height)];
//#warning 测试
//        btnItem.backgroundColor = RGBColorAlpha(11*i, 22*i, 33*i, 1);
        btnItem.titleLabel.font = kFontNormal;
        [btnItem setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
        btnItem.tag = i;
        [btnItem addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if ((i+1) % _singleLineCount == 0 && (i+1) >= _singleLineCount) {
            minX = -_marginX;
            minY += btnItem.height + _marginY;
        } else {
            minX += btnItem.width + _marginX;
        }
        
        if (_titles.count > 0)
            [btnItem setTitle:[_titles objectAtIndex:i] forState:UIControlStateNormal];
        if (_images.count > 0) {
            // 传送的是图片
            if ([[_images objectAtIndex:i] isKindOfClass:[UIImage class]])
                [btnItem setImage:[_images objectAtIndex:i] forState:UIControlStateNormal];
            // 传送的是图片名字
            else
                [btnItem setImage:[UIImage imageNamed:[_images objectAtIndex:i]] forState:UIControlStateNormal];
        }
        
        // 横
        if (_viewStyle == UCSingleSelectionViewStyleX) {
            btnItem.titleEdgeInsets = UIEdgeInsetsMake(0, -btnItem.imageView.width, 0, -19 + _offset);
            btnItem.imageEdgeInsets = UIEdgeInsetsMake(0, -41 + _offset, 0, -[btnItem.titleLabel.text sizeWithFont:btnItem.titleLabel.font].width);
        }
        // 竖
        if (_viewStyle == UCSingleSelectionViewStyleY) {
            // 为修正iOS8.0的bug，iOS8下，按钮中的titleLabel.bounds的宽有错
            CGFloat width = [btnItem.titleLabel.text sizeWithFont:btnItem.titleLabel.font].width;
            btnItem.titleEdgeInsets = UIEdgeInsetsMake(35 + _offset, -btnItem.imageView.width, 0, 0);
            btnItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 25 + _offset, -width);
        }
        
        [_buttonItems addObject:btnItem];
        
        [self addSubview:btnItem];
    }

    self.size = CGSizeMake(_buttonSize.width * _singleLineCount + (_singleLineCount-1) * _marginX, minY + _buttonSize.height + _marginY);
}

/** 点击按钮 */
- (void)onClickButton:(UIButton *)btn
{

    if ([_delegate respondsToSelector:@selector(UCSingleSelectionView:didSelectedButton:)])
        [_delegate UCSingleSelectionView:self didSelectedButton:btn];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
