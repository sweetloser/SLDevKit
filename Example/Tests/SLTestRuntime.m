//
//  SLTestRuntime.m
//  SLDevKit_Tests
//
//  Created by zengxiangxiang on 2023/1/13.
//  Copyright © 2023 sweetloser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@interface SLTestRuntime : XCTestCase

@end

@implementation SLTestRuntime

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    Method m = class_getInstanceMethod(NSClassFromString(@"SLViewController"), @selector(description));
    IMP imp = method_getImplementation(m);
    UIViewController *vc = (UIViewController *)[NSClassFromString(@"SLViewController") new];
    NSString *v = imp(vc, @selector(description));
    NSLog(@"0x%lx",(long)imp);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
