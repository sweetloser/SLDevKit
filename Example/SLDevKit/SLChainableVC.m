//
//  SLChainableVC.m
//  SLDevKit_Example
//
//  Created by zengxiangxiang on 2023/2/8.
//  Copyright © 2023 sweetloser. All rights reserved.
//

#import "SLChainableVC.h"
#import <SLDevKit/SLDevKit.h>

@interface SLChainableVC ()

@end

@implementation SLChainableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.bgColor(@"#FFF");
    UILabel *l1 = [[UILabel alloc] init].bgColor(@"0xeee").tColor(@"red").str(@"我是一个label");
    l1.frame = CGRectMake(12, 100, self.view.frame.size.width-24, 30);
    self.view.addChild(l1);
    NSLog(@"%@",[UIDevice currentDevice].model);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
