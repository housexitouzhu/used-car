//
//  UCUploadPhotosView.m
//  UsedCar
//
//  Created by Alan on 13-11-20.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCUploadPhotosView.h"
#import "UIImage+Util.h"
#import "UIImageView+Util.h"
#import "AMCacheManage.h"
#import "APIHelper.h"
#import "ELCAlbumPickerController.h"
#import "DAProgressOverlayView.h"
#import "UIImageView+WebCache.h"
#import "UCCarPhotoEditView.h"
#import "UCLoginClientView.h"
#import "UCLoginDealerView.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kCarPhotoBtnEmptyAddTag 1498
#define kCarPhotoWidth 80
#define kCarPhotoHeight 60

@interface UCUploadPhotosView ()<UCCarPhotoEditViewDelegate, UIAlertViewDelegate>

@property (nonatomic) BOOL isBusiness; // 是否商家模式
@property (nonatomic) CGFloat photoSpace;
@property (nonatomic, strong) UILabel *labTips;
@property (nonatomic, strong) UIButton *btnLastAdd;
@property (nonatomic, strong) UIScrollView *svCarPhoto;
@property (nonatomic, strong) NSMutableArray *vCarPhotos;
@property (nonatomic, strong) NSMutableArray *imgUrls;
@property (nonatomic) UCCarPhotoViewStyle viewStyle;
@property (nonatomic, strong) NSArray *arraySelected;

@property (nonatomic, strong) AMPhotoPickerController *amPicker;
@property (nonatomic, strong) ELCImagePickerController *elcPicker;

@end

@implementation UCUploadPhotosView 

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame stringImageUrls:nil isBusiness:NO];
}

/** 上传车辆照片 */
- (id)initWithFrame:(CGRect)frame stringImageUrls:(NSString *)urls isBusiness:(BOOL)isBusiness;
{
    self = [super initWithFrame:frame];
    if (self) {
        _viewStyle = UCCarPhotoViewStyleCarPhoto;
        _isBusiness = isBusiness;
        [self initView:urls];
    }
    return self;
}

/** 上传行驶证图片 */
- (id)initDrivingLicenseViewWithFrame:(CGRect)frame stringImageUrls:(NSString *)urls
{
    self = [super initWithFrame:frame];
    if (self) {
        _viewStyle = UCCarPhotoViewStyleDrivingLicense;
        _isBusiness = YES;
        [self initView:urls];
    }
    return self;
}

/** 上传检测报告图片 */
- (id)initWithFrame:(CGRect)frame stringImageUrls:(NSString *)urls
{
    self = [super initWithFrame:frame];
    if (self) {
        _viewStyle = UCCarPhotoViewStyleTextReport;
        _isBusiness = YES;
        [self initView:urls];
    }
    return self;
}

