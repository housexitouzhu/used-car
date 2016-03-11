//
//  SHLActionSheet.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-19.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "SHLActionSheet.h"

#define kDefaultSideGap 8.0
#define kDefaultWidthGap kDefaultSideGap*2
#define kDefaultCornerRadiiSize CGSizeMake(4.0, 4.0)
#define kDefaultRowHeight 44.0
#define kDefaultButtonTextColor [UIColor colorWithRed:0.000 green:0.500 blue:1.000 alpha:1.000]
#define kDefaultButtonTitleFont [UIFont boldSystemFontOfSize:21]
#define kDefaultDestructiveButtonTextColor [UIColor colorWithRed:1.000 green:0.229 blue:0.000 alpha:1.000]
#define kDefaultSeperatorHeight 1.0
#define kDefaultSeperatorRetinaHeight 0.5
#define kDefaultCancelButtonGap 10.0
#define kDefaultBottomGap 10.0
#define kDefaultTransparentAlpha 0.4

#pragma mark - SHLActionSheet
@implementation SHLActionSheet

- (id)init {
    
    self = [self initWithFrame:CGRectZero];
    self.buttonResponse = SHLActionSheetButtonResponseFadesOnPress;
    self.backgroundColor = [UIColor clearColor];
    self.buttons = [[NSMutableArray alloc] init];
    self.seperators = [[NSMutableArray alloc] init];
    self.shouldCancelOnTouch = YES;
    
    self.transparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    self.transparentView.backgroundColor = [UIColor blackColor];
    self.transparentView.alpha = 0.0f;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromView)];
    tap.numberOfTapsRequired = 1;
    [self.transparentView addGestureRecognizer:tap];
    
    return self;
}


