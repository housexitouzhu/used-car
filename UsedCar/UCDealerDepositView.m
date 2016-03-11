//
//  UCDealerDepositView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-8-7.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCDealerDepositView.h"
#import "UCTopBar.h"
#import "CoreTextView.h"
#import "UIImage+Util.h"
#import "JSBadgeView.h"
#import "UCDepositDetailView.h"
#import "UCClaimRecordView.h"
#import "APIHelper.h"
#import "AMCacheManage.h"
#import "UCDealerDepositModel.h"
#import "UCMainView.h"
#import "UCContactUsView.h"

@interface UCDealerDepositView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (retain, nonatomic) UIScrollView *vScroll;
@property (retain, nonatomic) UIView *vInfo;
@property (retain, nonatomic) JSBadgeView *vClaimBadge;
@property (retain, nonatomic) UILabel *labPayment; //保证金金额
@property (retain, nonatomic) UILabel *labBalance; //保证金余额
@property (retain, nonatomic) UILabel *labDueValue; //到期时间
@property (nonatomic, strong) UILabel *labStatusValue; //保证金状态
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *dueLabel;
@property (nonatomic, strong) UIView *hLine3;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIButton *btnClaim;
@property (retain, nonatomic) CoreTextView *vDesc;
@property (nonatomic, assign) NSInteger *claimCount;

@property (nonatomic, strong) APIHelper *apiHelper;
@end

@implementation UCDealerDepositView

- (id)initWithFrame:(CGRect)frame claimCount:(NSInteger *)claimCount
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _claimCount = claimCount;
        [self initView];
        [self getDealerDepositInfo];
        [UMStatistics event:pv_3_9_2_buiness_bond];
        if ([AMCacheManage currentUserType] == UserStyleBusiness) {
            UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
            [UMSAgent postEvent:buiness_bond_pv page_name:NSStringFromClass(self.class)
                     eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 mUserInfo.userid, @"userid#4", nil]];
        } else {
            [UMSAgent postEvent:buiness_bond_pv page_name:NSStringFromClass(self.class)];
        }
    }
    return self;
}

- (void)viewWillShow:(BOOL)animated{
    [super viewWillShow:animated];
    
    if (*_claimCount > 0) {
        _vClaimBadge.badgeText = [NSString stringWithFormat:@"%d", *_claimCount];
    }
    else{
        _vClaimBadge.badgeText = nil;
    }
}

