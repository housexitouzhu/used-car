//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UCActivityModel : NSObject<NSCoding>

@property (nonatomic,retain) NSString *activityvss;
@property (nonatomic,retain) NSMutableArray *adlist;


-(id)initWithJson:(NSDictionary *)json;

@end


@interface AdlistItemModel : NSObject<NSCoding>

@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSNumber *position;
@property (nonatomic,retain) NSString *url;
@property (nonatomic,retain) NSString *pid;
@property (nonatomic,retain) NSString *cid;

//v40 接口
@property (nonatomic,retain)NSString *articletitle;
@property (nonatomic,retain)NSString *content;
@property (nonatomic,retain)NSString *shorturl;
@property (nonatomic,retain)NSString *icon;

-(id)initWithJson:(NSDictionary *)json;

@end
