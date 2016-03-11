//
//  ClaimCaseCell.m
//  UsedCar
//
//  Created by Sun Honglin on 14-8-10.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "ClaimCaseCell.h"
#import "UIImageView+WebCacheAnimation.h"
#import "CoreTextView.h"

#define kTopGap 20.0
#define kCaseCellHeight 160.0


@interface ClaimCaseCell ()

@property (retain, nonatomic) UIImageView *ivNew;
@property (retain, nonatomic) UIImageView *ivCarPhoto;

@property (retain, nonatomic) UILabel     *labTitle;// 标题
@property (retain, nonatomic) UILabel     *labPrice;// 价格
@property (retain, nonatomic) UILabel     *labText;//公里数/年份
@property (retain, nonatomic) CoreTextView *tvCaseDesc;
@property (retain, nonatomic) CoreTextView *tvCaseStatus;


@end

@implementation ClaimCaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.width = self.contentView.width = cellWidth;
        
        self.backgroundColor = kColorClear;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 白色背景
        UIView *vBG = [[UIView alloc] initWithFrame:CGRectMake(0, kTopGap, self.width, kCaseCellHeight-kTopGap)];
        vBG.backgroundColor = kColorWhite;
        
        
        // 上中下分隔线
        UIView *hLineT = [[UIView alloc] initLineWithFrame:CGRectMake(0, kTopGap, self.width, kLinePixel) color:kColorNewLine];
        UIView *hLineM = [[UIView alloc] initLineWithFrame:CGRectMake(0, kTopGap+90, self.width, kLinePixel) color:kColorNewLine];
        UIView *hLineB = [[UIView alloc] initLineWithFrame:CGRectMake(0, kCaseCellHeight - kLinePixel, self.width, kLinePixel) color:kColorNewLine];
        
        // NEW标记图片
        _ivNew = [[UIImageView alloc] initWithFrame:CGRectMake(0, kTopGap, 35, 35)];
        [_ivNew setImage:[UIImage imageNamed:@"new_icon_corner"]];
        
        
        // 图片
        _ivCarPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(7, 11+ hLineT.maxY, 90, 67.5)];
        [_ivCarPhoto setImage:[UIImage imageNamed:@"home_default"]];
        
        
        // 标题
        _labTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(_ivCarPhoto.maxX + 10, hLineT.maxY + 10, self.contentView.width - 115, 18)];
        _labTitle.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        _labTitle.numberOfLines = 1;
        _labTitle.font = kFontLarge;
        _labTitle.textColor = kColorNewGray1;
        _labTitle.backgroundColor = [UIColor clearColor];
        
        
        // 公里数/年份
        _labText = [[UILabel alloc] initWithClearFrame:CGRectMake(_ivCarPhoto.maxX + 10, _labTitle.maxY + 8, 130, 15)];
        _labText.font = kFontNormal;
        _labText.textColor = kColorNewGray2;
        _labText.backgroundColor = [UIColor clearColor];
        
        
        // 价格
        _labPrice = [[UILabel alloc] initWithClearFrame:CGRectMake(_labText.minX, _labText.maxY + 8, 90, 15)];
        _labPrice.textAlignment = NSTextAlignmentLeft;
        _labPrice.font = kFontLarge1;
        _labPrice.textColor = kColorNewOrange;
        _labPrice.backgroundColor = [UIColor clearColor];
        
        
        UIImageView *ivArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 36, kTopGap + (90-18)/2 , 18, 18)];
        ivArrow.image = [UIImage imageNamed:@"set_arrow_right"];
        
        //
        _tvCaseDesc = [[CoreTextView alloc] initWithFrame:CGRectZero];
        _tvCaseDesc.backgroundColor = kColorClear;
        _tvCaseDesc.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
        _tvCaseDesc.frame = CGRectMake(10, hLineM.maxY+5, self.width-20, 14);
        
        _tvCaseStatus = [[CoreTextView alloc] initWithFrame:CGRectZero];
        _tvCaseStatus.backgroundColor = kColorClear;
        _tvCaseStatus.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
        
        [self.contentView addSubview:vBG];
        [self.contentView addSubview:hLineT];
        [self.contentView addSubview:_ivCarPhoto];
        [self.contentView addSubview:_ivNew];
        [self.contentView addSubview:_labTitle];
        [self.contentView addSubview:_labText];
        [self.contentView addSubview:_labPrice];
        [self.contentView addSubview:ivArrow];
        [self.contentView addSubview:hLineM];
        [self.contentView addSubview:_tvCaseDesc];
        [self.contentView addSubview:_tvCaseStatus];
        [self.contentView addSubview:hLineB];
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)makeViewWithModel:(ClaimRecordItem*)itemModel{
    
    [_ivCarPhoto sd_setImageWithURL:[NSURL URLWithString:itemModel.AutoIcon] placeholderImage:[UIImage imageNamed:@"home_default"] animate:YES];
    
    if (itemModel.isnew.boolValue) {
        _ivNew.hidden = NO;
    }
    else{
        _ivNew.hidden = YES;
    }
    
    _labTitle.text = itemModel.CarName; //@"宝马7系 2013款 730i 豪华版";
    _labText.text = [NSString stringWithFormat:@"%@万公里/%@年", itemModel.Mileage, itemModel.registeDate]; //@"8.90万公里/2012年";
    _labPrice.text = [NSString stringWithFormat:@"%.2f万", [itemModel.Price floatValue]]; //@"246.20万";
    
    NSString *descHTML = [NSString stringWithFormat:@"<span size='12' color='rgba(144,154,171,1)'>用户<span color='rgba(74,87,108,1)'>%@ <b>%@</b></span> 投诉该车辆为%@</span>", itemModel.username, itemModel.ComplaintDate, itemModel.ClaimerReason];
    
    _tvCaseDesc.attributedString = [NSAttributedString attributedStringWithHTML:descHTML];
    _tvCaseDesc.frame = CGRectMake(10, kTopGap+90+7, self.width-20, [_tvCaseDesc sizeThatFits:CGSizeMake(self.width-20, 14)].height);
    
//    // 如果已经完结
//    if (itemModel.State.integerValue != 0) {
//        _tvCaseDesc.frame = CGRectMake(10, kTopGap+90+7, self.width-20, [_tvCaseDesc sizeThatFits:CGSizeMake(self.width-20, 14)].height);
//    }
//    else{
//        //未完结
//        _tvCaseDesc.frame = CGRectMake(10, kTopGap+90+16, self.width-20, [_tvCaseDesc sizeThatFits:CGSizeMake(self.width-20, 14)].height);
//    }
    
    
    NSString *statusHTML = @"";
    
    if (itemModel.State.integerValue != 0) {
        statusHTML = [NSString stringWithFormat:@"<span size='12' color='rgba(144,154,171,1)' wrap='ellipsis-tail'>%@</span>", itemModel.CheckMark];
    }
    else{
        //<span color='rgba(250,140,0,1)'>
        statusHTML = @"<span size='12' color='rgba(144,154,171,1)'>如有任何疑问请拨打<span color='rgba(74,87,108,1)'><b>010-59857661</b></span>查询</span>";
        //@"<span size='12' color='rgba(144,154,171,1)' wrap='ellipsis-tail'>请于 <span color='rgba(74,87,108,1)'><b>2012-12-12 23:59</b></span> 分前处理，否则视为自动确认</span>";
    }
    
    _tvCaseStatus.attributedString = [NSAttributedString attributedStringWithHTML:statusHTML];
    _tvCaseStatus.frame = CGRectMake(10, _tvCaseDesc.maxY + 5, self.width-20, [_tvCaseStatus sizeThatFits:CGSizeMake(self.width-20, 14)].height);
}


- (void)setIsNewReaded:(BOOL)readed{
    if (readed) {
        _ivNew.hidden = YES;
    }
    else{
        _ivNew.hidden = NO;
    }
}

@end

