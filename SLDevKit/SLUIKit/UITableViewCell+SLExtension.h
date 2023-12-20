//
//  UITableViewCell+SLExtension.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewCell (SLExtension)

+ (void)sl_registerForTableView:(UITableView *)tableView;

+ (UITableViewCell *)sl_dequeueReusableCellInTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
