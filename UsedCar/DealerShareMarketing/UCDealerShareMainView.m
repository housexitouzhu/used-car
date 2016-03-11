//
//  UCDealerShareMainView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-10-13.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCDealerShareMainView.h"
#import "UCTopBar.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialData.h"
#import "WXApi.h"
#import "APIHelper.h"
#import "AMCacheManage.h"
#import "QRCodeGenerator.h"
#import "UCDealerShareHistory.h"
#import "UCDealerShareCarView.h"
#import "UCSNSHelper.h"

@interface UCDealerShareMainView ()<UCSNSHelperDelegate>

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UIScrollView *vScroll;
@property (nonatomic, strong) UIImageView *ivQRcode;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *shareImageURL;
@property (nonatomic, strong) NSString *shareURL;

@property (nonatomic, strong) NSNumber *dealerID;
@property (nonatomic, strong) NSNumber *shareID;

@property (nonatomic, strong) APIHelper *imageUrlHelper;
@property (nonatomic, strong) APIHelper *shareUrlHelper;
@property (nonatomic, strong) APIHelper *updateShareHelper;
@property (nonatomic, assign) SNSChannelType channelType;

@property (nonatomic, strong) UCSNSHelper *snsHelper;

@end

@implementation UCDealerShareMainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [UMSAgent postEvent:buiness_share_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:[AMCacheManage currentUserInfo].userid, @"dealerid#5", nil]];
        [self initView];
        
        if ([AMCacheManage currentUserInfo].dealerid) {
            self.dealerID = [AMCacheManage currentUserInfo].dealerid;
            [self generateQRCode];
        }
        else{
            [self getDealerStoreInfoForShare:NO];
        }
        
        
    }
    return self;
}

- (void)initView{
    
    [UMStatistics event:pv_4_1_buiness_share];
    self.backgroundColor =  kColorNewBackground;
    self.tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:self.tbTop];
    
    self.vScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.tbTop.maxY, self.width, self.height - self.tbTop.height)];
    self.vScroll.backgroundColor = kColorClear;
    self.vScroll.showsVerticalScrollIndicator = NO;
    self.vScroll.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.vScroll];
    
    //创建顶部二维码视图区域
    UIView *vTopSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 263)];
    vTopSection.backgroundColor = kColorClear;
    
    self.ivQRcode = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - 155)/2, 40, 155, 155)];
    [self.ivQRcode setBackgroundColor:kColorWhite];
    [self.ivQRcode setImage:[UIImage imageNamed:@"failedtoload"]];
    [vTopSection addSubview:self.ivQRcode];
    
    UILabel *labIntro = [[UILabel alloc] initWithFrame:CGRectMake(0, self.ivQRcode.maxY+15, self.width, 14)];
    labIntro.font = kFontNormal;
    labIntro.textColor = kColorNewGray2;
    labIntro.textAlignment = NSTextAlignmentCenter;
    labIntro.backgroundColor = kColorClear;
    labIntro.text = @"手机扫描二维码快速浏览店铺信息";
    [vTopSection addSubview:labIntro];
    
    [self.vScroll addSubview:vTopSection];
    
    UIView *btnSection = [self createButtonList:CGPointMake(0, 263) titles:@[@"店铺分享",@"车源分享",@"分享记录"]];
    [self.vScroll addSubview:btnSection];
    
    self.vScroll.contentSize = CGSizeMake(self.width, btnSection.maxY);
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"分享营销" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

