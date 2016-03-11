//
//  UCExpandSeriesView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-9.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCExpandSeriesView.h"
#import "DatabaseHelper1.h"
#import "GroupTableCell.h"
#import "UCMainView.h"
#import "AMCacheManage.h"
#import "HotBrandCell.h"
#import "MultiCell.h"
#import "UCExpandSpecView.h"
#import "NSString+Util.h"

#define kCarSeriesSectionIndexs @"kCarSeriesSectionIndexs"

@interface UCExpandSeriesView()
{
    BOOL isShowOpen;
}

@property (nonatomic, weak) UCFilterModel         *mFilterTemp;     // 未经过改动的model
@property (nonatomic, strong) UCFilterModel       *mFilter;
@property (nonatomic, strong) NSMutableDictionary *dicCarSeries;    // 车系
@property (strong, nonatomic) GroupTableView *group;
@property (strong, nonatomic) NSIndexPath *selectedIndex;
@end

@implementation UCExpandSeriesView

- (id)initWithFrame:(CGRect)frame filterTemp:(UCFilterModel *)mFilterTemp filter:(UCFilterModel *)mFilter BrandID:(NSString*)brandID
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.brandID = brandID;
        _mFilterTemp = mFilterTemp;
        self.mFilter = mFilter;
        
        [self initView];
    }
    return self;
}

/** 初始化视图 */
- (void)initView
{
    [self initCarSeriesWithBrandId:self.brandID];
    
    _group = [[GroupTableView alloc]initWithFrame:self.bounds];
    _group.autoresizesSubviews = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    UIView *_backgroundview = [[UIView alloc] initWithFrame:self.bounds];
    [_backgroundview setBackgroundColor:[UIColor whiteColor]];
    [self.group setBackgroundView:_backgroundview];
    _group.separatorColor=[UIColor clearColor];
    [self addSubview:_group];
    
    _group.dataSource=self;
    _group.delegate=self;
    
    [_group reloadData];
}

