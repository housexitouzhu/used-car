//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "IMUserInfoModel.h"

@implementation IMUserInfoModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
    if(json != nil)
    {
       self.name  = [json objectForKey:@"name"];
 self.nickname  = [json objectForKey:@"nickname"];
 self.pwd  = [json objectForKey:@"pwd"];
 
    }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
[aCoder encodeObject:self.nickname forKey:@"nickname"];
[aCoder encodeObject:self.pwd forKey:@"pwd"];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.name = [aDecoder decodeObjectForKey:@"name"];
 self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
 self.pwd = [aDecoder decodeObjectForKey:@"pwd"];
 
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"name : %@\n",self.name];
result = [result stringByAppendingFormat:@"nickname : %@\n",self.nickname];
result = [result stringByAppendingFormat:@"pwd : %@\n",self.pwd];

    return result;
}

@end
