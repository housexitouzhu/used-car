//
//  UCOptionBar.m
//  UsedCar
//
//  Created by Alan on 13-11-7.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCOptionBar.h"
#import <QuartzCore/QuartzCore.h>

@implementation UCOptionBarItem

@end


@implementation UCOptionBar

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame sliderView:nil];
}

- (id)initWithFrame:(CGRect)frame sliderView:(UIView *)sliderView
{
    _selectedItemIndex = NSNotFound;
    _lastSelectedItemIndex = _selectedItemIndex;
	if(self = [super initWithFrame:frame]){
		//是否显示滑动块
        _isShowSlider = sliderView ? YES : NO;
		if (_isShowSlider) {
            sliderView.userInteractionEnabled = NO;
            sliderView.layer.zPosition = 100;
            _vSlider = sliderView;
		}
		_items = [[NSMutableArray alloc] init];
		_viewItems = [[UIView alloc] initWithFrame:self.bounds];
		[self addSubview:_viewItems];
	}
	return self;
}

- (void)setItems:(NSArray *)items{
	[_items setArray:items];
	[_viewItems removeAllSubviews];

	NSUInteger count = [items count];
	for(NSUInteger i = 0; i < count; i++){
		//数据
		UCOptionBarItem *item = [items objectAtIndex:i];
		//生成Item放入_viewItems进行管理
		UIButton *viewItem = [self buttonWithItem:item];
		[_viewItems addSubview:viewItem];
	}
	[self adjustViewItems];
}

- (void)addItem:(UCOptionBarItem *)item{
    [self insertItem:item atIndex:_items.count];
}

- (void)insertItem:(UCOptionBarItem *)item atIndex:(NSUInteger)index{
	if(_items.count >= index){
		[_items insertObject:item atIndex:index];
		UIButton *viewItem = [self buttonWithItem:item];
		[_viewItems insertSubview:viewItem atIndex:index];

        viewItem.alpha = 0;
        [UIView beginAnimations:nil context:NULL];
        [self adjustViewItems];
        [UIView commitAnimations];

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.2];
        viewItem.alpha = 1;
        [UIView commitAnimations];
	}
}

- (void)removeItemAtIndex:(NSUInteger)index{
	if(_items.count > index){
		[_items removeObjectAtIndex:index];
		UIButton *viewItem = [_viewItems.subviews objectAtIndex:index];

        [UIView beginAnimations:nil context:NULL];
        [viewItem removeFromSuperview];
        [self adjustViewItems];
        [UIView commitAnimations];
	}
}

- (void)removeItem:(UCOptionBarItem *)item{
	[self removeItemAtIndex:[_items indexOfObject:item]];
}

- (UIView *)itemViewAtIndex:(NSUInteger)index{
    return [_viewItems.subviews objectAtIndex:index];
}

- (void)setBadgeAtIndex:(NSUInteger)index badgeValue:(NSString *)badgeValue{
    static int vBadgeTag = 0xBBBB;
    UIButton *viewItem = [_viewItems.subviews objectAtIndex:index];
    UIView* oldBadgeView = [viewItem viewWithTag:vBadgeTag];
    [oldBadgeView removeFromSuperview];

    if(badgeValue){
        UILabel *labBadge = [[UILabel alloc] initWithFrame:CGRectZero];
        labBadge.text = badgeValue;
        [labBadge sizeToFit];
        labBadge.textColor = kColorWhite;
        labBadge.backgroundColor = [UIColor clearColor];
        labBadge.font = [UIFont systemFontOfSize:12];
        labBadge.textAlignment = NSTextAlignmentCenter;

        UIImage *bgImage = [[UIImage imageNamed:@"bg_badge"] stretchableImageWithLeftCapWidth:12 topCapHeight:12];

        CGFloat badgeWidth = labBadge.frame.size.width > bgImage.size.width ? labBadge.frame.size.width : bgImage.size.width;
        CGFloat badgeHeight = labBadge.frame.size.height > bgImage.size.height ? labBadge.frame.size.height : bgImage.size.height;

        UIView *vBadge = [[UIView alloc] initWithFrame:CGRectMake(viewItem.width - labBadge.width - (viewItem.width - labBadge.width) / 5, 0, badgeWidth, badgeHeight)];
        vBadge.tag = vBadgeTag;
        [vBadge setBackgroundImage:bgImage];
        labBadge.center = vBadge.centerBounds;
        [vBadge addSubview:labBadge];

        [viewItem addSubview:vBadge];
    }
}

//- (void)addItemAnimation:(UIButton *)viewItem{
//	[UIView beginAnimations:nil context:NULL];
//	viewItem.alpha = 1;
//	[UIView commitAnimations];
//}
//
//- (void)removeItemAnimation:(UIButton *)viewItem{
//	[UIView beginAnimations:nil context:NULL];
//	[viewItem removeFromSuperview];
//	[self adjustViewItems];
//	[UIView commitAnimations];
//}

