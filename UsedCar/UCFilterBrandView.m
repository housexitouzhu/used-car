//
//  UCFilterBrandView.m
//  UsedCar
//
//  Created by Alan on 13-11-15.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCFilterBrandView.h"
#import "DatabaseHelper1.h"
#import "MultiCell.h"
#import "UCMainView.h"
#import "AMCacheManage.h"

#define kCarBrandsSectionIndexs @"kCarBrandsSectionIndexs"
#define kCarSeriesSectionIndexs @"kCarSeriesSectionIndexs"

@interface UCFilterBrandView ()

@property (nonatomic, strong) UCFilterModel *mFilter;
@property (nonatomic, strong) NSMutableDictionary *dicCarBrands;    // 品牌
@property (nonatomic, strong) NSMutableDictionary *dicCarSeries;    // 车系
@property (nonatomic, strong) NSMutableArray *carSpecs;             // 车型
@property (nonatomic, strong) NSMutableArray *selectedIndexPaths;   // cell索引
@property (nonatomic, strong) MultiTablesView *mtvBrand;
@property (nonatomic) UCFilterBrandViewStyle viewStyle;

@end

@implementation UCFilterBrandView

- (id)initWithFrame:(CGRect)frame filter:(UCFilterModel *)mFilter UCFilterBrandViewStyle:(UCFilterBrandViewStyle)viewStyle
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedIndexPaths = [[NSMutableArray alloc] init];
        self.mFilter = mFilter;
        self.mFilterTemp = [mFilter copy];
        _viewStyle = viewStyle;

        [self initView];
    }
    return self;
}

/** 初始化视图 */
- (void)initView
{
    [self initAllCarBrands];
    
    _mtvBrand = [[MultiTablesView alloc] initWithFrame:self.bounds];
    _mtvBrand.delegate = self;
    _mtvBrand.dataSource = self;
    _mtvBrand.marginLeft = 43;
    _mtvBrand.marginLifts = [NSArray arrayWithObjects:[NSNumber numberWithFloat:20], [NSNumber numberWithFloat:40], nil];

    [self addSubview:_mtvBrand];

    // 添加自定义索引栏
    MJNIndexView *ivIndexBar = [[MJNIndexView alloc] initWithFrame:self.bounds];
    ivIndexBar.dataSource = self;
    UITableView *tableView = [_mtvBrand tableViewAtIndex:0];
    [_mtvBrand insertSubview:ivIndexBar aboveSubview:tableView];
    
}

