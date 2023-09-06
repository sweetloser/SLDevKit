//
//  SLCacheVC.m
//  SLDevKit_Example
//
//  Created by zengxiangxiang on 2023/9/6.
//  Copyright © 2023 sweetloser. All rights reserved.
//

#import "SLCacheVC.h"
#import <SLDevKit/SLDevKit.h>
#import <YYCache/YYCache.h>

@interface SLCacheVC ()

@end

@implementation SLCacheVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.bgColor(@"#FFFFFF");
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    SLCache *cache = [[SLCache alloc] initWithPath:[path stringByAppendingPathComponent:@"slcache"]];
    for (int i=0; i<100; i++) {
        NSString *key = [NSString stringWithFormat:@"key%d", i];
        NSString *value = [NSString stringWithFormat:@"我的第%d个值！！！",i];
        cache.cacheObjectWithKey_sl(value, key);
    }
    
    YYCache *yyCache = [[YYCache alloc] initWithPath:[path stringByAppendingPathComponent:@"yycache"]];
    for (int i=0; i<100; i++) {
        NSString *key = [NSString stringWithFormat:@"key%d", i];
        NSString *value = [NSString stringWithFormat:@"我的第%d个值！！！",i];
        [yyCache setObject:value forKey:key];
    }
    NSLog(@"缓存结束");
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
