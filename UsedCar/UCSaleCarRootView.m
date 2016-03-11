//
//  UCSaleCarRootView.m
//  UsedCar
//
//  Created by wangfaquan on 14-3-13.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSaleCarRootView.h"
#import "AMCacheManage.h"
#import "UCSaleCarView.h"
#import "UCMainView.h"
#import "UCTopBar.h"
#import "UCLoginDealerView.h"
#import "UCLoginClientView.h"
#import "InfiniteScrollView.h"

@interface UCSaleCarRootView ()<UCLoginClientViewDelegate, UCLoginDealerViewDelegate>

@property (nonatomic, strong) UIButton *btnBusiness;
@property (nonatomic, strong) UIButton *btnPersonal;
@property (nonatomic) UserStyle userStyle;
@property (nonatomic, strong) InfiniteScrollView *svInfinite;
@property (nonatomic) UCSaleCarRootViewFrom viewType;

@end

@implementation UCSaleCarRootView

#pragma mark  - initView
- (id)initWithFrame:(CGRect)frame fromView:(UCSaleCarRootViewFrom)fromView
{
    self = [super initWithFrame:frame];
    if (self) {
        _viewType = fromView;
        // Initialization code
        [self loadView];
    }
    return self;
}

- (void)loadView
{
    self.backgroundColor = kColorNewBackground;
    _userStyle = [AMCacheManage currentUserType];
    
    [self removeAllSubviews];
    
    UCTopBar *vTopBar = [self creatTopBarView];
    
    /** 轮播图 */
    NSArray *arrGuide;
    if (SCREEN_HEIGHT > 480) {
        arrGuide = @[@"sale_guide_0",@"sale_guide_1",@"sale_guide_2",@"sale_guide_3",@"sale_guide_4"];
    }
    else{
        arrGuide = @[@"sale_guide_0_4",@"sale_guide_1_4",@"sale_guide_2_4",@"sale_guide_3_4",@"sale_guide_4_4"];
    }
    self.svInfinite = [[InfiniteScrollView alloc] initWithFrame:CGRectMake(0, vTopBar.maxY, self.width, self.height - kMainOptionBarHeight - self.height * 1/4 - vTopBar.maxY) withImageNameArray:arrGuide];
    
    
    UIView *vLoginButton = [self creatLoginButtonView:CGRectMake(0, self.height - self.height * 1/4 - (_viewType == UCSaleCarRootViewFromRootView ? kMainOptionBarHeight : 0), self.width, self.height * 1/4)];
    
    [self addSubview:vTopBar];
    [self addSubview:self.svInfinite];
    [self addSubview:vLoginButton];
    
}

- (void)viewDidShow:(BOOL)animated{
    [super viewDidShow:animated];
    
    self.userStyle = [AMCacheManage currentUserType];
    
    if (self.userStyle == UserStyleBusiness) {
        self.btnPersonal.enabled = NO;
    }
    else{
        self.btnPersonal.enabled = YES;
    }
    
    if (self.userStyle == UserStylePersonal) {
        self.btnBusiness.enabled = NO;
    }
    else{
        self.btnBusiness.enabled = YES;
    }
}

