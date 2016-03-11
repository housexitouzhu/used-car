//
//  JPickRangeSlider.m
//  JPickRangeSlider
//
//  Created by jun on 3/14/14.
//  Copyright (c) 2014 Junkor. All rights reserved.
//

#import "JPickRangeSlider.h"
#import "UIView+ViewFrameGeometry.h"
#import "OMG.h"

#define kBubbleHeight (25)
#define kBubbleSize ((CGSize){22,kBubbleHeight})
#define kCalibrationHeight (25)

#define COLOR_iOS7_BLUE [UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0]

@interface JPickRangeSlider ()

@property (nonatomic,strong) UIButton *leftThumb;
@property (nonatomic,strong) UIButton *rightThumb;

@property (nonatomic,assign) float mostLeft;    // min thumb's center's x
@property (nonatomic,assign) float mostRight;   // max thumb's center's x

@property (nonatomic,strong) NSArray *indexLocations;
@property (nonatomic,strong) NSArray *topIndexLabels;
@property (nonatomic,strong) NSArray *bottomIndexLabels;

@property (nonatomic,strong) UIImageView *bubbleBg;
@property (nonatomic,strong) UILabel *bubbleLabel;

@property (nonatomic,strong) UIImageView *intervalView;

@property (nonatomic,assign) float indexMargin;

@end

@implementation JPickRangeSlider

- (BOOL)isPriceAll
{
    if (_leftValue < _minValue && _rightValue > _maxValue) {
        return YES;
    }
    return NO;
}

- (id)initWithFrame:(CGRect)frame indexValues:(NSArray *)values andIndexTexts:(NSArray *)texts
{
    self = [super initWithFrame:frame];
    if (self && texts)
    {
        self.backgroundColor = [UIColor clearColor];
        _indexTexts = texts;
        _indexValues = values;
        [self setup];
    }
    return self;
}

- (void)setup
{
    NSUInteger count = self.indexTexts.count;
    if (count <= 1) {
        return;
    }
    
    UIImageView *calibrationImageView = [[UIImageView alloc] initWithFrame:(CGRect){8,0,self.width-16,kCalibrationHeight}];
    calibrationImageView.image = [UIImage imageNamed:@"kedu"];
    calibrationImageView.center = (CGPoint){calibrationImageView.center.x,kDefault_Top_Margin};
    [self addSubview:calibrationImageView];
    
    float indexMargin = (self.width - kDefault_Thumb_Margin*2 - kDefault_Thumb_Width-kDefault_Boundary_Width*2)/(count-1);
    self.indexMargin = indexMargin;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapRecognizer];
    
    // selected interval background view
    UIImageView *intervalView = [[UIImageView alloc] init];
    intervalView.image = [[UIImage imageNamed:@"lvtiao"] stretchableImageWithLeftCapWidth:5 topCapHeight:2];
    [self addSubview:intervalView];
    self.intervalView = intervalView;
    
    UIButton *leftThumb = [[UIButton alloc] initWithFrame:(CGRect){CGPointZero,kDefault_Thumb_Size}];
    UIImage *leftImage = [UIImage imageNamed:@"xiabashou"];
    [leftThumb setImage:leftImage forState:UIControlStateNormal];
    [leftThumb setImage:leftImage forState:UIControlStateHighlighted];
    [self addSubview:leftThumb];
    self.leftThumb = leftThumb;
    
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    [leftThumb addGestureRecognizer:leftPan];
    
    UIButton *rightThumb = [[UIButton alloc] initWithFrame:(CGRect){CGPointZero,kDefault_Thumb_Size}];
    [rightThumb setImage:leftImage forState:UIControlStateNormal];
    [rightThumb setImage:leftImage forState:UIControlStateHighlighted];
    [self addSubview:rightThumb];
    self.rightThumb = rightThumb;
    
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
    [rightThumb addGestureRecognizer:rightPan];
    
    UIImageView *bubbleBg = [[UIImageView alloc] initWithFrame:(CGRect){0,-25,kBubbleSize}];
    bubbleBg.image = [UIImage imageNamed:@"bubble"];
    [self addSubview:bubbleBg];
    bubbleBg.alpha = 0;
    bubbleBg.hidden = YES;              // 默认是隐藏的
    self.bubbleBg = bubbleBg;
    
    UILabel *bubbleLabel = [[UILabel alloc] initWithFrame:bubbleBg.bounds];
    bubbleLabel.backgroundColor = [UIColor clearColor];
    bubbleLabel.font = kDefault_BubbleLabel_Font;
    bubbleLabel.textAlignment = NSTextAlignmentCenter;
    bubbleLabel.textColor = [UIColor whiteColor];
    [bubbleBg addSubview:bubbleLabel];
    self.bubbleLabel = bubbleLabel;
    
    [self initIndexLabels];
}

