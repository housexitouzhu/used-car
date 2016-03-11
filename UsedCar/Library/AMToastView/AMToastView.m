//
//  AMToastView.m
//  UsedCar
//
//  Created by Alan on 13-11-11.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "AMToastView.h"
#import "UIImageView+Util.h"


@interface AMToastView ()

@property (nonatomic, copy) ToastCancel blockCancel;;

@end

static AMToastView *_toastView;

@implementation AMToastView

+ (AMToastView *)toastView{
    if(!_toastView)
        _toastView = [[AMToastView alloc] initWithWindow];
    return _toastView;
}

+ (AMToastView *)toastView:(BOOL)isIntercept{
    if(!_toastView)
        _toastView = [[AMToastView alloc] initWithWindow];
    [_toastView setTouchIntercept:isIntercept];
    return _toastView;
}

- (id)initWithWindow
{
    self = [super init];
    if(self){
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _window.windowLevel = UIWindowLevelStatusBar;
        _window.userInteractionEnabled = NO;
        _window.tag = 10000;
        [self initMainView];
        
        // 监听后台重新唤起
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:[UIApplication sharedApplication]];
    }
    
    return self;
}

- (void)applicationDidBecomeActive {
    if (!_ivLoading.hidden && ![_ivLoading isCoreAnimating])
        [_ivLoading startCoreAnimating];
}

////暂停layer上面的动画
//- (void)pauseLayer:(CALayer*)layer
//{
//    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
//    layer.speed = 0.0;
//    layer.timeOffset = pausedTime;
//}
//
////继续layer上面的动画
//- (void)resumeLayer:(CALayer*)layer
//{
//    CFTimeInterval pausedTime = [layer timeOffset];
//    layer.speed = 1.0;
//    layer.timeOffset = 0.0;
//    layer.beginTime = 0.0;
//    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
//    layer.beginTime = timeSincePause;
//}

- (id)initWithView:(UIView *)view
{
    self = [super init];
    if(self){
        _rootView = view;
        [self initMainView];
    }
    return self;
}

- (void)setTouchIntercept:(BOOL)isIntercept{
    if(_window){
        _window.userInteractionEnabled = isIntercept;
    }else{
        _vMain.userInteractionEnabled = isIntercept;
    }
    
    if(isIntercept)
        _vMain.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    else
        _vMain.backgroundColor = [UIColor clearColor];
}

- (void)initMainView{
    self.fromScale = 1.4;
    
    //主视图
    _vMain = [[UIView alloc] initWithFrame:CGRectZero];
    
    //面板
    _vPanel = [[UIView alloc] initWithFrame:CGRectZero];
    _vPanel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    //_vPanel.layer.cornerRadius = 8;
    _vPanel.layer.masksToBounds = YES;
    _vPanel.opaque = NO;
    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickPanel)];
    [_vPanel addGestureRecognizer:tapSingle];
    
    //菊花
    _ivLoading = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_loading_icon"]];
    
    //关闭
    _ivClose = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_loading_cancel_icon"]];
    
    //图片
    _ivImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    //标题
    _labTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    _labTitle.font = [UIFont boldSystemFontOfSize:12.0];
    _labTitle.backgroundColor = [UIColor clearColor];
    _labTitle.textColor = kColorWhite;
    _labTitle.numberOfLines = 0;
    _labTitle.lineBreakMode = UILineBreakModeCharacterWrap;
    
    [_vPanel addSubview:_ivLoading];
    [_vPanel addSubview:_ivClose];
    [_vPanel addSubview:_ivImage];
    [_vPanel addSubview:_labTitle];
    
    [_vMain addSubview:_vPanel];
}

- (void)onClickPanel {
    if (_blockCancel)
        _blockCancel();
}

