//
//  UCAttentionDetailView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-21.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCAttentionDetailView.h"
#import "UCTopBar.h"
#import "AMBlurView.h"
#import "UIImage+Util.h"
#import "UCOptionBar.h"
#import "UCAreaMode.h"
#import "NSString+Util.h"
#import "UCAttentionDetailHeader.h"
#import "UCAttentionDetailList.h"
#import "UCCarAttenModel.h"
#import "UCFilterModel.h"

#define kOrderScrollViewTag            34582944
#define kOrderShadowStartTag           200000
#define kOrderByPriceArrowTag          28394081

@interface UCAttentionDetailView ()
<UCAttentionDetailListDelegate, UIScrollViewDelegate, UCOptionBarDelegate>

@property (nonatomic, strong) UIView *vStatusBar;
@property (nonatomic, strong) UIScrollView *svOrder;    // 排序
@property (nonatomic, strong) AMBlurView *bvToolBar;
@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCAttentionDetailHeader *vHeader;
@property (nonatomic, strong) UCAttentionDetailList *vCarList;
@property (nonatomic, strong) UCOptionBar *obFilter;

@property (nonatomic) CGFloat lastScrollOffsetY;
@property (nonatomic) CGFloat nodeScrollOffsetY;
@property (nonatomic) NSInteger scrollDirection;
@property (nonatomic, strong) UCAreaMode *mArea;

@property (nonatomic, strong) NSArray *orderValues;
@property (nonatomic, strong) NSString *keyWord;
@property (nonatomic, assign) NSInteger resultCount;

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSMutableArray *attArray;

@end

@implementation UCAttentionDetailView

- (id)initWithFrame:(CGRect)frame withAttentionModel:(UCCarAttenModel*)mCarAttention attentionDictionary:(NSMutableDictionary*)dict;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _mCarAttention = mCarAttention;
        _dicReadNew = dict;
        _attArray = [[NSMutableArray alloc] init];
        
        NSArray *arr = [_dicReadNew valueForKey:[NSString stringWithFormat:@"%@",_mCarAttention.attenID]];
        if (arr.count>0){
            [_attArray addObjectsFromArray:[_dicReadNew valueForKey:[NSString stringWithFormat:@"%@",_mCarAttention.attenID]]];
        }
        
        self.mFilter = [[UCFilterModel alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FilterValues" ofType:@"plist"];
        NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
        self.orderValues = values[@"Order"];
        
        if (_mCarAttention.Name.length > 0)
            self.title = _mCarAttention.Name;
        else
            self.title = @"全部品牌";
        
        [self initView];
    }
    return self;
}

- (void)initView{
    
    self.clipsToBounds = YES;
    self.backgroundColor = kColorWhite;
    
    // 状态栏
    _vStatusBar = [self creatStatusBarView:CGRectMake(0, 0, self.width, 20)];
    [self addSubview:_vStatusBar];
    // 头视图(导航)
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    
    [self createToolBar];
    [self createResultHeader];
    
    _vCarList = [self creatAttentionListView:CGRectMake(0, _tbTop.maxY, self.width, self.height-_tbTop.maxY)];
    
    [_vCarList refreshCarList];
    [self addSubview:_vCarList];
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
    
    [_tbTop.btnTitle setTitle:self.title forState:UIControlStateNormal];
    [_tbTop.btnTitle setTitleColor:kColorWhite forState:UIControlStateNormal];
    
    return _tbTop;
}
/** 工具栏 */
-(void)createToolBar{
    // 工具栏
    _bvToolBar = [[AMBlurView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, kTopOptionHeight)];
    _bvToolBar.clipsToBounds = YES;
    _bvToolBar.isEnableBlur = NO;
    
    // 筛选栏
    _svOrder = [self creatFilterScrollView:CGRectMake(10, 0, self.width - 10 * 2, kTopOptionHeight)];
    
    [_bvToolBar addSubview:_svOrder];
    
    // 屏蔽iPhone6
    if (_svOrder.contentSize.width > _svOrder.width) {
        
        // 左右边距
        UIImage *iLeft = [UIImage imageNamed:@"screennotes_cover_l_icon"];
        UIImageView *ivLeft = [[UIImageView alloc] initWithImage:iLeft];
        ivLeft.origin = CGPointMake(-iLeft.width + 15, 0);
        ivLeft.hidden = YES;
        ivLeft.tag = kOrderShadowStartTag + 0;
        
        UIImage *iRight = [UIImage imageNamed:@"screennotes_cover_icon"];
        UIImageView *ivRight = [[UIImageView alloc] initWithFrame:CGRectMake(_bvToolBar.width - 15, 0, iRight.width, iRight.height)];
        ivRight.image = iRight;
        ivRight.hidden = NO;
        ivRight.tag = kOrderShadowStartTag + 1;
        [_bvToolBar addSubview:ivLeft];
        [_bvToolBar addSubview:ivRight];
    }
   
    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, _bvToolBar.height - kLinePixel, _bvToolBar.width, kLinePixel) color:kColorNewLine];
    [_bvToolBar addSubview:vLine];
    [self addSubview:_bvToolBar];
    _bvToolBar.hidden = YES;
}

