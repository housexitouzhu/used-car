//
//  InfoBarView.m
//  UsedCar
//
//  Created by 张鑫 on 14-9-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "InfoBarView.h"
#import "UCMainView.h"
#import "UIImage+Util.h"
#import "JSBadgeView.h"
#import "AMCacheManage.h"

#define kInfoBarCount            200

@implementation InfoBarView

- (id)initWithUserStyle:(UserStyle)userStyle
{
    self = [super init];
    if (self) {
        self.backgroundColor = kColorClear;
        [self initViewWithUserStyle:userStyle];
    }
    return self;
}

- (void)initViewWithUserStyle:(UserStyle)userSytle
{
    [self creatUserStyleViewWithUserStyle:userSytle];
}

#pragma mark - Public Method
- (void)creatUserStyleViewWithUserStyle:(UserStyle)userStyle
{
    // 移除所有视图
    // 无状态
    if (userStyle == UserStyleNone || userStyle == UserStylePhone) {
        [self creatUserStyleNoneViewWithSize:CGSizeMake([UCMainView sharedMainView].width, 90)];
    }
    else if (userStyle == UserStyleBusiness) {
        [self creatUserStyleBusinessViewWithSize];
    }
    else if (userStyle == UserStylePersonal) {
        [self creatUserStyleNoneViewWithSize:CGSizeMake([UCMainView sharedMainView].width, 90)];
    }
}

/** 无身份视图 */
- (void)creatUserStyleNoneViewWithSize:(CGSize)size
{
    /** 创建用户身份视图 */
    self.size = size;
    
    NSArray *titles = @[@"收藏的车", @"订阅的车", @"咨询记录"];
    NSArray *images = @[@"my_list_collection", @"my_list_subscribe", @"my_list_consultation"];
    NSArray *buttonStyles = [NSArray arrayWithObjects:
                             [NSNumber numberWithInt:InfoBarButtonSytleCount],
                             [NSNumber numberWithInt:InfoBarButtonSytleBubble],
                             [NSNumber numberWithInt:InfoBarButtonSytleBubble], nil];
    NSArray *buttonTags = [NSArray arrayWithObjects:
                           [NSNumber numberWithInteger:InfoBarButtonTagFavourties],
                           [NSNumber numberWithInteger:InfoBarButtonTagSubscribe],
                           [NSNumber numberWithInteger:InfoBarButtonTagChat], nil];
    
    self.size = CGSizeMake([UCMainView sharedMainView].width, 45 * titles.count);

    CGFloat height = 45;
    
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [self creatBarButtonWithFrame:CGRectMake(0, 45*(i), self.width, height) tittle:titles[i] imageName:images[i] buttonStyle:[buttonStyles[i] integerValue] tag:[buttonTags[i] integerValue]];
        [self addSubview:btnItem];
        [btnItem addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(15, 0, btnItem.width - 15, kLinePixel) color:kColorNewLine]];
    }
    
    [self addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine]];
    [self addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, self.height - kLinePixel, self.width, kLinePixel) color:kColorNewLine]];
}

