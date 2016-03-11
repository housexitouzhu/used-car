//
//  UCActivityView.h
//  UsedCar
//
//  Created by Alan on 14-5-23.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCActivityModel.h"

@interface UCActivityView : UCView<UIWebViewDelegate>


- (id)initWithFrame:(CGRect)frame withActivityModel:(AdlistItemModel*)model;
- (void)loadWebWithString:(NSString*)urlString;

@end