- (id)initWithTitle:(NSString *)title delegate:(id<SHLActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelTitle destructiveButtonTitle:(NSString *)destructiveTitle otherButtonTitles:(NSString *)otherTitles, ... {
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    
    if (otherTitles) {
        va_list args;
        va_start(args, otherTitles);
        for (NSString *arg = otherTitles; arg != nil; arg = va_arg(args, NSString* ))
        {
            [titles addObject:arg];
        }
        va_end(args);
    }
    return [self initWithTitle:title delegate:delegate cancelButtonTitle:cancelTitle destructiveButtonTitle:destructiveTitle otherButtonTitlesArray:titles];
}


- (id)initWithTitle:(NSString *)title delegate:(id<SHLActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelTitle destructiveButtonTitle:(NSString *)destructiveTitle otherButtonTitlesArray:(NSArray *)otherTitlesArray {
    
    self = [self init];
    self.delegate = delegate;
    
    NSMutableArray* titles = [otherTitlesArray mutableCopy];
    
    
    if (destructiveTitle) {
        [titles insertObject:destructiveTitle atIndex:0];
        self.hasDestructiveButton = YES;
    } else {
        self.hasDestructiveButton = NO;
    }
    
    // set up cancel button
    if (cancelTitle) {
        SHLActionSheetButton *cancelButton = [[SHLActionSheetButton alloc] initWithAllCornersRounded];
        
        cancelButton.titleLabel.font = kDefaultButtonTitleFont;
        [cancelButton setTitle:cancelTitle forState:UIControlStateAll];
        [self.buttons addObject:cancelButton];
        self.hasCancelButton = YES;
    }
    else {
        self.shouldCancelOnTouch = NO;
        self.hasCancelButton = NO;
    }
    
    switch (titles.count) {
        case 0:
            
            break;
        case 1:
        {
            
            SHLActionSheetButton *onlyButton;
            if (title) {
                onlyButton = [[SHLActionSheetButton alloc] initWithBottomCornersRounded];
            } else {
                onlyButton = [[SHLActionSheetButton alloc] initWithAllCornersRounded];
            }
            
            [onlyButton setTitle:[titles objectAtIndex:0] forState:UIControlStateAll];
            [self.buttons insertObject:onlyButton atIndex:0];
            
        }
            break;
        case 2:
        {
            SHLActionSheetButton *firstButton;
            
            if (title) {
                firstButton = [[SHLActionSheetButton alloc] init];
            } else {
                firstButton = [[SHLActionSheetButton alloc] initWithTopCornersRounded];
            }
            
            [firstButton setTitle:[titles objectAtIndex:0] forState:UIControlStateAll];
            
            SHLActionSheetButton *secondButton = [[SHLActionSheetButton alloc] initWithBottomCornersRounded];
            [secondButton setTitle:[titles objectAtIndex:1] forState:UIControlStateAll];
            
            [self.buttons insertObject:firstButton atIndex:0];
            [self.buttons insertObject:secondButton atIndex:1];
        }
            break;
            
        default:{
            
            SHLActionSheetButton *topButton;
            
            if (title) {
                topButton = [[SHLActionSheetButton alloc] init];
            } else {
                topButton = [[SHLActionSheetButton alloc] initWithTopCornersRounded];
            }
            
            [topButton setTitle:[titles objectAtIndex:0] forState:UIControlStateAll];
            [self.buttons insertObject:topButton atIndex:0];
            
            int whereToStop = titles.count - 1;
            for (int i = 1; i < whereToStop; ++i) {
                SHLActionSheetButton *middleButton = [[SHLActionSheetButton alloc] init];
                [middleButton setTitle:[titles objectAtIndex:i] forState:UIControlStateAll];
                [self.buttons insertObject:middleButton atIndex:i];
            }
            
            SHLActionSheetButton *bottomButton = [[SHLActionSheetButton alloc] initWithBottomCornersRounded];
            [bottomButton setTitle:[titles lastObject] forState:UIControlStateAll];
            
            [self.buttons insertObject:bottomButton atIndex:(titles.count - 1)];
            
        }
            break;
    }
    
    [self setUpTheActions];
    
    if (self.hasDestructiveButton) {
        [[self.buttons objectAtIndex:0] setTextColor:kDefaultDestructiveButtonTextColor];
        [[self.buttons objectAtIndex:0] setOriginalTextColor:kDefaultDestructiveButtonTextColor];
    }
    
    for (int i = 0; i < self.buttons.count; ++i) {
        [[self.buttons objectAtIndex:i] setIndex:i];
    }
    
    if (title) {
        self.title = title;
    } else {
        [self setUpTheActionSheet];
    }
    
    return self;
}

- (void)setUpTheActionSheet {
    
    CGFloat height = 0;
    CGFloat width;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        width = CGRectGetWidth([UIScreen mainScreen].bounds);
    } else {
        width = CGRectGetHeight([UIScreen mainScreen].bounds);
    }
    
    // setup spacing for retina devices
    if (self.hasCancelButton) {
        
        height = kDefaultBottomGap;
        
        if (self.buttonHeight > 0) {
            height += self.buttonHeight;
        }
        else{
            height += kDefaultRowHeight;
        }
        if (self.cancelButtonGap > 0){
            height += self.cancelButtonGap;
        }
        else{
            height += kDefaultCancelButtonGap;
        }
        
        height += .5;
    }
    
    if (self.titleView) {
        if (self.buttonHeight > 0) {
            height += self.buttonHeight;
        }
        else{
            height += kDefaultRowHeight;
        }
        height += 0.5;
    }
    
    if (self.buttons.count) {
        
        if (self.buttonHeight > 0) {
            height += (self.buttons.count * self.buttonHeight);
        }
        else{
            height += (self.buttons.count * kDefaultRowHeight);
        }
        
        if (self.seperatorHeight > 0) {
            height += (self.buttons.count * self.seperatorHeight);
        }
        else{
            height += (self.buttons.count * kDefaultSeperatorRetinaHeight);
        }
    }
    
    self.frame = CGRectMake(0, 0, width, height);
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGPoint pointOfReference = CGPointMake(CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight(self.frame) - 30);
    
    int whereToStop;
    if (self.hasCancelButton) {
        [self addSubview:[self.buttons lastObject]];
        [[self.buttons lastObject] setCenter:pointOfReference];
        [[self.buttons objectAtIndex:0] setCenter:CGPointMake(pointOfReference.x, pointOfReference.y - 52)];
        pointOfReference = CGPointMake(pointOfReference.x, pointOfReference.y - 52);
        whereToStop = self.buttons.count - 2;
    } else {
        [self addSubview:[self.buttons lastObject]];
        [[self.buttons lastObject] setCenter:pointOfReference];
        whereToStop = self.buttons.count - 1;
    }
    
    for (int i = 0, j = whereToStop; i <= whereToStop; ++i, --j) {
        [self addSubview:[self.buttons objectAtIndex:i]];
        [[self.buttons objectAtIndex:i] setCenter:CGPointMake(pointOfReference.x, pointOfReference.y - ((kDefaultRowHeight + kDefaultSeperatorRetinaHeight) * j))];
    }
    
    if (self.titleView) {
        [self addSubview:self.titleView];
        self.titleView.center = CGPointMake(self.center.x, CGRectGetHeight(self.titleView.frame) / 2.0);
    }
    
}

- (void)setUpTheActions {
    
    for (SHLActionSheetButton *button in self.buttons) {
        if ([button isKindOfClass:[SHLActionSheetButton class]]) {
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(highlightPressedButton:) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(unhighlightPressedButton:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
        }
    }
}

- (void)highlightPressedButton:(SHLActionSheetButton *)button {
    
    [UIView animateWithDuration:0.15f
                     animations:^() {
                         
                         if (self.buttonResponse == SHLActionSheetButtonResponseFadesOnPress) {
                             button.alpha = .80f;
                         } else if (self.buttonResponse == SHLActionSheetButtonResponseShrinksOnPress) {
                             button.transform = CGAffineTransformMakeScale(.98, .95);
                         } else if (self.buttonResponse == SHLActionSheetButtonResponseHighlightsOnPress) {
                             button.backgroundColor = button.highlightBackgroundColor;
                             [button setTitleColor:button.highlightTextColor forState:UIControlStateAll];
                             
                         } else {
                             
                             UIColor *tempColor = button.titleLabel.textColor;
                             [button setTitleColor:button.backgroundColor forState:UIControlStateAll];
                             button.backgroundColor = tempColor;
                         }
                         
                     }];
}

- (void)unhighlightPressedButton:(SHLActionSheetButton *)button {
    
    [UIView animateWithDuration:0.3f
                     animations:^() {
                         
                         if (self.buttonResponse == SHLActionSheetButtonResponseFadesOnPress) {
                             button.alpha = .95f;
                         } else if( self.buttonResponse == SHLActionSheetButtonResponseShrinksOnPress) {
                             button.transform = CGAffineTransformMakeScale(1, 1);
                         } else  if (self.buttonResponse == SHLActionSheetButtonResponseHighlightsOnPress) {
                             button.backgroundColor = button.originalBackgroundColor;
                             [button setTitleColor:button.originalTextColor forState:UIControlStateAll];
                         } else {
                             UIColor *tempColor = button.backgroundColor;
                             button.backgroundColor = button.titleLabel.textColor;
                             [button setTitleColor:tempColor forState:UIControlStateAll];
                         }
                     }];
    
}

#pragma mark IBActionSheet Helpful methods

- (NSInteger)addButtonWithTitle:(NSString *)title {
    
    int index = self.buttons.count;
    
    if (self.hasCancelButton) {
        index -= 1;
    }
    
    SHLActionSheetButton *button;
    
    if ((self.buttons.count == 1 && self.hasCancelButton && !self.titleView) || (self.buttons.count == 0 && !self.titleView))
        button = [[SHLActionSheetButton alloc] initWithAllCornersRounded];
    else
        button = [[SHLActionSheetButton alloc] initWithBottomCornersRounded];
    
    [button setTitle:title forState:UIControlStateAll];
    
    button.index = index;
    
    if (self.hasCancelButton) {
        
        // update the cancel button with its new index
        [self.buttons insertObject:button atIndex:index];
        SHLActionSheetButton *cancelButton = [self.buttons lastObject];
        cancelButton.index += 1;
        [self.buttons replaceObjectAtIndex:(index + 1) withObject:cancelButton];
        
        SHLActionSheetButton *tempButton;
        SHLActionSheetButton *theButtonToCopy;
        
        if (self.buttons.count == 3) {
            if (self.titleView) {
                tempButton = [[SHLActionSheetButton alloc] init];
            } else {
                tempButton = [[SHLActionSheetButton alloc] initWithTopCornersRounded];
            }
            
            theButtonToCopy = [self.buttons objectAtIndex:0];
            tempButton.index = theButtonToCopy.index;
            [tempButton setTitle:theButtonToCopy.titleLabel.text forState:UIControlStateAll];
            
            [self.buttons replaceObjectAtIndex:0 withObject:tempButton];
            [self setButtonTextColor:theButtonToCopy.titleLabel.textColor forButtonAtIndex:0];
            [self setButtonBackgroundColor:theButtonToCopy.backgroundColor forButtonAtIndex:0];
            
        } else if (self.buttons.count > 2) {
            
            tempButton = [[SHLActionSheetButton alloc] init];
            theButtonToCopy = [self.buttons objectAtIndex:(index - 1)];
            [tempButton setTitle:theButtonToCopy.titleLabel.text forState:UIControlStateAll];
            tempButton.titleLabel.text = theButtonToCopy.titleLabel.text;
            tempButton.index = theButtonToCopy.index;
            
            [self.buttons replaceObjectAtIndex:(index - 1) withObject:tempButton];
            [self setButtonTextColor:theButtonToCopy.titleLabel.textColor forButtonAtIndex:(index - 1)];
            [self setButtonBackgroundColor:theButtonToCopy.backgroundColor forButtonAtIndex:(index - 1)];
        }
    } else {
        
        button.index = self.buttons.count;
        [self.buttons addObject:button];
        
        
        if (self.buttons.count == 3) {
            
            SHLActionSheetButton *theButtonToCopy = [self.buttons objectAtIndex:0];
            SHLActionSheetButton *tempButton;
            
            if (self.titleView)
                tempButton = [[SHLActionSheetButton alloc] init];
            else
                tempButton = [[SHLActionSheetButton alloc] initWithTopCornersRounded];
            
            [tempButton setTitle:theButtonToCopy.titleLabel.text forState:UIControlStateAll];
            tempButton.titleLabel.text = theButtonToCopy.titleLabel.text;
            tempButton.index = theButtonToCopy.index;
            
            [self.buttons replaceObjectAtIndex:tempButton.index withObject:tempButton];
        }
        
        if (self.buttons.count >= 2) {
            
            SHLActionSheetButton *theButtonToCopy;
            
            if (self.buttons.count == 2 && !self.hasCancelButton)
                theButtonToCopy = [self.buttons objectAtIndex:index - 1];
            else
                theButtonToCopy = [self.buttons objectAtIndex:index];
            SHLActionSheetButton *tempButton;
            
            if (self.titleView || self.buttons.count > 2)
                tempButton = [[SHLActionSheetButton alloc] init];
            else
                tempButton = [[SHLActionSheetButton alloc] initWithTopCornersRounded];
            
            [tempButton setTitle:theButtonToCopy.titleLabel.text forState:UIControlStateAll];
            tempButton.titleLabel.text = theButtonToCopy.titleLabel.text;
            tempButton.index = theButtonToCopy.index;
            
            [self.buttons replaceObjectAtIndex:tempButton.index withObject:tempButton];
            
        }
        
        
    }
    
    [self setUpTheActions];
    [self setUpTheActionSheet];
    
    return index;
}

- (void)buttonClicked:(SHLActionSheetButton *)button {
    
    [self.delegate actionSheet:self clickedButtonAtIndex:button.index];
    self.shouldCancelOnTouch = YES;
    [self removeFromView];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    
    if (!animated) {
        [self.transparentView removeFromSuperview];
        [self removeFromSuperview];
        self.visible = NO;
        [self.delegate actionSheet:self clickedButtonAtIndex:buttonIndex];
    } else {
        [self removeFromView];
        [self.delegate actionSheet:self clickedButtonAtIndex:buttonIndex];
    }
}

- (void)showInView:(UIView *)theView {
    
    [theView addSubview:self];
    [theView insertSubview:self.transparentView belowSubview:self];
    
    CGRect theScreenRect = [UIScreen mainScreen].bounds;
    
    float height;
    float x;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        height = CGRectGetHeight(theScreenRect);
        x = CGRectGetWidth(theView.frame) / 2.0;
        self.transparentView.frame = CGRectMake(self.transparentView.center.x, self.transparentView.center.y, CGRectGetWidth(theScreenRect), CGRectGetHeight(theScreenRect));
    } else {
        height = CGRectGetWidth(theScreenRect);
        x = CGRectGetHeight(theView.frame) / 2.0;
        self.transparentView.frame = CGRectMake(self.transparentView.center.x, self.transparentView.center.y, CGRectGetHeight(theScreenRect), CGRectGetWidth(theScreenRect));
    }
    
    self.center = CGPointMake(x, height + CGRectGetHeight(self.frame) / 2.0);
    self.transparentView.center = CGPointMake(x, height / 2.0);
    
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        
        
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^() {
                             if (self.tranparentViewAlpha) {
                                 self.transparentView.alpha = self.tranparentViewAlpha;
                             }
                             else{
                                 self.transparentView.alpha = kDefaultTransparentAlpha;
                             }
                             self.center = CGPointMake(x, (height - 20) - CGRectGetHeight(self.frame) / 2.0);
                             
                         } completion:^(BOOL finished) {
                             self.visible = YES;
                         }];
    } else {
        
        [UIView animateWithDuration:0.5f
                              delay:0
             usingSpringWithDamping:0.6f
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             if (self.tranparentViewAlpha) {
                                 self.transparentView.alpha = self.tranparentViewAlpha;
                             }
                             else{
                                 self.transparentView.alpha = kDefaultTransparentAlpha;
                             }
                             self.center = CGPointMake(x, height - CGRectGetHeight(self.frame) / 2.0);
                             
                         } completion:^(BOOL finished) {
                             self.visible = YES;
                         }];
    }
}

