//
//  BFBaseDataRequet.m
//  BFNetwork
//
//  Created by tcguo on 2016/12/13.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "BFBaseDataRequest.h"
#import "BFNetwork.h"

NSString * const kResponseRetKey = @"ret";
NSString * const kResponseRetMsgKey = @"ret_msg";

@interface BFBaseDataRequest ()

@property (nonatomic, assign, readwrite) BaiduFinanceRequestStatus requestStatus;

@property (nonatomic, copy, readwrite) NSString *apiHostHttp;
@property (nonatomic, copy, readwrite) NSString *apiHostHttps;

@property (nonatomic, copy, readwrite) NSString *errCode;
@property (nonatomic, copy, readwrite) NSString *errMsg;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, strong, readwrite) NSDictionary *resultDictionary;
@property (nonatomic, assign) BOOL isHttps;

@property (nonatomic, weak) BFNetworkTask *task;

@end

@implementation BFBaseDataRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestMethod = BaiduFinanceRequestMethodGet;
        
        /*
        EnvironmentItem *item = [AppStatus sharedManager].environmentItem;
        switch (item.type) {
            case kEnvironmentTypeOL:
            case kEnvironmentTypePRE:
                _isHttps = YES;
                break;
            case kEnvironmentTypeRD:
            case kEnvironmentTypeQA:
                _isHttps = NO;
                break;
            default:
                break;
        }
        */
        
        _urlString = nil;
    }
    
    return self;
}


#pragma mark - Public
- (void)start {
    
    if (!self.isHttps) {
        [BFNetworkTask setDefaultBaseURL:self.apiHostHttp backupVIPURL:self.apiHostHttp];
    } else {
        [BFNetworkTask setDefaultBaseURL:self.apiHostHttps backupVIPURL:self.apiHostHttps];
    }
    
    BFNetworkTask *task = [[BFNetworkTask alloc] init];
    self.task = task;
    
    BaiduFinanceRequestMethod requestMethod = self.requestMethod;
    NSString *httpMethod = @"GET";
    if (requestMethod == BaiduFinanceRequestMethodPost) {
        httpMethod = @"POST";
    }
    self.task.HTTPMethod = httpMethod;
    if (self.urlString) {
        self.task.urlString = self.urlString;
    }
    self.task.queryName = self.queryName;
    
    NSMutableDictionary *commonParams = [NSMutableDictionary dictionaryWithDictionary:self.requestParams];
    [commonParams setValue:@"3.0.2" forKey:@"from"];
    [commonParams setValue:@"ios" forKey:@"device"];
    self.task.paramsDictionary = commonParams;
    
    __weak typeof(self) weakself = self;
    self.task.completion = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error && error.code == -999) {
            return;
        }
        if (weakself == nil) {
            return;
        }
        
        NSString *domain = @"bdlicai";
        if (error) {
            weakself.errCode = [NSString stringWithFormat:@"%ld", BaiduFinanceRequestStatusRequestError];
            weakself.errMsg = @"network error";
            NSDictionary *userInfo = @{ kResponseRetMsgKey: weakself.errMsg,
                                        kResponseRetKey: weakself.errCode };
            weakself.error = [NSError errorWithDomain:domain code:BaiduFinanceRequestStatusRequestError userInfo:userInfo];
            weakself.requestStatus = BaiduFinanceRequestStatusRequestError;
            
            weakself.failureCompletionBlock(weakself);
            return;
        }
        
        // JSONSerialization
        NSError *jsonErr = nil;
        NSDictionary *jsonResut = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonErr];
        if (jsonErr) {
            weakself.errCode = [NSString stringWithFormat:@"%ld", BaiduFinanceRequestStatusParseJsonError];
            weakself.errMsg = @"data error";
            NSDictionary *userInfo = @{ kResponseRetMsgKey: weakself.errMsg,
                                        kResponseRetKey: weakself.errCode };
            
            weakself.error = [NSError errorWithDomain:domain code:BaiduFinanceRequestStatusParseJsonError userInfo:userInfo];
            weakself.requestStatus = BaiduFinanceRequestStatusParseJsonError;
            weakself.failureCompletionBlock(weakself);
            return;
        }
        weakself.errMsg = [jsonResut valueForKey:kResponseRetMsgKey];
        if ([[jsonResut valueForKey:kResponseRetKey] isKindOfClass:[NSNumber class]]) {
            weakself.errCode = [[jsonResut valueForKey:kResponseRetKey] stringValue];
        } else {
            weakself.errCode = [NSString stringWithFormat:@"%@", [jsonResut valueForKey:kResponseRetKey]];
        }
        
        weakself.resultDictionary = jsonResut;
    };
    
    [self.task resume];
}

- (void)suspend {
    if (self.task) {
        [self.task suspend];
    }
}

- (void)cancel {
    if (self.task) {
        [self.task cancel];
    }
}

- (void)startWithSuccess:(BFRequestCompletionBlock)success
                 failure:(BFRequestCompletionBlock)failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    [self start];
}


#pragma mark - Property
- (NSString *)apiHostHttp {
//    EnvironmentItem *itme = [AppStatus sharedManager].environmentItem;
    return [NSString stringWithFormat:@"http://%@", @"8.baidu.com"];
}

- (NSString *)apiHostHttps {
//    EnvironmentItem *itme = [AppStatus sharedManager].environmentItem;
    return [NSString stringWithFormat:@"https://%@", @"8.baidu.com"];
}

#pragma mark - Private
- (void)resetResult {
    self.errCode = nil;
    self.errMsg = nil;
    self.error = nil;
    self.resultDictionary = nil;
}

#pragma mark - Override
- (NSString *)description {
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"reqest:\nurl=%@\nqueryName=%@\nrequestParams=%@\n", self.task.urlString, self.task.queryName, self.task.paramsDictionary];
    [desc appendFormat:@"respone:\nrequestStatus=%ld\nerror=%@\nresultDictionary=%@", self.requestStatus, self.error, self.resultDictionary];
    return desc;
}

@end
