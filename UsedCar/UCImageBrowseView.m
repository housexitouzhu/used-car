//
//  UCImageBrowseView.m
//  UsedCar
//
//  Created by 张鑫 on 13-11-17.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCImageBrowseView.h"
#import "UCTopBar.h"
#import "MainViewController.h"
#import "APIHelper.h"
#import "AMCacheManage.h"
#import "UIImage+Util.h"
#import "AMToastView.h"
#import "ALAssetsLibrary+Util.h"
#import "UIImageView+WebCache.h"

#define KCarThumbnailTag            93847654
#define kPictureImageViewTag        74657384
#define KTitleBarHeight             44
#define KGetImageCount              3

@interface UCImageBrowseView ()
@property (nonatomic) BOOL isHorizontal;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic, strong) NSArray *imageUrls;
@property (nonatomic, strong) NSMutableArray *savedPhotos;
@property (nonatomic, strong) UIScrollView *svThumbnail;
@property (nonatomic, strong) AMToastView *vToast;
@property (nonatomic, strong) AMToastView *vToastImage;
@property (nonatomic, strong) UCTopBar *tobBar;
@property (nonatomic, strong) UIScrollView *svPhoto;
@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) UIView *vThumbnail;
@property (nonatomic, strong) UIView *vBar;
@property (nonatomic, strong) UIButton *btnLeft;
@property (nonatomic, strong) UIButton *btnRight;
@property (nonatomic, strong) UIImageView *ivBackgroundBox;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@end

@implementation UCImageBrowseView

- (id)initWithFrame:(CGRect)frame index:(NSInteger)index thumbimgurls:(NSArray *)thumbimgurls imageUrls:(NSArray *)imageUrls
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        _savedPhotos = [NSMutableArray array];
        [self initView:index thumbimgurls:thumbimgurls imageUrls:imageUrls];
    }
    return self;
}

