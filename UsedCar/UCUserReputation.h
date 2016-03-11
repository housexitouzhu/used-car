//
//  UCUserReputation.h
//  UsedCar
//
//  Created by 张鑫 on 14-6-9.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

@interface UCUserReputation : UCView <UIWebViewDelegate>

- (void)loadWebWithString:(NSString *)urlString;

@end
