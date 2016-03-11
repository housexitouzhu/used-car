//
//  UCEvaluationView.m
//  UsedCar
//
//  Created by 张鑫 on 13-12-31.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCEvaluationView.h"
#import "UCTopBar.h"
#import "DatabaseHelper1.h"
#import "UCEvaluationModel.h"
#import "UIImage+Util.h"
#import "UCChooseCarView.h"
#import "NSString+Util.h"
#import "UIImage+Util.h"
#import "AreaProvinceItem.h"
#import "APIHelper.h"
#import "UCEvaluationPriceModel.h"
#import "AMCacheManage.h"
#import "UCCarInfoEditModel.h"

#define kCarBasicItemStartTag       10000
#define kCarBasicCarInfoTag         10001
#define kCarFirstregtimeTag         10002
#define kCarBasicDriveMileageTag    10003
#define kCarBasicLocationTag        10004

#define kCarTitleStarTag            20001

@interface UCEvaluationView ()

@property (nonatomic) CGFloat keyboardHeight;                   // 键盘高度
@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UIScrollView *svMain;
@property (nonatomic, strong) UITextView *tvCarInfo;            // 车辆信息(车型,变速箱,排量)
@property (nonatomic, strong) UIButton *btnCloseKeyboard;       // 关闭键盘
@property (nonatomic, strong) UISelectorView *vSelector;        // 选择器
@property (nonatomic, strong) NSArray *provinces;               // 省
@property (nonatomic, strong) UCEvaluationModel *mEvaluation;   // 估价数据
@property (nonatomic, strong) APIHelper *apiEvaluationHelper;
@property (nonatomic, strong) UCEvaluationDetailView *vEvaluationDetail;
@property (nonatomic, strong) UCCarInfoEditModel *mCarInfoEdit; // 发车model

@end

@implementation UCEvaluationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [UMStatistics event:pv_4_1_tool_evaluation];

        if ([AMCacheManage currentUserType] == UserStyleBusiness) {
            UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
            [UMSAgent postEvent:tool_evaluation_pv page_name:NSStringFromClass(self.class)
                     eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 mUserInfo.userid, @"dealerid#5",
                                 mUserInfo.userid, @"userid#4", nil]];
        } else {
            [UMSAgent postEvent:tool_evaluation_pv page_name:NSStringFromClass(self.class)];
        }
        // 城市数据
        self.provinces = [OMG areaProvinces];
        self.mEvaluation = [[UCEvaluationModel alloc] init];
        self.apiEvaluationHelper = [[APIHelper alloc] init];
        self.mCarInfoEdit = [[UCCarInfoEditModel alloc] init];
        [self initView];
    }
    return self;
}

-(void)viewWillHide:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewWillHide:animated];
}

- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    
    // 导航头
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    // 初始化主滚动布局
    _svMain = [[UIScrollView alloc] initWithFrame:self.bounds];
    
    _svMain.clipsToBounds = YES;
    
    // 初始化选择器
    _vSelector = [[UISelectorView alloc] initWithFrame:CGRectMake(0, 0, self.width, 216)];
    _vSelector.delegate = self;
    _vSelector.backgroundColor = kColorGrey5;
    _vSelector.colorSelector = kColorBlue1;
    
    [self initCarInfoView];
    
    // 键盘关闭按钮
    UIImage *imgClose = [UIImage imageNamed:@"keboard_off_btn"];
    _btnCloseKeyboard = [[UIButton alloc] initWithFrame:CGRectMake(self.width - imgClose.width, self.height, imgClose.width + 10, imgClose.height + 10)];
    [_btnCloseKeyboard setImage:imgClose forState:UIControlStateNormal];
    [_btnCloseKeyboard addTarget:self action:@selector(onClickCloseKeyboard) forControlEvents:UIControlEventTouchUpInside];
    _btnCloseKeyboard.alpha = 0;
    
    [self addSubview:_svMain];
    [self addSubview:_btnCloseKeyboard];
    [self addSubview:_tbTop];
    
    _svMain.contentSize = CGSizeMake(_svMain.width, _svMain.maxY);
    
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    _tbTop = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [_tbTop.btnTitle setTitle:@"估价" forState:UIControlStateNormal];
    
    _tbTop.btnLeft.width = 130;
    _tbTop.btnLeft.adjustsImageWhenHighlighted = NO;
    _tbTop.btnLeft.titleLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return _tbTop;
}

