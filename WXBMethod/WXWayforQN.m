//
//  WXWayforQN.m
//  WXRequestWay
//
//  Created by mamie on 17/5/10.
//  Copyright © 2017年 mamie. All rights reserved.
//
#define WXQN_ACCESSKEY @"JSsaO6S_oHvKLSPjvOjddYZzsLILy3Z96kLz7E-B"//accesskey
#define WXQN_SECRETKEY @"FLdU-mwyTgQLYuR6XXMRoNYx9KjutNybiMHL4Q0F"//secretkey
#define WXQN_BUCKET    @"wqcypt2"                                //空间名
#define WXQN_DOMAIN    @"http://7xn1dx.com1.z0.glb.clouddn.com"//域名


#import "QiniuSDK.h"
#import "QN_GTM_Base64.h"
#import <CommonCrypto/CommonHMAC.h>

#import "WXWayforQN.h"
#import "WXFMDB.h"
@implementation WXWayforQN
+(void)uploadFileToQN:(NSData*__nonnull)fileData  fileName:(NSString*__nullable)fileName completion:(void(^__nullable)(BOOL success,NSDictionary*__nullable fileInfo,NSString *__nullable fileName))completion{
    
    NSString *token=[self getUploadTokenForQN:fileName];
    QNConfiguration *config=[QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone=[QNZone zone0];
    }];
    QNUploadManager *manager=[[QNUploadManager alloc]initWithConfiguration:config];
    [manager putData:fileData key:fileName token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        NSMutableDictionary *wInfo=[NSMutableDictionary dictionaryWithDictionary:resp];
        if(info.statusCode==200){
            if(completion){completion(YES,wInfo,key);}
        }else if(info.statusCode==413){
            if(completion){[wInfo setObject:@"文件多大,请重新传！" forKey:@"error"];completion(NO,wInfo,key);}
        }else if(info.statusCode==614){
            if(completion){[wInfo setObject:@"文件名已存在,请重新传！" forKey:@"error"];completion(NO,wInfo,key);}
        }else{
            if(completion){[wInfo setObject:@"文件上传失败,请重新传！" forKey:@"error"];completion(NO,wInfo,key);}
        }
    } option:nil];
}


+(NSString*__nonnull)downFileFormQN:(NSString*__nonnull)fileName thumbnail:(NSString*__nullable)thumbnail{
    [[WXFMDB shareDatabase]wx_creactTable:@"imgtab" withKeys:@{@"name":@"TEXT",@"url":@"TEXT",@"upTime":@"TEXT",@"endTime":@"TEXT"} withPrimaryKey:@"name"];
    NSDictionary *dic=[[WXFMDB shareDatabase]wx_queryTable:@"imgtab" whereFormat:[NSString stringWithFormat:@"name='%@'",fileName]];
    if(dic!=nil&&dic.count!=0){
        return [dic objectForKey:@"url"];
    }
    
    NSTimeInterval startTime=[[NSDate date]timeIntervalSince1970];
    NSTimeInterval endTime=startTime+7*24*60*60;
    
    
    NSString *url=[NSString stringWithFormat:@"%@/%@",WXQN_DOMAIN,fileName];
    NSNumber *outTime=[NSNumber numberWithDouble:floor(endTime)];
    if(thumbnail!=nil||thumbnail.length!=0){
        url=[NSString stringWithFormat:@"%@?%@&e=%@",url,thumbnail,outTime];
    }else{
        url=[NSString stringWithFormat:@"%@?e=%@",url,outTime];
    }
    
    const char *urlStr =[url UTF8String];
    const char *secretKeyStr =[WXQN_SECRETKEY UTF8String];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1,secretKeyStr, strlen(secretKeyStr), urlStr, strlen(urlStr), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *urlcode = [QNUrlSafeBase64 encodeData:HMAC];HMAC=nil;
    NSString *token = [NSString stringWithFormat:@"%@:%@",WXQN_ACCESSKEY, urlcode];
    NSString *downUrl=[NSString stringWithFormat:@"%@&token=%@",url,token];
    downUrl=[downUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[WXFMDB shareDatabase]wx_insertTable:@"imgtab" withValues:@{@"name":fileName,@"url":downUrl,@"upTime":@(startTime),@"endTime":@(endTime)}];
    [[WXFMDB shareDatabase]wx_deleteTable:@"imgtab" whereFormat:[NSString stringWithFormat:@"%f>endTime",startTime]];
    return downUrl;
}
/**
 生成上传七牛文件的token

 @return 返回token
 */
+(NSString*)getUploadTokenForQN:(NSString*)key{
    const char *secretKeyStr =[WXQN_SECRETKEY UTF8String];
    NSNumber *number=[NSNumber numberWithDouble:floor([[NSDate date] timeIntervalSince1970])+3600];
    
    //    1. “image/*“表示只允许上传图片类型；“image/jpeg;image/png”表示只允许上传jpg和png类型的图片； 真正服务器判断文件格式的字段 “!application/json;text/plain”表示禁止上传json文本和纯文本
    //    2. ["image/png", "image/jpeg", "application/zip", "application/rar", "application/x-rar", "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/pdf"],
    //    3.允许上传的文件类型 png jpg zip rar xls xlsx doc docx pdf
    //上传策略
    NSDictionary *dic=@{@"key": @"$(key)", @"hash": @"$(etag)", @"w": @"$(imageInfo.width)", @"h": @"$(imageInfo.height)"};
    NSData *returnData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *returnBody=[[NSString alloc]initWithData:returnData encoding:NSUTF8StringEncoding];
    NSDictionary  *putPolicy=@{@"scope":[NSString stringWithFormat:@"%@:%@",WXQN_BUCKET,key],
                               @"deadline":number,
                               @"fsizeLimit":[NSNumber numberWithDouble:1024*1024*20],
                               @"mimeLimit":@"image/jpeg;image/png;application/zip;application/rar;application/x-rar;application/vnd.ms-excel;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;application/msword;application/vnd.openxmlformats-officedocument.wordprocessingml.document;application/pdf",
                               @"returnBody":returnBody
                               };
    NSData *jsonStrData=[NSJSONSerialization dataWithJSONObject:putPolicy options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr=[[NSString alloc]initWithData:jsonStrData encoding:NSUTF8StringEncoding];

    NSData *policyData=[jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    returnBody=nil;jsonStr=nil;
    NSString *policyStr=[QN_GTM_Base64 stringByWebSafeEncodingData:policyData padded:YES];
    const char *encodedPolicyStr = [policyStr cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, secretKeyStr, strlen(secretKeyStr), encodedPolicyStr, strlen(encodedPolicyStr), cHMAC);
    
    NSString *encodedDigest = [QN_GTM_Base64 stringByWebSafeEncodingBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH padded:TRUE];
    
    NSString *token = [NSString stringWithFormat:@"%@:%@:%@", WXQN_ACCESSKEY, encodedDigest, policyStr];    return token;
}
@end
