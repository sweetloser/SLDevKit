//
//  SLUpdateAlertView.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/4/26.
//

#import "SLUpdateAlertView.h"
#import "SLAutoLayout.h"
#import "SLUIKit.h"
#import "SLFoundation.h"

#define _kDefultIconHeight      66


@interface SLUpdateAlertView()

@property(nonatomic,strong)UIView *containView;

@property(nonatomic,strong)UIImageView *iconImageView;
@property(nonatomic,strong)UILabel *tipLabel;
@property(nonatomic,strong)UILabel *versionLabel;
@property(nonatomic,strong)UITextView *updateDescTextView;
@property(nonatomic,strong)UIButton *cancelButton;
@property(nonatomic,strong)UIButton *updateButton;


/*布局相关*/
@property(nonatomic,assign)CGFloat containMargin;
@property(nonatomic,assign)CGFloat iconTop;
@property(nonatomic,assign)CGSize iconSize;
@property(nonatomic,assign)CGFloat tipTop;
@property(nonatomic,assign)CGFloat tipHeight;
@property(nonatomic,assign)CGFloat versionTop;
@property(nonatomic,assign)CGFloat versionHeight;
@property(nonatomic,assign)CGFloat descTop;
@property(nonatomic,assign)CGFloat descLeft;
@property(nonatomic,assign)CGFloat descHeight;
@property(nonatomic,assign)CGFloat buttonTop;
@property(nonatomic,assign)CGFloat buttonHeight;
@property(nonatomic,assign)CGFloat bottomPadding;

@end

@implementation SLUpdateAlertView

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    if (CGRectEqualToRect(frame, CGRectZero)) {
        frame = CGRectMake(0, 0, SL_SCREEN_WIDTH, SL_SCREEN_HEIGHT);
    }
    self = [super initWithFrame:frame];
    if (self) {
        [self _defaultLayoutValue];
        [self _setupSubviews];
    }
    return self;
}
- (void)dealloc {
    NSLog(@"%@销毁了!!!",[self class]);
}
#pragma mark - 初始化默认值
-(void)_defaultLayoutValue {
    self.containMargin = 24;
    self.iconTop = 0;
    self.iconSize = CGSizeZero;
    self.tipTop = 0;
    self.tipHeight = 0;
    self.versionTop = 0;
    self.versionHeight = 0;
    self.descTop = 0;
    self.descLeft = 0;
    self.descHeight = 0;
    self.buttonTop = 50;
    self.buttonHeight = 50;
    self.bottomPadding = 25;
}
#pragma mark - UI布局
-(void)_setupSubviews {
    self.bgColor(@"0,0,0,0.3");
    self.containView.addTo(self).slLayout().centerXEqualToView_sl(self).centerYEqualToView_sl(self).wIs_sl(SL_SCREEN_WIDTH-self.containMargin*2).hIs_sl([self _getNewestContainHeight]);
    
    // 增加动画效果
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.6;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [self.containView.layer addAnimation:animation forKey:nil];
}
-(void)_updateUILayout {
    self.containView.slLayout().wIs_sl(SL_SCREEN_WIDTH-self.containMargin*2).hIs_sl([self _getNewestContainHeight]);
    
    self.iconImageView.slLayout().topSpaceToView_sl(self.iconTop, self.containView).whIs_sl(self.iconSize.width, self.iconSize.height);
    
    self.tipLabel.slLayout().topSpaceToView_sl(self.tipTop, self.iconImageView).hIs_sl(self.tipHeight);
    
    self.versionLabel.slLayout().topSpaceToView_sl(self.versionTop, self.tipLabel).hIs_sl(self.versionHeight);
    
    self.updateDescTextView.slLayout().topSpaceToView_sl(self.descTop, self.versionLabel).hIs_sl(self.descHeight);
    
    self.updateButton.slLayout().wIs_sl((SL_SCREEN_WIDTH-self.containMargin*2-20*2-20)/2.f);
}

-(void)_showInKeyWindow {
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    [keyWindow addSubview:self];
    [keyWindow bringSubviewToFront:self];
}
-(void)dismissAlert {
    [UIView animateWithDuration:0.6 animations:^{
        self.transform = (CGAffineTransformMakeScale(1.5, 1.5));
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    } ];
}

