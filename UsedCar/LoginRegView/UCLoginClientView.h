//
//  UCLoginClientView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-9-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

typedef enum : NSUInteger {
    UCLoginClientTypeNormal,
    UCLoginClientTypeSaleCar,
} UCLoginClientType;

@protocol UCLoginClientViewDelegate;

@interface UCLoginClientView : UCView

@property (nonatomic, weak) id<UCLoginClientViewDelegate> delegate;
@property (nonatomic, assign) UCLoginClientType loginType;

- (id)initWithFrame:(CGRect)frame loginType:(UCLoginClientType)type;

@end

@protocol UCLoginClientViewDelegate <NSObject>

@optional
- (void)UCLoginClientView:(UCLoginClientView *)vLoginClient loginSuccess:(BOOL)success NeedSNYC:(BOOL)needSYNC SYNCSuccess:(BOOL)SYNCSuccess;
- (void)UCLoginClientView:(UCLoginClientView *)vLoginClient onClickLoginButton:(UIButton *)btnLogin;

- (void)UCLoginClientViewExpressSaleCar:(UCLoginClientView *)vLoginClient;

@end