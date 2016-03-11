//
//  UCExpandSpecView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-9.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCExpandSpecView.h"
#import "DatabaseHelper1.h"
#import "SpecCell.h"
#import "UCMainView.h"
#import "AMCacheManage.h"
#import "NSString+Util.h"

@interface UCExpandSpecView()
{
    BOOL isShowOpen;
    
}

@property (nonatomic, weak)   UCFilterModel  *mFilterTemp;  // 未经过改动的model
@property (nonatomic, strong) UCFilterModel  *mFilter;
@property (nonatomic, strong) NSMutableArray *dicCarSpec;   //车型
@property (strong, nonatomic) UITableView    *tableView;
@property (strong, nonatomic) NSIndexPath    *selectedIndex;

@end

@implementation UCExpandSpecView

- (id)initWithFrame:(CGRect)frame filterTemp:(UCFilterModel *)mFilterTemp filter:(UCFilterModel *)mFilter SeriesID:(NSString*)seriesID
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _mFilterTemp = mFilterTemp;
        self.mFilter = mFilter;
        self.seriesID = seriesID;
        
        [self initView];
    }
    return self;
}

- (void)initView
{
    
    [self carSpecsWithSeriesId:self.seriesID];
    
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    
    _tableView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    UIView *_backgroundview = [[UIView alloc] initWithFrame:self.bounds];
    [_backgroundview setBackgroundColor:[UIColor whiteColor]];
    [_tableView setBackgroundView:_backgroundview];
    _tableView.separatorColor=[UIColor clearColor];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    
    [self addSubview:_tableView];
    
    [_tableView reloadData];
}

/** 当前车型 */
- (void)carSpecsWithSeriesId:(NSString *)seriesId
{
    // 筛选页增加不限选项
    self.dicCarSpec = [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObject:@"不限车型" forKey:@"Name"]];
    
    if (seriesId) {
        NSString *dbPath = [AMCacheManage cacheDbPathForResource:@"Cars"];
        DatabaseHelper1 *dbHelper = [[DatabaseHelper1 alloc] initWithDbPath:dbPath];
        [self.dicCarSpec addObjectsFromArray:[dbHelper querryTable:[NSString stringWithFormat:@"SELECT * FROM CarSpec WHERE FatherId = '%d' ORDER BY Year DESC", [seriesId integerValue]]]];
    }
    // 没有数据
    if ([self.dicCarSpec count] == 0) {
        self.dicCarSpec = [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObject:@"暂无数据" forKey:@"Name"]];
    }
    
    // 型号索引
    // 有型号时
    if (_mFilterTemp.specid) {
        for (int i = 0; i < [self.dicCarSpec count]; i++) {
            NSDictionary *cityTemp = [self.dicCarSpec objectAtIndex:i];
            if ([[cityTemp objectForKey:@"SpecId"] integerValue] == _mFilterTemp.specid.integerValue) {
                self.selectedIndex = [NSIndexPath indexPathForRow:i inSection:0];
                break;
            }
        }
    }
    // 无型号时
    else {
        self.selectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    }
}


#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dicCarSpec count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SpecCell *cell = (SpecCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[SpecCell alloc] initWithBrandLogoStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier level:0 marginLeftOfLine:16.0f cellWidth:tableView.width];
        cell.tag = indexPath.row;
    }
    
    NSDictionary *specDict = [self.dicCarSpec objectAtIndex:indexPath.row];
    NSString *title = [specDict objectForKey:@"Name"];
    cell.labText.text = title.trim;
    cell.vLine.hidden = self.dicCarSpec.count == indexPath.row + 1; // 隐藏每个section最后一根分割线
    cell.ivLogoImg.hidden = YES;
    //    cell.labText.minX = 20 + cell.ivLogoImg.maxX;
    
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *specsId = [[self.dicCarSpec objectAtIndex:indexPath.row] objectForKey:@"SpecId"];
    NSString *specsName = [[self.dicCarSpec objectAtIndex:indexPath.row] objectForKey:@"Name"];
    
    if (specsId) {
        self.mFilter.specid = specsId;
        self.mFilter.specidText = specsName;
    } else {
        self.mFilter.specid = nil;
        self.mFilter.specidText = nil;
    }
//    AMLog(@"%@", self.mFilter);
    
    if ([self.delegate respondsToSelector:@selector(UCExpandSpecView:filterModel:)]) {
        [self.delegate UCExpandSpecView:self filterModel:_mFilter];
    }
}

- (void)setSelectSpecCell
{
    // 车型
    if (_mFilterTemp.specid) {
        [self.tableView selectRowAtIndexPath:self.selectedIndex animated:NO scrollPosition:UITableViewScrollPositionMiddle];
//        if ([self.tableView.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
//            [self.tableView.delegate tableView:self.tableView willSelectRowAtIndexPath:self.selectedIndex];
//        if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
//            [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:self.selectedIndex];
    }
    else{
        if (_mFilterTemp.seriesid.integerValue > 0 && _mFilterTemp.specid.integerValue == 0) {
            NSIndexPath *indexPathZero = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView selectRowAtIndexPath:indexPathZero animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
    }
}



@end
