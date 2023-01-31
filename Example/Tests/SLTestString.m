//
//  SLTestString.m
//  SLDevKit_Tests
//
//  Created by sweetloser on 2022/11/4.
//  Copyright © 2022 sweetloser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SLDevKit/SLDevKit.h>

@interface SLTestString : XCTestCase

@end

@implementation SLTestString

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

-(void)testAAndAp {
    NSString *testA = @"testStr";
    testA = testA.a(@"append").ap(@"path");
    NSLog(@"%@",testA);
    NSAssert([testA isEqualToString:@"testStrappend/path"], @"error");
    
    testA = testA.a(@"%s==%d","/abcf",100);
    NSLog(@"%@",testA);
}

-(void)testSubFromIndex {
    NSString *testStr = @"testStr";
    testStr = testStr.subFromIndex(7);
    NSLog(@"%@",testStr);
    NSAssert([testStr isEqualToString:@""], @"error");
}

-(void)testSubToIndex {
    NSString *testStr = @"ABCDEFG";
    testStr = testStr.subToIndex(3);
    NSLog(@"%@",testStr);
    NSAssert([testStr isEqualToString:@"ABC"], @"error");
}
-(void)testEncode {
    NSLog(@"const_char_*_type:%s",@encode(const char *));
    NSLog(@"cgsize_type:%s",@encode(int));
    NSLog(@"[char]:%s",@encode(const char[10]));
}
-(void)testStringFromTypeAndValue {
    CGRect rect = CGRectMake(0, 0, 100, 100);
    NSString *testRect = SLStrFromValue(rect);
    NSLog(@"rect:%@",testRect);
    
    float f = 3.14159;
    NSString *testF = SLStrFromValue(f);
    NSLog(@"f:%@",testF);
    
    char *cp = "我是哈哈哈HHHHH";
    NSString *testCp = SLStrFromValue(cp);
    NSLog(@"cp:%@",testCp);
    
}

-(void)testReplaceStr {
    NSString *testStr = @"hello world";
    NSRegularExpression *rep = [[NSRegularExpression alloc] initWithPattern:@"(\\w+) (\\w+)" options:0 error:nil];
    NSString *testR = [rep stringByReplacingMatchesInString:testStr options:0 range:NSMakeRange(0, testStr.length) withTemplate:@"$2 $1"];
    NSLog(@"test result:%@",testR);
    NSString *slTestR = testStr.replaceStr(@"(\\w+) (\\w+)", @"$2 $1");
    NSLog(@"sl_test result:%@",slTestR);
}

-(void)testBase64 {
    NSString *testStr = @"Hello world";
    NSString *encodeStr = testStr.base64Encode();
    NSLog(@"%@",encodeStr);
    NSLog(@"%@",encodeStr.base64Decode());
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
