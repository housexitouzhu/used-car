//
//  UCSearchView.m
//  UsedCar
//
//  Created by wangfaquan on 14-5-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSearchView.h"
#import "AMCacheManage.h"
#import "UCSearchCell.h"
#import "UCCarBrandModel.h"
#import "UCCarSeriesModel.h"
#import "UCCarSpecModel.h"

@interface UCSearchView()

@property (nonatomic, strong) UIButton *btnSearchCancel;
@property (nonatomic, strong) UIView *vLine1;
@property (nonatomic, strong) NSMutableDictionary *dicCarModelInfo;
@property (nonatomic) BOOL isShowCancelButton;
@property (nonatomic, strong) NSNotification *lastNotification;
@property (nonatomic) BOOL isLightView;

@end

@implementation UCSearchView

- (id)initWithFrame:(CGRect)frame isShowCancelButton:(BOOL)isShowCancelButton
{
    self = [super initWithFrame:frame];
    if (self) {
        _isShowCancelButton = isShowCancelButton;
        _dicCarModelInfo = [[NSMutableDictionary alloc] init];
        [self initViewWithFrame:frame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame isShowCancelButton:(BOOL)isShowCancelButton isLightView:(BOOL)isLightView
{
    self = [super initWithFrame:frame];
    if (self) {
        _isLightView = isLightView;
        _isShowCancelButton = isShowCancelButton;
        _dicCarModelInfo = [[NSMutableDictionary alloc] init];
        [self initViewWithFrame:frame];
    }
    return self;
}

#pragma mark - initView
- (void)initViewWithFrame:(CGRect)frame
{
    // 搜索框
    CGFloat tfSearchWidth = 245;
    
    if (!_isLightView) {
        
        //设置搜索 textfield 的宽度
        tfSearchWidth = 260;
        
        // 搜索图片视图
        _ivSearchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55, frame.size.height)];
        _ivSearchIcon.image = [UIImage imageNamed:@"home_seach_btn"];
        _ivSearchIcon.contentMode = UIViewContentModeCenter;
    }
    
    _tfSearch = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, tfSearchWidth, frame.size.height)];
    _tfSearch.delegate = self;
    _tfSearch.font = kFontLarge;
    _tfSearch.backgroundColor = kColorClear;
    _tfSearch.leftView = _ivSearchIcon;
    _tfSearch.leftViewMode = UITextFieldViewModeAlways;
    _tfSearch.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tfSearch.returnKeyType = UIReturnKeySearch;
    _tfSearch.enablesReturnKeyAutomatically = YES;
    _tfSearch.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _tfSearch.autocorrectionType = UITextAutocorrectionTypeNo;
    _tfSearch.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tfSearch.placeholder = @"输入品牌或车系";
    
    
    if (!_isLightView) {
        // 分割线
        _vLine1 = [[UIView alloc] initLineWithFrame:CGRectMake(_tfSearch.maxX + 3, (frame.size.height - 15) / 2, kLinePixel, 15) color:kColorNewLine];
        _vLine1.hidden = _isShowCancelButton ? NO : YES;
        
        UIView *vLine2 = [[UIView alloc] initLineWithFrame:CGRectMake(0, self.height - kLinePixel, self.width, kLinePixel) color:kColorNewLine];
        [self addSubview:vLine2];
        
        // 取消搜索
        _btnSearchCancel = [[UIButton alloc] initWithFrame:CGRectMake(_vLine1.maxX + 5, 0, 50, frame.size.height)];
        _btnSearchCancel.titleLabel.font = [UIFont systemFontOfSize:15];
        [_btnSearchCancel setTitle:@"取消" forState:UIControlStateNormal];
        [_btnSearchCancel setTitleColor:kColorBlue1 forState:UIControlStateNormal];
        [_btnSearchCancel addTarget:self action:@selector(onClickCancelSearch:) forControlEvents:UIControlEventTouchUpInside];
        if (!_isShowCancelButton)
            _btnSearchCancel.hidden = YES;
        
        [self addSubview:_btnSearchCancel];
    }
    
    // 列表
    _tvSelect = [[UITableView alloc] init];
    _tvSelect.userInteractionEnabled = YES;
    _tvSelect.delegate = self;
    _tvSelect.dataSource = self;
    
    // 解决中文联想监听不响应问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:_tfSearch];
    
    [self addSubview:_tfSearch];
    [self addSubview:_vLine1];
    
}

#pragma mark - public Method
/** 关闭列表 */
- (void)closeSearchList
{
    if (!_isLightView) {
        self.size = CGSizeMake(self.width, 42);
        _btnSearchCancel.hidden = _isShowCancelButton ? NO :YES;
        _vLine1.hidden = _isShowCancelButton ? NO : YES;
    }
    // 判断是否需要隐藏表
    
    [UIView animateWithDuration:kAnimateSpeedFast animations:^{
        _tvSelect.alpha = 0.0;
    } completion:^(BOOL finished) {
        _tvSelect.hidden = YES;
    }];
     
    _tfSearch.text = nil;
    
    [_tfSearch resignFirstResponder];
}

#pragma mark - private Method
- (void)resignKeyBoard
{
    [_tfSearch resignFirstResponder];
}

/* textFieldDidEndEditing 中文上屏监听不响应, 使用通知监听 */
- (void)textFieldTextDidChange:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UITextField class]]) {
        
        if ([_delegate respondsToSelector:@selector(UCSearchView:textFieldHaveChanged:)]) {
            [_delegate UCSearchView:self textFieldHaveChanged:notification.object];
        }

        //取消延迟隐藏
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fuzzyMatching:) object:_lastNotification];
        //延迟取消
        [self performSelector:@selector(fuzzyMatching:) withObject:notification afterDelay:0.3];
        
        _lastNotification = notification;
    }
}

