//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AreaCityItem : NSObject <NSCoding>

@property (nonatomic, strong) NSString  *CN; // 市名
@property (nonatomic, strong) NSNumber  *CI; // 市ID
//@property (nonatomic, retain) NSNumber  *Lng;
//@property (nonatomic, retain) NSNumber  *Lat;

- (id)initWithCN:(NSString *)CN CI:(NSNumber *)CI;
- (id)initWithJson:(NSDictionary *)json;

@end