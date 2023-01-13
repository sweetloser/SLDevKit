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
    self.testFontLabel.font = [UIFont fontWithName:UIFontTextStyleFootnote size:16];
    
    self.testFontLabel.fnt(@16).str(@"%d+%d=%d",1,1,1+1).bgColor(@"0xA0A0A0").touchInsets(5, 0, 5, 0).onClick(^(){
        NSLog(@"点击");
    });
    
//    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:@"测试富文本AAABBBCCC11111111111222222222222333333333333334444444444444"];
//    attri.range(1,3).color(@"#FF9900").bgColor(@"#AAAAAA").obliqueness(0.6f).expansion(0.8).baselineOffset(-5).lineSpacing(8).underline(NSUnderlineStyleDouble).strikethrough(NSUnderlineStyleDouble).match(@"[a-zA-Z]+").addMatch(@"[1-9]+").color(@"#FF0000");
//    self.testFontLabel.attributedText = attri;
    
    NSArray *array = @[@"aaa",@"bbb",@"ccc"];
//
//    array.forEach(^(NSString *str){
//        NSLog(@"+++%@++++",str);
//    });
    array.forEach(^(NSString *str) {
        NSLog(@"%@====",str);
        
    });
    NSString *s = array.reduce(@"开始：",^(NSString *accumulator,NSString *str) {
        return [NSString stringWithFormat:@"%@%@",accumulator,str];
    });
    NSLog(@"%@",s);
    
    Class _selfClass = [self class];
    Method aM = class_getInstanceMethod(_selfClass, @selector(funcA));
    Method bM = class_getInstanceMethod(_selfClass, @selector(funcB));
    
    IMP aI = method_getImplementation(aM);
    IMP bI = method_getImplementation(bM);
    
    const char *tE = method_getTypeEncoding(bM);
    
    class_replaceMethod(_selfClass, @selector(funcA), bI, tE);
    
    [self funcA];
    [self funcB];
    
}

-(void)funcA {
    NSLog(@"%s",__func__);
}
-(void)funcB {
    NSLog(@"%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
