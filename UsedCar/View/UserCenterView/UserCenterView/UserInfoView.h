//
//  UserCenterView.h
//  UsedCar
//
//  Created by 张鑫 on 14-9-16.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserInfoViewDelegate;

typedef enum {
    LoginButtonTagDealer = 20000,
    LoginButtonTagClient
} LoginButtonTag;

@interface UserInfoView : UIView

@property (nonatomic, strong) UILabel *labName;
@property (nonatomic, strong) UILabel *labMobile;
@property (nonatomic, weak) id<UserInfoViewDelegate> delegate;

- (id)initWithUserStyle:(UserStyle)userStyle;
- (void)creatUserStyleViewWithUserStyle:(UserStyle)userStyle;

@end

@protocol UserInfoViewDelegate <NSObject>

- (void)UserInfoView:(UserInfoView *)vUserInfo onClickLoginBtn:(UIButton *)btn;

@end
