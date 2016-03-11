//
//  UCPushSettingView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-16.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCPushSettingView.h"
#import "UCTopBar.h"
#import "AMCacheManage.h"
#import "KLSwitch.h"
#import "APIHelper.h"

@interface UCPushSettingView ()

@property (nonatomic, strong) UIView *vStatusBar;
@property (nonatomic, strong) UCTopBar *tbTop;
@property (retain, nonatomic) APIHelper *apiHelper;
@property (nonatomic, assign) ConfigPushStatus pushStatus;

@end

@implementation UCPushSettingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // 状态栏
        _vStatusBar = [self creatStatusBarView:CGRectMake(0, 0, self.width, 20)];
        [self addSubview:_vStatusBar];
        // 头视图(导航)
        _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
        [self addSubview:_tbTop];
        
        self.pushStatus = [AMCacheManage currentPushStatus];
        
        [self createCellsView];
        
    }
    return self;
}

/** 状态栏 */
- (UIView *)creatStatusBarView:(CGRect)frame
{
    _vStatusBar = [[UIView alloc] initWithFrame:frame];
    _vStatusBar.backgroundColor = kColorBlue;
    _vStatusBar.alpha = 0.9;
    _vStatusBar.hidden = YES;
    return _vStatusBar;
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:frame];
    
    _tbTop.btnLeft.width = 130;
    _tbTop.btnLeft.adjustsImageWhenHighlighted = NO;
    _tbTop.btnLeft.titleLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    
    [_tbTop.btnTitle setTitle:@"推送设置" forState:UIControlStateNormal];
    [_tbTop.btnTitle setTitleColor:kColorWhite forState:UIControlStateNormal];
    
    return _tbTop;
}


