//
//  SLCustomField.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/5/30.
//

#import "SLCustomField.h"
#import "SLAutoLayout.h"
#import "SLCustomFieldItemCell.h"
#import "SLCustomFieldItemModel.h"
#import "SLFoundation.h"

@interface SLCustomField ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

#pragma mark - 配置属性
/// 是否需要光标
@property(nonatomic,assign)BOOL cursor;
/// 光标颜色
@property(nonatomic,strong)UIColor *cursorColor;

/// 验证码长度
@property(nonatomic,assign)NSInteger codeLength;
/// 框大小
@property(nonatomic,assign)CGSize itemSize;
/// 边框宽度
@property(nonatomic,assign)CGFloat borderWidth;
/// 边框圆角
@property(nonatomic,assign)CGFloat borderRadius;

/// 边框颜色 对应三种状态【1、聚焦；2、已输入；3、未输入】
@property(nonatomic,strong)UIColor *focusBorderColor;
@property(nonatomic,strong)UIColor *enteredBorderColor;
@property(nonatomic,strong)UIColor *emptyBorderColor;

#pragma mark - 视图布局
@property(nonatomic,strong)UICollectionView *contentCollectionView;
@property(nonatomic,strong)UICollectionViewFlowLayout *boxFlowLayout;
@property(nonatomic,strong)UITextField *inputTextField;
@property(nonatomic,strong)UITapGestureRecognizer *tapGesture;

@property(nonatomic,strong)NSMutableArray *itemModelArray;

/// 本次输入前 的值
@property(nonatomic,copy)NSString *lastValues;
@end

@implementation SLCustomField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _defaultValues];
        [self _layoutSubviews];
    }
    return self;
}
-(void)_defaultValues {
    _lastValues = @"";
    _cursor = YES;
    _cursorColor = Color(@"#FF0000");
    _codeLength = 4;
    _borderWidth = 0.5;
    _borderRadius = 2.5;
    _focusBorderColor = Color(@"#8C8C8C");
    _enteredBorderColor = Color(@"#8C8C8C");
    _emptyBorderColor = Color(@"#8C8C8C");
    _itemSize = CGSizeMake(42, 45);
    self.itemModelArray = [NSMutableArray arrayWithCapacity:_codeLength];
}
-(void)_layoutSubviews {
    self.contentCollectionView.addTo(self).slLayout().spaceToSuperview_sl(0);
    self.inputTextField.addTo(self).slLayout().xywhIs_sl(0);
    
    // 添加一个tap手势
    [self addGestureRecognizer:self.tapGesture];
}

#pragma mark - UI交互
- (void)tapGestureAction {
    if (![self.inputTextField isFirstResponder]) {
        [self.inputTextField becomeFirstResponder];
    }
}
- (void)inputTextFieldValueChangeAction:(UITextField *)textField {
    NSString *curValues = textField.text;
    if (curValues.length > self.codeLength) {
        curValues = curValues.subToIndex(self.codeLength);
        textField.text = curValues;
    }
    // 删除了最后一个字符
    if (self.lastValues.length > curValues.length) {
        // 清空最后一个的value，并将最后一个输入框置为聚焦状态
        SLCustomFieldItemModel *lastItemModel = self.itemModelArray[self.lastValues.length-1];
        lastItemModel.focus = YES;
        lastItemModel.value = @"";
                
        // 清除上一个聚焦状态格子的光标
        if (self.lastValues.length != self.codeLength) {
            SLCustomFieldItemModel *lastCursorItemModel = self.itemModelArray[self.lastValues.length];
            lastCursorItemModel.focus = NO;
        }
//        [self.contentCollectionView reloadItemsAtIndexPaths:reloadIndexs];
        
    } else if (self.lastValues.length < curValues.length) {
        // 输入了一个新值
        SLCustomFieldItemModel *lastItemModel = self.itemModelArray[self.lastValues.length];
        lastItemModel.focus = NO;
        lastItemModel.value = curValues.subFromIndex(self.lastValues.length);
        
        // 将光标向后移一位
        if (self.lastValues.length + 1 < self.codeLength) {
            SLCustomFieldItemModel *lastCursorItemModel = self.itemModelArray[self.lastValues.length + 1];
            lastCursorItemModel.focus = YES;
        }
    }
    
    [self.contentCollectionView reloadData];
    
    self.lastValues = curValues;
    
    if (self.lastValues.length == self.codeLength) {
        [textField resignFirstResponder];
    }
    
}

