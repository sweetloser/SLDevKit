//
//  _SLModelXMLParser.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/21.
//

#import "_SLModelXMLParser.h"
#import "_SLModelXMLParserStack.h"

static BOOL NSStringEqualsXMLNullString(NSString *string);

@interface _SLModelXMLParser ()<NSXMLParserDelegate>

@property(nonatomic,strong)NSXMLParser *parser;
@property(nonatomic,strong)id parserData;
@property(nonatomic,assign)id currentNode;
@property(nonatomic,copy)NSString *xml;

@property (nonatomic, strong) NSMutableString *foundCharacters;
@property (nonatomic, retain) NSMutableData *foundCDATA;

@property(nonatomic,strong)_SLModelXMLParserStack *parentNodesStack;

@property(nonatomic,strong)dispatch_semaphore_t lock;
@end

@implementation _SLModelXMLParser

+ (id)sl_parserDataWithXml:(NSString *)xml {
    if (!xml || ![xml isKindOfClass:[NSString class]]) return nil;
    
    _SLModelXMLParser *parser = [[_SLModelXMLParser alloc] initWithXml:xml];
    dispatch_semaphore_wait(parser.lock, DISPATCH_TIME_FOREVER);
    [parser _sl_startParser];
    
    dispatch_semaphore_wait(parser.lock, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_signal(parser.lock);
    return parser.parserData;
}

- (instancetype)initWithXml:(NSString *)xml {
    self = [super init];
    if (self) {
        _xml = xml;
        
        _parser = [[NSXMLParser alloc] initWithData:[xml dataUsingEncoding:NSUTF8StringEncoding]];
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)_sl_startParser {
    _parser.delegate = self;
    [_parser parse];
}

#pragma mark - NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    dispatch_semaphore_signal(self.lock);
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"解析失败了");
    dispatch_semaphore_signal(self.lock);
}
- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    NSLog(@"解析失败了");
    dispatch_semaphore_signal(self.lock);
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if (!self.parserData) {
        self.parserData = [NSMutableDictionary dictionary];
        self.currentNode = self.parserData;
        self.parentNodesStack = [_SLModelXMLParserStack stack];
    }
    
    NSString *currentNodeKey = nil;
    if ([self.currentNode objectForKey:elementName]) {
        NSMutableArray *elementsArray = [NSMutableArray arrayWithObjects:[self.currentNode objectForKey:elementName], [_SLModelXMLParser cleanedAttributes:attributeDict], nil];
        currentNodeKey = [elementName stringByAppendingString:@"sArray"];
        [self.currentNode setObject:elementsArray forKey:currentNodeKey];
        [self.currentNode removeObjectForKey:elementName];
        
    } else if ([self.currentNode objectForKey:[elementName stringByAppendingString:@"sArray"]]) {
        NSMutableArray *currentNode = [self.currentNode objectForKey:[elementName stringByAppendingString:@"sArray"]];
        [currentNode addObject:[_SLModelXMLParser cleanedAttributes:attributeDict]];
        currentNodeKey = [elementName stringByAppendingString:@"sArray"];
        
    } else {
        currentNodeKey = elementName;
        [self.currentNode setObject:[_SLModelXMLParser cleanedAttributes:attributeDict] forKey:elementName];
    }
    
    [self.parentNodesStack push:self.currentNode];
    
    id currentNode = [self.currentNode objectForKey:currentNodeKey];
    if ([currentNode isKindOfClass:[NSDictionary class]]) {
        self.currentNode = currentNode;
    } else {
        [self.parentNodesStack push:currentNode];
        self.currentNode = [currentNode lastObject];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([self.foundCharacters length] > 0 && !NSStringEqualsXMLNullString(self.foundCharacters)) {
        [self.currentNode setObject:[self.foundCharacters stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"content"];
        self.foundCharacters = nil;
    } else if ([self.foundCDATA length] > 0 && !NSStringEqualsXMLNullString(self.foundCharacters)) {
        NSString *foundCDATA = [[NSString alloc] initWithData:self.foundCDATA encoding:NSUTF8StringEncoding];
        [self.currentNode setObject:[foundCDATA stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"content"];
        self.foundCDATA = nil;
    }
    
    id parentNode = [self.parentNodesStack pop];
    if ([parentNode isKindOfClass:[NSDictionary class]]) {
        self.currentNode = parentNode;
    } else {
        self.currentNode = [self.parentNodesStack pop];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.foundCharacters appendString:string];
}
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    
}

#pragma mark Attributes Cleaning
+ (NSMutableDictionary *)cleanedAttributes:(NSDictionary *)attributes {
    NSMutableDictionary *cleanedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    
    NSSet *nullObjectsKeys = [cleanedAttributes keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return ([obj isKindOfClass:[NSString class]] && NSStringEqualsXMLNullString(obj));
    }];
    
    [cleanedAttributes removeObjectsForKeys:[nullObjectsKeys allObjects]];
    
    
    return cleanedAttributes;
}

#pragma mark - getter
- (NSMutableString *)foundCharacters {
    if (!_foundCharacters) {
        _foundCharacters = [[NSMutableString alloc] init];
    }
    return _foundCharacters;
}
- (NSMutableData *)foundCDATA {
    if (!_foundCDATA) {
        _foundCDATA = [[NSMutableData alloc] init];
    }
    return _foundCDATA;
}

@end

#pragma mark - Utilities
static BOOL NSStringEqualsXMLNullString(NSString *string) {
    return [string isEqualToString:@"null"];
}
