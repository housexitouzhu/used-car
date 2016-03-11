//
//  UserLogInOutHelper.m
//  UsedCar
//
//  Created by Sun Honglin on 14-9-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UserLogInOutHelper.h"
#import "APIHelper.h"
#import "AMCacheManage.h"
#import "UCSalesLeadsView.h"
#import "UCMainView.h"
#import "XMPPStream.h"

@interface UserLogInOutHelper()

@property (nonatomic, strong) APIHelper *apiLogin;
@property (nonatomic, strong) APIHelper *apiRegister;
@property (nonatomic, strong) APIHelper *apiLogout;
@property (nonatomic, strong) APIHelper *apiRetrieve;
@property (nonatomic, strong) APIHelper *syncFav;

@end

@implementation UserLogInOutHelper

+ (instancetype)userHelper{
    return [[self alloc] init];
}

#pragma mark - 注册
- (void)clientRegisterWithClientModel:(UCRegisterClientModel*)mRegisterClient returnBlock:(UserRegisterBlock)block{
    
    if (!_apiRegister) {
        _apiRegister = [[APIHelper alloc] init];
    }
    
    // 状态提示框
    [[AMToastView toastView:YES] showLoading:@"正在注册..." cancel:^{
        //        [_apiLogin cancel];
        //        [[AMToastView toastView] hide];
    }];
    
    [_apiRegister setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            // 取消请求
            if (error.code == ConnectionStatusCancel) {
                [[AMToastView toastView] hide];
            }
            // 其他错误
            else{
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                NSString *message = nil;
                
                //                UserInfoModel *mUserInfo = [[UserInfoModel alloc] initWithJson:mBase.result];
                
                // 注册是否成功
                if (mBase.returncode == 0) {
                    //给调用注册的类返回数据
                    block(YES, mBase.returncode);
                }
                else{
                    //给调用注册的类返回数据
                    block(NO, mBase.returncode);
                    message = mBase.message;
                }
                
                
                if (message)
                    [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                else
                    [[AMToastView toastView] hide];
            } else {
                [[AMToastView toastView] hide];
            }
        } else {
            [[AMToastView toastView] hide];
        }
        
        
    }];
    [_apiRegister registerClient:mRegisterClient];
    
}

- (void)dealerRegisterWithDealerRegisterModel:(UCRegisterDealerModel*)mRegisterDealer returnBlock:(UserRegisterBlock)block{
    
    
    
    
}

#pragma mark - 登录
- (void)clientLoginWithUserName:(NSString*)username password:(NSString*)password verifyCode:(NSString*)verifyCode returnBlock:(UserLoginBlock)block{
    
    if (!_apiLogin)
        _apiLogin = [[APIHelper alloc] init];
    // 状态提示框
    [[AMToastView toastView:YES] showLoading:@"正在登录..." cancel:^{
        [_apiLogin cancel];
        [[AMToastView toastView] hide];
    }];
    
    __weak UserLogInOutHelper *weakSelf = self;
    // 设置请求完成后回调方法
    [_apiLogin setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            // 取消请求
            if (error.code == ConnectionStatusCancel) {
                [[AMToastView toastView] hide];
            }
            // 其他错误
            else{
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                NSString *message = nil;
                
                UserInfoModel *mUserInfo = [[UserInfoModel alloc] initWithJson:mBase.result];
                
                // 登录是否成功
                if (mBase.returncode == 0) {
                    // 断聊天
                    XMPPManager *xmpp = [XMPPManager sharedManager];
                    if (xmpp.xStream.isConnected) {
                        [xmpp logout];
                    }
                    
                    [AMCacheManage setLastRefreshUserInfoTime:[NSDate date]];
                    //这里缓存用户数据
                    [AMCacheManage setCurrentUserInfo:mUserInfo];
                    // 统计
                    [UMSAgent bindUserIdentifier:[NSString stringWithFormat:@"p%@", [AMCacheManage currentUserInfo].userid]];
                    [weakSelf refreshUserInfoCount];
                    
                    //                    //同步车源和订阅 转移到用户登录页面
                    //                    [weakSelf.class clientSyncCar];
                    //                    [weakSelf.class clientSyncSubscription];
                    
                    //给调用登录的类返回数据
                    block(YES, mBase.returncode, mBase.message, mUserInfo);
                    
                }
                else{
                    //给调用登录的类返回数据
                    block(NO, mBase.returncode, mBase.message, mUserInfo);
                    message = mBase.message;
                }
                
                if (message)
                    [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                else
                    [[AMToastView toastView] hide];
            } else {
                [[AMToastView toastView] hide];
            }
        } else {
            [[AMToastView toastView] hide];
        }
    }];
    // 请求用户登录
    [_apiLogin clientLogin:username pass:password code:verifyCode];
}


