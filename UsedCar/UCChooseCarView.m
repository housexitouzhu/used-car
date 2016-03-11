//
//  UCChooseCarView.m
//  UsedCar
//
//  Created by 张鑫 on 13-11-27.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCChooseCarView.h"
#import "UCTopBar.h"
#import "MainViewController.h"
#import "UIImage+Util.h"
#import "UCFilterBrandView.h"
#import "UISelectorView.h"
#import "UCFilterModel.h"
#import "UCSearchView.h"
#import "UCAutonomyAddView.h"
#import "UCCarBrandModel.h"
#import "UCCarSeriesModel.h"
#import "UCCarSpecModel.h"

#define kCarDisplacementTag 2300

@interface UCChooseCarView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UITextField *tfName;
@property (nonatomic, strong) NSMutableDictionary *dicCarModel;     // 返回数据
@property (nonatomic, strong) UIView *vTransmissionBg;
@property (nonatomic, strong) UITextField *tfDisplacement;
@property (nonatomic, strong) UISelectorView *vSelector;
@property (nonatomic, strong) UIButton *btnSubmit;
@property (nonatomic, strong) NSMutableArray *naCarNames;
@property (nonatomic, strong) UCSearchView *vSearchView;
@property (nonatomic, strong) UCFilterBrandView *vFilterBrand;
@property (nonatomic) BOOL isShowMaskView;                          // 是否显示遮罩层
@property (nonatomic) BOOL isCustomCarView;                         // 是否包含自定义栏目
@property (nonatomic) UCFilterBrandViewStyle viewStyle;
@property (nonatomic, strong) UILabel *labTitles ;
@property (nonatomic, assign) CGFloat minYFilter;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UCFilterModel *mFilter;

@end

@implementation UCChooseCarView

- (id)initWithCustomCarFrame:(CGRect)frame viewStyle:(UCFilterBrandViewStyle)viewStyle
{
    // 包含自定义车辆视图
    _isCustomCarView = YES;
    return [self initWithFrame:frame viewStyle:viewStyle isTop:NO];
}

- (id)initWithCustomCarFrame:(CGRect)frame viewStyle:(UCFilterBrandViewStyle)viewStyle carName:(NSString *)carName mAFilter:(UCFilterModel *)filter
{
    // 包含自定义车辆视图
    _carNames = carName;
    _mFilter = [[UCFilterModel alloc] init];
    _mFilter = filter;
    return [self initWithFrame:frame viewStyle:viewStyle isTop:YES];
}

- (id)initWithFrame:(CGRect)frame viewStyle:(UCFilterBrandViewStyle)viewStyle isTop:(BOOL)isTop
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dicCarModel = [NSMutableDictionary dictionary];
        _viewStyle = viewStyle;
        if (isTop == YES) {
            [self initView:YES];
        } else {
            [self initView:NO];
        }
        
    }
    return self;
}

