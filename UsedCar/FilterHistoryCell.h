//
//  FilterHistoryCell.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterHistoryCellDelegate <NSObject>

- (void)filterHistoryCellDeleteButtonClicked:(UIButton*)button atIndexPath:(NSIndexPath *)indexPath;

@end

@interface FilterHistoryCell : UITableViewCell

@property (retain, nonatomic) NSIndexPath *indexPath;
@property (retain, nonatomic) UILabel *recordLabel;
@property (retain, nonatomic) UIButton *deleteButton;
@property (retain, nonatomic) id<FilterHistoryCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellHeight:(CGFloat)cellHeight;

@end
