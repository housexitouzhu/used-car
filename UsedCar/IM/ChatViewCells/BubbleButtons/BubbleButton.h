//
//  BubbleButton.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-25.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellVGap     (10)
#define kCellHGap     (5)
#define kCellSpaceGap (90)

#define kBubbleHeadGap        (10)
#define kBubbleTailGap        (20)
#define kBubbleVGap           (13)
#define kBubbleHeight_MIN     (40)
#define kBubbleHeight_MAX     MAXFLOAT
#define kBubbleWidth_MIN      (60)
#define kBubbleWidth_MAX      (SCREEN_WIDTH - kCellSpaceGap - kCellHGap*2)
#define kBubbleVoiceWidth_MIN (70)
#define kBubbleImageWidth     (150)
#define kBubbleImageHeight    (115)
#define kBubbleCarWidth       (210)
#define kBubbleCarHeight      (87)

#define kCellDefaultHeight  (kBubbleHeight_MIN + kCellVGap * 2)
#define kCellCarHeight      (kBubbleCarHeight + kCellVGap * 2)
#define kCellImageHeight    (kBubbleImageHeight + kCellVGap * 2)

typedef enum : NSUInteger {
    BubbleTypeLeft,
    BubbleTypeRight,
    BubbleTypeNone
} BubbleType;

@interface BubbleButton : UIButton

@property (nonatomic, assign) BubbleType bubbleType;

@property (nonatomic, strong, readonly) UIImage *bubbleLeft;
@property (nonatomic, strong, readonly) UIImage *bubbleLeftPress;
@property (nonatomic, strong, readonly) UIImage *bubbleRight;
@property (nonatomic, strong, readonly) UIImage *bubbleRightPress;

@property (nonatomic, strong, readonly) UIImage *bubbleInfoLeft;
@property (nonatomic, strong, readonly) UIImage *bubbleInfoLeftPress;
@property (nonatomic, strong, readonly) UIImage *bubbleInfoRight;
@property (nonatomic, strong, readonly) UIImage *bubbleInfoRightPress;

@property (nonatomic, strong, readonly) UIImage *bubbleImageLeft;
@property (nonatomic, strong, readonly) UIImage *bubbleImageRight;


- (id)initWithCustomButtonWithType:(BubbleType)type;

@end
