//
//  UCExpandSeriesView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-9.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupTableView.h"

@class UCFilterModel;

typedef enum{
    SeriesExpandTypeNO,
    SeriesExpandTypeYES
}SeriesExpandType;

@protocol UCExpandSeriesViewDelegate;

@interface UCExpandSeriesView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) NSString         *brandID;
@property (retain, nonatomic) NSString         *brandName;
@property (nonatomic, assign) SeriesExpandType expandType;
@property (nonatomic, weak) id <UCExpandSeriesViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame filterTemp:(UCFilterModel *)mFilterTemp filter:(UCFilterModel *)mFilter BrandID:(NSString*)brandID;

- (void)setSelectecSeriesCell;

@end

@protocol UCExpandSeriesViewDelegate <NSObject>

- (void)UCExpandSeriesView:(UCExpandSeriesView *)vExpandSeries filterModel:(UCFilterModel *)mFilter;

@end
