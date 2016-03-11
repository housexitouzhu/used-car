//
//  UCAttentionView.h
//  UsedCar
//
//  Created by wangfaquan on 14-4-4.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCAttentionListView.h"

typedef enum {
    UCAttentionViewSytleMainView = 100,
} UCAttentionViewSytle;

typedef enum {
    UCAttentionViewLeftButtonStyleBack = 0,
    UCAttentionViewLeftButtonStyleClose = 1,
} UCAttentionViewLeftButtonStyle;

@protocol UCCarAttentionDelegate;

@interface UCAttentionView : UCView<UCCarAttenlistDelegate>

@property (nonatomic) UCAttentionViewSytle viewStyle;
@property (nonatomic) BOOL isEnablePullRefresh;         // 是否启用下拉刷新
@property (assign, nonatomic) BOOL shouldClearNotifyMarkAfterClose;

- (id)initWithFrame:(CGRect)frame UCAttentionViewLeftButtonStyle:(UCAttentionViewLeftButtonStyle)leftButtonStyle;

@end



