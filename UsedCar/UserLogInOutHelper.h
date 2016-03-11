//
//  UserLogInOutHelper.h
//  UsedCar
//
//  Created by Sun Honglin on 14-9-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoModel.h"
#import "UCRegisterDealerModel.h"
#import "UCRegisterClientModel.h"


#pragma mark - block 定义
typedef void(^UserLoginBlock)(BOOL success, NSInteger returnCode, NSString *message, UserInfoModel *userInfoModel);
typedef void(^UserRegisterBlock)(BOOL success, NSInteger returnCode);
typedef void(^UserLogoutBlock)(BOOL success, NSString *message);
typedef void(^UserSYNCfavoritesBlock)(BOOL success);

/**
 *  手机号找回车源 block
 *
 *  @param success     接口请求结果成功或者失败
 *  @param returnCode 101,"缺少必要的请求参数"; 103, "缺少参数_appid"; 104, "该_appid不存在";  112, "HTTP请求非Post方式"; 500, "服务器错误"; 2049021，手机号格式错误; 106, "缺少签名"; 107,"签名错误"; 2049037,"验证码已过有效期; 2049021，手机号格式错误
 *  @param mUserInfo  user info model
 */
typedef void(^CarRetrieveBlock)(BOOL success, NSInteger returnCode, UserInfoModel *mUserInfo);

#pragma mark - interface
@interface UserLogInOutHelper : NSObject

//不用非得 copy, 这样,如果套用了2层以上的 block 会在用 weakself 的时候被释放掉
//@property (nonatomic, copy) UserRegisterBlock      registerBlock;
//@property (nonatomic, copy) UserLoginBlock         loginBlock;
//@property (nonatomic, copy) UserLogoutBlock        logoutBlock;
//@property (nonatomic, copy) CarRetrieveBlock       carRetrieveBlock;
//@property (nonatomic, copy) UserSYNCfavoritesBlock syncFavoritesBlock;


+ (instancetype)userHelper;

#pragma mark - 注册
/**
 *  用户注册
 *
 *  @param mRegisterClient 用户注册信息的 model
 *  @param block           注册返回的 block
 */
- (void)clientRegisterWithClientModel:(UCRegisterClientModel*)mRegisterClient returnBlock:(UserRegisterBlock)block;

/**
 *  商家注册
 *
 *  @param mRegisterDealer 商家注册信息的 model
 *  @param block           商家注册返回的 block
 */
- (void)dealerRegisterWithDealerRegisterModel:(UCRegisterDealerModel*)mRegisterDealer returnBlock:(UserRegisterBlock)block;


#pragma mark - 登录
/**
 *  用户登录
 *
 *  @param username   用户名
 *  @param password   密码
 *  @param verifyCode 验证码
 *  @param block      返回 block
 */
- (void)clientLoginWithUserName:(NSString*)username password:(NSString*)password verifyCode:(NSString*)verifyCode returnBlock:(UserLoginBlock)block;

/**
 *  商家登录
 *
 *  @param username 商家用户帐号
 *  @param password 商家密码
 *  @param block    用户登录的返回 block
 */
- (void)dealerLoginWithUserName:(NSString*)username password:(NSString*)password returnBlock:(UserLoginBlock)block;


#pragma mark - 登出
/** 退出登录 */
- (void)userLogoutShowToast:(BOOL)toastFlag logoutBlock:(UserLogoutBlock)block;

#pragma mark - 手机号找回车源
/**
 *  手机号找回车源
 *
 *  @param mobile       手机号
 *  @param validateCode 验证码
 */
- (void)carRetrieveWithMobile:(NSString*)mobile validateCode:(NSString*)validateCode returnBlock:(CarRetrieveBlock)block;


#pragma mark - 个人同步功能
+ (void)clientSyncCar;
+ (void)clientSyncSubscription;
- (void)clientSyncFavoritesWithFinishBlock:(UserSYNCfavoritesBlock)syncBlock;

@end