- (void)makeMainView:(UIView *)rootView {
    _vMain.frame = rootView.bounds;
    
    [_ivLoading stopCoreAnimating];
    _ivLoading.hidden = YES;
    _ivClose.hidden = YES;
    _ivImage.hidden = YES;
    _labTitle.hidden = YES;
    
    CGFloat width = 240;
    CGFloat maxWidth = 0;
    
    //菊花
    if(self.isLoading){
        _ivLoading.hidden = NO;
        [_ivLoading startCoreAnimating];
        // 设置了取消回调方法才显示关闭按钮
        _ivClose.hidden = self.blockCancel ? NO : YES;
        maxWidth = _ivLoading.width;
    }
    //图片
    else if(self.icon){
        _ivImage.hidden = NO;
        _ivImage.image = self.icon;
        _ivImage.size = self.icon.size;
        if(_ivImage.width > maxWidth)
            maxWidth = _ivImage.width;
    }
    //文字
    if(self.title){
        _labTitle.hidden = NO;
        _labTitle.text = self.title;
        CGSize titleSize = [self.title sizeWithFont:_labTitle.font constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        _labTitle.size = titleSize;
        if(_labTitle.width > maxWidth)
            maxWidth = _labTitle.width;
    }
    
    //调整位置
    maxWidth = maxWidth + 20;
    _vPanel.width = maxWidth < width ? maxWidth : width;
    //菊花
    if(self.isLoading){
        _ivLoading.origin = CGPointMake((_vPanel.width - _ivLoading.width) / 2, 10);
        _ivClose.origin = CGPointMake(_vPanel.width - _ivClose.width - 2, 2);
    }
    //图片
    else if(self.icon){
        _ivImage.origin = CGPointMake((_vPanel.width - _ivImage.width) / 2, 10);
    }
    //文字
    if(self.title){
        CGFloat titleMinY = 0;
        if (!_ivLoading.hidden)
            titleMinY = _ivLoading.maxY;
        else if(!_ivImage.hidden)
            titleMinY = _ivImage.maxY;
        _labTitle.origin = CGPointMake((_vPanel.width - _labTitle.width) / 2, titleMinY + 10);
    }
    CGFloat panelH = 0;
    if(!_labTitle.hidden)
        panelH = _labTitle.maxY;
    else if (!_ivImage.hidden)
        panelH = _ivImage.maxY;
    else if (!_ivLoading.maxY)
        panelH = _ivLoading.maxY;
    
    _vPanel.height = panelH + 10;
    _vPanel.center = _vMain.center;
    
    if(![_vMain isDescendantOfView:rootView])
        [rootView addSubview:_vMain];
}

- (void)showLoading:(NSString *)title cancel:(ToastCancel)blockCancel {
    _blockCancel = blockCancel;
    [self show:title icon:nil isLoading:YES duration:0];
}

- (void)showMessage:(NSString *)title icon:(UIImage *)icon duration:(AMToastDuration)duration {
    [self setTouchIntercept:NO];
    [self show:title icon:icon isLoading:NO duration:duration];
}

/* 显示提示框 */
- (void)show:(NSString *)title icon:(UIImage *)icon isLoading:(BOOL)isLoading duration:(NSTimeInterval)duration {
    //取消延迟隐藏
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    
    //设置属性
    self.title = title;
    self.icon = icon;
    self.loading = isLoading;
    
    //定制视图
    if(_window){
        if(_window.isHidden)
            //[_window makeKeyAndVisible];
            _window.hidden = NO;
        [self makeMainView:_window];
    }
    
    else if(_rootView){
        [self makeMainView:_rootView];
    }
    
    if(!_isShow){
        _isShow = YES;
        
        //显示
        _vMain.alpha = 0;
        _vPanel.transform = CGAffineTransformMakeScale(self.fromScale, self.fromScale);
        
        [UIView animateWithDuration:0.2 animations:^{
            _vPanel.transform = CGAffineTransformMakeScale(1.0, 1.0);
            _vMain.alpha = 1;
        }];
    }
    
    //延迟取消
    if (duration > 0)
        [self performSelector:@selector(hide) withObject:nil afterDelay:duration];
}

/* 隐藏提示框 */
- (void)hide{
    if (_blockCancel)
        self.blockCancel = nil;
    if (_isShow) {
        _isShow = NO;
        [UIView animateWithDuration:0.2 animations:^{
            _vPanel.transform = CGAffineTransformMakeScale(self.fromScale, self.fromScale);
            _vMain.alpha = 0;
        } completion:^(BOOL finished) {
            _vPanel.transform = CGAffineTransformMakeScale(1, 1);
            //移除提示框
            [_vMain removeFromSuperview];
            if (_window)
                _window.hidden = YES;
        }];
    }
}

@end
