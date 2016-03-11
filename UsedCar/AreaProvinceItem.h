//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AreaCityItem.h"
@class UCHotAreaModel;

@interface AreaProvinceItem : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber          *PI; // 省ID
@property (nonatomic, strong) NSString          *PN; // 省名称
@property (nonatomic, strong) NSString          *FL; // 首字母
@property (nonatomic, strong) NSMutableArray    *CL; // 城市列表

- (id)initWithPN:(NSString *)PN PI:(NSNumber *)PI;
- (id)initWithJson:(NSDictionary *)json;
- (id)initWithHotAreaModel:(UCHotAreaModel *)mHotArea;

@end