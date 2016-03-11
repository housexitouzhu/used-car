//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "UCAdviserModel.h"

@implementation UCAdviserModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
            self.mobile  = [json objectForKey:@"mobile"];
            self.position  = [json objectForKey:@"position"];
            self.qq  = [json objectForKey:@"qq"];
            self.email  = [json objectForKey:@"email"];
            self.tel  = [json objectForKey:@"tel"];
            self.sex  = [json objectForKey:@"sex"];
            self.name  = [json objectForKey:@"name"];
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.mobile forKey:@"mobile"];
    [aCoder encodeObject:self.position forKey:@"position"];
    [aCoder encodeObject:self.qq forKey:@"qq"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.tel forKey:@"tel"];
    [aCoder encodeObject:self.sex forKey:@"sex"];
    [aCoder encodeObject:self.name forKey:@"name"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.mobile = [aDecoder decodeObjectForKey:@"mobile"];
        self.position = [aDecoder decodeObjectForKey:@"position"];
        self.qq = [aDecoder decodeObjectForKey:@"qq"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.tel = [aDecoder decodeObjectForKey:@"tel"];
        self.sex = [aDecoder decodeObjectForKey:@"sex"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"mobile : %@\n",self.mobile];
    result = [result stringByAppendingFormat:@"position : %@\n",self.position];
    result = [result stringByAppendingFormat:@"qq : %@\n",self.qq];
    result = [result stringByAppendingFormat:@"email : %@\n",self.email];
    result = [result stringByAppendingFormat:@"tel : %@\n",self.tel];
    result = [result stringByAppendingFormat:@"sex : %@\n",self.sex];
    result = [result stringByAppendingFormat:@"name : %@\n",self.name];
    
    return result;
}

@end
