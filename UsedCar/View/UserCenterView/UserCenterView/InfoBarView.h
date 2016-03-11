//
//  InfoBarView.h
//  UsedCar
//
//  Created by 张鑫 on 14-9-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JSBadgeView;

typedef enum {
    InfoBarButtonTagSales = 10000,
    InfoBarButtonTagLeads,
    InfoBarButtonTagBail,
    InfoBarButtonTagChat,
    InfoBarButtonTagShare,
    InfoBarButtonTagFavourties,
    InfoBarButtonTagSubscribe
} InfoBarButtonTag;

typedef enum {
    InfoBarButtonSytleCount = 20000,
    InfoBarButtonSytleBubble
} InfoBarButtonSytle;

@protocol InfoBarViewDelegate;

@interface InfoBarView : UIView

@property (nonatomic, strong) JSBadgeView *vAtttentionBadge;
@property (nonatomic, weak) id<InfoBarViewDelegate> delegate;
@property (nonatomic, strong) UIView *vChatPoint;

- (id)initWithUserStyle:(UserStyle)userStyle;
- (void)creatUserStyleViewWithUserStyle:(UserStyle)userStyle;
- (UILabel *)getInfoBarCountLabelWithInfoBarButtonTag:(InfoBarButtonTag)tag;
- (JSBadgeView *)getInfoBarCountBubbleWithInfoBarButtonTag:(InfoBarButtonTag)tag;

@end

@protocol InfoBarViewDelegate <NSObject>

- (void)infoBarView:(InfoBarView *)vInfoBar onClickInfoBarBtn:(UIButton *)btn;

@end
