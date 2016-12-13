//
//  BFHomeProvider.m
//  BFNetwork
//
//  Created by tcguo on 2016/12/13.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "BFHomeProvider.h"
#import "BFBaseDataRequest.h"

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
