//
//  UCReferencePriceModel.h
//  UsedCar
//
//  Created by 张鑫 on 13-11-17.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCReferencePriceModel : NSObject
@property (nonatomic, strong) NSString *referenceprice;
@property (nonatomic, strong) NSString *newcarprice;

- (id)initWithJson:(NSDictionary *)json;
@end