/** 设置选中状态 */
- (void)setSelectedCells
{
    UITableView *tableView = [_mtvBrand tableViewAtIndex:0];

    // 品牌
    if (_mFilterTemp.brandid) {

        NSIndexPath *indexPath = [_selectedIndexPaths objectAtIndex:0];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        if ([tableView.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
            [tableView.delegate tableView:tableView willSelectRowAtIndexPath:indexPath];
        if ([tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
            [tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
        
        // 没有车系默认不限
        if (!_mFilterTemp.seriesid && _viewStyle == UCFilterBrandViewStyleBrand) {
            UITableView *tableView = [_mtvBrand tableViewAtIndex:1];
            [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
            return;
        }

    }
    // 没有品牌默认不限
    else if (_viewStyle == UCFilterBrandViewStyleBrand){
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        return;
    }
    
    [self performSelector:@selector(showSeriesTableView) withObject:nil afterDelay:0.0f];
}

/** 显示车系*/
-(void)showSeriesTableView
{
    // 车系
    if (_mFilterTemp.seriesid) {
        UITableView *tableView = [_mtvBrand tableViewAtIndex:1];
        NSIndexPath *indexPath = [_selectedIndexPaths objectAtIndex:1];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        if ([tableView.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
            [tableView.delegate tableView:tableView willSelectRowAtIndexPath:indexPath];
        if ([tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
            [tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
        
        // 没有车型默认不限
        if (!_mFilterTemp.specid && _viewStyle == UCFilterBrandViewStyleBrand) {
            UITableView *tableView = [_mtvBrand tableViewAtIndex:2];
            [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
            return;
        }
    }
    
    // 车型
    if (_mFilterTemp.specid) {
        UITableView *tableView = [_mtvBrand tableViewAtIndex:2];
        NSIndexPath *indexPath = [_selectedIndexPaths objectAtIndex:2];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        
        NSString *specsId = [[self.carSpecs objectAtIndex:indexPath.row] objectForKey:@"SpecId"];
        NSString *specsName = [[self.carSpecs objectAtIndex:indexPath.row] objectForKey:@"SpecName"];
        if (specsId) {
            self.mFilter.specid = specsId;
            self.mFilter.specidText = specsName;
        } else {
            self.mFilter.specid = nil;
            self.mFilter.specidText = nil;
        }
    }
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
    if (_viewStyle == UCFilterBrandViewStyleBrand) {
        [_dicCarBrands setObject:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"全部品牌", @"Name", nil]] forKey:@"*"];
        orderArray = [NSMutableArray arrayWithObject:@"*"];
    } else {
        orderArray = [NSMutableArray array];
    }
    
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

/** 当前车系 */
- (void)carSeriesWithBrandId:(NSString *)brandId
{
    
    NSUInteger section = 0, row = 0;
    
    NSString *dbPath = [AMCacheManage cacheDbPathForResource:@"Cars"];
    DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:dbPath];
    
    NSArray *carSeries = [dbHelper querryTable:[NSString stringWithFormat:@"SELECT * FROM CarSeries WHERE FatherId = '%d' ORDER BY Orderby", [brandId integerValue]]];
    
    self.dicCarSeries = [NSMutableDictionary dictionary];
    NSMutableArray *merchantNames = nil;
    
    if (_viewStyle == UCFilterBrandViewStyleBrand) {
        [self.dicCarSeries setObject:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"不限车系", @"Name", nil]] forKey:@"*"];
        merchantNames = [NSMutableArray arrayWithObject:@"*"];
    }
    else {
        merchantNames = [NSMutableArray array];
    }
    
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
                [_selectedIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
            }
        }
        
    }
    [self.dicCarSeries setObject:merchantNames forKey:kCarSeriesSectionIndexs];
}

/** 当前车型 */
- (void)carSpecsWithSeriesId:(NSString *)seriesId
{
    // 筛选页增加不限选项
    if (_viewStyle == UCFilterBrandViewStyleBrand || _viewStyle == UCFilterBrandViewStyleSeries)
        self.carSpecs = [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObject:@"不限车型" forKey:@"Name"]];
    else
        self.carSpecs = [NSMutableArray array];
    
    if (seriesId) {
        NSString *dbPath = [AMCacheManage cacheDbPathForResource:@"Cars"];
        DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:dbPath];
        [self.carSpecs addObjectsFromArray:[dbHelper querryTable:[NSString stringWithFormat:@"SELECT * FROM CarSpec WHERE FatherId = '%d' ORDER BY Year DESC", [seriesId integerValue]]]];
    }
    // 没有数据
    if ([self.carSpecs count] == 0) {
        self.carSpecs = [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObject:@"暂无数据" forKey:@"Name"]];
    }
    // 型号索引
    if ([_selectedIndexPaths count] == 2) {
        // 有型号时
        if (_mFilterTemp.specid) {
            for (int i = 0; i < [self.carSpecs count]; i++) {
                NSDictionary *cityTemp = [self.carSpecs objectAtIndex:i];
                if ([[cityTemp objectForKey:@"SpecId"] integerValue] == _mFilterTemp.specid.integerValue) {
                    [_selectedIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    break;
                }
            }
        }
        // 无型号时
        else {
            [_selectedIndexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
    }
}

#pragma mark - MJNIndexViewDataSource
- (NSArray *)sectionIndexTitlesForMJNIndexView:(MJNIndexView *)indexView
{
    return (NSArray *)[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs];
}

- (void)sectionForSectionMJNIndexTitle:(NSString *)title atIndex:(NSInteger)index;
{
    UITableView *tableView = [_mtvBrand tableViewAtIndex:0];
    if ([tableView numberOfSections] > index && index > -1)
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition: UITableViewScrollPositionTop animated:YES];
}

#pragma mark - MultiTablesViewDataSource
/** 多少组 */
- (NSInteger)numberOfLevelsInMultiTablesView:(MultiTablesView *)multiTablesView
{
	return 3;
}

/** 控制sections个数 */
- (NSInteger)multiTablesView:(MultiTablesView *)multiTablesView numberOfSectionsAtLevel:(NSInteger)level
{
    NSInteger number = 0;
    if (level == 0)
        number = [[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs] count];
    else if (level == 1)
        number = [[self.dicCarSeries objectForKey:kCarSeriesSectionIndexs] count];
    else if (level == 2)
        number = 1;
	return number;
}

/** 每栏的row个数 */
- (NSInteger)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 0;
    if (level == 0)
        number = [[self.dicCarBrands objectForKey:[[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs] objectAtIndex:section]] count];
    else if (level == 1)
        number = [[self.dicCarSeries objectForKey:[[self.dicCarSeries objectForKey:kCarSeriesSectionIndexs] objectAtIndex:section]] count];
    else if (level == 2)
        number = self.carSpecs.count;
	return number;
}

/** cell内容 */
- (UITableViewCell *)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    MultiCell *cell = (MultiCell *)[multiTablesView dequeueReusableCellForLevel:level withIdentifier:CellIdentifier];
    if (!cell) {
		cell = [[MultiCell alloc] initWithBrandLogoStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier level:(NSInteger)level marginLeftOfLine:16.0f cellWidth:multiTablesView.width];
        cell.tag = indexPath.row;
	}
    
    if (level == 0) {
        NSArray *cellCarBrands = [self.dicCarBrands objectForKey:[[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs] objectAtIndex:indexPath.section]];
        // logo
        [cell.ivLogoImg sd_setImageWithURL:[[cellCarBrands objectAtIndex:indexPath.row] objectForKey:@"LogoUrl"] placeholderImage:[UIImage imageNamed:@"screen_picture"]];
        cell.labText.text = [[cellCarBrands objectAtIndex:indexPath.row] objectForKey:@"Name"];
        cell.vLine.hidden = cellCarBrands.count == indexPath.row + 1; // 隐藏每个section最后一根分割线
        
        if ([cell.labText.text isEqualToString:@"全部品牌"]) {
            cell.ivLogoImg.hidden = YES;
            cell.vLine.minX = 16;
            cell.labText.minX = 23;
        } else {
            cell.ivLogoImg.hidden = NO;
            cell.vLine.minX = 64;
            cell.labText.minX = 65;
        }
        
    } else if(level == 1) {
        NSArray *cellCarSeries = [self.dicCarSeries objectForKey:[[self.dicCarSeries objectForKey:kCarSeriesSectionIndexs] objectAtIndex:indexPath.section]];
        cell.labText.text = [[cellCarSeries objectAtIndex:indexPath.row] objectForKey:@"Name"];
        cell.vLine.hidden = cellCarSeries.count == indexPath.row + 1; // 隐藏每个section最后一根分割线
    } else if (level == 2) {
        // label自适应
        cell.labText.numberOfLines = 0;
        cell.labText.font = [UIFont systemFontOfSize:14];
        cell.labText.text = [NSString stringWithFormat:@"%@",[[self.carSpecs objectAtIndex:indexPath.row] objectForKey:@"Name"]];
        CGSize size = CGSizeMake(self.width - 180 ,2000);
        CGSize labelsize = [cell.labText.text sizeWithFont:cell.labText.font constrainedToSize:size lineBreakMode:cell.labText.lineBreakMode];
        cell.labText.frame = CGRectMake(cell.labText.minX, 0, labelsize.width, labelsize.height + 16 > 50 ? labelsize.height + 16 : 50);
        
        // 分割线
        cell.vLine.minY = cell.labText.maxY;
        
        // 绘制左边线
        [cell makeView:labelsize.height + 17 > 51 ? labelsize.height + 17 : 51];
    }
    
//    cell.labText.minX = 20 + cell.ivLogoImg.maxX;
    
    if ([cell.labText.text isEqualToString:@"暂无数据"])
        cell.userInteractionEnabled = NO;
    else
        cell.userInteractionEnabled = YES;

    return cell;
}

- (CGFloat)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level heightForRowAtIndexPath:(NSInteger)indexPath
{
    CGFloat height = 51.0f;
    if (level == 2) {
        CGSize size = CGSizeMake(140,2000);
        CGSize labelsize = [[NSString stringWithFormat:@"%@",[[self.carSpecs objectAtIndex:indexPath] objectForKey:@"Name"]] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
        height = labelsize.height + 17 > 51 ? labelsize.height + 17 : 51;
    }
    return height;
}

#pragma mark - MultiTablesViewDelegate
- (void)multiTablesView:(MultiTablesView *)multiTablesView levelDidChange:(NSInteger)level
{
    if (multiTablesView.currentTableViewIndex == level) {
		[multiTablesView.currentTableView deselectRowAtIndexPath:[multiTablesView.currentTableView indexPathForSelectedRow] animated:YES];
	}
}

/** 选择cell */
- (void)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (level == 0) {
        NSArray *cellCarBrands = [self.dicCarBrands objectForKey:[[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs] objectAtIndex:indexPath.section]];
        NSString *brandId = [[cellCarBrands objectAtIndex:indexPath.row] objectForKey:@"BrandId"];
        NSString *brandName = [[cellCarBrands objectAtIndex:indexPath.row] objectForKey:@"Name"];
        
        self.mFilter.seriesid = nil;
        self.mFilter.specid = nil;
        self.mFilter.seriesidText = nil;
        self.mFilter.specidText = nil;
        
        if (brandId) {
            self.mFilter.brandid = brandId;
            self.mFilter.brandidText = brandName;
            [self carSeriesWithBrandId:brandId];
        } else {
            multiTablesView.automaticPush = NO;
            self.mFilter.brandid = nil;
            self.mFilter.brandidText = nil;
            [self.vFilter closeFilter:YES];
        }
    }
    else if (level == 1) {
        NSArray *cellCarSeries = [self.dicCarSeries objectForKey:[[self.dicCarSeries objectForKey:kCarSeriesSectionIndexs] objectAtIndex:indexPath.section]];
        NSString *seriesId = [[cellCarSeries objectAtIndex:indexPath.row] objectForKey:@"SeriesId"];
        NSString *seriesName = [[cellCarSeries objectAtIndex:indexPath.row] objectForKey:@"Name"];
        
        self.mFilter.specid = nil;
        self.mFilter.specidText = nil;
        if (seriesId) {
            self.mFilter.seriesid = seriesId;
            self.mFilter.seriesidText = seriesName;
            [self carSpecsWithSeriesId:seriesId];
        } else {
            multiTablesView.automaticPush = NO;
            self.mFilter.seriesid = seriesId;
            self.mFilter.seriesidText = seriesName;
            [self.vFilter closeFilter:YES];
        }
        
    }
}

/** 选择完毕 */
- (void)multiTablesView:(MultiTablesView *)multiTablesView lastLevel:(NSInteger)lastLevel didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *specsId = [[self.carSpecs objectAtIndex:indexPath.row] objectForKey:@"SpecId"];
    NSString *specsName = [[self.carSpecs objectAtIndex:indexPath.row] objectForKey:@"Name"];
    
    if (specsId) {
        self.mFilter.specid = specsId;
        self.mFilter.specidText = specsName;
    } else {
        self.mFilter.specid = nil;
        self.mFilter.specidText = nil;
    }
    if (_viewStyle == UCFilterBrandViewStyleBrand) {
        [self.vFilter closeFilter:YES];
    } else {
        if ([self.delegate respondsToSelector:@selector(filterBrandView: filterModel:)]) {
            [self.delegate filterBrandView:self filterModel:self.mFilter];
        }
    }
}

#pragma mark - Sections Headers & Footers
/** 设置sections 的 footers 高度 */
- (CGFloat)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level heightForFooterInSection:(NSInteger)section
{
	return 0.0;
}

/** 设置sections 的 Headers 高度 */
- (CGFloat)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level heightForHeaderInSection:(NSInteger)section
{
    if ((section == 0 && _viewStyle == UCFilterBrandViewStyleBrand) || level > 1) {
        return 0;
    }
	return 20.0;
}

/** 设置sections 的 索引值 */
//- (NSArray *)sectionIndexTitlesForTableView:(MultiTablesView *)multiTablesView level:(NSInteger)level
//{
//    return (NSArray *)[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs];
//}

/** 设置分割线风格 */
- (UITableViewCellSeparatorStyle)multiTablesView:(MultiTablesView *)multiTablesView separatorStyleForLevel:(NSInteger)level
{
    return UITableViewCellSeparatorStyleNone;
}

/** 设置sections 的 Header */
- (UIView *)multiTablesView:(MultiTablesView *)multiTablesView sliderLevel:(NSInteger)sliderLevel viewForHeaderInSection:(NSInteger)section
{
    UIView *vHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, multiTablesView.frame.size.width, 20)];
    // 背景
    UIView *vHeaderBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, vHeader.frame.size.width, 20)];
    vHeaderBG.backgroundColor = kColorGrey5;
    [vHeader addSubview:vHeaderBG];
    
    // 标题
    CGFloat marginLeftText = 7.0f;
    if (sliderLevel == 0)
        marginLeftText = 26;
    else if (sliderLevel == 1)
        marginLeftText = 20;
    
    NSString *strSection = sliderLevel == 0 ? [NSString stringWithFormat:@"%@",[[self.dicCarBrands objectForKey:kCarBrandsSectionIndexs] objectAtIndex:section]] : [NSString stringWithFormat:@"%@",[[self.dicCarSeries objectForKey:kCarSeriesSectionIndexs] objectAtIndex:section]];
    
    UILabel *labTittle = [[UILabel alloc] initWithFrame:CGRectMake(marginLeftText, 0, vHeaderBG.frame.size.width, 20)];
    labTittle.font = [UIFont boldSystemFontOfSize:sliderLevel == 0 ? 15 : 14];
    labTittle.backgroundColor = [UIColor clearColor];
    labTittle.textColor = kColorBlue1;
    labTittle.text = strSection;
    [vHeaderBG addSubview:labTittle];
    
    // 左侧线
    UIView *vLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLinePixel, vHeader.height)];
    vLine.backgroundColor = kColorNewLine;
    [vHeader addSubview:vLine];
    
    return vHeader;
}

- (void)dealloc
{
    AMLog(@"dealloc...");
}

@end
