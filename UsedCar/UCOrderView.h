//
//  UCOrderView.h
//  UsedCar
//
//  Created by 张鑫 on 14/10/23.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCOptionBar.h"

@protocol UCOrderViewDelegate;

@interface UCOrderView : UIView <UIScrollViewDelegate, UCOptionBarDelegate>

@property (nonatomic, weak) id<UCOrderViewDelegate>delegate;

@end

@protocol UCOrderViewDelegate <NSObject>

- (void)orderView:(UCOrderView *)vOrder didSelectedIndex:(NSInteger)index;

@end