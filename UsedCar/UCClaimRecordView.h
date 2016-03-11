//
//  UCClaimRecordView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-8-8.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "ClaimCasesList.h"

typedef enum {
    UCClaimRecordViewStyleNormal,
    UCClaimRecordViewStylePopUp
}UCClaimRecordViewStyle;

@interface UCClaimRecordView : UCView

@property (nonatomic, assign) UCClaimRecordViewStyle viewStyle;
@property (nonatomic, assign) ClaimListType claimType;
@property (nonatomic, assign) BOOL shouldClearNotifyMarkAfterClose;

- (id)initWithFrame:(CGRect)frame withStyle:(UCClaimRecordViewStyle)style ClaimType:(ClaimListType)claimType;

@end
