//
//  ImageMessage.h
//  IMDemo
//
//  Created by jun on 11/4/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "MessageBody.h"

@interface ImageMessageBody : MessageBody

// 图片信息缩略图URL
@property (nonatomic,retain) NSString *smallUri;

// 图片信息原图URL
@property (nonatomic,retain) NSString *uri;


- (id)initWithSmallUri:(NSString *)sUri largeUri:(NSString *)largeUri;

@end
