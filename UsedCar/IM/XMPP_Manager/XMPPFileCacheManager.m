//
//  XMPPFileCacheManager.m
//  IMDemo
//
//  Created by jun on 11/8/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "XMPPFileCacheManager.h"

#import "NSString+Util.h"
#import "FileManager.h"
#import "IMUserInfoModel.h"
#import "StorageMessage.h"
#import "IMCacheManage.h"

#define kDBDirName (@"DB")
#define kDBFileName (@"xmpp.db")
#define kImgDirName (@"IMG")
#define kVoiceDirName (@"Voice")

@implementation XMPPFileCacheManager

+ (id)sharedManager
{
    static XMPPFileCacheManager *fileCacheManager = nil;
    if (fileCacheManager == nil) {
        fileCacheManager = [[XMPPFileCacheManager alloc] init];
    }
    return fileCacheManager;
}

- (NSString *)cacheDirPath
{
    IMUserInfoModel *mIMUserInfo = [IMCacheManage currentIMUserInfo];
    
    NSString *docDir = [FileManager defaultDocumentsPath];
    NSString *currentJid = mIMUserInfo.name;
    return [docDir stringByAppendingPathComponent:currentJid.md5];
}

- (NSString *)currentIMGPath
{
    return [self.cacheDirPath stringByAppendingPathComponent:kImgDirName];
}

// 获取图片缓存路径
- (NSString *)imgCacheDirPathForJid:(NSString *)jid
{
    if (jid != nil && jid.length > 0) {
        
        NSString *imgPath = [self.currentIMGPath stringByAppendingPathComponent:jid.md5];
        return imgPath;
    }
    return nil;
}

- (NSString *)currentVoicePath
{
    return [self.cacheDirPath stringByAppendingPathComponent:kVoiceDirName];
}

// 获取语音缓存路径
- (NSString *)voiceCacheDirPathForJid:(NSString *)jid
{
    if (jid != nil && jid.length > 0) {
        
        NSString *voicePath = [self.currentVoicePath stringByAppendingPathComponent:jid.md5];
        return voicePath;
    }
    return nil;
}

