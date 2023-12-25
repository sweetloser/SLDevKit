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

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        sl_importTableReplace("1", "2", NULL, NULL);
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SLAppDelegate class]));
    }
}