- (void)initIndexLabels
{
    NSMutableArray *indexLocations = [NSMutableArray array];
    NSMutableArray *topIndexLabels = [NSMutableArray array];
    NSMutableArray *bottomIndexLabels = [NSMutableArray array];
    
    float pointX = kLeftCalculateEdageX;    // x location
    float pointY = kDefault_Top_Margin;   // y location
    
    float labelX = kLeftCalculateEdageX;
    
    for (int i = 0; i<self.indexValues.count; i++)
    {
        UILabel *topLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero,50,20}];
        topLabel.center = (CGPoint){labelX+i*self.indexMargin,pointY-16};
        topLabel.backgroundColor = [UIColor clearColor];
        topLabel.font = kDefault_IndexLabel_Font;
        topLabel.text = self.indexTexts[i];
        topLabel.textAlignment = NSTextAlignmentCenter;
        topLabel.textColor = kColorNewGray2;
        [self addSubview:topLabel];
        [topIndexLabels addObject:topLabel];
        
        // calculate the index's location point
        [indexLocations addObject:[NSValue valueWithCGPoint:(CGPoint){pointX+i*self.indexMargin,pointY}]];
    }
    self.topIndexLabels = topIndexLabels;
    self.bottomIndexLabels = bottomIndexLabels;
    self.indexLocations = indexLocations;
    
    CGPoint startPoint = [self.indexLocations[0] CGPointValue];
    CGPoint endPoint = [[self.indexLocations lastObject] CGPointValue];
    self.mostLeft = startPoint.x - kDefault_Boundary_Width;
    self.mostRight = endPoint.x + kDefault_Boundary_Width;
    
    [self bringSubviewToFront:self.bubbleBg];
    
    [self resetToPriceAll];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self];
    
//    NSLog(@" point : %@ ",NSStringFromCGPoint(point));
    if (point.y > kDefault_Top_Margin-25 && point.y < kDefault_Top_Margin+25)
    {
        for (int i = 0; i< self.indexLocations.count; i++)
        {
            CGPoint left = [self.indexLocations[i] CGPointValue];
            CGPoint right = CGPointZero;
            if (i < self.indexLocations.count-1)
            {
                right = [self.indexLocations[i+1] CGPointValue];
            }
            
            if (i == 0 && point.x < left.x)
            {
                [self moveThumbToLeftIndex:-1 rightIndex:0];    // 最左端
                [self callTapEvent];
                break;
            }
            else if (i == self.indexLocations.count-1 && point.x > right.x)
            {
                [self moveThumbToLeftIndex:i rightIndex:i+1];
                [self callTapEvent];
                break;
            }
            else if (point.x > left.x && point.x < right.x)
            {
//                NSLog(@" index : %d ",i);
                [self moveThumbToLeftIndex:i rightIndex:i+1];
                [self callTapEvent];
                break;
            }
        }
    }
}

- (void) callTapEvent
{
    self.selectedTag = eLastSelectedTag_MIDDLE;
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void) moveThumbToMinPrice:(float)min andMaxPrice:(float)max
{
    if (min == 0 && max == 0) {
        [self resetToPriceAll];
        return;
    }else if (min>0 && max==0){
        max = self.maxValue+1;
    }else if (min==0 && max > 0){
        min = self.minValue-1;
    }
    
    float leftX = [self xLocationForValue:min];
    float rightX = [self xLocationForValue:max];
    
    if (min<self.minValue)
    {
        [self moveLeftThumbToMostLeft];
    }else{
        self.leftThumb.center = (CGPoint){leftX,self.leftThumb.center.y};
        self.leftValue = min;
    }
    
    if (max>self.maxValue)
    {
        [self moveRightThumbToMostRight];
    }else{
        self.rightThumb.center = (CGPoint){rightX,self.rightThumb.center.y};
        self.rightValue = max;
    }
    
    [self relocateIntervalView];
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
}

- (void) moveThumbToLeftIndex:(int)leftIndex rightIndex:(int)rightIndex
{
    [self moveLeftThumbToIndex:leftIndex];
    [self moveRightThumbToIndex:rightIndex];
    [self relocateIntervalView];
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
}

- (void) moveLeftThumbToIndex:(int)index
{
    if (index == -1)
    {
        // 选为最小区间
        [self moveLeftThumbToMostLeft];
        
    }
    else if (index <= self.indexLocations.count-1)
    {
        CGPoint point = [_indexLocations[index] CGPointValue];
        self.leftThumb.center = (CGPoint){point.x,point.y+kDefault_Thumb_Y_OffSet};
        self.leftValue = [self.indexValues[index] floatValue];
    }
}

