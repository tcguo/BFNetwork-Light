# BFNetwork-Light
a light network library based on NSNSURLSession
it contains only three classes:

**BFNetworkTask**

**BFNetworkTaskQueue**

**BFNetworkSessionManager**

# BFBaseDataRequest
a customized base class set default values and common params, define the return values.

```objc
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

```


# Data provider
the data provider manage allrequestes life. Any request is a BFBaseDataRequest. A view controller with a data provider.

```objc
@interface BFHomeProvider : NSObject

- (void)requestData;

- (void)requestMoreData;
@end


@interface BFHomeProvider ()

@property (nonatomic, strong) BFBaseDataRequest *homeDataRequest;

@end

@implementation BFHomeProvider

/**
 demo method
 */
- (void)requestData {
    if (self.homeDataRequest) {
        [self.homeDataRequest cancel];
    }
    
    self.homeDataRequest.queryName = @"/app/home";
    self.homeDataRequest.requestParams = @{ @"type": @(1) };
    
    [self.homeDataRequest startWithSuccess:^(__kindof BFBaseDataRequest *request) {
        
    } failure:^(__kindof BFBaseDataRequest *request) {
        
    }];
}

- (void)requestMoreData {
    
}

- (BFBaseDataRequest *)homeDataRequest {
    if (!_homeDataRequest) {
        _homeDataRequest = [[BFBaseDataRequest alloc] init];
    }
    return _homeDataRequest;
}

@end
```


