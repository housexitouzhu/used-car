//
//  UCFavoritesView.h
//  UsedCar
//
//  Created by wangfaquan on 13-12-5.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCOptionBar.h"
#import "UCFavoritesModel.h"

@protocol FavoritesDelegate;

@interface UCFavoritesView : UCView

@property (nonatomic, assign) id<FavoritesDelegate>delegate;

- (void)refreshFavoritesList;

@end

@protocol FavoritesDelegate <NSObject>

- (void)refreshFavoritesCarList;

@end