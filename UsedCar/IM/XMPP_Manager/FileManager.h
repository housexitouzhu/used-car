//
//  JFileManager.h
//  TuGua
//
//  Created by jun on 6/16/13.
//  Copyright (c) 2013 eshellcn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (BOOL)fileExistsAtPath: (NSString *)filePath;

/*!
 @method
 @abstract 获取指定文件的大小
 @param filePath 文件的路径
 @result nil
 */
+ (float) fileSizeAtPath:(NSString*) filePath;

/*!
 @method
 @abstract 获取指定目录的大小
 @param filePath 文件的路径
 @result nil
 */
+ (float) folderSizeAtPath:(NSString*) folderPath;

/*!
 @method
 @abstract  删除指定路径的文件
 @param path 具体文件的路径
 @return 是否删除成功
 */
+ (BOOL)removeItemAtPath:(NSString *)path;

/*!
 @method
 @abstract  移除指定目录下的所有文件
 @discussion  (包括目录下的子目录)
 @param forderPath 要移除的目录的路径
 */
+ (void)removeSubItemOfForderPath:(NSString *)forderPath;

/*!
 @method
 @abstract  获取App默认的Cache目录路径
 @return App默认的Cache目录路径
 */
+ (NSString *)defaultCachePath;

/*!
 @method
 @abstract  获取App默认的Document目录路径
 @return App默认的Document目录路径
 */
+ (NSString *)defaultDocumentsPath;

/*!
 @method
 @abstract  获取App默认的Downloads目录路径
 @return App默认的Downloads目录路径
 */
+ (NSString *)defaultDownloadsPath;

/*!
 *  @method
 *  @abstract 保存数据到指定位置
 *  @param data
 *  @param path
 *  @return 是否保存成功
 */
+ (BOOL)saveData:(NSData *)data toPath:(NSString *)path;

/*!
 *  @method
 *  @abstract  从指定位置加载数据
 *  @param path
 *  @return 数据
 */
+ (NSData *)loadDataForPath:(NSString *)path;

/*!
 @method
 @abstract  保存图片到指定目录
 @param directoryPath 目录的路径
 @param image      图片对象
 @param imageName     图片名称
 @return 是否保存成功
 */
+ (BOOL) saveImageToPath:(NSString *)directoryPath  image:(UIImage *)image imageName:(NSString *)imageName;

/*!
 @method
 @abstract  从指定目录加载图片文件
 @param directoryPath 
 @param imageName     目录的路径
 @return 图片对象
 */
+ (UIImage *) loadImageDataFromPath:(NSString *)directoryPath imageName:( NSString *)imageName;

/*!
 @method
 @abstract  重命名
 @param oldPath     老路径名
 @param newPath     新路径名
 @return 是否操作成功
 */
+ (BOOL)renameFilePath:(NSString *)oldPath toFilePath:(NSString *)newPath;

/*!
 @method
 @abstract  重命名
 @param oldPath     老路径名
 @param newPath     新路径名
 @return 是否操作成功
 */
+ (BOOL)copyFilePath:(NSString *)oldPath toFilePath:(NSString *)newPath;

/*!
 @method
 @abstract  Cache目录下文件的路径
 @param fileName 文件名称
 @return 文件路径
 */
+ (NSString *) pathInCacheDirectory:(NSString *)fileName;

/*!
 @method
 @abstract  在cache目录下创建目录
 @param dirName 目录名称
 @return 是否创建成功
 */
+ (BOOL) createDirInCache:(NSString *)dirName;

/*!
 *  @method
 *  @abstract  创建指定路径的Dir
 *  @param dirPath
 *  @return 是否创建成功
 */
+ (BOOL)createDirPath:(NSString *)dirPath;

@end
