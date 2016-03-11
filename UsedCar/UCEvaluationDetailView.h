//
//  UCEvaluationDetailView.h
//  UsedCar
//
//  Created by 张鑫 on 14-1-1.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCSaleCarRootView.h"
#import "UCSaleCarView.h"

@class UCEvaluationModel;
@class UCEvaluationPriceModel;
@class UCCarInfoEditModel;

typedef enum : NSUInteger {
    UCEvaluationDetailViewTypeSellCar,
    UCEvaluationDetailViewTypeBuyCar,
} UCEvaluationDetailViewType;

@protocol UCEvaluationDetailViewDelegate;

@interface UCEvaluationDetailView : UCView <UCSaleCarRootViewDelegate, UCReleaseCarViewDelegate>

@property (nonatomic, weak) id delegate;

- (id)initWithFrame:(CGRect)frame evaluationModel:(UCEvaluationModel *)mEvaluation carInfoEditModel:(UCCarInfoEditModel *)mCarInfoEdit viewType:(UCEvaluationDetailViewType)viewType;
- (void)reloadPriceView:(UCEvaluationPriceModel *)mEPrice;

@end

@protocol UCEvaluationDetailViewDelegate <NSObject>

- (void)didSuccessedReleaseCarWtihUCEvaluationDetailView:(UCEvaluationDetailView *)vEvaluationDetail;

@end
