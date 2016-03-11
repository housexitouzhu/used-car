//
//  EmojiFaceData.m
//  IMDemo
//
//  Created by jun on 11/20/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "EmojiFaceData.h"
#import "DDXML.h"

@implementation EmojiFaceData

- (id)init
{
    if (self = [super init]) {
        
        [self initData];
    }
    return self;
}

- (void)initData
{
    NSMutableArray *textArray = [NSMutableArray array];
    NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"xml"];
    NSString *xmlString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding
                                                             error:nil];
    NSXMLElement *rootElement = [[NSXMLElement alloc] initWithXMLString:xmlString error:nil];
    NSArray *emojiChildren = [rootElement children];
    
    for (int i = 0; i< emojiChildren.count; i++) {
        
        NSXMLElement *e = [emojiChildren objectAtIndex:i];
        
        //int tag = [[e attributeForName:@"Tag"].stringValue intValue];
        NSString *text = [e attributeForName:@"Text"].stringValue;
        NSString *image = [e attributeForName:@"Image"].stringValue;
        [textArray addObject:text];
        [imageDic setObject:image forKey:text];
    }
    
    self.emojiTextArray = textArray;
    self.emojiDictionary = imageDic;
}

+ (NSArray *)emojiTextArray
{
    return [[self sharedData] emojiTextArray];
}

+ (NSDictionary *)emojiDictionary
{
    return [[self sharedData] emojiDictionary];
}

+ (id)sharedData
{
    static EmojiFaceData *data = nil;
    if (data == nil) {
        data = [[EmojiFaceData alloc] init];
    }
    return data;
}

+ (NSString *)emojiText:(int)index
{
    if (index >= 0 && index < self.emojiTextArray.count) {
        return [self.emojiTextArray objectAtIndex:index];
    }
    return nil;
}

+ (UIImage *)emojiImage:(NSString *)text
{
    if (text) {
        NSString *imageName = [self.emojiDictionary objectForKey:text];
        return [UIImage imageNamed:imageName];
    }
    return nil;
}

+ (BOOL)isContainsEmojiText:(NSString *) text
{
    return [self.emojiTextArray containsObject:text];
}

@end
