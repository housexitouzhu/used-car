//
//  UCFavoritesCarList.h
//  UsedCar
//
//  Created by wangfaquan on 13-12-9.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRefreshControl;

@interface UCFavoritesList : UIView <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic)CGFloat cellHeight;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;

@property (nonatomic, assign) BOOL loadFavoritesInCloud;
@property (nonatomic, strong) NSMutableArray *mFavoritesList;

/** 刷新收藏列表 */
- (void)refreshFavoritesList;

@end
