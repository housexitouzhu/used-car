//
//  UCUploadPhotosView.h
//  UsedCar
//
//  Created by Alan on 13-11-20.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMPhotoPickerController.h"
#import "ELCImagePickerController.h"

typedef enum {
    UCCarPhotoViewStateUploading = 0,
    UCCarPhotoViewStateFailed,
    UCCarPhotoViewStateDone,
} UCCarPhotoViewState;

typedef enum {
    UCCarPhotoViewStyleCarPhoto = 0,
    UCCarPhotoViewStyleDrivingLicense,
    UCCarPhotoViewStyleTextReport,
} UCCarPhotoViewStyle;

@class APIHelper;

@protocol UCUploadPhotosViewDelegate;

@interface UCUploadPhotosView : UIView <UIScrollViewDelegate, AMPhotoPickerControllerDelegate, ELCImagePickerControllerDelegate>

@property (nonatomic) BOOL isStopCarPhotoRequest;
@property (nonatomic, weak) id <UCUploadPhotosViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame stringImageUrls:(NSString *)urls isBusiness:(BOOL)isBusiness;
/** 上传行驶证图片 */
- (id)initDrivingLicenseViewWithFrame:(CGRect)frame stringImageUrls:(NSString *)urls;
- (id)initWithFrame:(CGRect)frame stringImageUrls:(NSString *)urls;
- (BOOL)replaceImgUrlsOfString:(NSString *)target withString:(NSString *)replacement;
- (void)stopCarPhotoRequest;
- (NSInteger)totalImageNum;
- (NSInteger)notUploadNum;
- (NSString *)stringImageUrls;
- (void)onClickGetPhotoBtn:(UIButton *)btn;

@end

@protocol UCUploadPhotosViewDelegate <NSObject>
@optional

- (void)onClickChoosePhotoButton:(UCUploadPhotosView *)vUploadPhoto;

@end


@interface UCCarPhotoView : UIView <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) UCUploadPhotosView *vUploadPhotos;
@property (nonatomic, strong) UIImageView *ivFirstIcon;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic) UCCarPhotoViewState uploadState;

- (id)initWithFrame:(CGRect)frame UCUploadPhotosView:(UCUploadPhotosView *)vUploadPhotos;
- (void)stopRequest;

@end