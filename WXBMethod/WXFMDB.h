//
//  WXFMDB.h
//  WXRequestWay
//
//  Created by mamie on 17/5/10.
//  Copyright © 2017年 mamie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXFMDB : NSObject
+(instancetype)shareDatabase;

/**
 创建表

 @param tableName 表名
 @param keys 设置表的字段 可以传model(runtime自动生成字段)或字典(格式:@{@"name":@"TEXT"})
 @param pKey  主键字段
 @return 是否创建成功
 */
-(BOOL)wx_creactTable:(NSString*)tableName withKeys:(id)keys withPrimaryKey:(NSString*)pKey;


/**
 插入数据

 @param tableName 表名
 @param values 要插入的数据,可以是model或dictionary(格式:@{@"name":@"小李"})
 @return 是否插入成功
 */
-(BOOL)wx_insertTable:(NSString*)tableName withValues:(id)values;

/**
 查询数据

 @param tableName 表名
 @param format 条件语句 如:@"where name = '小李'"
 @return 查询的数据
 */
-(NSDictionary*)wx_queryTable:(NSString*)tableName whereFormat:(NSString*)format;
/**
 根据条件删除表中数据

 @param tableName 表名
 @param format 条件语句, 如:@"where name = '小李'"
 */
-(BOOL)wx_deleteTable:(NSString*)tableName whereFormat:(NSString*)format;

-(void)open;
-(void)close;
@end
