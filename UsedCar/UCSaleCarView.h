//
//  UCSaleCarView.h
//  UsedCar
//
//  Created by Alan on 13-11-20.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UISelectorView.h"
#import "AMRadioButton.h"
#import "UCChooseCarView.h"
#import "UCUploadPhotosView.h"

@class UserInfoModel;
@class UCCarInfoEditModel;
@class CMTopBarView;

@protocol UCReleaseCarViewDelegate <NSObject>

@optional

- (void)releaseCarFinish:(UCCarInfoEditModel *)mCarInfoEdit;
- (void)releaseCarClose:(UCCarInfoEditModel *)mCarInfoEdit;

@end

@interface UCSaleCarView : UCView<UIActionSheetDelegate, UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UISelectorViewDelegate, AMRadioButtonDelegate, UCChooseCarViewDelegate, UCUploadPhotosViewDelegate>

@property (nonatomic, weak) id<UCReleaseCarViewDelegate> delegate;
//@property (nonatomic, assign) BOOL isStopCarPhotoRequest; // 是否停止所有图片上传

- (id)initWithFrame:(CGRect)frame carInfoEdit:(UCCarInfoEditModel *)mCarInfoEdit;
//- (id)initWithFrame:(CGRect)frame carInfoEdit:(UCCarInfoEditModel *)mCarInfoEdit userInfo:(UserInfoModel *)mUserInfo;
//- (void)delCarPhotoName:(NSString *)name;
//- (BOOL)replaceimgUrlsOfString:(NSString *)target withString:(NSString *)replacement;

@end