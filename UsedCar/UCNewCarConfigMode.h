//
//  UCNewCarConfigMode.h
//  UsedCar
//
//  Created by 张鑫 on 14-2-14.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCNewCarConfigMode : NSObject

@property (nonatomic, strong)NSMutableArray *configurations;

- (id)initWithJson:(NSDictionary *)json;

@end
