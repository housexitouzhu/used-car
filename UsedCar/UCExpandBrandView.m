//
//  UCExpandBrandView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-8.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCExpandBrandView.h"
#import "DatabaseHelper1.h"
#import "MultiCell.h"
#import "UCMainView.h"
#import "AMCacheManage.h"
#import "HotBrandCell.h"
#import "GroupTableCell.h"
#import "UCExpandSeriesView.h"
#import "Reachability.h"

#define kCarBrandsSectionIndexs @"kCarBrandsSectionIndexs"

@interface UCExpandBrandView () <HotBrandCellDelegate>
{
    BOOL isShowOpen;
    NSIndexPath *selectedIndex;
    
}

@property (nonatomic, strong) UCFilterModel       *mFilter;
@property (nonatomic, weak)   UCFilterModel       *mFilterTemp;        // 临时存储首页的 model
@property (nonatomic, strong) NSMutableDictionary *dicCarBrands;// 品牌
@property (nonatomic, strong) NSMutableArray      *selectedIndexPaths;// cell索引
@property (nonatomic, strong) GroupTableView      *group;
@property (nonatomic, strong) MJNIndexView        *ivIndexBar;
@property (nonatomic        ) ExpandFilterBrandViewStyle viewStyle;

@end

@implementation UCExpandBrandView

- (id)initWithFrame:(CGRect)frame filter:(UCFilterModel *)mFilter ExpandFilterBrandViewStyle:(ExpandFilterBrandViewStyle)viewStyle;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.selectedIndexPaths = [[NSMutableArray alloc] init];
        self.mFilterTemp = mFilter;
        self.mFilter = [mFilter copy];
        _viewStyle = viewStyle;
        
        [self initView];
    }
    return self;
}

/** 初始化视图 */
- (void)initView
{
    [self initAllCarBrands];
    
    _group = [[GroupTableView alloc]initWithFrame:self.bounds];
    _group.autoresizesSubviews = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    UIView *_backgroundview = [[UIView alloc] initWithFrame:self.bounds];
    [_backgroundview setBackgroundColor:[UIColor whiteColor]];
    [self.group setBackgroundView:_backgroundview];
    _group.separatorColor=[UIColor clearColor];
    [self addSubview:_group];
    
    _group.dataSource=self;
    _group.delegate=self;
    
    // 添加自定义索引栏
    self.ivIndexBar = [[MJNIndexView alloc] initWithFrame:self.bounds];
    [self.ivIndexBar setFontColor:kColorNewGray2];
    self.ivIndexBar.dataSource = self;
    [self addSubview:self.ivIndexBar];
    [_group reloadData];
    
    // 选中记录
//    if (_mFilterTemp.brandid.integerValue > 0 || _viewStyle == ExpandFilterBrandViewStyleBrand) {
//        [self setSelectedBrandCell];
//    }

}

/** 初始化所有品牌 */
- (void)initAllCarBrands
{
    NSUInteger section = 0,row = 0;
    
    NSString *dbPath = [AMCacheManage cacheDbPathForResource:@"Cars"];
    DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:dbPath];
    NSArray *carBrands = [dbHelper querryTable:[NSString stringWithFormat:@"SELECT * FROM CarBrand ORDER BY FirstLetter"]];
    
    [_dicCarBrands removeAllObjects];
    _dicCarBrands = [NSMutableDictionary dictionary];
    // 筛选页增加不限选项
    NSMutableArray *orderArray = nil;
    
    [_dicCarBrands setObject:@[ @{@"Name":@"热门品牌"} ] forKey:@"热"];
    orderArray = [NSMutableArray arrayWithObject:@"热"];
    
    [_dicCarBrands setObject:@[ @{@"Name":@"不限品牌"} ] forKey:@"*"];
    [orderArray addObject:@"*"];
    
    for (NSDictionary *temp in carBrands) {
        NSString *firstLetter = [temp objectForKey:@"FirstLetter"];
        NSMutableArray *array = [_dicCarBrands objectForKey:firstLetter];
        if (!array) {
            array = [NSMutableArray array];
            [_dicCarBrands setObject:array forKey:firstLetter];
            [orderArray addObject:firstLetter];
        }
        [array addObject:temp];
        // 记录品牌索引
        if (_mFilterTemp.brandid) {
            if ([[temp objectForKey:@"BrandId"] integerValue] == _mFilterTemp.brandid.integerValue) {
                section = [orderArray indexOfObject:firstLetter];
                row = [[_dicCarBrands objectForKey:firstLetter] indexOfObject:temp];
                [_selectedIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
            }
        }
        
    }
    [_dicCarBrands setObject:orderArray forKey:kCarBrandsSectionIndexs];
}


