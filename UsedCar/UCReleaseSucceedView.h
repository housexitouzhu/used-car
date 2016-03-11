//
//  UCReleaseSucceedView.h
//  UsedCar
//
//  Created by Alan on 13-12-11.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"

typedef enum : NSUInteger {
    FromViewTypeSaleCar,
    FromViewTypeEditCar,
} FromViewType;

@class UCCarInfoEditModel;

@protocol UCReleaseSucceedViewDelegate;

@interface UCReleaseSucceedView : UCView

- (id)initWithFrame:(CGRect)frame isBusiness:(BOOL)isBusiness mCarInfoEdit:(UCCarInfoEditModel *)mCarInfoEdit fromView:(FromViewType)viewType;

@property(nonatomic, weak) id delegate;
@property(nonatomic) FromViewType viewType;
@property (nonatomic) BOOL isBusiness;

@end

@protocol UCReleaseSucceedViewDelegate <NSObject>

- (void)didSelectedReleaseAgain:(UCReleaseSucceedView *)vReleaseSuccessed;

@end
