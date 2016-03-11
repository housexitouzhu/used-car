//
//  UCOrderView.m
//  UsedCar
//
//  Created by 张鑫 on 14/10/23.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCOrderView.h"
#import "UIImage+Util.h"
#import "UCView.h"

#define kOrderByPriceArrowTag          63748565
#define kOrderShadowStartTag           200000

@interface UCOrderView ()

@property (nonatomic, strong) UIScrollView *svOrder;    // 排序
@property (nonatomic, strong) UCOptionBar *obFilter;
@property (nonatomic) NSInteger orderBy;
@property (nonatomic, strong) NSArray *orderValues;

@end

@implementation UCOrderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FilterValues" ofType:@"plist"];
        NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
        self.orderValues = values[@"Order"];
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.backgroundColor = kColorWhite;
    
    // 左右边距
    UIImage *iLeft = [UIImage imageNamed:@"screennotes_cover_l_icon"];
    UIImageView *ivLeft = [[UIImageView alloc] initWithImage:iLeft];
    ivLeft.origin = CGPointMake(-iLeft.width + 15, 0);
    ivLeft.hidden = YES;
    ivLeft.tag = kOrderShadowStartTag + 0;
    
    UIImage *iRight = [UIImage imageNamed:@"screennotes_cover_icon"];
    UIImageView *ivRight = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 15, 0, iRight.width, iRight.height)];
    ivRight.image = iRight;
    ivRight.hidden = NO;
    ivRight.tag = kOrderShadowStartTag + 1;
    [self addSubview:ivLeft];
    [self addSubview:ivRight];
    
    // 筛选栏
    _svOrder = [self creatFilterScrollView:CGRectMake(10, 0, self.width - 10 * 2, kTopOptionHeight)];
    [self addSubview:_svOrder];
    
}

/** 筛选条 */
- (UIScrollView *)creatFilterScrollView:(CGRect)frame
{
    CGFloat width = 69;
    NSArray *titles = @[@"默认", @"价格", @"发布新", @"车龄短", @"里程少", @"资料全"];
    
    _svOrder = [[UIScrollView alloc] initWithFrame:frame];
    _svOrder.delegate = self;
    _svOrder.showsHorizontalScrollIndicator = NO;
    _svOrder.showsVerticalScrollIndicator = NO;
    _svOrder.contentInset = UIEdgeInsetsMake(0, -10, 0, -10);
    
    // 底部条
    UIView *vSlider = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 4, 41, 4)];
    vSlider.backgroundColor = kColorBlue;
    
    // 筛选条
    _obFilter = [[UCOptionBar alloc] initWithFrame:CGRectMake(0, 0, titles.count * width, frame.size.height) sliderView:vSlider];
    _obFilter.isAutoAdjustSlider = YES;
    _obFilter.delegate = self;
    _obFilter.isEnableBlur = NO;
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger i = 0; i < titles.count; i++) {
        UCOptionBarItem *item = [[UCOptionBarItem alloc] init];
        item.titleFont = kFontLarge;
        item.titleColor = kColorNewGray1;
        item.titleColorSelected = kColorBlue;
        item.title = titles[i];
        
        // 价格
        if (i == 1) {
            UIImage *iorder = [UIImage imageNamed:@"price_all_icon"];
            UIImageView *ivOrder = [[UIImageView alloc] initWithImage:iorder];
            ivOrder.origin = CGPointMake(0, 0);
            ivOrder.tag = kOrderByPriceArrowTag;
            
            UIView *vRight = [[UIView alloc] initWithFrame:CGRectMake(-ivOrder.width - 10, 12.5, ivOrder.width + 1, ivOrder.height)];
            
            [vRight addSubview:ivOrder];
            item.rightView = vRight;
        }
        
        [items addObject:item];
    }
    
    [_obFilter setItems:items];
    [_obFilter selectItemAtIndex:0];
    _svOrder.contentSize = CGSizeMake(_obFilter.width, _svOrder.height);
    if (_svOrder.contentSize.width == self.width) {
        UIImageView *ivRight = (UIImageView *)[self viewWithTag:kOrderShadowStartTag + 1];
        ivRight.hidden = YES;
    }
    
    [_svOrder addSubview:_obFilter];
    
    
    return _svOrder;
}

#pragma mark - UCOptionBarDelegate
- (void)optionBar:(UCOptionBar *)optionBar didSelectAtIndex:(NSInteger)index
{

    if (optionBar.lastSelectedItemIndex == index && index != 1)
        return;
    NSInteger orderIndex = index;
    
    // 调整滑动区域
    UIView *vItem = [_obFilter itemViewAtIndex:index];
    CGFloat offsetX = vItem.minX - _svOrder.width / 2 + vItem.width / 2;

    if (offsetX < 0)
        [_svOrder setContentOffset:CGPointMake(10, 0) animated:YES];
    else if (offsetX > _svOrder.contentSize.width - _svOrder.width)
        [_svOrder setContentOffset:CGPointMake(_svOrder.contentSize.width - _svOrder.width - 10, 0) animated:YES];
    else
        [_svOrder setContentOffset:CGPointMake(vItem.minX - _svOrder.width / 2 + vItem.width / 2, 0) animated:YES];
    
    // 非（价格、默认）
    UIImageView *ivOrder = (UIImageView *)[_obFilter viewWithTag:kOrderByPriceArrowTag];
    if (index > 1)
        orderIndex +=1;
    // 价格
    else if (index == 1) {
        orderIndex = _orderBy == 2 ? 2 : 1;
        ivOrder.image = [UIImage imageNamed:orderIndex == 2 ? @"price_low_icon" : @"price_high_icon"];
    }
    // 默认
    else
        orderIndex = index;
    
    // 恢复价格默认图片
    if (index != 1)
        ivOrder.image = [UIImage imageNamed:@"price_all_icon"];
    
    NSString *order = [[self.orderValues objectAtIndex:orderIndex] objectForKey:@"Value"];
    _orderBy = order.integerValue == NSNotFound ? _orderBy : order.integerValue;
    
    if ([self.delegate respondsToSelector:@selector(orderView:didSelectedIndex:)]) {
        [self.delegate orderView:self didSelectedIndex:_orderBy];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIImageView *ivLeft = (UIImageView *)[self viewWithTag:kOrderShadowStartTag + 0];
    UIImageView *ivRight = (UIImageView *)[self viewWithTag:kOrderShadowStartTag + 1];
    ivLeft.hidden = scrollView.contentOffset.x > 21 ? NO : YES;
    ivRight.hidden = scrollView.contentOffset.x >= (scrollView.contentSize.width - scrollView.width - 10) ? YES : NO;
}


@end