#pragma mark - initView
- (void)initView:(BOOL)isTop
{
    self.backgroundColor = kColorWhite;
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    
    // 标题
    [self.tbTop.btnTitle setTitle:@"选择车型" forState:UIControlStateNormal];
    [self.tbTop.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    [self.tbTop.btnLeft addTarget:self action:@selector(onClickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    
    if (isTop == YES) {
        [self.tbTop.btnTitle setTitle:@"车型纠错" forState:UIControlStateNormal];
        
        _labTitles = [[UILabel alloc] initLineWithFrame:CGRectMake(10, _tbTop.maxY + 5, self.width - 10, 34) color:kColorWhite];
        _labTitles.text = [NSString stringWithFormat:@"%@%@",@"当前车型:",_carNames];
        _labTitles.textColor = kColorGrey3;
        _labTitles.font = kFontSmall;
        // 分割线
        UIView *vLines = [[UIView alloc] initLineWithFrame:CGRectMake(0, _labTitles.maxY + 1 , self.width, kLinePixel) color:kColorNewLine];
        [self addSubview:_labTitles];
        [self addSubview:vLines];
        
        _minYFilter = vLines.maxY;
    } else {
        _minYFilter = self.tbTop.maxY;
    }
    
    // 有自定义车名
    if (_isCustomCarView) {
        [self.tbTop.btnRight setTitle:@"添加车型" forState:UIControlStateNormal];
        [self.tbTop.btnRight addTarget:self action:@selector(onClickAddBtn:) forControlEvents:UIControlEventTouchUpInside];
        _naCarNames = [NSMutableArray array];
        _vSearchView = [[UCSearchView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, 42) isShowCancelButton:NO];
        _vSearchView.delegate = self;
        _vSearchView.backgroundColor = kColorWhite;
        [self addSubview:_vSearchView];
        _minYFilter = _vSearchView.maxY;
    }
    
    // 选车
    UCFilterModel *mFilter = [[UCFilterModel alloc] init];
    if (_carNames) {
        mFilter = _mFilter;
    }
    _vFilterBrand = [[UCFilterBrandView alloc] initWithFrame:CGRectMake(0, _minYFilter, self.width, self.height - _minYFilter) filter:mFilter UCFilterBrandViewStyle:_viewStyle];
    _vFilterBrand.delegate = self;
    [self addSubview:_vFilterBrand];
    if (_carNames) {
        [_vFilterBrand setSelectedCells];
    }
    // 有自定义车名
    if (_isCustomCarView)
        [self creatTransmissionView];
    
    // 添加搜索框
    _vSearchView.tvSelect.frame = CGRectMake(0, _vSearchView.maxY, self.width, self.height - _vSearchView.maxY);
    _vSearchView.tvSelect.hidden = YES;
    _vSearchView.tvSelect.alpha = 0.0;
    [self addSubview:_vSearchView.tvSelect];
}

- (void)creatTransmissionView
{
    // 变速箱和排量背景
    _vTransmissionBg = [[UIView alloc] initWithFrame:self.bounds];
    _vTransmissionBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    _vTransmissionBg.hidden = YES;
    
    // 变速箱和排量背景
    UIView *vTransmission = [[UIView alloc] initWithFrame:CGRectMake((self.width - 250) / 2, (self.height - 150)/2 , 250, 141)];
    vTransmission.backgroundColor = kColorWhite;
    vTransmission.layer.cornerRadius = 5;
    vTransmission.layer.masksToBounds = YES;
    
    // 分割线
    UIView *vLine1 = [[UIView alloc] initLineWithFrame:CGRectMake(0, 50, vTransmission.width, kLinePixel) color:kColorNewLine];
    
    UIView *vLine2 = [[UIView alloc] initLineWithFrame:CGRectMake(0, 100, vTransmission.width, kLinePixel) color:kColorNewLine];
    
    // 变速箱
    UILabel *labTransmission = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 70, 50)];
    labTransmission.text = @"变速箱:";
    labTransmission.textColor = kColorGrey2;
    labTransmission.font = [UIFont systemFontOfSize:15];
    
    // 手动挡
    UIButton *btnManual = [[UIButton alloc] initWithFrame:CGRectMake(labTransmission.maxX, 1, 72, 50)];
    btnManual.tag = 65274570;
    btnManual.selected = NO;
    [btnManual setTitle:@"手动" forState:UIControlStateNormal];
    btnManual.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnManual setTitleColor:kColorGray1 forState:UIControlStateNormal];
    [btnManual addTarget:self action:@selector(onClickTransmissionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btnManual setImage:[UIImage imageNamed:@"vehicle_circle"] forState:UIControlStateNormal];
    [btnManual setImage:[UIImage imageNamed:@"vehicle_circle_h"] forState:UIControlStateSelected];
    [btnManual setImage:[UIImage imageNamed:@"vehicle_circle_h"] forState:UIControlStateHighlighted];
    btnManual.imageEdgeInsets = UIEdgeInsetsMake(1, -10, 0, 0);
    
    // 自动挡
    UIButton *btnAutomatic = [[UIButton alloc] initWithFrame:CGRectMake(btnManual.maxX + 9, 1, 72, 50)];
    btnAutomatic.tag = 65274571;
    btnAutomatic.selected = NO;
    [btnAutomatic setTitle:@"自动" forState:UIControlStateNormal];
    btnAutomatic.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnAutomatic setTitleColor:kColorGray1 forState:UIControlStateNormal];
    [btnAutomatic addTarget:self action:@selector(onClickTransmissionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btnAutomatic setImage:[UIImage imageNamed:@"vehicle_circle"] forState:UIControlStateNormal];
    [btnAutomatic setImage:[UIImage imageNamed:@"vehicle_circle_h"] forState:UIControlStateSelected];
    [btnAutomatic setImage:[UIImage imageNamed:@"vehicle_circle_h"] forState:UIControlStateHighlighted];
    btnAutomatic.imageEdgeInsets = UIEdgeInsetsMake(1, -10, 0, 0);
    
    // 排量
    UILabel *labDisplacement = [[UILabel alloc] initWithClearFrame:CGRectMake(20, 50, 70, 50)];
    labDisplacement.text = @"排    量:";
    labDisplacement.textColor = kColorGrey2;
    labDisplacement.font = [UIFont systemFontOfSize:15];
    
    UILabel *labUnit = [[UILabel alloc] initWithClearFrame:CGRectMake(vTransmission.width - 30, 51, 10, 50)];
    labUnit.font = [UIFont systemFontOfSize:18];
    labUnit.text = @"L";
    labUnit.textColor = kColorGrey3;
    
    // 输入排量
    _tfDisplacement = [[UITextField alloc] initWithFrame:CGRectMake(labDisplacement.maxX - 30, 51, 140, 50)];
    _tfDisplacement.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfDisplacement.delegate = self;
    _tfDisplacement.tag = kCarDisplacementTag;
    _tfDisplacement.backgroundColor = [UIColor clearColor];
    _tfDisplacement.textAlignment = NSTextAlignmentCenter;
    
    // 初始化选择器
    NSArray *selectorNums = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    _vSelector = [[UISelectorView alloc] initWithFrame:CGRectMake(0, 0, self.width, 150)];
    _vSelector.colorSelector = kColorBlue1;
    _vSelector.delegate = self;
    _vSelector.backgroundColor = kColorGrey5;
    _vSelector.dataSource = [NSMutableArray arrayWithObjects:selectorNums,@[@"."], selectorNums, nil];
    [_vSelector selectRow:0 inComponent:0 animated:NO];
    [_vSelector selectRow:0 inComponent:1 animated:NO];
    _vSelector.colorStateNormal = kColorGray1;
    
    _tfDisplacement.inputView = _vSelector;
    
    // 取消
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, vLine2.maxY, 250 / 2, 41)];
    [btnCancel addTarget:self action:@selector(onClickCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnCancel setTitleColor:kColorBlue1 forState:UIControlStateNormal];
    [btnCancel setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnCancel.size] forState:UIControlStateHighlighted];
    
    // 分割线
    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(btnCancel.maxX, vLine2.minY + kLinePixel, kLinePixel, vTransmission.height - vLine2.maxY) color:kColorNewLine];
    [vTransmission addSubview:vLine];
    
    // 排量的确定按钮
    _btnSubmit = [[UIButton alloc] initWithFrame:CGRectMake(vLine.maxX, vLine2.maxY, 250 / 2, 41)];
    [_btnSubmit addTarget:self action:@selector(onClickSubmitBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_btnSubmit setTitle:@"确定" forState:UIControlStateNormal];
    [_btnSubmit setTitleColor:kColorBlue1 forState:UIControlStateNormal];
    [_btnSubmit setTitleColor:kColorGrey3 forState:UIControlStateDisabled];
    _btnSubmit.titleLabel.font = [UIFont systemFontOfSize:15];
    _btnSubmit.enabled = NO;
    [_btnSubmit setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:_btnSubmit.size] forState:UIControlStateHighlighted];
    
    [vTransmission addSubview:vLine1];
    [vTransmission addSubview:vLine2];
    [vTransmission addSubview:labTransmission];
    [vTransmission addSubview:btnManual];
    [vTransmission addSubview:btnAutomatic];
    [vTransmission addSubview:labDisplacement];
    [vTransmission addSubview:_tfDisplacement];
    [vTransmission addSubview:labUnit];
    [vTransmission addSubview:btnCancel];
    [vTransmission addSubview:_btnSubmit];
    
    [_vTransmissionBg addSubview:vTransmission];
    [self addSubview:_vTransmissionBg];
    
}

