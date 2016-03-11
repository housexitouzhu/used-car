//
//  ChatListView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "ChatListView.h"
#import "StorageMessage.h"
#import "BaseChatCell.h"
#import "TextChatCell.h"
#import "CarInfoChatCell.h"
#import "ImageChatCell.h"
#import "TextMessageBody.h"
#import "StorageContact.h"
#import "XMPPMessageUploader.h"
#import "XMPPDBCacheManager.h"
#import "XMPPManager.h"
#import "ImageMessageBody.h"
#import "CKRefreshControl.h"



@interface ChatListView ()<UITableViewDelegate, UITableViewDataSource, ChatCellDelegate, ChatCellResendDelegate, XMPPManagerDelegate>
{
    NSInteger _page;
}
@property (nonatomic, strong) StorageContact *contact;
@property (nonatomic, strong) CKRefreshControl *pullRefresh;

@end

@implementation ChatListView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _arrMessage = [[NSMutableArray alloc] init];
        
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        _tableView.backgroundColor = kColorNewBackground;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:_tableView];
        
        _pullRefresh = [[CKRefreshControl alloc] initInScrollView:_tableView];
        _pullRefresh.titleRefreshing = @"正在加载中…";
        _pullRefresh.backgroundColor = [UIColor clearColor];
        [_pullRefresh addTarget:self action:@selector(PullToRefresh) forControlEvents:UIControlEventValueChanged];
        
//        UITapGestureRecognizer *hideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
//        hideTap.numberOfTapsRequired = 1;
//        hideTap.numberOfTouchesRequired = 1;
//        hideTap.delegate = self;
//        [self addGestureRecognizer:hideTap];
        
        [[XMPPManager sharedManager] addToDelegateQueue:self];
        
    }
    
    return self;
}


//#pragma mark - gestureRecognizer
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if ([touch.view isKindOfClass:[UIButton class]]) {
//        return NO;
//    }
//    return YES;
//}

#pragma mark -

- (void)dismissKeyboard{
    if ([_delegate respondsToSelector:@selector(ChatListView:shouldDismissKeyboard:)]) {
        [_delegate ChatListView:self shouldDismissKeyboard:YES];
    }
}

- (void)PullToRefresh
{
    // 有联系人加载聊天记录
    if ([[XMPPDBCacheManager sharedManager] hasContactWithJid:self.contact.shortJid] > 0) {
        NSArray *tempArray = [[XMPPDBCacheManager sharedManager] messagesWithPage:(_page+1) andJid:self.contact.shortJid];
        if (tempArray.count>0) {
            [_arrMessage insertObjects:tempArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tempArray.count)]];
            _page ++;
            
            [self refreshTableScrollToMessage:NO];
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:tempArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            
            [_pullRefresh endRefreshing];
        }
        else{
            [_pullRefresh endRefreshing];
        }
    }
    else{
        [_pullRefresh endRefreshing];
    }
}

- (void)addNewMessageToArray:(StorageMessage *)message{
//    [_arrMessage addObject:message];
//    [self refreshTableScrollToMessage:YES];
    [self addNewMessageToArray:message toContact:nil];
}

- (void)addNewMessageToArray:(StorageMessage *)message toContact:(StorageContact *)contact{
    [_arrMessage addObject:message];
    [self refreshTableScrollToMessage:YES];
    if (contact) {
        self.contact = contact;
    }
    
    if (message.type == IMMessageTypeImage || message.type == IMMessageTypeVoice) {
        [self uploadMessage:message toContact:contact];
    }
    
}

- (void)addHistoryMessagesToArray:(NSArray *)array contact:(StorageContact *)contact{
    _page = 0;
    [_arrMessage addObjectsFromArray:array];
    [self refreshTableScrollToMessage:NO];
    self.contact = contact;
}

- (void)refreshTableScrollToMessage:(BOOL)flag{
    [_tableView reloadData];
    if (flag) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_arrMessage.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [_tableView setFrame:self.bounds];
}

//#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    // 关掉手势使其不是第一响应者
//    return NO;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    // 接受touch事件
//    AMLog(@"touch.view %@", touch.view);
//    if ([touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[UITableViewCell class]]) {
//        return NO;
//    }
//    else{
//        return YES;
//    }
//}

#pragma mark - XMPP Connection
- (void)uploadMessage:(StorageMessage *)message toContact:(StorageContact *)contact
{
    if (message.type == IMMessageTypeImage) {
        XMPPMessageUploader *uploader = [[XMPPMessageUploader alloc] init];
        [uploader
         postImageMessage:message
         contact:contact
         progressBlock:^(unsigned long long sizeSent, unsigned long long total) {
             AMLog(@"setBytesSentBlock << %f >> ", (float)sizeSent/total * 100);
             for (BaseChatCell *cell in [_tableView visibleCells]) {
                 if([cell isKindOfClass:[ImageChatCell class]] && cell.message.mesId == message.mesId){
                     ImageChatCell *imageCell = (ImageChatCell *)cell;
                     [imageCell updateImageProgress:(float)sizeSent/total];
                 }
             }
         }
         completion:^(StorageMessage *message) {
             
             if (message.status == IMMessageStatusNormal) {
                 [[XMPPDBCacheManager sharedManager] updateMessageBodyWithMessage:message];
//                 [self updateAndSaveCurrentContactRecentMessage:message];
                 [[XMPPManager sharedManager] sendStorageMessage:message];
             }
             else if(message.status == IMMessageStatusFailure){
                 [[XMPPDBCacheManager sharedManager] updateStatusWithMessage:message];
                 [self refreshTableScrollToMessage:NO];
                 
             }
             
         }];
    }
}

