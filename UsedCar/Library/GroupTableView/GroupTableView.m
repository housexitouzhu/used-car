//
//  GroupTableView.m
//  open
//
//  Created by 王俊 on 13-12-3.
//  Copyright (c) 2013年 ATHM. All rights reserved.
//

#import "GroupTableView.h"
#import "UIView+screenshot.h"
#import "UIView+ViewFrameGeometry.h"
#import "UIImageView+WebCache.h"
#define COVERALPHA 0

@implementation GroupTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)openFolderAtIndexPath:(NSIndexPath *)indexPath WithContentView:(UIView *)subClassContentView closeHandler:(void (^)(void))closeHandler
{
    _closeHandler =[closeHandler copy];
    self.scrollEnabled=NO;
    self.subClassContentView = subClassContentView;
    self.closing = NO;
    // 位置和高度参数
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    CGFloat deltaY = self.contentOffset.y;
    CGFloat positionX;
    
    positionX = 0;
    
    CGPoint position = CGPointMake(positionX, cell.frame.origin.y+cell.frame.size.height - 1);
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if (position.y - deltaY > height) {
        self.offsetY = position.y - height - deltaY;
    } else {
        self.offsetY = 0.0f;
    }

    // 重置contentoffset  这里要动画吗？
    self.oldContentOffset = self.contentOffset;
    self.contentOffset = CGPointMake(0, self.offsetY + deltaY);
    
    deltaY = self.contentOffset.y;
    
    UIImage *screenshot = [self screenshotWithOffset:-deltaY];
    
    // 配置上下遮罩
    CGRect upperRect = CGRectMake(0, deltaY, width, position.y - deltaY);
    CGRect lowerRect = CGRectMake(0, position.y, width, height + deltaY - position.y);
    
    self.top = [self buttonForRect:upperRect
                            screen:screenshot
                          position:position
                               top:YES
                       transparent:NO];
    self.bottom = [self buttonForRect:lowerRect
                               screen:screenshot
                             position:position
                                  top:NO
                          transparent:NO];
    
    [self addSubview:subClassContentView];
    [self addSubview:self.top];
    [self addSubview:self.bottom];
    
    float headerHeight = 0;
    if (self.headerTitle.length>0) {
        headerHeight = 25;
    }
    
    _btnClose = [[UIButton alloc]initWithFrame:CGRectMake(0, self.top.height-cell.height-headerHeight, cell.width, cell.height+headerHeight)];
    UIView*linesView=[[UIView alloc]initWithFrame:CGRectMake(0, _btnClose.height-.5, self.width, .5)];
    linesView.backgroundColor=kColorNewLine;
    [_btnClose addSubview:linesView];
    
   
    float closeimgTop=(cell.height+headerHeight)/2-6;
    UIImageView *closeImg = [[UIImageView alloc]initWithFrame:CGRectMake(_btnClose.width-20, closeimgTop, 12, 12)];
    closeImg.image = [UIImage imageNamed:@"close.png"];
    [_btnClose addSubview:closeImg];
    
    if (self.headerTitle.length>0) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.btnClose.width, 26)];
        headerView.backgroundColor=[UIColor whiteColor];
        UILabel *lbTitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.btnClose.width, 26)];
        lbTitle.font=kFontLarge;
        lbTitle.backgroundColor=[UIColor clearColor];
        lbTitle.textAlignment=NSTextAlignmentCenter;
        lbTitle.textColor=kColorNewGray1;
        lbTitle.text = self.headerTitle;
        [headerView addSubview:lbTitle];
        [_btnClose addSubview:headerView];
        UIView*linesView=[[UIView alloc]initWithFrame:CGRectMake(0, headerView.height-.5, self.width, .5)];
        linesView.backgroundColor=kColorNewLine;
        [headerView addSubview:linesView];
        closeImg.top+=14;
    }
    
    [_btnClose addTarget:self action:@selector(performClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.top addSubview:_btnClose];
    [self.top.cover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)]];
    [self.bottom.cover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)]];

    if (self.logoURL.length>0) {
        self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake(13, self.top.height - 35 - 7, 35, 35)];
        [self.logoView setBackgroundColor:[UIColor clearColor]];
