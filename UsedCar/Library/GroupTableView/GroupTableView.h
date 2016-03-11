//
//  GroupTableView.h
//  open
//
//  Created by 王俊 on 13-12-3.
//  Copyright (c) 2013年 ATHM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolderCoverView.h"

@interface GroupTableView : UITableView
{
    UIView *backView;
    UIView *headerView;
}

@property (strong, nonatomic) NSString *logoURL;
@property (strong, nonatomic) UIImageView *logoView;
@property (nonatomic) BOOL closing;
@property (strong, nonatomic) UIView *subClassContentView;
@property (nonatomic, strong) FolderCoverView *top, *bottom;
@property (nonatomic) CGPoint oldTopPoint, oldBottomPoint;
@property (nonatomic) CGFloat offsetY;
@property (nonatomic) CGPoint oldContentOffset;
@property (strong, nonatomic) UIButton *btnClose;
@property (strong, nonatomic) NSString *headerTitle;
@property (nonatomic, copy) void (^closeHandler)(void);


- (void)openFolderAtIndexPath:(NSIndexPath *)indexPath WithContentView:(UIView *)subClassContentView closeHandler:(void (^)(void))closeHandler;
- (void)performClose:(id)sender;
@end
