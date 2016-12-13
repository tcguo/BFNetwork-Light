//
//  ViewController.m
//  BFNetwork
//
//  Created by tcguo on 2016/12/8.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "ViewController.h"
#import "BFHomeProvider.h"

@interface ViewController ()

@property (nonatomic, strong) BFHomeProvider *homeProvider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)loadData {
    if (_homeProvider) {
        _homeProvider = [[BFHomeProvider alloc] init];
    }
    
    [self.homeProvider requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