- (void)initView{
    
    self.backgroundColor =  kColorNewBackground;
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    [self addSubview:_tbTop];
    
    _vScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height-86)];
    _vScroll.backgroundColor = [UIColor clearColor];
    [self addSubview:_vScroll];
    
    UCContactUsView *vContactUs = [[UCContactUsView alloc] initWithFrame:CGRectMake(0, self.height-86, self.width, 86) withStatementArray:@[@"索赔联系方式：", @"010-59857692 \\ QQ 2843157669", @"您在索赔中有任何问题可联系"] andPhoneNumber:@"01059857692"];
    [self addSubview:vContactUs];
    
    _vInfo = [self createDealerInfoView:nil];
    [_vScroll addSubview:_vInfo];
    
    UIView *hLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, _vInfo.maxY+20, self.width, kLinePixel) color:kColorNewLine];
    [_vScroll addSubview:hLine];
    
    UIButton *btnDeposit= [[UIButton alloc] initWithFrame:CGRectMake(0, hLine.maxY, self.width, 50)];
    [btnDeposit setTitle:@"保证金明细" forState:UIControlStateNormal];
    [btnDeposit setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
    btnDeposit.backgroundColor = kColorWhite;
    btnDeposit.titleLabel.font = [UIFont systemFontOfSize:15];
    btnDeposit.titleEdgeInsets = UIEdgeInsetsMake(0, 22, 0,0);
    btnDeposit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnDeposit addTarget:self action:@selector(onClickDepositBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btnDeposit setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnDeposit.size] forState:UIControlStateHighlighted];
    [_vScroll addSubview:btnDeposit];
    
    // 箭头
    UIImageView * arrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 36, 16.5, 18, 18)];
    arrow.image = [UIImage imageNamed:@"set_arrow_right"];
    [btnDeposit addSubview:arrow];
    
    UIView *hLine2 = [[UIView alloc] initLineWithFrame:CGRectMake(0, btnDeposit.maxY, self.width, kLinePixel) color:kColorNewLine];
    [_vScroll addSubview:hLine2];
    
    
    self.btnClaim= [[UIButton alloc] initWithFrame:CGRectMake(0, hLine2.maxY, self.width, 50)];
    [self.btnClaim setTitle:@"车源投诉记录" forState:UIControlStateNormal];
    [self.btnClaim setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
    self.btnClaim.backgroundColor = kColorWhite;
    self.btnClaim.titleLabel.font = [UIFont systemFontOfSize:15];
    self.btnClaim.titleEdgeInsets = UIEdgeInsetsMake(0, 22, 0,0);
    self.btnClaim.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.btnClaim addTarget:self action:@selector(onClickClaimBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnClaim setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:self.btnClaim.size] forState:UIControlStateHighlighted];
    [_vScroll addSubview:self.btnClaim];
    
    // 箭头
    UIImageView * arrow2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 36, 16.5, 18, 18)];
    arrow2.image = [UIImage imageNamed:@"set_arrow_right"];
    [self.btnClaim addSubview:arrow2];
    
    _vClaimBadge = [[JSBadgeView alloc] initWithParentView:self.btnClaim alignment:JSBadgeViewAlignmentCenter];
    _vClaimBadge.userInteractionEnabled = NO;
    _vClaimBadge.badgePositionAdjustment = CGPointMake(+100, 0);
    if (*_claimCount > 0) {
        _vClaimBadge.badgeText = [NSString stringWithFormat:@"%d", *_claimCount];
    }
    else{
        _vClaimBadge.badgeText = nil;
    }
    
    UIView *hLine3 = [[UIView alloc] initLineWithFrame:CGRectMake(0, self.btnClaim.maxY, self.width, kLinePixel) color:kColorNewLine];
    [_vScroll addSubview:hLine3];
    
    [_vScroll setContentSize:CGSizeMake(self.width, hLine3.maxY)];
    
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"保证金" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

