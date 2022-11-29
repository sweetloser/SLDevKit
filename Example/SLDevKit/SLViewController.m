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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
