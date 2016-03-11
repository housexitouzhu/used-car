//
//  UCChangeScrollView.m
//  UsedCar
//
//  Created by 张鑫 on 14-6-6.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCChangeScrollView.h"
#import "NSString+Util.h"

#define circleWidth 2

@interface UCChangeScrollView ()

@property (nonatomic, strong) UILabel *labHeader;
@property (nonatomic, strong) UILabel *labFooter;
@property (nonatomic, strong) CAShapeLayer *layerTop;
@property (nonatomic, strong) CAShapeLayer *layerBottom;
@property (nonatomic, strong) UIView * vCircleTop;
@property (nonatomic, strong) UIView * vCircleBottom;
@property (nonatomic) BOOL isOpenTurning;          // 默认可以开启关闭


@end

@implementation UCChangeScrollView

- (id)initWithFrame:(CGRect)frame isOpenTurning:(BOOL)isOpenTurning
{
    self = [super initWithFrame:frame];
    if (self) {
        _isOpenTurning = isOpenTurning;
        self.delegate = self;
        if(_isOpenTurning) {
            [self addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
            [self initHeaderAndFooterview:frame];
        }
    }
    return self;
}

/** 创建头和底部 */
- (void)initHeaderAndFooterview:(CGRect)frame
{
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat size = 60;
    // 头部
    _vHeader = [[UIView alloc] initWithFrame:CGRectMake(0, -60, self.width, 60)];
    
    // 圆 顶
    _vCircleTop = [[UIView alloc] initWithFrame:CGRectMake(18, 0, size, size)];
    _vCircleTop.backgroundColor = [UIColor clearColor];
    
    // 圈背景
    CAShapeLayer *layerTopBag;
    UIBezierPath *pathBag = [UIBezierPath bezierPath];
    CGRect rectBag = CGRectMake(_vCircleTop.width / 2, _vCircleTop.height / 2, size, size);
    [pathBag addArcWithCenter:CGPointMake(0, 0) radius:10 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    layerTopBag = [CAShapeLayer layer];
    layerTopBag.path = pathBag.CGPath;
    layerTopBag.fillColor = [UIColor clearColor].CGColor;
    layerTopBag.strokeColor = kColorGrey4.CGColor;
    layerTopBag.lineWidth = circleWidth;
    layerTopBag.frame = rectBag;
    
    // 圈实体
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect rect = CGRectMake(_vCircleTop.width / 2, _vCircleTop.height / 2, size, size);
    [path addArcWithCenter:CGPointMake(0, 0) radius:10 startAngle:0 endAngle:0 clockwise:YES];
    _layerTop = [CAShapeLayer layer];
    _layerTop.path = path.CGPath;
    _layerTop.fillColor = [UIColor clearColor].CGColor;
    _layerTop.strokeColor = kColorBlue1.CGColor;
    _layerTop.lineWidth = circleWidth;
    _layerTop.frame = rect;
    [_vCircleTop.layer addSublayer:layerTopBag];
    [_vCircleTop.layer addSublayer:_layerTop];
    
    
    // 头-文字
    // 文字
    _labHeader = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, _vHeader.width - 70 - 20, _vHeader.height)];
    _labHeader.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _labHeader.textAlignment = NSTextAlignmentLeft;
    _labHeader.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    _labHeader.backgroundColor = [UIColor clearColor];
    _labHeader.textColor = [UIColor colorWithWhite:0.5 alpha:1];

    // 底部
    _vFooter = [[UIView alloc] init];
    _vFooter.size = CGSizeMake(self.width, 60);
    
    // 圆 底
    _vCircleBottom = [[UIView alloc] initWithFrame:CGRectMake(18, 0, size, size)];
    _vCircleBottom.backgroundColor = [UIColor clearColor];
    
    // 圈背景
    CAShapeLayer *layerBottomBag;
    UIBezierPath *pathBottomBag = [UIBezierPath bezierPath];
    CGRect rectBottomBag = CGRectMake(_vCircleBottom.width / 2, _vCircleBottom.height / 2, size, size);
    [pathBottomBag addArcWithCenter:CGPointMake(0, 0) radius:10 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    layerBottomBag = [CAShapeLayer layer];
    layerBottomBag.path = pathBottomBag.CGPath;
    layerBottomBag.fillColor = [UIColor clearColor].CGColor;
    layerBottomBag.strokeColor = kColorGrey4.CGColor;
    layerBottomBag.lineWidth = circleWidth;
    layerBottomBag.frame = rectBottomBag;
    
    // 圈实体
    UIBezierPath *pathBottom = [UIBezierPath bezierPath];
    CGRect rectBottom = CGRectMake(_vCircleBottom.width / 2, _vCircleBottom.height / 2, size, size);
    [pathBottom addArcWithCenter:CGPointMake(0, 0) radius:10 startAngle:0 endAngle:0 clockwise:YES];
    _layerBottom = [CAShapeLayer layer];
    _layerBottom.path = pathBottom.CGPath;
    _layerBottom.fillColor = [UIColor clearColor].CGColor;
    _layerBottom.strokeColor = kColorBlue1.CGColor;
    _layerBottom.lineWidth = circleWidth;
    _layerBottom.frame = rectBottom;
    [_vCircleBottom.layer addSublayer:layerBottomBag];
    [_vCircleBottom.layer addSublayer:_layerBottom];

    // 文字
    _labFooter = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, _vFooter.width - 70 - 20, _vHeader.height)];
    _labFooter.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _labFooter.textAlignment = NSTextAlignmentLeft;
    _labFooter.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    _labFooter.backgroundColor = [UIColor clearColor];
    _labFooter.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    
    [_vHeader addSubview:_labHeader];
    [_vHeader addSubview:_vCircleTop];
    [_vFooter addSubview:_labFooter];
    [_vFooter addSubview:_vCircleBottom];
    [self addSubview:_vHeader];
    [self addSubview:_vFooter];
}

