//
//  ChatListView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StorageMessage;
@class StorageContact;

@protocol ChatListViewDelegate;

@interface ChatListView : UIView

@property (nonatomic, strong) NSMutableArray *arrMessage;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,weak) id delegateOfCell;
@property (nonatomic, weak) id<ChatListViewDelegate> delegate;

- (void)addNewMessageToArray:(StorageMessage *)message;
- (void)addNewMessageToArray:(StorageMessage *)message toContact:(StorageContact *)contact;

- (void)addHistoryMessagesToArray:(NSArray *)array contact:(StorageContact *)contact;

- (void)refreshTableScrollToMessage:(BOOL)flag;

@end

@protocol ChatListViewDelegate <NSObject>

- (void)ChatListView:(ChatListView *)chatListView shouldDismissKeyboard:(BOOL)flag;

@end