- (void)removeFromView {
    
    if (self.shouldCancelOnTouch) {
        
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            
            
            [UIView animateWithDuration:0.2f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^() {
                                 self.transparentView.alpha = 0.0f;
                                 self.center = CGPointMake(CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight([UIScreen mainScreen].bounds) + CGRectGetHeight(self.frame) / 2.0);
                                 
                             } completion:^(BOOL finished) {
                                 [self.transparentView removeFromSuperview];
                                 [self removeFromSuperview];
                                 self.visible = NO;
                             }];
        } else {
            
            [UIView animateWithDuration:0.5f
                                  delay:0
                 usingSpringWithDamping:0.6f
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 self.transparentView.alpha = 0.0f;
                                 self.center = CGPointMake(CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight([UIScreen mainScreen].bounds) + CGRectGetHeight(self.frame) / 2.0);
                                 
                             } completion:^(BOOL finished) {
                                 [self.transparentView removeFromSuperview];
                                 [self removeFromSuperview];
                                 self.visible = NO;
                             }];
        }
        
    }
    
}


#pragma mark IBActionSheet Color methods

- (void)setButtonTextColor:(UIColor *)color {
    
    for (SHLActionSheetButton *button in self.buttons) {
        [button setTitleColor:color forState:UIControlStateAll];
        button.originalTextColor = color;
    }
    
    [self setTitleTextColor:color];
}

