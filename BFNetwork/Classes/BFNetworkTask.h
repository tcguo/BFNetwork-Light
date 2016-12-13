//
//  BFNetworkTask.h
//  BFNetwork
//
//  Created by tcguo on 2016/4/8.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define StringNilToDefault(str, defaultStr) if(!str){str=defaultStr;}

extern  NSString * _Nonnull  const BFNetworkDefaultSpellPolicyKey;

NS_ASSUME_NONNULL_BEGIN

typedef  NSURLRequest * _Nonnull (^BFNetworkSpellPolicy)(NSString *urlString, NSString *queryName, NSString *HTTPMethod, NSDictionary *parameters, NSArray *cookies, NSDictionary *headers);

@interface BFNetworkTask : NSObject

/**
 GET or POST
 */
@property (nonatomic, copy, nonnull) NSString *HTTPMethod;
@property (nonatomic, strong, nullable) NSDictionary *paramsDictionary;

/**
 interface name
 */
@property (nonatomic, strong, nullable) NSString *queryName;

/**
 base url
 */
@property (nonatomic, strong, nullable) NSString *urlString;
@property (nonatomic, strong, nullable) NSArray<NSHTTPCookie *> *cookies;
@property (nonatomic, strong, nullable) NSDictionary<NSString*, NSString*> *headers;

@property(nonatomic, copy, nullable) void (^progressBlock)(CGFloat uploadProgress,CGFloat downloadProgress);
@property (nonatomic, copy, nonnull) void (^completion)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);


- (void)suspend;
- (void)resume;
- (void)cancel;

@end


@interface BFNetworkTask (RequestPolicy)

/**
 *  添加URLRequest配置策略
 *
 *  @param policy 配置策略block
 *  @param key    键值
 */
+ (void)addPolicy:(BFNetworkSpellPolicy)policy forKey:(id<NSCopying>)key;
/**
 *  配置默认预定义参数
 *
 *  @param parameters 参数字典
 */
+ (void)setDefaultPredefineParameters:(NSDictionary *)parameters;
/**
 *  配置默认URL中的预定义参数
 *
 *  @param parameters 参数字典
 */
+ (void)setDefaultPredefineInURLParameters:(NSDictionary *)parameters;
/**
 *  配置默认baseURL 如果发请求的urlString为空 则使用baseURL
 *
 *  @param baseURL   baseURL
 *  @param backupURL 域名解析失败时用的vip地址
 */
+ (void)setDefaultBaseURL:(NSString *)baseURL backupVIPURL:(NSString *)backupURL;
/**
 *  C-Style URLEncoding
 *
 *  @param encodingString 要编码的字符串
 *  @param encoding       编码格式
 *
 *  @return 编码后的字符串
 */
extern NSString * BFNetworkEncodingString(NSString *encodingString, NSStringEncoding encoding);
/**
 *  转换字典为query格式string 比如 {key1:value1,key2:value2} -> key1=value1&key2=value2
 *
 *  @param parameters 参数字典
 *
 *  @return query字符串
 */
extern NSString * BFNetworkConvertParametersToQueryString(NSDictionary *parameters);
/**
 *  内置的基础公共参数方法
 *
 *  @return 公共参数字典
 */
extern NSDictionary * BFNetworkDefaultPublicParameters();

@end

NS_ASSUME_NONNULL_END
