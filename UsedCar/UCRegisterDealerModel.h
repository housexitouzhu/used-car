//
//  UCResisterModel.h
//  UsedCar
//
//  Created by 张鑫 on 14-5-21.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCRegisterDealerModel : NSObject

@property (nonatomic, strong) NSString *shopname;
@property (nonatomic, strong) NSNumber *companytype;
@property (nonatomic, strong) NSNumber *pid;
@property (nonatomic, strong) NSNumber *cid;
@property (nonatomic, strong) NSString *contactname;
@property (nonatomic, strong) NSString *phonenumber;

- (id)initWithJson:(NSDictionary *)json;

@end