#pragma mark - MJNIndexViewDataSource
- (NSArray *)sectionIndexTitlesForMJNIndexView:(MJNIndexView *)indexView
{
    return (NSArray *)[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs];
}

- (void)sectionForSectionMJNIndexTitle:(NSString *)title atIndex:(NSInteger)index;
{
    
    if ([_group numberOfSections] > index && index > -1)
        [_group scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition: UITableViewScrollPositionTop animated:YES];
}

#pragma mark - UITableView Datasource
//品牌列表SectionHeader
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *vHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _group.frame.size.width, 20)];
    // 背景
    UIView *vHeaderBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, vHeader.frame.size.width, 20)];
    vHeaderBG.backgroundColor = kColorNewLine;
    [vHeader addSubview:vHeaderBG];
    
    // 标题
    CGFloat marginLeftText = 7.0f;
    marginLeftText = 20;
    
    NSString *strSection = [[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs] objectAtIndex:section];
    
    UILabel *labTittle = [[UILabel alloc] initWithFrame:CGRectMake(marginLeftText, 0, vHeaderBG.frame.size.width, 20)];
    labTittle.font = kFontSmall;
    labTittle.backgroundColor = [UIColor clearColor];
    labTittle.textColor = kColorNewGray2;
    if (section == 0) {
        labTittle.text = @"热门品牌";
    }
    else{
        labTittle.text = strSection;
    }
    
    [vHeaderBG addSubview:labTittle];
    
    return vHeader;
}

- (CGFloat) tableView :( UITableView *) tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs] count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dicCarBrands objectForKey:[[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs] objectAtIndex:section]] count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *hotIdentifier = @"HotCell";
    static NSString *CellIdentifier = @"Cell";
    
    if (indexPath.section == 0) {
        HotBrandCell *hotCell = (HotBrandCell *)[tableView dequeueReusableCellWithIdentifier:hotIdentifier];
        if (!hotCell) {
            hotCell = [[HotBrandCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:hotIdentifier];
            hotCell.delegate = self;
        }
        return hotCell;
        
    } else {
        
        GroupTableCell *cell = (GroupTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GroupTableCell alloc] initWithBrandLogoStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier level:0 marginLeftOfLine:16.0f cellWidth:tableView.width];
            cell.tag = indexPath.row;
        }
        
        NSArray *cellCarBrands = [self.dicCarBrands objectForKey:[[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs] objectAtIndex:indexPath.section]];
        // logo
        [cell.ivLogoImg sd_setImageWithURL:[[cellCarBrands objectAtIndex:indexPath.row] objectForKey:@"LogoUrl"] placeholderImage:[UIImage imageNamed:@"screen_picture"] options:SDWebImageRetryFailed];
        cell.labText.text = [[cellCarBrands objectAtIndex:indexPath.row] objectForKey:@"Name"];
        cell.vLine.hidden = cellCarBrands.count == indexPath.row + 1; // 隐藏每个section最后一根分割线
        
        if ([cell.labText.text isEqualToString:@"不限品牌"]) {
            cell.ivLogoImg.hidden = YES;
            cell.vLine.minX = 16;
            cell.labText.minX = 23;
        } else {
            cell.ivLogoImg.hidden = NO;
            cell.vLine.minX = 64;
            cell.labText.minX = 65;
        }
        //    cell.labText.minX = 20 + cell.ivLogoImg.maxX;
        [cell.closeIconView setHidden:YES];
        if ([cell.labText.text isEqualToString:@"暂无数据"])
            cell.userInteractionEnabled = NO;
        else
            cell.userInteractionEnabled = YES;
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 85;
    }
    else{
        return 50;
    }
}


