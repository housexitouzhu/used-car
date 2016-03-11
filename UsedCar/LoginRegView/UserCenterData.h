//
//  UserCenterData.h
//  UsedCar
//
//  Created by 张鑫 on 14-9-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

typedef void(^GetUserInfoBlock)(BOOL isSuccess, NSError *error, BaseModel *mBase);
typedef void(^GetClientFavoritesBlock)(BOOL isSuccess, NSError *error, NSInteger count);

@interface UserCenterData : NSObject

@property (nonatomic, copy) GetUserInfoBlock blockUserInfo;
@property (nonatomic, copy) GetClientFavoritesBlock blockClientFavorites;

- (void)getUserInfo:(UserStyle)userStyle getUserInfo:(GetUserInfoBlock)block;
- (void)getClientFavorites:(GetClientFavoritesBlock)block;

@end