- (void)setButtonBackgroundColor:(UIColor *)color {
    
    for (SHLActionSheetButton *button in self.buttons) {
        button.backgroundColor = color;
        button.originalBackgroundColor = color;
    }
    
    [self setTitleBackgroundColor:color];
}

- (void)setTitleTextColor:(UIColor *)color {
    self.titleView.titleLabel.textColor = color;
}

- (void)setTitleBackgroundColor:(UIColor *)color {
    self.titleView.backgroundColor = color;
}

- (void)setTextColor:(UIColor *)color ForButton:(SHLActionSheetButton *)button {
    [button setTitleColor:color forState:UIControlStateAll];
}

- (void)setButtonBackgroundColor:(UIColor *)color forButtonAtIndex:(NSInteger)index {
    [[self.buttons objectAtIndex:index] setBackgroundColor:color];
}

- (void)setButtonTextColor:(UIColor *)color forButtonAtIndex:(NSInteger)index {
    [self setTextColor:color ForButton:[self.buttons objectAtIndex:index]];
}

- (UIColor *)buttonBackgroundColorAtIndex:(NSInteger)index {
    return [[self.buttons objectAtIndex:index] backgroundColor];
}

- (UIColor *)buttonTextColorAtIndex:(NSInteger)index {
    return [[[self.buttons objectAtIndex:index] titleLabel] textColor];
}

