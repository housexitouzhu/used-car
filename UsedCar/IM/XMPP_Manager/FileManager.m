//
//  JFileManager.m
//  TuGua
//
//  Created by jun on 6/16/13.
//  Copyright (c) 2013 eshellcn. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

+ (BOOL)fileExistsAtPath: (NSString *)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return YES;
    }
    return NO;
}

+ (float)fileSizeAtPath:(NSString *)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        long long fileSize = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        return fileSize/1000.0;
    }
    return 0;
}

+ (float)folderSizeAtPath:(NSString *)folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) {
        return 0;
    }
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    double folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    
    return folderSize;
}

+ (NSString *)defaultCachePath
{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)defaultDocumentsPath
{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)defaultDownloadsPath
{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory,NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (BOOL)removeItemAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:path error:nil];
}

+ (void)removeSubItemOfForderPath:(NSString *)forderPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = YES;
    BOOL existed = [fileManager fileExistsAtPath:forderPath isDirectory:&isDir];
    
    if (isDir && existed) {
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:forderPath error:NULL];
        NSEnumerator *e = [contents objectEnumerator];
        NSString *filename;
        while ((filename = [e nextObject])) {
            [fileManager removeItemAtPath:[forderPath stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}

//location the path to the CacheDirectory
+ (NSString *) pathInCacheDirectory:(NSString *)fileName
{
    return [[self defaultCachePath] stringByAppendingPathComponent:fileName];
}

//创建缓存文件夹
+ (BOOL) createDirInCache:(NSString *)dirName
{
    NSString *imageDir = [self pathInCacheDirectory:dirName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    BOOL isCreated = NO;
    if ( !(isDir == YES && existed == YES) )
    {
        isCreated = [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (existed) {
        isCreated = YES;
    }
    return isCreated;
}

//
+ (BOOL)createDirPath:(NSString *)dirPath
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    BOOL isCreated = NO;
    if ( !(isDir == YES && existed == YES) )
    {
        isCreated = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (existed) {
        isCreated = YES;
    }
    return isCreated;
}

//重命名旧名称到新名称
+ (BOOL)renameFilePath:(NSString *)oldPath toFilePath:(NSString *)newPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager moveItemAtPath:oldPath toPath:newPath error:nil];
}

//重命名旧名称到新名称
+ (BOOL)copyFilePath:(NSString *)oldPath toFilePath:(NSString *)newPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager copyItemAtPath:oldPath toPath:newPath error:nil];
}

+ (BOOL)saveData:(NSData *)data toPath:(NSString *)path
{
    if (data != nil) {
        
        NSString *dir = [path stringByDeletingLastPathComponent];
        BOOL existed = [self createDirPath:dir];
        
        if (existed) {
            return [data writeToFile:path atomically:YES];
        }
    }
    
    return NO;
}

+ (NSData *)loadDataForPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        return [NSData dataWithContentsOfFile:path];
    }
    
    return nil;
}

+ (BOOL) saveImageToPath:(NSString *)directoryPath  image:(UIImage *)image imageName:(NSString *)imageName
{
    BOOL existed = [self createDirPath:directoryPath];
    
    bool isSaved = false;
    if (existed == YES )
    {
        isSaved = [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:imageName] options:NSAtomicWrite error:nil];
    }
    return isSaved;
}

+ (UIImage *) loadImageDataFromPath:(NSString *)directoryPath imageName:( NSString *)imageName
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dirExisted = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    if ( isDir == YES && dirExisted == YES )
    {
        NSString *imagePath = [directoryPath stringByAppendingPathComponent:imageName];
        
        BOOL fileExisted = [fileManager fileExistsAtPath:imagePath];
        if (!fileExisted) {
            return nil;
        }
        NSData *imageData = [NSData dataWithContentsOfFile : imagePath];
        return [UIImage imageWithData:imageData];
    }else{
        return nil;
    }
}

@end
