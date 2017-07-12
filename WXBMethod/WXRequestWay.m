//
//  WXRequestWay.m
//  WXRequestWay
//
//  Created by mamie on 17/5/9.
//  Copyright © 2017年 mamie. All rights reserved.
//

#import "WXRequestWay.h"
#import "AFNetworking.h"
@implementation WXRequestWay
+(void)getRequest:(NSString*)url  parameters:(NSDictionary*)parameters cache:(BOOL)iscache  completion:(void(^)(BOOL success,NSDictionary *jsonData, NSError*error))completion{
    
    NSMutableURLRequest *request=[[AFJSONRequestSerializer serializer]requestWithMethod:@"GET" URLString:url parameters:parameters error:nil];
    [request setCachePolicy:iscache?NSURLRequestUseProtocolCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:20.0];
    
    [self urlRequest:request cache:iscache completion:completion];
}
+(void)postRequest:(NSString*)url  parameters:(NSDictionary*)parameters cache:(BOOL)iscache  completion:(void(^)(BOOL success,NSDictionary *jsonData, NSError*error))completion{
    
    NSMutableURLRequest* request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:parameters error:nil];
    [request setCachePolicy:iscache?NSURLRequestUseProtocolCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:20.0];
    [self urlRequest:request cache:iscache completion:completion];
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:iscache?NSURLRequestUseProtocolCachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
//    request.HTTPMethod=@"POST";
//    request.allHTTPHeaderFields=parameters;
}
+(void)urlRequest:(NSMutableURLRequest*)request cache:(BOOL)iscache completion:(void(^)(BOOL success,NSDictionary *jsonData, NSError*error))completion{
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *agent=[request valueForHTTPHeaderField:@"User-Agent"];
    NSString *bundleName=[(NSDictionary*)[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleExecutable"];
    agent=[agent stringByReplacingOccurrencesOfString:bundleName withString:[NSString stringWithFormat:@"ios%@",bundleName]];
    [request setValue:agent forHTTPHeaderField:@"User-Agent"];
  
    NSUserDefaults *user = [[NSUserDefaults alloc]initWithSuiteName:@"defalutUser"];
    NSString  * token =[user valueForKey:@"wxToken"];
    [request setValue:[NSString stringWithFormat:@"%@",[token isEqual:[NSNull null]]||[token isEqual:@"(null)"]?@"":token] forHTTPHeaderField:@"Authorization"];
    
    //configuration
    NSURLSessionConfiguration *urlSessionConfig=[NSURLSessionConfiguration defaultSessionConfiguration];
    urlSessionConfig.HTTPShouldSetCookies=YES;
    urlSessionConfig.HTTPShouldUsePipelining=YES;
    urlSessionConfig.allowsCellularAccess=YES;
    urlSessionConfig.timeoutIntervalForResource=60.0;
    //manager
    AFURLSessionManager *manager=[[AFURLSessionManager alloc]initWithSessionConfiguration:urlSessionConfig];
    AFHTTPResponseSerializer*serializer=[AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes=[NSSet setWithObjects:@"text/html",@"application/json",@"text/json",@"text/plain", nil];
    manager.responseSerializer = serializer;
    serializer=nil;
    NSURLSessionDataTask *task=[manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        BOOL success=NO;
        NSError *parseError=nil;
        NSDictionary *jsonObject=nil;
        if(!error){
            jsonObject=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&parseError];
            !parseError?(success=YES):(success=NO);
        }else{
            if(iscache){
                //如果获取错误，有缓存，取缓存数据
                NSCachedURLResponse *cacheResponse =  [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
                if(cacheResponse.data){
                    jsonObject=[NSJSONSerialization JSONObjectWithData:cacheResponse.data options:NSJSONReadingAllowFragments error:&parseError];
                    !parseError?(success=YES):(success=NO);
                }else{
                    success=NO;
                }
            }else{
                success=NO;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completion){
                completion(success,jsonObject,error);
            }
        });
    }];
    [task resume];
}
+(void)removeAllCachedResponses{
    [[NSURLCache sharedURLCache]removeAllCachedResponses];
}
+(BOOL)hasNetWorkState{
   __block BOOL hasNetWork=YES;
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            hasNetWork= NO;
        }
    }];
    return hasNetWork;
}



@end
