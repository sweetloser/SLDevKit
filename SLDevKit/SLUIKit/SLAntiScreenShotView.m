//
//  SLAntiScreenShotView.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/29.
//

#import "SLAntiScreenShotView.h"

@interface SLAntiScreenShotView ()<UITextFieldDelegate>

@property (nonatomic,strong) UITextField *textField;
/// 真正的内容视图
@property (nonatomic,strong) UIView *realContainView;

@end

@implementation SLAntiScreenShotView

#pragma mark - 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupUI];
    }
    return self;
}
#pragma mark - 销毁
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 布局
- (void)setupUI {
    [self addSubview:self.textField];
    //self.textField.subviews.firstObject 主要需要这个view实现antiscreenshot
    self.textField.subviews.firstObject.userInteractionEnabled = YES;
    [self.textField.subviews.firstObject addSubview:self.realContainView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.textField.frame = self.bounds;
    self.realContainView.frame = self.bounds;
    
    if (self.textField.superview != self) {
        [self addSubview:self.textField];
    }
}

#pragma mark - 通知
- (void)keyboardWillShow:(NSNotification *)noti {
    if (self.textField.isFirstResponder) {
        [self.textField resignFirstResponder];
        self.textField.subviews.firstObject.userInteractionEnabled = YES;
    }
}


/// 重写 addSubview 将添加到self的view重新添加到realContainView上
/// - Parameter view: 要添加的视图
- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    if (self.textField != view) {
        [self.realContainView addSubview:view];
    }
}
#pragma mark - UITextField代理方法
// 禁止当前UITextField成为响应者，从而导致键盘莫名其妙弹出
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.textField) return NO;
    return YES;
}
#pragma mark - 懒加载
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.secureTextEntry = YES;
        _textField.delegate = self;
    }
    return _textField;
}

- (UIView *)realContainView {
    if (!_realContainView) {
        _realContainView = [[UIView alloc] init];
        _realContainView.backgroundColor = [UIColor clearColor];
    }
    return _realContainView;
}

@end