- (void)initCarInfoView
{
    
    UILabel *labPrompt = [[UILabel alloc] init];
    labPrompt.backgroundColor = kColorClear;
    labPrompt.font = kFontSmall;
    labPrompt.textAlignment = NSTextAlignmentCenter;
    labPrompt.textColor = kColorBlue;
    labPrompt.text = @"请完整填写信息，以便准确估价";
    [labPrompt sizeToFit];
    labPrompt.origin = CGPointMake((_svMain.width - labPrompt.width) / 2, _tbTop.maxY + 20);
    [_svMain addSubview:labPrompt];
    
    CGFloat height = 44;
    CGFloat marginTop = 0;

    UIView *vInput = [[UIView alloc] initLineWithFrame:CGRectMake(0, labPrompt.maxY + 8, self.width, height * 4) color:kColorWhite];
    
    NSArray *infoTitles = @[@"车辆信息：", @"上牌日期：", @"行驶里程：", @"所在城市："];
    NSArray *icons = @[@"tool_evaluation_vehicleinformation", @"tool_evaluation_registrationdate", @"tool_evaluation_mileage", @"tool_evaluation_address"];
    
    
    for (int i = 0; i < infoTitles.count; i++) {
        UIImage *image = [UIImage imageNamed:icons[i]];
        UIImageView *ivIcon = [[UIImageView alloc] initWithImage:image];
        ivIcon.origin = CGPointMake(15, (44 - image.height) / 2);
        
        // leftView
        UIView *vLeft = [[UIView alloc] initWithClearFrame:CGRectMake(0, 0, 125, height)];
        
        // 标题
        UILabel *labTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(ivIcon.maxX + 10, 0, 75, height)];
        labTitle.backgroundColor = [UIColor clearColor];
        labTitle.textColor = kColorNewGray1;
        labTitle.textAlignment = NSTextAlignmentCenter;
        labTitle.font = kFontLarge;
        labTitle.text = [infoTitles objectAtIndex:i];
        labTitle.tag = kCarTitleStarTag + i;
        
        [vLeft addSubview:labTitle];
        [vLeft addSubview:ivIcon];
        
        // 内容
        UITextField *tfContent = [[UITextField alloc] initWithFrame:CGRectMake(0, marginTop, self.width, height)];
        tfContent.font = kFontLarge;
        tfContent.textColor = kColorNewGray1;
        tfContent.delegate = self;
        
        // 车辆信息 使用 TextView代替
        if ([labTitle.text hasPrefix:@"车辆信息"]) {
            tfContent.tag = kCarBasicCarInfoTag;
            _tvCarInfo = [[UITextView alloc] initWithClearFrame:CGRectMake(119, 5, tfContent.width, tfContent.height)];
            _tvCarInfo.delegate = self;
            _tvCarInfo.textColor = kColorNewGray1;
            _tvCarInfo.font = kFontLarge;
            _tvCarInfo.scrollEnabled = NO;
            _tvCarInfo.exclusiveTouch = YES;
            [tfContent addSubview:_tvCarInfo];
        }
        
        // 上牌日期
        else if ([labTitle.text hasPrefix:@"上牌日期"]) {
            tfContent.tag = kCarFirstregtimeTag;
            tfContent.inputView = _vSelector;
        }
        // 行驶里程
        else if ([labTitle.text hasPrefix:@"行驶里程"]) {
            tfContent.tag = kCarBasicDriveMileageTag;
            tfContent.keyboardType = UIKeyboardTypeDecimalPad;
            // 文字颜色
            tfContent.font = kFontLarge;
            // 单位
            UILabel *labUnit = [[UILabel alloc] initWithClearFrame:CGRectMake(vInput.width - 60 - 15, tfContent.minY, 60, tfContent.height)];
            labUnit.textColor = kColorNewGray1;
            labUnit.textAlignment = NSTextAlignmentRight;
            labUnit.font = kFontLarge;
            labUnit.text = @"万公里";
            [vInput addSubview:labUnit];
        }
        // 所在城市
        else if ([labTitle.text hasPrefix:@"所在城市"]) {
            tfContent.tag = kCarBasicLocationTag;
            tfContent.inputView = _vSelector;
        }
        
        tfContent.leftView = vLeft;
        tfContent.rightView = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, 4, tfContent.height) color:kColorRed];
        tfContent.leftViewMode = UITextFieldViewModeAlways;
        tfContent.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        if (i != 0) {
            [vInput addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(45, marginTop - kLinePixel, vInput.width - 45, kLinePixel) color:kColorNewLine]];
        }
        [vInput addSubview:tfContent];
        // 上下分割线
        [vInput addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, vInput.width, kLinePixel) color:kColorNewLine]];
        [vInput addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, vInput.height - kLinePixel, vInput.width, kLinePixel) color:kColorNewLine]];
        
        marginTop = tfContent.maxY;
    }
    
    NSArray *titles = @[@"卖这辆车", @"买这辆车"];
    
    for (int i = 0; i < titles.count; i++) {
        // 估价按钮
        UIButton *btnEvaluation = [[UIButton alloc] initWithFrame:CGRectMake(i == 0 ? 10 : (vInput.width - 10 - (_svMain.width - 10 * 2 - 10) / 2), vInput.maxY + 20, (_svMain.width - 10 * 2 - 10) / 2, 44)];
        [btnEvaluation setBackgroundImage:[UIImage imageWithColor:kColorBlue size:btnEvaluation.size] forState:UIControlStateNormal];
        [btnEvaluation setTitle:titles[i] forState:UIControlStateNormal];
        btnEvaluation.titleLabel.font = kFontLarge;
        btnEvaluation.titleLabel.textColor = kColorWhite;
        btnEvaluation.layer.masksToBounds = YES;
        btnEvaluation.layer.cornerRadius = 3;
        btnEvaluation.tag = i;
        [btnEvaluation addTarget:self action:@selector(onClickEvaluate:) forControlEvents:UIControlEventTouchUpInside];
        
        [_svMain addSubview:btnEvaluation];
    }
    
    [_svMain addSubview:vInput];
    
    
}

