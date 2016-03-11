//
//  UCEmissionSearchView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-10-22.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCEmissionSearchView.h"
#import "UCTopBar.h"
#import "UIImage+Util.h"
#import "APIHelper.h"
#import "UISelectorView.h"
#import "AreaProvinceItem.h"
#import "AreaCityItem.h"
#import "UCSNSHelper.h"
#import "AMCacheManage.h"

@interface UCEmissionSearchView ()<UISelectorViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UITextField *tfArea;
@property (nonatomic, strong) UIButton *btnSearch;
@property (nonatomic, strong) UIView   *vResult;
@property (nonatomic, strong) UILabel  *labTitle;
@property (nonatomic, strong) UILabel  *labStandardTitle;
@property (nonatomic, strong) UILabel  *labDetailTitle;
@property (nonatomic, strong) UILabel  *labStandard;
@property (nonatomic, strong) UILabel  *labDetail;
@property (nonatomic, strong) UILabel  *labNoInfo;

@property (nonatomic, strong) APIHelper *searchHelper;

@property (nonatomic, strong) UISelectorView *vSelector;
@property (nonatomic, strong) UIButton *btnCloseKeyboard;       // 关闭键盘

@property (nonatomic, strong) NSArray *provinces;               // 省
@property (nonatomic, strong) NSString *provinceId;
@property (nonatomic, strong) NSString *cityId;
@property (nonatomic, strong) NSString *provinceName;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) UIButton *btnShare;
@property (nonatomic, strong) UCSNSHelper *snsHelper;

@end


@implementation UCEmissionSearchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
        NSNumber *userid = nil;
        NSNumber *dealerid = nil;
        switch ([AMCacheManage currentUserType]) {
            case UserStylePersonal:
                userid = mUserInfo.userid;
                break;
            case UserStyleBusiness:
                dealerid = mUserInfo.userid;
                
            default:
                break;
        }
        [UMSAgent postEvent:tool_displacement_area_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:userid, @"userid#4", dealerid, @"dealerid#5", nil]];
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        self.provinces = [OMG areaProvinces];
        [self initView];
    }
    return self;
}

- (void)initView{
    [UMStatistics event:pv_4_1_tool_displacement_area];
    
    self.backgroundColor =  kColorNewBackground;
    self.tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:self.tbTop];
    
    UILabel *labNotice = [[UILabel alloc] initWithFrame:CGRectMake(15, self.tbTop.maxY + 20, self.width - 30, 15)];
    labNotice.backgroundColor = kColorClear;
    labNotice.textColor = kColorNewGray1;
    labNotice.font = kFontLarge;
    labNotice.text = @"按迁入地区查询";
    [self addSubview:labNotice];
    
    UIView *hLineT = [[UIView alloc] initLineWithFrame:CGRectMake(0, labNotice.maxY + 8, self.width, kLinePixel) color:kColorNewLine];
    [self addSubview:hLineT];
    
    [self createSelector];
    
    self.tfArea = [[UITextField alloc] initWithFrame:CGRectMake(0, hLineT.maxY, self.width, 46)];
    self.tfArea.font = kFontLarge;
    self.tfArea.backgroundColor = kColorWhite;
    [self.tfArea setTextColor:kColorNewGray1];
    self.tfArea.delegate = self;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 46)];
    leftView.backgroundColor = kColorClear;
    self.tfArea.leftView = leftView;
    self.tfArea.leftViewMode = UITextFieldViewModeAlways;
    self.tfArea.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.tfArea.inputView = self.vSelector;
    [self addSubview:self.tfArea];
    
    UIView *hLineB = [[UIView alloc] initLineWithFrame:CGRectMake(0, self.tfArea.maxY, self.width, kLinePixel) color:kColorNewLine];
    [self addSubview:hLineB];
    
    self.btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSearch.frame = CGRectMake(10, hLineB.maxY + 20, self.width - 20, 44);
    self.btnSearch.titleLabel.font = kFontLarge;
    [self.btnSearch setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self.btnSearch setTitle:@"立即查询" forState:UIControlStateNormal];
    [self.btnSearch setBackgroundImage:[UIImage imageWithColor:kColorBlue size:self.btnSearch.size] forState:UIControlStateNormal];
    [self.btnSearch setBackgroundImage:[UIImage imageWithColor:kColorBlueH size:self.btnSearch.size] forState:UIControlStateSelected];
    [self.btnSearch setBackgroundImage:[UIImage imageWithColor:kColorBlueH size:self.btnSearch.size] forState:UIControlStateHighlighted];
    [self.btnSearch.layer setCornerRadius:3.0];
    [self.btnSearch.layer setMasksToBounds:YES];
    [self.btnSearch addTarget:self action:@selector(onClickSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btnSearch];
    
    [self createResultView];
    
    // 键盘关闭按钮
    UIImage *imgClose = [UIImage imageNamed:@"keboard_off_btn"];
    self.btnCloseKeyboard = [[UIButton alloc] initWithFrame:CGRectMake(self.width - imgClose.width, self.height, imgClose.width + 10, imgClose.height + 10)];
    [self.btnCloseKeyboard setImage:imgClose forState:UIControlStateNormal];
    [self.btnCloseKeyboard addTarget:self action:@selector(onClickCloseKeyboard) forControlEvents:UIControlEventTouchUpInside];
    self.btnCloseKeyboard.alpha = 0;
    [self addSubview:self.btnCloseKeyboard];
    
    [self.tfArea becomeFirstResponder];
}


