//
//  BaseModel.h
//  UsedCar
//
//  Created by Alan on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject

@property (nonatomic) NSInteger returncode;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) id result;

- (id)initWithData:(NSData *)data;

@end
