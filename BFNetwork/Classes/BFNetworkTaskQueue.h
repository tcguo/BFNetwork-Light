//
//  BFNetworkTaskQueue.h
//  BFNetwork
//
//  Created by tcguo on 2016/4/8.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFNetworkTask;
@interface BFNetworkTaskQueue : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

+ (void)addTask:(BFNetworkTask *)task;
+ (void)removeTask:(BFNetworkTask *)task;

@end