/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"限迁标准查询" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnShare setFrame:CGRectMake(vTopBar.btnRight.width-34-8, 0, 34, vTopBar.btnRight.height)];
    [self.btnShare setImage:[UIImage imageNamed:@"detail_share_btn"] forState:UIControlStateNormal];
    [self.btnShare setImage:[UIImage imageNamed:@"detail_share_btn_d"] forState:UIControlStateDisabled];
    [self.btnShare addTarget:self action:@selector(onClickShareBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.btnShare.hidden = YES;
    [vTopBar.btnRight addSubview:self.btnShare];
    
    return vTopBar;
}

- (void)createResultView{
    
    self.vResult = [[UIView alloc] initWithFrame:CGRectMake(0, self.btnSearch.maxY+20, self.width, self.height - self.btnSearch.maxY - 20)];
    self.vResult.backgroundColor = kColorClear;
    self.vResult.hidden = YES;
    [self addSubview:self.vResult];
    
    UIImageView *vDashLine = [[UIImageView alloc]initWithFrame:CGRectMake(15, 0, self.width-30, 1)];
    UIImage *resizeImage = [[UIImage imageNamed:@"dashed"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
    [vDashLine setImage:resizeImage];
    [self.vResult addSubview:vDashLine];
    
    self.labTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, vDashLine.maxY+20, self.width, 15)];
    self.labTitle.backgroundColor = kColorClear;
    self.labTitle.font = kFontLarge_b;
    self.labTitle.textColor = kColorNewGray1;
    self.labTitle.text = @"查询结果";
    self.labTitle.textAlignment = NSTextAlignmentCenter;
    [self.vResult addSubview:self.labTitle];
    
    self.labStandardTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, self.labTitle.maxY+20, 75, 15)];
    self.labStandardTitle.text = @"准迁标准：";
    self.labStandardTitle.backgroundColor = kColorClear;
    self.labStandardTitle.textColor = kColorNewGray1;
    self.labStandardTitle.font = kFontLarge;
    [self.vResult addSubview:self.labStandardTitle];
    
    self.labDetailTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, self.labStandardTitle.maxY+10, 75, 15)];
    self.labDetailTitle.text = @"标准细节：";
    self.labDetailTitle.backgroundColor = kColorClear;
    self.labDetailTitle.textColor = kColorNewGray1;
    self.labDetailTitle.font = kFontLarge;
    [self.vResult addSubview:self.labDetailTitle];
    
    self.labStandard = [[UILabel alloc] initWithFrame:CGRectMake(self.labStandardTitle.maxX, self.labStandardTitle.origin.y, self.width - self.labStandardTitle.maxX - 15, 15)];
    self.labStandard.backgroundColor = kColorClear;
    self.labStandard.textColor = kColorNewGray1;
    self.labStandard.font = kFontLarge;
    [self.vResult addSubview:self.labStandard];
    
    self.labDetail = [[UILabel alloc] initWithFrame:CGRectMake(self.labDetailTitle.maxX, self.labDetailTitle.origin.y, self.width - self.labDetailTitle.maxX - 15, 15)];
    self.labDetail.backgroundColor = kColorClear;
    self.labDetail.textColor = kColorNewGray1;
    self.labDetail.font = kFontLarge;
    self.labDetail.numberOfLines = 0;
    [self.vResult addSubview:self.labDetail];
    
    self.labNoInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, vDashLine.maxY+40, self.width, 15)];
    self.labNoInfo.backgroundColor = kColorClear;
    self.labNoInfo.text = @"该城市暂无标准信息";
    self.labNoInfo.textAlignment = NSTextAlignmentCenter;
    self.labNoInfo.font = kFontLarge;
    self.labNoInfo.textColor = kColorNewGray2;
    [self.vResult addSubview:self.labNoInfo];
    
}