#pragma mark - onClickButton
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/** 关闭键盘事件 */
- (void)onClickCloseKeyboard
{
    [self closeKeyBoard];
}

/** 估价 */
- (void)onClickEvaluate:(UIButton *)btn
{
    // 卖这辆车
    if (btn.tag == 0) {
        [UMStatistics event:c_4_1_tool_evaluation_sellcar];
    }
    // 买这辆车
    else {
        [UMStatistics event:c_4_1_tool_evaluation_buycar];
    }
    [self closeKeyBoard];
    NSMutableArray *errors = [NSMutableArray array];
    if (_mEvaluation.specid.integerValue == 0)
        [errors addObject:[NSNumber numberWithInt:kCarBasicCarInfoTag]];
    if (_mEvaluation.mileage.doubleValue == 0)
        [errors addObject:[NSNumber numberWithInt:kCarBasicDriveMileageTag]];
    if (_mEvaluation.pid.integerValue == 0 || _mEvaluation.cid.integerValue == 0)
        [errors addObject:[NSNumber numberWithInt:kCarBasicLocationTag]];
    if (_mEvaluation.firstregtime.length == 0)
        [errors addObject:[NSNumber numberWithInt:kCarFirstregtimeTag]];
    
    // 未填完提示
    if (errors.count > 0) {
        [[AMToastView toastView] showMessage:[NSString stringWithFormat:@"还有%d项未填写", errors.count] icon:kImageRequestError duration:AMToastDurationNormal];
        for (NSNumber *num in errors) {
            UILabel *labTitle = (UILabel *)[_svMain viewWithTag:num.integerValue + 10000];
            labTitle.textColor = kColorRed; //font 16
        }
    } else {
        
        // 存储发车需要的model
        self.mCarInfoEdit.brandid = self.mEvaluation.brandid;
        self.mCarInfoEdit.brandname = self.mEvaluation.brandText;
        self.mCarInfoEdit.seriesid = self.mEvaluation.seriesid;
        self.mCarInfoEdit.seriesname = self.mEvaluation.seriesidText;
        self.mCarInfoEdit.productid = self.mEvaluation.specid;
        self.mCarInfoEdit.productname = self.mEvaluation.specidText;
        self.mCarInfoEdit.firstregtime = [self.mEvaluation.firstregtime stringByReplacingOccurrencesOfString:@"," withString:@"-"];
        self.mCarInfoEdit.drivemileage = self.mEvaluation.mileage;
        self.mCarInfoEdit.provinceid = self.mEvaluation.pid;
        self.mCarInfoEdit.cityid = self.mEvaluation.cid;
        NSString *year = [[self.mCarInfoEdit.firstregtime componentsSeparatedByString:@"-"] objectAtIndex:0];
        NSString *month = [[self.mCarInfoEdit.firstregtime componentsSeparatedByString:@"-"] objectAtIndex:1];
        // 车辆年审
        self.mCarInfoEdit.verifytime = [OMG dateCheckForTag:1 year:year.integerValue month:month.integerValue];
        // 交强险
        self.mCarInfoEdit.insurancedate = [OMG dateCheckForTag:3 year:year.integerValue month:month.integerValue];
        self.mCarInfoEdit.veticaltaxtime = [OMG dateCheckForTag:2 year:year.integerValue month:month.integerValue];
        
        // 卖这辆车
        if (btn.tag == 0) {
            [self evaluatePrice:_mEvaluation viewType:UCEvaluationDetailViewTypeSellCar];
        }
        // 买这辆车
        else {
            [self evaluatePrice:_mEvaluation viewType:UCEvaluationDetailViewTypeBuyCar];
        }
    }
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // 边框变色
    for (int i = 0; i < 4; i++) {
        UITextField *tfItem = (UITextField *)[_svMain viewWithTag:kCarBasicItemStartTag + i + 1];
        tfItem.layer.borderColor = kColorGrey3.CGColor;
    }
    textField.layer.borderColor = kColorBlue3.CGColor;
    
    // 车辆名称
    if (textField.tag == kCarBasicCarInfoTag) {
        return NO;
    }
    // 所在城市
    else if (textField.tag == kCarBasicLocationTag) {
        _vSelector.tag = kCarBasicLocationTag - kCarBasicItemStartTag;
        
        NSInteger row0 = 0;
        NSInteger row1 = 0;
        // 省市名称
        NSMutableArray *provinceNames = [NSMutableArray array];
        for (int i = 0; i < _provinces.count; i++) {
            AreaProvinceItem *apItem = [_provinces objectAtIndex:i];
            [provinceNames addObject:apItem.PN];
            // 已选择省
            if (_mEvaluation.pid.integerValue == apItem.PI.integerValue)
                row0 = i;
        }
        
        // 城市名称
        NSMutableArray *cityNames = [NSMutableArray array];
        NSArray *citys = [(AreaProvinceItem *)[_provinces objectAtIndex:row0] CL];
        
        for (int i = 0; i < citys.count; i++) {
            AreaCityItem *acItem = [citys objectAtIndex:i];
            [cityNames addObject:acItem.CN];
            // 已选择市
            if (_mEvaluation.cid.integerValue == acItem.CI.integerValue)
                row1 = i;
        }
        
        _vSelector.dataSource = [NSMutableArray arrayWithObjects:provinceNames, cityNames, nil];
        [_vSelector selectRow:row0 inComponent:0 animated:NO];
        [_vSelector selectRow:row1 inComponent:1 animated:NO];
        
        //        textField.inputView = _vSelector;
    }
    // 首次上牌日期
    else if (textField.tag == kCarFirstregtimeTag) {
        NSInteger row0 = 0;
        NSInteger row1 = 0;
        NSMutableArray *dateSource = [self buildDateSource:0 strDate:_mEvaluation.firstregtime row0:&row0 row1:&row1];
        
        _vSelector.tag = kCarFirstregtimeTag - kCarBasicItemStartTag;
        _vSelector.dataSource = dateSource;
        [_vSelector selectRow:row0 inComponent:0 animated:NO];
        [_vSelector selectRow:row1 inComponent:1 animated:NO];
        //        textField.inputView = _vSelector;
    }
    
    // 控制视图高度
    if (DEVICE_IS_IPHONE5) {
        [UIView animateWithDuration:0.25 animations:^{
            _btnCloseKeyboard.maxY = self.height - 216 + 5;
            _btnCloseKeyboard.alpha = 1;
        }];
    } else {
        CGFloat minYMainView = 0;
        
        if (textField.tag == kCarBasicCarInfoTag || textField.tag == kCarFirstregtimeTag)
            minYMainView = 0;
        else if (textField.tag == kCarBasicDriveMileageTag)
            minYMainView = 37;
        else if (textField.tag == kCarBasicLocationTag)
            minYMainView = 81;
        
        [UIView animateWithDuration:0.25 animations:^{
            _btnCloseKeyboard.maxY = self.height - 216 + 5;
            _btnCloseKeyboard.alpha = 1;
            _svMain.contentOffset = CGPointMake(0, minYMainView);
        }];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSRange rDot = [textField.text rangeOfString:@"."];
    if (rDot.location != NSNotFound && [string isEqualToString:@"."])
        return NO;
    
    if (range.location > rDot.location && string.length > 0 && textField.text.length - rDot.location > 2)
        return NO;
    
    if (textField.tag == kCarBasicDriveMileageTag) {
        // 屏蔽以 “.” 和 "0" 开头
        if (([textField.text isEqualToString:@""] && [string isEqualToString:@"."])
            || ([textField.text isEqualToString:@"0"] && ![string isEqualToString:@"."] && string.length > 0))
            return NO;
        //
        NSMutableString *str = [NSMutableString stringWithString:textField.text];
        if (string.length > 0)
            [str insertString:string atIndex:range.location];
        else
            [str deleteCharactersInRange:range];
        
        // 行驶里程
        if (textField.tag == kCarBasicDriveMileageTag) {
            // 禁止空格
            unichar uc = [string characterAtIndex: [string length]-1];
            //禁止输入空格 ASCII ==32
            if (uc == 32)
                return NO;
            
            // 限制字数
            NSInteger surplus = 5 - textField.text.length;
            if (string.length > surplus)
                return NO;
            
            if (str.doubleValue >= 100)
                return NO;
            
            // 行驶里程 数据保存到实体
            _mEvaluation.mileage = [NSNumber numberWithDouble:[str doubleValue]];
            _mEvaluation.mileageText = [NSString stringWithFormat:@"%@万公里",str];
        }
        // 设置标题为正常颜色
        UILabel *labTitle = (UILabel *)[_svMain viewWithTag:textField.tag + 10000];
        [labTitle setTextColor:kColorNewGray1];
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    // 车辆信息
    if (textView == _tvCarInfo) {
        [self closeKeyBoard];
        [self switchChooseCarView];
        return NO;
    }
    return YES;
}

#pragma mark - UISelectorViewDelegate
- (void)selectorView:(UISelectorView *)selectorView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UILabel *labTitle = (UILabel *)[self viewWithTag:kCarTitleStarTag + selectorView.tag - 1];
    // 设置标题为正常颜色
    [labTitle setTextColor:kColorNewGray1];
    
    UITextField *tfItem = (UITextField *)[self viewWithTag:kCarBasicItemStartTag + selectorView.tag];
    
    // 所在城市
    if (selectorView.tag == kCarBasicLocationTag - kCarBasicItemStartTag) {
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
        NSString *provinceId = apItem.PI.stringValue;
        NSString *provinceName = apItem.PN;
        // 市
        AreaCityItem *acItem = [apItem.CL objectAtIndex:row1];
        NSString *cityId = acItem.CI.stringValue;
        NSString *cityName = acItem.CN;
        
        // 设置显示数据
        tfItem.text = [NSString stringWithFormat:@"%@ %@", provinceName, cityName];
        
        // 保存数据到实体
        _mEvaluation.pid = [NSNumber numberWithInteger:provinceId.integerValue];
        _mEvaluation.cid = [NSNumber numberWithInteger:cityId.integerValue];
        _mEvaluation.pidText = provinceName;
        _mEvaluation.cidText = cityName;
    }
    // 首次上牌日期
    else if (selectorView.tag == kCarFirstregtimeTag - kCarBasicItemStartTag) {
        NSString *year = [[selectorView.dataSource objectAtIndex:0] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:0] row]];
        NSString *month = [[selectorView.dataSource objectAtIndex:1] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:1] row]];
        // 保存数据到实体
        _mEvaluation.firstregtime = [NSString stringWithFormat:@"%@,%@", year, month];
        _mEvaluation.firstregtimeText = [NSString stringWithFormat:@"%@年",year];
        // 显示选中的日期
        tfItem.text = [NSString stringWithFormat:@"%@年%@月", year, month];
        
    }
}

