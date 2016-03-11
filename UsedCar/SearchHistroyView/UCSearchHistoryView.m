//
//  UCSearchHistoryView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-11.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSearchHistoryView.h"
#import "SearchHistoryCell.h"
#import "SearchHistoryClearCell.h"
#import "AMCacheManage.h"

static NSString *identifier = @"CELL"; //普通 cell
static NSString *clearIdentifier = @"ClearCELL"; //最后一个按钮的 cell

@interface UCSearchHistoryView ()
<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) UILabel *labNoData;

@end

@implementation UCSearchHistoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [UMStatistics event:pv_3_8_buycar_search];
        self.dataArray = [[NSMutableArray alloc] init];
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        
        UIView *_backgroundview = [[UIView alloc] initWithFrame:self.tableView.bounds];
        [_backgroundview setBackgroundColor:kColorNewBackground];
        [self.tableView setBackgroundView:_backgroundview];
        
        [self addSubview:self.tableView];
        
        [self getLocalSearchHistory];
    }
    return self;
}

-(void)refreshTable{
    [self.dataArray removeAllObjects];
    [self getLocalSearchHistory];
    [self.tableView reloadData];
}

-(void)saveHistoryWithNewEntry:(NSString*)searchText{
    if (![self.dataArray containsObject:searchText]) {
        if (self.dataArray.count >= 20) {
            [self.dataArray removeLastObject];
        }
        [self.dataArray insertObject:searchText atIndex:0];
        if ([AMCacheManage setSearchHistory:self.dataArray]) {
            [self refreshTable];
        }
    }
}

-(void)setNoSearchHistoryHidden:(BOOL)boolean{
    if (!_labNoData) {
        _labNoData = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - (DEVICE_IS_IPHONE5 ? 50 : 100))];
        _labNoData.backgroundColor = kColorNewBackground;
        _labNoData.text = @"暂无搜索记录";
        _labNoData.textAlignment = NSTextAlignmentCenter;
        _labNoData.font = kFontLarge;
        _labNoData.textColor = kColorNewGray2;
        [self addSubview:_labNoData];
    }
    _labNoData.hidden = boolean;
}

#pragma mark - Local Search History
- (void)getLocalSearchHistory{
    
    [self.dataArray addObjectsFromArray:[AMCacheManage getSearchHistory]];;
    
    if (self.dataArray.count > 0) {
        [self.tableView reloadData];
        [self setNoSearchHistoryHidden:YES];
    }
    else{
        [self setNoSearchHistoryHidden:NO];
    }
    
}

- (void)removeLocalSearchHistory{
    
    if ([AMCacheManage removeSearchHistory]) {
//        [[AMToastView toastView] showMessage:@"成功移除历史记录" icon:kImageRequestSuccess duration:AMToastDurationShort];
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
        [self setNoSearchHistoryHidden:NO];
    }
    else{
//        [[AMToastView toastView] showMessage:@"移除历史记录失败了" icon:kImageRequestError duration:AMToastDurationNormal];
    }
    
}

#pragma mark - UIScroll View Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(shouldHideKeyboard)]) {
        [self.delegate shouldHideKeyboard];
    }
}

#pragma mark - uitableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataArray.count > 0) {
        return self.dataArray.count + 1;
    }
    else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row != self.dataArray.count) {
        SearchHistoryCell *cell = (SearchHistoryCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[SearchHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier cellWidth:tableView.width];
        }
        
        [cell.nameLabel setText:[self.dataArray objectAtIndex:indexPath.row]];
        return cell;
    }
    else{
        SearchHistoryClearCell *clearCell = (SearchHistoryClearCell *)[tableView dequeueReusableCellWithIdentifier:clearIdentifier];
        if (!clearCell) {
            clearCell = [[SearchHistoryClearCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:clearIdentifier cellWidth:tableView.width];
        }
        
        return clearCell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[UIColor whiteColor]];
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    [backgroundView setBackgroundColor:kColorNewLine];
    [cell setSelectedBackgroundView:backgroundView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row != self.dataArray.count) {
        if ([self.delegate respondsToSelector:@selector(searchHistoryDidSelectRowWithKeyword:)]) {
            [self.delegate searchHistoryDidSelectRowWithKeyword:[self.dataArray objectAtIndex:indexPath.row]];
        }
    }
    else{
        // 清楚历史记录
        [self removeLocalSearchHistory];
        
        /* 需求暂不做提示
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"是否清除搜索历史记录?"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        [alertView show];
         */
    }
}

#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) { //确定
        [self removeLocalSearchHistory];
    }
    
}



@end