#pragma mark - private Method
//按下Done键关闭键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self switchReleaseMasView];
    return NO;
}

- (BOOL)UCSearchView:(UCSearchView *)vSearch textFieldShouldReturn:(UITextField *)textField
{
    if ([vSearch.naCarNames count] == 0)
        [[AMToastView toastView] showMessage:@"没有查询到相关结果" icon:kImageRequestError duration:AMToastDurationNormal];
    
    return YES;
}

- (void)switchReleaseMasView
{
    _isShowMaskView = !_isShowMaskView;
    
    static NSInteger vReleaseMaskTag = 41783142;
    UIView *vKeyboardMask = nil;
    
    if (_isShowMaskView) {
        // 初始化发车视图
        vKeyboardMask = [[UIView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY + 42, self.width , self.height - _tbTop.maxY + 42)];
        vKeyboardMask.backgroundColor = kColorWhite;
        vKeyboardMask.alpha = 1;
        vKeyboardMask.tag = vReleaseMaskTag;
        
        //添加点击回收键盘事件
        UITapGestureRecognizer *tapClosekeyboard  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClosekeyboard:)];
        [vKeyboardMask addGestureRecognizer:tapClosekeyboard];
        
        // 添加搜索视图
        [self addSubview:vKeyboardMask];
    } else {
        vKeyboardMask = (UIView *)[self viewWithTag:vReleaseMaskTag];
    }
    
    [UIView animateWithDuration:kAnimateSpeedNormal animations:^{
        if (_isShowMaskView)
            vKeyboardMask.alpha = 1;
        else
            vKeyboardMask.alpha = 0;
    } completion:^(BOOL finished) {
        if (!_isShowMaskView)
            [vKeyboardMask removeFromSuperview];
    }];
}

