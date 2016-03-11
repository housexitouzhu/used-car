//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "SalesPersonModel.h"

@implementation SalesPersonModel

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    self.txtsalesqq = @"";
    self.txtsaleslinktime = @"";
    self.txtsalesname = @"";
    self.txtsalesphone = @"";
    self.txtsalestype = @"";
    
    if (self) {
        if (json != nil) {
            self.salesqq = [json objectForKey:@"salesqq"];
            self.saleslinktime = [json objectForKey:@"saleslinktime"];
            self.salesid = [json objectForKey:@"salesid"];
            self.salesname = [json objectForKey:@"salesname"];
            self.salesphone = [json objectForKey:@"salesphone"];
            self.salestype = [json objectForKey:@"salestype"];
            
            self.txtsalesqq = self.salesqq.length > 0 ? self.salesqq : @"";
            self.txtsaleslinktime = self.saleslinktime ? [self.saleslinktime stringValue] : @"";
            self.txtsalesname = self.salesname.length > 0 ? self.salesname : @"";
            self.txtsalesphone = self.salesphone.length > 0 ? self.salesphone : @"";
            if (self.salestype)
                self.txtsalestype = [self.salestype integerValue] == 1 ? @"个人" : @"商家";
            else
                self.txtsalestype = @"";
        }
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.salesqq forKey:@"salesqq"];
    [aCoder encodeObject:self.saleslinktime forKey:@"saleslinktime"];
    [aCoder encodeObject:self.salesid forKey:@"salesid"];
    [aCoder encodeObject:self.salesname forKey:@"salesname"];
    [aCoder encodeObject:self.salesphone forKey:@"salesphone"];
    [aCoder encodeObject:self.salestype forKey:@"salestype"];
    
    [aCoder encodeObject:self.txtsalesqq forKey:@"txtsalesqq"];
    [aCoder encodeObject:self.txtsaleslinktime forKey:@"txtsaleslinktime"];
    [aCoder encodeObject:self.txtsalesname forKey:@"txtsalesname"];
    [aCoder encodeObject:self.txtsalesphone forKey:@"txtsalesphone"];
    [aCoder encodeObject:self.txtsalestype forKey:@"txtsalestype"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self) {
        self.salesqq = [aDecoder decodeObjectForKey:@"salesqq"];
        self.saleslinktime = [aDecoder decodeObjectForKey:@"saleslinktime"];
        self.salesid = [aDecoder decodeObjectForKey:@"salesid"];
        self.salesname = [aDecoder decodeObjectForKey:@"salesname"];
        self.salesphone = [aDecoder decodeObjectForKey:@"salesphone"];
        self.salestype = [aDecoder decodeObjectForKey:@"salestype"];
        
        self.txtsalesqq = [aDecoder decodeObjectForKey:@"txtsalesqq"];
        self.txtsaleslinktime = [aDecoder decodeObjectForKey:@"txtsaleslinktime"];
        self.txtsalesname = [aDecoder decodeObjectForKey:@"txtsalesname"];
        self.txtsalesphone = [aDecoder decodeObjectForKey:@"txtsalesphone"];
        self.txtsalestype = [aDecoder decodeObjectForKey:@"txtsalestype"];
    }

    return self;
}

- (NSString *)description
{
    NSString *result = @"";

    result = [result stringByAppendingFormat:@"salesqq : %@\n", self.salesqq];
    result = [result stringByAppendingFormat:@"saleslinktime : %@\n", self.saleslinktime];
    result = [result stringByAppendingFormat:@"salesid : %@\n", self.salesid];
    result = [result stringByAppendingFormat:@"salesname : %@\n", self.salesname];
    result = [result stringByAppendingFormat:@"salesphone : %@\n", self.salesphone];
    result = [result stringByAppendingFormat:@"salestype : %@\n", self.salestype];
    
    result = [result stringByAppendingFormat:@"txtsalesqq : %@\n", self.txtsalesqq];
    result = [result stringByAppendingFormat:@"txtsaleslinktime : %@\n", self.txtsaleslinktime];
    result = [result stringByAppendingFormat:@"txtsalesname : %@\n", self.txtsalesname];
    result = [result stringByAppendingFormat:@"txtsalesphone : %@\n", self.txtsalesphone];
    result = [result stringByAppendingFormat:@"txtsalestype : %@\n", self.txtsalestype];

    return result;
}

@end