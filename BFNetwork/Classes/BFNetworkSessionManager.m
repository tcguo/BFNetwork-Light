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

@end
