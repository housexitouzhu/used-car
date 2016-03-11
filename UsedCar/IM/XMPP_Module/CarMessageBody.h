//
//  SpecMessage.h
//  IMDemo
//
//  Created by jun on 11/4/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "MessageBody.h"
@class UCCarDetailInfoModel;

@interface CarMessageBody : MessageBody

#pragma mark - 车源基本信息
/*!
 *  @property
 *  @abstract  车型id
 */
@property (nonatomic,strong) NSNumber *carid;

/*!
 *  @property
 *  @abstract  车型名称
 */
@property (nonatomic,strong) NSString *carname;

/*!
 *  @property
 *  @abstract  车型图片
 */
@property (nonatomic,strong) NSString *carimage;

/*!
 *  @property
 *  @abstract  车型价格
 */
@property (nonatomic,strong) NSString *carprice;

/*!
 *  @property
 *  @abstract  上牌时间
 */
@property (nonatomic,strong) NSString *registrationdate;

/*!
 *  @property
 *  @abstract  里程
 */
@property (nonatomic,strong) NSString *mileage;

/*!
 *  @property
 *  @abstract  车源实体说有数据
 */
@property (nonatomic,strong) NSString *carJson;

#pragma mark - 商家/卖家信息
/*!
 *  @property
 *  @abstract  车主/销售代表名称
 */
@property (nonatomic,strong) NSString *nickname;

/*!
 *  @property
 *  @abstract  商家 id
 */
@property (nonatomic,strong) NSNumber *dealerid;

/*!
 *  @property
 *  @abstract  商家 id
 */
@property (nonatomic,strong) NSNumber *memberid;

/*!
 *  @property
 *  @abstract   商家名称
 */
@property (nonatomic,strong) NSString *dealername;


- (id)initWithModel:(UCCarDetailInfoModel *)model;

@end
