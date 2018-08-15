//
//  ViewController.m
//  in-AppPurchase
//
//  Created by 卢腾达 on 2018/3/8.
//  Copyright © 2018年 卢腾达. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
@interface ViewController (){
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
    [button setTitle:@"点击测试" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    [button addTarget:self action:@selector(buttonEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.view.multipleTouchEnabled = TRUE;
}

- (void)buttonEvent{
    [[AppDelegate theAppDelegate] buysomething:@"com.manman.comiclover.huiyuan.iap.6yuan"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
