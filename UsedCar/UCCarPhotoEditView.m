//
//  UCCarPhotoEditView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-6.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCCarPhotoEditView.h"
#import "UCTopBar.h"
#import "SHLDrawScrollView.h"
#import "SHLDrawView.h"
#import "ALAssetsLibrary+Util.h"
#import "AMCacheManage.h"

@interface UCCarPhotoEditView ()<UIScrollViewDelegate, SHLDrawCanvasDelegate, UIGestureRecognizerDelegate>
{
    NSInteger currentPage;
    CGFloat scale;
    BOOL currentImageDrawed;
    BOOL photoArrayChanged;
    BOOL barHidden;
}

@property (nonatomic, strong) NSMutableArray *arrCellViews;

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UIView *vBottom;
@property (nonatomic, strong) UIButton *btnDraw;
@property (nonatomic, strong) UIButton *btnReset;
@property (nonatomic, strong) UIButton *btnDone;
@property (nonatomic, strong) EditScrollView *vScroll;
@property (nonatomic, strong) SHLDrawCanvas *currentCanvas;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end


@implementation UCCarPhotoEditView

- (id)initWithFrame:(CGRect)frame photoArray:(NSArray*)array
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.photoArray = [[NSMutableArray alloc] initWithArray:array];
        self.arrCellViews = [NSMutableArray new];
        
        [self initView];
    }
    return self;
}

- (void)viewWillShow:(BOOL)animated
{
    [super viewWillShow:animated];
    self.isSupportGesturesToBack = NO;
    //复写一个空的, 用来 hack 取消父类 UCView 里的手势
}