/** 创建列表按钮 */
- (UIView *)createButtonList:(CGPoint)point titles:(NSArray*)titles{
    UIView *vSection = [[UIView alloc] initWithFrame:CGRectZero];
    vSection.backgroundColor = kColorWhite;
    
    UIView *hLineT = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine];
    [vSection addSubview:hLineT];
    
    for (int i = 0; i < titles.count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, i*kLineButtonHeight + kLinePixel*(i+1), self.width, kLineButtonHeight);
        btn.backgroundColor = kColorWhite;
        [btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
        [btn.titleLabel setFont:kFontLarge];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn setBackgroundImage:[OMG imageWithColor:kColorGrey5 andSize:btn.frame.size] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(onClickBtnItem:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [vSection addSubview:btn];
        
        // 箭头
        UIImageView * arrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 33, 14, 18, 18)];
        arrow.image = [UIImage imageNamed:@"set_arrow_right"];
        [btn addSubview:arrow];
        
        if (i == titles.count - 1) {
            //最后一条通长的横线
            UIView *hLineB = [[UIView alloc] initLineWithFrame:CGRectMake(0, btn.maxY, self.width, kLinePixel) color:kColorNewLine];
            [vSection addSubview:hLineB];
        }
        else{
            UIView *hLine = [[UIView alloc] initLineWithFrame:CGRectMake(15, btn.maxY, self.width - 15, kLinePixel) color:kColorNewLine];
            [vSection addSubview:hLine];
        }
    }
    
    CGFloat secHeight = kLinePixel*2 + kLineButtonHeight*titles.count + kLinePixel*(kLinePixel*titles.count-1);
    vSection.frame = CGRectMake(point.x, point.y, self.width, secHeight);
    
    return vSection;
}

- (void)generateQRCode{
    
    NSString *dealerURL = [[APIHelper getShareDealerStore] stringByAppendingString:self.dealerID.stringValue];
//    [NSString stringWithFormat:@"%@%@", kShareURL_DealerStore ,self.dealerID.stringValue];
    
    UIImage *qrImage = [QRCodeGenerator qrImageForString:dealerURL imageSize:self.ivQRcode.size.width];
    
    [self.ivQRcode setImage:qrImage];
}

#pragma mark - button actions
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

- (void)onClickBtnItem:(UIButton*)btn{
    
    switch (btn.tag) {
        case 0:
        {
            if (![OMG isValidClick])
                return;
            
            [UMStatistics event:c_4_1_buiness_share_shopshare];
            [self shareDealerStore];
        }
            break;
        case 1:
        {
            if (![OMG isValidClick])
                return;
            
            [UMStatistics event:c_4_1_buiness_share_carshare];
            UCDealerShareCarView *vShareCar = [[UCDealerShareCarView alloc] initWithFrame:self.bounds];
            [[MainViewController sharedVCMain] openView:vShareCar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
        case 2:
        {
            if (![OMG isValidClick])
                return;
            
            [UMStatistics event:c_4_1_buiness_share_history];
            UCDealerShareHistory *vShareHistory = [[UCDealerShareHistory alloc] initWithFrame:self.bounds];
            [[MainViewController sharedVCMain] openView:vShareHistory animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
        default:
            break;
    }
    
}



#pragma mark - 分享
- (void)shareDealerStore{
    
    self.title = [AMCacheManage currentUserInfo].username;
    self.content = [self.title stringByAppendingString:@"，二手车之家推荐商家 #二手车之家# "];
    
    //每次都要获取 share url, share id
    [self getDealerStoreShareURL];
    
}

- (void)openShareView{
    
    if (!self.snsHelper) {
        self.snsHelper = [[UCSNSHelper alloc] init];
    }
    self.snsHelper.delegate = self;
    
    self.snsHelper.title = self.title;
    self.snsHelper.content = [self.content stringByAppendingString: self.shareURL];
    self.snsHelper.contentNoURL = self.content;
    self.snsHelper.contentWeChat = [self.title stringByAppendingString:@"，欢迎随时到店了解优质车源信息"];
    self.snsHelper.shareURL = self.shareURL;
    
    if (self.shareImageURL.length > 0) {
        self.snsHelper.imageURL = self.shareImageURL;
    }
    else{
        self.snsHelper.imageShareIcon = [UIImage imageNamed:@"failedtoload"];
    }
    
    [self.snsHelper openShareViewForAllPlatform:YES];
}

#pragma mark - UCSNSHelperDelegate
- (void)UCSNSHelper:(UCSNSHelper*)helper shareSuccessWithChannelType:(SNSChannelType)channelType{
    self.channelType = channelType;
    [self updateDealerShareStoreInfo];
}


#pragma mark - 取商家图片 URL

/**
 *  @brief  获取商家信息, 主要是验证 id 和 获取 logo 的 url
 *
 *  @param forShare 是否是用来 share 的, yes 获取 logo, no 验证更新 user info model
 */
- (void)getDealerStoreInfoForShare:(BOOL)forShare{
    
    [[AMToastView toastView] showLoading:@"数据加载中" cancel:nil];
    
    if (!self.imageUrlHelper) {
        self.imageUrlHelper = [[APIHelper alloc] init];
    }
    
    __weak UCDealerShareMainView *weakSelf = self;
    [self.imageUrlHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
            if (forShare) {
                [weakSelf openShareView];
            }
            
            return;
        }
        
        [[AMToastView toastView] hide];
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase.returncode == 0) {
                UserInfoModel *mUserNew = [[UserInfoModel alloc] initWithJson:mBase.result];
                weakSelf.shareImageURL = mUserNew.logo;
                
                if (!forShare) {
                    
                    weakSelf.dealerID = mUserNew.dealerid;
                    
                    UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
                    if (mUserInfo) {
                        if (mUserNew.userid) mUserInfo.userid                   = mUserNew.userid;
                        if (mUserNew.username) mUserInfo.username               = mUserNew.username;
                        if (mUserNew.mobile) mUserInfo.mobile                   = mUserNew.mobile;
                        if (mUserNew.carnotpassed) mUserInfo.carnotpassed       = mUserNew.carnotpassed;
                        if (mUserNew.carsaleing) mUserInfo.carsaleing           = mUserNew.carsaleing;
                        if (mUserNew.type) mUserInfo.type                       = mUserNew.type;
                        if (mUserNew.salespersonlist) mUserInfo.salespersonlist = mUserNew.salespersonlist;
                        if (mUserNew.bdpmstatue) mUserInfo.bdpmstatue           = mUserNew.bdpmstatue;
                        if (mUserNew.carinvalid) mUserInfo.carinvalid           = mUserNew.carinvalid;
                        if (mUserNew.isbailcar) mUserInfo.isbailcar             = mUserNew.isbailcar;
                        if (mUserNew.carsaled) mUserInfo.carsaled               = mUserNew.carsaled;
                        if (mUserNew.carchecking) mUserInfo.carchecking         = mUserNew.carchecking;
                        if (mUserNew.code) mUserInfo.code                       = mUserNew.code;
                        if (mUserNew.dealerid) mUserInfo.dealerid               = mUserNew.dealerid;
                        [AMCacheManage setCurrentUserInfo:mUserInfo];
                    } else {
                        [AMCacheManage setCurrentUserInfo:mUserNew];
                    }
                    [weakSelf generateQRCode];
                }
                
            }
        }
        
        if (forShare) {
            [weakSelf openShareView];
        }
        
    }];
    
    [self.imageUrlHelper getUserInfo];
}