//        [self.logoView setContentMode:(UIViewContentModeCenter & UIViewContentModeScaleAspectFit)];
        [self.logoView sd_setImageWithURL:[NSURL URLWithString:self.logoURL] placeholderImage:[UIImage imageNamed:@"screen_picture"]];
        [self.top addSubview:self.logoView];
    }
    
    
    CGRect viewFrame = subClassContentView.frame;
    if (position.y - deltaY + viewFrame.size.height > height) {
        viewFrame.origin.y = height + deltaY - viewFrame.size.height;
    } else {
        viewFrame.origin.y = position.y;
    }
    subClassContentView.frame = viewFrame;
    
    // 配置打开动画
    CGFloat contentHeight = subClassContentView.frame.size.height;
    CFTimeInterval duration = 0.3f;
    CGPoint toTopPoint;
    CABasicAnimation *moveTop = [CABasicAnimation animationWithKeyPath:@"position"];
    moveTop.duration = duration;
    moveTop.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.oldTopPoint = self.top.layer.position;
    CGFloat newTopY;
    if (self.top.frame.origin.y + self.top.frame.size.height > subClassContentView.frame.origin.y) {
        newTopY = self.oldTopPoint.y + subClassContentView.frame.origin.y - (self.top.frame.origin.y + self.top.frame.size.height);
    } else {
        newTopY = self.oldTopPoint.y;
    }
    toTopPoint = (CGPoint){ self.oldTopPoint.x, newTopY};
    moveTop.fromValue = [NSValue valueWithCGPoint:self.oldTopPoint];
    moveTop.toValue = [NSValue valueWithCGPoint:toTopPoint];
    
    
    CGPoint toBottomPoint;
    CABasicAnimation *moveBottom = [CABasicAnimation animationWithKeyPath:@"position"];
    moveBottom.duration = duration;
    moveBottom.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.oldBottomPoint = self.bottom.layer.position;
    CGFloat newBottomY;
    if (subClassContentView.frame.origin.y + subClassContentView.frame.size.height > height + deltaY ) {
        newBottomY = self.oldBottomPoint.y + (subClassContentView.frame.origin.y + contentHeight) - deltaY - height;
    } else {
        newBottomY = self.oldBottomPoint.y + contentHeight;
    }
    toBottomPoint = (CGPoint){ self.oldBottomPoint.x, newBottomY};
    moveBottom.fromValue = [NSValue valueWithCGPoint:self.oldBottomPoint];
    moveBottom.toValue = [NSValue valueWithCGPoint:toBottomPoint];
    
    // 打开动画
    [self.top.layer addAnimation:moveTop forKey:@"t1"];
    [self.bottom.layer addAnimation:moveBottom forKey:@"t2"];
    
    // 透明变半透明
    [UIView animateWithDuration:duration animations:^{
        self.top.cover.alpha = COVERALPHA;
        self.bottom.cover.alpha = COVERALPHA;
    }];
    
    [self.top.layer setPosition:toTopPoint];
    [self.bottom.layer setPosition:toBottomPoint];
    
}

- (void)performClose:(id)sender {
    if (headerView) {
        [headerView removeFromSuperview];
    }
    if (self.closing) {
        return;
    }else {
        self.closing = YES;
    }
    
    // 配置关闭动画
    CFTimeInterval duration = 0.3f;
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *moveTop = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveTop setValue:@"close" forKey:@"animationType"];
    [moveTop setDelegate:self];
    [moveTop setTimingFunction:timingFunction];
    moveTop.fromValue = [NSValue valueWithCGPoint:[[self.top.layer presentationLayer] position]];
    moveTop.toValue = [NSValue valueWithCGPoint:self.oldTopPoint];
    moveTop.duration = duration;
    
    
    CABasicAnimation *moveBottom = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveBottom setValue:@"close" forKey:@"animationType"];
    [moveBottom setDelegate:self];
    [moveBottom setTimingFunction:timingFunction];
    moveBottom.fromValue = [NSValue valueWithCGPoint:[[self.bottom.layer presentationLayer] position]];
    moveBottom.toValue = [NSValue valueWithCGPoint:self.oldBottomPoint];
    moveBottom.duration = duration;
    
    // 关闭动画
    [self.top.layer addAnimation:moveTop forKey:@"b1"];
    [self.bottom.layer addAnimation:moveBottom forKey:@"b2"];
    
    // 半透明变透明
    [UIView animateWithDuration:duration animations:^{
        
        self.contentOffset = self.oldContentOffset;
        self.top.cover.alpha = 0;
        self.bottom.cover.alpha = 0;
        
    } completion:^(BOOL finished) {
        if (_closeHandler) {
            _closeHandler();
        }
    }];
    
    
    [self.top.layer setPosition:self.oldTopPoint];
    [self.bottom.layer setPosition:self.oldBottomPoint];
    
    if (self.logoURL.length>0) {
        [self.logoView removeFromSuperview];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if ([[anim valueForKey:@"animationType"] isEqualToString:@"close"]) {
        [self.top removeFromSuperview];
        [self.bottom removeFromSuperview];
        [self.subClassContentView removeFromSuperview];
        
        self.top = nil;
        self.bottom = nil;
        self.subClassContentView = nil;
        
        self.scrollEnabled=YES;
    }
    
}


-(void)tapGestureAction:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged ||
        gesture.state == UIGestureRecognizerStateEnded) {
        if (gesture.numberOfTapsRequired > 0) {
            [self performClose:gesture];
        }
    }
}



- (void)scrollToTopCellAtIndex:(NSIndexPath *)indexPath
{
    CGRect frameOfCell = [self rectForRowAtIndexPath:indexPath];
    CGPoint offsetCellToTop = CGPointMake(self.contentOffset.x, frameOfCell.origin.y);
     self.contentOffset = offsetCellToTop;
}


- (FolderCoverView *)buttonForRect:(CGRect)aRect
                            screen:(UIImage *)screen
                          position:(CGPoint)position
                               top:(BOOL)isTop
                       transparent:(BOOL)isTransparent {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat width = aRect.size.width;
    CGFloat height = aRect.size.height;
    CGPoint origin = aRect.origin;
    CGFloat deltaY = self.contentOffset.y;
    
    CGRect scaledRect = CGRectMake(origin.x*scale, origin.y*scale - deltaY*scale, width*scale, height*scale);
    CGImageRef ref1 = CGImageCreateWithImageInRect([screen CGImage], scaledRect);
    
    FolderCoverView *button;
    if (isTop) {
        button = [[FolderCoverView alloc] initWithFrame:aRect offset:self.rowHeight];
        
//        UIImageView *notch = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tip.png"]];
//        notch.center = CGPointMake(position.x, height - 2);
//        [button addSubview:notch];
        
    } else {
        button = [[FolderCoverView alloc] initWithFrame:aRect offset:0];
    }
    
    [button setIsTopView:isTop];
    
    button.position = position;
    button.layer.contentsScale = scale;
    button.layer.contents = isTransparent ? nil : (__bridge id)(ref1);
    button.layer.contentsGravity = kCAGravityCenter;
    CGImageRelease(ref1);
    
    return button;
}

@end