#pragma mark - UITableView Delegate methods
/**
 *  group控件的展开处理方法
 *
 *  @param group
 *  @param indexPath 选中的下标
 *  @param fromType 来源 0 用户手动点击每一项 1：自动展开触发
 */
- (void)groupTableView:(UITableView *)group didSelectRowAtIndexPath:(NSIndexPath *)indexPath expandType:(NSInteger)expandType
{
    if ([[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs] count] >indexPath.section)
    {
        self.ivIndexBar.hidden=YES;
        NSArray *brandIndexes = [self.dicCarBrands objectForKey:kCarBrandsSectionIndexs];
        NSString *index = [brandIndexes objectAtIndex:indexPath.section];
        NSArray *brandArrayForIndex = [self.dicCarBrands objectForKey:index];
        
        if (brandArrayForIndex.count > indexPath.row)
        {
            
            NSDictionary *brandDict = [brandArrayForIndex objectAtIndex:indexPath.row];
            
            float h=0;
            if (IOS7_OR_LATER)
            {
                h=64;
            }
            
            // 修复筛选页调用展开坐标偏移问题
            if (expandType == BrandExpandTypeNO) {
                h=0;
            }
            
            [self.group scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
            NSString *brandID = [brandDict objectForKey:@"BrandId"];
            NSString *brandName = [brandDict objectForKey:@"Name"];
            
            GroupTableCell *cell = (GroupTableCell*)[group cellForRowAtIndexPath:indexPath];
            [cell.closeIconView setHidden:NO];
            
            GroupTableView *tv = (GroupTableView*)group;
            NSArray *cellCarBrands = [self.dicCarBrands objectForKey:[[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs] objectAtIndex:indexPath.section]];
            [tv setLogoURL:[[cellCarBrands objectAtIndex:indexPath.row] objectForKey:@"LogoUrl"]];
            
            
            // 车系页面
            CGFloat height = ceil(self.group.height - 50 - h);
            UCExpandSeriesView *seriesView = [[UCExpandSeriesView alloc] initWithFrame:CGRectMake(0, 0, _group.frame.size.width, height) filterTemp:_mFilterTemp filter:_mFilter BrandID:brandID];
            seriesView.delegate = self; // 品牌、车系、车型的总代理，在本类中执行并给外接最终值
            seriesView.brandName = brandName;
            
            [seriesView setSelectecSeriesCell];
            
            __weak typeof(self) weakSelf = self;
            [_group openFolderAtIndexPath:indexPath WithContentView:seriesView closeHandler:^{
                weakSelf.ivIndexBar.hidden=NO;
                [cell.closeIconView setHidden:YES];
            }];
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        
    }
    else if (indexPath.section == 1){
        self.mFilter.brandid = nil;
        self.mFilter.brandidText = nil;
        self.mFilter.seriesid = nil;
        self.mFilter.seriesidText = nil;
        self.mFilter.specid = nil;
        self.mFilter.specidText = nil;
        
        // 执行代理
        [self executeDelegateWithfilterModel:self.mFilter];
    }
    else{
        
        NSArray *cellCarBrands = [self.dicCarBrands objectForKey:[[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs] objectAtIndex:indexPath.section]];
        NSString *brandId = [[cellCarBrands objectAtIndex:indexPath.row] objectForKey:@"BrandId"];
        NSString *brandName = [[cellCarBrands objectAtIndex:indexPath.row] objectForKey:@"Name"];
        
        if (_mFilterTemp.brandid.intValue != brandId.intValue) {
            self.mFilter.seriesid = nil;
            self.mFilter.specid = nil;
            self.mFilter.seriesidText = nil;
            self.mFilter.specidText = nil;
            self.mFilterTemp.brandid = nil;
            self.mFilterTemp.brandidText = nil;
            self.mFilterTemp.seriesid = nil;
            self.mFilterTemp.specid = nil;
            self.mFilterTemp.seriesidText = nil;
            self.mFilterTemp.specidText = nil;
        }
        
        if (brandId) {
            self.mFilter.brandid = brandId;
            self.mFilter.brandidText = brandName;
            
        } else {
            self.mFilter.brandid = nil;
            self.mFilter.brandidText = nil;

            // 执行代理
            [self executeDelegateWithfilterModel:self.mFilter];
        }
        
        // set logo
        GroupTableCell *cell = (GroupTableCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell.ivLogoImg sd_setImageWithURL:[[cellCarBrands objectAtIndex:indexPath.row] objectForKey:@"LogoUrl"]
                       placeholderImage:[UIImage imageNamed:@"screen_picture"]];
        
        [self groupTableView:tableView didSelectRowAtIndexPath:indexPath expandType:BrandExpandTypeNO];
    }
}

/** 设置选中状态 */
- (void)setSelectedBrandCellshouldSelectAllBrandCell:(BOOL)flag
{
    // 品牌
    if (_mFilterTemp.brandid) {
        
        NSIndexPath *indexPath = [_selectedIndexPaths objectAtIndex:0];
        [_group selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        
        [self performSelector:@selector(selectCellWithIndex:) withObject:indexPath afterDelay:0];
        
    }
    else if(_viewStyle == UCFilterViewStyleBrand && flag){
        
        //设置是否选中不限品牌 cell
        NSIndexPath *indexPathZero = [NSIndexPath indexPathForRow:0 inSection:1];
        [_group selectRowAtIndexPath:indexPathZero animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void)selectCellWithIndex:(NSIndexPath*)indexPath{
    if ([_group.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
        [_group.delegate tableView:_group willSelectRowAtIndexPath:indexPath];
    if ([_group.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
        [_group.delegate tableView:_group didSelectRowAtIndexPath:indexPath];
}

#pragma mark - HotBrandCell Delegate
-(void)hotBrandCellDidClickAtBrand:(NSString*)brandID andFirstLetter:(NSString *)firstLetter{
    
    [UMStatistics event:c_3_8_buycar_creening_brand_hot];
    
    NSArray *indexs = [self.dicCarBrands objectForKey:kCarBrandsSectionIndexs];
    NSInteger section = [indexs indexOfObject:firstLetter];
    
    NSArray *secArray = [self.dicCarBrands objectForKey:firstLetter];
    for (int i = 0; i < secArray.count; i++) {
        NSDictionary *itemDict = [secArray objectAtIndex:i];
        NSInteger bid = [[itemDict objectForKey:@"BrandId"] integerValue];
        
        if (bid == brandID.integerValue) {
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:i inSection:section];
            [_group selectRowAtIndexPath:cellIndexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            if ([_group.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
                [_group.delegate tableView:_group willSelectRowAtIndexPath:cellIndexPath];
            if ([_group.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
                [_group.delegate tableView:_group didSelectRowAtIndexPath:cellIndexPath];
            return;
        }
//        AMLog(@"%d %d", i, secArray.count);
    }
}

#pragma mark - UCExpandSeriesViewDelegate
-(void)UCExpandSeriesView:(UCExpandSeriesView *)vExpandSeries filterModel:(UCFilterModel *)mFilter
{
    // 执行代理
    [self executeDelegateWithfilterModel:mFilter];
}

#pragma mark - UCExpandSpecViewDelegate
-(void)UCExpandSpecView:(UCExpandSpecView *)vExpandSpec filterModel:(UCFilterModel *)mFilter
{
    // 执行代理
    [self executeDelegateWithfilterModel:mFilter];
}

- (void)executeDelegateWithfilterModel:(UCFilterModel *)mFilter
{
    // 执行代理
    if ([_delegate respondsToSelector:@selector(UCExpandBrandView:isChanged:filterModel:)]) {
        BOOL isChangedOfFilterModel = ![mFilter isEqualToFilter:_mFilterTemp];
        [_delegate UCExpandBrandView:self isChanged:isChangedOfFilterModel filterModel:mFilter];
    }
}

@end