/**
 *  @brief  获取店铺分享的 URL
 */
- (void)getDealerStoreShareURL{
    
    [[AMToastView toastView] showLoading:@"数据加载中" cancel:nil];
    
    if (!self.shareUrlHelper) {
        self.shareUrlHelper = [[APIHelper alloc] init];
    }
    
    __weak UCDealerShareMainView *weakSelf = self;
    [self.shareUrlHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        
        if (error) {
            [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
            return ;
        }
        
        if (apiHelper.data.length > 0) {
            
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase.returncode == 0) {
                weakSelf.shareURL = [mBase.result objectForKey:@"shareurl"];
                weakSelf.shareID = [mBase.result objectForKey:@"shareid"];
                
                if (!weakSelf.shareImageURL){
                    [weakSelf getDealerStoreInfoForShare:YES];
                }
                else{
                    [[AMToastView toastView] hide];
                    [weakSelf openShareView];
                }
            }
            else{
                if (mBase.message) {
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                }
                else{
                    [[AMToastView toastView] hide];
                }
            }
        }
        else{
            [[AMToastView toastView] hide];
        }
        
    }];
    
    [self.shareUrlHelper addDealerShare:DealerShareTypeStore title:self.title content:self.content carids:nil];
}

- (void)updateDealerShareStoreInfo{
    
    if (!self.updateShareHelper) {
        self.updateShareHelper = [[APIHelper alloc] init];
    }
    
//    __weak UCDealerShareMainView *weakSelf = self;
    [self.updateShareHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            return ;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase.returncode == 0) {
                
            }
        }
        
    }];
    
    [self.updateShareHelper updateDealerShareWithShareid:self.shareID channelType:self.channelType];
    
}

@end
