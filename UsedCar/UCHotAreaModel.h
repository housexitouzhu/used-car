//
//  UCHotAreaModel.h
//  UsedCar
//
//  Created by 张鑫 on 14-6-19.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCHotAreaModel : NSObject

@property (nonatomic, strong) NSNumber *Id;             // 地区ID
@property (nonatomic, strong) NSString *Name;           // 地区名
@property (nonatomic, strong) NSString *Pinyin;         // 地区拼音
@property (nonatomic, strong) NSString *IsProvince;     // 地区是否是省
@property (nonatomic, strong) NSArray *AreaId;          // 地区子列表id

- (id)initWithJson:(NSDictionary *)json;

@end
