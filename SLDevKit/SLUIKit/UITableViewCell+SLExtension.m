//
//  UITableViewCell+SLExtension.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/27.
//

#import "UITableViewCell+SLExtension.h"

@implementation UITableViewCell (SLExtension)

+ (void)sl_registerForTableView:(UITableView *)tableView {
    Class cls = self;
    [tableView registerClass:cls forCellReuseIdentifier:NSStringFromClass(cls)];
}

+ (UITableViewCell *)sl_dequeueReusableCellInTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self) forIndexPath:indexPath];
    if (!cell) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(self)];
    }
    return cell;
}

@end