/** 回收键盘 */
- (void)tapClosekeyboard:(id)sender{
    
    [self switchReleaseMasView];
    _tfName.text = nil;
    [_tfName resignFirstResponder];
    
}

/** 判断是否确定键可点击 */
- (void)isEnableOKbtn{
    
    UIButton *btnManual = (UIButton *)[self viewWithTag:65274570];
    UIButton *btnAutomatic = (UIButton *)[self viewWithTag:65274571];
    
    BOOL isManualBtn = btnManual.selected;
    BOOL isAutomaticBtn = btnAutomatic.selected;
    
    if ((isManualBtn == NO && isAutomaticBtn == NO) || _tfDisplacement.text.length <= 0)
        _btnSubmit.enabled = NO;
    else
        _btnSubmit.enabled = YES;
    
}

#pragma mark - onClickButton
/** 返回 */
- (void)onClickBackBtn
{
    if ([self.delegate respondsToSelector:@selector(chooseCarViewDidCancel:)])
        [self.delegate chooseCarViewDidCancel:self];
}

/** 跳转到自主添加界面 */
- (void)onClickAddBtn:(UIButton *)btn
{
    [UMStatistics event:c_3_6_Selectcar_add];
    // 关闭模糊搜索
    [_vSearchView closeSearchList];
    
    UCAutonomyAddView *vAutonomyAdd = [[UCAutonomyAddView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    vAutonomyAdd.delegate = self;
    [[MainViewController sharedVCMain] openView:vAutonomyAdd animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

/** 确定 */
- (void)onClickOKBtn:(UIButton *)btn
{
    // 判断是否为空
    if ([[_tfName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || _tfName.text == nil) {
        [[AMToastView toastView] showMessage:@"自定义车辆名称不能为空" icon:kImageRequestError duration: AMToastDurationNormal];
        return;
    }
    
    // 收回键盘
    [_tfName resignFirstResponder];
    
    // 只接受关闭
    if (_isShowMaskView == YES)
        [self switchReleaseMasView];
    
    [_dicCarModel setObject:[_tfName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"CarName"];
    
    // 设置变速器，排量
    _vTransmissionBg.hidden = NO;
    
}

/** 取消 */
- (void)onClickCancelBtn:(UIButton *)button
{
    _vTransmissionBg.hidden = YES;
    // 重置数据
    _tfDisplacement.text = nil;
    UIButton *btnManual = (UIButton *)[self viewWithTag:65274570];
    btnManual.selected = NO;
    UIButton *btnAutomatic = (UIButton *)[self viewWithTag:65274571];
    btnAutomatic.selected = NO;
    [self isEnableOKbtn];
    [_tfDisplacement resignFirstResponder];
    
}
/** 确定 */
- (void)onClickSubmitBtn:(UIButton *)button
{
    UIButton *btnManual = (UIButton *)[self viewWithTag:65274570];
    UIButton *btnAutomatic = (UIButton *)[self viewWithTag:65274571];
    
    // 存储变速器
    if (btnManual.selected || btnAutomatic.selected)
        [_dicCarModel setObject:btnManual.selected ? @"手动" : @"自动" forKey:@"Gearbox"];
    else
        return;
    
    // 存储排量
    [_dicCarModel setObject:_tfDisplacement.text forKey:@"Displacement"];
    
    [_dicCarModel removeObjectForKey:@"ProductID"];
    [_dicCarModel removeObjectForKey:@"ProductName"];
    [_dicCarModel removeObjectForKey:@"BrandID"];
    [_dicCarModel removeObjectForKey:@"BrandName"];
    [_dicCarModel removeObjectForKey:@"SeriesID"];
    [_dicCarModel removeObjectForKey:@"SeriesName"];
    
    // 执行代理
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(chooseCarView:didFinishChooseWithInfo:)])
            [self.delegate chooseCarView:self didFinishChooseWithInfo:_dicCarModel];
    }
}

/** 选择手动档，自动挡 */
- (void)onClickTransmissionBtn:(UIButton *)button
{
    button.selected = YES;
    if (button.tag == 65274570) {
        UIButton *btnTemp = (UIButton *)[self viewWithTag:65274571];
        btnTemp.selected = NO;
    }else{
        UIButton *btnTemp = (UIButton *)[self viewWithTag:65274570];
        btnTemp.selected = NO;
    }
    
    // 判断确定键是否可点击
    [self isEnableOKbtn];
    
}

#pragma mark - UCAutonomyViewDelegate
/** 自主添加 */
- (void)UCAutonomyAddView:(UCAutonomyAddView *)mAutonomyAdd didFinishEditCarInfo:(NSDictionary *)carInfo
{
    if ([_delegate respondsToSelector:@selector(chooseCarView:didFinishChooseWithInfo:)])
        [_delegate chooseCarView:self didFinishChooseWithInfo:carInfo];
}

#pragma mark - UCFilterBrandViewDelegate
- (void)filterBrandView:(UCFilterBrandView *)vFilterBarnd filterModel:(UCFilterModel *)mFilter{
    [_dicCarModel setValue:mFilter.brandid forKey:@"brandid"];
    [_dicCarModel setValue:mFilter.brandidText forKey:@"brandidText"];
    [_dicCarModel setValue:mFilter.seriesid forKey:@"seriesid"];
    [_dicCarModel setValue:mFilter.seriesidText forKey:@"seriesidText"];
    [_dicCarModel setValue:mFilter.specid forKey:@"specid"];
    [_dicCarModel setValue:mFilter.specidText forKey:@"specidText"];
    [_dicCarModel removeObjectForKey:@"CarName"];
    [_dicCarModel removeObjectForKey:@"Displacement"];
    [_dicCarModel removeObjectForKey:@"Gearbox"];
    if ([self.delegate respondsToSelector:@selector(chooseCarView:didFinishChooseWithInfo:)])
        [self.delegate chooseCarView:self didFinishChooseWithInfo:_dicCarModel];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    // 排量
    if (textField.tag == kCarDisplacementTag) {
        _vTransmissionBg.hidden = NO;
        [_vSelector selectRow:0 inComponent:0 animated:NO];
        [_vSelector selectRow:0 inComponent:2 animated:NO];
    }
    // 车型
    else{
        [self switchReleaseMasView];
    }
    return YES;
}

#pragma mark - UISelectorViewDelegate
- (void)selectorView:(UISelectorView *)selectorView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _tfDisplacement.text = [NSString stringWithFormat:@"%@.%@",[[selectorView.dataSource objectAtIndex:0] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:0] row]],[[selectorView.dataSource objectAtIndex:0] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:2] row]]];
    _tfDisplacement.font = [UIFont systemFontOfSize:15];
    
    if ([_tfDisplacement.text isEqualToString:@"0.0"])
        _tfDisplacement.text = @"";
    
    // 判断确定键是否可点击
    [self isEnableOKbtn];
}

