//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserBasicInfoModel : NSObject<NSCoding>

@property (nonatomic,retain) NSString *cname;
@property (nonatomic,retain) NSString *phone;
@property (nonatomic,retain) NSString *managetype;
@property (nonatomic,retain) NSNumber *memberId;    //2307707
@property (nonatomic,retain) NSString *address;
@property (nonatomic,retain) NSNumber *dealerstate; //-10开店20关店
@property (nonatomic,retain) NSString *username;
@property (nonatomic,retain) NSNumber *isbailcar;   //保证金商家0不是1是
@property (nonatomic,retain) NSNumber *bdpmstatue;  //检查报告模板0待审核，1审核通过2审核不通过
@property (nonatomic,retain) NSNumber *dealerid;    //50249
@property (nonatomic,retain) NSString *pname;
 

-(id)initWithJson:(NSDictionary *)json;

@end
