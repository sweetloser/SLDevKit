//
//  SLViewController.m
//  SLDevKit
//
//  Created by sweetloser on 11/04/2022.
//  Copyright (c) 2022 sweetloser. All rights reserved.
//

#import "SLViewController.h"
#import <SLDevKit/SLDevKit.h>

@interface SLViewController ()
@property (weak, nonatomic) IBOutlet UILabel *testFontLabel;

@end

@implementation SLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"aaa===%@",self.testFontLabel);
    self.testFontLabel.text = @"测试";
    self.testFontLabel.font = [UIFont fontWithName:UIFontTextStyleFootnote size:16];
    
    self.testFontLabel.backgroundColor = Color(@"#A8A8A8");
    self.testFontLabel.touchInsets(5, 0, 5, 0).onClick(^(){
        NSLog(@"点击");
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
