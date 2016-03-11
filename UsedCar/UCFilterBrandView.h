//
//  UCFilterBrandView.h
//  UsedCar
//
//  Created by Alan on 13-11-15.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiTablesView.h"
#import "MJNIndexView.h"

@protocol UCFilterBrandViewDelegate;

@class UCFilterView;
@class UCFilterModel;

typedef enum {
    UCFilterBrandViewStyleBrand = 0,
    UCFilterBrandViewStyleModel = 1,
    UCFilterBrandViewStyleSeries = 2,
} UCFilterBrandViewStyle;

@interface UCFilterBrandView : UIView <MultiTablesViewDataSource, MultiTablesViewDelegate, MJNIndexViewDataSource>

@property (nonatomic, weak) UCFilterView *vFilter;
@property (nonatomic, strong) UCFilterModel *mFilterTemp;           // 临时
@property (nonatomic, weak) id <UCFilterBrandViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame filter:(UCFilterModel *)mFilter UCFilterBrandViewStyle:(UCFilterBrandViewStyle)viewStyle;
- (void)setSelectedCells;

@end

@protocol UCFilterBrandViewDelegate <NSObject>

-(void)filterBrandView:(UCFilterBrandView *)vFilterBarnd filterModel:(UCFilterModel *)mFilter;

@end