/** 筛选条 */
- (UIScrollView *)creatFilterScrollView:(CGRect)frame
{
    CGFloat width = 69;
    NSArray *titles = @[@"最新", @"价格", @"车龄短", @"里程少", @"资料全"];
    
    _svOrder = [[UIScrollView alloc] initWithFrame:frame];
    _svOrder.delegate = self;
    _svOrder.tag = kOrderScrollViewTag;
    _svOrder.showsHorizontalScrollIndicator = NO;
    _svOrder.showsVerticalScrollIndicator = NO;
    _svOrder.contentInset = UIEdgeInsetsMake(0, -10, 0, -10);
    [_svOrder setContentSize:CGSizeMake(titles.count * width, CGRectGetHeight(frame))];
    
    // 底部条
    UIView *vSlider = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 4, 41, 4)];
    vSlider.backgroundColor = kColorBlue;
    
    // 筛选条
    _obFilter = [[UCOptionBar alloc] initWithFrame:CGRectMake(0, 0, titles.count * width, frame.size.height) sliderView:vSlider];
    _obFilter.isAutoAdjustSlider = YES;
    _obFilter.delegate = self;
    _obFilter.isEnableBlur = NO;
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger i = 0; i < titles.count; i++) {
        UCOptionBarItem *item = [[UCOptionBarItem alloc] init];
        item.titleFont = kFontLarge;
        item.titleColor = kColorNewGray1;
        item.titleColorSelected = kColorBlue;
        item.title = titles[i];
        
        // 价格
        if (i == 1) {
            UIImage *iorder = [UIImage imageNamed:@"price_all_icon"];
            UIImageView *ivOrder = [[UIImageView alloc] initWithImage:iorder];
            ivOrder.origin = CGPointMake(0, 0);
            ivOrder.tag = kOrderByPriceArrowTag;
            
            UIView *vRight = [[UIView alloc] initWithFrame:CGRectMake(-ivOrder.width - 10, 12.5, ivOrder.width + 1, ivOrder.height)];
            
            [vRight addSubview:ivOrder];
            item.rightView = vRight;
        }
        
        [items addObject:item];
    }
    
	[_obFilter setItems:items];
    [_obFilter selectItemAtIndex:0];
    _svOrder.contentSize = CGSizeMake(_obFilter.width, _svOrder.height);
    
    // 屏蔽iPhoneih6
    if (_svOrder.contentSize.width <= _svOrder.width) {
        _svOrder.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _svOrder.width = _svOrder.contentSize.width;
        _svOrder.minX = (self.width - _svOrder.width) / 2;
    }
    
    [_svOrder addSubview:_obFilter];
    
    return _svOrder;
}

-(void)createResultHeader{
    _vHeader = [[UCAttentionDetailHeader alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, 20)];
    NSString *lastupdate = _mCarAttention.lastdate;
    NSString *title = [NSString stringWithFormat:@"最新更新： %@", lastupdate];
    [_vHeader setTitleStr:title];
    [self addSubview:_vHeader];
    _vHeader.hidden = YES;
}


/** 列表 */
- (UCAttentionDetailList *)creatAttentionListView:(CGRect)frame
{
    // 车辆列表
    _vCarList = [[UCAttentionDetailList alloc] initWithFrame:frame withUCCarAttenModel:_mCarAttention AttentionDictionary:self.dicReadNew AttentionArray:_attArray LastUpdate:_mCarAttention.lastdate];
    
    _vCarList.orderby = @"4";
    _vCarList.delegate = self;
    _vCarList.scrollDelegate = self;
    _vCarList.isEnablePullRefresh = YES;
    [_vCarList.tvCarList setFrame:_vCarList.bounds];
    
    return _vCarList;
}

