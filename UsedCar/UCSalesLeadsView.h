//
//  UCSalesLeadsDetailView.h
//  UsedCar
//
//  Created by wangfaquan on 14-4-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCOptionBar.h"
#import "UCSalesLeadsDetailView.h"
#import "UCSalesLeadsListView.h"

typedef enum : NSUInteger {
    BackButtonTypeBack,
    BackButtonTypeClose,
} BackButtonType;

@interface UCSalesLeadsView : UCView<UCOptionBarDelegate, UCSalesLeadsDetailViewDelegate, UCSaleLeadListDelegate>

/** 无效阅读痕迹 */
+ (NSMutableArray *)instanceunAvailablyReadsCount;

/** 有效阅读痕迹 */
+ (NSMutableArray *)instanceavailablyReadsCount;

- (id)initWithFrame:(CGRect)frame backButtonType:(BackButtonType)backBtnType;

@end
