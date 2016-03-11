//
//  UCLocationView.h
//  UsedCar
//
//  Created by 张鑫 on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiTablesView.h"
#import "MJNIndexView.h"
#import <CoreLocation/CoreLocation.h>

@class UCFilterView;
@class UCAreaMode;

typedef enum LocationStatus{
    LocationStop = 0,
    LocationRunning = 1,
    LocationSuccess = 2,
    LocationFailed = 3
} LocationStatus;

typedef enum {
    UCLocationViewFromFilterView = 0,
    UCLocationViewFromAttentionView,
} UCLocationViewFrom;

@protocol UCLocationViewDelegate;

@interface UCLocationView : UIView <MultiTablesViewDataSource, MultiTablesViewDelegate, MJNIndexViewDataSource, CLLocationManagerDelegate>

@property (nonatomic, weak) UCFilterView *vFilter;
@property (nonatomic, weak) id<UCLocationViewDelegate> delegate;

/** 关注选车城市 */
- (id)initWithFrame:(CGRect)frame areaModel:(UCAreaMode *)mArea;
/** 关闭定位 */
- (void)stopLocation;
/** 设置选中状态 */
-(void)setSelectedCells:(UCAreaMode *)mSelectedArea;

@end

@protocol UCLocationViewDelegate <NSObject>

-(void)UCLocationView:(UCLocationView *)vLocation isChanged:(BOOL)isChanged areaModel:(UCAreaMode *)mArea;

@end
