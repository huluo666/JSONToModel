//
//  NSDictionary+JSON.m
//  JSON_Model
//
//  Created by luo.h on 2017/12/7.
//  Copyright © 2017年 meet.com.cn. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)


- (NSString *)toJSONString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
                                                     error:nil];
    
    if (data == nil) {
        return nil;
    }
    
    NSString *string = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    return string;
}

- (NSString *)toReadableJSONString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    
    if (data == nil) {
        return nil;
    }
    
    NSString *string = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    return string;
}

- (NSData *)toJSONData {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    
    return data;
}

@end


@implementation NSString (JSON)

+ (NSString *)removeSpaceAndNewline:(NSString *)json
{
    NSString *st = [json stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    st = [st stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    st = [st stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    st = [st stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    st = [st stringByReplacingOccurrencesOfString:@" " withString:@""];
    return st;
}

+(NSString *)removeAllSpace:(NSString *)str
{
    NSArray* words = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* nospacestring = [words componentsJoinedByString:@""];
    return nospacestring;
}

- (NSString *)uppercaseFirstCharacter
{
    if (self.length > 0) {
        char c = [self characterAtIndex:0];
        if (c >= 'a' && c <= 'z') {
            return [NSString stringWithFormat:@"%c%@", toupper(c), [self substringFromIndex:1]];
        }
    }
    return self;
}



- (id)objectFromJSONString{
    NSError * error;
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!jsonObj || error) {
        NSLog(@"JSON解析失败,开始去除换行符等");
        //当解析失败去掉可能的非法字符, 为适配部分接口问题
        if ([self length])
        {
            NSString *string = [self stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@"    "];
            jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
            if (jsonData) {
                jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData
                                                          options:NSJSONReadingMutableContainers
                                                            error:nil];
            }
            if (!jsonObj) {
                NSLog(@"JSON解析仍然失败 Error: %@", error);
                return nil;
            }
        }
        return jsonObj;
    } else {
        return jsonObj;
    }
    return nil;
}
@end
