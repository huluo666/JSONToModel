//
//  NSDictionary+JSON.h
//  JSON_Model
//
//  Created by luo.h on 2017/12/7.
//  Copyright © 2017年 meet.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)


/**
 *  转换成JSON串字符串（没有可读性）
 *
 *  @return JSON字符串
 */
- (NSString *)toJSONString;

/**
 *  转换成JSON串字符串（有可读性）
 *
 *  @return JSON字符串
 */
- (NSString *)toReadableJSONString;

/**
 *  转换成JSON数据
 *
 *  @return JSON数据
 */
- (NSData *)toJSONData;

@end

@interface NSString (JSON)

+ (NSString *)removeSpaceAndNewline:(NSString *)str;
+(NSString *)removeAllSpace:(NSString *)str;
- (NSString *)uppercaseFirstCharacter;

-(id)objectFromJSONString;//JSONString to NSDictionary

@end

