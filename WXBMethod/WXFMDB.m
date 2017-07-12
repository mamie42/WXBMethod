//
//  WXFMDB.m
//  WXRequestWay
//
//  Created by mamie on 17/5/10.
//  Copyright © 2017年 mamie. All rights reserved.
//

#define SQLITE_NAME @"WXFMDB.db"
#define SQL_TEXT     @"TEXT" //文本
#define SQL_INTEGER  @"INTEGER" //整数类型
#define SQL_REAL     @"REAL" //浮点
#define SQL_BLOB     @"BLOB" //二进制类型


#import "WXFMDB.h"
#import "FMDB.h"
#import <objc/runtime.h>
@interface WXFMDB()
@property (nonatomic, strong)NSString *dbPath;
@property (nonatomic, strong)FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) FMDatabase* db;
@end
@implementation WXFMDB
-(NSString*)dbPath{
    if(!_dbPath){
        NSString *documentsDirectory= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        _dbPath= [documentsDirectory stringByAppendingPathComponent:SQLITE_NAME];
    }
    return _dbPath;
}
-(FMDatabaseQueue*)dbQueue{
    if(!_dbQueue){
        _dbQueue=[FMDatabaseQueue databaseQueueWithPath:self.dbPath];
    }
   return _dbQueue;
}
+(instancetype)shareDatabase{
    static WXFMDB *wxFMDB=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wxFMDB=[[WXFMDB alloc]init];
        FMDatabase *fmdb=[FMDatabase databaseWithPath:wxFMDB.dbPath];
        if([fmdb open]){
            wxFMDB.db=fmdb;
        }
    });
    return wxFMDB;
}
#pragma mark-创建表
-(BOOL)wx_creactTable:(NSString*)tableName withKeys:(id)keys withPrimaryKey:(NSString*)pKey{
    if([self.db tableExists:tableName]){
        return YES;
    }
    NSDictionary *dic;
    Class wxCls;
    if([keys isKindOfClass:[NSDictionary class]]){
        dic=keys;
    }else if([keys isKindOfClass:[NSObject class]]){
        wxCls=[keys class];
        dic=[self modelToDictionary:wxCls];
    }else{
        NSLog(@"创建表：传的keys类型不对！");
        return NO;
    }
    
    NSString *keyType=[dic objectForKey:pKey];
    
    NSMutableString *fieldStr = [[NSMutableString alloc] initWithFormat:@"DROP TABLE IF EXISTS '%@';CREATE TABLE '%@' ('%@' %@ NOT NULL,",tableName,tableName,pKey,keyType];
    int keyCount = 0;
    for (NSString * key in dic.allKeys) {
        keyCount++;
        if(![key isEqualToString:pKey]){
            [fieldStr appendFormat:@"'%@' %@,", key,dic[key]];
        }
    }
    [fieldStr appendFormat:@"PRIMARY KEY('%@'));",pKey];
    BOOL result=[self.db executeStatements:fieldStr];
    return result;
}

-(BOOL)wx_insertTable:(NSString*)tableName withValues:(id)values{
    if(![self.db tableExists:tableName]){
        NSLog(@"%@表不存在，请先创建",tableName);
        return NO;
    }
    NSDictionary *dic;
    if ([values isKindOfClass:[NSDictionary class]]) {
        dic = values;
    }else {
        dic = [self getModelPropertyKeyValue:values];
    }
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"replace into %@(",tableName];
    NSMutableString *tempStr = [NSMutableString stringWithCapacity:0];
    int keyCount = 0;
    for (NSString * key in dic.allKeys) {
         keyCount++;
        [finalStr appendFormat:@"%@%@",key,(keyCount==dic.count?@")":@",")];
        [tempStr appendFormat:@"'%@'%@",dic[key],(keyCount==dic.count?@")":@",")];
    }
    [finalStr appendFormat:@"values(%@",tempStr];
    BOOL result=[self.db executeUpdate:finalStr];
    return result;
}
-(NSDictionary*)wx_queryTable:(NSString*)tableName whereFormat:(NSString*)format{
    if(![self.db tableExists:tableName]){
        NSLog(@"%@表不存在，请先创建",tableName);
        return nil;
    }
    NSString *sql=[NSString stringWithFormat:@"select * FROM %@ WHERE %@",tableName,format];
    FMResultSet *rs=[self.db executeQuery:sql];
    NSMutableDictionary   *dic=[NSMutableDictionary dictionary];
    
    if([rs next]){
        for (NSString *key in rs.columnNameToIndexMap) {
          [dic setObject:[rs stringForColumn:key] forKey:key];
        }
    }
    return dic;
}
-(BOOL)wx_deleteTable:(NSString*)tableName whereFormat:(NSString*)format{
    if(![self.db tableExists:tableName]){
        NSLog(@"%@表不存在，请先创建",tableName);
        return NO;
    }
    NSString *sql=[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",tableName,format];
    BOOL result=[self.db executeUpdate:sql];
    return result;
}
-(void)open{
    [self.db open];
}
-(void)close{
    [self.db close];
}
#pragma mark------------
// 获取model的key和value
- (NSDictionary *)getModelPropertyKeyValue:(id)model
{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        id value = [model valueForKey:name];
        if (value) {
            [mDic setObject:value forKey:name];
        }
    }
    free(properties);
    
    return mDic;
}

-(NSDictionary*)modelToDictionary:(Class)wxCls{
    NSMutableDictionary *mDic=[NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t *properties=class_copyPropertyList(wxCls,&outCount);
    for (int i=0; i<outCount; i++) {
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        NSString *type = [NSString stringWithCString:property_getAttributes(properties[i]) encoding:NSUTF8StringEncoding];
        
        id value = [self propertTypeConvert:type];
        if (value) {
            [mDic setObject:value forKey:name];
        }
    }
    free(properties);
    return mDic;
}
- (NSString *)propertTypeConvert:(NSString *)typeStr
{
    NSString *resultStr = nil;
    if ([typeStr hasPrefix:@"T@\"NSString\""]) {
        resultStr = SQL_TEXT;
    } else if ([typeStr hasPrefix:@"T@\"NSData\""]) {
        resultStr = SQL_BLOB;
    } else if ([typeStr hasPrefix:@"Ti"]||[typeStr hasPrefix:@"TI"]||[typeStr hasPrefix:@"Ts"]||[typeStr hasPrefix:@"TS"]||[typeStr hasPrefix:@"T@\"NSNumber\""]||[typeStr hasPrefix:@"TB"]||[typeStr hasPrefix:@"Tq"]||[typeStr hasPrefix:@"TQ"]) {
        resultStr = SQL_INTEGER;
    } else if ([typeStr hasPrefix:@"Tf"] || [typeStr hasPrefix:@"Td"]){
        resultStr= SQL_REAL;
    }
    return resultStr;
}

@end
