//
//  XMPPMessageUploader.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-28.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "XMPPMessageUploader.h"
#import "XMPPFileCacheManager.h"
#import "ImageMessageBody.h"
#import "VoiceMessageBody.h"
#import "IMCacheManage.h"


@interface XMPPMessageUploader ()



@end

@implementation XMPPMessageUploader

//+ (id)sharedUploader
//{
//    static XMPPMessageUploader *uploader = nil;
//    if (uploader == nil) {
//        uploader = [[XMPPMessageUploader alloc] init];
//    }
//    return uploader;
//}

- (void)postImageMessage:(StorageMessage *)message contact:(StorageContact *)contact progressBlock:(ProgressBlock)progress completion:(CompletionBlock)completion{
    self.progress = progress;
    self.completion = completion;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSData *data = UIImageJPEGRepresentation(message.originalImage, 1.0);
        NSString *requestUrl = [IMCacheManage currentIMUserInfo].imgupload;
        
        ASIFormDataRequest *formRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
        formRequest.delegate = self;
        formRequest.tag = message.mesId;
        [formRequest setTimeOutSeconds:80];
        __weak ASIFormDataRequest *weakForm = formRequest;
        [formRequest setBytesSentBlock:^(unsigned long long size, unsigned long long total) {
            progress(weakForm.totalBytesSent, weakForm.postLength);
        }];
        [formRequest addData:data withFileName:@"tmp.jpg" andContentType:@"image/jpeg" forKey:@"myfile"];
        [formRequest addPostValue:contact.shortJid forKey:@"imId"];
        [formRequest setFailedBlock:^{
            AMLog(@"formRequest error %@",weakForm.error);
            message.status = IMMessageStatusFailure;
            self.completion(message);
        }];
        [formRequest setCompletionBlock:^{
            NSData *jsonData = weakForm.responseData;
            
            AMLog(@" ResponseString : %@ ",weakForm.responseString);
            
            id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
            
            if (jsonObj) {
                NSInteger returnCode = [[jsonObj objectForKey:@"returncode"] intValue];
                if (returnCode == 0) {
                    id result = [jsonObj objectForKey:@"result"];
                    
                    NSString *smallUrl = [result objectForKey:@"smallUri"];
                    NSString *originalUrl = [result objectForKey:@"uri"];
                    //                float fileSize = [[XMPPFileCacheManager sharedManager] imageFileSizeWithMessage:message];
                    
                    ImageMessageBody *imageBody = [[ImageMessageBody alloc] initWithSmallUri:smallUrl largeUri:originalUrl];
                    message.mesBody = imageBody;
                    message.message = imageBody.jsonString;
                    message.status = IMMessageStatusNormal;
                    
                    self.completion(message);
                }else{
                    message.status = IMMessageStatusFailure;
                    self.completion(message);
                }
            }
        }];
        [formRequest startSynchronous];
    });
}


//- (void)uploadMessage:(StorageMessage *)message progressBlock:(void(^)(unsigned long long sizeSent, unsigned long long total))progress completion:(void(^)(StorageMessage *mes))completion{
//    self.progress = progress;
//    self.completion = completion;
//    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    
//    dispatch_async(queue, ^{
//        
//        switch (message.type) {
//            case IMMessageTypeImage:
//            {
//                NSData *data = UIImageJPEGRepresentation(message.originalImage, 1.0);
//                
//                NSData *jsonData = [self postImageData:data progressBlock:^(unsigned long long sizeSent, unsigned long long total) {
//                    progress(sizeSent, total);
//                }] ;
//                id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
//                
//                if (jsonObj) {
//                    
//                    NSInteger returnCode = [[jsonObj objectForKey:@"returncode"] intValue];
//                    if (returnCode == 0) {
//                        id result = [jsonObj objectForKey:@"result"];
//                        
//                        NSString *smallUrl = [result objectForKey:@"smallUri"];
//                        NSString *originalUrl = [result objectForKey:@"uri"];
////                        float fileSize = [[XMPPFileCacheManager sharedManager] imageFileSizeWithMessage:message];
//                        
//                        ImageMessageBody *imageBody = [[ImageMessageBody alloc] initWithSmallUri:smallUrl largeUri:originalUrl];
//                        message.mesBody = imageBody;
//                        message.message = imageBody.jsonString;
//                        message.status = IMMessageStatusNormal;
//                        
//                        self.completion(message);
//                    }else{
//                        message.status = IMMessageStatusFailure;
//                        self.completion(message);
//                    }
//                }
//            }
//                break;
//            case IMMessageTypeVoice:
//            {
//                NSData *jsonData = [self postVoiceData:message.amrData];
//                id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
//                
//                if (jsonObj) {
//                    
//                    NSInteger returnCode = [[jsonObj objectForKey:@"returncode"] intValue];
//                    if (returnCode == 0) {
//                        id result = [jsonObj objectForKey:@"result"];
//                        
//                        NSString *voiceUri = [result objectForKey:@"uri"];
//                        
//                        VoiceMessageBody *voiceBody = [[VoiceMessageBody alloc] initWithVoiceUri:voiceUri andDuration:message.duration];
//                        
//                        message.status = IMMessageStatusNormal;
//                        message.mesBody = voiceBody;
//                        message.message = voiceBody.jsonString;
//                        
//                        self.completion(message);
//                    }else{
//                        message.status = IMMessageStatusFailure;
//                        self.completion(message);
//                    }
//                }
//            }
//                break;
//            default:
//                break;
//        }
//    });
//}
//
//- (NSData *)postImageData:(NSData *)data progressBlock:(void(^)(unsigned long long sizeSent, unsigned long long total))progress
//{
//    
//    NSString *requestUrl = [IMCacheManage currentIMUserInfo].serverimg;
//    
//    if (self.formRequest != nil)
//    {
//        [self.formRequest clearDelegatesAndCancel];
//    }
//    
//    self.formRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
//    self.formRequest.delegate = self;
//    [self.formRequest setTimeOutSeconds:80];
//    [self.formRequest setBytesSentBlock:^(unsigned long long size, unsigned long long total) {
//        AMLog(@">>>setBytesSentBlock>>>>> %f", (float)size/total);
//        progress(size, total);
//    }];
//    
//    [self.formRequest addData:data withFileName:@"tmp.jpg" andContentType:@"image/jpeg" forKey:@"myfile"];
//    
//    [self.formRequest startSynchronous];
//    
//    NSLog(@" ResponseString : %@ ",self.formRequest.responseString);
//    
//    return self.formRequest.responseData;
//}
//
//- (NSData *)postVoiceData:(NSData *)data
//{
//    NSString *requestUrl = [IMCacheManage currentIMUserInfo].servervoice;
//    
//    if (self.formRequest != nil)
//    {
//        [self.formRequest clearDelegatesAndCancel];
//    }
//    
//    self.formRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
//    self.formRequest.delegate = self;
//    [self.formRequest setTimeOutSeconds:100];
//    
//    [self.formRequest addData:data withFileName:@"tmp.amr" andContentType:@"audio/amr" forKey:@"myfile"];
//    
//    [self.formRequest startSynchronous];
//    return self.formRequest.responseData;
//}

@end