- (NSString *)voicePathForMessage:(StorageMessage *)message
{
    return [[self voiceCacheDirPathForJid:message.jid] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.voice",message.mesId]];
}

- (BOOL) saveSmallImage:(UIImage *)image withMesId:(int)mesId andJid:(NSString *)jid
{
    return [self saveSmallImageData:UIImageJPEGRepresentation(image, 1.0) withMesId:mesId andJid:jid];
}

- (BOOL) saveSmallImageData:(NSData *)data withMesId:(int)mesId andJid:(NSString *)jid
{
    if (data != nil && mesId >= 0 && jid != nil && jid.length > 0){
     
        NSString *imgDir = [self imgCacheDirPathForJid:jid];
        NSString *imgName = [NSString stringWithFormat:@"%d.pic_thum",mesId];
        NSString *picThumPath = [imgDir stringByAppendingPathComponent:imgName];
        return [FileManager saveData:data toPath:picThumPath];
    }
    return NO;
}

- (BOOL) saveOriginalImage:(UIImage *)image withMesId:(int)mesId andJid:(NSString *)jid
{
    return [self saveOriginalImageData:UIImageJPEGRepresentation(image, 1.0) withMesId:mesId andJid:jid];
}

- (BOOL) saveOriginalImageData:(NSData *)data withMesId:(int)mesId andJid:(NSString *)jid
{
    if (data != nil && mesId >= 0 && jid != nil && jid.length > 0){
        
        NSString *imgDir = [self imgCacheDirPathForJid:jid];
        NSString *imgName = [NSString stringWithFormat:@"%d.pic",mesId];
        NSString *picPath = [imgDir stringByAppendingPathComponent:imgName];
        return [FileManager saveData:data toPath:picPath];
    }
    return NO;
}

- (BOOL) saveVoiceData:(NSData *)data withMesId:(int)mesId andJid:(NSString *)jid
{
    if (data != nil && mesId >= 0 && jid != nil && jid.length > 0){
        
        NSString *voiceDir = [self voiceCacheDirPathForJid:jid];
        NSString *voiceName = [NSString stringWithFormat:@"%d.voice",mesId];
        NSString *voicePath = [voiceDir stringByAppendingPathComponent:voiceName];
        return [FileManager saveData:data toPath:voicePath];
    }
    return NO;
}

- (UIImage *)smallImageWithMesId:(int)mesId andJid:(NSString *)jid
{
    if (mesId >= 0 && jid != nil && jid.length > 0) {
        NSString *imgDir = [self imgCacheDirPathForJid:jid];
        NSString *imgName = [NSString stringWithFormat:@"%d.pic_thum",mesId];
        NSString *picThumPath = [imgDir stringByAppendingPathComponent:imgName];
        return [UIImage imageWithContentsOfFile:picThumPath];
    }
    return nil;
}

- (UIImage *)originalImageWithMesId:(int)mesId andJid:(NSString *)jid
{
    if (mesId >= 0 && jid != nil && jid.length > 0) {
        NSString *imgDir = [self imgCacheDirPathForJid:jid];
        NSString *imgName = [NSString stringWithFormat:@"%d.pic",mesId];
        NSString *picPath = [imgDir stringByAppendingPathComponent:imgName];
        return [UIImage imageWithContentsOfFile:picPath];
    }
    return nil;
}

- (NSData *)voiceDataWithMesId:(int)mesId andJid:(NSString *)jid
{
    if (mesId >= 0 && jid != nil && jid.length > 0) {
        NSString *voiceDir = [self voiceCacheDirPathForJid:jid];
        NSString *voiceName = [NSString stringWithFormat:@"%d.voice",mesId];
        NSString *voicePath = [voiceDir stringByAppendingPathComponent:voiceName];
        return [NSData dataWithContentsOfFile:voicePath];
    }
    return nil;
}

- (NSString *)currentDBPath
{
    return [[self.cacheDirPath stringByAppendingPathComponent:kDBDirName]
            stringByAppendingPathComponent:kDBFileName];
}

- (BOOL)createDBFileIfNessary
{
    NSString *dbPath = self.currentDBPath;
    if ([FileManager fileExistsAtPath:dbPath]) {
        return YES;
    }
    
    NSString *dbDir = [self.currentDBPath stringByDeletingLastPathComponent];
    //如果不存在创建对应的目录，并copy对应的DB文件到相应目录中
    BOOL exists = [FileManager createDirPath:dbDir];
    if (exists) {
        NSString *bundleDBPath = [[NSBundle mainBundle] pathForResource:@"xmpp" ofType:@"db"];
        return [FileManager copyFilePath:bundleDBPath toFilePath:dbPath];
    }
    return NO;
}

- (float)imageFileSizeWithMessage:(StorageMessage *)message
{
    if (message != nil) {
        NSString *imgDir = [self imgCacheDirPathForJid:message.jid];
        NSString *imgName = [NSString stringWithFormat:@"%d.pic",message.mesId];
        NSString *picPath = [imgDir stringByAppendingPathComponent:imgName];
        return [FileManager fileSizeAtPath:picPath];
    }
    return 0;
}

- (BOOL)saveToCacheWithMessage:(StorageMessage *)message
{
    if (message != nil) {
        switch (message.type) {
            case IMMessageTypeImage:
            {
                [self saveOriginalImage:message.originalImage withMesId:message.mesId andJid:message.jid];
                [self saveSmallImage:message.smallImage withMesId:message.mesId andJid:message.jid];
                return YES;
            }
                break;
            case IMMessageTypeVoice:
            {
                [self saveVoiceData:message.amrData withMesId:message.mesId andJid:message.jid];
            }
                break;
            default:
                break;
        }
    }
    return NO;
}

- (StorageMessage *)loadCacheForMessage:(StorageMessage *)message
{
    if (message != nil) {
        switch (message.type) {
            case IMMessageTypeImage:
            {
                message.originalImage = [self originalImageWithMesId:message.mesId andJid:message.jid];
                message.smallImage = [self smallImageWithMesId:message.mesId andJid:message.jid];
            }
                break;
            case IMMessageTypeVoice:
            {
                message.amrData = [self voiceDataWithMesId:message.mesId andJid:message.jid];
            }
                break;
            default:
                break;
        }
    }
    return message;
}

- (StorageMessage *)loadVoiceCacheForMessage:(StorageMessage *)message
{
    if (message.type == IMMessageTypeVoice && message.amrData == nil) {
        message.amrData = [self voiceDataWithMesId:message.mesId andJid:message.jid];
    }
    return message;
}

- (void)removeImageCacheWithJid:(NSString *)jid
{
    NSString *cachePath = [self imgCacheDirPathForJid:jid];
    //[FileManager removeSubItemOfForderPath:cachePath];
    [FileManager removeItemAtPath:cachePath];
}

- (void)removeVoiceCacheWithJid:(NSString *)jid
{
    NSString *cachePath = [self voiceCacheDirPathForJid:jid];
    //[FileManager removeSubItemOfForderPath:cachePath];
    [FileManager removeItemAtPath:cachePath];
}

@end
