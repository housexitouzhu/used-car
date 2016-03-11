//
//  UCNewCarConfigView.h
//  UsedCar
//
//  Created by 张鑫 on 14-2-14.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCCarDetailInfoModel;

@interface UCNewCarConfigView : UIView <UIScrollViewDelegate>

- (id)initWithFrame:(CGRect)frame mCarDetailInfo:(UCCarDetailInfoModel *)mCarDetailInfo;
- (void)loadData;

@end