/** 顶栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (![OMG isValidClick])
        return;
    
    switch (btn.tag) {
        case UCTopBarButtonLeft:
        {
            [[MainViewController sharedVCMain] closeView:self animateOption: AnimateOptionMoveLeft];
        }
            break;
        default:
            break;
    }
}


-(void)createCellsView{
    
    self.backgroundColor = kColorNewBackground;
    
    BOOL setOn = NO;
    if (self.pushStatus == ConfigPushStatusON) {
        setOn = YES;
    }
    
    UIView *followCell = [self cellViewWithFrame:CGRectMake(0, _tbTop.maxY + 20, self.width, 50)
                                      LabelTitle:@"订阅车源推送"
                                     switchIndex:0
                                        switchOn:setOn
                                     withTopLine:YES];
    [self addSubview:followCell];
    
//    //声音提醒开关
//    UIView *soundCell = [self cellViewWithFrame:CGRectMake(0, followCell.maxY+20, self.width, 50)
//                                      LabelTitle:@"声音提醒"
//                                     switchIndex:1
//                                        switchOn:YES
//                                     withTopLine:YES];
//    [self addSubview:soundCell];
//    
//    //振动提醒开关
//    UIView *vibrateCell = [self cellViewWithFrame:CGRectMake(0, soundCell.maxY, self.width, 50)
//                                      LabelTitle:@"振动提醒"
//                                     switchIndex:2
//                                        switchOn:YES
//                                     withTopLine:NO];
//    [self addSubview:vibrateCell];
    
    UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, followCell.maxY+10, self.width-30, 24)];
    [noticeLabel setBackgroundColor:[UIColor clearColor]];
    [noticeLabel setTextColor:kColorNewGray2];
    [noticeLabel setNumberOfLines:2];
    [noticeLabel setFont:kFontMini];
    [noticeLabel setText:@"如不能正常接收推送，请检查手机的 “设置” - “通知” - “二手车” 的权限是否已经开启"];
    [self addSubview:noticeLabel];
    
}


-(UIView *)cellViewWithFrame:(CGRect)frame LabelTitle:(NSString*)title switchIndex:(NSInteger)index switchOn:(BOOL)setON withTopLine:(BOOL)boolean{
    UIView *cellView = [[UIView alloc] initLineWithFrame:frame color:kColorWhite];
    
    if (boolean) {
        UIView *topLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine];
        [cellView addSubview:topLine];
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [titleLabel setTextColor:kColorNewGray1];
    [titleLabel setFont:kFontNormal];
    [titleLabel setText:title];
    [titleLabel sizeToFit];
    [titleLabel setOrigin:CGPointMake(19, (cellView.height - titleLabel.height)/2)];
    
    [cellView addSubview:titleLabel];
    
    KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:CGRectMake(cellView.width - 15 - 52, (cellView.height-30)/2, 52, 30)];
    klswitch.onTintColor = kColorSwitchGreen;
    klswitch.tag = index;
    klswitch.on = setON;
    [klswitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [cellView addSubview:klswitch];
    
    UIView *bottomLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, cellView.height-kLinePixel, self.width, kLinePixel) color:kColorNewLine];
    [cellView addSubview:bottomLine];
    
    return cellView;
}


-(void)switchValueChanged:(KLSwitch*)sender{
    
    switch (sender.tag) {
        case 0:
        {
            NSString *toastStr;
            if (self.pushStatus == ConfigPushStatusOFF){
                toastStr = @"正在打开推送";
                [self enablePush:sender];
            }
            else if(self.pushStatus == ConfigPushStatusON){
                toastStr = @"正在关闭推送";
                [self disablePush:sender];
            }
            else{
                toastStr = @"正在打开推送";
                [self registPush:sender];
            }
            
            __weak typeof(self) weakSelf = self;
            [[AMToastView toastView:YES] showLoading:toastStr cancel:^{
                [_apiHelper cancel];
                [weakSelf resetSwitchStatus:sender];
                [[AMToastView toastView] hide];
            }];

        }
            break;
        default:
            break;
    }
}

-(void)resetSwitchStatus:(KLSwitch*)sender{
    if(self.pushStatus == ConfigPushStatusON){
        sender.on = YES;
    }
    else{
        sender.on = NO;
    }
}

#pragma mark - 请求关闭, 请求打开推送
-(void)enablePush:(KLSwitch*)sender{
    if (!_apiHelper)
        _apiHelper = [[APIHelper alloc] init];
    
    __weak typeof(self) weakSelf = self;
    // 设置请求完成后回调方法
    [_apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            AMLog(@"%@",error.domain);
            return;
        }
        AMLog(@"%@",apiHelper);
        if (apiHelper.data.length > 0) {
            
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                NSString *message = nil;
                
                // 更新成功
                if (mBase.returncode == 0){
                    weakSelf.pushStatus = ConfigPushStatusON;
                    [AMCacheManage setPushStatus:ConfigPushStatusON];
                    sender.on = YES;
                    [[AMToastView toastView] showMessage:@"打开成功" icon:kImageRequestSuccess duration:1.5];
                    AMLog(@"\n*** 注册通知^_^ ***\n");
                }
                    
                if (message){
                    sender.on = NO;
                    [[AMToastView toastView] showMessage:@"打开失败,请稍后重试" icon:kImageRequestError duration:1.5];
                    AMLog(@"注册失败-_-：%@", message);
                }
                
            }
        }
    }];
    // 开启push
    [_apiHelper setPushTime:YES starttime:800 endtime:2200 allowperson:0 allowsystem:0];
    
}

-(void)disablePush:(KLSwitch*)sender{
    if (!_apiHelper)
        _apiHelper = [[APIHelper alloc] init];
    
    __weak typeof(self) weakSelf = self;
    // 设置请求完成后回调方法
    [_apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            AMLog(@"%@",error.domain);
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                NSString *message = nil;
                
                // 关闭成功
                if (mBase.returncode == 0){
                    weakSelf.pushStatus = ConfigPushStatusOFF;
                    [AMCacheManage setPushStatus:ConfigPushStatusOFF];
                    sender.on = NO;
                    [[AMToastView toastView] showMessage:@"关闭成功" icon:kImageRequestSuccess duration:1.5];
                    AMLog(@"\n*** 取消通知成功 ***\n");
                }
                if (message){
                    sender.on = YES;
                    [[AMToastView toastView] showMessage:@"关闭失败,请稍后重试" icon:kImageRequestError duration:1.5];
                    AMLog(@"取消注册失败-_-：%@", message);
                }
                    
            }
        }
    }];
    // 关闭push
    [_apiHelper setPushTime:NO starttime:800 endtime:2200 allowperson:0 allowsystem:0];
    
}

/** 根据用户id注册push */
- (void)registPush:(KLSwitch*)sender
{
    if (!_apiHelper)
        _apiHelper = [[APIHelper alloc] init];
    
    __weak typeof(self) weakSelf = self;
    
    // 设置请求完成后回调方法
    [_apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            AMLog(@"%@",error.domain);
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                NSString *message = nil;
                if (mBase.returncode == 0){
                    weakSelf.pushStatus = ConfigPushStatusON;
                    [AMCacheManage setPushStatus:ConfigPushStatusON];
                    sender.on = YES;
                    [[AMToastView toastView] showMessage:@"成功开启推送" icon:kImageRequestSuccess duration:1.5];
                    AMLog(@"\n*** 注册通知^_^ ***\n");
                }
                
                if (message){
                    sender.on = NO;
                    [[AMToastView toastView] showMessage:@"开启推送失败,请稍后重试" icon:kImageRequestError duration:1.5];
                    AMLog(@"注册失败-_-：%@", message);
                }
            }
        }
    }];
    // 注册push
    [_apiHelper registPush];
}


@end