- (void)initView{
    [UMStatistics event:pv_4_1_saleCar_Person_Photo_Edit];
    
    if ([AMCacheManage currentUserType] == UserStyleBusiness) {
        [UMSAgent postEvent:salecar_business_photo_edit_pv page_name:NSStringFromClass(self.class)];
    }
    else{
        [UMSAgent postEvent:salecar_person_photo_edit_pv page_name:NSStringFromClass(self.class)];
    }
    
    self.backgroundColor =  [UIColor blackColor];
    
    self.vScroll = [[EditScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.vScroll.backgroundColor = kColorClear;
    self.vScroll.pagingEnabled = YES;
    self.vScroll.delegate = self;
    self.vScroll.showsVerticalScrollIndicator = NO;
    self.vScroll.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.vScroll];
    
    self.tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:self.tbTop];
    
    self.vBottom = [self createBottomBar:CGRectMake(0, self.height - 44, self.width, 44)];
    [self addSubview:self.vBottom];
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapScrollView:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.delegate = self;
    [self.vScroll addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapScrollView:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.delegate = self;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.vScroll addGestureRecognizer:singleTap];
    
    [self setUpScrollViewContent];
    
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    [vTopBar setBackgroundColor:[UIColor colorWithRed:31.0/255 green:31.0/255 blue:31.0/255 alpha:1.0]];
    // 标题
    [vTopBar.btnTitle setTitle:[@"选择照片" stringByAppendingFormat:@"1/%d", self.photoArray.count]  forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"关闭"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

- (UIView *)createBottomBar:(CGRect)frame{
    UIView *baseView = [[UIView alloc] initWithFrame:frame];
    [baseView setBackgroundColor:[UIColor colorWithRed:31.0/255 green:31.0/255 blue:31.0/255 alpha:1.0]];
    
    self.btnDraw = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnDraw.frame = CGRectMake((self.width - 50)/2, 0, 50, 44);
    self.btnDraw.titleLabel.font = kFontLarge1;
    [self.btnDraw setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self.btnDraw setTitle:@"涂抹" forState:UIControlStateNormal];
    [self.btnDraw addTarget:self action:@selector(onClickDrawBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnReset = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnReset.frame = CGRectMake(0, 0, 50, 44);
    self.btnReset.titleLabel.font = kFontLarge1;
    [self.btnReset setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self.btnReset setTitle:@"复原" forState:UIControlStateNormal];
    [self.btnReset addTarget:self action:@selector(onClickResetBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnDone.frame = CGRectMake((self.width - 50), 0, 50, 44);
    self.btnDone.titleLabel.font = kFontLarge1;
    [self.btnDone setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self.btnDone setTitle:@"完成" forState:UIControlStateNormal];
    [self.btnDone addTarget:self action:@selector(onClickDoneBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnReset.hidden = YES;
    self.btnDone.hidden = YES;
    
    [baseView addSubview:self.btnReset];
    [baseView addSubview:self.btnDraw];
    [baseView addSubview:self.btnDone];
    
    return baseView;
}

#pragma mark - button actions
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    if (photoArrayChanged) {
        if ([self.delegate respondsToSelector:@selector(UCCarPhotoEditView:didFinishEditingPhotos:)]) {
            [self.delegate UCCarPhotoEditView:self didFinishEditingPhotos:self.photoArray];
        }
    }
    else{
        if ([self.delegate respondsToSelector:@selector(UCCarPhotoEditView:cancelledWithOrignalArray:)]) {
            [self.delegate UCCarPhotoEditView:self cancelledWithOrignalArray:self.photoArray];
        }
    }
    
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveUp];
}

- (void)onClickDrawBtn:(UIButton *)btn{
    [UMStatistics event:c_4_1_saleCar_Person_Photo_Edit_Modify];
    [UMStatistics event:pv_4_1_saleCar_Person_Photo_Edit_Modify];
    
    self.btnDraw.hidden = YES;
    self.btnDone.hidden = NO;
    
    [self setViewInDrawingMode:YES];
}

- (void)onClickResetBtn:(UIButton *)btn{
    self.btnReset.hidden = YES;
    currentImageDrawed = NO;
    [self.currentCanvas removeImageDrawed];
}

- (void)onClickDoneBtn:(UIButton *)btn{
    self.btnDraw.hidden = NO;
    self.btnReset.hidden = YES;
    self.btnDone.hidden = YES;
    
    if (currentImageDrawed) {
        [UMStatistics event:c_4_1_saleCar_Person_Photo_Edit_Modify_Done];
        [self mergeDrawToImage];
        currentImageDrawed = NO;
    }
    else{
        SHLDrawScrollView *svDraw = [self.arrCellViews objectAtIndex:currentPage-1];
        [svDraw setZoomScale:1.0 animated:YES];
        [self setViewInDrawingMode:NO];
    }
}

- (void)onTapScrollView:(UITapGestureRecognizer*)tapGesture{
    
    if (!self.vScroll.isDrawing) {
        if(tapGesture.numberOfTapsRequired == 1){
            
            CGRect topFrame = self.tbTop.frame;
            CGRect bottomFrame = self.vBottom.frame;
            
            if (barHidden) {
                
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                
                topFrame.origin.y += 64;
                bottomFrame.origin.y -= 44;
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                [UIView setAnimationDuration:kAnimateSpeedNormal];
                self.tbTop.frame = topFrame;
                self.vBottom.frame = bottomFrame;
                [UIView commitAnimations];
                barHidden = NO;
            }
            else{
                [UMStatistics event:c_4_1_saleCar_Person_Photo_Edit_FullScreen];
                
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                
                topFrame.origin.y -= 64;
                bottomFrame.origin.y += 44;
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                [UIView setAnimationDuration:kAnimateSpeedNormal];
                self.tbTop.frame = topFrame;
                self.vBottom.frame = bottomFrame;
                [UIView commitAnimations];
                barHidden = YES;
            }
        }
        else if (tapGesture.numberOfTapsRequired == 2){
            SHLDrawScrollView *svDraw = [self.arrCellViews objectAtIndex:currentPage-1];
            SHLDrawView *vDraw = [svDraw.subviews firstObject];
            CGPoint pointInView = [tapGesture locationInView:vDraw];
            
            // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
            CGFloat newZoomScale = svDraw.zoomScale * 2.0f;
            newZoomScale = MIN(newZoomScale, svDraw.maximumZoomScale);
            
            // Figure out the rect we want to zoom to, then zoom to it
            CGSize scrollViewSize = self.bounds.size;
            
            CGFloat w = scrollViewSize.width / newZoomScale;
            CGFloat h = scrollViewSize.height / newZoomScale;
            CGFloat x = pointInView.x - (w / 2.0f);
            CGFloat y = pointInView.y - (h / 2.0f);
            
            CGRect rectToZoomTo = CGRectMake(x, y, w, h);
            
            [svDraw zoomToRect:rectToZoomTo animated:YES];
        }
    }
}



#pragma mark - 方法

- (void)setViewInDrawingMode:(BOOL)isDrawing{
    if (isDrawing) {
        
        SHLDrawScrollView *svDraw = [self.arrCellViews objectAtIndex:currentPage-1];
        svDraw.isDrawing = YES;
        svDraw.delaysContentTouches=NO;
        svDraw.canCancelContentTouches= NO;
        
        SHLDrawView *vDraw = [svDraw.subviews firstObject];
        vDraw.drawCanvas.selectedColor = [UIColor colorWithRed:31.0/255 green:31.0/255 blue:31.0/255 alpha:1.0];
        vDraw.drawCanvas.userInteractionEnabled = YES;
        [vDraw.drawCanvas setDrawMode:SHLDrawModePaint];
        
        self.vScroll.isDrawing = YES;
        self.vScroll.delaysContentTouches=NO;
        self.vScroll.canCancelContentTouches= NO;
    }
    else{
        
        SHLDrawScrollView *svDraw = [self.arrCellViews objectAtIndex:currentPage-1];
        svDraw.isDrawing = NO;
        svDraw.delaysContentTouches=YES;
        svDraw.canCancelContentTouches= YES;
        
        SHLDrawView *vDraw = [svDraw.subviews firstObject];
        vDraw.drawCanvas.userInteractionEnabled = NO;
        [vDraw.drawCanvas setDrawMode:SHLDrawModeNone];
        [svDraw setContentSize:vDraw.size];
        
        self.vScroll.isDrawing = NO;
        self.vScroll.delaysContentTouches=YES;
        self.vScroll.canCancelContentTouches= YES;
        [self.vScroll setContentSize:CGSizeMake(self.width*self.photoArray.count, self.vScroll.height)];
    }
}


- (void)mergeDrawToImage{
    
    SHLDrawScrollView *svDraw = [self.arrCellViews objectAtIndex:currentPage-1];
    SHLDrawView *vDraw = [svDraw.subviews firstObject];
    
    CGSize finalSize = [vDraw.image size];
    UIGraphicsBeginImageContextWithOptions(finalSize, NO, [UIScreen mainScreen].scale); //这里要根据屏幕的密度来创建, 否则图片会失真变虚
    [vDraw.image drawInRect:CGRectMake(0,0,finalSize.width,finalSize.height)];
    [vDraw.drawCanvas.drawImage drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height )];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [vDraw setImage:newImage];
    [vDraw.drawCanvas setDrawImage:nil];
    [self saveImageToDisk:newImage scrollCell:svDraw];
}

- (void)saveImageToDisk:(UIImage*)image scrollCell:(SHLDrawScrollView*)drawScroll{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    [[AMToastView toastView] showLoading:@"正在保存..." cancel:nil];
    
    [_assetsLibrary saveImage:image toAlbum:@"二手车之家" withCompletionBlock:^(ALAsset *asset, NSError *error) {
        
        if (error) {
            NSString *message = nil;
            if (error.code == -3311)
                message = @"保存失败，未允许访问相册";
            else
                message = @"图片保存失败";
            [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationShort];
        }
        else {
            [[AMToastView toastView] showMessage:@"图片已保存到本地" icon:kImageRequestSuccess duration:AMToastDurationNormal];
            
            NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
            [workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
            [workingDictionary setObject:image forKey:@"UIImagePickerControllerOriginalImage"];
            [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
            
            [self.photoArray replaceObjectAtIndex:currentPage-1 withObject:workingDictionary];
            
            [drawScroll setZoomScale:1.0 animated:YES];
            SHLDrawView *vDraw = [drawScroll.subviews firstObject];
            [vDraw setImage:image];
            photoArrayChanged = YES;
            
            [self setViewInDrawingMode:NO];
        }
    }];
}

#pragma mark - 加载 scroll view 的方法

- (void)setUpScrollViewContent{
    
    scale = 0;
    for (int i = 0; i<self.photoArray.count; i++) {
        NSDictionary *info = [self.photoArray objectAtIndex:i];
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        SHLDrawScrollView *svDraw = [[SHLDrawScrollView alloc] initWithFrame:CGRectMake(self.vScroll.width*i, 0, self.vScroll.width, self.vScroll.height)];
        svDraw.backgroundColor = kColorClear;
        svDraw.showsVerticalScrollIndicator = NO;
        svDraw.showsHorizontalScrollIndicator = NO;
        svDraw.delegate = self;
        svDraw.minimumZoomScale = 1.0;
        svDraw.maximumZoomScale = 4.0;
        svDraw.tag = i;
        svDraw.scrollEnabled = NO;
        
        SHLDrawView *drawView = [[SHLDrawView alloc] initWithImage:image andWidth:svDraw.width];
        drawView.drawCanvas.selectedColor = [UIColor colorWithRed:0.33 green:0.37 blue:0.45 alpha:1.0];
        [drawView setOrigin:CGPointMake(0, (svDraw.height - drawView.height)/2)];
        drawView.tag = i;
        drawView.drawCanvas.tag = i;
        drawView.drawCanvas.delegate = self;
        
        [svDraw addSubview:drawView];
        [svDraw setContentSize:drawView.size];
        [self.arrCellViews addObject:svDraw];
        [self.vScroll addSubview:svDraw];
    }
    
//    for (int i = 0; i < self.arrCellViews.count; i++) {
//        SHLDrawScrollView *svDraw = [self.arrCellViews objectAtIndex:i];
//        [svDraw setOrigin:CGPointMake(self.vScroll.width*i, 0)]; //(self.vScroll.height-svDraw.height)/2
//        [self.vScroll addSubview:svDraw];
//    }
    currentPage = 1;
    [self.vScroll setContentSize:CGSizeMake(self.vScroll.width*self.arrCellViews.count, self.vScroll.height)];
}

- (int)validPageValue:(NSInteger)value {
    
    if(value == -1) value = self.arrCellViews.count - 1;
    if(value == self.arrCellViews.count) value = 0;
    
    return value;
    
}


#pragma mark - UIScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if ([scrollView isKindOfClass:[EditScrollView class]]) {
        int x = self.vScroll.contentOffset.x;
        currentPage = x/self.width + 1;
        
        if (currentPage < 1) {
            currentPage = 1;
        }
        
//        AMLog(@"currentPage %d", currentPage);
        
        [self.tbTop.btnTitle setTitle:[@"选择照片" stringByAppendingFormat:@"%d/%d", currentPage,self.photoArray.count]  forState:UIControlStateNormal];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    if ([scrollView isKindOfClass:[EditScrollView class]]) {
//        int x = self.vScroll.contentOffset.x;
//        currentPage = x/self.width + 1;
//        AMLog(@"currentPage %d", currentPage);
//        
//        [self.tbTop.btnTitle setTitle:[@"选择照片" stringByAppendingFormat:@"%d/%d", currentPage,self.photoArray.count]  forState:UIControlStateNormal];
//    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    if ([scrollView isKindOfClass:[SHLDrawScrollView class]]) {
        scale = scrollView.zoomScale;
//        AMLog(@"scale: %f", scale);
        
        SHLDrawScrollView *svDraw = [self.arrCellViews objectAtIndex:currentPage-1];
        SHLDrawView *vDraw = [[svDraw subviews] firstObject];
        CGRect bgFrame = [self centeredFrameForScrollView:svDraw andUIView:vDraw];
        vDraw.frame = bgFrame;
    }
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if ([scrollView isKindOfClass:[SHLDrawScrollView class]]) {
        SHLDrawView *vDraw = [[[self.arrCellViews objectAtIndex:currentPage-1] subviews] firstObject];
        return vDraw;
    }
    else{
        return nil;
    }
}

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    
    return frameToCenter;
}

#pragma mark - SHLDrawCanvasDelegate

- (void)imageDrawedOnCanvas:(SHLDrawCanvas*)canvas{
    if (self.btnReset.hidden) {
        self.btnReset.hidden = NO;
    }
    self.currentCanvas = canvas;
    currentImageDrawed = YES;
}

#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
////    AMLog(@"gestureRecognizer %@ \ntouch %@ \nisKindOfClass%d \n------------------------", gestureRecognizer, touch, [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]);
//    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
//        if (self.vScroll.isDrawing && [touch.view isKindOfClass:[EditScrollView class]]) {
//            return NO;
//        }
//        else{
//            return YES;
//        }
//    }
//    else{
//        return NO;
//    }
//}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    AMLog(@"touchesBegan touches %@", touches);
//}

@end

#pragma mark - 本页使用的横滚 scrollview

@implementation EditScrollView

//- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    UIView* result = [super hitTest:point withEvent:event];
//    
//    if ([result.superview isKindOfClass:[UCCarPhotoEditView class]])
//    {
//        self.scrollEnabled = NO;
//    }
//    else
//    {
//        self.scrollEnabled = YES;
//    }
//    return result;
//}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    UITouch *touch = [[event allTouches] anyObject];
//if ([touch tapCount]==2) {
//    NSLog(@"双击");
//}
//}
//
//- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
//{
//        AMLog(@"touchesShouldBegin touchs:%@ \nevent%@ \nview%@ \n--------------", touches, event, view);
//    if (self.isDrawing && [view isKindOfClass:[SHLDrawCanvas class]]) {
//        return YES;
//    }
//    else{
//        return NO;
//    }
//}
//- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
//{
//    AMLog(@"touches %@ \nevent %@ \nview:%@ \n----------------", touches, event, view);
//    return YES;
//    if (self.isDrawing) { //[view isKindOfClass:[SHLDrawScrollView class]]
//        return YES;
//    }
//    else{
//        return NO;
//    }
//}
//
//- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
//    if (!self.isDrawing && self.panGestureRecognizer) {
//        return YES;
//    }
//    else{
//        return NO;
//    }
//}

@end

