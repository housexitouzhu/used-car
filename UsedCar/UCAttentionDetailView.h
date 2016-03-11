//
//  UCAttentionDetailView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-21.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
@class UCCarAttenModel;
@class UCFilterModel;

@protocol UCAttentionDetailViewDelegate <NSObject>

- (void)detailListDidSelectAtIndex:(NSInteger)index itemID:(NSString*)itemID;

@end

@interface UCAttentionDetailView : UCView

@property (strong, nonatomic) UCFilterModel       *mFilter;
@property (strong, nonatomic) NSMutableArray      *detailArray;
@property (assign, nonatomic) NSInteger           index;
@property (assign, nonatomic) NSInteger           dateTime;
@property (strong, nonatomic) UCCarAttenModel     *mCarAttention;
@property (nonatomic, strong) NSMutableDictionary *dicReadNew;

@property (strong, nonatomic) id<UCAttentionDetailViewDelegate> delegate;


- (id)initWithFrame:(CGRect)frame withAttentionModel:(UCCarAttenModel*)mCarAttention attentionDictionary:(NSMutableDictionary*)dict;


@end