- (void)initView:(NSString *)urls
{
    _photoSpace = (self.width - ((kCarPhotoWidth + 10) * 3)) / 4;
    
    _svCarPhoto = [[UIScrollView alloc] initWithFrame:self.bounds];
    _svCarPhoto.contentSize = CGSizeMake(_svCarPhoto.width + 1, _svCarPhoto.height);

 
    // 车辆照片视图数组
    if (!_vCarPhotos)
        _vCarPhotos = [[NSMutableArray alloc] init];
    else
        [_vCarPhotos removeAllObjects];

    if (_viewStyle == UCCarPhotoViewStyleCarPhoto) {
        _labTips = [[UILabel alloc] initWithClearFrame:CGRectMake(128, 0, _svCarPhoto.width - 125 - 23, _svCarPhoto.height)];
        _labTips.textColor =  kColorNewGray2;
        _labTips.font = [UIFont systemFontOfSize:12];
        _labTips.text = @"添加车辆照片\n上传后可设置首图";
        _labTips.numberOfLines = 2;
        [_svCarPhoto addSubview:_labTips];
    }
    
    // 尾随的添加按钮
    UIImage *imgBtnLastAdd = [UIImage imageNamed:@"publish_photograph_btn"];
    _btnLastAdd = [[UIButton alloc] initWithFrame:CGRectMake(_photoSpace + 1.5, (_svCarPhoto.height - (imgBtnLastAdd.height + 10)) / 2, imgBtnLastAdd.width + 10, imgBtnLastAdd.height + 10)];
    [_btnLastAdd setImage:imgBtnLastAdd forState:UIControlStateNormal];
    [_btnLastAdd addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
    
    [_svCarPhoto addSubview:_btnLastAdd];
    
    [self addSubview:_svCarPhoto];
    
//    [_svCarPhotoView addSubviewReleased:labTips];
//    [_svCarPhotoView addSubviewReleased:btnEmptyAdd];
//    [_svCarPhotoView addSubviewReleased:btnLastAdd];
    
    // 初始化添加图片
    _imgUrls = [[NSMutableArray alloc] init];
    if (urls.length > 0) {
        NSArray *imgUrls = [urls componentsSeparatedByString:@","];
        // 重新添加一遍, 顺便过滤不存在的图片
        for (NSString *imgUrl in imgUrls) {
            [self addCarPhotoName:imgUrl];
        }
    }
}

/** 图片路径集合 */
- (NSString *)stringImageUrls
{
    @synchronized(_imgUrls) {
        NSMutableString *imageUrls = [NSMutableString string];
        for (int i = 0; i < _vCarPhotos.count; i++) {
            UCCarPhotoView *vCarPhoto = [_vCarPhotos objectAtIndex:i];
            [imageUrls appendString:[NSString stringWithFormat:@",%@", vCarPhoto.imageName]];
        }
        if (imageUrls.length > 0)
            return [imageUrls substringFromIndex:1];
        return nil;
    }
}

/**　没有上传成功的个数　*/
- (NSInteger)notUploadNum
{
    NSInteger errorCount = _vCarPhotos.count > 0 ? _vCarPhotos.count : NSNotFound;
    for (int i = 0; i < _vCarPhotos.count; i++) {
        UCCarPhotoView *vCarPhoto = [_vCarPhotos objectAtIndex:i];
        if (vCarPhoto.uploadState == UCCarPhotoViewStateDone)
            errorCount--;
    }
    return errorCount;
}

/** 总共图片数量　*/
- (NSInteger)totalImageNum
{
    return _vCarPhotos.count;
}

/** 停止车辆照片请求 */
- (void)stopCarPhotoRequest
{
    self.isStopCarPhotoRequest = YES;
    for (UCCarPhotoView *vCarPhoto in _vCarPhotos) {
        [vCarPhoto stopRequest];
    }
}

/** 选择图片 */
- (void)chooseImage
{
    if ([_delegate respondsToSelector:@selector(onClickChoosePhotoButton:)]) {
        [_delegate onClickChoosePhotoButton:self];
    }
}

/* 添加车辆照片 */
- (void)addCarPhotoName:(NSString *)name
{
    
    @synchronized(_imgUrls) {
        
        // 未上传图片 & 缓存目录下不存在
        if ([name hasPrefix:@"local"] && ![AMCacheManage isExistsImage:name])
            return;
        
        // 添加照片文件名称
        [_imgUrls addObject:name];
        
        // 提示语隐藏
        if (_viewStyle == UCCarPhotoViewStyleCarPhoto)
            self.labTips.hidden = YES;
        
        // 添加一张车辆照片
        CGRect frame = [self frameWhitCarPhotoCount:_vCarPhotos.count];
        UCCarPhotoView *vCarPhoto = [[UCCarPhotoView alloc] initWithFrame:frame UCUploadPhotosView:self];
        vCarPhoto.imageName = name;
        [_svCarPhoto addSubview:vCarPhoto];
        
        // 车辆照片视图保存到数组方便管理
        [_vCarPhotos addObject:vCarPhoto];
        // 设置首图图标显示
        if ([_vCarPhotos indexOfObject:vCarPhoto] == 0) {
            vCarPhoto.ivFirstIcon.hidden = NO;
        }
        
        // 尾随添加按钮位置
        NSInteger count = NSNotFound;
        if (_viewStyle == UCCarPhotoViewStyleCarPhoto)
            count = 15;
        else if (_viewStyle == UCCarPhotoViewStyleDrivingLicense)
            count = 1;
        else if (_viewStyle == UCCarPhotoViewStyleTextReport)
            count = 3;
        
        if (_vCarPhotos.count >= count)
            _btnLastAdd.frame = frame;
        else {
            frame = [self frameWhitCarPhotoCount:_vCarPhotos.count];
            _btnLastAdd.frame = frame;
        }

        CGFloat contentSizeW = _btnLastAdd.maxX + _photoSpace;
        if (contentSizeW <= _svCarPhoto.width)
            contentSizeW = _svCarPhoto.width + 1;
        _svCarPhoto.contentSize = CGSizeMake(contentSizeW, _svCarPhoto.height);
        [_svCarPhoto setContentOffset:CGPointMake(contentSizeW - _svCarPhoto.width, 0) animated:YES];
    }
}

/* 删除车辆照片 */
- (void)delCarPhotoName:(NSString *)name
{
    @synchronized(_imgUrls) {
        // 删除对应的照片缓存
        [AMCacheManage saveImageWhitName:name data:nil];
        // 删除照片文件名称
        [_imgUrls removeObject:name];
        
        // 删除车辆照片 和 添加按钮调整
        for (int i = 0; i < _vCarPhotos.count; i++) {
            UCCarPhotoView *vCarPhoto = [_vCarPhotos objectAtIndex:i];
            if ([vCarPhoto.imageName isEqualToString:name]) {
                // 删除车辆照片动画
                [UIView animateWithDuration:kAnimateSpeedFast animations:^{
                    // 车辆照片删除动画
                    CGRect moveFrame = vCarPhoto.frame;
                    vCarPhoto.alpha = 0;
                    
                    NSInteger count = _vCarPhotos.count;
                    for (int j = i + 1; j < count; j++) {
                        UCCarPhotoView *vCarPhotoMove = [_vCarPhotos objectAtIndex:j];
                        CGRect frame = vCarPhotoMove.frame;
                        vCarPhotoMove.frame = moveFrame;
                        moveFrame = frame;
                    }
                    
                    NSInteger countTemp = NSNotFound;
                    if (_viewStyle == UCCarPhotoViewStyleCarPhoto)
                        countTemp = 15;
                    else if (_viewStyle == UCCarPhotoViewStyleDrivingLicense)
                        countTemp = 1;
                    else if (_viewStyle == UCCarPhotoViewStyleTextReport)
                        countTemp = 3;
                    
                    // 添加按钮显示调整
                    _btnLastAdd.frame = moveFrame;
                    _btnLastAdd.hidden = (count - 1) >= countTemp;
                    
                    // 滚动布局调整
                    CGFloat contentSizeW =  _btnLastAdd.maxX + _photoSpace;
                    if (contentSizeW <= _svCarPhoto.width)
                        contentSizeW = _svCarPhoto.width + 1;
                    _svCarPhoto.contentSize = CGSizeMake(contentSizeW, _svCarPhoto.height);
                    
                } completion:^(BOOL finished) {
                    [vCarPhoto removeFromSuperview];
                    [_vCarPhotos removeObject:vCarPhoto];
                    // 设置首图图标显示
                    [self setFirstImageIcon];
                    // 提示语显示
                    if (_viewStyle == UCCarPhotoViewStyleCarPhoto)
                        self.labTips.hidden = _vCarPhotos.count != 0;
                }];
                break;
            }
        }
    }
}

- (void)firstCarPhotoName:(NSString *)name
{
    @synchronized(_imgUrls) {
        
        // 过滤第首图重复设置
        if ([name isEqualToString:[_vCarPhotos objectAtIndex:0]])
            return;
        
        // 设为首图的车辆照片位置调整
        [_imgUrls removeObject:name];
        [_imgUrls insertObject:name atIndex:0];
        
        // 先删除需要设为首图的车辆照片 然后插到第一个位置
        for (int i = 0; i < _vCarPhotos.count; i++) {
            UCCarPhotoView *vCarPhoto = [_vCarPhotos objectAtIndex:i];
            if ([vCarPhoto.imageName isEqualToString:name]) {
                // 删除车辆照片动画
                [UIView animateWithDuration:kAnimateSpeedFast animations:^{
                    // 车辆照片删除动画
                    CGRect moveFrame = vCarPhoto.frame;
                    
                    for (int j = i - 1; j >= 0; j--) {
                        UCCarPhotoView *vCarPhotoMove = [_vCarPhotos objectAtIndex:j];
                        CGRect frame = vCarPhotoMove.frame;
                        vCarPhotoMove.frame = moveFrame;
                        moveFrame = frame;
                    }
                    
                    vCarPhoto.frame = moveFrame;
                    
                    // 滚动布局调整到最前面
                    _svCarPhoto.contentOffset = CGPointMake(0, 0);
                    
                } completion:^(BOOL finished) {
                    [_vCarPhotos removeObject:vCarPhoto];
                    [_vCarPhotos insertObject:vCarPhoto atIndex:0];
                    // 设置首图图标显示
                    [self setFirstImageIcon];
                }];
                break;
            }
        }
    }
}

/** 设置首图图标显示 */
- (void)setFirstImageIcon
{
    for (int i = 0; i < _vCarPhotos.count; i++) {
        UCCarPhotoView *vCarPhoto = [_vCarPhotos objectAtIndex:i];
        vCarPhoto.ivFirstIcon.hidden = i != 0;
    }
}

/* 上传成功, 图片的 http路径 替换 local路径 */
- (BOOL)replaceImgUrlsOfString:(NSString *)target withString:(NSString *)replacement
{
    @synchronized(_imgUrls) {
        // 修改对应的图片名称为http
        BOOL isDone = [AMCacheManage replaceImageName:target withString:replacement];
        if (isDone) {
            NSUInteger index = [_imgUrls indexOfObject:target];
            [_imgUrls replaceObjectAtIndex:index withObject:replacement];
        }
        return isDone;
    }
}

/* 车辆照片位置 */
- (CGRect)frameWhitCarPhotoCount:(NSInteger)count
{
    CGRect frame = CGRectMake(0, (self.height - kCarPhotoHeight) / 2 - 5, kCarPhotoWidth + 10, kCarPhotoHeight + 10);
    frame.origin.x = _photoSpace + count * frame.size.width + count * _photoSpace;
    return frame;
}

/** 点击选择上传图片方式按钮 */
- (void)onClickGetPhotoBtn:(UIButton *)btn
{
    NSInteger count = NSNotFound;
    if (_viewStyle == UCCarPhotoViewStyleCarPhoto)
        count = 15;
    else if (_viewStyle == UCCarPhotoViewStyleDrivingLicense)
        count = 1;
    else if (_viewStyle == UCCarPhotoViewStyleTextReport)
        count = 3;
    
    // 拍照
    if (btn.tag == 0) {
        
        //检查相机模式是否可用
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            return;
        }
        
        //获得相机模式下支持的媒体类型
        NSArray* availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        
        BOOL canTakePicture = NO;
        
        for (NSString* mediaType in availableMediaTypes) {
            
            if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
                
                //支持拍照
                canTakePicture = YES;
                break;
            }
            
        }
        
        //检查是否支持拍照
        if (!canTakePicture) {
            
            return;
        }
        
        NSUInteger sourceType = UIImagePickerControllerSourceTypeCamera;
        
        AMPhotoPickerController *photoPickerController = [[AMPhotoPickerController alloc] init];
        photoPickerController.photoDelegate = self;
        photoPickerController.sourceType = sourceType;
        photoPickerController.maxPickerNumber = count - _vCarPhotos.count;
        
        [[MainViewController sharedVCMain] presentViewController:photoPickerController animated:YES completion:NULL];
    }
    // 相册
    else {
        ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
        ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
        [albumController setParent:imagePicker];
        [imagePicker setDelegate:self];
//        albumController.maxSelectNum = count - _vCarPhotos.count;
        
        [[MainViewController sharedVCMain] presentViewController:imagePicker animated:YES completion:NULL];
    }
}

