//
//  UserCenterData.m
//  UsedCar
//
//  Created by 张鑫 on 14-9-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UserCenterData.h"
#import "APIHelper.h"
#import "AMCacheManage.h"
#import "UserLogInOutHelper.h"
#import "UCFavoritesCloudListModel.h"

@interface UserCenterData()

@property (nonatomic, strong) APIHelper *apiGetUserInfo;
@property (nonatomic, strong) APIHelper *apiGetClientFavorites;

@end

@implementation UserCenterData

-(APIHelper *)apiGetUserInfo
{
    if (!_apiGetUserInfo) {
        _apiGetUserInfo = [[APIHelper alloc] init];
    }
    return _apiGetUserInfo;
}

-(APIHelper *)apiGetClientFavorites
{
    if (!_apiGetClientFavorites) {
        _apiGetClientFavorites = [[APIHelper alloc] init];
    }
    return _apiGetClientFavorites;
}

- (void)getUserInfo:(UserStyle)userStyle getUserInfo:(GetUserInfoBlock)block
{
    // 同步个人订阅和车源
    if ([AMCacheManage currentUserType] == UserStylePersonal) {
        if ([AMCacheManage SYNCclientSubscriptionNeeded] && [AMCacheManage SYNCclientSubscriptionSuccess] == NO) {
            [UserLogInOutHelper clientSyncSubscription];
        }
        if ([AMCacheManage SYNCclientCarNeeded] && [AMCacheManage SYNCclientCarSuccess] == NO) {
            [UserLogInOutHelper clientSyncCar];
        }
    }
    
    self.blockUserInfo = block;
    // 设置请求完成后回调方法
    __weak UserCenterData *userCenterData = self;
    
    [self.apiGetUserInfo setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 非取消请求错误
            if (userCenterData.blockUserInfo) {
                userCenterData.blockUserInfo(NO, [NSError errorWithDomain:error.domain code:error.code userInfo:nil], nil);
                userCenterData.blockUserInfo = nil;
            }
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase) {
                if (mBase.returncode == 0) {
                    NSDateFormatter *dateFormatter = [OMG defaultDateFormatter];
                    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
                    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
                    
                    UserInfoModel *tempUserInfo = [[UserInfoModel alloc] initWithJson: mBase.result];
                    tempUserInfo.updatetime = currentDateStr;
                    
                    [AMCacheManage setLastRefreshUserInfoTime:[NSDate date]];
                    
                    // 缓存用户信息
                    if ([AMCacheManage currentUserType] == UserStyleBusiness || [AMCacheManage currentUserType] == UserStylePersonal || [AMCacheManage currentUserType] == UserStylePhone) {
                        
                        //获取信息的接口回传的没有 userKey, 需要做一对一的处理
                        UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
                        if (mUserInfo) {
                            if (currentDateStr) mUserInfo.updatetime                    = currentDateStr;
                            if (tempUserInfo.userid) mUserInfo.userid                   = tempUserInfo.userid;
                            if (tempUserInfo.username) mUserInfo.username               = tempUserInfo.username;
                            if (tempUserInfo.mobile) mUserInfo.mobile                   = tempUserInfo.mobile;
                            if (tempUserInfo.carnotpassed) mUserInfo.carnotpassed       = tempUserInfo.carnotpassed;
                            if (tempUserInfo.carsaleing) mUserInfo.carsaleing           = tempUserInfo.carsaleing;
                            if (tempUserInfo.type) mUserInfo.type                       = tempUserInfo.type;
                            if (tempUserInfo.salespersonlist) mUserInfo.salespersonlist = tempUserInfo.salespersonlist;
                            if (tempUserInfo.bdpmstatue) mUserInfo.bdpmstatue           = tempUserInfo.bdpmstatue;
                            if (tempUserInfo.carinvalid) mUserInfo.carinvalid           = tempUserInfo.carinvalid;
                            if (tempUserInfo.isbailcar) mUserInfo.isbailcar             = tempUserInfo.isbailcar;
                            if (tempUserInfo.carsaled) mUserInfo.carsaled               = tempUserInfo.carsaled;
                            if (tempUserInfo.carchecking) mUserInfo.carchecking         = tempUserInfo.carchecking;
                            if (tempUserInfo.code) mUserInfo.code                       = tempUserInfo.code;
                            if (tempUserInfo.dealerid) mUserInfo.dealerid               = tempUserInfo.dealerid;
                            if (tempUserInfo.adviser) {
                                if (!mUserInfo.adviser)
                                    mUserInfo.adviser = [[UCAdviserModel alloc] init];
                                mUserInfo.adviser.mobile = tempUserInfo.adviser.mobile;
                                mUserInfo.adviser.position = tempUserInfo.adviser.position;
                                mUserInfo.adviser.qq = tempUserInfo.adviser.qq;
                                mUserInfo.adviser.email = tempUserInfo.adviser.email;
                                mUserInfo.adviser.tel = tempUserInfo.adviser.tel;
                                mUserInfo.adviser.sex = tempUserInfo.adviser.sex;
                                mUserInfo.adviser.name = tempUserInfo.adviser.name;
                            }
                            [AMCacheManage setCurrentUserInfo:mUserInfo];
                        } else {
                            [AMCacheManage setCurrentUserInfo:tempUserInfo];
                        }
                    } else {
                        [AMCacheManage setCurrentUserInfo:tempUserInfo];
                    }
                    if (userCenterData.blockUserInfo) {
                        userCenterData.blockUserInfo(YES, nil, mBase);
                        userCenterData.blockUserInfo = nil;
                    }
                }
                else {
                    if (userCenterData.blockUserInfo) {
                        userCenterData.blockUserInfo(NO, [NSError errorWithDomain:mBase.message ? mBase.message : @"" code:mBase.returncode ? mBase.returncode : -1 userInfo:nil], mBase);
                        userCenterData.blockUserInfo = nil;
                    }
                }
                
            }
        }
    }];
    [self.apiGetUserInfo getUserInfo];
}

- (void)getClientFavorites:(GetClientFavoritesBlock)block
{
    self.blockClientFavorites = block;
    // 设置请求完成后回调方法
    __weak UserCenterData *userCenterData = self;
    
    [self.apiGetClientFavorites setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            if (userCenterData.blockClientFavorites) {
                userCenterData.blockClientFavorites(NO, [NSError errorWithDomain:error.domain ? error.domain : @"" code:error.code ? error.code : -1 userInfo:nil], NSNotFound);
                userCenterData.blockClientFavorites = nil;
            }
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase) {
                if (mBase.returncode == 0) {
                    if (userCenterData.blockClientFavorites) {
                        UCFavoritesCloudListModel *mFavoritesCloud = [[UCFavoritesCloudListModel alloc] initWithJson:mBase.result];
                        userCenterData.blockClientFavorites(YES, nil, mFavoritesCloud.rowcount.integerValue);
                        userCenterData.blockClientFavorites = nil;
                    }
                }
                else {
                    if (userCenterData.blockClientFavorites) {
                        userCenterData.blockClientFavorites(NO, [NSError errorWithDomain:mBase.message ? mBase.message : @"" code:mBase.returncode ? mBase.returncode : -1 userInfo:nil], NSNotFound);
                        userCenterData.blockClientFavorites = nil;
                    }
                }
            }
        } else {
            if (userCenterData.blockClientFavorites) {
                userCenterData.blockClientFavorites(NO, [NSError errorWithDomain:@"" code:-1 userInfo:nil], NSNotFound);
                userCenterData.blockClientFavorites = nil;
            }
        }
    }];
    [self.apiGetClientFavorites getFavoritesListPageIndex:1 size:1];
}

@end
