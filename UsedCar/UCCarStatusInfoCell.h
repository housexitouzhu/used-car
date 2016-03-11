//
//  UCCarStatusInfoCell.h
//  UsedCar
//
//  Created by 张鑫 on 13-12-9.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCCarStatusListView.h"
#import "UIImageView+WebCache.h"

#define UCCarStatusInfoCellHeight 84

@class UCCarInfoEditModel;

@interface UCCarStatusInfoCell : UITableViewCell {
    // 近似新车
    UIImageView *_ivNewCar;
    // 延长质保
    UIImageView *_ivWarrantly;
}

@property (nonatomic, readonly) UIButton *btnMoveCell;
@property (nonatomic, readonly) UIImageView *ivCarPhoto;
@property (nonatomic, readonly) UIImageView *ivBtnImage;
@property (nonatomic, readonly) UIView *vCarInfo;
@property (nonatomic, assign) UCCarInfoEditModel *mCarInfoEdit;
@property (nonatomic, assign) UCCarStatusListView *delegateView;

- (void)openCell:(BOOL)isOpenCell btnBackgroundView:(UIView *)vBtnBackground;
- (void)makeView:(UCCarInfoEditModel *)carInfoModel carListState:(UCCarStatusListViewStyle)carListState cellRow:(NSInteger)row;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;

@end
