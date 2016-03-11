//
//  UCCarPreviewView.h
//  UsedCar
//
//  Created by 张鑫 on 13-11-15.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCCarDetailInfoModel.h"
#import "UCThumbnailsView.h"
#import "UCOptionBar.h"

@class UCCarInfoModel;

typedef enum {
    UCCarPreviewViewPromptNewCar = 100,
    UCCarPreviewViewPromptExtended,
    UCCarPreviewViewPromptAuthentication,
    UCCarPreviewViewPromptHaswarranty,
    UCCarPreviewViewPromptHasDeposit,
} UCCarPreviewViewPrompt;

typedef enum {
    UCCarPreviewViewThumbnailsCarPhoto = 200,
    UCCarPreviewViewThumbnailsTestReport,
} UCCarPreviewViewThumbnails;

@interface UCCarPreviewView : UCView <UIScrollViewDelegate, UCThumbnailsViewDelegate>

/** 发车预览 */
- (id)initWithFrame:(CGRect)frame mCarDetailInfo:(UCCarDetailInfoModel *)mCarDetailInfo isBusiness:(BOOL)isBusiness;

@end
