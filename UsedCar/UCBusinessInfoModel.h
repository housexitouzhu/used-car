//
//  UCBusinessInfoModel.h
//  UsedCar
//
//  Created by 张鑫 on 13-12-4.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCBusinessInfoModel : NSObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *cname;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longtitude;
@property (nonatomic, strong) NSString *managetype;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *pname;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *money;

- (id)initWithJson:(NSDictionary *)json;

@end