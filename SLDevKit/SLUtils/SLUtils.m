//
//  SLUtils.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import "SLUtils.h"
#import "SLDefs.h"
#import <SystemConfiguration/CaptiveNetwork.h>

id _slConvertValueToString(const char *type, ...) {
    id result = nil;
    
    va_list argList;
    va_start(argList, type);
    
    if (SL_CHECK_IS_INT(type[0])) {
        // 判断参数是否为整型【所有整型：包含int、long、bool、short等】
        NSInteger n = va_arg(argList, NSInteger);
        return [@(n) description];
    } else if (SL_CHECK_IS_FLOAT(type[0])) {
        // 判断参数是否为浮点型【float、double】
        double d = va_arg(argList, double);
        return [@(d) description];
    } else {
        result = va_arg(argList, id);
    }
    va_end(argList);
    
    return result;
}

@implementation SLUtils

+ (BOOL)matchNumLetterAndEnglishSymbol:(NSString *)matchString {
    NSString *pattern = @"^[!-~]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    BOOL isMatch = [pred evaluateWithObject:matchString];
    return isMatch;
}


+ (NSString *)wiFiName {
NSArray *wiFiName = CFBridgingRelease(CNCopySupportedInterfaces());
id info1 = nil;
for (NSString *wfName in wiFiName) {
    info1 = (__bridge_transfer id)CNCopyCurrentNetworkInfo((CFStringRef) wfName);
        if (info1 && [info1 count]) {
            break;
        }
    }
    NSDictionary *dic = (NSDictionary *)info1;

    NSString *ssidName = [[dic objectForKey:@"SSID"] lowercaseString];

    return ssidName;
}

+ (BOOL)isVPNOn {
   BOOL flag = NO;
   NSString *version = [UIDevice currentDevice].systemVersion;
   // need two ways to judge this.
   if (version.doubleValue >= 9.0) {
       NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
       NSArray *keys = [dict[@"__SCOPED__"] allKeys];
       for (NSString *key in keys) {
           if ([key rangeOfString:@"tap"].location != NSNotFound ||
               [key rangeOfString:@"tun"].location != NSNotFound ||
               [key rangeOfString:@"ipsec"].location != NSNotFound ||
               [key rangeOfString:@"ppp"].location != NSNotFound){
               flag = YES;
               break;
           }
       }
   }

   return flag;
}

+ (BOOL)isOpenTheProxy {
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"https://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    NSDictionary *settings = proxies[0];
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)isJailBroken {
#if TARGET_OS_SIMULATOR
    return NO;
#endif
    // 判断 Cydia 是否安装
    BOOL isCydiaInstalled = [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] || [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]];

    // 判断是否有越狱工具的安装目录
    BOOL isJailbreakTool = [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"] ||
                       [[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"] ||
                       [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"] ||
                       [[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"];

    // 判断是否有越狱工具的文件
    BOOL isJailbreakToolExist = [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt"] ||
                                [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/cydia"] ||
                                [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/mobile/Library/SBSettings/Themes"] ||
                                [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/stash"] ||
                                [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/libexec/cydia/cydo"];

    // 判断是否安装了 MobileSubstrate 应用程序
    BOOL isMobileSubstrateInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/mobilesubstrate"]];
    
    return isCydiaInstalled || isJailbreakTool || isJailbreakToolExist || isMobileSubstrateInstalled;
}

@end
