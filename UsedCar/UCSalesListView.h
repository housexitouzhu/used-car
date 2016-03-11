//
//  UCSalesListView.h
//  UsedCar
//
//  Created by 张鑫 on 13-12-19.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "SalesPersonModel.h"
#import "UCAddSalesPerson.h"

@class CMSalesListCell;

@interface UCSalesListView : UCView <UITableViewDataSource, UITableViewDelegate, UCAddSalesPersonDelegate>

@property(nonatomic, retain) NSMutableArray *sales;

@end

/** UCSalesListCell */
@interface UCSalesListCell : UITableViewCell

@property (nonatomic, readonly) UILabel *labSalesName;
@property (nonatomic, readonly) UILabel *labSalesPhone;
@property (nonatomic, assign) SalesPersonModel *mSalesPerson;

- (void)makeView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;

@end