/** 创建商家信息块 **/
- (UIView *)createDealerInfoView:(id)dealerModel{
    
    self.bgView = [[UIView alloc] init];
    [self.bgView setBackgroundColor:kColorWhite];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.width-40, 50)];
    [titleLabel setNumberOfLines:2];
    [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [titleLabel setTextColor:kColorNewGray1];
    [titleLabel setFont:kFontLarge];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:[AMCacheManage currentUserInfo].username];  //@"北京左姐航二手车交易有限公司北京左姐航二手车交易有限公司"];
    
    UIView *hLine = [[UIView alloc] initLineWithFrame:CGRectMake(22, titleLabel.maxY, self.width - 22 * 2, kLinePixel) color:kColorNewLine];
    
    // 缴纳的价格
    UIView *vPayment = [[UIView alloc] initWithFrame:CGRectMake(22, hLine.maxY, self.width / 2 - 22, 77.5)];
    [vPayment setBackgroundColor:kColorClear];
    
    //保证金金额
    _labPayment = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, vPayment.width, 20)];
    _labPayment.backgroundColor = kColorClear;
    _labPayment.font = kFontSuper;
    _labPayment.textColor = kColorNewOrange;
    _labPayment.textAlignment = NSTextAlignmentCenter;
    _labPayment.text = @"--元";
    [vPayment addSubview:_labPayment];
    
    // 缴纳保证金文字
    UILabel *labPayTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, _labPayment.maxY + 5, vPayment.width, 16)];
    labPayTitle.backgroundColor = kColorClear;
    labPayTitle.font = kFontLarge;
    labPayTitle.textColor = kColorNewGray1;
    labPayTitle.textAlignment = NSTextAlignmentCenter;
    labPayTitle.text = @"缴纳保证金";
    [vPayment addSubview:labPayTitle];
    
    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(vPayment.maxX, titleLabel.maxY + 18, 1, 41) color:kColorNewLine];
    
    UIView *vBalance = [[UIView alloc] initWithFrame:CGRectMake(vLine.maxX, hLine.maxY, 138, 77.5)];
    [vBalance setBackgroundColor:kColorClear];
    
    //保证金余额
    _labBalance = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, vPayment.width, 20)];
    _labBalance.backgroundColor = kColorClear;
    _labBalance.font = kFontSuper;
    _labBalance.textColor = kColorNewOrange;
    _labBalance.textAlignment = NSTextAlignmentCenter;
    _labBalance.text = @"--元";
    [vBalance addSubview:_labBalance];
    
    // 保证金余额文字
    UILabel *labBalanceTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, _labBalance.maxY + 5, vPayment.width, 16)];
    labBalanceTitle.backgroundColor = kColorClear;
    labBalanceTitle.font = kFontLarge;
    labBalanceTitle.textColor = kColorNewGray1;
    labBalanceTitle.textAlignment = NSTextAlignmentCenter;
    labBalanceTitle.text = @"保证金余额";
    [vBalance addSubview:labBalanceTitle];
    
    
    UIView *hLine2 = [[UIView alloc] initLineWithFrame:CGRectMake(22, vBalance.maxY, self.width - 22 * 2, kLinePixel) color:kColorNewLine];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.5, hLine2.maxY + 13.5, 72, 14)];
    [self.statusLabel setText:@"保证金状态："];
    [self.statusLabel setFont:kFontSmall];
    [self.statusLabel setTextColor:kColorNewGray1];
    
    self.labStatusValue = [[UILabel alloc] initWithFrame:CGRectMake(self.statusLabel.maxX, self.statusLabel.origin.y, self.width/2-self.statusLabel.width - 22, self.statusLabel.height )];
    self.labStatusValue.text = @"--";
    [self.labStatusValue setTextAlignment:NSTextAlignmentCenter];
    
    _dueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width/2 + 10, self.statusLabel.origin.y, 60, 14)];
    [_dueLabel setText:@"到期时间："];
    [_dueLabel setFont:kFontSmall];
    [_dueLabel setTextColor:kColorNewGray1];
    
    self.labDueValue = [[UILabel alloc] initWithFrame:CGRectMake(_dueLabel.maxX, self.statusLabel.origin.y, self.width-22-_dueLabel.maxX, 14)];
    [self.labDueValue setFont:kFontSmallBold];
    [self.labDueValue setTextColor:kColorNewGray1];
    self.labDueValue.text = @"--";
    
    _vDesc = [[CoreTextView alloc] initWithFrame:CGRectMake(20, self.statusLabel.maxY + 7.5, self.width-40,  12)];
    [_vDesc setBackgroundColor:kColorClear];
    
    
    self.hLine3 = [[UIView alloc] initLineWithFrame:CGRectMake(0, _vDesc.maxY+15, self.width, kLinePixel) color:kColorNewLine];
    
    [self.bgView setFrame:CGRectMake(0, 0, self.width, self.hLine3.maxY)];
    
    [self.bgView addSubview:titleLabel];
    [self.bgView addSubview:hLine];
    [self.bgView addSubview:vPayment];
    [self.bgView addSubview:vLine];
    [self.bgView addSubview:vBalance];
    [self.bgView addSubview:hLine2];
    [self.bgView addSubview:self.statusLabel];
    [self.bgView addSubview:self.labStatusValue];
    [self.bgView addSubview:_dueLabel];
    [self.bgView addSubview:self.labDueValue];
    [self.bgView addSubview:_vDesc];
    [self.bgView addSubview:self.hLine3];
    
    
    return self.bgView;
}


#pragma mark - onClickButton

