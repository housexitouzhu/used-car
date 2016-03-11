//
//  UCSalesLeadsDetailView.h
//  UsedCar
//
//  Created by 张鑫 on 14-4-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCSalesLeadsModel.h"
#import "UCCarListView.h"

@protocol UCSalesLeadsDetailViewDelegate;

typedef enum {
    UCSalesLeadsDetailViewStyleUntreated = 0,
    UCSalesLeadsDetailViewStyleProcessed,
    UCSalesLeadsDetailViewStyleInvalidClues,
    
} UCSalesLeadsDetailViewStyle;

@interface UCSalesLeadsDetailView : UCView <UIAlertViewDelegate, UITextViewDelegate, UCCarListViewDelegate>

@property (nonatomic, weak) id<UCSalesLeadsDetailViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame viewStyle:(UCSalesLeadsDetailViewStyle)viewStyle saleLeadModel:(UCSalesLeadsModel *)mSaleLead;

@end

@protocol UCSalesLeadsDetailViewDelegate <NSObject>

- (void)UCSalesLeadsDetailView:(UCSalesLeadsDetailView *)vSalesLeadsDetail ignoreSuccess:(UCSalesLeadsModel *)mSaleLead;
- (void)UCSalesLeadsDetailView:(UCSalesLeadsDetailView *)vSalesLeadsDetail handleSuccess:(UCSalesLeadsModel *)mSaleLead;

@end