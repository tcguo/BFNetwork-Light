//
//  BFNetworkSessionManager.h
//  BFNetwork
//
//  Created by tcguo on 2016/4/8.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFNetworkSessionManager : NSObject

// avoid init
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

+ (NSURLSession *)defalutURLSession;

@end
