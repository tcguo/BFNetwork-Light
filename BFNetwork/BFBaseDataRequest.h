//
//  BFBaseDataRequet.h
//  BFNetwork
//
//  Created by tcguo on 2016/4/10.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kResponseRetKey;
extern NSString * const kResponseRetMsgKey;

@class BFBaseDataRequest;
typedef void(^BFRequestCompletionBlock)(__kindof BFBaseDataRequest *request);

typedef enum BaiduFinanceRequestMethod {
    BaiduFinanceRequestMethodPost = 0,
    BaiduFinanceRequestMethodGet,
}BaiduFinanceRequestMethod;

typedef NS_ENUM(NSInteger, BaiduFinanceRequestStatus) {
    BaiduFinanceRequestStatusSuccess = 0,
    BaiduFinanceRequestStatusNoNetwork = 900000,      // 无网络
    BaiduFinanceRequestStatusRequestError = 900001,   // 请求失败
    BaiduFinanceRequestStatusParseJsonError,          // json解析失败
    BaiduFinanceRequestStatusResultError,             // 结果错误
};

@interface BFBaseDataRequest : NSObject

@property (nonatomic, copy, readonly) NSString *apiHostHttp;
@property (nonatomic, copy, readonly) NSString *apiHostHttps;

// 请求必设参数
// 默认GET
@property (nonatomic, assign) BaiduFinanceRequestMethod requestMethod;
@property (nonatomic, copy) NSString *queryName;
@property (nonatomic, strong) NSDictionary *requestParams;
// 默认为nil, 不设则默认使用配置基地址
@property (nonatomic, copy) NSString *urlString;

// 返回参数
@property (nonatomic, assign, readonly) BaiduFinanceRequestStatus requestStatus;
@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, copy, readonly) NSString *errCode;
@property (nonatomic, copy, readonly) NSString *errMsg;
@property (nonatomic, strong, readonly) NSDictionary *resultDictionary;

@property (nonatomic, copy) BFRequestCompletionBlock successCompletionBlock;
@property (nonatomic, copy) BFRequestCompletionBlock failureCompletionBlock;

- (void)start;
- (void)cancel;
- (void)suspend;
- (void)startWithSuccess:(BFRequestCompletionBlock)success
                 failure:(BFRequestCompletionBlock)failure;

@end
