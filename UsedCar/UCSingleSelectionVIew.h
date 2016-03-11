//
//  UCSingleSelectionVIew.h
//  UsedCar
//
//  Created by 张鑫 on 14-7-9.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UCSingleSelectionViewStyleNone = 100,
    UCSingleSelectionViewStyleX,
    UCSingleSelectionViewStyleY,
} UCSingleSelectionViewStyle;

@protocol UCSingleSelectionViewDelegate;

@interface UCSingleSelectionVIew : UIView

@property (nonatomic, readonly) NSMutableArray *buttonItems;

@property (nonatomic, weak) id<UCSingleSelectionViewDelegate>delegate;

- (id)initWithMarginX:(CGFloat)marginX marginY:(CGFloat)marginY buttonSize:(CGSize)buttonSize singleLineCount:(NSInteger)singleLineCount title:(NSArray *)title images:(NSArray *)images UCSingleSelectionViewStyle:(UCSingleSelectionViewStyle)viewStyle offset:(CGFloat)offset;

@end

@protocol UCSingleSelectionViewDelegate <NSObject>

- (void)UCSingleSelectionView:(UCSingleSelectionVIew *)vSingleSelection didSelectedButton:(UIButton *)btn;

@end
