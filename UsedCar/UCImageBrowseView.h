//
//  UCImageBrowseView.h
//  UsedCar
//
//  Created by 张鑫 on 13-11-17.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UIImageView+WebCache.h"

@class APIHelper;

@interface UCImageBrowseView : UCView<UIScrollViewDelegate>{
    
    UIView *_vImageBrowse;
    
    NSInteger _previousOrientation;
    NSInteger _currentImageView;
    NSInteger _scrollViewTag;
    NSInteger _totalPage;
    NSInteger _downPage;
    
    APIHelper *_apiGetImage;
}

- (id)initWithFrame:(CGRect)frame index:(NSInteger)index thumbimgurls:(NSArray *)thumbimgurls imageUrls:(NSArray *)imageUrls;

@end
