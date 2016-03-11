//
//  UCWelcome.m
//  UsedCar
//
//  Created by wangfaquan on 14-2-26.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCWelcome.h"
#import "UIIndexControl.h"
#import "UIImage+Util.h"
#import "AMCacheManage.h"

@implementation UCWelcome

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

#pragma mark - initView
-(void)initView
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    self.backgroundColor = kColorWhite; //kColorGuideBG;
    _pageNumber = 2;
    
    // 创建scrollView
    _svScroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    _svScroll.delegate = self;
    _svScroll.pagingEnabled = YES;
    _svScroll.decelerationRate = UIScrollViewDecelerationRateNormal;
    _svScroll.showsHorizontalScrollIndicator = NO;
    _svScroll.showsVerticalScrollIndicator = NO;
    _svScroll.contentSize = CGSizeMake(_svScroll.width * _pageNumber, self.height);
    _svScroll.scrollEnabled = YES;
    
    // 添加图片
    for (int i = 0; i < _pageNumber; i++) {
        UIImageView *iPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(_svScroll.width * i, 0, _svScroll.width, _svScroll.height)];
        iPhoto.contentMode = UIViewContentModeScaleAspectFit;
        NSString *imageName = nil;
        if (SCREEN_HEIGHT == 480) {
            imageName = [NSString stringWithFormat:@"startGuide_%d", i + 1];
        }
        else if (SCREEN_HEIGHT == 568) {
            imageName = [NSString stringWithFormat:@"startGuide_%d_R4", i + 1];
        }
        else if (SCREEN_HEIGHT == 667){
            imageName = [NSString stringWithFormat:@"startGuide_%d_R47", i + 1];
        }
        else{
            imageName = [NSString stringWithFormat:@"startGuide_%d_R55", i + 1];
        }
        iPhoto.image = [UIImage imageNamed:imageName];
        iPhoto.userInteractionEnabled = YES;
        [_svScroll addSubview:iPhoto];
        
        // 关闭按钮
        if (_pageNumber - 1) {
            
//            CGFloat x = _svScroll.width*_pageNumber - (260 + (_svScroll.width-260)/2);
//            UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(x, kUnkown, 260, 44)];
//            [btnClose setBackgroundImage:[UIImage imageWithColor:kColorBlue2 size:btnClose.bounds.size] forState:UIControlStateNormal];
//            [btnClose setBackgroundImage:[UIImage imageWithColor:kColorBlue2H size:btnClose.bounds.size] forState:UIControlStateHighlighted];
            UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
            CGFloat x = _svScroll.width*_pageNumber - (90 + (_svScroll.width-90)/2);
            [btnClose setFrame:CGRectMake(x, kUnkown, 90, 32)];
            [btnClose setBackgroundImage:[UIImage imageWithColor:RGBColorAlpha(255, 133, 132, 1.0) size:btnClose.bounds.size] forState:UIControlStateNormal];
            [btnClose setBackgroundImage:[UIImage imageWithColor:RGBColorAlpha(209, 69, 68, 1.0) size:btnClose.bounds.size] forState:UIControlStateHighlighted];
            [btnClose setTitle:@"立即体验" forState:UIControlStateNormal];
            [btnClose setTitleColor:kColorWhite forState:UIControlStateNormal];
            [btnClose.titleLabel setFont:kFontLarge];
            [btnClose.layer setCornerRadius:5.0];
            [btnClose.layer setMasksToBounds:YES];
            
            if (SCREEN_HEIGHT == 480) {
                btnClose.maxY = self.height - 25;
            }
            else if (SCREEN_HEIGHT == 568) {
                btnClose.maxY = self.height - 49;
            }
            else if (SCREEN_HEIGHT == 667){
                CGFloat x = _svScroll.width*_pageNumber - (100 + (_svScroll.width-100)/2);
                [btnClose setFrame:CGRectMake(x, kUnkown, 100, 36)];
                [btnClose setBackgroundImage:[UIImage imageWithColor:RGBColorAlpha(255, 133, 132, 1.0) size:btnClose.bounds.size] forState:UIControlStateNormal];
                [btnClose setBackgroundImage:[UIImage imageWithColor:RGBColorAlpha(209, 69, 68, 1.0) size:btnClose.bounds.size] forState:UIControlStateHighlighted];
                [btnClose.titleLabel setFont:kFontLarge1];
                btnClose.maxY = self.height - 55;
            }
            else{
                CGFloat x = _svScroll.width*_pageNumber - (120 + (_svScroll.width-120)/2);
                [btnClose setFrame:CGRectMake(x, kUnkown, 120, 42)];
                [btnClose setBackgroundImage:[UIImage imageWithColor:RGBColorAlpha(255, 133, 132, 1.0) size:btnClose.bounds.size] forState:UIControlStateNormal];
                [btnClose setBackgroundImage:[UIImage imageWithColor:RGBColorAlpha(209, 69, 68, 1.0) size:btnClose.bounds.size] forState:UIControlStateHighlighted];
                [btnClose.titleLabel setFont:kFontLarge1];
                btnClose.maxY = self.height - 55;
            }
            
            [btnClose addTarget:self action:@selector(onClickCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
            [_svScroll addSubview:btnClose];
        }
        
    }
    
    // 创建pageControl
//    if (SCREEN_HEIGHT > 480)
//         _pcPhoto = [[UIIndexControl alloc] initWithFrame:CGRectMake(0, self.height - 45, self.width, 20)currentImageName:@"guides_in_icon" commonImageName:@"guides_out_icon"];
//    else
//        _pcPhoto = [[UIIndexControl alloc] initWithFrame:CGRectMake(0, self.height - 28, self.width, 20)currentImageName:@"guides_in_icon" commonImageName:@"guides_out_icon"];
    
    if (SCREEN_HEIGHT > 480)
        _pcPhoto = [[UIIndexControl alloc] initWithFrame:CGRectMake(0, self.height - 30, self.width, 10) currentImageName:@"sale_pictureswitch_over" commonImageName:@"sale_pictureswitch"];
    else
        _pcPhoto = [[UIIndexControl alloc] initWithFrame:CGRectMake(0, self.height - 17, self.width, 10) currentImageName:@"sale_pictureswitch_over" commonImageName:@"sale_pictureswitch"];
    
    _pcPhoto.hidesForSinglePage = YES;
    // 要显示的页数
    _pcPhoto.numberOfPages = _pageNumber;
    [_pcPhoto setCurrentPage:0];
    _pcPhoto.userInteractionEnabled = NO;
    [self addSubview:_svScroll];
    [self addSubview:_pcPhoto];
}

#pragma mark - onClickBtn
/** 关闭页面 */
-(void)onClickCloseBtn:(UIButton *)button
{
    // 执行关闭的代理
    if ([_delegate respondsToSelector:@selector(didCloseWelcomeView:)])
        [_delegate didCloseWelcomeView:self];
    
    // 显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [AMCacheManage setCurrentIsUsed:YES];
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveRight];
}

#pragma  mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offsetofScrollView = scrollView.contentOffset;
    [_pcPhoto setCurrentPage:offsetofScrollView.x / scrollView.frame.size.width];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGPoint offsetofScrollView = scrollView.contentOffset;
    if (offsetofScrollView.x > self.width * (_pageNumber - 1) + self.width / 4)
        [self onClickCloseBtn:nil];
    
}


@end
