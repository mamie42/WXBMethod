//
//  WXRequestWay.h
//  WXRequestWay
//
//  Created by mamie on 17/5/9.
//  Copyright © 2017年 mamie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXRequestWay : NSObject
/*
 *post 请求数据
 *@param  url  请求的地址
 *@param  parameters  请求参数
 *@param  iscache  是否用缓存
 */

+(void)postRequest:(NSString*)url  parameters:(NSDictionary*)parameters cache:(BOOL)iscache  completion:(void(^)(BOOL success,NSDictionary *jsonData, NSError*error))completion;
+(void)getRequest:(NSString*)url  parameters:(NSDictionary*)parameters cache:(BOOL)iscache  completion:(void(^)(BOOL success,NSDictionary *jsonData, NSError*error))completion;

/*
 *清除所有的缓存
 */
+(void)removeAllCachedResponses;
@end
