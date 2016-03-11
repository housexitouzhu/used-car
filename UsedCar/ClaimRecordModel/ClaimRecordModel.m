//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "ClaimRecordModel.h"

@implementation ClaimRecordModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
    if(json != nil)
    {
       self.Count  = [json objectForKey:@"Count"];
 self.ClaimList = [NSMutableArray array];
for(id item in [json objectForKey:@"ClaimList"])
{
if ([item isKindOfClass:[NSDictionary class]]){
    [self.ClaimList addObject:[[ClaimRecordItem alloc] initWithJson:item]];
}
else{
[self.ClaimList addObject:item];
}
}

    }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.Count forKey:@"Count"];
[aCoder encodeObject:self.ClaimList forKey:@"ClaimList"];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.Count = [aDecoder decodeObjectForKey:@"Count"];
 self.ClaimList = [aDecoder decodeObjectForKey:@"ClaimList"];
 
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"Count : %@\n",self.Count];
result = [result stringByAppendingFormat:@"ClaimList : %@\n",self.ClaimList];

    return result;
}

@end
