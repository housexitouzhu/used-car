//
//  UCNewFilterBrandView.h
//  UsedCar
//
//  Created by 张鑫 on 14-7-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCExpandBrandView.h"

@class UCFilterModel;

@protocol UCNewFilterBrandViewDelegate;

@interface UCNewFilterBrandView : UCView <UCExpandBrandViewDelegate>

@property (nonatomic, weak) id<UCNewFilterBrandViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame mFilter:(UCFilterModel *)mFilter;

@end

@protocol UCNewFilterBrandViewDelegate <NSObject>

- (void)UCNewFilterBrandView:(UCNewFilterBrandView *)vNewFilterBrand isChanged:(BOOL)isChanged filterModel:(UCFilterModel *)mFilter;

@end
