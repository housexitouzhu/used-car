//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DealerModel : NSObject<NSCoding>

@property (nonatomic,retain)NSString *cname;
@property (nonatomic,retain)NSString *descriptioninfo;
@property (nonatomic,retain)NSString *phone;
@property (nonatomic,retain)NSNumber *kindid;
@property (nonatomic,retain)NSString *latitude;
@property (nonatomic,retain)NSString *longtitude;
@property (nonatomic,retain)NSString *logo;
@property (nonatomic,retain)NSString *address;
@property (nonatomic,retain)NSString *username;
@property (nonatomic,retain)NSNumber *isbailcar;
@property (nonatomic,retain)NSString *pname;
 

-(id)initWithJson:(NSDictionary *)json;

@end
