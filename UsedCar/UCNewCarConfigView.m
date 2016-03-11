//
//  UCNewCarConfigView.m
//  UsedCar
//
//  Created by 张鑫 on 14-2-14.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCNewCarConfigView.h"
#import "APIHelper.h"
#import "UCCarDetailInfoModel.h"
#import "UCNewCarConfigMode.h"
#import "UIImage+Util.h"

#define kMenuViewDefaultHeiht           40

@interface UCNewCarConfigView ()

@property (nonatomic, strong) APIHelper *apiHelper;
@property (nonatomic, strong) UCCarDetailInfoModel *mCarDetailInfo;
@property (nonatomic, strong) UIScrollView *svConfiguration;
@property (nonatomic, strong) UIButton *btnReload;
@property (nonatomic, strong) UIButton *btnMenu;
@property (nonatomic, strong) UIView *vMain;
@property (nonatomic, strong) UIView *vMenu;
@property (nonatomic, strong) UIView *vOptions;
@property (nonatomic, strong) UIActivityIndicatorView *aiActivity;
@property (nonatomic, strong) NSMutableArray *configurations;
@property (nonatomic, strong) UIView *vOptionBackground;
@property (nonatomic, strong) NSMutableArray *contentOffsets;          // 快捷定位坐标
@property (nonatomic, strong) UIButton *btnScrollToTop;
@property (nonatomic, strong) UIButton *btnMenus;

@end

@implementation UCNewCarConfigView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame mCarDetailInfo:(UCCarDetailInfoModel *)mCarDetailInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        _mCarDetailInfo = mCarDetailInfo;
        _configurations = [NSMutableArray array];
        _contentOffsets = [NSMutableArray array];
        [self initView];
        // 获取数据
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.2];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    
    // 主视图
    _vMain = [[UIView alloc] initWithFrame:self.bounds];
    _vMain.backgroundColor = kColorNewBackground;
    [self addSubview:_vMain];
    
    // 菜单视图
    _vMenu = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, kMenuViewDefaultHeiht)];
    _vMenu.backgroundColor = kColorWhite;
    _vMain.hidden = YES;
    [_vMain addSubview:_vMenu];
    
    // 标识view
    UIView *vIdentify = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _vMenu.width, 40)];
    vIdentify.backgroundColor = kColorWhite;
    
    NSArray *titles = @[@"标配", @"选配", @"无"];
    NSArray *images = @[@"detail_newcar_circle1", @"detail_newcar_circle2", @"detail_newcar_none"];
    CGFloat centerX = 15;
    CGFloat centerY = vIdentify.centerY;
    
    for (int i = 0 ; i < titles.count; i++) {
        // 图片
        UIImage *iImage = [UIImage imageNamed:[images objectAtIndex:i]];
        UIImageView *ivImage = [[UIImageView alloc] init];
        ivImage.image = iImage;
        ivImage.center = CGPointMake(centerX, centerY - 2);
        ivImage.size = iImage.size;
        [vIdentify addSubview:ivImage];
        
        // 标题
        UILabel *labTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(ivImage.maxX + 8, 0, 35, vIdentify.height)];
        labTitle.font = [UIFont systemFontOfSize:13];
        labTitle.textColor = kColorGrey2;
        labTitle.text = [titles objectAtIndex:i];
        [vIdentify addSubview:labTitle];
        
        centerX += 60;
    }
    
    // 分割线
    UIView *vLive = [[UIView alloc] initLineWithFrame:CGRectMake(0, vIdentify.height - kLinePixel, vIdentify.width, kLinePixel) color:kColorNewLine];
    [vIdentify addSubview:vLive];
   // 右边按钮
    _btnMenus = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 40, 10, 30, 20)];
    [_btnMenus setImage:[UIImage imageNamed:@"detail_newcar_menu"] forState:UIControlStateNormal];
    [_btnMenus setImage:[UIImage imageNamed:@"detail_newcar_menu_h"] forState:UIControlStateSelected];
    [_btnMenus addTarget:self action:@selector(onClickMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
    _btnMenus.selected = YES;
    [vIdentify addSubview:_btnMenus];

    // 快捷菜单按钮下分割线
    UIView *vBtnMenuBottomLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, _vMenu.height - kLinePixel, _vMenu.width, kLinePixel) color:kColorNewLine];
    
    // 快捷选项view
    _vOptions = [[UIView alloc] initWithFrame:CGRectMake(0, vIdentify.maxY, _vMenu.width, CGFLOAT_MIN)];
    _vOptions.backgroundColor = kColorBlue1;
    
    // 快捷按钮高亮状态
    _vOptionBackground = [[UIView alloc] init];
    _vOptionBackground.size = CGSizeMake(74, 34);
    _vOptionBackground.backgroundColor = kColorBlue3;
    _vOptionBackground.layer.cornerRadius = 5;
    _vOptionBackground.layer.masksToBounds = YES;
    _vOptionBackground.userInteractionEnabled = NO;
    _vOptionBackground.hidden = YES;
    [_vOptions addSubview:_vOptionBackground];
    
    [_vMenu addSubview:vIdentify];
    [_vMenu addSubview:vBtnMenuBottomLine];
    [_vMenu addSubview:_vOptions];
    
    // 新车配置视图
    _svConfiguration = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _vMenu.maxY - 20 , self.width, self.height - _vMenu.maxY)];
    _svConfiguration.delegate = self;
    _svConfiguration.backgroundColor = kColorNewBackground;
    [_vMain addSubview:_svConfiguration];
    
    // 回到顶部
    UIImage *iScrollToTop = [UIImage imageNamed:@"detail_newcar_up_btn"];
    _btnScrollToTop = [[UIButton alloc] initWithFrame:CGRectMake(_vMain.width - iScrollToTop.width - 15, _vMain.height - iScrollToTop.height - 15, iScrollToTop.width, iScrollToTop.height)];
    [_btnScrollToTop setImage:iScrollToTop forState:UIControlStateNormal];
    _btnScrollToTop.hidden = YES;
    [_btnScrollToTop addTarget:self action:@selector(onClickScrollToTopBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_vMain addSubview:_btnScrollToTop];
    
}