- (void) moveRightThumbToIndex:(int)index
{
    if (index < 0)
    {
        // 右边不能一直移到最左
        return;
    }
    
    if (index <= self.indexLocations.count-1)
    {
        CGPoint point = [_indexLocations[index] CGPointValue];
        
        self.rightThumb.center = (CGPoint){point.x,point.y+kDefault_Thumb_Y_OffSet};
        self.rightValue = [self.indexValues[index] floatValue];
    }
    else if (index == self.indexLocations.count)
    {
        // 选为最大区间
        [self moveRightThumbToMostRight];
    }
}

- (void) moveLeftThumbToMostLeft
{
    self.leftValue = self.minValue - 1;
    self.leftThumb.center = (CGPoint){self.mostLeft,kDefault_Top_Margin+kDefault_Thumb_Y_OffSet};
}

- (void) moveRightThumbToMostRight
{
    self.rightValue = self.maxValue + 1;
    self.rightThumb.center = (CGPoint){self.mostRight,kDefault_Top_Margin+kDefault_Thumb_Y_OffSet};
}

- (void) resetToPriceAll
{
    [self moveThumbToLeftIndex:-1 rightIndex:self.indexLocations.count];
}

- (void) relocateIntervalView
{
    CGPoint point = [self.indexLocations[0] CGPointValue];
    CGRect frame = (CGRect){
        self.leftThumb.center.x,
        point.y-kDefault_IntervalView_Height*0.5,
        self.rightThumb.center.x-self.leftThumb.center.x,
        kDefault_IntervalView_Height
    };
    self.intervalView.frame = frame;
}

- (void)hideBubbleAnimated:(BOOL)animated
{
    if (self.bubbleBg.hidden) {
        return;
    }
    
    if (animated)
    {
        [UIView animateWithDuration:kDefault_BubbleFadeDuration animations:^{
            self.bubbleBg.alpha = 0;
        } completion:^(BOOL finished) {
            self.bubbleBg.hidden = YES;
        }];
    }
    else
    {
        self.bubbleBg.hidden = YES;
        self.bubbleBg.alpha = 0;
    }
}

- (void)showBubbleAnimated:(BOOL)animated
{
    if (!self.bubbleBg.hidden) {
        return;
    }
    
    self.bubbleBg.hidden = NO;
    
    if (animated)
    {
        [UIView animateWithDuration:kDefault_BubbleFadeDuration animations:^{
            self.bubbleBg.alpha = 1;
        }];
    }
    else
    {
        self.bubbleBg.alpha = 1;
    }
}

- (void)locateBubbleForThumb:(UIButton *)thumb
{
    self.bubbleBg.center = (CGPoint){thumb.center.x,kDefault_Top_Margin-18};
}

// handle leftThumb Pan Gesture
- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            [self bringSubviewToFront:_leftThumb];
        }
        // 最左端
        float mostLeft = self.mostLeft-kDefault_Thumb_Width*0.5;
        
        // 做按钮的不能位于右按钮最右端，且不得大于最大值
        CGPoint rightPoint = [self.indexLocations.lastObject CGPointValue];
        float mostRight = rightPoint.x - kDefault_Thumb_Width*0.5;
        if ( self.rightThumb.left < mostRight)
        {
            mostRight = self.rightThumb.left;
        }
        
        CGPoint translation = [gesture translationInView:self];
        float wantedX = self.leftThumb.left + translation.x;
        if (wantedX < mostLeft)
        {
            self.leftThumb.left = mostLeft;
        }
        else if (wantedX > mostRight)
        {
            self.leftThumb.left = mostRight;
        }
        else
        {
            self.leftThumb.left = wantedX;
        }
        
        self.leftValue = [self valueForThumb:self.leftThumb];
        
        [self updateBubbleTextForThumb:_leftThumb];
        [self autoMoveThumb:_rightThumb];
        
        [self relocateIntervalView];
        [self showBubbleAnimated:YES];
        [self locateBubbleForThumb:self.leftThumb];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
        [gesture setTranslation:CGPointZero inView:self];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        // when pan gesture over, adjust thumb to suitable location
        [self hideBubbleAnimated:YES];
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
        
        // 操作完的回调
        self.selectedTag = eLastSelectedTag_LEFT;
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

