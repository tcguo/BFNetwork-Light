//
//  BFNetworkTask.m
//  BFNetwork
//
//  Created by tcguo on 2016/12/8.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "BFNetworkTask.h"
#import "BFNetworkTaskQueue.h"
#import "BFNetworkSessionManager.h"

// 构造请求策略
static NSMutableDictionary *policyDictionary;
NSString * const BFNetworkDefaultSpellPolicyKey = @"BFNetworkDefaultPolicyKey";

// 预定义公参在url
static NSDictionary *predefinedParametersInURL;
// 预定义公参
static NSDictionary *predefinedParameters;

static NSString *defaultBaseURL = @"https://8.baidu.com";
// 备用baseurl
static NSString *defaultBaseURLBackup = @"http://119.75.222.55:80/";
static NSTimeInterval kTimeoutSeconds = 15.f;

@interface BFNetworkTask () {
    NSURLSessionTask *_currentTask;
    NSString *_policyKey;
}

@end

@implementation BFNetworkTask

+ (void)load {
    policyDictionary = [[NSMutableDictionary alloc] init];
    BFNetworkSpellPolicy defaultPolicy = ^(NSString *urlString, NSString *queryName, NSString *HTTPMethod, NSDictionary *parameters, NSArray *cookies, NSDictionary *headers) {
        
        NSMutableString *url = [[NSMutableString alloc] initWithString:urlString];
        [url appendString:queryName];
        
        // check that url whether contains query string or not
        BOOL hasQueryString = ([NSURL URLWithString:url].query.length > 0);
        if (predefinedParametersInURL.count > 0) {
            NSString *format = hasQueryString ? @"&%@" : @"?%@";
            [url appendFormat:format, BFNetworkConvertParametersToQueryString(predefinedParametersInURL)];
            hasQueryString = YES;
        }
        
        NSMutableDictionary *mergedParameters = [NSMutableDictionary dictionaryWithDictionary:predefinedParameters];
        [mergedParameters addEntriesFromDictionary:parameters];
        NSString *queryString = BFNetworkConvertParametersToQueryString(mergedParameters);
        
        
        NSMutableURLRequest *request = nil;
        if ([HTTPMethod isEqualToString:@"GET"]) {
            if (queryString.length > 0) {
                NSString *format = hasQueryString ? @"&%@" : @"?%@";
                [url appendFormat:format, queryString];
            }
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                          timeoutInterval:kTimeoutSeconds];
            request.HTTPMethod = @"GET";
        } else if ([HTTPMethod isEqualToString:@"POST"]) {
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                          timeoutInterval:kTimeoutSeconds];
            request.HTTPMethod = @"POST";
            if (queryString.length > 0)
                request.HTTPBody = [queryString dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            @throw [NSException exceptionWithName:@"Unsupported HTTP Method" reason:nil userInfo:nil];
        }

        if (request) {
            [request setHTTPShouldHandleCookies:YES];
            if (cookies && cookies.count != 0) {
                NSDictionary *dictCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
                [request setValue:[dictCookies objectForKey:@"Cookie"] forHTTPHeaderField: @"Cookie"];
            }
            
            if (headers && headers.count > 0) {
                [request setAllHTTPHeaderFields:headers];
            }
        }
        
        return request;;
    };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _urlString = defaultBaseURL;
        _policyKey = BFNetworkDefaultSpellPolicyKey;
    }
    return self;
}

- (void)dealloc {
    [_currentTask removeObserver:self forKeyPath:@"countOfBytesSent"];
    [_currentTask removeObserver:self forKeyPath:@"countOfBytesReceived"];
    NSLog(@"life end");
}

#pragma mark - public
- (void)resume {
    if (!_currentTask) {
        _currentTask = [self task];
//        [BFNetworkTaskCollection addTask:self];
    };
    [_currentTask resume];
}

- (void)suspend {
    [_currentTask suspend];
}

- (void)cancel {
    [_currentTask cancel];
}

#pragma mark - private
- (NSURLSessionTask *)task {
    BFNetworkSpellPolicy policy = policyDictionary[_policyKey];
    
    NSURLSessionTask *task = [[BFNetworkSessionManager defalutURLSession] dataTaskWithRequest:policy(self.urlString, self.queryName, self.HTTPMethod, self.paramsDictionary, self.cookies, self.headers)
                                                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                                // 如果DNS解析失败 更换IP
                                                                                if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == -1003)         {
                                                                                    defaultBaseURL = defaultBaseURLBackup;
                                                                                };
                                                                                [BFNetworkTaskQueue removeTask:self];
                                                                                self.completion(data,response,error);
                                                                            }];
    
    [task addObserver:self forKeyPath:@"countOfBytesReceived" options:NSKeyValueObservingOptionNew context:NULL];
    [task addObserver:self forKeyPath:@"countOfBytesSent" options:NSKeyValueObservingOptionNew context:NULL];
    return task;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (self.progressBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //CGFloat uploadProgress = _currentTask.countOfBytesSent / _currentTask.countOfBytesExpectedToSend;
            //CGFloat downloadProgress = _currentTask.countOfBytesReceived / _currentTask.countOfBytesExpectedToReceive;
            self.progressBlock(_currentTask.response.expectedContentLength,_currentTask.countOfBytesReceived);
        });
    }
}




@end


@implementation BFNetworkTask (RequestPolicy)

+ (void)addPolicy:(BFNetworkSpellPolicy)policy forKey:(id<NSCopying>)key {
    [policyDictionary setObject:policy forKey:key];
}

+ (void)setDefaultPredefineParameters:(NSDictionary *)parameters {
    predefinedParameters = parameters;
}

+ (void)setDefaultPredefineInURLParameters:(NSDictionary *)parameters {
    predefinedParametersInURL = parameters;
}

+ (void)setDefaultBaseURL:(NSString *)baseURL backupVIPURL:(NSString *)backupURL {
    defaultBaseURL = baseURL;
    defaultBaseURLBackup = backupURL;
}


NSString * BFNetworkEncodingString(NSString *encodingString, NSStringEncoding encoding) {
    
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef)encodingString,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]%",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding));
    
}


NSString * BFNetworkConvertParametersToQueryString(NSDictionary *parameters) {
    NSMutableString *buffer = [NSMutableString string];
    
    for (NSString *key in parameters) {
        NSString *value = [NSString stringWithFormat:@"%@", parameters[key]];
        
        NSString *encodedKey =  BFNetworkEncodingString(key, NSUTF8StringEncoding);
        NSString *encodedValue = BFNetworkEncodingString(value, NSUTF8StringEncoding);
        
        if (buffer.length > 0)
            [buffer appendString:@"&"];
        
        [buffer appendFormat:@"%@=%@", encodedKey, encodedValue];
    }
    return buffer;
}

NSDictionary * OBNetworkDefaultPublicParameters(){
    NSString *logid = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    NSString *os_ver = [[UIDevice currentDevice] systemVersion];
    StringNilToDefault(os_ver, @"");
    NSString *device = [UIDevice currentDevice].model;
    StringNilToDefault(device, @"");
    
    return NSDictionaryOfVariableBindings(logid, os_ver, device);
}

@end