- (void)setButtonHighlightBackgroundColor:(UIColor *)color {
    for (SHLActionSheetButton *button in self.buttons) {
        button.highlightBackgroundColor = color;
    }
}

- (void)setButtonHighlightBackgroundColor:(UIColor *)color forButtonAtIndex:(NSInteger)index {
    [[self.buttons objectAtIndex:index] setHighlightBackgroundColor:color];
}

- (void)setButtonHighlightTextColor:(UIColor *)color {
    for (SHLActionSheetButton *button in self.buttons) {
        button.highlightTextColor = color;
    }
}

- (void)setButtonHighlightTextColor:(UIColor *)color forButtonAtIndex:(NSInteger)index {
    [[self.buttons objectAtIndex:index] setHighlightTextColor:color];
}

#pragma mark - Additional Set up
- (void)setButtonAlpha:(CGFloat)buttonAlpha{
    _buttonAlpha = buttonAlpha;
    for (SHLActionSheetButton *button in self.buttons) {
        button.alpha = buttonAlpha;
    }
}


#pragma mark IBActionSheet Other Properties methods

- (void)setTitle:(NSString *)title {
    self.titleView = [[SHLActionSheetTitleView alloc] initWithTitle:title font:nil];
    [self setUpTheActionSheet];
}

- (NSString *)buttonTitleAtIndex:(NSInteger)index {
    return [[[self.buttons objectAtIndex:index] titleLabel] text];
}

