//
//  BaseModel.m
//  UsedCar
//
//  Created by Alan on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

- (id)initWithData:(NSData *)data;
{
    self = [super init];
    
    if (self) {
        if (data != nil) {
            NSError *error = nil;
            
            NSDictionary *dic = data ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
            
            self.returncode = NSNotFound; // 返回码
            self.message = nil; // 消息
            self.result = nil; // 数据
            // 数据处理
            if (!error && dic) {
                self.returncode = [[dic objectForKey:@"returncode"] integerValue];
                self.message = [dic objectForKey:@"message"];
                self.result = [dic objectForKey:@"result"];
            }
        }
    }
    
    return self;
}


@end
