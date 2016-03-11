//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UCAdviserModel : NSObject<NSCoding>

@property (nonatomic,retain)NSString *mobile;
@property (nonatomic,retain)NSString *position;
@property (nonatomic,retain)NSString *qq;
@property (nonatomic,retain)NSString *email;
@property (nonatomic,retain)NSString *tel;
@property (nonatomic,retain)NSNumber *sex;
@property (nonatomic,retain)NSString *name;
 

-(id)initWithJson:(NSDictionary *)json;

@end
