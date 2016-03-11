//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCAreaMode : NSObject <NSCoding>

@property (nonatomic, strong) NSString  *pName;
@property (nonatomic, strong) NSString  *cName;
@property (nonatomic, strong) NSString  *pid;
@property (nonatomic, strong) NSString  *cid;
@property (nonatomic, strong) NSString  *firstLetter;
@property (nonatomic, strong) NSString  *parent;
@property (nonatomic, strong) NSString  *areaid;
@property (nonatomic, strong) NSString  *areaName;

- (id)initWithJson:(NSDictionary *)json;

- (BOOL)isEqualToArea:(UCAreaMode *)mArea;
- (BOOL)isNull;
- (void)setNull;
- (void)setEqualToArea:(UCAreaMode *)mArea;

@end