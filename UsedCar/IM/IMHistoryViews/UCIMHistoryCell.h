//
//  UCIMHistoryCell.h
//  UsedCar
//
//  Created by 张鑫 on 14/11/24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kHistoryCellHeight  75

@class StorageContact;

@interface UCIMHistoryCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;
- (void)makeView:(StorageContact *)mIMHistory;
@end