/** 创建商家视图 */
- (void)creatUserStyleBusinessViewWithSize
{
    BOOL isBail = [[AMCacheManage currentUserInfo].isbailcar integerValue] == 1;
    
    NSArray *titles = isBail ? @[@"销售代表", @"销售线索", @"保证金", @"咨询记录", @"分享营销", @"收藏的车", @"订阅的车"] : @[@"销售代表", @"销售线索", @"咨询记录", @"分享营销", @"收藏的车", @"订阅的车"];
    NSArray *images = isBail ? @[@"my_list_ct", @"my_list_information", @"my_list_bond", @"my_list_consultation", @"my_list_share",  @"my_list_collection", @"my_list_subscribe"] : @[@"my_list_ct", @"my_list_information", @"my_list_consultation", @"my_list_share", @"my_list_collection", @"my_list_subscribe"];
    NSArray *buttonStyles = isBail ? [NSArray arrayWithObjects:
                                      [NSNumber numberWithInt:InfoBarButtonSytleCount],
                                      [NSNumber numberWithInt:InfoBarButtonSytleBubble],
                                      [NSNumber numberWithInt:InfoBarButtonSytleBubble],
                                      [NSNumber numberWithInt:InfoBarButtonSytleBubble],
                                      [NSNumber numberWithInt:InfoBarButtonSytleCount],
                                      [NSNumber numberWithInt:InfoBarButtonSytleCount],
                                      [NSNumber numberWithInt:InfoBarButtonSytleBubble]
                                      , nil] :  [NSArray arrayWithObjects:
                                                 [NSNumber numberWithInt:InfoBarButtonSytleCount],
                                                 [NSNumber numberWithInt:InfoBarButtonSytleBubble],
                                                 [NSNumber numberWithInt:InfoBarButtonSytleBubble],
                                                 [NSNumber numberWithInt:InfoBarButtonSytleCount],
                                                 [NSNumber numberWithInt:InfoBarButtonSytleCount],
                                                 [NSNumber numberWithInt:InfoBarButtonSytleBubble], nil];
    
    NSArray *buttonTags = isBail ? [NSArray arrayWithObjects:
                                    [NSNumber numberWithInteger:InfoBarButtonTagSales],
                                    [NSNumber numberWithInteger:InfoBarButtonTagLeads],
                                    [NSNumber numberWithInteger:InfoBarButtonTagBail],
                                    [NSNumber numberWithInteger:InfoBarButtonTagChat],
                                    [NSNumber numberWithInteger:InfoBarButtonTagShare],
                                    [NSNumber numberWithInteger:InfoBarButtonTagFavourties],
                                    [NSNumber numberWithInteger:InfoBarButtonTagSubscribe]
                                    , nil] : [NSArray arrayWithObjects:
                                              [NSNumber numberWithInteger:InfoBarButtonTagSales],
                                              [NSNumber numberWithInteger:InfoBarButtonTagLeads],
                                              [NSNumber numberWithInteger:InfoBarButtonTagChat],
                                              [NSNumber numberWithInteger:InfoBarButtonTagShare],
                                              [NSNumber numberWithInteger:InfoBarButtonTagFavourties],
                                              [NSNumber numberWithInteger:InfoBarButtonTagSubscribe], nil];
    
    self.size = CGSizeMake([UCMainView sharedMainView].width, 20 + 45 * titles.count);
    
    CGFloat minY = 0;
    CGFloat height = 45;
    
    for (int i = 0; i < titles.count; i++) {
        if ([buttonTags[i] integerValue] == InfoBarButtonTagFavourties)
            minY += 20;
        UIButton *btnItem = [self creatBarButtonWithFrame:CGRectMake(0, minY, self.width, height) tittle:titles[i] imageName:images[i] buttonStyle:[buttonStyles[i] integerValue] tag:[buttonTags[i] integerValue]];
        [self addSubview:btnItem];
        
        minY += height;
        
        CGFloat minXOfLine = (i == 0 || i == titles.count - 2) ? 0 : 15;
        
        if (i == titles.count - 3) {
            [btnItem addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, btnItem.height - kLinePixel, btnItem.width, kLinePixel) color:kColorNewLine]];
        }
        [btnItem addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(minXOfLine, 0, btnItem.width - minXOfLine, kLinePixel) color:kColorNewLine]];
    }
    [self addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, self.height - kLinePixel, self.width, kLinePixel) color:kColorNewLine]];
}

/** 创建个人视图 */
- (void)creatUserStylePersonalViewWithSize:(CGSize)size
{
    self.size = size;
    
    NSArray *titles = @[@"收藏的车", @"订阅的车", @"咨询记录"];
    NSArray *images = @[@"my_list_collection", @"my_list_subscribe", @"my_list_consultation"];
    NSArray *buttonStyles = [NSArray arrayWithObjects:
                             [NSNumber numberWithInt:InfoBarButtonSytleCount],
                             [NSNumber numberWithInt:InfoBarButtonSytleBubble],
                             [NSNumber numberWithInt:InfoBarButtonSytleBubble], nil];
    NSArray *buttonTags = [NSArray arrayWithObjects:
                           [NSNumber numberWithInteger:InfoBarButtonTagFavourties],
                           [NSNumber numberWithInteger:InfoBarButtonTagSubscribe],
                           [NSNumber numberWithInteger:InfoBarButtonTagChat], nil];
    
    self.size = CGSizeMake([UCMainView sharedMainView].width, 20 + 45 * titles.count);

    CGFloat height = 45;
    
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [self creatBarButtonWithFrame:CGRectMake(0, 45*(i), self.width, height) tittle:titles[i] imageName:images[i] buttonStyle:[buttonStyles[i] integerValue] tag:[buttonTags[i] integerValue]];
        [self addSubview:btnItem];
    }
    
    [self addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine]];
    [self addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, self.height - kLinePixel, self.width, kLinePixel) color:kColorNewLine]];
}