- (void)createSelector{
    // 初始化选择器
    _vSelector = [[UISelectorView alloc] initWithFrame:CGRectMake(0, 0, self.width, 216)];
    _vSelector.delegate = self;
    _vSelector.backgroundColor = kColorGrey5;
    _vSelector.colorSelector = kColorBlue1;
    
    NSInteger row0 = 0;
    // 省市名称
    NSMutableArray *provinceNames = [NSMutableArray array];
    for (int i = 0; i < _provinces.count; i++) {
        AreaProvinceItem *apItem = [_provinces objectAtIndex:i];
        [provinceNames addObject:apItem.PN];
    }
    
    // 城市名称
    NSMutableArray *cityNames = [NSMutableArray array];
    NSArray *citys = [(AreaProvinceItem *)[_provinces objectAtIndex:row0] CL];
    
    for (int i = 0; i < citys.count; i++) {
        AreaCityItem *acItem = [citys objectAtIndex:i];
        [cityNames addObject:acItem.CN];
    }
    
    _vSelector.dataSource = [NSMutableArray arrayWithObjects:provinceNames, cityNames, nil];
}

- (void)setResultViewWithResult:(NSDictionary*)dict{
    
    NSNumber *userid = nil;
    NSNumber *dealerid = nil;
    UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
    switch ([AMCacheManage currentUserType]) {
        case UserStyleBusiness:
            dealerid = mUserInfo.userid;
            break;
        case UserStylePersonal:
            userid = mUserInfo.userid;
            break;
            
        default:
            break;
    }
    
    if (dict == nil) {
        [UMStatistics event:pv_4_1_tool_displacementright_errorarea];
        [UMSAgent postEvent:tool_displacementright_errorarea_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:dealerid, @"dealerid#5", userid, @"userid#4", nil]];
        self.labNoInfo.hidden = NO;
        self.labTitle.hidden = YES;
        self.labStandardTitle.hidden = YES;
        self.labDetailTitle.hidden = YES;
        self.labStandard.hidden = YES;
        self.labDetail.hidden = YES;
        self.vResult.hidden = NO;
    }
    else{
        [UMStatistics event:pv_4_1_tool_displacementright_rightarea];
        [UMSAgent postEvent:tool_displacementright_rightarea_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:dealerid, @"dealerid#5", userid, @"userid#4", nil]];
        
        self.labNoInfo.hidden = YES;
        self.labTitle.hidden = NO;
        self.labStandardTitle.hidden = NO;
        self.labStandard.hidden = NO;
        self.vResult.hidden = NO;
        
        self.btnShare.hidden = NO;
        
        self.labStandard.text = [dict objectForKey:@"norm"];
        if([[dict objectForKey:@"memo"] length] > 0){
            self.labDetailTitle.hidden = NO;
            self.labDetail.hidden = NO;
            NSString *strDetail = [dict objectForKey:@"memo"];
            self.labDetail.text = strDetail;
            
            CGFloat width = self.width - self.labDetailTitle.maxX - 15;
            CGFloat height = self.vResult.height - self.labDetail.minY;
            CGSize size = [strDetail sizeWithFont:kFontLarge constrainedToSize:CGSizeMake(width, height)];
            self.labDetail.size = size;
        }
        else{
            self.labDetailTitle.hidden = YES;
            self.labDetail.hidden = YES;
            self.labDetail.text = nil;
        }
    }
    
}

#pragma mark - button actions
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [self endEditing:NO];
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

- (void)onClickShareBtn:(UIButton *)btn{
    [UMStatistics event:c_4_1_tool_displacement_rightarea_share];
    
    if (!self.snsHelper) {
        self.snsHelper = [[UCSNSHelper alloc] init];
    }
    NSString *shareURL = [[APIHelper getShareEmissionResult] stringByAppendingString:self.cityId];
    self.snsHelper.shareURL = shareURL;
    self.snsHelper.title = [NSString stringWithFormat:@"%@市限迁标准查询结果",self.cityName];
    self.snsHelper.contentWeChat = @"限迁标准查询，帮助您快速了解迁入地排放标准#二手车之家#。";
    self.snsHelper.content = [NSString stringWithFormat:@"%@市限迁标准查询结果，%@ #二手车之家#",self.cityName, shareURL];
    self.snsHelper.imageShareIcon = [UIImage imageNamed:@"emissionShare"];
    [self.snsHelper openShareViewForAllPlatform:NO];
}

