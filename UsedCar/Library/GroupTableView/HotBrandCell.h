//
//  HotBrandCell.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-9.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HotBrandCellDelegate <NSObject>

-(void)hotBrandCellDidClickAtBrand:(NSString*)brandID andFirstLetter:(NSString*)firstLetter;

@end

@interface HotBrandCell : UITableViewCell

@property (weak, nonatomic) id<HotBrandCellDelegate> delegate;
@property (strong, nonatomic) UIButton *loadingButton;

@end

