//
//  UCChatRootView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

@class UCCarDetailInfoModel;
@class StorageContact;

@interface UCChatRootView : UCView

- (id)initWithFrame:(CGRect)frame withCarInfoModel:(UCCarDetailInfoModel *)mCarInfo;

- (id)initWithFrame:(CGRect)frame contact:(StorageContact *)listContact withHistoryArray:(NSArray *)array;

@end