/** 创建新车配置view和数据 */
- (void)initConfigurationView
{
    CGFloat height = 42;
    CGFloat width = _vOptions.width / 4;
    NSInteger row = _configurations.count / 4;
    
    // 创建快捷选项
    for (int i = 0; i < _configurations.count; i++) {
        NSDictionary *dicTemp = [_configurations objectAtIndex:i];
        NSInteger nowSection = i / 4;
        NSInteger nowRow = i % 4;
        // 操作项
        UIButton *btnOption = [[UIButton alloc] initWithFrame:CGRectMake(nowRow * width, height * nowSection, width, height)];
        btnOption.tag = i;
        [btnOption setTitleColor:kColorWhite forState:UIControlStateNormal];
        btnOption.titleLabel.font = [UIFont systemFontOfSize:13];
        btnOption.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btnOption setTitle:[dicTemp objectForKey:@"itemtype"] forState:UIControlStateNormal];
        [btnOption addTarget:self action:@selector(onClickOptionBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnOption addTarget:self action:@selector(onTouchMenuBtnBegin:) forControlEvents:UIControlEventTouchDown];
        [btnOption addTarget:self action:@selector(onTouchMenuBtnEnd:) forControlEvents:UIControlEventTouchDragOutside];
        [btnOption addTarget:self action:@selector(onTouchMenuBtnEnd:) forControlEvents:UIControlEventTouchUpInside];
        [_vOptions addSubview:btnOption];
    }
    _vOptions.height = height * row;
    _vMenu.height = kMenuViewDefaultHeiht + _vOptions.height;
    // 默认打开菜单栏
    _svConfiguration.frame = CGRectMake(0, _vMenu.maxY, _svConfiguration.width, self.height - _vMenu.height);
    _btnMenu.selected = YES;
    
    // 配置参数
    CGFloat minYMain = 0;       // 大块的min
    for (int i = 0; i < _configurations.count; i++) {
        // 存储当前contentOffset
        [_contentOffsets addObject:[NSNumber numberWithFloat:minYMain]];
        // 大块所有数据
        NSDictionary *dicTemp = [_configurations objectAtIndex:i];
        
        // 主视图
        UIView *vMain = [[UIView alloc] initWithFrame:CGRectMake(0, minYMain, _svConfiguration.width, CGFLOAT_MIN)];
        [_svConfiguration addSubview:vMain];
        
        // 标题栏view
        UIView *vTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, vMain.width, 20)];
        vTitle.backgroundColor = kColorNewLine;
        [vMain addSubview:vTitle];
        
        UILabel *labTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(15, 0, vTitle.width - 30, vTitle.height)];
        labTitle.font = kFontLarge;
        labTitle.textColor = kColorNewGray2;
        labTitle.text = [dicTemp objectForKey:@"itemtype"];
        [vTitle addSubview:labTitle];
        labTitle.font = kFontSmall;
        [vTitle addSubview:_btnMenu];
        
        // 大块内容数据
        NSArray *contents = [dicTemp objectForKey:@"items"];
        
        // 内容view
        UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, vTitle.maxY, vMain.width, CGFLOAT_MIN)];
        vContent.backgroundColor = [UIColor whiteColor];
        [vMain addSubview:vContent];
        
        // 小栏目
        CGFloat onceHeight = 0;         // 小块view的高
        CGFloat minYSmallView = 0;      // 小块view的minY
        
        for (int i = 0; i < contents.count; i++) {
            
            CGFloat width = vContent.width / 2; // 一块的宽度
            CGFloat marginTop = 15.0f;          // 上下边距
            CGFloat marginLeft = 15.0f;         // 左右边距
            CGFloat marginBetween = 10.0f;      // 标题和内容间距
            CGFloat nowHeight = 0.0f;           // 当前小块高度
            
            // 每个数据
            NSDictionary *onceData = (NSDictionary *)[contents objectAtIndex:i];
            
            // 标题
            UILabel *labTitle = [[UILabel alloc] init];
            labTitle.origin = CGPointMake(marginLeft, marginTop);
            labTitle.font = [UIFont boldSystemFontOfSize:15];
            labTitle.numberOfLines = 0;
            labTitle.text = [onceData objectForKey:@"name"];
            labTitle.lineBreakMode = NSLineBreakByCharWrapping;
            CGSize titleSize = [labTitle.text sizeWithFont:labTitle.font constrainedToSize:CGSizeMake(width - marginLeft * 2, 200) lineBreakMode:labTitle.lineBreakMode];
            labTitle.size = titleSize;
            labTitle.textColor = kColorNewGray1;
            
            // 内容
            UILabel *labContent = [[UILabel alloc] init];
            labContent.origin = CGPointMake(marginLeft, labTitle.maxY + marginBetween);
            labContent.font = [UIFont fontWithName:@"ArialMT" size:15];
            labContent.numberOfLines = 0;
            labContent.text = [[[onceData objectForKey:@"modelexcessids"] objectAtIndex:0] objectForKey:@"value"];
            labContent.textColor = kColorNewGray2;
            labContent.lineBreakMode = NSLineBreakByCharWrapping;
            CGSize contentSize = [labContent.text sizeWithFont:labContent.font constrainedToSize:CGSizeMake(width - marginLeft * 2, 200) lineBreakMode:labContent.lineBreakMode];
            labContent.size = contentSize;
            
            // 当前小块高度
            nowHeight = marginTop * 2 + titleSize.height + marginBetween + contentSize.height;
            
            // 小块高度取最大值
            onceHeight = i % 2 == 0 ? 0 : onceHeight;
            onceHeight = nowHeight > onceHeight ? nowHeight : onceHeight;
            
            // 一块view
            UIView *vOnceView = [[UIView alloc] initWithFrame:CGRectMake(i % 2 == 0 ? 0 : vContent.width / 2, minYSmallView, width, onceHeight)];
            
            [vContent addSubview:vOnceView];
            [vOnceView addSubview:labTitle];
            [vOnceView addSubview:labContent];
            
            // 刷新小view高度，大view高度，大view minY
            minYSmallView = i % 2 == 0 ? minYSmallView : vOnceView.maxY;
            vContent.height = vOnceView.maxY;
            vMain.height = vContent.maxY;
            minYMain = vMain.maxY;
            _svConfiguration.contentSize = CGSizeMake(_svConfiguration.width, vMain.maxY);
            
            // 下分割线
            if (i % 2 != 0) {
                UIView *vbottomLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, minYSmallView - kLinePixel, vContent.width, kLinePixel) color:kColorNewLine];
                [vContent addSubview:vbottomLine];
            }
            
            // 右分割线
            if (i == contents.count - 1) {
                UIView *vRightLine = [[UIView alloc] initLineWithFrame:CGRectMake(vContent.width / 2 - kLinePixel, 0, kLinePixel, vContent.height) color:kColorNewLine];
                [vContent addSubview:vRightLine];
            }
        }
    }
}

