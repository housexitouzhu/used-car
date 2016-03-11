//
//  UCNewFilterView.h
//  UsedCar
//
//  Created by 张鑫 on 14-7-9.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCSingleSelectionVIew.h"
#import "UCNewFilterBrandView.h"
#import "UCChoseLocationView.h"

typedef enum UCNewFilterViewStyle{
    UCNewFilterViewStyleFromHomeView = 0,
    UCNewFilterViewStyleFromSearchView,
    UCNewFilterViewStyleFromAddAttentionView,
    UCNewFilterViewStyleFromEditAttentionView,
} UCNewFilterViewStyle;

@class UCNewFilterView;

@protocol UCNewFilterViewDelegate;

@interface UCNewFilterView : UCView <UCSingleSelectionViewDelegate, UCNewFilterBrandViewDelegate, UCChoseLocationViewDelegate>

@property (nonatomic, weak) id<UCNewFilterViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame mFilter:(UCFilterModel *)mFilter rowCount:(NSInteger)rowCount orderby:(NSString *)orderby mArea:(UCAreaMode *)mArea;

/** 带关键字的初始化，从搜索结果页进 */
- (id)initWithFrame:(CGRect)frame mFilter:(UCFilterModel *)mFilter rowCount:(NSInteger)rowCount orderby:(NSString *)orderby keyWords:(NSString *)keyWords;

/** 添加关注或修改 */
- (id)initWithFrame:(CGRect)frame mFilter:(UCFilterModel *)mFilter mArea:(UCAreaMode *)mArea attentionID:(NSNumber *)ID;

@end

@protocol UCNewFilterViewDelegate <NSObject>

@optional
/** 选择筛选条件完毕 */
- (void)UCNewFilterView:(UCNewFilterView *)vNewFilter isChanged:(BOOL)isChanged filterModelChanged:(UCFilterModel *)mFilter didClickedViewCarListBtnWithCarLists:(NSMutableArray *)mCarLists rowCount:(NSInteger)rowCount;

@optional
/** 添加关注完毕 */
- (void)UCNewFilterView:(UCNewFilterView *)vNewFilter addAttentionWithAreaModel:(UCAreaMode *)mArea filterModel:(UCFilterModel *)mFilter;

@optional
/** 修改关注完毕 */
- (void)UCNewFilterView:(UCNewFilterView *)vNewFilter attentionID:(NSNumber *)ID isChanged:(BOOL)isChanged editAttentionWithAreaModel:(UCAreaMode *)mArea filterModel:(UCFilterModel *)mFilter;

@end