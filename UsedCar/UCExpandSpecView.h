//
//  UCExpandSpecView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-9.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UCExpandSpecViewDelegate;

@interface UCExpandSpecView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) NSString       *seriesID;
@property (retain, nonatomic) NSString       *seriesName;
@property (nonatomic, weak)   id<UCExpandSpecViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame filterTemp:(UCFilterModel *)mFilterTemp filter:(UCFilterModel *)mFilter SeriesID:(NSString*)seriesID;
- (void)setSelectSpecCell;

@end

@protocol UCExpandSpecViewDelegate <NSObject>

- (void)UCExpandSpecView:(UCExpandSpecView *)vExpandSpec filterModel:(UCFilterModel *)mFilter;

@end
