//
//  AFNetClient.h
//  MLSocketioChat
//
//  Created by luo.h on 2017/10/13.
//  Copyright © 2017年 apple.com..cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void (^MTSuccessBlock)(NSHTTPURLResponse *response,id JSONDict);
typedef void (^MTFailedBlock)(NSError *error);

@interface AFNetClient : NSObject

+ (AFHTTPSessionManager *)defaultManager;

+ (void)uploadImage;


/**
 @       get  请求
 @param  path  无参数
 */
+ (NSURLSessionTask *)GET_Path:(NSString *)path completed:(MTSuccessBlock )successBlock failed:(MTFailedBlock )faileBlock;

+(NSURLSessionTask *)GET_Path:(NSString *)path
         params:(NSDictionary *)params
        headers:(NSDictionary *)headers
      completed:(MTSuccessBlock )successBlock failed:(MTFailedBlock )faileBlock;
/**
 @       get  请求
 @param  path  有参数
 */
+(NSURLSessionTask *)GET_Path:(NSString *)path  params:(NSDictionary *)params  completed:(MTSuccessBlock )successBlock failed:(MTFailedBlock )faileBlock;

/**
 @  POST  请求 无参数
 */
+ (void)POST_Path:(NSString *)path completed:(MTSuccessBlock )successBlock failed:(MTFailedBlock )faileBlock;


/**
 @  POST  请求  有参数
 */
+ (void)POST_Path:(NSString *)path params:(NSDictionary *)paramsDic completed:(MTSuccessBlock )successBlock failed:(MTFailedBlock )faileBlock;


+(void)POST_Path:(NSString *)path
          params:(NSDictionary *)params
         headers:(NSDictionary *)headers
       completed:(MTSuccessBlock )successBlock failed:(MTFailedBlock )faileBlock;




#pragma mark=================监测网络状态================
/**网络状态Block*/
typedef void(^AFNetworkStatusBlock)(AFNetworkReachabilityStatus status);

/*实时获取网络状态，此方法可多次调用*/
+ (void)networkStatusWithBlock:(AFNetworkStatusBlock)networkStatus;

/*判断是否有网*/
+ (BOOL)isNetwork;

/*是否是手机网络*/
+ (BOOL)isWWANNetwork;

/*是否是WiFi网络*/
+ (BOOL)isWiFiNetwork;


@end
