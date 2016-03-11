//
//  ShareCarInfoCell.m
//  UsedCar
//
//  Created by Sun Honglin on 14-10-15.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "ShareCarInfoCell.h"
#import "UCCarInfoModel.h"

@interface ShareCarInfoCell ()



@end

@implementation ShareCarInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellWidth:cellWidth];
    if (self) {

        self.width = self.contentView.width = cellWidth;
        self.vShareCount = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 17)];
        self.vShareCount.image = [UIImage imageNamed:@"share_number_bg"];
        
        UIImageView *ivShareIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 3, 8.5, 11)];
        [ivShareIcon setImage:[UIImage imageNamed:@"share_number"]];
        [self.vShareCount addSubview:ivShareIcon];
        
        self.labCount = [[UILabel alloc] initWithFrame:CGRectMake(ivShareIcon.maxX+3, 3.5, 26, 10)];
        self.labCount.backgroundColor = kColorClear;
        [self.labCount setTextColor:kColorWhite];
        [self.labCount setFont:kFontMini];
        [self.labCount setBackgroundColor:kColorClear];
        [self.labCount setTextAlignment:NSTextAlignmentCenter];
        [self.labCount setText:@"0"];
        [self.vShareCount addSubview:self.labCount];
        
        [self.vCellMain addSubview:self.vShareCount];
        
        self.vMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, UCCarInfoCellHeight)];
        [self.vMask setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.3]];
        self.vMask.hidden = YES;
        
        [self.vCellMain addSubview:self.vMask];
        
        self.ivChecked = [[UIImageView alloc] initWithFrame:CGRectMake(-(46-12), (UCCarInfoCellHeight - 22)/2+1, 22, 22)];
        if (IOS8_OR_LATER) {
            self.ivChecked.hidden = YES;
        }
        [self.vCellMain insertSubview:self.ivChecked belowSubview:self.ivCarPhoto];
        
    }
    return self;
}


- (void)makeView:(UCCarInfoModel *)mCarInfo isShowSelect:(BOOL)isShowSelect
{
    [super makeView:mCarInfo isShowSelect:isShowSelect];
    
    //显示隐藏左上角的分享数
    if (mCarInfo.sharetimes.integerValue > 0) {
        self.vShareCount.hidden = NO;
    }
    else{
        self.vShareCount.hidden = YES;
    }
    self.labCount.text = mCarInfo.sharetimes.stringValue;
    
    // 隐藏销售线索车源状态
    _labCarStatus2.hidden = YES;
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    //覆盖掉父类里的显示选中背景的方法
    if (highlighted)
        self.contentView.backgroundColor = kColorWhite;
    else
        self.contentView.backgroundColor = kColorWhite;
}


- (void)setChecked:(BOOL)checked{
    _checked = checked;
    
    [self setCheckedImageChecked:checked];
}

-(void)setCheckedImageChecked:(BOOL)checked{
//    if (self.ivChecked.hidden) {
//        self.ivChecked.hidden = NO;
//    }
    if (checked) {
        self.vMask.hidden = NO;
        self.ivChecked.image = [UIImage imageNamed:@"share_selected"];
    }
    else{
        self.vMask.hidden = YES;
        self.ivChecked.image = [UIImage imageNamed:@"share_notselected"];
    }
}

- (void)setCellToEditingMode:(BOOL)inEditing Animated:(BOOL)animated{
    
    if (animated) {
        [UIView animateWithDuration:kAnimateSpeedFast animations:^{
            if (inEditing) {
                [self.vCellMain setOrigin:CGPointMake(46, 0)];
                self.ivChecked.image = [UIImage imageNamed:@"share_notselected"];
            }
            else{
                [self.vCellMain setOrigin:CGPointMake(0, 0)];
                self.ivChecked.image = [UIImage imageNamed:@"share_notselected"];
            }
        } completion:^(BOOL finished) {
            if (IOS8_OR_LATER) {
                if (inEditing) {
                    self.ivChecked.hidden = NO;
                }
                else{
                    self.ivChecked.hidden = YES;
                }
            }
        }];
    }
    else{
        if (inEditing) {
            [self.vCellMain setOrigin:CGPointMake(46, 0)];
            self.ivChecked.image = [UIImage imageNamed:@"share_notselected"];
            if (IOS8_OR_LATER) {
                self.ivChecked.hidden = NO;
            }
        }
        else{
            [self.vCellMain setOrigin:CGPointMake(0, 0)];
            self.ivChecked.image = [UIImage imageNamed:@"share_notselected"];
            if (IOS8_OR_LATER) {
                self.ivChecked.hidden = YES;
            }
        }
    }
    
}

@end
