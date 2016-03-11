//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IMUserInfoModel : NSObject<NSCoding>

@property (nonatomic,retain)NSString *name;
@property (nonatomic,retain)NSString *nickname;
@property (nonatomic,retain)NSString *pwd;
 

-(id)initWithJson:(NSDictionary *)json;

@end
