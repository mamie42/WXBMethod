//
//  UIView+WXAlterView.h
//  WXBMethodDemo
//
//  Created by mamie on 17/5/17.
//  Copyright © 2017年 mamie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@interface WXAlterView: UIView
+(void)showAlterWithTitle:(NSString *)title message:(NSString *)message action:(void(^)(void))action;
+(void)showAlterWithTitle:(NSString *)title message:(NSString *)message  buttonTitles:(NSArray <NSString *>*)buttonTitles actionWithIndex:(void(^)(NSInteger index))action;

+(void)showAlterFieldWith:(NSString*)title placeholder:(NSString*)placeholder action:(void(^)(NSString*string))action;
+(void)hideAlterField;

@end