/** 顶栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (![OMG isValidClick])
        return;
    
    switch (btn.tag) {
        case UCTopBarButtonLeft:
        {
            [_dicReadNew setValue:_attArray forKey:[NSString stringWithFormat:@"%@",_mCarAttention.attenID]];
            [[MainViewController sharedVCMain] closeView:self animateOption: AnimateOptionMoveLeft];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 设置 result Header count
- (void)setHeaderCount{
    
    [_vHeader setResultCount:self.resultCount];
}

#pragma mark - UCOptionBarDelegate
- (void)optionBar:(UCOptionBar *)optionBar didSelectAtIndex:(NSInteger)index
{
    if (optionBar.lastSelectedItemIndex == index && index != 1)
        return;
    
    NSInteger orderIndex = index;
    
    // 屏蔽iPhone6
    if (_svOrder.width < _svOrder.contentSize.width) {
        // 调整滑动区域
        UIView *vItem = [_obFilter itemViewAtIndex:index];
        CGFloat contentWidth = _svOrder.contentSize.width;
        CGFloat itemWidth = vItem.width;
        //居中
        if(index == 2){
            [_svOrder setContentOffset:CGPointMake(vItem.minX+itemWidth/2 - _svOrder.width/2, 0) animated:YES];
        }
        //居左
        else if (index < 2) {
            [_svOrder setContentOffset:CGPointMake(10, 0) animated:YES];
        }
        else {
            [_svOrder setContentOffset:CGPointMake(contentWidth - _svOrder.width, 0) animated:YES];
        }

    }
    
    // 非（价格、默认）
    UIImageView *ivOrder = (UIImageView *)[_obFilter viewWithTag:kOrderByPriceArrowTag];
        
    switch (index) {
        case 0:
        {
            orderIndex = 3;
        }
            break;
        case 1:
        {
            // 价格
            orderIndex = [_vCarList.orderby isEqualToString:@"2"] ? 2 : 1;
            ivOrder.image = [UIImage imageNamed:orderIndex == 2 ? @"price_low_icon" : @"price_high_icon"];
        }
            break;
        default:
        {
            orderIndex += 2;
        }
            break;
    }
    
    // 恢复价格默认图片
    if (index != 1)
        ivOrder.image = [UIImage imageNamed:@"price_all_icon"];
    
    NSString *order = [[self.orderValues objectAtIndex:orderIndex] objectForKey:@"Value"];
    // 刷新列表
    [self updateOrderBy:order];
}

/** 更新排序 */
- (void)updateOrderBy:(NSString *)order
{
    if (order != self.vCarList.orderby && ![order isEqualToString:self.vCarList.orderby]) {
        // 刷新主页车辆列表数据
        _vCarList.orderby = order;
        [_vCarList refreshCarList];
    }
}

#pragma mark - UCAttentionDetailListDelegate
-(void)carListViewLoadDataSuccess:(UCAttentionDetailList *)vCarList
{
    // 刷新总数
    self.resultCount = vCarList.carListAllCount;
    [self setHeaderCount];
    
    [self hideToolBarAndHeaderWithRowCount:self.resultCount];
}

-(void)carListViewDidSearched:(UCAttentionDetailList *)vCarList ConnectionError:(NSError *)error{
    _bvToolBar.hidden = YES;
    _vHeader.hidden = YES;
    
    [_vCarList setFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height-_tbTop.maxY)];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 屏蔽iPhone6
    if (scrollView.width >= scrollView.contentSize.width) {
        return;
    }
    
    if (scrollView.tag == kOrderScrollViewTag) {
        UIImageView *ivLeft = (UIImageView *)[_bvToolBar viewWithTag:kOrderShadowStartTag + 0];
        UIImageView *ivRight = (UIImageView *)[_bvToolBar viewWithTag:kOrderShadowStartTag + 1];
        ivLeft.hidden = scrollView.contentOffset.x > 21 ? NO : YES;
        ivRight.hidden = scrollView.contentOffset.x > 34 ? YES : NO;
    }
}

#pragma mark - 判断 count 设置 bar & header 的显隐
-(void)hideToolBarAndHeaderWithRowCount:(NSInteger)count{
    if (count > 0) {
        _bvToolBar.hidden = NO;
        [_vHeader setFrame:CGRectMake(0, _bvToolBar.maxY, self.width, 20)];
    }
    else{
        _vCarList.isEnablePullRefresh = NO;
    }
    
    _vHeader.hidden = NO;
    [_vCarList setFrame:CGRectMake(0, _vHeader.maxY, self.width, self.height-_vHeader.maxY)];
}

@end
