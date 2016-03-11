//
//  UCReputationDetailView.h
//  UsedCar
//
//  Created by wangfaquan on 14-6-20.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

@interface UCReputationDetailView : UCView <UIWebViewDelegate>

- (void)loadWebWithString:(NSURL*)urlString;

@end
