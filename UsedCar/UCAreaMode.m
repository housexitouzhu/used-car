//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "UCAreaMode.h"

@implementation UCAreaMode

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];

    if (self) {
        if (json != nil) {
            self.pName = [json objectForKey:@"pName"];
            self.cName = [json objectForKey:@"Name"];
            self.pid = [json objectForKey:@"pid"];
            self.cid = [json objectForKey:@"AreaId"];
            self.firstLetter = [json objectForKey:@"FirstLetter"];
            self.parent = [json objectForKey:@"Parent"];
            self.areaid = [json objectForKey:@"areaid"];
            self.areaName = [json objectForKey:@"areaName"];
        }
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.pName forKey:@"pName"];
    [aCoder encodeObject:self.cName forKey:@"Name"];
    [aCoder encodeObject:self.pid forKey:@"pid"];
    [aCoder encodeObject:self.cid forKey:@"AreaId"];
    [aCoder encodeObject:self.firstLetter forKey:@"FirstLetter"];
    [aCoder encodeObject:self.parent forKey:@"Parent"];
    [aCoder encodeObject:self.areaid forKey:@"areaid"];
    [aCoder encodeObject:self.areaName forKey:@"areaName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self) {
        self.pName = [aDecoder decodeObjectForKey:@"pName"];
        self.cName = [aDecoder decodeObjectForKey:@"Name"];
        self.pid = [aDecoder decodeObjectForKey:@"pid"];
        self.cid = [aDecoder decodeObjectForKey:@"AreaId"];
        self.firstLetter = [aDecoder decodeObjectForKey:@"FirstLetter"];
        self.parent = [aDecoder decodeObjectForKey:@"Parent"];
        self.areaid = [aDecoder decodeObjectForKey:@"areaid"];
        self.areaName = [aDecoder decodeObjectForKey:@"areaName"];
    }

    return self;
}

- (NSString *)description
{
    NSString *result = @"";

    result = [result stringByAppendingFormat:@"pName : %@\n", self.pName];
    result = [result stringByAppendingFormat:@"cName : %@\n", self.cName];
    result = [result stringByAppendingFormat:@"pid : %@\n", self.pid];
    result = [result stringByAppendingFormat:@"cid : %@\n", self.cid];
    result = [result stringByAppendingFormat:@"firstLetter : %@\n", self.firstLetter];
    result = [result stringByAppendingFormat:@"parent : %@\n", self.parent];
    result = [result stringByAppendingFormat:@"areaid : %@\n", self.areaid];
    result = [result stringByAppendingFormat:@"areaName : %@\n", self.areaName];
    
    return result;
}

- (id)copyWithZone:(NSZone *)zone
{
    UCAreaMode *result = [[[self class] allocWithZone:zone] init];
    
    result->_pName= [self->_pName copy];
    result->_cName = [self->_cName copy];
    result->_pid = [self->_pid copy];
    result->_cid = [self->_cid copy];
    result->_firstLetter = [self->_firstLetter copy];
    result->_parent = [self->_parent copy];
    result->_areaid = [self->_areaid copy];
    result->_areaName = [self->_areaName copy];
    
    return result;
}


- (BOOL)isEqualToArea:(UCAreaMode *)mArea
{
    if ((self.pid == mArea.pid || [self.pid isEqualToString:mArea.pid]) &&
        (self.cid == mArea.cid || [self.cid isEqualToString:mArea.cid]) && (self.areaid == mArea.areaid || [self.areaid isEqualToString:mArea.areaid]))
        return YES;
    else
        return NO;
}

- (BOOL)isNull
{
    if (self.areaid.length == 0 && self.pid.length == 0 && self.cid.length == 0) {
        return YES;
    }
    return NO;
}

- (void)setNull
{
    self.pName = nil;
    self.cName = nil;
    self.pid = nil;
    self.cid = nil;
    self.firstLetter = nil;
    self.parent = nil;
    self.areaid = nil;
    self.areaName = nil;
}

- (void)setEqualToArea:(UCAreaMode *)mArea
{
    self.pName = mArea.pName;
    self.cName = mArea.cName;
    self.pid = mArea.pid;
    self.cid = mArea.cid;
    self.areaid = mArea.areaid;
    self.areaName = mArea.areaName;
    self.firstLetter = mArea.firstLetter;
    self.parent = mArea.parent;
}

@end