- (void)dealerLoginWithUserName:(NSString*)username password:(NSString*)password returnBlock:(UserLoginBlock)block{
    
    if (!_apiLogin)
        _apiLogin = [[APIHelper alloc] init];
    // 状态提示框
    [[AMToastView toastView:YES] showLoading:@"正在登录..." cancel:^{
        [_apiLogin cancel];
        [[AMToastView toastView] hide];
    }];
    
    __weak UserLogInOutHelper *weakSelf = self;
    
    // 设置请求完成后回调方法
    [_apiLogin setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 取消请求
            if (error.code == ConnectionStatusCancel) {
                [[AMToastView toastView] hide];
            }
            // 其他错误
            else{
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            UserInfoModel *mUserInfo = [[UserInfoModel alloc] initWithJson:mBase.result];
            
            if (mBase) {
                NSString *message = nil;
                
                // 登录是否成功
                if (mBase.returncode == 0) {
                    // 断聊天
                    XMPPManager *xmpp = [XMPPManager sharedManager];
                    if (xmpp.xStream.isConnected) {
                        [xmpp logout];
                    }
                    // 销售线索的已读痕迹
                    [[UCSalesLeadsView instanceavailablyReadsCount] removeAllObjects];
                    [[UCSalesLeadsView instanceunAvailablyReadsCount] removeAllObjects];
                    
                    // 更新时间
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
                    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
                    mUserInfo.updatetime = currentDateStr;
                    
                    [AMCacheManage setLastRefreshUserInfoTime:[NSDate date]];
                    
                    [AMCacheManage setCurrentUserInfo:mUserInfo];
                    // 统计
                    [UMSAgent bindUserIdentifier:[NSString stringWithFormat:@"d%@", [AMCacheManage currentUserInfo].userid]];
                    [weakSelf refreshUserInfoCount];
                    
                    block(YES, mBase.returncode, mBase.message, mUserInfo);
                    
                }
                else{
                    block(NO, mBase.returncode, mBase.message, mUserInfo);
                    message = mBase.message;
                }
                
                if (message)
                    [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                else
                    [[AMToastView toastView] hide];
            } else {
                [[AMToastView toastView] hide];
            }
        } else {
            [[AMToastView toastView] hide];
        }
    }];
    // 请求商家登录
    [_apiLogin userLogin:username pass:password];
}



#pragma mark - 退出
- (void)userLogoutShowToast:(BOOL)toastFlag logoutBlock:(UserLogoutBlock)block{
    
    if (!self.apiLogout) {
        self.apiLogout = [[APIHelper alloc] init];
    }
    
    // 状态提示框
    if (toastFlag) {
        [[AMToastView toastView:YES] showLoading:@"正在操作..." cancel:^{
            [self.apiLogout cancel];
            [[AMToastView toastView] hide];
        }];
    }
    __weak UserLogInOutHelper *weakSelf = self;
    
    // 设置请求完成后回调方法
    [self.apiLogout setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            // 取消请求
            if (toastFlag) {
                if (error.code == ConnectionStatusCancel)
                    [[AMToastView toastView] hide];
                else
                    [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            
            block(NO,nil);
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (toastFlag) {
                    [[AMToastView toastView] hide];
                }
                
                // 退出登录成功
                if (mBase.returncode == 0) {
                    // 断开IM连接
                    XMPPManager *xmpp = [XMPPManager sharedManager];
                    if (xmpp.xStream.isConnected) {
                        [xmpp logout];
                    }
                    [AMCacheManage setLastRefreshUserInfoTime:[NSDate date]];
                    //重置所有同步状态标记位
                    [AMCacheManage setCurrentUserInfo:nil];
                    // 统计
                    [UMSAgent bindUserIdentifier:@"0"];
                    [AMCacheManage setSYNCclientCarNeeded:NO];
                    [AMCacheManage setSYNCclientCarSuccess:NO];
                    [AMCacheManage setSYNCclientSubscriptionNeeded:NO];
                    [AMCacheManage setSYNCclientSubscriptionSuccess:NO];
                    [AMCacheManage setSYNCclientFavoritesNeeded:NO];
                    [AMCacheManage setSYNCclientFavoritesSuccess:NO];
                    
                    [weakSelf refreshUserInfoCount];
                    
                    block(YES,mBase.message);
                    
                } else {
                    
                    if (toastFlag) {
                        [[AMToastView toastView] showMessage:@"退出失败，请稍后重试…" icon:kImageRequestError duration:AMToastDurationNormal];
                    }
                    
                    block(NO,mBase.message);
                }
            }
            else{
                if (toastFlag) {
                    [[AMToastView toastView] hide];
                }
            }
        }
        else{
            if (toastFlag) {
                [[AMToastView toastView] hide];
            }
        }
    }];
    
    [self.apiLogout userLogout];
}

