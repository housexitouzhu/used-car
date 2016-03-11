//
//  EmojiFaceData.h
//  IMDemo
//
//  Created by jun on 11/20/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmojiFaceData : NSObject

@property (nonatomic,retain) NSArray *emojiTextArray;
@property (nonatomic,retain) NSDictionary *emojiDictionary;

+ (id)sharedData;

+ (NSString *)emojiText:(int)index;

+ (UIImage *)emojiImage:(NSString *)text;

+ (BOOL)isContainsEmojiText:(NSString *) text;

@end