// handle rightThumb Pan Gesture
- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            [self bringSubviewToFront:_rightThumb];
        }
        // 右按钮的不能位于左按钮最左端，且不得小于最小值
        float mostLeft = self.leftThumb.left;
        CGPoint leftPoint = [self.indexLocations.firstObject CGPointValue];
        float leftX = leftPoint.x - kDefault_Thumb_Width*0.5;
        if ( mostLeft < leftX)
        {
            mostLeft = leftX;
        }
        
        // 最右端
        float mostRight = self.mostRight-kDefault_Thumb_Width*0.5;
        
        CGPoint translation = [gesture translationInView:self];
        float wantedX = self.rightThumb.left + translation.x;
        if (wantedX < mostLeft)
        {
            self.rightThumb.left = mostLeft;
        }
        else if (wantedX > mostRight)
        {
            self.rightThumb.left = mostRight;
        }else{
            self.rightThumb.left = wantedX;
        }
        
        self.rightValue = [self valueForThumb:self.rightThumb];
        
        [self updateBubbleTextForThumb:_rightThumb];
        [self autoMoveThumb:_leftThumb];
        
        [self relocateIntervalView];
        [self showBubbleAnimated:YES];
        [self locateBubbleForThumb:self.rightThumb];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
        [gesture setTranslation:CGPointZero inView:self];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        // when pan gesture over, adjust thumb to suitable location
        [self hideBubbleAnimated:YES];
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
        
        // 操作完的回调
        self.selectedTag = eLastSelectedTag_RIGHT;
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) updateBubbleTextForThumb:(UIButton *)thumb
{
    if (thumb == _leftThumb)
    {
        if (self.leftValue < self.minValue)
        {
            self.bubbleLabel.text = [NSString stringWithFormat:@"%.0f-",self.minValue];
        }else if (self.leftValue > self.maxValue)
        {
            self.bubbleLabel.text = [NSString stringWithFormat:@"%.0f",self.maxValue];
        }
        else{
            self.bubbleLabel.text = [NSString stringWithFormat:@"%.0f",self.leftValue];
        }
    }
    else
    {
        if (self.rightValue > self.maxValue)
        {
            self.bubbleLabel.text = [NSString stringWithFormat:@"%.0f+",self.maxValue];
        }else{
            self.bubbleLabel.text = [NSString stringWithFormat:@"%.0f",self.rightValue];
        }
    }
}

- (float) valueForThumb:(UIButton *)thumb
{
    float x = thumb.center.x;           // thumb's current location
    int index = (x - kLeftCalculateEdageX)/self.indexMargin;
    if (index < self.indexValues.count)
    {
        if (index == self.indexValues.count-1) {
            index = self.indexValues.count-2;
        }
        
        CGPoint point = [self.indexLocations[index] CGPointValue];
        float left = [self.indexValues[index] floatValue];
        float right = [self.indexValues[index+1] floatValue];
        
//        NSLog( @" ~~~~~~~~~~~ left & right : (%f,%f)",left,right);
    
        float value = left + (x-point.x)/self.indexMargin * (right-left);
        
        return value;
    }else{
        return self.maxValue + 1;
    }
    
    return 0;
}

- (float)xLocationForValue:(float)value
{
    for (int i = 0; i<self.indexValues.count-1;i++)
    {
        float left = [self.indexValues[i] floatValue];
        float right = [self.indexValues[i+1] floatValue];
        
        if (value>left && value<right)
        {
            CGPoint leftPoint = [self.indexLocations[i] CGPointValue];
            float pixValue = (right-left)/self.indexMargin;
            float offset = (value-left)/pixValue;
            return leftPoint.x + offset;
        }
        else if (value == left)
        {
            return [self.indexLocations[i] CGPointValue].x;
        }
        else if (value == right)
        {
            return [self.indexLocations[i+1] CGPointValue].x;
        }
    }
    
    return 0;
}

- (void) autoMoveThumb:(UIButton *)thumb
{
    if (thumb == _leftThumb)
    {
        float edgeValue = self.rightValue-self.autoMoveValue;
        if (edgeValue > [self.indexValues.firstObject floatValue]) {
            if (self.leftValue > edgeValue)
            {
                self.leftValue = self.rightValue-self.autoMoveValue;
                self.leftThumb.center = (CGPoint){[self xLocationForValue:self.leftValue],_leftThumb.center.y};
            }
        }
        else
        {
            // 置于5万以下 （无穷小）
            [self moveLeftThumbToMostLeft];
        }
    }
    else
    {
        float edgeValue = self.leftValue+self.autoMoveValue;
        
        if (edgeValue < [self.indexValues.lastObject floatValue]) {
            if (self.rightValue < edgeValue)
            {
                self.rightValue = self.leftValue+self.autoMoveValue;
                self.rightThumb.center = (CGPoint){[self xLocationForValue:self.rightValue],_rightThumb.center.y};
            }
        }
        else
        {
            // 置于100万以上 （无穷大）
            [self moveRightThumbToMostRight];
        }
    }
}

@end