#pragma mark - public Method
/** 获取数据 */
- (void)loadData
{
    // 有数据不处理
    if (_configurations.count > 0) {
        return;
    }
    // 无数据获取
    else {
        [self getNewCarConfigure];
    }
}

#pragma mark - Private Method
/** 是否显示菊花 */
- (void)setShowReloading:(BOOL)isShow
{
    // 显示菊花
    if (isShow) {
        _vMain.hidden = YES;
        if (!_aiActivity ) {
            // 菊花
            _aiActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _aiActivity.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            _aiActivity.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
            [self addSubview:_aiActivity];
            [self sendSubviewToBack:_aiActivity];
            [_aiActivity startAnimating];
        } else {
            [_aiActivity startAnimating];
            _aiActivity.hidden = NO;
        }
    }
    // 隐藏菊花
    else {
        _vMain.hidden = NO;
        [_aiActivity stopAnimating];
        _aiActivity.hidden = YES;
    }
}

/** 是否显示重新加载按钮 */
- (void)setShowReloadButton:(BOOL)isShow
{
    // 显示重新加载按钮
    if (isShow) {
        if (!_btnReload) {
            // 重新加载
            _btnReload = [[UIButton alloc] initWithFrame:_vMain.bounds];
            _btnReload.backgroundColor = kColorWhite;
            _btnReload.titleLabel.font = [UIFont systemFontOfSize:16];
            _btnReload.titleLabel.numberOfLines = 0;
            _btnReload.titleLabel.textAlignment = NSTextAlignmentCenter;
            [_btnReload setTitleColor:kColorGrey2 forState:UIControlStateNormal];
            [_btnReload addTarget:self action:@selector(onClickReloadBtn:) forControlEvents:UIControlEventTouchUpInside];
            _btnReload.hidden = NO;
            [self sendSubviewToBack:_btnReload];
            [self addSubview:_btnReload];
        } else {
            _btnReload.hidden = NO;
        }
    }
    // 隐藏重新加载按钮
    else {
        _btnReload.hidden = YES;
    }
}

