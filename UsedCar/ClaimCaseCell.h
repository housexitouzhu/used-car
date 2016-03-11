//
//  ClaimCaseCell.h
//  UsedCar
//
//  Created by Sun Honglin on 14-8-10.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClaimRecordItem.h"

@interface ClaimCaseCell : UITableViewCell

- (void)makeViewWithModel:(ClaimRecordItem*)itemModel;

- (void)setIsNewReaded:(BOOL)readed;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;

@end