#pragma mark - initView
- (void)initView:(NSInteger)index thumbimgurls:(NSArray *)thumbimgurls imageUrls:(NSArray *)imageUrls;
{
    self.layer.masksToBounds = NO;
    self.userInteractionEnabled = YES;
    
    self.backgroundColor = kColorGray1;
    
    // 初始默认页
    _currentPage = index % 100;
    _imageUrls = [NSArray arrayWithArray:imageUrls];
    
    // 主页
    _vImageBrowse = [[UIView alloc] initWithFrame:self.bounds];
    _vImageBrowse.backgroundColor = kColorGray1;
    _vImageBrowse.userInteractionEnabled = YES;
    _vImageBrowse.autoresizesSubviews = YES;
    
    // 所有图片的ScrollView
    _svPhoto = [[UIScrollView alloc] initWithFrame:_vImageBrowse.bounds];
    _svPhoto.delegate = self;
    _svPhoto.showsHorizontalScrollIndicator = NO;
    _svPhoto.tag = 12097666;
    _svPhoto.pagingEnabled = YES;
    
    // 设置总页数
    _totalPage = [imageUrls count];
    
    for (int i = 0; i<[imageUrls count]; i++) {
        UIScrollView *svImage = [[UIScrollView alloc] initWithFrame:CGRectMake(i*self.width, 0, _svPhoto.width, _svPhoto.height)];
        svImage.minimumZoomScale = 1.0;
        svImage.maximumZoomScale = 5.0;
        svImage.tag = 27845000+i;
        svImage.delegate = self;
        svImage.bouncesZoom = YES;
        svImage.showsHorizontalScrollIndicator = NO;
        svImage.showsVerticalScrollIndicator = NO;
        svImage.decelerationRate = 1.0f; // 减速速率
        
        // 单机事件
        UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(handleTap:)];
        singleFingerOne.numberOfTapsRequired = 1;
        [svImage addGestureRecognizer:singleFingerOne];
        
        // 双击缩放
        UITapGestureRecognizer *singleFingerTwo = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(imageViewPressed:)];
        singleFingerTwo.numberOfTapsRequired = 2;              // 设置双击
        [svImage addGestureRecognizer:singleFingerTwo];
        
        // 如果不加下面的话，当单指双击时，会先调用单指单击中的处理，再调用单指双击中的处理
        [singleFingerOne requireGestureRecognizerToFail:singleFingerTwo];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = kPictureImageViewTag + i;
        svImage.contentSize = imageView.bounds.size;
        [self adjustImageViewFrame:svImage];
        
        [svImage addSubview:imageView];
        [_svPhoto addSubview:svImage];
    }
    
    _svPhoto.contentSize = CGSizeMake(self.width*[imageUrls count], _svPhoto.height);
    
    [_vImageBrowse addSubview:_svPhoto];
    
    [self addSubview:_vImageBrowse];
    
    // 滑动到指定位置
    [_svPhoto scrollRectToVisible:CGRectMake(_currentPage*self.width, 0, _vImageBrowse.width, _vImageBrowse.height) animated:NO];
    
    _vBar = [[UIView alloc] initWithFrame:CGRectMake(0, IOS7_OR_LATER ? 0 : 20, self.width, IOS7_OR_LATER ? KTitleBarHeight + 20 : KTitleBarHeight)];
    _vBar.backgroundColor = RGBColorAlpha(0, 0, 0, 0.4);
    _vBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // tobBar 不加入到视图，只告诉当前返回按钮大小等
    _tobBar = [[UCTopBar alloc] init];
    
    // 左按钮
    _btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _vBar.width / 4, _vBar.height)];
    _btnLeft.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_btnLeft setImage:[UIImage imageNamed:@"topbar_backbtn"] forState:UIControlStateNormal];
    [_btnLeft setTitle:@"返回" forState:UIControlStateNormal];
    _btnLeft.titleLabel.font = _tobBar.btnLeft.titleLabel.font;
    _btnLeft.imageEdgeInsets = UIEdgeInsetsMake(0, kBackButtonEdgeInsetsLeft, IOS7_OR_LATER ? -20 : 0, 0);
    _btnLeft.titleEdgeInsets = UIEdgeInsetsMake(0, kBackButtonEdgeInsetsLeft, IOS7_OR_LATER ? -20 : 0, 0);
    [_btnLeft addTarget:self action:@selector(onClickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    
    // 右按钮
    _btnRight = [[UIButton alloc] initWithFrame:CGRectMake(_vBar.width - _vBar.width / 4, 0, _vBar.width / 4, _vBar.height)];
    _btnRight.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_btnRight setTitle:@"保存" forState:UIControlStateNormal];
    [_btnRight setTitleColor:kColorGrey5 forState:UIControlStateDisabled];
    _btnRight.titleLabel.font = _tobBar.btnRight.titleLabel.font;
    _btnRight.titleEdgeInsets = UIEdgeInsetsMake(0, 0, IOS7_OR_LATER ? -20 : 0, kButtonEdgeInsetsLeft);
    [_btnRight addTarget:self action:@selector(onClickSaveBtn) forControlEvents:UIControlEventTouchUpInside];
    
    // 标题
    _labTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, _vBar.height - KTitleBarHeight, _vBar.width, KTitleBarHeight)];
    // 页数显示
    _labTitle.font = [UIFont systemFontOfSize:12];
    _labTitle.backgroundColor = [UIColor clearColor];
    _labTitle.textColor = kColorWhite;
    _labTitle.textAlignment = NSTextAlignmentCenter;
    _labTitle.tag  = 64555462;
    _labTitle.text = [NSString stringWithFormat:@"%d/%d", _currentPage + 1, _totalPage];
    
    [_vBar addSubview:_labTitle];
    [_vBar addSubview:_btnLeft];
    [_vBar addSubview:_btnRight];
    [_vImageBrowse addSubview:_vBar];
    
    // 缩略图
    _vThumbnail = [[UIView alloc] initLineWithFrame:CGRectMake(0, _vImageBrowse.height - 73, _vImageBrowse.width, 73) color:RGBColorAlpha(0, 0, 0, 0.4)];
    _svThumbnail = [[UIScrollView alloc] initWithClearFrame:CGRectMake(0, 0, _vThumbnail.width, _vThumbnail.height)];
    _vThumbnail.userInteractionEnabled = YES;
    
    CGFloat marginLeft = 10.f;
    
    if (thumbimgurls.count == 0)
        thumbimgurls = imageUrls;
    
    for (int i = 0; i<[thumbimgurls count]; i++) {
        // 背景图
        UIImageView *ivbackground = [[UIImageView alloc] initWithFrame:CGRectMake(marginLeft, (73 - 58) / 2, 77, 58)];
        ivbackground.image = [UIImage imageNamed:@"home_default.png"];
        [_svThumbnail addSubview:ivbackground];
        
        // 图片按钮
        UIImageView *amImgPhoto = [[UIImageView alloc] init];
        amImgPhoto.frame = CGRectMake(marginLeft, (73 - 58) / 2, 77, 58);
        amImgPhoto.tag = KCarThumbnailTag + i;
        amImgPhoto.userInteractionEnabled = NO;
        [amImgPhoto sd_setImageWithURL:[thumbimgurls objectAtIndex:i]];
        [_svThumbnail addSubview:amImgPhoto];
        marginLeft = amImgPhoto.maxX + 10;
        
        UIButton *btnPhoto = [[UIButton alloc] initWithFrame:amImgPhoto.frame];
        btnPhoto.tag = i;
        btnPhoto.userInteractionEnabled = YES;
        [btnPhoto addTarget:self action:@selector(onClickThumbailBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_svThumbnail addSubview:btnPhoto];
        
    }
    _svThumbnail.contentSize = CGSizeMake(marginLeft, _svThumbnail.height);
    
    // 背景框
    _ivBackgroundBox = [[UIImageView alloc] initWithFrame:CGRectMake(9, (73 - 58) / 2 - 1, 79, 60)];
    _ivBackgroundBox.backgroundColor = [UIColor clearColor];
    _ivBackgroundBox.layer.borderColor = kColorLightGreen.CGColor;
    _ivBackgroundBox.layer.borderWidth = 1;
    _ivBackgroundBox.userInteractionEnabled = NO;
    
    [_vThumbnail addSubview:_svThumbnail];
    [_svThumbnail addSubview:_ivBackgroundBox];
    [_vImageBrowse addSubview:_vThumbnail];
    
    // 选中初始图片
    UIButton *btnPhoto = (UIButton *)[self viewWithTag:index];
    [self onClickThumbailBtn:btnPhoto];
    
    [self performSelector:@selector(onDeviceOrientationChange) withObject:nil afterDelay:0.3];

}

