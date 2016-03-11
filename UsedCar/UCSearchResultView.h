//
//  UCSearchResultView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCNewFilterView.h"
#import "UCOrderView.h"

@class UCFilterModel;

@interface UCSearchResultView : UCView <UCNewFilterViewDelegate, UCOrderViewDelegate>

- (id)initWithFrame:(CGRect)frame withKeyword:(NSString*)keyWord;
- (void)setResultHeaderTitle;

@end
