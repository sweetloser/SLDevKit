//
//  main.m
//  SLDevKit
//
//  Created by sweetloser on 11/04/2022.
//  Copyright (c) 2022 sweetloser. All rights reserved.
//

@import UIKit;
#import "SLAppDelegate.h"
#import <SLDevKit/SLDevKit.h>

int main(int argc, char * argv[])
{
    
    NSString *str = @"1234567890";
    NSData *key = [@"1234567890123456" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *iv = [@"1234567890123456" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",[[NSString alloc] initWithData:data.sm4CbcEncrypt(key, iv) encoding:NSUTF8StringEncoding]);
    NSLog(@"%@",[[NSString alloc] initWithData:data.sm4CbcEncrypt(key, iv).sm4CbcDecrypt(key, iv) encoding:NSUTF8StringEncoding]);
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SLAppDelegate class]));
    }
}