#pragma mark - private Method
/** 设置保存按钮可否点击 */
- (void)setEnableSave
{
    BOOL isExist = NO;
    for (int i = 0; i < _savedPhotos.count; i++) {
        if (_currentPage == [[_savedPhotos objectAtIndex:i] integerValue]) {
            isExist = YES;
            break;
        }
    }
    if (!isExist)
        _btnRight.enabled = YES;
    else
        _btnRight.enabled = NO;
}


/** onTapView */
- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGFloat minY = _isHorizontal ? 0 : (IOS7_OR_LATER ? 0 : 20);
        [UIView animateWithDuration:kAnimateSpeedFast animations:^{
            if (_vBar.minY == minY) {
                _vBar.minY -= _vBar.height + minY;
                _vThumbnail.minY += _vThumbnail.height;
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            } else {
                _vBar.minY += _vBar.height + minY;
                _vThumbnail.minY -= _vThumbnail.height;
                if (!_isHorizontal) {
                    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                }
                
            }
            
        }];
    }
}

/** 双击缩放 */
- (void)imageViewPressed:(id)sender
{
    UIScrollView *svCurrent = (UIScrollView *)[self viewWithTag:27845000 + _currentPage];
    CGFloat zs = svCurrent.zoomScale;
    zs = (zs == 1.0) ? 3.0 : 1.0;              // 双击倍数
    [svCurrent setZoomScale:zs animated:YES];
}

