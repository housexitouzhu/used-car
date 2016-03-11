//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UCShareHistoryModel : NSObject<NSCoding>

@property (nonatomic,retain)NSNumber *dealerid;
@property (nonatomic,retain)NSString *content;
@property (nonatomic,retain)NSNumber *appid;
@property (nonatomic,retain)NSString *createtimeshow;
@property (nonatomic,retain)NSNumber *channeltype;
@property (nonatomic,retain)NSString *thumbnailurls;
@property (nonatomic,retain)NSString *dealername;
@property (nonatomic,retain)NSNumber *type;
@property (nonatomic,retain)NSString *createtime;
@property (nonatomic,retain)NSNumber *shareid;
@property (nonatomic,retain)NSString *dealerlogo;
@property (nonatomic,retain)NSNumber *carcount;

-(id)initWithJson:(NSDictionary *)json;

@end
