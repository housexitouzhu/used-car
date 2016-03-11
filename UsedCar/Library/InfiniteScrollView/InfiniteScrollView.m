//
//  InfiniteScrollView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-9-28.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "InfiniteScrollView.h"

@interface InfiniteScrollView ()<UIScrollViewDelegate>
{
//    NSInteger timerPageNum;
    NSInteger currentPage;
//    NSInteger MaxShowingPage;
    
    NSDate *pauseStart, *previousFireDate;
    
    CGFloat startPointX;
    CGFloat willEndPointX;
    CGFloat didEndPointX;
}
@property (nonatomic, strong) NSMutableArray *arrImageNames;
@property (nonatomic, strong) NSMutableArray *arrCellViews;
@property (nonatomic, strong) NSMutableArray *arrCurrentViews;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation InfiniteScrollView

- (id)initWithFrame:(CGRect)frame withViewArray:(NSArray *)arrView{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.arrCellViews = [NSMutableArray new];
        [self.arrCellViews addObjectsFromArray:arrView];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withImageNameArray:(NSArray *)arrImageName{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.arrImageNames = [NSMutableArray new];
        [self.arrImageNames addObjectsFromArray:arrImageName];
        self.arrCellViews = [NSMutableArray new];
        
        [self initViewWithImages];
        
    }
    return self;
}

- (void)initViewWithImages{
    
    self.backgroundColor = kColorClear;
    
    self.vScroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.vScroll.backgroundColor = kColorClear;
    self.vScroll.pagingEnabled = YES;
    self.vScroll.showsVerticalScrollIndicator = NO;
    self.vScroll.showsHorizontalScrollIndicator = NO;
    self.vScroll.delegate = self;
    [self.vScroll setContentSize:CGSizeMake(self.vScroll.width*3, self.vScroll.height)];
    
    for (int i = 0; i < self.arrImageNames.count; i++) {
        NSString *strImage = [self.arrImageNames objectAtIndex:i];
        UIImage *image = [UIImage imageNamed:strImage];
        UIImageView *vImage = [[UIImageView alloc] initWithImage:image];
        vImage.userInteractionEnabled = YES;
        vImage.tag = i;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnImage:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [vImage addGestureRecognizer:singleTap];
        
        if (SCREEN_HEIGHT > 480) {
            [vImage setContentMode: UIViewContentModeScaleAspectFit];
        }
        else{
            [vImage setContentMode: UIViewContentModeScaleAspectFill];
        }
        
        [vImage setFrame:CGRectMake(0, 0, self.vScroll.width, self.vScroll.height)];
        [self.arrCellViews addObject:vImage];
    }
    
    self.ctrlPage = [[SMPageControl alloc] initWithFrame:CGRectMake(0, self.height - 15, self.width, 15)];
    [self.ctrlPage setPageIndicatorImage:[UIImage imageNamed:@"sale_pictureswitch"]];
    [self.ctrlPage setCurrentPageIndicatorImage:[UIImage imageNamed:@"sale_pictureswitch_over"]];
    self.ctrlPage.numberOfPages = self.arrImageNames.count;
    [self.ctrlPage setCurrentPage:0];
    [self.ctrlPage setUserInteractionEnabled:NO];
    
    if (SCREEN_HEIGHT > 480) {
        [self.ctrlPage setFrame:CGRectMake(0, self.height - 15 - 5, self.width, 15)];
    }
    
    [self addSubview:self.vScroll];
    [self addSubview:self.ctrlPage];
    
    [self setUpScrollViewForIndex:0];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(showImagesOnTimer) userInfo:nil repeats:YES] ;
    
}

#pragma mark - 
- (void)handleTapOnImage:(UITapGestureRecognizer *)gesture{
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        if ([self.delegate respondsToSelector:@selector(InfiniteScrollView:didClickItemOnIndex:)]) {
            [self.delegate InfiniteScrollView:self didClickItemOnIndex:gesture.view.tag];
        }
    }
}

#pragma mark - 加载 scroll view 的方法