#pragma mark - onClickButton
/** 点击缩略图的按钮 */
-(void)onClickThumbailBtn:(UIButton *)btn
{
    _currentPage = btn.tag;
    
    // 恢复上一个大小
    if(_svPhoto.tag != _scrollViewTag){
        UIScrollView *pScrollView = (UIScrollView *)[_svPhoto viewWithTag:_scrollViewTag];
        [pScrollView setZoomScale:1.0 animated:NO];
    }
    
    // 设置当前页数
    UILabel *labPage = (UILabel *)[self viewWithTag:64555462];
    labPage.text = [NSString stringWithFormat:@"%d/%d",_currentPage + 1,_totalPage];
    
    // 得到当前图片
    [self getImageData];
    
    // 判断保存按钮是否有效
    UIScrollView *svCurrent = (UIScrollView *)[self viewWithTag:27845000 + _currentPage];
    UIImageView *ivCurrent = (UIImageView *)[svCurrent viewWithTag:kPictureImageViewTag + _currentPage];
    if (ivCurrent.image) {
        [self setEnableSave];
    }
    else
        _btnRight.enabled = NO;
    
    // 更新缩略图位置
    UIImageView *ivCurrentThumbnail = (UIImageView *)[self viewWithTag:KCarThumbnailTag + _currentPage];
    _ivBackgroundBox.minX = ivCurrentThumbnail.minX - 1;
    
    if (_svThumbnail.contentSize.width > (_isHorizontal ? _vImageBrowse.height : _vImageBrowse.width)) {
        CGFloat marginLeft = 0.f;
        
        if (_isHorizontal)
            marginLeft = _ivBackgroundBox.minX - 245 + (IOS7_OR_LATER ? 0 : 44);
        else
            marginLeft = _ivBackgroundBox.minX - 118;
        
        if (marginLeft < 0 ) {
            marginLeft = 0;
        }
        
        if (!_isHorizontal && ( marginLeft >  _svThumbnail.contentSize.width - self.width)) {
            marginLeft = _svThumbnail.contentSize.width - self.width;
        }
        if (_isHorizontal && (marginLeft > _svThumbnail.contentSize.width - self.height)) {
            marginLeft = _svThumbnail.contentSize.width - self.height;
        }
        
        [_svThumbnail setContentOffset:CGPointMake(marginLeft , 0) animated:YES];
    }
    
    [_svPhoto setContentOffset:CGPointMake(btn.tag * (_isHorizontal ? _vImageBrowse.height : self.width), 0) animated:YES];
    
}

/** 点击返回 */
-(void)onClickBackBtn
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onDeviceOrientationChange) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //设置状态栏旋转
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/** 保存页面 */
- (void)onClickSaveBtn
{
    UIScrollView *scPrevious = (UIScrollView *)[self viewWithTag:27845000 + _currentPage];
    UIImageView *ivPrevious = (UIImageView *)[scPrevious viewWithTag:kPictureImageViewTag + _currentPage];
    // 屏蔽保存按钮
    _btnRight.enabled = NO;
    
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    [[AMToastView toastView] showLoading:@"正在保存..." cancel:nil];
    
    [_assetsLibrary saveImage:ivPrevious.image toAlbum:@"二手车之家" withCompletionBlock:^(ALAsset *asset, NSError *error) {
        [[AMToastView toastView] hide];
        _btnRight.enabled = YES;
        if (error) {
            NSString *message = nil;
            if (error.code == -3311)
                message = @"保存失败，未允许访问相册";
            else
                message = @"图片保存失败";
            [_vToast showMessage:message icon:kImageRequestError duration:AMToastDurationShort];
        }
        else {
            [_vToast showMessage:@"图片已保存到本地" icon:kImageRequestSuccess duration:AMToastDurationShort];
            _btnRight.enabled = NO;
            // 添加保存索引
            BOOL isExist = NO;
            for (int i = 0; i < _savedPhotos.count; i++) {
                if (_currentPage == [[_savedPhotos objectAtIndex:i] integerValue]) {
                    isExist = YES;
                    break;
                }
            }
            if (!isExist) {
                [_savedPhotos addObject:[NSNumber numberWithInteger:_currentPage]];
            }
        }
    }];
}

