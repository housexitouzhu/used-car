//
//  NSString+Util.h
//  UsedCar
//
//  Created by Alan on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Util)

+ (NSString *)openUDID;
- (NSString *)md5;
- (NSString *)encrypt3DES;
- (NSString *)decrypt3DES;
- (NSString *)encodeURL;
- (NSString *)trim;
- (NSString *)dNull;
- (BOOL)isContainsString:(NSString *)aString;
/* 防止显示（null） */
- (NSString *)dNull:(NSString *)replace;
- (int)lengthUnicode;
- (NSString *)omitForSize:(CGSize)size font:(UIFont *)font;

/* 3DES加密 */
- (NSString *)encrypt3DES:(NSString *)gkey iv:(NSString *)iv;
/* 3DES解密 */
- (NSString *)decrypt3DES:(NSString *)gkey iv:(NSString *)iv;

@end
