//
//  UCProtocolView.h
//  UsedCar
//
//  Created by 张鑫 on 14-5-14.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

@protocol UCProtocolsDelegate;

@interface UCProtocolView : UCView

@property (nonatomic, weak) id<UCProtocolsDelegate>delegate;
@property (nonatomic, strong) UIButton *btn;

@end

@protocol UCProtocolsDelegate <NSObject>
/** 同意协议 */
- (void)didAgreeProtocol;

@end