#pragma mark - method
- (void)refreshUserInfoCount
{
    // 刷新关注总数
    [UCMainView sharedMainView].subscribeCount = 0;
    [UCMainView sharedMainView].claimCount = 0;
    [UCMainView sharedMainView].imCount = 0;
    [[UCMainView sharedMainView] refreshRedPointAndUserCenterChatBarCountIfNeed];
    [[UCMainView sharedMainView] getAttentionCount:YES block:nil];
    if ([AMCacheManage currentUserType] == UserStyleBusiness) {
        // 刷新销售总数
        [[UCMainView sharedMainView] getSaleTotalNumber:NO block:nil];
        // 刷新商家保证金总数
        [[UCMainView sharedMainView] getClaimCount:YES block:nil];
    }
    
}

#pragma mark - 手机号找回车源
/**
 *  手机号找回车源
 *
 *  @param mobile       手机号
 *  @param validateCode 验证码
 */
- (void)carRetrieveWithMobile:(NSString*)mobile validateCode:(NSString*)validateCode returnBlock:(CarRetrieveBlock)block{
    
    if (!self.apiRetrieve) {
        self.apiRetrieve = [[APIHelper alloc] init];
    }
    
    [self.apiRetrieve setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            UserInfoModel *mUserInfo = [[UserInfoModel alloc] initWithJson:mBase.result];
            
            if (mBase) {
                NSString *message = nil;
                
                // 登录是否成功
                if (mBase.returncode == 0) {
                    
                    [AMCacheManage setCurrentUserInfo:mUserInfo];
                    
                    block(YES, mBase.returncode, mUserInfo);
                }
                else{
                    message = mBase.message;
                    block(NO, mBase.returncode,  mUserInfo);
                }
                
                if (message)
                    [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                
            }
        }
    }];
    
    [self.apiRetrieve carRetrieveByMobile:mobile validateCode:validateCode];
}

#pragma mark - 个人同步功能
+ (void)clientSyncCar{
    APIHelper *syncCar = [[APIHelper alloc] init];
    
    [syncCar setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            [AMCacheManage setSYNCclientCarSuccess:NO];
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase) {
                
                if (mBase.returncode == 0) {
                    [AMCacheManage setSYNCclientCarSuccess:YES];
                }
                else{
                    [AMCacheManage setSYNCclientCarSuccess:NO];
                }
            }
        }
        else{
            [AMCacheManage setSYNCclientCarSuccess:NO];
        }
        
    }];
    
    [syncCar clientSyncCar];
}

+ (void)clientSyncSubscription{
    APIHelper *syncCar = [[APIHelper alloc] init];
    
    [syncCar setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            [AMCacheManage setSYNCclientSubscriptionSuccess:NO];
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                
                if (mBase.returncode == 0) {
                    [AMCacheManage setSYNCclientSubscriptionSuccess:YES];
                }
                else{
                    [AMCacheManage setSYNCclientSubscriptionSuccess:NO];
                }
            }
        }
        else{
            [AMCacheManage setSYNCclientSubscriptionSuccess:NO];
        }
        
    }];
    
    [syncCar clientSyncSubscription];
}

- (void)clientSyncFavoritesWithFinishBlock:(UserSYNCfavoritesBlock)syncBlock{
    
    [[AMToastView toastView] showLoading:@"车源信息同步中" cancel:nil];
    [[AMToastView toastView] setTouchIntercept:NO];
    
    NSArray *arrFav = [AMCacheManage currentFavourites];
    
    AMLog(@"arrFav %@", arrFav);
    //如果本地的收藏本身为0
    if (arrFav.count==0) {
        [[AMToastView toastView] hide];
        [AMCacheManage setSYNCclientFavoritesNeeded:YES];
        [AMCacheManage setSYNCclientFavoritesSuccess:YES];
        syncBlock(NO);
        return;
    }
    
    
    NSMutableArray *arrCarIDs = [[NSMutableArray alloc] init];
    
    for (UCFavoritesModel *mFavorite in arrFav) {
        //        UCFavoritesModel *mFavorite = [[UCFavoritesModel alloc] initWithJson:dic];
        [arrCarIDs addObject:mFavorite.quoteID];
    }
    
    if (!self.syncFav) {
        self.syncFav = [[APIHelper alloc] init];
    }
    
    [self.syncFav setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            [[AMToastView toastView] showMessage:@"同步失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            [AMCacheManage setSYNCclientFavoritesSuccess:NO];
            syncBlock(NO);
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase) {
                
                if (mBase.returncode == 0) {
                    [[AMToastView toastView] showMessage:@"同步成功" icon:kImageRequestSuccess duration:AMToastDurationNormal];
                    [AMCacheManage setSYNCclientFavoritesSuccess:YES];
                    syncBlock(YES);
                }
                else{
                    [[AMToastView toastView] showMessage:@"同步失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
                    [AMCacheManage setSYNCclientFavoritesSuccess:NO];
                    syncBlock(NO);
                }
            }
        }
        else{
            [[AMToastView toastView] showMessage:@"同步失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            [AMCacheManage setSYNCclientFavoritesSuccess:NO];
            syncBlock(NO);
        }
        
    }];
    
    [self.syncFav clientSyncFavoritesWithCarIDs:arrCarIDs];
}

#pragma mark -






@end
