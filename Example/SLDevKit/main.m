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
#import "SLHookVC.h"

int add(int a, int b) {
    return a + b;
}

void callback(void *address, SLRegisterContext *ctx) {
    NSLog(@"===");
}

int main(int argc, char * argv[]) {
    
    uint8_t ret[4] = {0x1F, 0x20, 0x03, 0xD5};
    
//    sl_codePatch(&add, ret, 4);
    sl_instrument(&add, (sl_instrument_callback_t)&callback);
    add(10, 20);
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SLAppDelegate class]));
    }
}
