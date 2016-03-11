//
//  ClaimCasesList.h
//  UsedCar
//
//  Created by Sun Honglin on 14-8-10.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClaimRecordModel.h"
#import "ClaimRecordItem.h"

typedef enum : NSUInteger {
    ClaimListTypeFinished = 1,
    ClaimListTypeOnGoing = 2
} ClaimListType;

@protocol ClaimCasesListDelegate;

@interface ClaimCasesList : UIView

<UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UITableView *tableView;
@property (nonatomic, assign) ClaimListType claimListType;
@property (nonatomic, weak) id<ClaimCasesListDelegate> delegate;


@end

@protocol ClaimCasesListDelegate <NSObject>

- (void)ClaimCasesList:(ClaimCasesList*)claimCasesList didSelectItem:(ClaimRecordItem*)claimItem;

@end