/** 创建按钮条 */
- (UIButton *)creatBarButtonWithFrame:(CGRect)frame tittle:(NSString *)title imageName:(NSString *)imageName buttonStyle:(InfoBarButtonSytle)style tag:(NSInteger)tag
{
    UIButton *btnItem = [[UIButton alloc] initWithFrame:frame];
    btnItem.backgroundColor = kColorWhite;
    btnItem.titleLabel.font = kFontLarge;
    [btnItem setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
    [btnItem setTitle:title forState:UIControlStateNormal];
    [btnItem setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btnItem setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnItem.size] forState:UIControlStateHighlighted];
    btnItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 25, 0, 0)];
    [btnItem setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [btnItem addTarget:self action:@selector(onClickInfoBarBtn:) forControlEvents:UIControlEventTouchUpInside];
    btnItem.tag = tag;
    
    // 文字个数
    if (style == InfoBarButtonSytleCount) {
        UILabel *labCount = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, self.width - 200 - 35, btnItem.height - 1)];
        labCount.tag = tag + kInfoBarCount;
        labCount.backgroundColor = kColorClear;
        labCount.textColor = kColorNewGray2;
        labCount.font = kFontLarge;
        labCount.textAlignment = NSTextAlignmentRight;
        [btnItem addSubview:labCount];
    }
    else if (style == InfoBarButtonSytleBubble) {
        // 关注数量
        JSBadgeView *vAtttentionBadge = [[JSBadgeView alloc] initWithParentView:btnItem alignment:JSBadgeViewAlignmentCenterRight];
        vAtttentionBadge.tag = tag + kInfoBarCount;
        vAtttentionBadge.userInteractionEnabled = NO;
        vAtttentionBadge.badgePositionAdjustment = CGPointMake(-47, 0);
    }
    
    // 箭头
    UIImage *imageArrow = [UIImage imageNamed:@"set_arrow_right"];
    UIImageView *ivArrow = [[UIImageView alloc] initWithImage:imageArrow];
    ivArrow.size = CGSizeMake(15, 15);
    ivArrow.origin = CGPointMake(self.width - 35 + 8, (btnItem.height - ivArrow.size.height) / 2);
    
    [self addSubview:btnItem];
    
    [btnItem addSubview:ivArrow];
    
    if (btnItem.tag == InfoBarButtonTagChat) {
        _vChatPoint = [[UIView alloc] initWithFrame:CGRectMake(ivArrow.minX - 8 - 8, (btnItem.height - 8)/2, 8, 8)];
        _vChatPoint.backgroundColor = kColorRed;
        _vChatPoint.layer.masksToBounds = YES;
        _vChatPoint.layer.cornerRadius = _vChatPoint.width/2;
        _vChatPoint.hidden = YES;
        [btnItem addSubview:_vChatPoint];
    }
    
    return btnItem;
}

- (UILabel *)getInfoBarCountLabelWithInfoBarButtonTag:(InfoBarButtonTag)tag
{
    return (UILabel *)[self viewWithTag:tag + kInfoBarCount];
}

- (JSBadgeView *)getInfoBarCountBubbleWithInfoBarButtonTag:(InfoBarButtonTag)tag
{
    return (JSBadgeView *)[self viewWithTag:tag + kInfoBarCount];
}

#pragma mark - onClickButton
/** 点击条按钮 */
- (void)onClickInfoBarBtn:(UIButton *)btn
{
    if (![OMG isValidClick])
        return;
    
    if ([self.delegate respondsToSelector:@selector(infoBarView:onClickInfoBarBtn:)]) {
        [self.delegate infoBarView:self onClickInfoBarBtn:btn];
    }
}


@end
