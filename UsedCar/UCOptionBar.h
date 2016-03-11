//
//  UCOptionBar.h
//  UsedCar
//
//  Created by Alan on 13-11-7.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "AMBlurView.h"

@protocol UCOptionBarDelegate;

@interface UCOptionBarItem : NSObject

@property(nonatomic, strong) UIFont *titleFont;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *titleSelected;
@property(nonatomic, strong) NSString *titleHighlighted;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) UIImage *imageSelected;
@property(nonatomic, strong) UIImage *imageHighlighted;
@property(nonatomic, strong) UIColor *titleColor;
@property(nonatomic, strong) UIColor *titleColorSelected;
@property(nonatomic, strong) UIView *leftView;
@property(nonatomic, strong) UIView *rightView;
@property(nonatomic) BOOL isSelected;
@property(nonatomic, weak) id tag;
@property(nonatomic) CGFloat padding;
//@property(nonatomic) BOOL stateAnimationEnabled;

//- (id)initWithImage:(UIImage *)image
////			 target:(id)target
////			 action:(SEL)action
//   forControlEvents:(UIControlEvents)controlEvents;
//
//- (id)initWithImage:(UIImage *)image
//   imageHighlighted:(UIImage *)imageHighlighted
////			 target:(id)target
////			 action:(SEL)action
//   forControlEvents:(UIControlEvents)controlEvents;
//
//- (id)initWithTitle:(NSString *)title
//   titleHighlighted:(NSString *)titleHighlighted
//			  image:(UIImage *)image
//   imageHighlighted:(UIImage *)imageHighlighted
////			 target:(id)target
////			 action:(SEL)action
//   forControlEvents:(UIControlEvents)controlEvents;
//
//- (id)initWithTitle:(NSString *)title
//			  image:(UIImage *)image
//   imageHighlighted:(UIImage *)imageHighlighted
////			 target:(id)target
////			 action:(SEL)action
//   forControlEvents:(UIControlEvents)controlEvents;


@end

@interface UCOptionBar : AMBlurView
{
	NSMutableArray *_items;
	UIView *_viewItems;
	
	BOOL _isShowSlider;
	UIView *_vSlider;
	
	UCOptionBarItem *_selectedItem;
    NSUInteger _selectedItemIndex;
    
    NSCondition *_condition;
    
}

@property(nonatomic, weak) id <UCOptionBarDelegate> delegate;
//@property(nonatomic, readonly) UCOptionBarItem *selectedItem;
@property(nonatomic, readonly) NSUInteger selectedItemIndex;
@property(nonatomic, readonly) NSUInteger lastSelectedItemIndex;
@property(nonatomic, strong) NSArray *items;
@property(nonatomic) BOOL isAutoAdjustSlider;               // 是否自适应滑动条
//@property(nonatomic, getter = isReselect) BOOL reselect; // 是否支持重复选择
//@property(nonatomic, getter = isCancelSelect) BOOL cancelSelect; // 取消选中项

- (id)initWithFrame:(CGRect)frame sliderView:(UIView *)sliderView;

- (void)addItem:(UCOptionBarItem *)item;
- (void)insertItem:(UCOptionBarItem *)item atIndex:(NSUInteger)index;
- (void)removeItemAtIndex:(NSUInteger)index;
- (void)removeItem:(UCOptionBarItem *)item;
- (void)selectItemAtIndex:(NSUInteger)index;
- (void)selectItemAtIndex:(NSUInteger)index isPerform:(BOOL)isPerform;
- (void)selectItem:(UCOptionBarItem *)item;
- (UCOptionBarItem *)itemAtIndex:(NSUInteger)index;
- (void)hiddenWithIndex:(NSUInteger)index isHidden:(BOOL)isHidden;
- (void)enabledWithIndex:(NSUInteger)index isEnabled:(BOOL)isEnabled;
- (void)enabledAll:(BOOL)isEnabled;
- (UIView *)itemViewAtIndex:(NSUInteger)index;
- (void)setBadgeAtIndex:(NSUInteger)index badgeValue:(NSString *)badgeValue;
- (void)cancelSelected;

@end

@protocol UCOptionBarDelegate <NSObject>

- (void)optionBar:(UCOptionBar *)optionBar didSelectAtIndex:(NSInteger)index;

@end
