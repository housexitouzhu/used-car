//
//  UCCarDetailView.h
//  UsedCar
//
//  Created by 张鑫 on 13-11-15.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import <MessageUI/MessageUI.h>
#import "UCCarDetailInfoModel.h"
#import "UCCarCompareView.h"
#import "UCThumbnailsView.h"
#import "UCOptionBar.h"
#import "UCChangeScrollView.h"

@class UCFavoritesList;
@class UCCarInfoModel;

typedef enum {
    UCCarDetailViewPromptNewCar = 100,
    UCCarDetailViewPromptExtended,
    UCCarDetailViewPromptAuthentication,
    UCCarDetailViewPromptHaswarranty,
    UCCarDetailViewPromptHasDeposit,
} UCCarDetailViewPrompt;

typedef enum {
    UCCarDetailViewThumbnailsCarPhoto = 200,
    UCCarDetailViewThumbnailsTestReport,
} UCCarDetailViewThumbnails;

@interface UCCarDetailView : UCView <UIScrollViewDelegate,MFMessageComposeViewControllerDelegate, UCCarCompareViewDelegate, UCThumbnailsViewDelegate, UCOptionBarDelegate, UIAlertViewDelegate, UCChangeScrollViewDelegate>

@property (nonatomic, weak) UCFavoritesList *vFavoritesList;
@property (nonatomic, weak) NSMutableArray *mCarLists;

/** 车辆详情 */
- (id)initWithFrame:(CGRect)frame mCarInfo:(UCCarInfoModel *)mCarInfo;
/** 车辆详情可翻页 */
- (id)initTurningDetailViewWithFrame:(CGRect)frame mCarInfo:(UCCarInfoModel *)mCarInfo;
/** IM查看车辆详情 */
- (id)initWithFrame:(CGRect)frame CarID:(NSNumber*)carID;

/** 设置列表页数据源和总数量 */
- (void)setCarInfoModels:(NSMutableArray *)mCarInfos carAllCount:(NSInteger)carAllCount;

@end
