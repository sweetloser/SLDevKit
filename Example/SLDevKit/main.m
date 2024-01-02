//
//  main.m
//  SLDevKit
//
//  Created by sweetloser on 11/04/2022.
//  Copyright (c) 2022 sweetloser. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SLAppDelegate.h"
#import <SLDevKit/SLDevKit.h>
#define MYLOG(fmt, ...) {   \
    NSString *_d_fmts = [@"fake log" stringByAppendingFormat:fmt, __VA_ARGS__];   \
    sl_nslog(_d_fmts);      \
}
void (*orig_nslog)(NSString *fmt, ...);
void sl_nslog(NSString *fmt, ...) {
    orig_nslog(fmt);
}

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        sl_importTableReplace(NULL, "NSLog", sl_nslog, (void **)&orig_nslog);
        orig_nslog = sl_symbolResolver("SLDevKit", "sl_nslog");
        MYLOG(@"aaaaa=:%s===========",argv[0]);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SLAppDelegate class]));
    }
}