- (NSInteger)numberOfButtons {
    return self.buttons.count;
}

- (void)setFont:(UIFont *)font {
    for (SHLActionSheetButton *button in self.buttons) {
        [self setFont:font forButton:button];
    }
    
    [self setTitleFont:font];
}

- (void)setFont:(UIFont *)font forButtonAtIndex:(NSInteger)index {
    [[[self.buttons objectAtIndex:index] titleLabel] setFont:font];
}

- (void)setFont:(UIFont *)font forButton:(SHLActionSheetButton *)button {
    button.titleLabel.font = font;
}

- (void)setTitleFont:(UIFont *)font {
    if (self.titleView) {
        UIColor *backgroundColor = self.titleView.backgroundColor;
        UIColor *textColor = self.titleView.titleLabel.textColor;
        self.titleView = [[SHLActionSheetTitleView alloc] initWithTitle:self.titleView.titleLabel.text font:font];
        self.titleView.backgroundColor = backgroundColor;
        self.titleView.titleLabel.textColor = textColor;
        [self setUpTheActionSheet];
    }
}

- (void)setButtonWidth:(CGFloat)buttonWidth{
    //TODO
}

- (void)setButtonWidth:(CGFloat)buttonWidth forButtonAtIndex:(NSInteger)index{
    
}

- (void)setButtonHeight:(CGFloat)buttonHeight{
    
}

- (void)setButtonHeight:(CGFloat)buttonHeight forButtonAtIndex:(NSInteger)index{
    
}

@end

#pragma mark - SHLActionSheetButton
@implementation SHLActionSheetButton

- (id)initWithTopCornersRounded {
    self = [self init];
    [self setMaskTo:self byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerSize:kDefaultCornerRadiiSize];
    self.cornerType = SHLActionSheetButtonCornerTypeTopCornersRounded;
    self.roundingCorners = UIRectCornerTopLeft | UIRectCornerTopRight;
    self.cornerRadiiSize = kDefaultCornerRadiiSize;
    return self;
}

- (id)initWithBottomCornersRounded {
    self = [self init];
    [self setMaskTo:self byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerSize:kDefaultCornerRadiiSize];
    self.cornerType = SHLActionSheetButtonCornerTypeBottomCornersRounded;
    self.roundingCorners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    self.cornerRadiiSize = kDefaultCornerRadiiSize;
    return self;
}

- (id)initWithAllCornersRounded {
    self = [self init];
    [self setMaskTo:self byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerSize:kDefaultCornerRadiiSize];
    self.cornerType = SHLActionSheetButtonCornerTypeAllCornersRounded;
    self.roundingCorners = UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight;
    self.cornerRadiiSize = kDefaultCornerRadiiSize;
    return self;
}


- (id)init {
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    self = [self initWithFrame:CGRectMake(0, 0, width - kDefaultWidthGap, kDefaultRowHeight)];
    
    if (self) {
        self.buttonWidth = width - kDefaultWidthGap;
        self.buttonHeight = kDefaultRowHeight;
        
        self.backgroundColor = [UIColor whiteColor];
        self.originalTextColor = self.backgroundColor;
        self.highlightBackgroundColor = [UIColor whiteColor];
        
        self.buttonFont = self.titleLabel.font = [UIFont systemFontOfSize:21];
        
        [self setTitleColor:kDefaultButtonTextColor forState:UIControlStateAll];
        self.originalTextColor = kDefaultButtonTextColor;
        self.highlightTextColor = kDefaultButtonTextColor;
        self.buttonAlpha = self.alpha = 0.95f;
        
        self.cornerType = SHLActionSheetButtonCornerTypeNoCornersRounded;
    }
    
    return self;
}

// set up properties
- (void)setRoundingCorners:(UIRectCorner)roundingCorners{
    _roundingCorners = roundingCorners;
    [self setMaskTo:self byRoundingCorners:roundingCorners cornerSize:self.cornerRadiiSize];
}

- (void)setCornerRadiiSize:(CGSize)cornerRadiiSize{
    _cornerRadiiSize = cornerRadiiSize;
    [self setMaskTo:self byRoundingCorners:self.roundingCorners cornerSize:cornerRadiiSize];
}

