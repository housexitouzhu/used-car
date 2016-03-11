//
//  UCAboutUs.m
//  UsedCar
//
//  Created by wangfaquan on 13-12-7.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCAboutUs.h"
#import "UCTopBar.h"
#import "AppDelegate.h"

#define kDeviceHeight [UIScreen mainScreen].bounds.size.height

@interface UCAboutUs ()

@property (nonatomic, strong) UIImageView *ivIcon;
@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UIButton *btnTitle;
//@property (nonatomic, strong) UIScrollView *svAboutusPic;

@end

@implementation UCAboutUs

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorGrey5;
    
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [_tbTop.btnTitle setTitle:@"关于我们" forState:UIControlStateNormal];
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:
     UIControlEventTouchUpInside];
    
    // 二手车之家图片
    UIImageView *ivAutoHome = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aboutus_icon"]];
    ivAutoHome.center = CGPointMake(self.center.x, self.center.y - 10) ;
    
    // 获取版本号
    UILabel *labVersion = [[UILabel alloc] initWithClearFrame:CGRectMake(0, ivAutoHome.maxY + 10, self.width, 30)];
    NSString *strChannel = [AppDelegate sharedAppDelegate].strChannel;
    labVersion.text = [NSString stringWithFormat:@"V%@",APP_VERSION];
    if ([strChannel isEqualToString:kChannel_Beta] || [strChannel isEqualToString:kChannel_TongCe]) {
        labVersion.text = [NSString stringWithFormat:@"V%@%@",APP_VERSION, APP_BUILD];
    }
    labVersion.font = [UIFont systemFontOfSize:19];
    labVersion.textAlignment = NSTextAlignmentCenter;
    labVersion.textColor = kColorGrey3;
    
    // 版权所有
    UILabel *labCopyright = [[UILabel alloc] init];
    labCopyright.backgroundColor = [UIColor clearColor];
    labCopyright.text = @"二手车之家版权所有";
    labCopyright.textColor = kColorGrey3;
    labCopyright.font = [UIFont systemFontOfSize:13];
    [labCopyright sizeToFit];
    labCopyright.origin = CGPointMake((self.width - labCopyright.width) / 2, self.height - 30);
    
//    // 版本介绍
//    UIButton *btnVersonDescribies = [[UIButton alloc] initWithFrame:CGRectMake(30, _tbTop.maxY + (430 + 63) / 2, 260, 40)];
//    [btnVersonDescribies setTitle:@"版本介绍" forState:UIControlStateNormal];
//    [btnVersonDescribies setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btnVersonDescribies setBackgroundColor:[UIColor colorWithRed:72/255.0 green:210/255.0 blue:86/255.0 alpha:1]];
//    btnVersonDescribies.layer.cornerRadius = 5;
    
//    UIImage *iClick = [UIImage imageNamed:@"aboutus_btn_picture"];
//    
//    _svAboutusPic = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kDeviceHeight - iClick.size.height, self.width, kDeviceHeight + 6)];
//    _svAboutusPic.showsHorizontalScrollIndicator = NO;
//    _svAboutusPic.delegate = self;
    
//    // 图标图片视图
//    UIView *vPopIcon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, iClick.size.height)];
//    
//    // 图标图片
//    _ivIcon = [[UIImageView alloc] initWithImage:iClick];
//    _ivIcon.frame = CGRectMake(vPopIcon.width - iClick.size.width, 0, iClick.size.width, iClick.size.height);
//    _ivIcon.userInteractionEnabled = YES;
//    [vPopIcon addSubview:_ivIcon];
//    [_svAboutusPic addSubview:vPopIcon];
    
//    // 图标图片上面添加手势
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(showAboutUsDetail:)];
//    [vPopIcon addGestureRecognizer:pan];
//    
//    // 添加点击手势
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShowAboutDetail:)];
//    [vPopIcon addGestureRecognizer:tap];
//    tap.numberOfTapsRequired = 1;

//    // 详情图片
//    UIImage *iPicture = [UIImage imageNamed:@"aboutus_picture"];
//    UIImageView *ivAbout = [[UIImageView alloc] initWithImage:iPicture];
//    ivAbout.frame = CGRectMake(0, iClick.size.height - 6, iPicture.size.width, iPicture.size.height);
//    _svAboutusPic.contentSize = CGSizeMake(self.width, ivAbout.size.height + iClick.size.height - 6);
//    [_svAboutusPic addSubview:ivAbout];
    
    [self addSubview:ivAutoHome];
    [self addSubview:labVersion];
    [self addSubview:labCopyright];
//    [self addSubview:btnVersonDescribies];
//    [self addSubview:_svAboutusPic];
    [self addSubview:_tbTop];
    
}

//#pragma mark - show aboutUs Detail
//- (void)showAboutUsDetail:(UIPanGestureRecognizer *)sender
//{
//    // 得到详情页的偏移量
//    CGPoint point = [sender translationInView:_ivIcon];
//    CGRect frame = _svAboutusPic.frame;
//    frame.origin.y = frame.origin.y + point.y;
//    
//    // 通过设置详情页偏移量,改变frame
//    _svAboutusPic.frame = frame;
//    if (sender.state == UIGestureRecognizerStateEnded) {
//        if (frame.origin.y <= kDeviceHeight - kDeviceHeight / 5)
//            frame.origin.y = _tbTop.maxY - _ivIcon.height;
//        else
//            frame.origin.y = kDeviceHeight - _ivIcon.height;
//    }
//    
//    [UIView animateWithDuration:0.2 animations:^{
//        _svAboutusPic.frame = frame;
//    }];
//    
//    _svAboutusPic.scrollEnabled = YES;
//    _svAboutusPic.bounces = YES;
//    
//    // 重设偏移量
//    [sender setTranslation:CGPointZero inView:_ivIcon];
//}

//// 点击手势
//- (void)tapShowAboutDetail:(UITapGestureRecognizer *)sender {
//    if (sender.numberOfTapsRequired == 1) {
//        CGRect frame = _svAboutusPic.frame;
//        frame.origin.y = _tbTop.maxY - _ivIcon.height;
//        [UIView animateWithDuration:0.2 animations:^{
//            _svAboutusPic.frame = frame;
//        }];
//        _svAboutusPic.scrollEnabled = YES;
//        _svAboutusPic.bounces = YES;
//    }
//}

#pragma mark - onClickBtn
/** 点击返回 */
- (void)onClickBackBtn:(UIButton*)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    // scrollview的偏移量
//    CGPoint point = scrollView.contentOffset;
//    if (point.y <= 0)
//        _svAboutusPic.bounces = YES;
//    else
//        _svAboutusPic.bounces = NO;
//    
//    // 临界点
//    if (_svAboutusPic.frame.origin.y >= kDeviceHeight / 5) {
//        _svAboutusPic.frame = CGRectMake(0, kDeviceHeight - _ivIcon.height, self.height, kDeviceHeight + 6);
//        _svAboutusPic.scrollEnabled = NO;
//    } else
//        _svAboutusPic.scrollEnabled = YES;
//    // 判断,如果往下拖动图片,拖动5/1的时候,自动下来
//    if (point.y <= - kDeviceHeight / 5) {
//        [UIView animateWithDuration:0.2 animations:^{
//            _svAboutusPic.frame = CGRectMake(0, kDeviceHeight - _ivIcon.height, self.height, kDeviceHeight + 6);
//        }];
//    }
}

@end
