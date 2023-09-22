//
//  SLModelVC.m
//  SLDevKit_Example
//
//  Created by zengxiangxiang on 2023/9/14.
//  Copyright © 2023 sweetloser. All rights reserved.
//

#import "SLModelVC.h"
#import <SLDevKit/SLDevKit.h>
#import <YYModel.h>

@protocol AnimalProtocol <NSObject>
@optional
- (void)eat;
@end

@protocol CatProtocol <NSObject>

@optional
- (void)scratch;

@end

@interface Cat : NSObject<CatProtocol>

@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)int age;

@end
@implementation Cat

@end

@interface Person : NSObject

@property(nonatomic,assign)CGPoint position;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSDictionary *myname;
@property(nonatomic,assign)NSUInteger age;
@property(nonatomic,copy)void(^block)(void);
@property(nonatomic,strong)id <CatProtocol,AnimalProtocol>petCat;

@property(nonatomic,copy)NSString *firstname;
@property(nonatomic,strong)NSArray *phonesArray;

@end

@implementation Person
@end

@interface SLModelVC ()

@end

@implementation SLModelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.bgColor(@"#FFF");
    
    NSString *json = @"{\"name\":\"房东\",\"age\":29}";
    
    NSDictionary *dictJson = @{@"name":@"房东", @"age":@28, @"block":^{
        NSLog(@"blockkkk");
    }};
    
    NSString *xmlString = @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><contact identifier=\"0\"><myname><firstname>Zouhair</firstname><lastname>lllllll</lastname></myname><phone type=\"mobile\"><code>86</code><number>199999999999</number></phone><phone type=\"home\"><code>86</code><number>18888888888</number></phone></contact>";
    
    Person *xmlp = [Person sl_modelWithXML:xmlString];
    
    Person *py = [Person yy_modelWithJSON:dictJson];
    Person *p = [Person sl_modelWithJson:dictJson];
    NSLog(@"p:%@",p);
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