#pragma mark - 链式调用
- (SLChainableSLUpdateAlertViewFloatBlock)borderRadius_sl {
    return ^(CGFloat f) {
        self.containView.borderRadius(f);
        return self;
    };
}
- (SLChainableSLUpdateAlertViewFloatBlock)margin_sl {
    return ^(CGFloat f) {
        self.containMargin = f;
        return self;
    };
}
- (SLChainableSLUpdateAlertViewObjectBlock)img_sl {
    return ^(NSObject *obj){
        self.iconImageView.img(obj);
        self.iconTop = self.iconTop?:10;
        self.iconSize = CGSizeEqualToSize(self.iconSize, CGSizeZero)?CGSizeMake(66, 66):self.iconSize;
        return self;
    };
}
- (SLChainableSLUpdateAlertViewTwoFloatBlock)imgSize_sl {
    return ^(CGFloat f1, CGFloat f2) {
        self.iconSize = CGSizeMake(f1, f2);
        return self;
    };
}
- (SLChainableSLUpdateAlertViewObjectBlock)tips_sl {
    return ^(NSObject *obj) {
        self.tipLabel.str(obj);
        self.tipTop = self.tipTop?:10;
        self.tipHeight = self.tipHeight?:25;
        return self;
    };
}
- (SLChainableSLUpdateAlertViewObjectBlock)version_sl {
    return ^(NSObject *obj) {
        self.versionLabel.str(obj);
        self.versionTop = self.versionTop?:10;
        self.versionHeight = self.versionHeight?:20;
        return self;
    };
}
- (SLChainableSLUpdateAlertViewObjectBlock)desc_sl {
    return ^(NSObject *obj) {
        self.updateDescTextView.str(obj);
        self.descTop = self.descTop?:10;
        self.descHeight = self.descHeight?:70;
        return self;
    };
}
- (SLChainableSLUpdateAlertViewCallBackBlock)updateOnClick_sl {
    return ^(id target, id obj){
        id(^onClick_)(id,id) = self.updateButton.onClick;
        onClick_(target, obj);
        return self;
    };
}
- (void (^)(void))show {
    return ^{
        [self _updateUILayout];
        [self _showInKeyWindow];
    };
}

#pragma mark - tools
-(CGFloat)_getNewestContainHeight {
    return self.iconTop+self.iconSize.height+self.tipTop+self.tipHeight+self.versionTop+self.versionHeight+self.descTop+self.descHeight+self.buttonTop+self.buttonHeight+self.bottomPadding;
}

#pragma mark - 懒加载
- (UIView *)containView {
    if (!_containView) {
        _containView = SLView.bgColor(@"white").borderRadius(10);
        
        self.iconImageView.addTo(_containView).slLayout().centerXEqualToView_sl(_containView).topSpaceToView_sl(self.iconTop).whIs_sl(self.iconSize.width, self.iconSize.height);
        self.tipLabel.addTo(_containView).slLayout().topSpaceToView_sl(self.tipTop,self.iconImageView).centerXEqualToView_sl(_containView).hIs_sl(25).wIs_sl(100);
        self.versionLabel.addTo(_containView).slLayout().topSpaceToView_sl(10, self.tipLabel).centerXEqualToView_sl(_containView).hIs_sl(20).wIs_sl(250);
        self.updateDescTextView.addTo(_containView).slLayout().topSpaceToView_sl(self.descTop, self.versionLabel).leftSpaceToView_sl(self.descLeft).rightSpaceToView_sl(self.descLeft).hIs_sl(70);
        self.updateButton.addTo(_containView).slLayout().rightSpaceToView_sl(20).hIs_sl(self.buttonHeight).wIs_sl((SL_SCREEN_WIDTH-self.containMargin*2-20*2-20)/2.f).bottomSpaceToView_sl(self.bottomPadding);
        self.cancelButton.addTo(_containView).slLayout().leftSpaceToView_sl(20).heightRatioToView_sl(1.f, self.updateButton).widthRatioToView_sl(1.f, self.updateButton).bottomEqualToView_sl(self.updateButton);
    }
    return _containView;
}
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = SLImageView.cMode(UIViewContentModeScaleAspectFit);
    }
    return _iconImageView;
}
- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = SLLabel.str(@"更新提示").fnt(@20).tColor(@"120,203,118").textAlign(1/*center*/);
    }
    return _tipLabel;
}
- (UILabel *)versionLabel {
    if (!_versionLabel) {
        _versionLabel = SLLabel.str(@"新版本已准备就绪，请更新！").tColor(@"0x282828").fnt(@18).textAlign(1/*center*/);
    }
    return _versionLabel;
}
- (UITextView *)updateDescTextView {
    if (!_updateDescTextView) {
        _updateDescTextView = SLTextView.fnt(@"15").tColor(@"0x8c8c8c");
    }
    return _updateDescTextView;
}
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = SLButton.bgColor(@"0xFFFFFF").tColor(@"120, 203, 118").str(@"取消").fnt(@18).borderRadius(25).border(1, @"120, 203, 118").onClick(^{
            [self dismissAlert];
        });
    }
    return _cancelButton;
}
- (UIButton *)updateButton {
    if (!_updateButton) {
        _updateButton = SLButton.bgColor(@"120, 203, 118").tColor(@"0xFFFFFF").str(@"立即更新").fnt(@18).borderRadius(25);
    }
    return _updateButton;
}

@end