/** 关闭键盘事件 */
- (void)onClickCloseKeyboard
{
    [self endEditing:NO];
}

- (void)onClickSearchBtn:(UIButton *)btn{
    [self endEditing:NO];
    if (![OMG isValidClick]) {
        return;
    }
    [UMStatistics event:c_4_1_tool_displacement_area_query];
    [self searchEmissionStandard];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSInteger row0 = 0;
    NSInteger row1 = 0;
    
    // 省市名称
    NSMutableArray *provinceNames = [NSMutableArray array];
    for (int i = 0; i < _provinces.count; i++) {
        AreaProvinceItem *apItem = [_provinces objectAtIndex:i];
        [provinceNames addObject:apItem.PN];
        // 已选择省
        if (self.provinceId.integerValue == apItem.PI.integerValue){
            row0 = i;
        }
    }
    
    // 城市名称
    NSMutableArray *cityNames = [NSMutableArray array];
    NSArray *citys = [(AreaProvinceItem *)[_provinces objectAtIndex:row0] CL];
    
    for (int i = 0; i < citys.count; i++) {
        AreaCityItem *acItem = [citys objectAtIndex:i];
        [cityNames addObject:acItem.CN];
        // 已选择市
        if (self.cityId.integerValue == acItem.CI.integerValue){
            row1 = i;
        }
    }
    
    [_vSelector selectRow:row0 inComponent:0 animated:NO];
    [_vSelector selectRow:row1 inComponent:1 animated:NO];
    
    
    return YES;
}

#pragma mark - keyboard did show & hide
- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSInteger showAnimationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:showAnimationCurve];
    [UIView setAnimationDuration:animationDuration];
    _btnCloseKeyboard.maxY = self.height - 216+5;
    _btnCloseKeyboard.alpha = 1;
    [UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notification{
    
    NSInteger hideAnimationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:hideAnimationCurve];
    [UIView setAnimationDuration:animationDuration];
    _btnCloseKeyboard.maxY = self.height;
    _btnCloseKeyboard.alpha = 0;
    [UIView commitAnimations];
}


#pragma mark - UISelectorView
- (void)selectorView:(UISelectorView *)selectorView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    // 省市联动
    if (component == 0) {
        // 城市名称
        NSMutableArray *cityNames = [NSMutableArray array];
        NSArray *citys = [(AreaProvinceItem *)[_provinces objectAtIndex:row] CL];
        for (AreaCityItem *acItem in citys) {
            [cityNames addObject:acItem.CN];
        }
        [selectorView.dataSource replaceObjectAtIndex:1 withObject:cityNames];
        [selectorView reloadComponent:1];
    }
    //获取选中的 省 市
    NSInteger row0 = [(NSIndexPath *)[selectorView.selectedIndexPaths objectAtIndex:0] row];
    NSInteger row1 = [(NSIndexPath *)[selectorView.selectedIndexPaths objectAtIndex:1] row];
    
    AreaProvinceItem *apItem = [_provinces objectAtIndex:row0];
    // 省
    self.provinceId = apItem.PI.stringValue;
    self.provinceName = apItem.PN;
    // 市
    AreaCityItem *acItem = [apItem.CL objectAtIndex:row1];
    
    if (acItem.CI.integerValue != self.cityId.integerValue) {
        //隐藏结果页
        self.vResult.hidden = YES;
        self.btnShare.hidden = YES;
    }
    
    self.cityId = acItem.CI.stringValue;
    self.cityName = acItem.CN;
    // 设置显示数据
    self.tfArea.text = [NSString stringWithFormat:@"%@ %@", self.provinceName, self.cityName];
}


#pragma mark - 网络请求
- (void)searchEmissionStandard{
    
    if (!self.searchHelper) {
        self.searchHelper = [[APIHelper alloc] init];
    }
    
    [[AMToastView toastView] showLoading:@"数据加载中..." cancel:^{
        [self.tfArea becomeFirstResponder];
    }];
    
    __weak UCEmissionSearchView *weakSelf = self;
    [self.searchHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            weakSelf.vResult.hidden = YES;
            weakSelf.btnShare.hidden = YES;
            [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
            return ;
        }
        
        if (apiHelper.data.length>0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase.returncode == 0) {
                [[AMToastView toastView] hide];
                [weakSelf setResultViewWithResult:mBase.result];
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
    
    [self.searchHelper getEmissionStandardForPid:self.provinceId Cid:self.cityId];
}

#pragma mark - dealloc
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