- (void)onClickDepositBtn:(id)sender{
    if (![OMG isValidClick])
        return;
    
    [UMStatistics event:c_3_9_2_buiness_bond_detailed];

    if ([AMCacheManage currentUserType] == UserStyleBusiness) {
        UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
        [UMSAgent postEvent:buiness_bond_detailed_pv page_name:NSStringFromClass(self.class)
                 eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             mUserInfo.userid, @"userid#4", nil]];
    } else {
        [UMSAgent postEvent:buiness_bond_detailed_pv page_name:NSStringFromClass(self.class)];
    }
    UCDepositDetailView *depositDetail = [[UCDepositDetailView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds];
    [[MainViewController sharedVCMain] openView:depositDetail animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    
}

- (void)onClickClaimBtn:(id)sender{
    
    if (![OMG isValidClick])
        return;
    
    [UMStatistics event:c_3_9_2_buiness_bond_complaint];
    if ([AMCacheManage currentUserType] == UserStyleBusiness) {
        UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
        [UMSAgent postEvent:buiness_bond_complaint_unfinished_pv page_name:NSStringFromClass(self.class)
                 eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             mUserInfo.userid, @"userid#4", nil]];
    } else {
        [UMSAgent postEvent:buiness_bond_complaint_unfinished_pv page_name:NSStringFromClass(self.class)];
    }
    *_claimCount = 0;
    _vClaimBadge.badgeText = nil;
    
    
    //车源投诉记录返回接口只是未处理
    UCClaimRecordView *vClaimRecord = [[UCClaimRecordView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds withStyle:UCClaimRecordViewStyleNormal ClaimType:ClaimListTypeOnGoing];
    [[MainViewController sharedVCMain] openView:vClaimRecord animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}


/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

#pragma mark - 设置保证金状态
- (void)setStatusLabelWithModel:(UCDealerDepositModel*)mDeposit{
    
    switch (mDeposit.bstatue.integerValue) {
        case 1:
        {
            [self.labStatusValue setTextColor:kColorNeWGreen];
            [self.labStatusValue setFont:kFontSmall];
            [self.labStatusValue setText:mDeposit.bstatuename];
        }
            break;
        default:
        {
            [self.labStatusValue setTextColor:kColorNeWRed];
            [self.labStatusValue setFont:kFontSmall];
            [self.labStatusValue setText:mDeposit.bstatuename];
        }
            break;
    }
    
}

- (void)setDescLabelWithInterval:(NSInteger)interval{
    
    NSString *html = [NSString stringWithFormat:@"<span size='10' color='rgba(144,154,171,1)' align='center'>保证金将会在<span color='rgba(250,140,0,1)'>%d天</span>后到期,请注意续约,否则将失去相关特权</span>", interval];
    _vDesc.attributedString = [NSAttributedString attributedStringWithHTML:html ];
    CGFloat vdescHeight = [_vDesc sizeThatFits:CGSizeMake(self.width-40, 12)].height;
    [_vDesc setFrame:CGRectMake(22, self.statusLabel.maxY + 7.5, self.width-44,  vdescHeight)];
    
    [self.hLine3 setFrame:CGRectMake(0, _vDesc.maxY+15, self.width, kLinePixel)];
    [self.bgView setFrame:CGRectMake(0, 0, self.width, self.hLine3.maxY)];
    [_vScroll setContentSize:CGSizeMake(self.width, self.btnClaim.maxY+kLinePixel)];
    
    [_labDueValue sizeToFit];
    CGFloat margin = ((self.width - _labDueValue.maxX) - _statusLabel.minX) / 2;
    _statusLabel.minX += margin;
    [_labStatusValue sizeToFit];
    _labStatusValue.minX = _statusLabel.maxX;
    _dueLabel.minX += margin;
    _labDueValue.minX = _dueLabel.maxX;
}

#pragma mark - 获取详细信息
- (void)getDealerDepositInfo{
    if (!_apiHelper) {
        _apiHelper = [[APIHelper alloc] init];
    }
    
    __weak typeof(self) weakSelf = self;
    [_apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (apiHelper.data.length > 0) {
            if (error) {
                AMLog(@"%@",error.domain);
                return;
            }
            
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    
                    UCDealerDepositModel *mDeposit = [[UCDealerDepositModel alloc] initWithJson:mBase.result];
                    
                    weakSelf.labPayment.text = [NSString stringWithFormat:@"%@元", mDeposit.bmoney];
                    weakSelf.labBalance.text = [NSString stringWithFormat:@"%@元", mDeposit.bailcurmoney];
                    
                    weakSelf.labDueValue.text = mDeposit.enddate;
                    [weakSelf setStatusLabelWithModel:mDeposit];
                    [weakSelf setDescLabelWithInterval:mDeposit.remainday.integerValue];
                }
                else{
                    AMLog(@"链接成功，请求失败");
                    if (mBase.message) {
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                    }
                    else{
                        [[AMToastView toastView] hide];
                    }
                }
            }
            
        }
    }];
    
    [_apiHelper getDealerDepositInfoWithUserKey:[AMCacheManage currentUserInfo].userkey];
}


@end

