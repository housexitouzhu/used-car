//
//  SHLActionSheet.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-19.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#define UIControlStateAll UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted
#define SYSTEM_VERSION_LESS_THAN(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending)

// Define 'button press' effects
typedef NS_ENUM(NSInteger, SHLActionSheetButtonResponse) {
    
    SHLActionSheetButtonResponseFadesOnPress,
    SHLActionSheetButtonResponseReversesColorsOnPress,
    SHLActionSheetButtonResponseShrinksOnPress,
    SHLActionSheetButtonResponseHighlightsOnPress
};

typedef NS_ENUM(NSInteger, SHLActionSheetButtonCornerType) {
    
    SHLActionSheetButtonCornerTypeNoCornersRounded,
    SHLActionSheetButtonCornerTypeTopCornersRounded,
    SHLActionSheetButtonCornerTypeBottomCornersRounded,
    SHLActionSheetButtonCornerTypeAllCornersRounded
    
};


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class SHLActionSheet, SHLActionSheetTitleView;

@protocol SHLActionSheetDelegate <NSObject>

-(void)actionSheet:(SHLActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

#pragma mark - SHLActionSheet
@interface SHLActionSheet : UIView

@property (nonatomic) UIView *transparentView;
@property (nonatomic) NSMutableArray *buttons;
@property (nonatomic) NSMutableArray *seperators;
@property (nonatomic) NSString *title;

@property (nonatomic) SHLActionSheetTitleView *titleView;
@property (nonatomic, weak) id <SHLActionSheetDelegate> delegate;
@property (nonatomic) SHLActionSheetButtonResponse buttonResponse;

@property (nonatomic) BOOL visible, hasCancelButton, hasDestructiveButton, shouldCancelOnTouch;

@property (nonatomic) CGFloat buttonWidth, buttonHeight;
@property (nonatomic) CGFloat seperatorHeight;
@property (nonatomic) CGFloat cancelButtonGap;

@property (nonatomic) UIColor *seperatorColor;
@property (nonatomic) CGFloat buttonAlpha; //alpha for all
@property (nonatomic) CGFloat tranparentViewAlpha;
@property (nonatomic) CGFloat otherButtonAlpha, cancelButtonAlpha, destructiveButtonAlpha;


//
- (void)showInView:(UIView *)theView;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

- (id)initWithTitle:(NSString *)title delegate:(id<SHLActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelTitle destructiveButtonTitle:(NSString *)destructiveTitle otherButtonTitles:(NSString *)otherTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (id)initWithTitle:(NSString *)title delegate:(id<SHLActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelTitle destructiveButtonTitle:(NSString *)destructiveTitle otherButtonTitlesArray:(NSArray *)otherTitlesArray;

// set button width & height
- (void)setButtonWidth:(CGFloat)width forButtonAtIndex:(NSInteger)index;
- (void)setButtonHeight:(CGFloat)height forButtonAtIndex:(NSInteger)index;

// get title & buttons
- (NSInteger)numberOfButtons;
- (NSString *)buttonTitleAtIndex:(NSInteger)index;

// get colors
- (UIColor *)buttonTextColorAtIndex:(NSInteger)index;
- (UIColor *)buttonBackgroundColorAtIndex:(NSInteger)index;

// fonts
- (void)setFont:(UIFont *)font;
- (void)setTitleFont:(UIFont *)font;
- (void)setFont:(UIFont *)font forButtonAtIndex:(NSInteger)index;

// set standard colors
- (void)setTitleTextColor:(UIColor *)color;
- (void)setButtonTextColor:(UIColor *)color;
- (void)setButtonTextColor:(UIColor *)color forButtonAtIndex:(NSInteger)index;

- (void)setTitleBackgroundColor:(UIColor *)color;
- (void)setButtonBackgroundColor:(UIColor *)color;
- (void)setButtonBackgroundColor:(UIColor *)color forButtonAtIndex:(NSInteger)index;

// highlight colors
- (void)setButtonHighlightBackgroundColor:(UIColor *)color;
- (void)setButtonHighlightBackgroundColor:(UIColor *)color forButtonAtIndex:(NSInteger)index;
- (void)setButtonHighlightTextColor:(UIColor *)color;
- (void)setButtonHighlightTextColor:(UIColor *)color forButtonAtIndex:(NSInteger)index;

@end

#pragma mark - SHLActionSheetButton
@interface SHLActionSheetButton : UIButton

@property (nonatomic) NSInteger index;
@property (nonatomic) SHLActionSheetButtonCornerType cornerType;
@property (nonatomic) UIRectCorner roundingCorners;
@property (nonatomic) CGSize cornerRadiiSize;
@property (nonatomic) UIColor *originalTextColor, *highlightTextColor;
@property (nonatomic) UIColor *originalBackgroundColor, *highlightBackgroundColor;

- (id)initWithTopCornersRounded;
- (id)initWithAllCornersRounded;
- (id)initWithBottomCornersRounded;

// additional set up
- (void)setButtonWidth:(CGFloat)width;
- (void)setButtonHeight:(CGFloat)height;
- (void)setButtonFont:(UIFont *)font;
- (void)setButtonAlpha:(CGFloat)alpha;

@end

#pragma mark - SHLActionSheetTitleView

@interface SHLActionSheetTitleView : UIView

@property (nonatomic) UILabel *titleLabel;

@property (nonatomic) UIRectCorner roundingCorners;
@property (nonatomic) CGSize cornerRadiiSize;


- (id)initWithTitle:(NSString *)title font:(UIFont *)font;

// additional set up
- (void)setTitleWidth:(CGFloat)width;
- (void)setTitleHeight:(CGFloat)height;
- (void)setTextColor:(UIColor *)color;
- (void)setTitleAlpha:(CGFloat)alpha;

@end



#pragma mark - SHLActionSheetSeperatorView

@interface SHLActionSheetSeperatorView : UIView

- (id) initWithFrame:(CGRect)frame color:(UIColor*)color;

- (void)setColor:(UIColor*)color;

@end















