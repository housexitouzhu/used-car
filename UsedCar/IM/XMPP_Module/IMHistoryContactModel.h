//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IMHistoryContactModel : NSObject<NSCoding>

@property (nonatomic,retain)NSNumber *itemid;
@property (nonatomic,retain)NSString *namefrom;
@property (nonatomic,retain)NSNumber *objectid;
@property (nonatomic,retain)NSNumber *memberid;
@property (nonatomic,retain)NSString *dealername;
@property (nonatomic,retain)NSString *createtime;
@property (nonatomic,retain)NSString *timetoshow;
@property (nonatomic,retain)NSNumber *state;
@property (nonatomic,retain)NSString *carimgurl;
@property (nonatomic,retain)NSString *nicknameTo;
@property (nonatomic,retain)NSNumber *salesid;
@property (nonatomic,retain)NSNumber *reversestate;
@property (nonatomic,retain)NSString *carname;
@property (nonatomic,retain)NSString *nickname;
@property (nonatomic,retain)NSString *nameto;
@property (nonatomic,retain)NSNumber *dealerid;
@property (nonatomic,retain)NSNumber *typeID;
 

-(id)initWithJson:(NSDictionary *)json;

@end