#pragma mark - initView
- (UCTopBar *)creatTopBarView
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [vTopBar.btnTitle setTitle:@"卖车" forState:UIControlStateNormal];
    
    if (_viewType == UCSaleCarRootViewFromEvaluationView) {
        [vTopBar setLetfTitle:@"返回"];
        [vTopBar.btnLeft addTarget:self action:@selector(onClickTopBarBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return vTopBar;
}


#pragma mark - onClickButton
- (void)onClickTopBarBtn:(UIButton *)btn
{
    if (btn.tag == UCTopBarButtonLeft) {
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
}

- (void)onClickBtn:(UIButton *)btn
{
    
    // 商家
    if (btn.tag == 0) {
        [UMStatistics event:c_4_0_salecar_businessse];
        if (self.userStyle == UserStyleBusiness) {
            UCSaleCarView *vSaleCar = [[UCSaleCarView alloc] initWithFrame:[UCMainView sharedMainView].bounds carInfoEdit:nil];
            vSaleCar.delegate = self;
            [[MainViewController sharedVCMain] openView:vSaleCar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
        else{
            UCLoginDealerView *vLoginDealer = [[UCLoginDealerView alloc] initWithFrame:[UCMainView sharedMainView].bounds];
            vLoginDealer.delegate = self;
            [[MainViewController sharedVCMain] openView:vLoginDealer animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
        }
    }
    // 个人
    else if (btn.tag == 1) {
        [UMStatistics event:c_4_0_salecar_peronal];
        if (self.userStyle == UserStylePersonal) {
            UCSaleCarView *vSaleCar = [[UCSaleCarView alloc] initWithFrame:[UCMainView sharedMainView].bounds carInfoEdit:nil];
            vSaleCar.delegate = self;
            [[MainViewController sharedVCMain] openView:vSaleCar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
        else{
            UCLoginClientView *vLoginClient = [[UCLoginClientView alloc] initWithFrame:[UCMainView sharedMainView].bounds loginType:UCLoginClientTypeSaleCar];
            vLoginClient.delegate = self;
            [[MainViewController sharedVCMain] openView:vLoginClient animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
        }
        
    }
}

- (UIView *)creatLoginButtonView:(CGRect)frame
{
    UIView *vLoginButton = [[UIView alloc] initWithFrame:frame];
    vLoginButton.backgroundColor = kColorWhite;
    
    NSArray *titles = @[@"商家卖车", @"个人卖车"];
    NSArray *image_n = @[@"sale_businesses", @"sale_i"];
    NSArray *image_h = @[@"sale_businesses_pre", @"sale_i_pre"];
    NSArray *image_d = @[@"sale_businesses_notpre", @"sale_i_notpre"];
    CGFloat minX = 0;
    
    self.btnBusiness = [[UIButton alloc] initWithFrame:CGRectMake(minX, 0, frame.size.width / 2, frame.size.height)];
    self.btnBusiness.tag = 0;
    [self.btnBusiness setTitle:titles[0] forState:UIControlStateNormal];
    [self.btnBusiness setTitleColor:kColorBlue forState:UIControlStateNormal];
    self.btnBusiness.titleLabel.font = kFontLarge1;
    [self.btnBusiness setImage:[UIImage imageNamed:image_n[0]] forState:UIControlStateNormal];
    [self.btnBusiness setImage:[UIImage imageNamed:image_h[0]] forState:UIControlStateHighlighted];
    [self.btnBusiness setImage:[UIImage imageNamed:image_d[0]] forState:UIControlStateDisabled];
    [self.btnBusiness setTitleEdgeInsets:UIEdgeInsetsMake(92.0,-self.btnBusiness.imageView.image.size.width, 0.0,0.0)];
    [self.btnBusiness setImageEdgeInsets:UIEdgeInsetsMake(-26, 0.0,0.0, -self.btnBusiness.titleLabel.bounds.size.width)];
    [self.btnBusiness addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [vLoginButton addSubview:self.btnBusiness];
    
    
    minX += self.btnBusiness.width;
    self.btnPersonal = [[UIButton alloc] initWithFrame:CGRectMake(minX, 0, frame.size.width / 2, frame.size.height)];
    self.btnPersonal.tag = 1;
    [self.btnPersonal setTitle:titles[1] forState:UIControlStateNormal];
    [self.btnPersonal setTitleColor:kColorBlue forState:UIControlStateNormal];
    self.btnPersonal.titleLabel.font = kFontLarge1;
    [self.btnPersonal setImage:[UIImage imageNamed:image_n[1]] forState:UIControlStateNormal];
    [self.btnPersonal setImage:[UIImage imageNamed:image_h[1]] forState:UIControlStateHighlighted];
    [self.btnPersonal setImage:[UIImage imageNamed:image_d[1]] forState:UIControlStateDisabled];
    [self.btnPersonal setTitleEdgeInsets:UIEdgeInsetsMake(92.0,-self.btnPersonal.imageView.image.size.width, 0.0,0.0)];
    [self.btnPersonal setImageEdgeInsets:UIEdgeInsetsMake(-26, 0.0,0.0, -self.btnPersonal.titleLabel.bounds.size.width)];
    [self.btnPersonal addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [vLoginButton addSubview:self.btnPersonal];
    
    
    [vLoginButton addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(self.btnBusiness.width, (vLoginButton.height - 100) / 2, kLinePixel, 100) color:kColorNewLine]];
    
    return vLoginButton;
}

#pragma mark - UCLoginClientViewDelegate
/** 个人登录 */
- (void)UCLoginClientView:(UCLoginClientView *)vLoginClient loginSuccess:(BOOL)success NeedSNYC:(BOOL)needSYNC SYNCSuccess:(BOOL)SYNCSuccess{
    if (success) {
        if (_viewType == UCSaleCarRootViewFromEvaluationView) {
            if ([self.delegate respondsToSelector:@selector(UCSaleCarRootViewDidSelectedUserType:)]) {
                [self.delegate UCSaleCarRootViewDidSelectedUserType:self];
            }
        } else {
            [[MainViewController sharedVCMain] closeView:vLoginClient animateOption:AnimateOptionMoveNone];
            UCSaleCarView *vSaleCar = [[UCSaleCarView alloc] initWithFrame:[UCMainView sharedMainView].bounds carInfoEdit:nil];
            vSaleCar.delegate = (_viewType == UCSaleCarRootViewFromEvaluationView) ? self.delegate : self;
            [[MainViewController sharedVCMain] openView:vSaleCar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
    }
}

/** 快速发车 */
- (void)UCLoginClientViewExpressSaleCar:(UCLoginClientView *)vLoginClient{
    if (_viewType == UCSaleCarRootViewFromEvaluationView) {
        if ([self.delegate respondsToSelector:@selector(UCSaleCarRootViewDidSelectedUserType:)]) {
            [self.delegate UCSaleCarRootViewDidSelectedUserType:self];
        }
    } else {
        [[MainViewController sharedVCMain] closeView:vLoginClient animateOption:AnimateOptionMoveNone];
        UCSaleCarView *vSaleCar = [[UCSaleCarView alloc] initWithFrame:[UCMainView sharedMainView].bounds carInfoEdit:nil];
        vSaleCar.delegate = (_viewType == UCSaleCarRootViewFromEvaluationView) ? self.delegate : self;
        [[MainViewController sharedVCMain] openView:vSaleCar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
    
}

-(void)UCLoginClientView:(UCLoginClientView *)vLoginClient onClickLoginButton:(UIButton *)btnLogin
{
    [UMStatistics event:c_4_0_salecar_peronal_login];
}

#pragma mark - UCLoginDealerViewDelegate
/** 商家登录 */
- (void)UCLoginDealerView:(UCLoginDealerView*)vLoginDealer loginSuccess:(BOOL)success{
    if (success) {
        if (_viewType == UCSaleCarRootViewFromEvaluationView) {
            if ([self.delegate respondsToSelector:@selector(UCSaleCarRootViewDidSelectedUserType:)]) {
                [self.delegate UCSaleCarRootViewDidSelectedUserType:self];
            }
        } else {
            [[MainViewController sharedVCMain] closeView:vLoginDealer animateOption:AnimateOptionMoveNone];
            UCSaleCarView *vSaleCar = [[UCSaleCarView alloc] initWithFrame:[UCMainView sharedMainView].bounds carInfoEdit:nil];
            vSaleCar.delegate = (_viewType == UCSaleCarRootViewFromEvaluationView) ? self.delegate : self;
            [[MainViewController sharedVCMain] openView:vSaleCar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
    }
}

#pragma mark - UCReleaseSucceedViewDelegate
- (void)didSelectedReleaseAgain:(UCReleaseSucceedView *)vReleaseSuccessed
{
    // 非修改车面再发一辆
    if (vReleaseSuccessed.viewType == FromViewTypeSaleCar)
        [UMStatistics event:vReleaseSuccessed.isBusiness ? c_3_1_buinesssuccessfultosend : c_3_1_personsuccessfultosend];
    
    UCSaleCarView *vSaleCar = [[UCSaleCarView alloc] initWithFrame:self.bounds carInfoEdit:nil];
    vSaleCar.delegate = self;
    [[MainViewController sharedVCMain] openView:vSaleCar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionPrevious];
}



@end
