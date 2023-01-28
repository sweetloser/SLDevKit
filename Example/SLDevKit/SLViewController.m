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

@interface SLViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"SLTestItemCell" bundle:nil] forCellReuseIdentifier:@"testItemCell"];
}

#pragma mark - tableview代理方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SLTestItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"testItemCell"];
    if (indexPath.row == 0) {
        cell.itemTitleLabel.text = @"链式调用";
    } else if (indexPath.row == 1){
        cell.itemTitleLabel.text = @"自动布局";
    }
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
