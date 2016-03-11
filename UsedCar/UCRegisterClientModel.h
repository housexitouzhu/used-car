//
//  UCClientRegisterModel.h
//  UsedCar
//
//  Created by Sun Honglin on 14-9-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCRegisterClientModel : NSObject

@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *userpwd;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *validecode;

- (id)initWithJson:(NSDictionary *)json;


@end