#pragma mark - 配置方法
- (SLChainableSLCustomFieldBoolBlock)cursor_sl {
    return ^(BOOL cursor) {
        self.cursor = cursor;
        return self;
    };
}

- (SLChainableSLCustomFieldObjectBlock)cursorColor_sl {
    return ^(id obj) {
        self.cursorColor = Color(obj);
        return self;
    };
}

-(SLChainableSLCustomFieldIntBlock)codeLength_sl {
    return ^(NSInteger codeLength) {
        self.codeLength = codeLength;
        return self;
    };
}
- (SLChainableSLCustomFieldEmptyBlock)show_sl {
    return ^{
        [self.itemModelArray removeAllObjects];
        for (int n=0; n<self.codeLength; n++) {
            SLCustomFieldItemModel *itemModel = [[SLCustomFieldItemModel alloc] init];
            itemModel.borderWidth = self.borderWidth;
            itemModel.borderRadius = self.borderRadius;
            itemModel.cursor = self.cursor;
            if (n == 0) {
                itemModel.focus = YES;
            }
            itemModel.cursorColor = self.cursorColor;
            itemModel.focusBorderColor = self.focusBorderColor;
            itemModel.emptyBorderColor = self.emptyBorderColor;
            itemModel.enteredBorderColor = self.enteredBorderColor;
            
            [self.itemModelArray addObject:itemModel];
        }
        [self.contentCollectionView reloadData];
        return self;
    };
}
- (SLChainableSLCustomFieldTwoFloatBlock)itemSize_sl {
    return ^(CGFloat w, CGFloat h) {
        self.itemSize = CGSizeMake(w, h);
        return self;
    };
}
- (SLChainableSLCustomFieldFloatBlock)borderWidth_sl {
    return ^(CGFloat w) {
        self.borderWidth = w;
        return self;
    };
}
- (SLChainableSLCustomFieldFloatBlock)borderRadius_sl {
    return ^(CGFloat r) {
        self.borderRadius = r;
        return self;
    };
}
- (SLChainableSLCustomFieldObjectBlock)focusBorderColor_sl {
    return ^(id obj) {
        self.focusBorderColor = Color(obj);
        return self;
    };
}
- (SLChainableSLCustomFieldObjectBlock)emptyBorderColor_sl {
    return ^(id obj) {
        self.emptyBorderColor = Color(obj);
        return self;
    };
}
- (SLChainableSLCustomFieldObjectBlock)enteredBorderColor_sl {
    return ^(id obj) {
        self.enteredBorderColor = Color(obj);
        return self;
    };
}

#pragma mark - collectionView代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemModelArray.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SLCustomFieldItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SLCustomFieldItemCell" forIndexPath:indexPath];
    cell.itemModel = self.itemModelArray[indexPath.row];
    return cell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemSize;
}

#pragma mark - 懒加载
- (UICollectionView *)contentCollectionView {
    if (!_contentCollectionView) {
        _contentCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.boxFlowLayout];
        _contentCollectionView.bgColor(UIColor.clearColor);
        _contentCollectionView.showsHorizontalScrollIndicator = NO;
        [_contentCollectionView registerClass:SLCustomFieldItemCell.class forCellWithReuseIdentifier:@"SLCustomFieldItemCell"];
        _contentCollectionView.delegate = self;
        _contentCollectionView.dataSource = self;
    }
    return _contentCollectionView;
}

- (UICollectionViewFlowLayout *)boxFlowLayout {
    if (!_boxFlowLayout) {
        _boxFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _boxFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _boxFlowLayout;
}

- (UITextField *)inputTextField {
    if (!_inputTextField) {
        _inputTextField = SLTextField;
        _inputTextField.delegate = self;
        [_inputTextField addTarget:self action:@selector(inputTextFieldValueChangeAction:) forControlEvents:UIControlEventEditingChanged];
        
    }
    return _inputTextField;
}
- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction)];
    }
    return _tapGesture;
}

@end