#pragma mark - UCChooseCarViewDelegate
- (void)chooseCarView:(UCChooseCarView *)vChooseCar didFinishChooseWithInfo:(NSMutableDictionary *)info
{
    if (info) {
        NSString *seriesID = [info objectForKey:@"seriesid"];
        NSString *productID = [info objectForKey:@"specid"];
        NSString *brandName = [info objectForKey:@"brandidText"];
        NSString *seriesName = [info objectForKey:@"seriesidText"];
        NSString *productName = [info objectForKey:@"specidText"];
        NSString *brandid = [info objectForKey:@"brandid"];
        
        _mEvaluation.specid = [NSNumber numberWithInteger:productID.integerValue];
        _mEvaluation.brandText = brandName;
        _mEvaluation.seriesid = [NSNumber numberWithInteger:seriesID.integerValue];
        _mEvaluation.seriesidText = seriesName;
        _mEvaluation.specidText = productName;
        _mEvaluation.brandid = [NSNumber numberWithInteger:brandid.integerValue];
        
        UILabel *labTitle = (UILabel *)[_svMain viewWithTag:kCarBasicCarInfoTag + 10000];
        if (seriesID && productID) {
            // 设置标题为正常颜色
            [labTitle setTextColor:kColorNewGray1];
            _tvCarInfo.text = [[NSString stringWithFormat:@"%@ %@",seriesName, productName] omitForSize:CGSizeMake(_svMain.width - _tvCarInfo.minX - 30, 20) font:_tvCarInfo.font];
        } else {
            [[AMToastView toastView] showMessage:@"选择车辆信息异常" icon:kImageRequestError duration:AMToastDurationNormal];
        }
    }
    [[MainViewController sharedVCMain] closeView:vChooseCar animateOption:AnimateOptionMoveUp];
    
}