- (void)setOriginalTextColor:(UIColor *)color {
    _originalTextColor = color;
    [self setTitleColor:color forState:UIControlStateNormal];
}

- (void)setHighlightTextColor:(UIColor *)color{
    _highlightTextColor = color;
    [self setTitleColor:color forState:UIControlStateSelected];
    [self setTitleColor:color forState:UIControlStateHighlighted];
}

- (void)setOriginalBackgroundColor:(UIColor *)color{
    _originalBackgroundColor = color;
    [self setBackgroundColor:color];
}

// additional set up
- (void)setButtonWidth:(CGFloat)width{
    CGRect newframe = self.frame;
    newframe.size.width = width;
    [self setFrame:newframe];
}

- (void)setButtonHeight:(CGFloat)height{
    CGRect newframe = self.frame;
    newframe.size.height = height;
    [self setFrame: newframe];
}

- (void)setButtonFont:(UIFont *)font{
    [self.titleLabel setFont:font];
}

- (void)setButtonAlpha:(CGFloat)alpha{
    [self setAlpha:alpha];
}

- (void)setMaskTo:(UIView*)view byRoundingCorners:(UIRectCorner)corners cornerSize:(CGSize)cornerRadiiSize
{
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                  byRoundingCorners:corners
                                                        cornerRadii:cornerRadiiSize];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    view.layer.mask = shape;
}

@end


#pragma mark - SHLActionSheetTitleView
@implementation SHLActionSheetTitleView

- (id)initWithTitle:(NSString *)title font:(UIFont *)font{
    self = [super init];
    
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    self.alpha = 0.95;
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, kDefaultRowHeight)];
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = title;
    self.titleLabel.numberOfLines = 1;
    
    if (font) {
        self.titleLabel.font = font;
    }
    else{
        self.titleLabel.font = [UIFont systemFontOfSize:12];
    }
    
    [self.titleLabel sizeToFit];
    
    CGRect titleFrame  = self.titleLabel.frame;
    CGFloat height = (CGRectGetHeight(titleFrame) + 30);
    
    if (height < kDefaultRowHeight) {
        self.frame = CGRectMake(0, 0, width - kDefaultWidthGap, kDefaultRowHeight);
    }
    else{
        self.frame = CGRectMake(0, 0, width - kDefaultWidthGap, height);
    }
    
    self.roundingCorners = UIRectCornerTopLeft | UIRectCornerTopRight;
    self.cornerRadiiSize = kDefaultCornerRadiiSize;
    [self setMaskTo:self byRoundingCorners:self.roundingCorners cornerSize:self.cornerRadiiSize];
    
    [self addSubview:self.titleLabel];
    self.titleLabel.center = self.center;
    
    return self;
}

- (void)setRoundingCorners:(UIRectCorner)roundingCorners{
    _roundingCorners = roundingCorners;
    [self setMaskTo:self byRoundingCorners:roundingCorners cornerSize:self.cornerRadiiSize];
}

- (void)setCornerRadiiSize:(CGSize)cornerRadiiSize{
    _cornerRadiiSize = cornerRadiiSize;
    [self setMaskTo:self byRoundingCorners:self.roundingCorners cornerSize:cornerRadiiSize];
}

- (void)setTitleAlpha:(CGFloat)alpha{
    self.alpha = alpha;
}

- (void)setTitleWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    [self setFrame:frame];
    [self.titleLabel setCenter:self.center];
}

- (void)setTitleHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height= height;
    [self setFrame:frame];
    [self.titleLabel setCenter:self.center];
}

- (void)setTextColor:(UIColor *)color{
    self.titleLabel.textColor = color;
}

- (void)setMaskTo:(UIView*)view byRoundingCorners:(UIRectCorner)corners cornerSize:(CGSize)cornerRadiiSize
{
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                  byRoundingCorners:corners
                                                        cornerRadii:cornerRadiiSize];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    view.layer.mask = shape;
}

@end


#pragma mark - SHLActionSheetSeperatorView

@implementation SHLActionSheetSeperatorView

- (id) initWithFrame:(CGRect)frame color:(UIColor*)color{
    self = [super initWithFrame:frame];
    if (self) {
        if (color) {
            self.backgroundColor = color;
        }
        else{
            self.backgroundColor = [UIColor clearColor];
        }
    }
    return self;
}

- (void)setColor:(UIColor*)color{
    self.backgroundColor = color;
}

@end



