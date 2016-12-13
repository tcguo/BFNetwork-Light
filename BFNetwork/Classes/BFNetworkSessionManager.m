//
//  BFNetworkSessionManager.m
//  BFNetwork
//
//  Created by tcguo on 2016/4/8.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "BFNetworkSessionManager.h"

@interface BFNetworkSessionManager ()<NSURLSessionDelegate>
{
    NSURLSession *_urlSession;
    NSOperationQueue *_privateQueue;
}

@end

@implementation BFNetworkSessionManager

- (instancetype)initPrivately {
    self = [super init];
    if (self) {
        _privateQueue = [[NSOperationQueue alloc] init];
        
    }
    return self;
}

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static BFNetworkSessionManager *instance = nil;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[BFNetworkSessionManager alloc] initPrivately];
        }
    });
    return instance;
}


+ (NSURLSession *)defalutURLSession {
    return [BFNetworkSessionManager defaultManager]->_urlSession;
}

- (void)setupURLSession {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:_privateQueue];
}

#pragma mark - NSURLSessionDelegate

// https证书检验和 match host in  white list

#ifndef DEBUG
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
    SecTrustRef serverTrust = protectionSpace.serverTrust;
    __block NSURLCredential *credential = nil;
    BOOL trust =  [[AppStatus sharedManager] matchHost:challenge.protectionSpace.host isWebView:NO];
    if (!trust) {
        if (completionHandler) {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
        return;
    }
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (BFServerTrustIsValid(serverTrust)) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        } else {
            disposition = NSURLSessionAuthChallengeRejectProtectionSpace;
        }
    } else {
        disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}


static BOOL BFServerTrustIsValid(SecTrustRef serverTrust) {
    BOOL isValid = NO;
    SecTrustResultType result;
    __Require_noErr_Quiet(SecTrustEvaluate(serverTrust, &result), _out);
    isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
    
_out:
    return isValid;
}
#endif

@end
