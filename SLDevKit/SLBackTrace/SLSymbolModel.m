//
//  SLSymbolModel.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/3/27.
//

#import "SLSymbolModel.h"

@implementation SLSymbolModel

- (instancetype)initWithDLInfo:(Dl_info *)info {
    self = [super init];
    if (self) {
        self.imageBase = (NSUInteger)info->dli_fbase;
        if (info->dli_fname != NULL) {
            self.imageName = [NSString stringWithUTF8String:info->dli_fname];
        }
        if (info->dli_sname != NULL) {
            self.symbolName = [NSString stringWithUTF8String:info->dli_sname];
        }
        self.symbolAddress = (NSUInteger)info->dli_saddr;
    }
    return self;
}

@end
