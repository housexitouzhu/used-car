//
//  UCThumbnailsView.m
//  UsedCar
//
//  Created by 张鑫 on 14-3-6.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCThumbnailsView.h"
#import "UIIndexControl.h"
#import "UIImageView+WebCache.h"

#define kIndexControlTag                32141876

@interface UCThumbnailsView ()

@property (nonatomic, strong) UIScrollView *svPhoto;
@property (nonatomic, strong) UIIndexControl *pcPhoto;

@end

@implementation UCThumbnailsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        // 初始化视图
        [self initView];
    }
    return self;
}

#pragma mark - initView
/** 初始化页面 */
- (void)initView
{
    self.layer.masksToBounds = YES;
    
    // 图片滚动视图
    _svPhoto = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, 80)];
    _svPhoto.delegate = self;
    _svPhoto.showsHorizontalScrollIndicator = NO;
    _svPhoto.pagingEnabled = YES;
    
    // 索引
    _pcPhoto = [[UIIndexControl alloc] initWithFrame:CGRectMake(0, _svPhoto.maxY + 6, self.width, 6) currentImageName:@"individual_points_h" commonImageName:@"individual_points"];
    _pcPhoto.tag = kIndexControlTag;
    _pcPhoto.hidesForSinglePage = YES;
    _pcPhoto.userInteractionEnabled = NO;
    
    if (_pcPhoto.maxY > self.height)
        _pcPhoto.minY = _svPhoto.maxY;
    
    // 分割线
    UIView *vImageViewLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, self.height - kLinePixel, self.width, kLinePixel) color:kColorNewLine];
    
    // 添加视图
    [self addSubview:_svPhoto];
    [self addSubview:_pcPhoto];
    [self addSubview:vImageViewLine];
    
}

#pragma mark - private Method
- (void)reloadPhoto
{    
    //无图片提示文字
    if ([_thumbimgurls count] == 0) {
        UIImageView *ivNoPic = [[UIImageView alloc] initWithFrame:self.bounds];
        ivNoPic.backgroundColor = [UIColor whiteColor];
        ivNoPic.image = [UIImage imageNamed:@"personaldetails_nopicture"];
        ivNoPic.contentMode = UIViewContentModeCenter;
        [_svPhoto addSubview:ivNoPic];
//        UILabel *labNoImage = [[UILabel alloc] initWithFrame:CGRectZero];
//        labNoImage.minY = 26;
//        labNoImage.text = @"暂无图片";
//        [labNoImage sizeToFit];
//        labNoImage.frame = CGRectMake(0, 84, labNoImage.width, labNoImage.height);
//        labNoImage.textAlignment = NSTextAlignmentCenter;
//        labNoImage.textColor = kColorGrey5;
    } else {
        CGFloat minX = 0.0f;
        for (int i = 0; i<[_thumbimgurls count]; i++) {
            
            if (i%3 == 0) {
                minX += (_svPhoto.width - 3*90) / 4;
            }
            // 图片按钮
            UIImageView *amImgPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(minX, 10, 90, 67.5)];
            amImgPhoto.frame = CGRectMake(minX, 10, 90, 67.5);
            amImgPhoto.tag = i;
            [amImgPhoto sd_setImageWithURL:[NSURL URLWithString:[_thumbimgurls objectAtIndex:i]] placeholderImage:[UIImage imageNamed:@"home_default"]];
            [_svPhoto addSubview:amImgPhoto];
            
            // 查看大图
            UIButton *photoBtn = [[UIButton alloc] init];
            photoBtn.frame = CGRectMake(minX, 10, 90, 67.5);
            photoBtn.tag = i;
            [photoBtn addTarget:self action:@selector(onClickPhotoBtn:) forControlEvents:UIControlEventTouchUpInside];
            photoBtn.backgroundColor = [UIColor clearColor];
            [_svPhoto addSubview:photoBtn];
            
            minX = amImgPhoto.maxX + (_svPhoto.width - 3*90) / 4;
        }
    }
    
    _svPhoto.contentSize = CGSizeMake(([_thumbimgurls count] % 3 == 0 ? [_thumbimgurls count] / 3 * _svPhoto.width : (([_thumbimgurls count] / 3 +1 ) * _svPhoto.width)), _svPhoto.height);
    
    _pcPhoto.numberOfPages = [_thumbimgurls count] % 3 == 0 ? [_thumbimgurls count] / 3 : ([_thumbimgurls count] / 3 + 1);
    [_pcPhoto setCurrentPage:0];
}

#pragma mark - onClickBtn
/** 点击图片 */
- (void)onClickPhotoBtn:(UIButton *)btn
{
    if ([_delegate respondsToSelector:@selector(UCThumbnailsView:onClickPhotoBtn:)]) {
        [_delegate UCThumbnailsView:self onClickPhotoBtn:btn];
    }
}

#pragma  mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1
{
    CGPoint offsetofScrollView = scrollView1.contentOffset;
    UIPageControl *pcPhotot = (UIPageControl *)[self viewWithTag:kIndexControlTag];
    [pcPhotot setCurrentPage:offsetofScrollView.x / scrollView1.frame.size.width];
}

@end
