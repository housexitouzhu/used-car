//
//  UCSalesLeadsDetailView.m
//  UsedCar
//
//  Created by wangfaquan on 14-4-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSalesLeadsView.h"
#import "UCTopBar.h"
#import "UCOptionBar.h"
#import "UCSalesLeadsListView.h"
#import "AMCacheManage.h"

static NSMutableArray *unAvailablyReads;    // 无效已读痕迹
static NSMutableArray *availablyReads;      // 有效已读痕迹

#define KdataHeight 30
#define kUntreatedListTag           37485938
#define kProcessedListTag           39483729
#define kInvalidListTag             39403820

@interface UCSalesLeadsView()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCOptionBar *obFilter;
@property (nonatomic, strong) UCSalesLeadsListView *vProcessed;
@property (nonatomic, strong) UCSalesLeadsListView *vUntreated;
@property (nonatomic, strong) UCSalesLeadsListView *vUnAvailably;
@property (nonatomic) BOOL isNeedReloadUnAvilablyViewData;      // 是否需要刷新忽略页面
@property (nonatomic) BOOL isNeedReloadProcessedViewData;       // 是否刷新已处理线索页面
@property (nonatomic, assign) BackButtonType backButtonType;
@end

@implementation UCSalesLeadsView

/** 无效阅读痕迹 */
+ (NSMutableArray *)instanceunAvailablyReadsCount
{
    return unAvailablyReads;
}

/** 有效阅读痕迹 */
+ (NSMutableArray *)instanceavailablyReadsCount
{
    return availablyReads;
}

- (id)initWithFrame:(CGRect)frame backButtonType:(BackButtonType)backBtnType
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backButtonType = backBtnType;
        _isNeedReloadUnAvilablyViewData = NO;
        _isNeedReloadUnAvilablyViewData = NO;
        if (!availablyReads)
            availablyReads = [NSMutableArray array];
        if (!unAvailablyReads)
            unAvailablyReads = [NSMutableArray array];
        [self initView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backButtonType = BackButtonTypeBack;
        _isNeedReloadUnAvilablyViewData = NO;
        _isNeedReloadUnAvilablyViewData = NO;
        if (!availablyReads)
            availablyReads = [NSMutableArray array];
        if (!unAvailablyReads)
            unAvailablyReads = [NSMutableArray array];
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    //导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [_tbTop.btnTitle setTitle:@"销售线索" forState:(UIControlStateNormal)];
    if (self.backButtonType == BackButtonTypeBack) {
        [_tbTop setLetfTitle:@"返回"];
    }
    else{
        [_tbTop setLetfTitle:@"关闭"];
    }
    [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    
    // 选择条
    _obFilter = [self creatFilterView:CGRectMake(0, _tbTop.maxY, self.width, kMainOptionBarHeight)];
    
    // 友情提示语
    UILabel *labData = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
    labData.textAlignment = NSTextAlignmentCenter;
    labData.numberOfLines = 0;
    labData.text = @"点击下方销售线索后拨打电话尽快联系买家，将提高销售线\n索处理率，有益于提高车源排序。";
    labData.font = kFontSmall;
    labData.backgroundColor = kColorClear;
    labData.textColor = kColorNewGray2;
    
    // 分割线
    UIView *vLine2 = [[UIView alloc] initLineWithFrame:CGRectMake(0, _tbTop.maxY ,self.width, kLinePixel) color:kColorNewLine];
    
    // 未处理
    _vUntreated = [[UCSalesLeadsListView alloc] initWithFrame:CGRectMake(0, _obFilter.maxY, self.width, self.height -  _obFilter.maxY)];
    _vUntreated.markReads = availablyReads;
    _vUntreated.delegate = self;
    [_vUntreated setFooterViewHeight:0];
    _vUntreated.tag = kUntreatedListTag;
    _vUntreated.listState = 2;      // 状态:1已阅2未阅读3忽略4（已阅+未阅）
    _vUntreated.tvSaleLeadList.tableHeaderView = labData;
    [self addSubview:_vUntreated];
    
    [_obFilter selectItemAtIndex:0];
    
    [self addSubview:_obFilter];
    [self addSubview:_tbTop];
    [self addSubview:vLine2];
    
    // 刷新数据
    [_vUntreated refreshData];
}

- (void)creatProcesseView
{
    // 已处理
    _vProcessed = [[UCSalesLeadsListView alloc] initWithFrame:CGRectMake(0, _obFilter.maxY, self.width, self.height -  _obFilter.maxY)];
    _vProcessed.markReads = availablyReads;
    _vProcessed.delegate = self;
    [_vProcessed setFooterViewHeight:0];
    _vProcessed.listState = 1;
    _vProcessed.tag = kProcessedListTag;
    [self addSubview:_vProcessed];
    [_vProcessed refreshData];
}

- (void)creatUnAvailablyView
{
    // 无效线索
    _vUnAvailably = [[UCSalesLeadsListView alloc] initWithFrame:CGRectMake(0, _obFilter.maxY, self.width, self.height -  _obFilter.maxY)];
    _vUnAvailably.markReads = unAvailablyReads;
    _vUnAvailably.delegate = self;
    _vUnAvailably.listState = 3;
    _vUnAvailably.tag = kInvalidListTag;
    [_vUnAvailably setFooterViewHeight:0];
    [self addSubview:_vUnAvailably];
    [_vUnAvailably refreshData];
}

/** 创建选择条 */
- (UCOptionBar *)creatFilterView:(CGRect)frame
{
    CGFloat barHeight = frame.size.height;
    NSArray *titles = @[@"未处理线索", @"已处理线索", @"无效线索"];
    
    // 选项条
    UIView *vSlider = [[UIView alloc] initWithFrame:CGRectMake(0, barHeight - 4, self.width / titles.count, 4)];
    vSlider.backgroundColor = kColorBlue;
    
    _obFilter = [[UCOptionBar alloc] initWithFrame:frame sliderView:vSlider];
    _obFilter.isAutoAdjustSlider = YES;
    _obFilter.backgroundColor = kColorWhite;
    _obFilter.delegate = self;
    [_obFilter addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, _obFilter.height - kLinePixel, _obFilter.width, kLinePixel) color:kColorNewLine]];
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger i = 0; i < titles.count; i++) {
        UCOptionBarItem *item = [[UCOptionBarItem alloc] init];
        item.titleFont = kFontLarge;
        item.titleColor = kColorNewGray1;
        item.titleFont = kFontLarge;;
        item.titleColorSelected = kColorBlue;
        item.title = titles[i];
        [items addObject:item];
    }
    
    [_obFilter setItems:items];
    
    return _obFilter;
}