- (void)setUpScrollViewForIndex:(NSInteger)index{
    
    self.ctrlPage.currentPage = currentPage;
    
    //从scrollView上移除所有的subview
    NSArray *subViews = [self.vScroll subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    NSInteger pre = [self validPageValue:currentPage-1];
    NSInteger last = [self validPageValue:currentPage+1];
    
    if (!self.arrCurrentViews) {
        self.arrCurrentViews = [[NSMutableArray alloc] init];
    }
    
    [self.arrCurrentViews removeAllObjects];
    
    [self.arrCurrentViews addObject:[self.arrCellViews objectAtIndex:pre]];
    [self.arrCurrentViews addObject:[self.arrCellViews objectAtIndex:index]];
    [self.arrCurrentViews addObject:[self.arrCellViews objectAtIndex:last]];
    
    for (int i = 0; i < 3; i++) {
        UIView *v = [self.arrCurrentViews objectAtIndex:i];
        [v setOrigin:CGPointMake(self.vScroll.width*i, 0)];
        [self.vScroll addSubview:v];
    }
    
    [self.vScroll setContentOffset:CGPointMake(self.vScroll.width, 0)];
    
}

- (int)validPageValue:(NSInteger)value {
    
    if(value == -1) value = self.arrCellViews.count - 1;
    if(value == self.arrCellViews.count) value = 0;
    
    return value;
    
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
//    CGFloat pageWidth = self.vScroll.frame.size.width;
//    int page = floor((self.vScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    
//    timerPageNum = page;
//
//    [self.ctrlPage setCurrentPage:currentPage];
    
    int x = scrollView.contentOffset.x;
    
    //往下翻一张
    if(x >= (2*self.frame.size.width)) {
        currentPage = [self validPageValue:currentPage+1];
        [self setUpScrollViewForIndex:currentPage];
    }
    
    //往上翻
    if(x <= 0) {
        currentPage = [self validPageValue:currentPage-1];
        [self setUpScrollViewForIndex:currentPage];
    }
    

}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    //只要开始滚动，就停止tmer
    [self pauseTimer:self.timer];
    
//    startPointX = scrollView.contentOffset.x;
    
}

//自动滚动时,滚动停止后
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    //这里在自动滚动动画完成后 去做 view 的重设
    [self setUpScrollViewForIndex:currentPage];
    
//    CGFloat pageWidth = self.vScroll.frame.size.width;
//    int page = floor((self.vScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    
//    timerPageNum = page;
//    
//    if (page < self.arrImageNames.count/2) {
//        [self.ctrlPage setCurrentPage:timerPageNum];
//    }
//    else{
//        [self.ctrlPage setCurrentPage:(timerPageNum - self.arrImageNamesUnit.count)];
//    }
    
}

//停止手动滑动以后
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [self resumeTimerAfter3Sec:self.timer];
    
}

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{    //将要停止前的坐标
//    
//    willEndPointX = scrollView.contentOffset.x;
//    
//}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//
//    [scrollView setContentOffset:CGPointMake(scrollView.width, 0) animated:YES];
//    CGFloat pageWidth = self.vScroll.frame.size.width;
//    int page = floor((self.vScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    
//    didEndPointX = scrollView.contentOffset.x;
//    
//    if (didEndPointX < willEndPointX && willEndPointX < startPointX) { //画面从右往左移动，前一页
//        
//        
//    }
//    else if (didEndPointX > willEndPointX && willEndPointX > startPointX) {//画面从左往右移动，后一页
//        
//    }
//    
//}

#pragma mark - timer 方法
-(void)showImagesOnTimer{
    
    //由于每个 正在显示的 view 都是正中间的页面, 所以这里一直都是去滚动到它的下一张.
    [self.vScroll scrollRectToVisible:CGRectMake(self.width*2, 0, self.vScroll.frame.size.width, self.vScroll.frame.size.height) animated:YES];
    
    //验证当前 page
    currentPage = [self validPageValue:currentPage];
    
//    if(timerPageNum >= MaxShowingPage){
//        timerPageNum = 0;
//        
//        [self.vScroll scrollRectToVisible:CGRectMake(self.width*timerPageNum, 0, self.vScroll.frame.size.width, self.vScroll.frame.size.height) animated:NO];
//        
//        timerPageNum ++;
//        
//    }else {
//        
//        [self.vScroll scrollRectToVisible:CGRectMake(self.width*timerPageNum, 0, self.vScroll.frame.size.width, self.vScroll.frame.size.height) animated:YES];
//        timerPageNum ++;
//    }
}

#pragma mark - Pause & Resume Timer

-(void) pauseTimer:(NSTimer *)timer {
    
    pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
    
    previousFireDate = [timer fireDate];
    
    [timer setFireDate:[NSDate distantFuture]];
}

-(void) resumeTimer:(NSTimer *)timer {
    
    float pauseTime = -1*[pauseStart timeIntervalSinceNow];
    
    [timer setFireDate:[previousFireDate initWithTimeInterval:pauseTime sinceDate:previousFireDate]];
}

-(void) resumeTimerAfter3Sec:(NSTimer *)timer {
    
    [timer setFireDate:[previousFireDate initWithTimeInterval:3 sinceDate:previousFireDate]];
    
}




@end