//这里不用操作了.都同一个 DB 里管理了.
//#pragma mark - 后台更新Contact的最新发送消息
//- (void)updateAndSaveCurrentContactRecentMessage:(StorageMessage *)message
//{
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    
//    dispatch_async(queue, ^{
//        [self.contact updateMostRecentMessage:message];
//        [[XMPPDBCacheManager sharedManager] updateContactRecentMessage:message];
//        [[XMPPDBCacheManager sharedManager] updateContactRecentMessageWithContact:_contact];
//    });
//}


#pragma mark - ChatCellResendDelegate
- (void)ChatCell:(BaseChatCell *)cell resendButtonClickedWithMessage:(StorageMessage *)message contact:(StorageContact *)contact{
    
    switch (message.type) {
        case IMMessageTypeText:
        {
            [[XMPPManager sharedManager] sendStorageMessage:message];
        }
            break;
        case IMMessageTypeImage:
        {
            ImageMessageBody *body = (ImageMessageBody *)message.mesBody;
            AMLog(@"resend message.jid %@ %@", message.jid, message.fullJid);
            AMLog(@"resend contact.fullJid %@", contact.fullJid);
            if ([body.uri hasPrefix:@"http"]) {
                [[XMPPManager sharedManager] sendStorageMessage:message];
            }
            else{
                [self uploadMessage:message toContact:self.contact];
                [self refreshTableScrollToMessage:NO];
            }
        }
            break;
        case IMMessageTypeCar:
        {
            [[XMPPManager sharedManager] sendStorageMessage:message];
        }
            break;
        default:
            break;
    }
}

#pragma mark - XMPP delegate
- (void)didSendXMPPMessage:(XMPPMessage *)message{
//    AMLog(@"didSendXMPPMessage %@", message.body);
    
    for (NSInteger i = self.arrMessage.count-1; i >= 0; i -- ) {
        StorageMessage *stoMessage = self.arrMessage[i];
        if (stoMessage.mesId == message.messageId.integerValue) {
            stoMessage.status = IMMessageStatusNormal;
        }
    }
    
    [self refreshTableScrollToMessage:NO];
}

- (void)didFailToSendMessage:(NSNumber *)mesId{
    
    for (NSInteger i = self.arrMessage.count-1; i >= 0; i -- ) {
        StorageMessage *stoMessage = self.arrMessage[i];
        if (stoMessage.mesId == mesId.integerValue) {
            stoMessage.status = IMMessageStatusFailure;
        }
    }
    
    [self refreshTableScrollToMessage:NO];
}

- (void)streamDidDisconnected:(XMPPStream *)sender{
    AMLog(@"<<<<<<<<< streamDidDisconnected %c >>>>>>>>>>>>", sender.keepAliveWhitespaceCharacter);
    
}



#pragma mark - UITableView Delegate & Data Source
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"TextCell";
    
    StorageMessage *message = [_arrMessage objectAtIndex:indexPath.row];
    
    switch (message.type) {
        case IMMessageTypeText:
        {
            identifier = @"TextCell";
        }
            break;
        case IMMessageTypeCar:
        {
            identifier = @"CarCell";
        }
            break;
        case IMMessageTypeImage:
        {
            identifier = @"ImageCell";
        }
            break;
        default:
            break;
    }
    
    //生成 cell
    BaseChatCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        switch (message.type) {
            case IMMessageTypeText:
            {
                cell = [[TextChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
                break;
            case IMMessageTypeCar:
            {
                cell = [[CarInfoChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
                break;
            case IMMessageTypeImage:
            {
                cell = [[ImageChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
                break;
            default:
                break;
        }
        cell.delegate = self.delegateOfCell;
        cell.resendDelegate = self;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (message.type == IMMessageTypeImage) {
        [cell setChatCellWithMessage:message contact:_contact];
    }
    else{
        [cell setChatCellWithMessage:message];
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self dismissKeyboard];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrMessage.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    StorageMessage *message = [_arrMessage objectAtIndex:indexPath.row];
    switch (message.type) {
        case IMMessageTypeText:
        {
            TextMessageBody *tmBody = (TextMessageBody *)message.mesBody;
            return [TextChatCell heightOfTextCell:tmBody.message];
        }
            break;
        case IMMessageTypeCar:
        {
            return kCellCarHeight;
        }
            break;
        case IMMessageTypeImage:
        {
            return kCellImageHeight;
        }
            break;
        default:
            return kCellDefaultHeight;
            break;
    }
}

#pragma mark - uiscrollview delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(ChatListView:shouldDismissKeyboard:)]) {
        [self.delegate ChatListView:self shouldDismissKeyboard:YES];
    }
}

#pragma mark - dealloc
- (void)dealloc{
    
}

@end
