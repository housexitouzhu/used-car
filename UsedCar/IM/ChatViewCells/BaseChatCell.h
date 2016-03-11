//
//  ChatCell.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StorageMessage.h"
#import "BubbleButton.h"
#import "XMPPMessageUploader.h"

@class BubbleButtonText;
@class BubbleButtonCar;
@class BubbleButtonImage;
@class BubbleButtonVoice;

typedef enum : NSUInteger {
    ChatCellTypeText,
    ChatCellTypeImage,
    ChatCellTypeVoice,
    ChatCellTypeCar,
    ChatCellTypeLocation,
    ChatCellTypeVCard,
    ChatCellTypeNotice
} ChatCellType;


@protocol ChatCellDelegate;
@protocol ChatCellResendDelegate;

@interface BaseChatCell : UITableViewCell

@property (nonatomic, assign          ) ChatCellType     cellType;
@property (nonatomic, assign          ) BubbleType       bubbleType;
@property (nonatomic, strong          ) UILabel          *labDuration;
@property (nonatomic, strong          ) UIImageView      *vNewDot;
@property (nonatomic, strong          ) UIButton         *btnResend;
@property (nonatomic, assign          ) id<ChatCellDelegate> delegate;
@property (nonatomic, assign          ) id<ChatCellResendDelegate> resendDelegate;
@property (nonatomic, strong, readonly) StorageMessage   *message;
@property (nonatomic, strong, readonly) StorageContact   *contact;

@property (nonatomic, strong) XMPPMessageUploader *uploader;


- (void)setChatCellWithMessage:(StorageMessage *)message;
- (void)setChatCellWithMessage:(StorageMessage *)message contact:(StorageContact *)contact;
//- (void)setChatCellWithMessage:(StorageMessage *)message contact:(StorageContact *)contact uploader:(XMPPMessageUploader *)uploader;


@end


@protocol ChatCellDelegate <NSObject>

@optional
- (void)ChatCell:(BaseChatCell *)cell buttonClickedWithMessage:(StorageMessage *)message;

@end

@protocol ChatCellResendDelegate <NSObject>

- (void)ChatCell:(BaseChatCell *)cell resendButtonClickedWithMessage:(StorageMessage *)message contact:(StorageContact *)contact;

@end