#pragma mark - UIScrollViewDelegate
/** 滑动停止 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if(scrollView.tag == 12097666 && _currentPage != (NSInteger)(scrollView.contentOffset.x / _svPhoto.width)){
        // 恢复上一个大小
        if(scrollView.tag != _scrollViewTag){
            UIScrollView *pScrollView = (UIScrollView *)[scrollView viewWithTag:_scrollViewTag];
            [pScrollView setZoomScale:1.0 animated:NO];
        }
        
        // 设置当前页数
        UILabel *labPage = (UILabel *)[self viewWithTag:64555462];
        _currentPage = scrollView.contentOffset.x / _svPhoto.width;
        labPage.text = [NSString stringWithFormat:@"%d/%d",_currentPage + 1,_totalPage];
        
        // 得到当前图片
        [self getImageData];
        
        // 判断保存按钮是否有效
        UIScrollView *svCurrent = (UIScrollView *)[self viewWithTag:27845000 + _currentPage];
        UIImageView *ivCurrent = (UIImageView *)[svCurrent viewWithTag:kPictureImageViewTag + _currentPage];
        
        if (ivCurrent.image) {
            [self setEnableSave];        }
        else {
            _btnRight.enabled = NO;
        }
        
        // 更新缩略图位置
        UIImageView *ivCurrentThumbnail = (UIImageView *)[self viewWithTag:KCarThumbnailTag + _currentPage];
        _ivBackgroundBox.minX = ivCurrentThumbnail.minX - 1;
        
        if (_svThumbnail.contentSize.width > (_isHorizontal ? _vImageBrowse.height : _vImageBrowse.width)) {
            
            CGFloat marginLeft = 0.f;
            
            if (_isHorizontal) {
                marginLeft = _ivBackgroundBox.minX - 245 + (IOS7_OR_LATER ? 0 : 44);
                _isHorizontal = YES;
            } else {//
                marginLeft = _ivBackgroundBox.minX - 118;
                _isHorizontal = NO;
            }
            
            if (marginLeft < 0 )
                marginLeft = 0;
        
            if (!_isHorizontal && ( marginLeft >  _svThumbnail.contentSize.width - self.width))
                marginLeft = _svThumbnail.contentSize.width - self.width;
            if (_isHorizontal && (marginLeft > _svThumbnail.contentSize.width - self.height))
                marginLeft = _svThumbnail.contentSize.width - self.height;
            
            [_svThumbnail setContentOffset:CGPointMake(marginLeft , 0) animated:YES];
        }
        
    }
    
}

/** 调整ImageView的Frame */
- (void)adjustImageViewFrame:(UIScrollView *)scrollViewImage
{
    _scrollViewTag = scrollViewImage.tag;
    CGFloat offsetX = (scrollViewImage.bounds.size.width > scrollViewImage.contentSize.width)?(scrollViewImage.bounds.size.width - scrollViewImage.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollViewImage.bounds.size.height > scrollViewImage.contentSize.height)?(scrollViewImage.bounds.size.height - scrollViewImage.contentSize.height)/2 : 0.0;
    UIImageView *temp = (UIImageView *)[scrollViewImage viewWithTag:kPictureImageViewTag + _currentPage];
    temp.center = CGPointMake(scrollViewImage.contentSize.width/2 + offsetX,scrollViewImage.contentSize.height/2 + offsetY);
}

/** 返回ScrollView上添加的需要缩放的视图 */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // 判断是否可触发缩放
    UIScrollView *svCurrent = (UIScrollView *)[self viewWithTag:27845000 + _currentPage];
    UIImageView *ivCurrent = (UIImageView *)[svCurrent viewWithTag:kPictureImageViewTag + _currentPage];
    if (!ivCurrent.image)
        return nil;
    
    if (scrollView.tag != 12097666)
        return (UIImageView *)[scrollView viewWithTag:kPictureImageViewTag + _currentPage];
    else
        return nil;
}

/** 缩放操作中被调用 */
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self adjustImageViewFrame:scrollView];
}

