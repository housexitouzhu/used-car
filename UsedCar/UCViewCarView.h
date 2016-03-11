//
//  UCReserVationCarView.h
//  UsedCar
//
//  Created by wangfaquan on 14-4-16.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCCarDetailInfoModel.h"

@interface UCViewCarView : UCView<UITextFieldDelegate, UIGestureRecognizerDelegate>

- (id)initWithFrame:(CGRect)frame mCarDetailInfo:(UCCarDetailInfoModel *)mCarDetailInfo;

@end