#pragma mark - UIPhotoPickerControllerDelegate
- (void)photoPickerController:(AMPhotoPickerController *)picker didFinishPickingMediaWithInfos:(NSArray *)infos
{
    self.amPicker = picker;
    [[AMToastView toastView] hide];
    if (infos.count>0) {
        if (self.tag == UCCarPhotoViewStyleCarPhoto) {
            self.arraySelected = infos;
            [self showPhotoEditAlert];
        }
        else{
            [self batchSaveImage:infos];
            [picker dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else{
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)photoPickerControllerBeyondMaxNumber:(AMPhotoPickerController *)picker
{
    NSString *strMessage = nil;
    if (_viewStyle == UCCarPhotoViewStyleCarPhoto)
        strMessage = @"最多只能添加15张车辆照片";
    else if (_viewStyle == UCCarPhotoViewStyleDrivingLicense)
        strMessage = @"最多只能添加1张行驶证";
    else if (_viewStyle == UCCarPhotoViewStyleTextReport)
        strMessage = @"最多只能添加3张检测报告";
    
    NSString *message = strMessage;
    [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
}

- (void)photoPickerControllerDidCancel:(AMPhotoPickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    AMLog(@"info %@", info);
    self.elcPicker = picker;
    [[AMToastView toastView] hide];
    if (info.count>0) {
        if (self.tag == UCCarPhotoViewStyleCarPhoto) {
            self.arraySelected = info;
            [self showPhotoEditAlert];
        }
        else{
            [self batchSaveImage:info];
            [picker dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else{
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
}

#pragma mark - 进入照片涂抹
- (void)showPhotoEditAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"是否需要涂抹?"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"涂抹", nil];
    alert.tag = 100;
    [alert show];
}

- (void)enterPhotoEdit{
    
    UCCarPhotoEditView *vPhotoEdit = [[UCCarPhotoEditView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds photoArray:self.arraySelected];
    vPhotoEdit.isSupportGesturesToBack = NO;
    vPhotoEdit.delegate = self;
    [[MainViewController sharedVCMain] openView:vPhotoEdit animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        
        if (buttonIndex == 0) {
            [self batchSaveImage:self.arraySelected];
        }
        else{
            [self enterPhotoEdit];
        }
        
        if (self.amPicker) {
            [self.amPicker dismissViewControllerAnimated:YES completion:nil];
        }
        if (self.elcPicker) {
            [self.elcPicker dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - UCCarPhotoEditViewDelegate
- (void)UCCarPhotoEditView:(UCCarPhotoEditView*)CarPhotoEditView didFinishEditingPhotos:(NSArray*)edittedPhotoArray{
    [self batchSaveImage:edittedPhotoArray];
}

- (void)UCCarPhotoEditView:(UCCarPhotoEditView*)CarPhotoEditView cancelledWithOrignalArray:(NSArray*)orignalArray{
    [self batchSaveImage:orignalArray];
}

#pragma mark -
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)elcImagePickerController:(ELCImagePickerController *)picker didSelcetedNumber:(NSInteger)number
{
    NSInteger maxNumber = NSNotFound;
    NSString *strMessage = nil;
    if (_viewStyle == UCCarPhotoViewStyleCarPhoto) {
        maxNumber = 15;
        strMessage = @"最多只能添加15张车辆照片";
    }
    else if (_viewStyle == UCCarPhotoViewStyleDrivingLicense) {
        maxNumber = 1;
        strMessage = @"最多只能添加1张行驶证";
    }
    else if (_viewStyle == UCCarPhotoViewStyleTextReport) {
        maxNumber = 3;
        strMessage = @"最多只能添加3张检测报告";
    }

    maxNumber = maxNumber - [self totalImageNum];
    
    if (number < maxNumber) {
        return YES;
    } else {
        NSString *message = strMessage;
        [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
        return NO;
    }
    
}

- (void)batchSaveImage:(NSArray *)infos
{
    for (NSDictionary *info in infos) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        [self saveImage:image];
    }
}

- (void)saveImage:(UIImage *)image
{
    // 修剪之4比3比例 & 缩放至800*600
    image = [image imageTo4b3AtSize:CGSizeMake(400, 300)];
    
    if (image) {
        NSString *fileName = [NSString stringWithFormat:@"local%f.jpg", [[NSDate date] timeIntervalSince1970]];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
        // 写入缓存
        [AMCacheManage saveImageWhitName:fileName data:imageData];
        // 添加车牌照片到实体
        [self addCarPhotoName:fileName];
    }
}



@end


@interface UCCarPhotoView ()<UCLoginClientViewDelegate, UCLoginDealerViewDelegate>

@property (nonatomic, strong) UIImageView *ivCarPhoto;
@property (nonatomic, strong) DAProgressOverlayView *vProgress;
@property (nonatomic, strong) APIHelper *apiUploadImage;
//@property (nonatomic, strong) APIHelper *apiDownImage;
@property (nonatomic) BOOL isDelCarPhoto;

@end

@implementation UCCarPhotoView

#define kAlertDelPhotoTag 87463765

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame UCUploadPhotosView:(UCUploadPhotosView *)vUploadPhotos
{
    self = [super initWithFrame:frame];
    if (self) {
        _vUploadPhotos = vUploadPhotos;
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    // 车辆照片
    _ivCarPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, kCarPhotoWidth, kCarPhotoHeight)];
    _ivCarPhoto.userInteractionEnabled = YES;
    
    // 首图
    if (_vUploadPhotos.viewStyle == UCCarPhotoViewStyleCarPhoto) {
        _ivFirstIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstpage_icon"]];
        _ivFirstIcon.maxX = _ivCarPhoto.maxX;
        _ivFirstIcon.maxY = _ivCarPhoto.maxY;
        _ivFirstIcon.hidden = YES;
    }
    
    // 单击手势
    UITapGestureRecognizer *tgrSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickPhoto)];
    tgrSingle.numberOfTapsRequired = 1;
    [_ivCarPhoto addGestureRecognizer:tgrSingle];
    
    // 单击手势
    if (_vUploadPhotos.viewStyle == UCCarPhotoViewStyleCarPhoto) {
        UILongPressGestureRecognizer *lpgrLong = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPhoto:)];
        lpgrLong.minimumPressDuration = 1.0;
        lpgrLong.numberOfTouchesRequired = 1;
//        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPhoto:)];
//        singleTap.numberOfTapsRequired = 1;
//        singleTap.numberOfTouchesRequired = 1;
        
        [_ivCarPhoto addGestureRecognizer:lpgrLong];
    }

    // 删除
    UIImage *imgBtnDel = [UIImage imageNamed:@"publish_delete"];
    UIButton *btnDel = [[UIButton alloc] initWithFrame:CGRectMake(_ivCarPhoto.width - 7, _ivCarPhoto.minY - 8, imgBtnDel.width, imgBtnDel.height)];
    btnDel.exclusiveTouch = YES;
    [btnDel setImage:imgBtnDel forState:UIControlStateNormal];
    [btnDel addTarget:self action:@selector(onClickDel) forControlEvents:UIControlEventTouchUpInside];
    
    // 进度条
    _vProgress = [[DAProgressOverlayView alloc] initWithFrame:_ivCarPhoto.frame];
    _vProgress.userInteractionEnabled = NO;
    
    [self addSubview:_ivCarPhoto];
    if (_vUploadPhotos.viewStyle == UCCarPhotoViewStyleCarPhoto)
        [self addSubview:_ivFirstIcon];
    [self addSubview:_vProgress];
    [self addSubview:btnDel];
}

#pragma mark - public Method
- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    
    // 读取缓存
    NSData *imgData = [AMCacheManage loadImageWhitName:_imageName];
    
    // 检测是否需要上传
    if ([_imageName hasPrefix:@"local"]) {
        if (imgData) {
            _ivCarPhoto.image = [[UIImage imageWithData:imgData] imageToSize:CGSizeMake(kCarPhotoWidth, kCarPhotoHeight)];
            // 图片上传
            [self uploadImageWhitName:imgData];
        }
    } else if ([_imageName hasPrefix:@"http"]) {
        // 设置图片为上传成功
        [self uploadDone];
        // 设置图片
        if (imgData)
            _ivCarPhoto.image = [[UIImage imageWithData:imgData] imageToSize:CGSizeMake(kCarPhotoWidth, kCarPhotoHeight)];
        // 下载图片
        else {
            _ivCarPhoto.image = [UIImage imageNamed:@"home_default"];
            [_ivCarPhoto sd_setImageWithURL:[NSURL URLWithString:_imageName] placeholderImage:[UIImage imageNamed:@"home_default"]];
        }
    }
}

- (void)tapOnPhoto:(UILongPressGestureRecognizer *)gestureRecognizer{
    UIActionSheet *sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"设为首图", @"删除", nil];
    [sheet showInView:self];
}

/** 长按车辆照片按钮 */
- (void)longPressPhoto:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"设为首图", @"删除图片", nil];
        [sheet showInView:self];
    }
}

/** 上传失败 */
- (void)uploadFailed
{
    _uploadState = UCCarPhotoViewStateFailed;
    if (!_isDelCarPhoto)
        _vProgress.progress = -1;
}

/** 上传成功 */
- (void)uploadDone
{
    _uploadState = UCCarPhotoViewStateDone;
    _vProgress.progress = 1;
    [_vProgress displayOperationDidFinishAnimation];
}

/** 停止接口请求 */
- (void)stopRequest
{
    if (_uploadState == UCCarPhotoViewStateUploading) {
        [self uploadFailed];
        [_apiUploadImage cancel];
        //        [_apiDownImage cancel];
    }
}

- (void)openLogin
{
    [self.vUploadPhotos stopCarPhotoRequest];
    
    // 身份失效, 打开登录页面
    if ([AMCacheManage currentUserType] == UserStyleBusiness) {
        UCLoginDealerView *vLoginDealer = [[UCLoginDealerView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds];
        vLoginDealer.delegate = self;
        [[MainViewController sharedVCMain] openView:vLoginDealer animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
    }
    else{
        UCLoginClientView *vLoginClient = [[UCLoginClientView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds loginType:UCLoginClientTypeNormal];
        vLoginClient.delegate = self;
        [[MainViewController sharedVCMain] openView:vLoginClient animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
    }
    
    [AMCacheManage setCurrentUserInfo:nil];
}

#pragma mark - onClickBtn
/** 点击车辆照片删除按钮 */
- (void)onClickDel
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"是否确认删除图片" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
}

/** 点击车辆照片按钮 */
- (void)onClickPhoto
{
    // 图片上传失败才响应
    if (_uploadState == UCCarPhotoViewStateFailed) {
        // 设置图片状态为上传中
        _uploadState = UCCarPhotoViewStateUploading;
        // 读取缓存
        NSData *imgData = [AMCacheManage loadImageWhitName:_imageName];
        // 上传
        [self uploadImageWhitName:imgData];
    }
}

#pragma mark - UCLogin ViewDelegate
- (void)UCLoginClientView:(UCLoginClientView *)vLoginClient loginSuccess:(BOOL)success NeedSNYC:(BOOL)needSYNC SYNCSuccess:(BOOL)SYNCSuccess{
    self.vUploadPhotos.isStopCarPhotoRequest = NO;
    if (success)
        [self onClickPhoto];
    
    [[MainViewController sharedVCMain] closeView:vLoginClient animateOption:AnimateOptionMoveUp];
}

- (void)UCLoginDealerView:(UCLoginDealerView*)vLoginDealer loginSuccess:(BOOL)success{
    self.vUploadPhotos.isStopCarPhotoRequest = NO;
    if (success)
        [self onClickPhoto];
    
    [[MainViewController sharedVCMain] closeView:vLoginDealer animateOption:AnimateOptionMoveUp];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        switch (buttonIndex) {
            case 0:
                [self.vUploadPhotos firstCarPhotoName:_imageName];
                break;
            case 1:
                [self onClickDel];
                break;
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 删除图片
    if (buttonIndex == 1) {
        _isDelCarPhoto = YES;
        [self stopRequest];
        [self.vUploadPhotos delCarPhotoName:self.imageName];
    }
}

#pragma mark - APIHelper
// 上传图片
- (void)uploadImageWhitName:(NSData *)imgData
{
    // 停止上传不执行任何操作
    if (self.vUploadPhotos.isStopCarPhotoRequest)
        return;
    
    if (!_apiUploadImage)
        _apiUploadImage = [[APIHelper alloc] init];
    
    if (imgData) {
        // 设置上传中状态
        self.uploadState = UCCarPhotoViewStateUploading;
        // 初始化图片上传进度
        _vProgress.progress = 0;
        [_vProgress displayOperationWillTriggerAnimation];

        __weak UCCarPhotoView *vCarPhoto = self;
        
        // 设置上传进度回调
        [_apiUploadImage setSendBlock:^(NSInteger written, NSInteger size, NSInteger total) {
            // 停止上传不执行任何操作
            if (vCarPhoto.vUploadPhotos.isStopCarPhotoRequest)
                return;

            vCarPhoto.vProgress.progress = size * 1.0 / (total + total / 12);
        }];
        
        // 设置请求完成后回调方法
        [_apiUploadImage setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
            // 发生错误, 设置图片上传失败
            if (error) {
                [vCarPhoto uploadFailed];
                return;
            }
            
            // 停止上传不执行任何操作
            if (vCarPhoto.vUploadPhotos.isStopCarPhotoRequest)
                return;
            
            NSString *imgUrl = nil;
            if (apiHelper.data.length > 0) {
                BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
                
                if (mBase) {
                    NSString *message = nil;
                    // 上传成功
                    if (mBase.returncode == 0) {
                        // 图片的http路径
                        imgUrl = [mBase.result objectForKey:@"img"];
                        // 图片的 http路径 替换 local路径
                        BOOL isDone = NO;
                        if (vCarPhoto.vUploadPhotos)
                            isDone = [vCarPhoto.vUploadPhotos replaceImgUrlsOfString:vCarPhoto.imageName withString:imgUrl];
                        // 替换成http路径
                        if (isDone)
                            vCarPhoto.imageName = imgUrl;
                    }
                    else if (mBase.returncode == 2049005) {
                        
                        message = @"身份验证失效，请重新登录";
                        [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                        [vCarPhoto uploadFailed];
                        [vCarPhoto openLogin];
                        return;
                    }
//                    else if (mBase.returncode == 2049007)
//                        message = @"图片格式有误";
//                    else if (mBase.returncode == 2049008)
//                        message = @"图片不能大于3M";
//                    else if (mBase.returncode == 2049009)
//                        message = @"图片上传失败";
//                    else
//                        message = @"服务器错误";
                }
            }
            // 没有生成图片URL, 设置图片上传失败
            if (!imgUrl)
                [vCarPhoto uploadFailed];
        }];
        
        // 上传图片
        if (vCarPhoto.vUploadPhotos.isBusiness)
            [_apiUploadImage uploadImage:[AMCacheManage currentUserInfo].userkey imageData:imgData];
        else
            [_apiUploadImage uploadImageNew:imgData];
    }
}

//- (void)downImageWhitName:(NSString *)name
//{
//    if (!_apiDownImage)
//        _apiDownImage = [[APIHelper alloc] init];
//    
//    __weak UCCarPhotoView *vCarPhoto = self;
//    // 设置请求完成后回调方法
//    [_apiDownImage setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
//        if (error) {
//            // 取消请求
//            if (error.code == ConnectionStatusCancel)
//                return;
//        }
//        
//        if (apiHelper.data.length > 0) {
//            vCarPhoto.ivCarPhoto.image = [UIImage imageWithData:apiHelper.data];
//        }
//    }];
//    
//    [_apiDownImage downloadImage:name];
//}

@end
