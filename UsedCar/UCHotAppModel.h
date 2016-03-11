//
//  UCHotAppModel.h
//  UsedCar
//
//  Created by wangfaquan on 14-1-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCHotAppModel : NSObject

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *icon;
@property (nonatomic, strong) NSString  *url;
@property (nonatomic, strong) NSString  *descriptions;

- (id)initWithJson:(NSDictionary *)json;

@end