- (void)onTouchMenuBtnBegin:(UIButton *)btn
{
    _vOptionBackground.hidden = NO;
    _vOptionBackground.center = btn.center;
}

- (void)onTouchMenuBtnEnd:(UIButton *)btn
{
    _vOptionBackground.hidden = YES;
}

#pragma mark - onClickButton
/** 重新加载 */
- (void)onClickReloadBtn:(UIButton *)btn
{
    [self loadData];
}

/** 点击菜单 */
- (void)onClickMenuBtn:(UIButton *)btn
{
    // 菜单动画
    btn.selected = !btn.selected;
    
    [UIView animateWithDuration:0.3 animations:^{
        _vMenu.height = btn.selected ? kMenuViewDefaultHeiht + _vOptions.height : kMenuViewDefaultHeiht;
        _svConfiguration.frame = CGRectMake(0, _vMenu.maxY, _svConfiguration.width, self.height - _vMenu.height );
    }];
}

/** 快捷选项 */
- (void)onClickOptionBtn:(UIButton *)btn
{
    // 滑到指定位置
    [_svConfiguration setContentOffset:CGPointMake(0, [[_contentOffsets objectAtIndex:btn.tag] floatValue])];
    // 关闭快捷菜单
    [self onClickMenuBtn:_btnMenus];
}

/** 回到顶部 */
- (void)onClickScrollToTopBtn:(UIButton *)btn
{
    BOOL isAnimated = !_btnMenu.selected;
    [_svConfiguration setContentOffset:CGPointMake(0, 0) animated:isAnimated];
    
    // 滑动收回快捷菜单
    if (_btnMenus.selected == YES)
        [self onClickMenuBtn:_btnMenus];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _btnScrollToTop.hidden = scrollView.contentOffset.y > _vMain.height * 2 ? NO : YES;
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 滑动收回快捷菜单
    if (_btnMenus.selected == YES)
        [self onClickMenuBtn:_btnMenus];
}

#pragma mark - APIHelper
/** 获取数据 */
- (void)getNewCarConfigure
{
    // 隐藏重新加载按钮
    [self setShowReloadButton:NO];
    // 显示菊花
    [self setShowReloading:YES];
    
    if (!self.apiHelper)
        self.apiHelper = [[APIHelper alloc] init];
    __weak UCNewCarConfigView *vNewCarConfig = self;
    [self.apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        // 隐藏菊花
        [vNewCarConfig setShowReloading:NO];
        
        if (error) {
            // 非取消请求
            if (error.code != ConnectionStatusCancel) {
                [vNewCarConfig setShowReloadButton:YES];
                [vNewCarConfig.btnReload setTitle:@"网络连接失败\n点击屏幕重新尝试" forState:UIControlStateNormal];
            }
            return;
        }
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    // 总车数
                    NSDictionary *dicCarInfo = mBase.result;
                    // 有值
                    UCNewCarConfigMode *mConfiguration = [[UCNewCarConfigMode alloc] initWithJson:dicCarInfo];
                    vNewCarConfig.configurations = mConfiguration.configurations;
                    if (vNewCarConfig.configurations.count > 0) {
                        // 隐藏菊花
                        [vNewCarConfig setShowReloadButton:NO];
                        // 创建新车配置参数视图
                        [vNewCarConfig initConfigurationView];
                    }
                    // 空值
                    else {
                        [vNewCarConfig setShowReloadButton:YES];
                        [vNewCarConfig.btnReload setTitle:@"未获取到新车配置信息\n点击屏幕重新尝试" forState:UIControlStateNormal];
                    }
                }
                else {
                    [vNewCarConfig setShowReloadButton:YES];
                    [vNewCarConfig.btnReload setTitle:@"网络连接失败\n点击屏幕重新尝试" forState:UIControlStateNormal];
                }
            }
        }
    }];
    [_apiHelper getNewCarConfigure:_mCarDetailInfo.productid];
}

- (void)dealloc
{
    AMLog(@"dealloc...");
    [_apiHelper cancel];
}

@end
