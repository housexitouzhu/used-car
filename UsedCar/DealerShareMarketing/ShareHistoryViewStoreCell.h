//
//  ShareHistoryViewCell.h
//  UsedCar
//
//  Created by 张鑫 on 14-10-14.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCShareHistoryModel;

@interface ShareHistoryViewStoreCell : UITableViewCell

- (void)makeViewWithModel:(UCShareHistoryModel *)mShare;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;
@end
