//
//  WXWayforQN.h
//  WXRequestWay
//
//  Created by mamie on 17/5/10.
//  Copyright © 2017年 mamie. All rights reserved.
//
#import <Foundation/Foundation.h>
@interface WXWayforQN :NSObject
/**
 上传文件去七牛

 @param fileData 文件数据
 @param fileName 文件名  为nil时表示是由七牛生成
 @param completion  success：是否上传成功   fileName：上传成功后的文件名   fileInfo：文件信息如：{h = 496; hash = FqUhGbp26QyamNwyzN54nge14vWj;key = "文件名";w = 748; error='错误信息'}
 */
+(void)uploadFileToQN:(NSData*__nonnull)fileData  fileName:(NSString*__nullable)fileName completion:(void(^__nullable)(BOOL success,NSDictionary*__nullable fileInfo,NSString *__nullable fileName))completion;

/**
 从七牛下载文件
 
 @param fileName 下载文件名
 @param thumbnail 缩略图    imageView2/1/w/600/h/400
 @return 下载地址
 */
+(NSString*__nonnull)downFileFormQN:(NSString*__nonnull)fileName thumbnail:(NSString*__nullable)thumbnail;
@end

