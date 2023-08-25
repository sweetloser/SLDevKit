//
//  SLCustomFieldVC.m
//  SLDevKit_Example
//
//  Created by zengxiangxiang on 2023/5/30.
//  Copyright © 2023 sweetloser. All rights reserved.
//

#import "SLCustomFieldVC.h"
#import <SLDevKit/SLCustomField.h>
#import <SLDevKit/SLDevKit.h>

@interface SLCustomFieldVC ()

@end

@implementation SLCustomFieldVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.bgColor(@"#FFF");
    SLCustomField *cf = [[SLCustomField alloc] initWithFrame:CGRectZero];
    cf.cursor_sl(YES).cursorColor_sl(@"#FF00FF").borderWidth_sl(2);
    cf.addTo(self.view).slLayout().centerXEqualToView_sl(self.view).centerYEqualToView_sl(self.view).whIs_sl(200, 50);
    cf.emptyBorderColor_sl(@"#00FF00").focusBorderColor_sl(@"#FF0000").enteredBorderColor_sl(@"#0000FF");
    cf.show_sl();
    
    SLMemoryCache *cache = [[SLMemoryCache alloc] init];
    cache.cacheObjectWithKey_sl(@"aaaa", @"11111111");
    
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
