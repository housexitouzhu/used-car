//
//  XMPPFileCacheManager.h
//  IMDemo
//
//  Created by jun on 11/8/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import <Foundation/Foundation.h>


@class StorageMessage;

/*!
 *  @class
 *  @abstract  管理XMPP文件缓存的Manager类
 */
@interface XMPPFileCacheManager : NSObject

+ (id)sharedManager;

/*!
 *  @method
 *  @abstract  获取对应jid的图片缓存目录
 *  @param jid
 *  @return 对应jid的图片缓存目录
 */
- (NSString *)imgCacheDirPathForJid:(NSString *)jid;

/*!
 *  @method
 *  @abstract  获取对应jid的语音缓存目录
 *  @param jid
 *  @return 对应jid的图片缓存目录
 */
- (NSString *)voiceCacheDirPathForJid:(NSString *)jid;

//获取对应message的语音的文件缓存路径
- (NSString *)voicePathForMessage:(StorageMessage *)message;

/*!
 *  @method
 *  @abstract  获取当前登陆用户的数据库DB文件路径
 *  @return DB的路径
 */
- (NSString *)currentDBPath;

/*!
 *  @method
 *  @abstract  创建对应的数据库文件
 *  @return 是否创建成功
 */
- (BOOL)createDBFileIfNessary;


- (BOOL) saveSmallImage:(UIImage *)image withMesId:(int)mesId andJid:(NSString *)jid;

/*!
 *  @method
 *  @abstract  保存缩略图到对应的MesId 和 jid
 *  @param data 图片数据
 *  @param mesId
 *  @param jid
 *  @return 是否保存成功
 */
- (BOOL) saveSmallImageData:(NSData *)data withMesId:(int)mesId andJid:(NSString *)jid;

- (BOOL) saveOriginalImage:(UIImage *)image withMesId:(int)mesId andJid:(NSString *)jid;

/*!
 *  @method
 *  @abstract  保存原图到对应的MesId 和 jid
 *  @param data 图片数据
 *  @param mesId
 *  @param jid
 *  @return 是否保存成功
 */
- (BOOL) saveOriginalImageData:(NSData *)data withMesId:(int)mesId andJid:(NSString *)jid;

/*!
 *  @method
 *  @abstract   保存语音到对应的MesId 和 jid
 *  @param data  语音数据
 *  @param mesId
 *  @param jid
 *  @return 是否保存成功
 */
- (BOOL) saveVoiceData:(NSData *)data withMesId:(int)mesId andJid:(NSString *)jid;

/*!
 *  @method
 *  @abstract  根据 mesId 和 jid 获取小图数据
 *  @param mesId
 *  @param jid
 *  @return 小图
 */
- (UIImage *)smallImageWithMesId:(int)mesId andJid:(NSString *)jid;

/*!
 *  @method
 *  @abstract  根据 mesId 和 jid 获取原图数据
 *  @param mesId
 *  @param jid
 *  @return 原图
 */
- (UIImage *)originalImageWithMesId:(int)mesId andJid:(NSString *)jid;

/*!
 *  @method
 *  @abstract  根据 mesId 和 jid 获取语音数据
 *  @param mesId
 *  @param jid
 *  @return 语音
 */
- (NSData *)voiceDataWithMesId:(int)mesId andJid:(NSString *)jid;

/*!
 *  @method
 *  @abstract  获取指定图片的文件大小
 *  @param message
 *  @return
 */
- (float)imageFileSizeWithMessage:(StorageMessage *)message;

/*!
 *  @method
 *  @abstract  保存message的图片、语音到文件缓存
 *  @param message
 *  @return 是否保存成功
 */
- (BOOL)saveToCacheWithMessage:(StorageMessage *)message;

/*!
 *  @method
 *  @abstract  从缓存中加载message的图片、语音
 *  @param message
 *  @return
 */
- (StorageMessage *)loadCacheForMessage:(StorageMessage *)message;

- (StorageMessage *)loadVoiceCacheForMessage:(StorageMessage *)message;

/******************************* 删除缓存 **************************************/

- (void)removeImageCacheWithJid:(NSString *)jid;

- (void)removeVoiceCacheWithJid:(NSString *)jid;

@end