- (void)fuzzyMatching:(NSNotification *)notification
{
    [self reloadSearchResultData:notification.object];
}

- (void)reloadSearchResultData:(UITextField *)tfSearch
{
    UITextField *textField = tfSearch;
    if (!_naCarNames) {
        _naCarNames = [NSMutableArray array];
    }
    [_naCarNames removeAllObjects];
    NSArray *allCarDatas = [AMCacheManage fuzzySearchCar:textField.text];
    [_naCarNames addObjectsFromArray:allCarDatas];
    [_tvSelect reloadData];
    
}

#pragma mark - onClickButton
/** 取消搜索 */
- (void)onClickCancelSearch:(UIButton *)btn
{
    if ([_delegate respondsToSelector:@selector(didClickCancelButton:)])
        [_delegate didClickCancelButton:self];
    
    if ([_delegate respondsToSelector:@selector(willCloseSearchView:)])
        [_delegate willCloseSearchView:self];
    
    [self closeSearchList];
}

#pragma mark -  UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL isBool = YES;
    if ([_delegate respondsToSelector:@selector(UCSearchView:textFieldShouldBeginEditing:)])
         isBool = [_delegate UCSearchView:self textFieldShouldBeginEditing:textField];
    
    // 显示白色列表
    
    _tvSelect.hidden = NO;
    [UIView animateWithDuration:kAnimateSpeedFast animations:^{
        _tvSelect.alpha = 1.0;
        
    }];
    
    self.hidden = NO;
    [UIView animateWithDuration:kAnimateSpeedFlash animations:^{
        
        _btnSearchCancel.hidden = NO;
        _vLine1.hidden = NO;
    }];

    return isBool;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL isBool = YES;
    if ([_delegate respondsToSelector:@selector(UCSearchView:textFieldShouldReturn:)])
        isBool = [_delegate UCSearchView:self textFieldShouldReturn:textField];
    
    [textField resignFirstResponder];
   
    return isBool;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)strin
{
    return YES;
}

//- (BOOL)textFieldShouldClear:(UITextField *)textField{
//    if ([self.delegate UCSearchView:self textFieldShouldClear:textField]) {
//        [self.delegate UCSearchView:self textFieldShouldClear:textField];
//    }
//    return YES;
//}

#pragma mark -  TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_naCarNames.count == 0) {
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        return 0;
    } else {
         [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        return [_naCarNames count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuse = @"carCell";
    UCSearchCell *cell = [tableview dequeueReusableCellWithIdentifier:reuse];
    tableview.contentInset = UIEdgeInsetsZero;
    if (!cell) {
        cell = [[UCSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
    }
    [cell makeView:[_naCarNames objectAtIndex:indexPath.row] isShowSelect:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableVie didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_dicCarModelInfo removeAllObjects];
    NSObject *model = [_naCarNames objectAtIndex:indexPath.row];
    NSString *strClass = NSStringFromClass(model.class);
    // 品牌
    if ([strClass isEqualToString:@"UCCarBrandModel"])
        [_dicCarModelInfo setValue:[_naCarNames objectAtIndex:indexPath.row] forKey:@"brand"];
    // 车系
    else if ([strClass isEqualToString:@"UCCarSeriesModel"])
        [_dicCarModelInfo setValue:[_naCarNames objectAtIndex:indexPath.row] forKey:@"series"];
    // 车型
    else if ([strClass isEqualToString:@"UCCarSpecModel"])
        [_dicCarModelInfo setValue:[_naCarNames objectAtIndex:indexPath.row] forKey:@"spec"];
    
    // 品牌
    UCCarBrandModel *mCarBrand = [_dicCarModelInfo objectForKey:@"brand"];
    // 车系
    UCCarSeriesModel *mCarSeries = [_dicCarModelInfo objectForKey:@"series"];
    // 车型
    UCCarSpecModel *mCarSpec = [_dicCarModelInfo objectForKey:@"spec"];
    
    // 根据车型获车系
    if (mCarSpec) {
        // 车系
        NSArray *series = [AMCacheManage selectFrome:@"CarSeries" where:@"SeriesId" equalValue:mCarSpec.fatherId];
        if (series.count > 0) {
            mCarSeries = [[UCCarSeriesModel alloc] initWithJson:[series objectAtIndex:0]];
            // 存储车系
            [_dicCarModelInfo setValue:mCarSeries forKey:@"series"];
        }
    }
    // 根据车系获取车牌
    if (mCarSeries) {
        // 车牌
        NSArray *brand = [AMCacheManage selectFrome:@"CarBrand" where:@"BrandId" equalValue:mCarSeries.fatherId];
        if (brand.count > 0) {
            mCarBrand = [[UCCarBrandModel alloc] initWithJson:[brand objectAtIndex:0]];
            [_dicCarModelInfo setValue:mCarBrand forKey:@"brand"];
        }
    }

    [_tfSearch resignFirstResponder];
    
    
    if ([_delegate respondsToSelector:@selector(willCloseSearchView:)])
        [_delegate willCloseSearchView:self];
    
    if ([self.delegate respondsToSelector:@selector(searchView:dicCarModel:)]) {
        [_delegate searchView:self dicCarModel:_dicCarModelInfo];
    }
}

/** 监听tableView滑动时收起键盘 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_tfSearch resignFirstResponder];
}

@end



