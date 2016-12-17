//
//  BFNetworkTaskQueue.m
//  BFNetwork
//
//  Created by tcguo on 2016/4/8.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "BFNetworkTaskQueue.h"
#import <libkern/OSSpinLockDeprecated.h>
@interface BFNetworkTaskQueue ()
{
    NSMutableArray *_colletion;
    dispatch_semaphore_t _semaphore_t;
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
        _semaphore_t = dispatch_semaphore_create(1);
    }
    return self;
}


- (void)addTask:(BFNetworkTask *)task {
    dispatch_semaphore_wait(_semaphore_t, DISPATCH_TIME_NOW);
    [_colletion addObject:task];
    dispatch_semaphore_signal(_semaphore_t);
}

- (void)removeTask:(BFNetworkTask *)task {
   dispatch_semaphore_wait(_semaphore_t, DISPATCH_TIME_NOW);
    if ([_colletion containsObject:task]) {
        [_colletion removeObject:task];
    }
    dispatch_semaphore_signal(_semaphore_t);
}

#pragma mark - Public
+ (void)addTask:(BFNetworkTask *)task {
    [[BFNetworkTaskQueue defaultQueue] addTask:task];
}

+ (void)removeTask:(BFNetworkTask *)task {
    [[BFNetworkTaskQueue defaultQueue] removeTask:task];
}


@end
