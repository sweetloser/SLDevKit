//
//  SLViewController.m
//  SLDevKit
//
//  Created by sweetloser on 11/04/2022.
//  Copyright (c) 2022 sweetloser. All rights reserved.
//

#import "SLViewController.h"
#import <SLDevKit/SLDevKit.h>
#import "SLTestItemCell.h"
#import "SLAutoLayoutVC.h"
#import "SLChainableVC.h"
#import "SLCustomFieldVC.h"
#import "SLCacheVC.h"
#import <Aspects.h>

@interface SLViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"SLTestItemCell" bundle:nil] forCellReuseIdentifier:@"testItemCell"];
    
    id<SLHookUnit> hookUnit = [self.superclass sl_hookSelector:@selector(viewWillAppear:) withHookOptions:SLHookPositionOptionBefore | SLHookOptionRemoveAfterCalled replaceBlock:^(id<SLHookInfo>info, BOOL b) {
        NSLog(@"你相信水吗？");
    } error:nil];
    NSError *error;
    id<SLHookUnit> hookUnit1 = [self.class sl_hookSelector:@selector(viewWillAppear:) withHookOptions:SLHookPositionOptionBefore | SLHookOptionRemoveAfterCalled replaceBlock:^(id<SLHookInfo>info, NSString *b) {
        NSLog(@"你相信光吗？");
    } error:&error];
    [hookUnit remove];
    
//    [self.superclass aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionBefore usingBlock:^{
//        NSLog(@"1111111111111111111111");
//    } error:nil];
//    [self.class aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionBefore usingBlock:^{
//        NSLog(@"22222222222222");
//    } error:nil];
    [self willBeHooked:@"11111"];
    [self willBeHooked:@"11111"];
}

- (void)willBeHooked:(NSString *)a {
    NSLog(@"啥也不是");
}


#pragma mark - tableview代理方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SLTestItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"testItemCell"];
    if (indexPath.row == 0) {
        cell.itemTitleLabel.text = @"链式调用";
    } else if (indexPath.row == 1) {
        cell.itemTitleLabel.text = @"自动布局";
    } else if (indexPath.row == 2) {
        cell.itemTitleLabel.text = @"自定义验证码输入框";
    } else if (indexPath.row == 3) {
        cell.itemTitleLabel.text = @"缓存";
    }
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        SLChainableVC *chaimableVc = [[SLChainableVC alloc] init];
        [self.navigationController pushViewController:chaimableVc animated:YES];
    } else if (indexPath.row == 1) {
        SLAutoLayoutVC *autoLayoutVc = [[SLAutoLayoutVC alloc] init];
        [self.navigationController pushViewController:autoLayoutVc animated:YES];
    } else if (indexPath.row == 2) {
        SLCustomFieldVC *customFieldVc = [[SLCustomFieldVC alloc] init];
        [self.navigationController pushViewController:customFieldVc animated:YES];
    } else if (indexPath.row == 3) {
        SLCacheVC *cacheVc = [[SLCacheVC alloc] init];
        [self.navigationController pushViewController:cacheVc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
