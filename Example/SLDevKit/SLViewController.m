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
    
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:@"测试富文本AAABBBCCC11111111111222222222222333333333333334444444444444"];
    attri.range(1,3).color(@"#FF9900").bgColor(@"#AAAAAA").obliqueness(0.6f).expansion(0.8).baselineOffset(-5).lineSpacing(8).underline(NSUnderlineStyleDouble).strikethrough(NSUnderlineStyleDouble).match(@"[a-zA-Z]+").addMatch(@"[1-9]+").color(@"#FF0000");
    self.testFontLabel.attributedText = attri;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
