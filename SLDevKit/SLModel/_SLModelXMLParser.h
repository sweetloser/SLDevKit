//
//  _SLModelXMLParser.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface _SLModelXMLParser : NSObject

+ (id)sl_parserDataWithXml:(NSString *)xml;

@end

NS_ASSUME_NONNULL_END
