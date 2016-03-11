//
//  JPickRangeSlider.h
//  JPickRangeSlider
//
//  Created by jun on 3/14/14.
//  Copyright (c) 2014 Junkor. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kDefault_Boundary_Width (18.0)

#define kDefault_Top_Margin (30)

#define kDefault_Thumb_Y_OffSet (20.0)  // 箭头离刻度尺的距离

#define kDefault_Thumb_Width (44.0)
#define kDefault_Thumb_Height (47.0)
#define kDefault_Thumb_Size ((CGSize){kDefault_Thumb_Width,kDefault_Thumb_Height})

#define kDefault_Thumb_Margin (0)
#define kDefault_Thumb_Top_Margin (5)

#define kDefault_Min_Height (60)
#define kDefault_Index_Min_Margin (kDefault_Thumb_Width)
#define kDefault_IndexLabel_Height (16)
#define kDefault_IndexLabel_Font ([UIFont systemFontOfSize:9])
#define kDefault_BubbleLabel_Font ([UIFont systemFontOfSize:9])

#define kDefault_BubbleFadeDuration (0.15)

#define kDefault_IntervalView_TopMargin (15)
#define kDefault_IntervalView_Height (5)

#define kLeftCalculateEdageX (kDefault_Thumb_Margin+kDefault_Thumb_Width*0.5+kDefault_Boundary_Width)


typedef enum
{
    eLastSelectedTag_NONE = 0,
    eLastSelectedTag_LEFT = 1,      //左按钮
    eLastSelectedTag_RIGHT = 2,     //右按钮
    eLastSelectedTag_MIDDLE = 3,    //价格区间
}ELastSelectedTag;

@interface JPickRangeSlider : UIControl

/**
 *  @property   indexTexts : use to show values Text
 *  @abstract   will create index point by the count of values
 */
@property (nonatomic,strong) NSArray *indexTexts;

@property (nonatomic,strong) NSArray *indexValues;

/**
 *  @property
 *  @abstract  left picker's index
 */
@property (nonatomic,assign) float leftValue;

/**
 *  @property
 *  @abstract  right picker's index
 */
@property (nonatomic,assign) float rightValue;

/**
 *  @property
 *  @abstract  最小间隔距离
 */
@property (nonatomic,assign) float autoMoveValue;

@property (nonatomic,assign) float minValue;
@property (nonatomic,assign) float maxValue;

/**
 *  @property
 *  @abstract  custom image of thumbs
 */
@property (nonatomic,strong) UIImage *thumbImage;

/**
 *  @property
 *  @abstract  不限价格
 */
@property (nonatomic,assign) BOOL isPriceAll;

@property (nonatomic,assign) ELastSelectedTag selectedTag;

- (id) initWithFrame:(CGRect)frame indexValues:(NSArray *)values andIndexTexts:(NSArray *)texts;

- (void) moveThumbToMinPrice:(float)min andMaxPrice:(float)max;

- (void) resetToPriceAll;

@end
