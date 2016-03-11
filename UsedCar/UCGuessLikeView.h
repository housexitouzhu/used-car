//
//  UCGuessLikeView.h
//  UsedCar
//
//  Created by wangfaquan on 13-12-17.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCCarListView.h"

@class UCFavoritesView;

@interface UCGuessLikeView : UCView <UCCarListViewDelegate>

@property (nonatomic, weak) UCFavoritesView *vFavorites;

- (id)initWithFrame:(CGRect)frame favoritesInCloud:(BOOL)inCloud favoritesList:(NSArray*)favList;

@end
