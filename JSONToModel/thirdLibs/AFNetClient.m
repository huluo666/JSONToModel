
//
//  AFNetClient.m
//  MLSocketioChat
//
//  Created by luo.h on 2017/10/13.
//  Copyright © 2017年 apple.com..cn. All rights reserved.
//

#import "AFNetClient.h"

static NSTimeInterval   KAFRequestTimeout = 20.f;
@implementation AFNetClient

#pragma mark - manager
+ (AFHTTPSessionManager *)defaultManager {
    //1.初始化
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //2.1设置网络请求超时时间
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = KAFRequestTimeout;
    
    //3.1配置请求序列化
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    [serializer setRemovesKeysWithNullValues:YES];
    manager.responseSerializer = serializer;

    NSMutableSet *ContentTypes = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [ContentTypes addObjectsFromArray:@[@"text/html"]];
    //3.2设置格式 (默认二进制, 这里不用改也OK)-配置响应序列化
    manager.responseSerializer.acceptableContentTypes=ContentTypes;
   
    return manager;
}




/**
 @       get  请求
 @param  path  无参数
 */
+ (NSURLSessionTask *)GET_Path:(NSString *)path completed:(MTSuccessBlock )successBlock failed:(MTFailedBlock )faileBlock
{
   return  [self GET_Path:path params:nil headers:nil completed:successBlock failed:faileBlock];
}

/**
 @       get  请求
 @param  path  有参数
 */
//https://stackoverflow.com/questions/19114623/request-failed-unacceptable-content-type-text-html-using-afnetworking-2-0
+(NSURLSessionTask *)GET_Path:(NSString *)path  params:(NSDictionary *)params  completed:(MTSuccessBlock )successBlock failed:(MTFailedBlock )faileBlock
{
  return  [self GET_Path:path params:params headers:nil completed:successBlock failed:faileBlock];
}


+(NSURLSessionTask *)GET_Path:(NSString *)path
         params:(NSDictionary *)params
        headers:(NSDictionary *)headers
      completed:(MTSuccessBlock )successBlock failed:(MTFailedBlock )faileBlock
{
    // 1.初始化
    AFHTTPSessionManager *manager =  [self defaultManager];
    
    // 2.设置请求头
    if (headers&&headers.count>0) {
        for (NSString *key in [headers allKeys]) {
            [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    NSLog(@"GET请求信息(%@=%@=%@)",path,params,headers);
   NSURLSessionDataTask *sessionTask = [manager GET:path parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock){
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
            }else{
                responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];//把NSData转换成字典类型
            }
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            successBlock(response,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (faileBlock){
            faileBlock(error);
        }
    }];
    return sessionTask;
}



/**
 @  POST  请求 无参数
 */
+ (void)POST_Path:(NSString *)path completed:(MTSuccessBlock )successBlock failed:(MTFailedBlock )faileBlock
{
    [self POST_Path:path params:nil headers:nil completed:successBlock failed:faileBlock];
}


/**
 @  POST  请求  有参数
 */
+ (void)POST_Path:(NSString *)path params:(NSDictionary *)paramsDic completed:(MTSuccessBlock )successBlock failed:(MTFailedBlock )faileBlock
{
    [self POST_Path:path params:paramsDic headers:nil completed:successBlock failed:faileBlock];
}


+(void)POST_Path:(NSString *)path
         params:(NSDictionary *)params
        headers:(NSDictionary *)headers
      completed:(MTSuccessBlock )successBlock failed:(MTFailedBlock )faileBlock
{
    // 1.获取默认manager
    AFHTTPSessionManager *manager = [self defaultManager];
    
    //若有汉语进行UTF8转码(这个方法是iOS9之后的方法)
    //path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // 2.设置请求头
    if (headers&&headers.count>0) {
        for (NSString *key in [headers allKeys]) {
            [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    NSLog(@"POST请求信息(Path=%@ params=%@ headers=%@)",path,params,headers);
    [manager POST:path parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock){
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
            }else{
                responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];//把NSData转换成字典类型
            }
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            successBlock(response,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (faileBlock){
            faileBlock(error);
        }
    }];
}



+(void)Request_Path:(NSString *)path
            method:(NSString *)method
             params:(NSDictionary *)params
            headers:(NSDictionary *)headers
          completed:(MTSuccessBlock )successBlock failed:(MTFailedBlock )faileBlock
{
//    need add
}



#pragma mark---
#pragma mark - 检查网络
+ (void)checkNetworkStatus {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                break;
            case AFNetworkReachabilityStatusUnknown:
              break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
              break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
              break;
            default:
                break;
        }
        
    }];
}


/*实时获取网络状态，此方法可多次调用*/
+ (void)networkStatusWithBlock:(AFNetworkStatusBlock)networkStatus{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            networkStatus ? networkStatus(status) : nil;
        }];
    });
}

+ (BOOL)isNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (BOOL)isWiFiNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

+ (BOOL)isWWANNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}


@end


#pragma mark -- NSDictionary,NSArray的分类------
/*
***************************************************************************
*   新建NSDictionary与NSArray的分类, 控制台打印json数据中的中文                 *
***************************************************************************
*/
@implementation NSArray (AFNET)

- (NSString *)descriptionWithLocale:(id)locale{
    
    NSMutableString *strM = [NSMutableString stringWithString:@"(\n"];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strM appendFormat:@"\t%@,\n",obj];
    }];
    [strM appendString:@")\n"];
    return  strM;
}
@end

@implementation NSDictionary (AFNET)

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSMutableString *desc = [NSMutableString string];
    NSMutableString *tabString = [[NSMutableString alloc] initWithCapacity:level];
    for (NSUInteger i = 0; i < level; ++i) {
        [tabString appendString:@"\t"];
    }
    
    NSString *tab = @"";
    if (level > 0) {
        tab = tabString;
    }
    
    [desc appendString:@"\t{\n"];
    
    // Through array, self is array
    for (id key in self.allKeys) {
        id obj = [self objectForKey:key];
        
        if ([obj isKindOfClass:[NSString class]]) {
            [desc appendFormat:@"%@\t%@ = \"%@\",\n", tab, key, obj];
        } else if ([obj isKindOfClass:[NSArray class]]
                   || [obj isKindOfClass:[NSDictionary class]]
                   || [obj isKindOfClass:[NSSet class]]) {
            [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, [obj descriptionWithLocale:locale indent:level + 1]];
        } else if ([obj isKindOfClass:[NSData class]]) {
            
            NSError *error = nil;
            NSObject *result =  [NSJSONSerialization JSONObjectWithData:obj
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
            
            if (error == nil && result != nil) {
                if ([result isKindOfClass:[NSDictionary class]]
                    || [result isKindOfClass:[NSArray class]]
                    || [result isKindOfClass:[NSSet class]]) {
                    NSString *str = [((NSDictionary *)result) descriptionWithLocale:locale indent:level + 1];
                    [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, str];
                } else if ([obj isKindOfClass:[NSString class]]) {
                    [desc appendFormat:@"%@\t%@ = \"%@\",\n", tab, key, result];
                }
            } else {
                @try {
                    NSString *str = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                    if (str != nil) {
                        [desc appendFormat:@"%@\t%@ = \"%@\",\n", tab, key, str];
                    } else {
                        [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, obj];
                    }
                }
                @catch (NSException *exception) {
                    [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, obj];
                }
            }
        } else {
            [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, obj];
        }
    }
    
    [desc appendFormat:@"%@}", tab];
    
    return desc;
}

@end





//acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];

