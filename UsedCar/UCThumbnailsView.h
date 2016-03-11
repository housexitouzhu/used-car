//
//  UCThumbnailsView.h
//  UsedCar
//
//  Created by 张鑫 on 14-3-6.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UCThumbnailsViewDelegate;

@interface UCThumbnailsView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) NSArray *thumbimgurls;
@property (nonatomic, weak) id <UCThumbnailsViewDelegate> delegate;

- (void)reloadPhoto;

@end

@protocol UCThumbnailsViewDelegate <NSObject>
@optional

- (void)UCThumbnailsView:(UCThumbnailsView *)vThumbnails onClickPhotoBtn:(UIButton *)btn;

@end
