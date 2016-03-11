//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SalesPersonModel : NSObject <NSCoding>


@property (nonatomic, strong) NSNumber  *saleslinktime;
@property (nonatomic, strong) NSNumber  *salesid;
@property (nonatomic, strong) NSString  *salesname;
@property (nonatomic, strong) NSString  *salesphone;
@property (nonatomic, strong) NSString  *salesqq;
@property (nonatomic, strong) NSNumber  *salestype;

@property (nonatomic, strong) NSString  *txtsaleslinktime;
@property (nonatomic, strong) NSString  *txtsalesname;
@property (nonatomic, strong) NSString  *txtsalesphone;
@property (nonatomic, strong) NSString  *txtsalesqq;
@property (nonatomic, strong) NSString  *txtsalestype;

- (id)initWithJson:(NSDictionary *)json;

@end