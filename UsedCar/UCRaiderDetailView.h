//
//  UCRaiderDetailView.h
//  UsedCar
//
//  Created by wangfaquan on 13-12-19.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCOptionBar.h"

@interface UCRaiderDetailView : UCView

@property (nonatomic)int indexPathRow;
@property (nonatomic, strong)NSString *TopTitle;

- (void)openContent:(NSString *)articleId;
- (void)openLoadLocalHtml:(NSURL *)url;

@end