#pragma mark - api
/** 本页图片 */
-(void)getImageData
{
    for (int i = _currentPage - 1; i < _currentPage + 2; i++) {
        if (i >= 0 && i <= _imageUrls.count - 1) {
            // 当前scrollview
            UIScrollView *svCurrent = (UIScrollView *)[self viewWithTag:27845000 + i];
            UIImageView *ivCurrent = (UIImageView *)[svCurrent viewWithTag:kPictureImageViewTag + i];
            
            if (!ivCurrent.image && i == _currentPage) {
                if (!_vToastImage) {
                    _vToastImage = [[AMToastView alloc] initWithView:_vImageBrowse];
                    [_vToastImage setTouchIntercept:NO];
                }
                [_vToastImage removeFromSuperview];
                _vToastImage.center = svCurrent.center;
                [svCurrent addSubview:_vToastImage];
                [_vToastImage showLoading:@"正在加载中…" cancel:nil];
                
                if (!_vToast) {
                    _vToast = [[AMToastView alloc] initWithView:_vImageBrowse];
                    [_vToast setTouchIntercept:NO];
                }
                [_vToast removeFromSuperview];
                _vToast.center = svCurrent.center;
                [svCurrent addSubview:_vToast];
                
                // 隐藏保存图片按钮
                _btnRight.enabled = NO;
            }
            __weak UIImageView *ivCurrents = ivCurrent;
            
            /**
             *  处理说明 更改大图加载方式
             *  这个方式是直接下载图片, 下载好以后通过 completion block 赋给 UIImageView
             */
//            AMLog(@"[_imageUrls objectAtIndex:i] %@", [_imageUrls objectAtIndex:i]);
            
            [SDWebImageManager.sharedManager downloadImageWithURL:[_imageUrls objectAtIndex:i] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                AMLog(@"image( %d ) %.2f %@", i, (float)receivedSize/expectedSize*100, @"%");
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (!image) {
                    NSString *message = error.code == 406 ? @"图片下载失败" : @"图片下载失败，请检查网络";
                    [self.vToast showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                    [self.vToastImage hide];
                } else {
                    if (ivCurrents.tag - kPictureImageViewTag == _currentPage) {
                        // 显示保存按钮
                        self.btnRight.enabled = YES;
                        [self.vToastImage hide];
                    }
                    UIImageView *ivCurrent = (UIImageView *)[svCurrent viewWithTag:kPictureImageViewTag + ivCurrents.tag - kPictureImageViewTag];
                    // 自适应宽高比
                    if (image) {
                        if (image.width >= image.height) {
                            CGFloat showWidth = self.svPhoto.width * (self.isHorizontal == NO ? 0.95 : 0.8);
                            ivCurrent.frame =  CGRectMake(0, 0, showWidth, image.height * showWidth / image.width);
                        } else {
                            CGFloat showheight = self.svPhoto.height * (self.isHorizontal == NO ? 0.95 : 0.8);
                            ivCurrent.frame =  CGRectMake(0, 0, image.width * showheight / image.height, showheight);
                        }
                    }
                    [ivCurrent setCenter:CGPointMake(self.svPhoto.width / 2, self.svPhoto.height / 2)];
                    
                    [UIView transitionWithView:ivCurrent
                                      duration:kAnimateSpeedFlash
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        [ivCurrent setImage:image];
                                    } completion:^(BOOL finished) {
                                        
                                    }];
                }
            }];
            
            
            
            /**
             *  处理说明
             *
             *  这里有一个 bug, 如果如片已经下载了, 还没有赋值给 UIimageview 的时候, 就用if (!ivCurrents.image)进行检测的话
             *  就会弹出 图片加载失败的 toast, 但是实际上图片已经加载了. 这个是 completion 和 setImage 的先后流程问题.
             *  应该用 if(!image) 对下载的图片进行判断. 
             *  但是这样的话, 在做自适应高宽比的时候 图片会二次闪现. 原因还需要再查一下.
             *
             */
//            [ivCurrent setImageWithURL:[_imageUrls objectAtIndex:i] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//                    if (!ivCurrents.image) {
//                        NSString *message = error.code == 406 ? @"图片下载失败" : @"图片下载失败，请检查网络";
//                        [self.vToast showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
//                        [self.vToastImage hide];
//                    } else {
//                        if (ivCurrents.tag - kPictureImageViewTag == _currentPage) {
//                            // 显示保存按钮
//                            self.btnRight.enabled = YES;
//                            [self.vToastImage hide];
//                        }
//                        UIImageView *ivCurrent = (UIImageView *)[svCurrent viewWithTag:kPictureImageViewTag + ivCurrents.tag - kPictureImageViewTag];
//                        // 自适应宽高比
//                        if (image) {
//                            if (image.width >= image.height) {
//                                CGFloat showWidth = self.svPhoto.width * (self.isHorizontal == NO ? 0.95 : 0.8);
//                                ivCurrent.frame =  CGRectMake(0, 0, showWidth, image.height * showWidth / image.width);
//                            } else {
//                                CGFloat showheight = self.svPhoto.height * (self.isHorizontal == NO ? 0.95 : 0.8);
//                                ivCurrent.frame =  CGRectMake(0, 0, image.width * showheight / image.height, showheight);
//                            }
//                        }
//                        [ivCurrent setCenter:CGPointMake(self.svPhoto.width / 2, self.svPhoto.height / 2)];
//                    }
//                }];
            
            }
    }
}

