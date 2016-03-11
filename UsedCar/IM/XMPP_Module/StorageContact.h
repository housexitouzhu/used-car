//
//  StorageContact.h
//  IMDemo
//
//  Created by jun on 11/11/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IMHistoryContactModel;
/*!
 
 CREATE TABLE Contacts (
 contactId integer PRIMARY KEY AUTOINCREMENT NOT NULL,
 jid_short text NOT NULL,
 jid_full text NOT NULL,
 name text,
 shortPY text,
 fullPY text,
 photo text,
 position text,
 dealerName text,
 mainBrand text,
 address text,
 certification text,
 unReadNum integer,
 lastInput text,
 mostRecentMessage text,
 mostRecentTime integer,
 mostRecentStatus integer
 );
 
 */

@class StorageMessage;

@interface StorageContact : NSObject

@property (nonatomic) NSInteger contactId;
@property (nonatomic,strong) NSString *shortJid;
@property (nonatomic,strong) NSString *fullJid;
@property (nonatomic,strong) NSString *carJson;
@property (nonatomic,strong) NSString *nickName;
@property (nonatomic,strong) NSString *dealerid;
@property (nonatomic,strong) NSString *salesid;
@property (nonatomic,strong) NSString *memberid;
@property (nonatomic,strong) NSString *dealerName;
@property (nonatomic,strong) NSString *carid;
@property (nonatomic,strong) NSString *photo;
@property (nonatomic,strong) NSString *carName;
@property (nonatomic) NSInteger isComplete;
@property (nonatomic) NSInteger unReadNum;
@property (nonatomic,strong) NSString *mostRecentMessage;
@property (nonatomic) double mostRecentTime;
@property (nonatomic) NSInteger mostRecentStatus;
@property (nonatomic) NSInteger isDeleted;

@property (nonatomic,strong) NSDate *mostRecentDate;

// 暂时未用到
@property (nonatomic,strong) NSString *name;


/*!
 *  @method
 *  @abstract  更新联系人的最新发送消息内容
 *  @param message
 */
- (void)updateMostRecentMessage:(StorageMessage *)message;

@end