/** 当前车系 */
- (void)initCarSeriesWithBrandId:(NSString *)brandId
{
    
    NSUInteger section = 0, row = 0;
    
    NSString *dbPath = [AMCacheManage cacheDbPathForResource:@"Cars"];
    DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:dbPath];
    
    NSArray *carSeries = [dbHelper querryTable:[NSString stringWithFormat:@"SELECT * FROM CarSeries WHERE FatherId = '%d' ORDER BY Orderby", [brandId integerValue]]];
    
    self.dicCarSeries = [NSMutableDictionary dictionary];
    NSMutableArray *merchantNames = nil;
    
    [self.dicCarSeries setObject:@[@{@"Name":@"不限车系"}] forKey:@"*"];
    merchantNames = [NSMutableArray arrayWithObject:@"*"];
    
    for (NSDictionary *temp in carSeries) {
        NSString *merchantName = [temp objectForKey:@"FactoryName"] ? [temp objectForKey:@"FactoryName"] : @"";
        NSMutableArray *array = [self.dicCarSeries objectForKey:merchantName];
        if (!array) {
            array = [NSMutableArray array];
            [self.dicCarSeries setObject:array forKey:merchantName];
            [merchantNames addObject:merchantName];
        }
        [array addObject:temp];
        // 记录品牌索引
        if (_mFilterTemp.seriesid) {
            if ([[temp objectForKey:@"SeriesId"] integerValue] == _mFilterTemp.seriesid.integerValue) {
                section = [merchantNames indexOfObject:merchantName];
                row = [[self.dicCarSeries objectForKey:merchantName] indexOfObject:temp];
                self.selectedIndex = [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
    }
    [self.dicCarSeries setObject:merchantNames forKey:kCarSeriesSectionIndexs];
    
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
    
    NSString *strSection = [[self.dicCarSeries objectForKey:kCarSeriesSectionIndexs] objectAtIndex:section];
    
    UILabel *labTittle = [[UILabel alloc] initWithFrame:CGRectMake(marginLeftText, 0, vHeaderBG.frame.size.width, 20)];
    labTittle.font = kFontSmall;
    labTittle.backgroundColor = [UIColor clearColor];
    labTittle.textColor = kColorNewGray2;
    labTittle.text = strSection;
    [vHeaderBG addSubview:labTittle];
    
    return vHeader;
}

- (CGFloat) tableView :( UITableView *) tableView
heightForHeaderInSection:(NSInteger)section
{
    return 20;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [[self.dicCarSeries objectForKey:kCarSeriesSectionIndexs] count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dicCarSeries objectForKey:[[self.dicCarSeries objectForKey:kCarSeriesSectionIndexs] objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    GroupTableCell *cell = (GroupTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[GroupTableCell alloc] initWithBrandLogoStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier level:0 marginLeftOfLine:16.0f cellWidth:tableView.width];
        cell.tag = indexPath.row;
    }
    
    NSArray *cellCarSeries = [self.dicCarSeries objectForKey:[[self.dicCarSeries objectForKey:kCarSeriesSectionIndexs] objectAtIndex:indexPath.section]];
    
    NSString *title = [[cellCarSeries objectAtIndex:indexPath.row] objectForKey:@"Name"];
    
    cell.labText.text = title.trim;
    cell.vLine.hidden = cellCarSeries.count == indexPath.row + 1; // 隐藏每个section最后一根分割线
    cell.ivLogoImg.hidden = YES;
    //    cell.labText.minX = 20 + cell.ivLogoImg.maxX;
    cell.closeIconView.hidden = YES;
    
    if ([cell.labText.text isEqualToString:@"暂无数据"])
        cell.userInteractionEnabled = NO;
    else
        cell.userInteractionEnabled = YES;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
    if ([[self.dicCarSeries objectForKey:kCarSeriesSectionIndexs] count] >indexPath.section)
    {
        
    }
    NSArray *brandIndexes = [self.dicCarSeries objectForKey:kCarSeriesSectionIndexs];
    NSString *index = [brandIndexes objectAtIndex:indexPath.section];
    NSArray *brandArrayForIndex = [self.dicCarSeries objectForKey:index];
    
    if (brandArrayForIndex.count > indexPath.row)
    {
        
        NSDictionary *seriesDict = [brandArrayForIndex objectAtIndex:indexPath.row];
        
        float h=0;
        if (IOS7_OR_LATER)
        {
            h=64;
        }
        
        // 修复筛选页调用展开坐标偏移问题
        if (expandType == SeriesExpandTypeNO) {
            h=0;
        }
        
        [self.group scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        NSString *seriesID = [seriesDict objectForKey:@"SeriesId"];
        NSString *seriesName = [seriesDict objectForKey:@"Name"];
        
        GroupTableCell *cell = (GroupTableCell*)[group cellForRowAtIndexPath:indexPath];
        [cell.closeIconView setHidden:NO];
        
        UCExpandSpecView *specView = [[UCExpandSpecView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.group.height-50-h) filterTemp:_mFilterTemp filter:_mFilter SeriesID:seriesID];
        specView.delegate = (id)_delegate; // 直接去UCExpandBrandView执行代理
        specView.seriesName = seriesName;
        
        [specView setSelectSpecCell];
        
        //            __weak typeof(self) weakSelf = self;
        [_group openFolderAtIndexPath:indexPath WithContentView:specView closeHandler:^{
            [cell.closeIconView setHidden:YES];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.mFilter.specid = nil;
    self.mFilter.specidText = nil;
    
//    AMLog(@"mFilter %@", self.mFilter);
    
    if (indexPath.section != 0) {
        
        [self groupTableView:tableView didSelectRowAtIndexPath:indexPath expandType:SeriesExpandTypeNO];
        
        NSArray *cellCarSeries = [self.dicCarSeries objectForKey:[[self.dicCarSeries objectForKey:kCarSeriesSectionIndexs] objectAtIndex:indexPath.section]];
        NSString *seriesId = [[cellCarSeries objectAtIndex:indexPath.row] objectForKey:@"SeriesId"];
        NSString *seriesName = [[cellCarSeries objectAtIndex:indexPath.row] objectForKey:@"Name"];
        
        if (seriesId) {
            self.mFilter.seriesid = seriesId;
            self.mFilter.seriesidText = seriesName;
        } else {
            self.mFilter.seriesid = nil;
            self.mFilter.seriesidText = nil;
            
            // 执行代理
            if ([_delegate respondsToSelector:@selector(UCExpandSeriesView:filterModel:)]) {
                [_delegate UCExpandSeriesView:self filterModel:self.mFilter];
            }
        }
        
    }
    else{
        self.mFilter.seriesid = nil;
        self.mFilter.seriesidText = nil;
        
        // 执行代理
        if ([_delegate respondsToSelector:@selector(UCExpandSeriesView:filterModel:)]) {
            [_delegate UCExpandSeriesView:self filterModel:self.mFilter];
        }
    }
}


- (void)setSelectecSeriesCell
{
    
    if (_mFilterTemp.seriesid) {
        [_group scrollToRowAtIndexPath:self.selectedIndex atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        [_group selectRowAtIndexPath:self.selectedIndex animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        if ([_group.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
            [_group.delegate tableView:_group willSelectRowAtIndexPath:self.selectedIndex];
        if ([_group.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
            [_group.delegate tableView:_group didSelectRowAtIndexPath:self.selectedIndex];
    }
    else{
        if (_mFilterTemp.brandid.integerValue > 0 && _mFilterTemp.seriesid.integerValue == 0) {
            NSIndexPath *indexPathZero = [NSIndexPath indexPathForRow:0 inSection:0];
            [_group selectRowAtIndexPath:indexPathZero animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
        
//        if ([_group.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
//            [_group.delegate tableView:_group willSelectRowAtIndexPath:indexPathZero];
//        if ([_group.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
//            [_group.delegate tableView:_group didSelectRowAtIndexPath:indexPathZero];
    }
}

@end
