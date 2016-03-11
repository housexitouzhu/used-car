//
//  UCUserCarDetailView.h
//  UsedCar
//
//  Created by 张鑫 on 13-12-11.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCCarInfoEditModel.h"
#import "UCCarStatusListView.h"
#import "APIHelper.h"
#import "UCThumbnailsView.h"

typedef enum {
    UCUserCarDetailViewPromptNewCar = 300,
    UCUserCarDetailViewPromptExtended,
} UCUserCarDetailViewPrompt;

typedef enum {
    UCUserCarDetailViewThumbnailsCarPhoto = 400,
    UCUserCarDetailViewThumbnailsTestReport,
} UCUserCarDetailViewThumbnails;

@class UCCarInfoEditModel;

@protocol UCUserCarDetailViewDelegate;

@interface UCUserCarDetailView : UCView <UIScrollViewDelegate, UCThumbnailsViewDelegate>

@property (nonatomic, assign) id delegate;

- (id)initWithFrame:(CGRect)frame userStyle:(UserStyle)userStyle statusStyle:(UCCarStatusListViewStyle)statusStyle carInfoEdeiModel:(UCCarInfoEditModel *)mCarInfo;

@end

@protocol UCUserCarDetailViewDelegate <NSObject>
@optional

- (void)removeCarFromList:(UCCarInfoEditModel *)mCarInfo carOperate:(CarOperate)operate;

@end
