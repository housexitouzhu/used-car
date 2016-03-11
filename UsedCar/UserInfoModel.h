//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCAdviserModel.h"

@interface UserInfoModel : NSObject <NSCoding>

@property (nonatomic,retain ) NSNumber       *userid;
@property (nonatomic,retain ) NSString       *username;
@property (nonatomic,retain ) NSString       *userkey;
@property (nonatomic, strong) NSNumber       *mobile;
@property (nonatomic, strong) NSString       *updatetime;
@property (nonatomic,retain ) NSNumber       *carnotpassed;
@property (nonatomic,retain ) NSNumber       *carsaleing;
@property (nonatomic,retain ) NSNumber       *type;
@property (nonatomic,retain ) NSMutableArray *salespersonlist;
@property (nonatomic,retain ) NSNumber       *bdpmstatue;
@property (nonatomic,retain ) NSNumber       *carinvalid;
@property (nonatomic,retain ) NSNumber       *isbailcar;
@property (nonatomic,retain ) NSNumber       *carsaled;
@property (nonatomic,retain ) NSNumber       *carchecking;
@property (nonatomic, strong) NSString       *code;
@property (nonatomic, strong) NSNumber       *dealerid;
@property (nonatomic, strong) NSString       *logo;
@property (nonatomic, strong) UCAdviserModel *adviser;

- (id)initWithJson:(NSDictionary *)json;

@end