// WARNING 原方法, 暂时取消, 暂不支持 iPad2
//- (void)setUpTheActionSheet {
//
//    float height;
//    float width;
//
//    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
//        width = CGRectGetWidth([UIScreen mainScreen].bounds);
//    } else {
//        width = CGRectGetHeight([UIScreen mainScreen].bounds);
//    }
//
//
//    // slight adjustment to take into account non-retina devices
//    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
//        && [[UIScreen mainScreen] scale] == 2.0) {
//
//        // setup spacing for retina devices
//        if (self.hasCancelButton) {
//            height = 59.5;
//        } else if (!self.hasCancelButton && self.titleView) {
//            height = 52.0;
//        } else {
//            height = 104.0;
//        }
//
//        if (self.buttons.count) {
//            height += (self.buttons.count * 44.5);
//        }
//        if (self.titleView) {
//            height += CGRectGetHeight(self.titleView.frame) - 44;
//        }
//
//        self.frame = CGRectMake(0, 0, width, height);
//        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//
//        CGPoint pointOfReference = CGPointMake(CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight(self.frame) - 30);
//
//        int whereToStop;
//        if (self.hasCancelButton) {
//            [self addSubview:[self.buttons lastObject]];
//            [[self.buttons lastObject] setCenter:pointOfReference];
//            [[self.buttons objectAtIndex:0] setCenter:CGPointMake(pointOfReference.x, pointOfReference.y - 52)];
//            pointOfReference = CGPointMake(pointOfReference.x, pointOfReference.y - 52);
//            whereToStop = self.buttons.count - 2;
//        } else {
//            [self addSubview:[self.buttons lastObject]];
//            [[self.buttons lastObject] setCenter:pointOfReference];
//            whereToStop = self.buttons.count - 1;
//        }
//
//        for (int i = 0, j = whereToStop; i <= whereToStop; ++i, --j) {
//            [self addSubview:[self.buttons objectAtIndex:i]];
//            [[self.buttons objectAtIndex:i] setCenter:CGPointMake(pointOfReference.x, pointOfReference.y - (44.5 * j))];
//        }
//
//        if (self.titleView) {
//            [self addSubview:self.titleView];
//            self.titleView.center = CGPointMake(self.center.x, CGRectGetHeight(self.titleView.frame) / 2.0);
//        }
//
//    } else {
//
//        // setup spacing for non-retina devices
//
//        if (self.hasCancelButton) {
//            height = 60.0;
//        } else {
//            height = 104.0;
//        }
//
//        if (self.buttons.count) {
//            height += (self.buttons.count * 45);
//        }
//        if (self.titleView) {
//            height += CGRectGetHeight(self.titleView.frame) - 45;
//        }
//
//        self.frame = CGRectMake(0, 0, width, height);
//        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//
//        CGPoint pointOfReference = CGPointMake(CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight(self.frame) - 30);
//
//        int whereToStop;
//        if (self.hasCancelButton) {
//            [self addSubview:[self.buttons lastObject]];
//            [[self.buttons lastObject] setCenter:pointOfReference];
//            [[self.buttons objectAtIndex:0] setCenter:CGPointMake(pointOfReference.x, pointOfReference.y - 52)];
//            pointOfReference = CGPointMake(pointOfReference.x, pointOfReference.y - 52);
//            whereToStop = self.buttons.count - 2;
//        } else {
//            [self addSubview:[self.buttons lastObject]];
//            [[self.buttons lastObject] setCenter:pointOfReference];
//            whereToStop = self.buttons.count - 1;
//        }
//
//        for (int i = 0, j = whereToStop; i <= whereToStop; ++i, --j) {
//            [self addSubview:[self.buttons objectAtIndex:i]];
//            [[self.buttons objectAtIndex:i] setCenter:CGPointMake(pointOfReference.x, pointOfReference.y - (45 * j))];
//        }
//
//        if (self.titleView) {
//            [self addSubview:self.titleView];
//            self.titleView.center = CGPointMake(self.center.x, CGRectGetHeight(self.titleView.frame) / 2.0);
//        }
//    }
//
//}
//
//- (void)setUpTheActions {
//
//    for (IBActionSheetButton *button in self.buttons) {
//        if ([button isKindOfClass:[IBActionSheetButton class]]) {
//            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
//            [button addTarget:self action:@selector(highlightPressedButton:) forControlEvents:UIControlEventTouchDown];
//            [button addTarget:self action:@selector(unhighlightPressedButton:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
//        }
//    }
//}


