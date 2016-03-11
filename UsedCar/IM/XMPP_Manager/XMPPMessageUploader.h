//
//  XMPPMessageUploader.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-28.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StorageMessage.h"
#import "StorageContact.h"
#import "ASIFormDataRequest.h"

typedef void(^CompletionBlock)(StorageMessage *message);
typedef void (^ProgressBlock)(unsigned long long sizeSent, unsigned long long total);

@interface XMPPMessageUploader : NSObject

//@property (nonatomic, strong) ASIFormDataRequest *formRequest;
@property (nonatomic, copy) CompletionBlock completion;
@property (nonatomic, copy) ProgressBlock progress;

//+ (id)sharedUploader;

//- (void)uploadMessage:(StorageMessage *)message progressBlock:(void(^)(unsigned long long sizeSent, unsigned long long total))progress completion:(void(^)(StorageMessage *mes))completion;

- (void)postImageMessage:(StorageMessage *)message contact:(StorageContact *)contact  progressBlock:(ProgressBlock)progress completion:(CompletionBlock)completion;


@end