#pragma mark - Horizontal screen
-(void)onDeviceOrientationChange
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    // 屏蔽平放和大头朝下
    if (orientation == 2 || orientation == 5 || orientation == 6)
        return;
    // 屏蔽重复方向的操作
    if (orientation == _previousOrientation)
        return;
    else
        _previousOrientation = orientation;
    
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    
    // 旋转屏幕还原初始大小
    UIScrollView *svCurrent = (UIScrollView *)[self viewWithTag:27845000 + _currentPage];
    [svCurrent setZoomScale:1.0 animated:YES];
    
    // 设置旋转动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    
    if(orientation == 3 || orientation == 4){
        
        // 设置状态栏旋转
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
        _isHorizontal = YES;
       
        if (orientation == 3)
            _vImageBrowse.transform = CGAffineTransformMakeRotation(M_PI*0.5);
        else
            _vImageBrowse.transform = CGAffineTransformMakeRotation(M_PI*1.5);
        
        // 缩放大视图
        _vImageBrowse.frame = CGRectMake(0, 0, self.width, self.height);
        _svPhoto.frame = CGRectMake(0, 0, self.height, self.width);
        // 标题栏
        _vBar.frame = CGRectMake(0, 0, _vImageBrowse.height, KTitleBarHeight);
        _btnRight.minX = _vImageBrowse.height - _btnRight.width;
        _btnRight.titleEdgeInsets = UIEdgeInsetsMake(0, 0, IOS7_OR_LATER ? 20 : 0, kButtonEdgeInsetsLeft);
        _btnLeft.imageEdgeInsets = UIEdgeInsetsMake(0, kBackButtonEdgeInsetsLeft, IOS7_OR_LATER ? 20 : 0, 0);
        _btnLeft.titleEdgeInsets = UIEdgeInsetsMake(0, kBackButtonEdgeInsetsLeft, IOS7_OR_LATER ? 20 : 0, 0);
        _labTitle.frame = _vBar.bounds;
        // 正在加载中
        if (_vToastImage.isShow) {
            [_vToastImage removeFromSuperview];
            [svCurrent addSubview:_vToastImage];
            _vToastImage.center = svCurrent.center;
            [_vToastImage showLoading:@"正在加载中…" cancel:nil];
            
        }
        // 缩略图
        _vThumbnail.frame = CGRectMake(0, self.width - _vThumbnail.height, _vImageBrowse.height, _vThumbnail.height);
        _svThumbnail.frame = CGRectMake(0, 0, _vThumbnail.width, _svThumbnail.height);
        
        for (int i = 0; i<[_imageUrls count]; i++) {
            UIScrollView *svImage = (UIScrollView *)[_vImageBrowse viewWithTag:27845000+i];
            svImage.frame = CGRectMake(i * self.height, 0, self.height ,self.width);
        }
        _svPhoto.contentSize = CGSizeMake(_svPhoto.width*[_imageUrls count], _svPhoto.height);
        
    }
    else if (orientation == 1){
        
        _isHorizontal = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
        _vImageBrowse.transform = CGAffineTransformIdentity;
        _vImageBrowse.frame = CGRectMake(0, 0, self.width, self.height);
        _svPhoto.frame = CGRectMake(0, 0, self.width, self.height);
        
        for (int i = 0; i<[_imageUrls count]; i++) {
            UIScrollView *svImage = (UIScrollView *)[_vImageBrowse viewWithTag:27845000+i];
            svImage.frame = CGRectMake(i * self.width, 0, self.width ,self.height);
            svImage.contentSize = CGSizeZero;
        }
        
        _svPhoto.contentSize = CGSizeMake(self.width * [_imageUrls count], _svPhoto.height);
        
        // 标题栏
        _vBar.frame = CGRectMake(0, IOS7_OR_LATER ? 0 : 20, _vImageBrowse.width, IOS7_OR_LATER ? KTitleBarHeight + 20 : KTitleBarHeight);
        _labTitle.frame = CGRectMake(0, _vBar.height - KTitleBarHeight, _vBar.width, KTitleBarHeight);
        _btnRight.minX = _vImageBrowse.width - _btnRight.width;
        if (IOS7_OR_LATER) {
            _btnRight.titleEdgeInsets = UIEdgeInsetsMake(20, 0, 0, kButtonEdgeInsetsLeft);
            _btnRight.height = _vBar.height;
            _btnLeft.imageEdgeInsets = UIEdgeInsetsMake(0, kBackButtonEdgeInsetsLeft, -20, 0);
            _btnLeft.titleEdgeInsets = UIEdgeInsetsMake(0, kBackButtonEdgeInsetsLeft, -20, 0);
            _btnLeft.height = _vBar.height;
        }
        // 正在加载中
        if (_vToastImage.isShow) {
            [_vToastImage removeFromSuperview];
            [svCurrent addSubview:_vToastImage];
            _vToastImage.center = svCurrent.center;
            [_vToastImage showLoading:@"正在加载中…" cancel:nil];
        }
        // 缩略图
        _vThumbnail.frame = CGRectMake(0, self.height - _vThumbnail.height, _vImageBrowse.width, _vThumbnail.height);
        _svThumbnail.frame = CGRectMake(0, 0, _vThumbnail.width, _svThumbnail.height);
        
    }
    [UIView commitAnimations];
    
    // 控制非当前显示图片自适应屏幕
    BOOL isHorizontal = NO;
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft ||[UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)
        isHorizontal = YES;
    else
        isHorizontal = NO;
    for (int i = 0; i < [_imageUrls count]; i++) {
        UIScrollView *svImage = (UIScrollView *)[_vImageBrowse viewWithTag:27845000+i];
        UIImageView *ivCurrent = (UIImageView *)[svImage viewWithTag:kPictureImageViewTag + i];
        UIImage *image = ivCurrent.image;
        if (image) {
            // 自适应宽高比
            if (image.width >= image.height) {
                CGFloat showWidth = _svPhoto.width * (isHorizontal == NO ? 0.95 : 0.8);
                ivCurrent.frame =  CGRectMake(0, 0, showWidth, image.height * showWidth / image.width);
            }else{
                CGFloat showheight = _svPhoto.height * (isHorizontal == NO ? 0.95 : 0.8);
                ivCurrent.frame =  CGRectMake(0, 0, image.width * showheight / image.height, showheight);
            }
            [ivCurrent setCenter:CGPointMake(_svPhoto.width / 2, _svPhoto.height / 2)];
        }
        
    }
    // 滑动到应显示位置
    if (orientation == 3)
        [_svPhoto scrollRectToVisible:CGRectMake(_currentPage * self.height, 0, _svPhoto.width, _svPhoto.height) animated:NO];
    else if (orientation == 4)
        [_svPhoto scrollRectToVisible:CGRectMake(_currentPage * self.height, 0, _svPhoto.width, _svPhoto.height) animated:NO];
    else if (orientation == 1)
        [_svPhoto scrollRectToVisible:CGRectMake(_currentPage * self.width, 0, _vImageBrowse.width, _vImageBrowse.height) animated:NO];
}

@end