- (void)chooseCarViewDidCancel:(UCChooseCarView *)vChooseCar
{
    [[MainViewController sharedVCMain] closeView:vChooseCar animateOption:AnimateOptionMoveUp];
}

#pragma mark - UCEvaluationDetailViewDelegate
-(void)didSuccessedReleaseCarWtihUCEvaluationDetailView:(UCEvaluationDetailView *)vEvaluationDetail
{
    _mCarInfoEdit = nil;
    _mCarInfoEdit = [[UCCarInfoEditModel alloc] init];
    _mEvaluation = nil;
    _mEvaluation = [[UCEvaluationModel alloc] init];
    _tvCarInfo.text = @"";
    for (int i = 0; i < 4; i++) {
        UITextField *tfItem = (UITextField *)[_svMain viewWithTag:kCarBasicItemStartTag + i + 1];
        tfItem.text = @"";        
    }
}

#pragma mark - SwitchView
/* 选择车辆信息 */
- (void)switchChooseCarView
{
    if (![[MainViewController sharedVCMain].vTop isKindOfClass:[UCChooseCarView class]]) {
        [self endEditing:YES];
        UCChooseCarView *vChooseCar = [[UCChooseCarView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds viewStyle:UCFilterBrandViewStyleModel isTop:NO];
        vChooseCar.delegate = self;
        [[MainViewController sharedVCMain] openView:vChooseCar animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
    }
}

/** 构建时间 */
- (NSMutableArray *)buildDateSource:(NSInteger)incremental strDate:(NSString *)strDate row0:(NSInteger *)row0 row1:(NSInteger *)row1
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit;
    NSDateComponents *comps  = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSInteger year = [comps year] + incremental;
    //NSInteger month = [comps month];
    
    NSMutableArray *dateSource = nil;
    
    // 正常时间 年 月
    if (incremental >= 0) {
        // 已选中处理
        NSString *selectedYear = nil;
        NSString *selectedMonth = nil;
        NSInteger seletedRow0 = 0;
        NSInteger seletedRow1 = 0;
        if (strDate) {
            NSArray *year_month = [strDate componentsSeparatedByString:@","];
            if (year_month.count == 2) {
                selectedYear = [year_month objectAtIndex:0];
                selectedMonth = [year_month objectAtIndex:1];
            }
        }
        
        NSMutableArray *years = [NSMutableArray array];
        NSMutableArray *months = [NSMutableArray array];
        
        NSInteger count = 20;
        for (NSInteger i = 0; i < count; i++) {
            NSString *tmpYear = [NSString stringWithFormat:@"%d", year - i];
            if ([selectedYear isEqualToString:tmpYear])
                seletedRow0 = i;
            [years addObject:tmpYear];
        }
        for (NSInteger i = 0; i < 12; i++) {
            NSString *tmpMonth = [NSString stringWithFormat:@"%d", i + 1];
            if ([selectedMonth isEqualToString:tmpMonth])
                seletedRow1 = i;
            [months addObject:tmpMonth];
        }
        *row0 = seletedRow0;
        *row1 = seletedRow1;
        
        dateSource = [NSMutableArray arrayWithObjects:years, months, nil];
    }
    
    // 过期时间
    else {
        NSMutableArray *years = [NSMutableArray array];
        [years addObject:@"已过期"];
        [years addObject:[NSString stringWithFormat:@"%d", year + 1]];
        [years addObject:[NSString stringWithFormat:@"%d", year + 2]];
        
        NSInteger seletedRow0 = 0;
        for (int i = 0; i < years.count; i++) {
            if ([strDate isEqualToString:[years objectAtIndex:i]])
                seletedRow0 = i;
        }
        *row0 = seletedRow0;
        
        dateSource = [NSMutableArray arrayWithObjects:years, nil];
    }
    
    return dateSource;
}

- (void)closeKeyBoard
{
    [self endEditing:NO];
    
    // 边框变色
    for (int i = 0; i < 4; i++) {
        UITextField *tfItem = (UITextField *)[_svMain viewWithTag:kCarBasicItemStartTag + i + 1];
        tfItem.layer.borderColor = kColorGrey3.CGColor;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        _btnCloseKeyboard.maxY = self.height;
        _btnCloseKeyboard.alpha = 0;
        
        [_svMain setContentOffset:CGPointMake(0, 0)];
    }];
}