#pragma mark - UCSerchViewDelegate
- (void)searchView:(UCSearchView *)vSearch dicCarModel:(NSMutableDictionary *)dicCarModel
{
    // 关闭搜索框
    [vSearch closeSearchList];
    // 清除列表数据
    [vSearch.naCarNames removeAllObjects];
    [vSearch.tvSelect reloadData];
    
    UCCarBrandModel *mCarBrand = [dicCarModel objectForKey:@"brand"];
    UCCarSeriesModel *mCarSeries = [dicCarModel objectForKey:@"series"];
    UCCarSpecModel *mCarSpec = [dicCarModel objectForKey:@"spec"];
    
    [_dicCarModel setValue:mCarBrand.brandId forKey:@"brandid"];
    [_dicCarModel setValue:mCarBrand.name forKey:@"brandidText"];
    [_dicCarModel setValue:mCarSeries.seriesId forKey:@"seriesid"];
    [_dicCarModel setValue:mCarSeries.name forKey:@"seriesidText"];
    [_dicCarModel setValue:mCarSpec.specId forKey:@"specid"];
    [_dicCarModel setValue:mCarSpec.name forKey:@"specidText"];
    [_dicCarModel removeObjectForKey:@"CarName"];
    [_dicCarModel removeObjectForKey:@"Displacement"];
    [_dicCarModel removeObjectForKey:@"Gearbox"];
    
    // 车型直接关闭
    if (mCarBrand && mCarSeries && mCarSpec) {
        if ([self.delegate respondsToSelector:@selector(chooseCarView:didFinishChooseWithInfo:)]) {
            [self.delegate chooseCarView:self didFinishChooseWithInfo:_dicCarModel];
            return;
        }
    }
    
    // 设置选中cell
    [_vFilterBrand removeFromSuperview];
    _vFilterBrand = nil;
    
    UCFilterModel *mFilter = [[UCFilterModel alloc] init];
    mFilter.brandid = mCarBrand.brandId;
    mFilter.brandidText = mCarBrand.name;
    mFilter.seriesid = mCarSeries.seriesId;
    mFilter.seriesidText = mCarSeries.name;
    mFilter.specid = mCarSpec.specId;
    mFilter.specidText = mCarSpec.name;
    
    // 品牌筛选
    _vFilterBrand = [[UCFilterBrandView alloc] initWithFrame:CGRectMake(0, self.tbTop.maxY + 40, self.width, self.height - _vSearchView.maxY) filter:mFilter UCFilterBrandViewStyle:_viewStyle];
    _vFilterBrand.delegate = self;
    [self insertSubview:_vFilterBrand belowSubview:_vSearchView];
    
    // 选中状态
    [_vFilterBrand setSelectedCells];
}

/** 获取焦点 */
- (BOOL)UCSearchView:(UCSearchView *)vSearch textFieldShouldBeginEditing:(UITextField *)textField
{
    // 刷新数据
    if (textField.text.length > 0) {
        [vSearch reloadSearchResultData:textField];
    }
    
    return YES;
}

/** 关闭空间 */
-(void)willCloseSearchView:(UCSearchView *)vSearch
{
    [UMStatistics event:c_3_6_Selectcar_search];
}

- (void)didClickCancelButton:(UCSearchView *)vSearch
{
    // 清空列表
    [vSearch.naCarNames removeAllObjects];
    [vSearch.tvSelect reloadData];
}

@end
