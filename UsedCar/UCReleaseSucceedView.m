//
//  UCReleaseSucceedView.m
//  UsedCar
//
//  Created by Alan on 13-12-11.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCReleaseSucceedView.h"
#import "UCTopBar.h"
#import "AMCacheManage.h"
#import "UIImage+Util.h"
#import "UCCarPreviewView.h"

@interface UCReleaseSucceedView ()

@property (nonatomic, strong) UCCarInfoEditModel *mCarInfoEdit;

@end

@implementation UCReleaseSucceedView

- (id)initWithFrame:(CGRect)frame isBusiness:(BOOL)isBusiness mCarInfoEdit:(UCCarInfoEditModel *)mCarInfoEdit fromView:(FromViewType)viewType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.viewType = viewType;
        [UMStatistics event:isBusiness ? pv_3_1_buinesssuccessful : pv_3_1_personsuccessful];
        if (isBusiness) {
            UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
            [UMSAgent postEvent:dealersuccess_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:mCarInfoEdit.seriesid.stringValue, @"seriesid#2", mCarInfoEdit.productid.stringValue, @"specid#3", mUserInfo.userid, @"dealerid#5", mUserInfo.userid, @"userid#4", nil]];
        } else {
            [UMSAgent postEvent:usersuccess_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:mCarInfoEdit.seriesid.stringValue, @"seriesid#2", mCarInfoEdit.productid.stringValue, @"specid#3", nil]];
        }
        
        _mCarInfoEdit = mCarInfoEdit;
        _isBusiness = isBusiness;
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    // 导航头
    UCTopBar *tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [tbTop.btnLeft setTitle:@"关闭" forState:UIControlStateNormal];
    [tbTop.btnRight setTitleColor:kColorLightGreen forState:UIControlStateNormal];
    [tbTop.btnTitle setTitle:_isBusiness ? @"商家卖车" : @"个人卖车" forState:UIControlStateNormal];
    [tbTop.btnLeft addTarget:self action:@selector(onClickClose) forControlEvents:UIControlEventTouchUpInside];
    
    // 初始化完成界面
    UIView *vReleaseCarFinish = [[UIView alloc] initWithFrame:CGRectMake(0, tbTop.height, self.width, self.height - tbTop.height)];
    vReleaseCarFinish.backgroundColor = kColorWhite;
    // 居中视图
    UIView *vCenter = [[UIView alloc] initWithFrame:CGRectMake(0, (vReleaseCarFinish.height - 45 - 220) / 2, vReleaseCarFinish.width, 220)];
    // 大图标
    UIImageView *ivIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"release_done_icon"]];
    ivIcon.minX = (vCenter.width - ivIcon.width) / 2;
    // 标题
    UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, ivIcon.maxY + 30, vReleaseCarFinish.width, 20)];
    labTitle.text = @"恭喜您, 车辆发布完成!";
    labTitle.textColor = kColorGray1;
    labTitle.font = [UIFont boldSystemFontOfSize:20];
    labTitle.textAlignment = NSTextAlignmentCenter;
    // 说明
    UILabel *labText = [[UILabel alloc] initWithFrame:CGRectMake(0, labTitle.maxY + 14, vReleaseCarFinish.width, 30)];
    labText.text = @"工作人员会在1天内完成审核\n请随时关注您的车辆信息";
    labText.textColor = kColorGrey3;
    labText.font = [UIFont systemFontOfSize:12];
    labText.lineBreakMode = UILineBreakModeWordWrap;
    labText.numberOfLines = 0;
    labText.textAlignment = NSTextAlignmentCenter;

    [vCenter addSubview:ivIcon];
    [vCenter addSubview:labTitle];
    [vCenter addSubview:labText];

    // 车辆信息预览
    UIButton *btnPreview = [[UIButton alloc] initWithFrame:CGRectMake(0, vReleaseCarFinish.height - 45, vReleaseCarFinish.width / 2, 45)];
    btnPreview.titleLabel.font = [UIFont systemFontOfSize:17];
    btnPreview.backgroundColor = kColorGrey5;
    [btnPreview setTitleColor:kColorBlue1 forState:UIControlStateNormal];
    [btnPreview setTitleColor:kColorGrey3 forState:UIControlStateDisabled];
    [btnPreview setTitle:@"车辆信息预览" forState:UIControlStateNormal];
    [btnPreview setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnPreview.bounds.size] forState:UIControlStateHighlighted];
    [btnPreview addTarget:self action:@selector(onClickPreview) forControlEvents:UIControlEventTouchUpInside];

    // 再添加一辆车
    UIButton *btnAddAgain = [[UIButton alloc] initWithFrame:CGRectMake(btnPreview.maxX, btnPreview.minY, vReleaseCarFinish.width / 2, 45)];
    btnAddAgain.titleLabel.font = [UIFont systemFontOfSize:17];
    btnAddAgain.backgroundColor = kColorGrey5;
    [btnAddAgain setTitleColor:kColorBlue1 forState:UIControlStateNormal];
    [btnAddAgain setTitleColor:kColorGrey3 forState:UIControlStateDisabled];
    [btnAddAgain setTitle:@"再发布一辆车" forState:UIControlStateNormal];
    [btnAddAgain setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnAddAgain.bounds.size] forState:UIControlStateHighlighted];
    [btnAddAgain addTarget:self action:@selector(onClickAddAgain) forControlEvents:UIControlEventTouchUpInside];

    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, btnPreview.minY, vReleaseCarFinish.width, kLinePixel) color:kColorNewLine];
    UIView *vLine1 = [[UIView alloc] initLineWithFrame:CGRectMake(btnPreview.maxX, btnPreview.minY + 10, kLinePixel, btnPreview.height - 20) color:kColorNewLine];

    [vReleaseCarFinish addSubview:vCenter];
    [vReleaseCarFinish addSubview:btnPreview];
    [vReleaseCarFinish addSubview:btnAddAgain];
    [vReleaseCarFinish addSubview:vLine];
    [vReleaseCarFinish addSubview:vLine1];

    [self addSubview:tbTop];
    [self addSubview:vReleaseCarFinish];
}

#pragma mark - onClickBtn
- (void)onClickClose
{
    [UMStatistics event:_isBusiness ? c_3_1_buinesssuccessfulclose : c_3_1_personsuccessfulclose];
    
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/* 点击预览按钮事件 */
- (void)onClickPreview
{
    [UMStatistics event:_isBusiness ? c_3_1_buinesssuccessfulpreview : c_3_1_personsuccessfulpreview];
    
    //预览
    UCCarDetailInfoModel *mCarDetailInfo = [[UCCarDetailInfoModel alloc] initWithCarInfoEditModel:_mCarInfoEdit];
    UCCarPreviewView *vCarPreview = [[UCCarPreviewView alloc] initWithFrame:self.bounds mCarDetailInfo:mCarDetailInfo isBusiness:_isBusiness];
    [[MainViewController sharedVCMain] openView:vCarPreview animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

/* 点击再添加按钮事件 */
- (void)onClickAddAgain
{
    // 选择再添加一辆
    if ([_delegate respondsToSelector:@selector(didSelectedReleaseAgain:)])
        [_delegate didSelectedReleaseAgain:self];    
}

@end