#pragma mark - APIHelper
/** 估价 */
- (void)evaluatePrice:(UCEvaluationModel *)mEvaluation viewType:(UCEvaluationDetailViewType)viewType
{
    [[AMToastView toastView:YES] showLoading:@"正在加载中..." cancel:^{
        [_apiEvaluationHelper cancel];
    }];
    
    __weak UCEvaluationView *vEvaluation = self;
    // 设置请求完成后回调方法
    [_apiEvaluationHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 任何一个连接已经失败或成功均可提示
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    // 估价详情数据
                    vEvaluation.vEvaluationDetail = [[UCEvaluationDetailView alloc] initWithFrame:vEvaluation.bounds evaluationModel:vEvaluation.mEvaluation carInfoEditModel:vEvaluation.mCarInfoEdit viewType:viewType];
                    vEvaluation.vEvaluationDetail.delegate = vEvaluation;
                    [[MainViewController sharedVCMain] openView:vEvaluation.vEvaluationDetail animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
                    [vEvaluation.vEvaluationDetail reloadPriceView:[[UCEvaluationPriceModel alloc] initWithJson:mBase.result]];
                    [[AMToastView toastView] hide];
                } else {
                    if (mBase.message) {
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                    }
                    else{
                        [[AMToastView toastView] hide];
                    }
                }
            }
        } else {
            [[AMToastView toastView] hide];
        }
    }];
    
    NSNumber *type = [NSNumber numberWithInteger:viewType == UCEvaluationDetailViewTypeSellCar ? 1 : 0];
    [_apiEvaluationHelper getEvaluetionPrice:mEvaluation type:type];
}

- (void)dealloc
{
    [_apiEvaluationHelper cancel];
    [[AMToastView toastView] hide];
    AMLog(@"dealloc...");
}

@end