- (void)adjustViewItems{
	NSInteger count = _viewItems.subviews.count;
    //计算隐藏的item
    NSInteger hidenCount = 0;
    for(UIButton *viewItem in _viewItems.subviews){
        if(viewItem.hidden)
            hidenCount++;
    }
    //调整位置
    NSInteger showCount = count - hidenCount;
    NSInteger xIndex = 0;
	for(NSInteger i = 0; i < count; i++){
		UIButton *viewItem = [_viewItems.subviews objectAtIndex:i];
		viewItem.tag = i;//button的tag用来保存索引,UIOptionBarItem的tag可以用来保存一个object.
        if (!viewItem.hidden) {
            UCOptionBarItem *item = [_items objectAtIndex:i];
            
            [viewItem setFrame:CGRectMake(_viewItems.width / showCount * xIndex++ + item.padding, item.padding, _viewItems.width / showCount - item.padding * 2, _viewItems.height - item.padding * 2)];

            if(item.title && item.image){
                // 图片文字偏移处理
                [viewItem setTitleEdgeInsets:UIEdgeInsetsMake(26, -viewItem.imageView.size.width, 0, 0)];
                [viewItem setImageEdgeInsets:UIEdgeInsetsMake(-12, 0, 0, -viewItem.titleLabel.bounds.size.width)];
            }
        }else {
            [viewItem setFrame:CGRectZero];
        }
	}
}

- (UIButton *)buttonWithItem:(UCOptionBarItem *)item{
	//选项
	UIButton *viewItem = [[UIButton alloc] initWithFrame:CGRectMake(1, 1, 1, 1)];
    viewItem.titleLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
	[viewItem addTarget:self action:@selector(onClickOptionBar:) forControlEvents:UIControlEventTouchUpInside];
	if(item.title){
		[viewItem.titleLabel setFont:item.titleFont];
		[viewItem setTitleColor:item.titleColor forState:UIControlStateNormal];
		[viewItem setTitleColor:item.titleColorSelected forState:UIControlStateSelected];
		[viewItem setTitle:item.title forState:UIControlStateNormal];
		[viewItem setTitle:item.titleSelected forState:UIControlStateSelected];
	}
	if(item.image){
		[viewItem setImage:item.image forState:UIControlStateNormal];
		[viewItem setImage:item.imageSelected forState:UIControlStateSelected];
	}
    
    if (item.leftView) {
        item.leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [viewItem addSubview:item.leftView];
    }
    
    if (item.rightView) {
        item.rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [viewItem addSubview:item.rightView];
    }
    
	return viewItem;
}

- (void)selectItemAtIndex:(NSUInteger)index{
	[self selectItemAtIndex:index isPerform:YES];
}

- (void)selectItemAtIndex:(NSUInteger)index isPerform:(BOOL)isPerform{
	[self onClickOptionBar:[_viewItems.subviews objectAtIndex:index]];
}

- (void)selectItem:(UCOptionBarItem *)item{
	[self selectItemAtIndex:[_items indexOfObject:item]];
}

- (UCOptionBarItem *)itemAtIndex:(NSUInteger)index{
    if(_items.count > index)
        return [_items objectAtIndex:index];
    else
        return nil;
}

- (void)hiddenWithIndex:(NSUInteger)index isHidden:(BOOL)isHidden{
    UIButton *viewItem = [_viewItems.subviews objectAtIndex:index];
    viewItem.hidden = isHidden;
    [self adjustViewItems];
}

- (void)enabledWithIndex:(NSUInteger)index isEnabled:(BOOL)isEnabled{
    UIButton *viewItem = [_viewItems.subviews objectAtIndex:index];
    viewItem.enabled = isEnabled;
}

- (void)enabledAll:(BOOL)isEnabled{
    for(UIButton *viewItem in _viewItems.subviews)
        viewItem.enabled = isEnabled;
}

- (void)cancelSelected{
    if (_selectedItemIndex != NSNotFound) {
        UIButton *selectedBtn = [_viewItems.subviews objectAtIndex:_selectedItemIndex];
        selectedBtn.selected = NO;
        
        _selectedItem = nil;
        _selectedItemIndex = NSNotFound;
        _lastSelectedItemIndex = _selectedItemIndex;
        if (_vSlider)
            [_vSlider removeFromSuperview];
    }
}

- (void)onClickOptionBar:(UIButton *)button{
    [self onClickOptionBar:button isPerform:YES];
}

- (void)onClickOptionBar:(UIButton *)button isPerform:(BOOL)isPerform{
    //上次已选中按钮设置取消
    if (_selectedItemIndex != NSNotFound) {
        UIButton *selectedBtn = [_viewItems.subviews objectAtIndex:_selectedItemIndex];
        selectedBtn.selected = NO;
    }
    //选中项索引
    _selectedItemIndex = button.tag;
    //本次选中按钮设置选中
    button.selected = YES;
	//滑动动画
	if(_isShowSlider && _lastSelectedItemIndex != _selectedItemIndex){
		if ([_vSlider isDescendantOfView:self]) {
			[UIView beginAnimations:nil context:nil];
            if (_isAutoAdjustSlider) {
                UCOptionBarItem *item = [self itemAtIndex:_selectedItemIndex];
                CGSize size = [item.title sizeWithFont:item.titleFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
                _vSlider.width = size.width;
            }
			_vSlider.minX = button.minX + (button.width - _vSlider.width) / 2;
            
			[UIView commitAnimations];
		}else {
            if (_isAutoAdjustSlider) {
                UCOptionBarItem *item = [self itemAtIndex:_selectedItemIndex];
                CGSize size = [item.title sizeWithFont:item.titleFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
                _vSlider.width = size.width;
            }
			_vSlider.minX = button.minX + (button.width - _vSlider.width) / 2;
			[self addSubview:_vSlider];
		}
	}
    
    if(isPerform)
        if ([self.delegate respondsToSelector:@selector(optionBar:didSelectAtIndex:)])
            [self.delegate optionBar:self didSelectAtIndex:_selectedItemIndex];

    _lastSelectedItemIndex = _selectedItemIndex;
}

@end
