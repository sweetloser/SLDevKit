//
//  SLTestData.m
//  SLDevKit_Tests
//
//  Created by zengxiangxiang on 2023/1/30.
//  Copyright © 2023 sweetloser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SLDevKit/SLDevKit.h>

@interface SLTestData : XCTestCase

@end

@implementation SLTestData

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    NSString *origStr = @"ABCDEFG";
    NSData *data = [NSData dataWithBytes:origStr.UTF8String length:origStr.length];
    NSData *enData = data.base64Encode();
    NSData *deData = enData.base64Decode();
    NSLog(@"~~~~~~~~~~~");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
