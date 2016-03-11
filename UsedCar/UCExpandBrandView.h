//
//  UCExpandBrandView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-8.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJNIndexView.h"
#import "GroupTableView.h"
#import "UCExpandSeriesView.h"
#import "UCExpandSpecView.h"

@class UCFilterModel;

typedef enum {
    ExpandFilterBrandViewStyleBrand = 0,
    ExpandFilterBrandViewStyleModel = 1,
    ExpandFilterBrandViewStyleSeries = 2
//    ExpandFilterBrandViewStyleWithHot = 3     // 暂未用到
} ExpandFilterBrandViewStyle;


typedef enum{
    BrandExpandTypeNO,
    BrandExpandTypeYES
}BrandExpandType;

@protocol UCExpandBrandViewDelegate;

@interface UCExpandBrandView : UIView <MJNIndexViewDataSource, UITableViewDelegate, UITableViewDataSource, UCExpandSeriesViewDelegate ,UCExpandSpecViewDelegate>

@property (nonatomic, assign) BrandExpandType expandType;
@property (nonatomic, weak) id<UCExpandBrandViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame filter:(UCFilterModel *)mFilter ExpandFilterBrandViewStyle:(ExpandFilterBrandViewStyle)viewStyle;
- (void)setSelectedBrandCellshouldSelectAllBrandCell:(BOOL)flag;

@end

@protocol UCExpandBrandViewDelegate <NSObject>

-(void)UCExpandBrandView:(UCExpandBrandView *)vFilterBarnd isChanged:(BOOL)isChanged filterModel:(UCFilterModel *)mFilter;

@end