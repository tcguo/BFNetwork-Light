//
//  BFNetworkTaskQueue.m
//  BFNetwork
//
//  Created by tcguo on 2016/4/8.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "BFNetworkTaskQueue.h"
#import <os/lock.h>

@interface BFNetworkTaskQueue ()
{
    NSMutableArray *_colletion;
    os_unfair_lock_t _unfairLock;
}

@end

@implementation BFNetworkTaskQueue

+ (instancetype)defaultQueue {
    static dispatch_once_t onceToken;
    static BFNetworkTaskQueue *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BFNetworkTaskQueue alloc] initPrivately];
    });
    return instance;
}

- (instancetype)initPrivately {
    self = [super init];
    if (self) {
        _colletion = [[NSMutableArray alloc] init];
        _unfairLock = &(OS_UNFAIR_LOCK_INIT);
    }
    return self;
}


- (void)addTask:(BFNetworkTask *)task {
    os_unfair_lock_lock(_unfairLock);
    [_colletion addObject:task];
    os_unfair_lock_unlock(_unfairLock);
}

- (void)removeTask:(BFNetworkTask *)task {
    os_unfair_lock_lock(_unfairLock);
    if ([_colletion containsObject:task]) {
        [_colletion removeObject:task];
    }
    os_unfair_lock_lock(_unfairLock);
}

#pragma mark - Public
+ (void)addTask:(BFNetworkTask *)task {
    [[BFNetworkTaskQueue defaultQueue] addTask:task];
}

+ (void)removeTask:(BFNetworkTask *)task {
    [[BFNetworkTaskQueue defaultQueue] removeTask:task];
}


@end
