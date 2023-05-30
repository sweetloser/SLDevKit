//
//  SLAutoLayoutVC.m
//  SLDevKit_Example
//
//  Created by zengxiangxiang on 2023/1/28.
//  Copyright © 2023 sweetloser. All rights reserved.
//

#import "SLAutoLayoutVC.h"
#import <SLDevKit/SLDevKit.h>

@interface SLAutoLayoutVC ()

@end

@implementation SLAutoLayoutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.bgColor(@"#FFFFFF");
    self.title = @"自动布局";
    [self layoutToSuperView];
    
}

-(void)layoutToSuperView {
    UIView *v1 = [[UIView alloc] initWithFrame:CGRectMake(12, 100, 200, 120)];
    v1.addTo(self.view).bgColor(@"blue").border(3,@"#eeeeee");
    
    UIView *v2 = [[UIView alloc] init];
    v2.addTo(v1).bgColor(@"red").slLayout().leftSpaceToView_sl(15,v1).rightSpaceToView_sl(15, v1).topSpaceToView_sl(10, v1).bottomSpaceToView_sl(10,v1);
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
