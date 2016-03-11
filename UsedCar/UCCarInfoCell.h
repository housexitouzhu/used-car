//
//  UCCarInfoCell.h
//  UsedCar
//
//  Created by Alan on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCacheAnimation.h"

#define UCCarInfoCellHeight 84

@class UCCarInfoModel;

@interface UCCarInfoCell : UITableViewCell {
    
    // 主列表车源状态
    UILabel *_labCarStatus1;
    
    // 销售线索车源状态
    UILabel *_labCarStatus2;
    
    // 公里数/年份
    UILabel *_labText;
    
    // 选中图片
    UIImageView *_ivSelect;
    // 是否被选中
    BOOL _isSelected;
    
    // 来源文字 + 时间
    UILabel *_labSourceTime;
    
    // 近似新车
    UIImageView *_ivNewCar;
    // 质保 原厂/延长
    UIImageView *_ivWarrantly;
    // 品牌认证
    UIImageView *_ivApprove;
    // 保证金
    UIImageView *_ivDeposit;
    
// 来源图标
//    UIImageView *_ivSource;
}

@property (nonatomic, strong) UIView      *vCellMain;
@property (nonatomic, strong) UIImageView *ivCarPhoto;// 图片
@property (nonatomic, strong) UILabel     *labPrice;// 价格
@property (nonatomic, strong) UILabel     *labTitle;// 标题
@property (strong, nonatomic) UILabel     *statusLabel;// 新旧关注 NEW 标识

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;
- (void)makeView:(UCCarInfoModel *)mCarInfo isShowSelect:(BOOL)isShowSelect;
/** 处理图片的状态 */
- (void)setImageWithSelectedState:(NSNumber *)isShowSelect;

@end