#pragma mark - onClickBtn
/** 顶栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (btn.tag == UCTopBarButtonLeft) {
        if (self.backButtonType == BackButtonTypeBack) {
            [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
        }
        else{
            [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveUp];
        }
    }
}

#pragma mark - UCOptionBarDelegate
- (void)optionBar:(UCOptionBar *)optionBar didSelectAtIndex:(NSInteger)index
{
    // 未处理
    if (index == 0) {
        [self bringSubviewToFront:_vUntreated];
    }
    // 已处理
    else if (index == 1) {
        if (!_vProcessed) {
            [self creatProcesseView];
        }
        
        if (_isNeedReloadProcessedViewData) {
            _isNeedReloadProcessedViewData = NO;
            [_vProcessed refreshData];
        }
        [self bringSubviewToFront:_vProcessed];
    }
    // 忽略
    else if (index == 2) {
        if (!_vUnAvailably) {
            [self creatUnAvailablyView];
        }
        
        if (_isNeedReloadUnAvilablyViewData) {
            _isNeedReloadUnAvilablyViewData = NO;
            [_vUnAvailably refreshData];
        }
        
        // 显示无效线索
        [self bringSubviewToFront:_vUnAvailably];
    }
    [self bringSubviewToFront:_obFilter];
    [self bringSubviewToFront:_tbTop];
}

#pragma mark - UCSaleLeadListDelegate
- (void)saleLeadList:(UCSalesLeadsListView *)vSaleLeadList saleLeadModel:(UCSalesLeadsModel *)mSaleLead
{
    MainViewController *vcMain = [MainViewController sharedVCMain];
    UCSalesLeadsDetailView *vSalesLeadsDetail = [[UCSalesLeadsDetailView alloc] initWithFrame:self.bounds viewStyle:_obFilter.selectedItemIndex saleLeadModel:mSaleLead];
    switch (_obFilter.selectedItemIndex) {
        case 0:
            [UMStatistics event:c_4_1_buiness_clues_untreatedcluesclick];
            break;
        case 1:
            [UMStatistics event:c_4_1_buiness_clues_havecluesclick];
            break;
        case 2:
            [UMStatistics event: c_3_5_invalidcueclick];
            break;
            
        default:
            break;
    }
    vSalesLeadsDetail.delegate = self;
    [vcMain openView:vSalesLeadsDetail animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

/** 获得数据 */
-(void)UCSalesLeadsListDidSuccessed:(UCSalesLeadsListView *)vSaleLeadList
{
    // 未处理
    if (_obFilter.selectedItemIndex == 0) {
        if (vSaleLeadList.tag == kUntreatedListTag) {
            [UMSAgent postEvent:buiness_clues_untreatedclues_pv page_name:NSStringFromClass(self.class)
                     eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [AMCacheManage currentUserInfo].userid, @"dealerid#5", nil]];
            [UMStatistics event:pv_4_1_buiness_clues_untreatedclues];
        }
    }
    // 已处理
    else if (_obFilter.selectedItemIndex == 1) {
        [UMSAgent postEvent:buiness_clues_haveclues_pv page_name:NSStringFromClass(self.class)
                 eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [AMCacheManage currentUserInfo].userid, @"dealerid#5", nil]];

        [UMStatistics event:pv_4_1_buiness_clues_haveclues];
    }
    // 忽略
    else if (_obFilter.selectedItemIndex == 2){
        if (vSaleLeadList.listState == 3)
            [UMStatistics event:pv_3_5_invalidcue];

        if ([AMCacheManage currentUserType] == UserStyleBusiness) {
            UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
            [UMSAgent postEvent:invalidcue_pv page_name:NSStringFromClass(self.class)
                     eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 mUserInfo.userid, @"userid#4", nil]];
        } else {
            [UMSAgent postEvent:invalidcue_pv page_name:NSStringFromClass(self.class)];
        }
    }
}

- (void)UCSalesLeadsDetailView:(UCSalesLeadsDetailView *)vSalesLeadsDetail ignoreSuccess:(UCSalesLeadsModel *)mSaleLead
{
    // 未处理
    if ([_obFilter selectedItemIndex] == 0) {
        [_vUntreated.items removeObject:mSaleLead];
        [_vUntreated refreshData];
    }
    // 已处理
    else if ([_obFilter selectedItemIndex] == 1) {
        [_vProcessed.items removeObject:mSaleLead];
        [_vProcessed refreshData];
    }
    _isNeedReloadUnAvilablyViewData = YES;
}

// 处理成功
-(void)UCSalesLeadsDetailView:(UCSalesLeadsDetailView *)vSalesLeadsDetail handleSuccess:(UCSalesLeadsModel *)mSaleLead
{
    [_vUntreated.items removeObject:mSaleLead];
    [_vUntreated refreshData];
    _isNeedReloadProcessedViewData = YES;

}

@end
