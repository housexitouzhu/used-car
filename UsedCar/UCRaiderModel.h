//
//  UCRaiderModel.h
//  UsedCar
//
//  Created by wangfaquan on 13-12-18.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCRaiderModel : NSObject <NSCoding>

@property (nonatomic, strong)NSString *articleid;
@property (nonatomic, strong)NSString *articletitle;
@property (nonatomic, strong)NSString *articleintroduce;
@property (nonatomic, strong)NSString *articlepublishdate;

- (id)initWithJson:(NSDictionary *)json;

@end