#pragma mark - private Method
- (void)setProgress:(CGFloat)progress position:(UCChangeScrollViewPosition)position
{
    CGFloat size = 60;
    CAShapeLayer *layerTemp = nil;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect rect;
    
    // 区分顶栏底栏
    if (position == UCChangeScrollViewPositionTop) {
        layerTemp = _layerTop;
        rect = CGRectMake(_vCircleTop.width / 2, _vCircleTop.height / 2, size, size);
    } else {
        layerTemp = _layerBottom;
        rect = CGRectMake(_vCircleBottom.width / 2, _vCircleBottom.height / 2, size, size);
    }
    
    CGFloat start;
    CGFloat end;
    
    if (position == UCChangeScrollViewPositionTop) {
        start = M_PI*2*1/4;
        end = (M_PI*2 + M_PI*2*1/4)*progress < start ? start : (M_PI*2 + M_PI*2*1/4)*progress;
        if (((M_PI*2 + M_PI*2*1/4)*progress) > (M_PI*2 + M_PI*2*1/4)) {
            end = (M_PI*2 + M_PI*2*1/4);
        }
    } else {
        start = M_PI*2*3/4;
        end = (M_PI*2 + M_PI*2*3/4) *progress < start ? start : (M_PI*2 + M_PI*2*3/4)*progress;
        if ((M_PI*2 + M_PI*2*3/4)* progress > (M_PI*2 + M_PI*2*3/4)) {
            end = (M_PI*2 + M_PI*2*3/4);
        }
    }
    
    [path addArcWithCenter:CGPointMake(0, 0) radius:10 startAngle:start endAngle:end clockwise:YES];
    layerTemp.path = path.CGPath;
}

/** 设置文字 - 居中显示 */
- (void)setHeaderText:(NSString *)head topCircleHidden:(BOOL)isTopHidden footerText:(NSString *)foot topCircleHidden:(BOOL)isBottomHidden
{
    if (_isOpenTurning) {
        // 设置文字
        _labHeader.text = [head dNull];
        _labFooter.text = [foot dNull];
        
        // 隐藏|显示圆
        _vCircleTop.hidden = isTopHidden;
        _vCircleBottom.hidden = isBottomHidden;
        
        CGSize size = CGSizeMake(self.width - 80,60);
        
        CGSize sizeHead = [_labHeader.text sizeWithFont:_labHeader.font constrainedToSize:size lineBreakMode:_labHeader.lineBreakMode];
        CGSize sizeFoot = [_labFooter.text sizeWithFont:_labFooter.font constrainedToSize:size lineBreakMode:_labFooter.lineBreakMode];
        
        _labHeader.width = sizeHead.width;
        _labFooter.width = sizeFoot.width;
        
        // 是否居中
        _labHeader.minX = isTopHidden ? (_vHeader.width - _labHeader.width) / 2 : 70;
        _labFooter.minX = isBottomHidden ? (_vFooter.width - _labFooter.width) / 2 : 70;
    }
}

/** 加载数据 */
- (void)reloadFootView
{
    // 设置头部
    _vFooter.minY = self.contentSize.height;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isOpenTurning) {
        CGFloat max = 95;
        CGFloat min = 30;
        // 顶 画圈
        if (-scrollView.contentOffset.y > min) {
            [self setProgress:((-scrollView.contentOffset.y - min) / (max - min)) position:UCChangeScrollViewPositionTop];
        }
        // 底 画圈
        if ((scrollView.contentOffset.y + scrollView.height - scrollView.contentSize.height) > min) {
            [self setProgress:(((scrollView.contentOffset.y + scrollView.height - scrollView.contentSize.height) - min) / (max - min)) position:UCChangeScrollViewPositionBottom];
        }
    }
    
    if ([_delegateChange respondsToSelector:@selector(UCChangeScrollViewDidScroll:)]) {
        [_delegateChange UCChangeScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_isOpenTurning) {
        // 下拉
        if (scrollView.contentOffset.y < -95) {
            if ([_delegateChange respondsToSelector:@selector(UCChangeScrollViewDidPull:pullType:)]) {
                [_delegateChange UCChangeScrollViewDidPull:scrollView pullType:UCChangeScrollViewPullTypeDown];
            }
        }
        
        // 上拉
        if (scrollView.contentOffset.y + scrollView.height > scrollView.contentSize.height + 95) {
            if ([_delegateChange respondsToSelector:@selector(UCChangeScrollViewDidPull:pullType:)]) {
                [_delegateChange UCChangeScrollViewDidPull:scrollView pullType:UCChangeScrollViewPullTypeUp];
            }
        }
    }
    
    if ([_delegateChange respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_delegateChange UCChangeScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self reloadFootView];
}

-(void)dealloc
{
    if (_isOpenTurning) {
        [self removeObserver:self forKeyPath:@"contentSize"];
    }
}

@end
