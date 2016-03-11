//
//  UCChoseLocationView.h
//  UsedCar
//
//  Created by 张鑫 on 14-7-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCLocationView.h"

@protocol UCChoseLocationViewDelegate;

@interface UCChoseLocationView : UCView <UCLocationViewDelegate>

@property (nonatomic, weak) id<UCChoseLocationViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame areaModel:(UCAreaMode *)mArea;

@end

@protocol UCChoseLocationViewDelegate <NSObject>

-(void)UCChoseLocationView:(UCChoseLocationView *)vChoseLocation isChanged:(BOOL)isChanged areaModel:(UCAreaMode *)mArea;

@end
