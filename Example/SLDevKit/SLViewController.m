//
//  SLViewController.m
//  SLDevKit
//
//  Created by sweetloser on 11/04/2022.
//  Copyright (c) 2022 sweetloser. All rights reserved.
//
#import <UIKit/UIKit.h>
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
    NSBundle *a;
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"SLTestItemCell" bundle:nil] forCellReuseIdentifier:@"testItemCell"];
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
