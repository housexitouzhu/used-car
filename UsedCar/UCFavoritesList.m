//
//  UCFavoritesCarList.m
//  UsedCar
//
//  Created by wangfaquan on 13-12-9.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCFavoritesList.h"
#import "UCCarInfoCell.h"
#import "CKRefreshControl.h"
#import "UCFavoritesModel.h"
#import "UCCarDetailView.h"
#import "AMCacheManage.h"
#import "UCCarDetailInfoModel.h"
#import "UCCarInfoModel.h"
#import "UserLogInOutHelper.h"
#import "APIHelper.h"
#import "UCFavoritesCloudListModel.h"
#import "UCFavoritesCloudModel.h"

#define kListPageSize       30
#define kMoreViewHeight     90
#define kLoadViewHeight     40
#define kFooterViewHeight   50

const static CGFloat kDeleteButtonWidth = 85.f;
const static CGFloat kDeleteButtonHeight = UCCarInfoCellHeight;

@interface UCFavoritesList ()
{
    UISwipeGestureRecognizer * _leftGestureRecognizer;
    UISwipeGestureRecognizer * _rightGestureRecognizer;
    UITapGestureRecognizer * _tapGestureRecognizer;
    UIButton * _deleteButton;
    NSInteger pageIndex;
}

@property (nonatomic, strong) UIView *vFooter;
@property (nonatomic, strong) UITableView *tvFavoritesList;
@property (nonatomic, strong) CKRefreshControl *pullRefresh;
@property (nonatomic, strong) UserLogInOutHelper *syncHelper;
@property (nonatomic, strong) APIHelper *listHelper;

@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, strong) UIView *vLoadMore;
@property (nonatomic, strong) UILabel *hintLabel;

@end

@implementation UCFavoritesList

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView;
{
    self.backgroundColor = kColorNewBackground;
    
    pageIndex = 1;
    _totalCount = 0;
    
    self.loadFavoritesInCloud = [AMCacheManage currentUserType] == UserStylePersonal;
    
    // 无数据提示
    _hintLabel = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 0, self.width, self.height)];
    //    _hintLabel.hidden = YES;
    _hintLabel.text = @"没有收藏的车辆";
    _hintLabel.textAlignment = NSTextAlignmentCenter;
    _hintLabel.font = [UIFont systemFontOfSize:16];
    _hintLabel.textColor = kColorNewGray2;
    _hintLabel.backgroundColor = kColorClear;
    [self addSubview:_hintLabel];
    
    // 列表
    _tvFavoritesList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _tvFavoritesList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tvFavoritesList.dataSource = self;
    _tvFavoritesList.delegate = self;
    _tvFavoritesList.tableFooterView = _vFooter;
    _tvFavoritesList.backgroundColor = kColorClear;
    [self addSubview:_tvFavoritesList];
    
    if (self.loadFavoritesInCloud) {
        _mFavoritesList = [[NSMutableArray alloc] init];
        
        _pullRefresh = [[CKRefreshControl alloc] initInScrollView:_tvFavoritesList];
        _pullRefresh.titlePulling = @"下拉即可刷新";
        _pullRefresh.titleReady = @"松开立即刷新";
        _pullRefresh.titleRefreshing = @"正在加载中…";
        _pullRefresh.backgroundColor = [UIColor clearColor];
        [_pullRefresh addTarget:self action:@selector(refreshFavoritesList) forControlEvents:UIControlEventValueChanged];
        
        
        
        // 列表垫底视图
        _vFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, kFooterViewHeight)];
        [_vFooter setBackgroundColor:[UIColor clearColor]];
        
        // 加载更多
        _vLoadMore = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tvFavoritesList.width, kLoadViewHeight)];
        [_vLoadMore setBackgroundColor:[UIColor clearColor]];
        
        UILabel *labText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _vLoadMore.width, kLoadViewHeight)];
        labText.text = @"正在加载更多…";
        labText.textColor = kColorGrey2;
        labText.font = [UIFont systemFontOfSize:15];
        labText.backgroundColor = [UIColor clearColor];
        labText.textAlignment = NSTextAlignmentCenter;
        labText.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        
        // 菊花
        UIActivityIndicatorView *aivLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        aivLoading.hidesWhenStopped = NO;
        aivLoading.center = CGPointMake((self.width - [labText.text sizeWithFont:labText.font].width) / 2 - aivLoading.width, labText.centerY);
        aivLoading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        aivLoading.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [aivLoading startAnimating];
        
        [_vLoadMore addSubview:labText];
        [_vLoadMore addSubview:aivLoading];
        
    }
    else{
        _mFavoritesList = [[NSMutableArray alloc] initWithArray:[AMCacheManage currentFavourites]];
    }
    
    
    
    [self initDeleteView];
}

/** 初始化删除按钮 */
- (void)initDeleteView
{
    _leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    _leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftGestureRecognizer.delegate = self;
    [_tvFavoritesList addGestureRecognizer:_leftGestureRecognizer];
    
    _rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    _rightGestureRecognizer.delegate = self;
    _rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [_tvFavoritesList addGestureRecognizer:_rightGestureRecognizer];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    _tapGestureRecognizer.delegate = self;
    
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _deleteButton.frame = CGRectMake(self.width, 0, kDeleteButtonWidth, kDeleteButtonHeight);
    _deleteButton.backgroundColor = kColorRed;
    _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    _deleteButton.titleLabel.font = kFontLarge;
    [_deleteButton setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    [_tvFavoritesList addSubview:_deleteButton];
}

#pragma mark - public Method
/** 刷新收藏列表 */
- (void)refreshFavoritesList
{
//    [_pullRefresh beginRefreshing];
    
    pageIndex = 1;
    
    if (self.loadFavoritesInCloud) {
        
        if ([AMCacheManage SYNCclientFavoritesNeeded] && ![AMCacheManage SYNCclientFavoritesSuccess]) {
            
            if (!self.syncHelper) {
                self.syncHelper = [[UserLogInOutHelper alloc] init];
            }
            
            [self.syncHelper clientSyncFavoritesWithFinishBlock:^(BOOL success) {
                
                [self getFavoritesInCloudList:pageIndex isRefreshing:YES];
                
            }];
        }
        else{
            [self getFavoritesInCloudList:pageIndex isRefreshing:YES];
        }
    }
    else{
        [_mFavoritesList removeAllObjects];
        _mFavoritesList = [[NSMutableArray alloc] initWithArray:[AMCacheManage currentFavourites]];
        [_tvFavoritesList reloadData];
        _tvFavoritesList.tableFooterView = _vFooter;
    }
    
    // 是否显示无数据提示
    _hintLabel.hidden = _mFavoritesList.count != 0;
}


- (void)getFavoritesInCloudList:(NSInteger)page isRefreshing:(BOOL)isRefreshing{
    if(!self.listHelper){
        self.listHelper = [[APIHelper alloc] init];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.listHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        [weakSelf.pullRefresh endRefreshing];
        
        if (error) {
            AMLog(@"%@",error.domain);
            [[AMToastView toastView] showMessage:@"链接失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            weakSelf.hintLabel.hidden = weakSelf.mFavoritesList.count != 0;
            
            return;
        }
        
        //成功后刷新 list
        // 需要建立新的 favorites model
        if (apiHelper.data.length>0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            AMLog(@"message %@ \nresult: %@", mBase.message, mBase.result);
            
            if (mBase.returncode == 0) {
                [weakSelf.hintLabel setHidden:YES];
                
                UCFavoritesCloudListModel *mFavoritesCloud = [[UCFavoritesCloudListModel alloc] initWithJson:mBase.result];
                weakSelf.totalCount = mFavoritesCloud.rowcount.integerValue;
                
                if (isRefreshing && weakSelf.mFavoritesList.count>0) {
                    [weakSelf.mFavoritesList removeAllObjects];
                }
                
                if (weakSelf.totalCount > 0) {
                    [weakSelf.hintLabel setHidden:YES];
                }
                else{
                    [weakSelf.hintLabel setHidden:NO];
                    
                }
                
                weakSelf.tvFavoritesList.tableFooterView = weakSelf.vFooter;
                [weakSelf.mFavoritesList addObjectsFromArray:mFavoritesCloud.carlist];
                
                [weakSelf.tvFavoritesList reloadData];
                
            }
            else{
                if (mBase.message) {
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                }
                else{
                    [[AMToastView toastView] hide];
                }
            }
        }
     
     
    }];
    
    [self.listHelper getFavoritesListPageIndex:page size:kListPageSize];
}

#pragma mark - private Method
/** 手势操作 */
- (void)swiped:(UISwipeGestureRecognizer *)gestureRecognizer
{
    NSIndexPath * indexPath = [self cellIndexPathForGestureRecognizer:gestureRecognizer];
    if(indexPath == nil)
        return;
    if(![_tvFavoritesList.dataSource tableView:_tvFavoritesList canEditRowAtIndexPath:indexPath]) {
        return;
    }
    
    if(gestureRecognizer == _leftGestureRecognizer && ![_editingIndexPath isEqual:indexPath]) {
        UITableViewCell * cell = [_tvFavoritesList cellForRowAtIndexPath:indexPath];
        [self setEditing:YES atIndexPath:indexPath cell:cell];
    } else if (gestureRecognizer == _rightGestureRecognizer && [_editingIndexPath isEqual:indexPath]){
        UITableViewCell * cell = [_tvFavoritesList cellForRowAtIndexPath:indexPath];
        [self setEditing:NO atIndexPath:indexPath cell:cell];
    }
}

- (void)deleteItem:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否确认删除" message:Nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alert show];
}

- (void)tapped:(UIGestureRecognizer *)gestureRecognizer
{
    if(_editingIndexPath) {
        UITableViewCell * cell = [_tvFavoritesList cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [_mFavoritesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"UCCarInfoCell";
    UCCarInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
        cell = [[UCCarInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier cellWidth:tableView.width];
    
    UCCarInfoModel *mCarInfor = [[UCCarInfoModel alloc] init];
    
    if (self.loadFavoritesInCloud) {
        UCFavoritesCloudModel *mFavorites = [_mFavoritesList objectAtIndex:indexPath.row];
        mCarInfor.image            = mFavorites.image;
        mCarInfor.carname          = mFavorites.carname;
        mCarInfor.sourceid         = mFavorites.sourceid;
        mCarInfor.price            = mFavorites.price;
        mCarInfor.mileage          = mFavorites.mileage;
        mCarInfor.isnewcar         = mFavorites.isnewcar;
        mCarInfor.invoice          = mFavorites.extendedrepair;
        mCarInfor.registrationdate = [mFavorites.registrationdate substringToIndex:4];
    }
    else{
        UCFavoritesModel *mFavorite = [_mFavoritesList objectAtIndex:indexPath.row];
        
        mCarInfor.image            = mFavorite.image;
        mCarInfor.carname          = mFavorite.name;
        mCarInfor.sourceid         = mFavorite.isDealer;
        mCarInfor.price            = mFavorite.price;
        mCarInfor.mileage          = mFavorite.mileage;
        mCarInfor.isnewcar         = mFavorite.isnewcar;
        mCarInfor.invoice          = mFavorite.invoice;
        mCarInfor.registrationdate = [mFavorite.registrationDate substringToIndex:4];
    }
    

    [cell makeView:mCarInfor isShowSelect:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UCCarInfoCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MainViewController *vcMain = [MainViewController sharedVCMain];
    
    UCCarInfoModel *mCarInfoTemp;
    if (self.loadFavoritesInCloud) {
        UCFavoritesCloudModel *mFavorites = [_mFavoritesList objectAtIndex:indexPath.row];
        mCarInfoTemp = [[UCCarInfoModel alloc] initWithFavoriteCloudModel:mFavorites];
    }
    else{
        UCFavoritesModel *mCarInfo = [_mFavoritesList objectAtIndex:indexPath.row];
        mCarInfoTemp = [[UCCarInfoModel alloc] initWithFavoriteModel:mCarInfo];
    }
    
    
    UCCarDetailView *vCarDetail = [[UCCarDetailView alloc] initWithFrame:vcMain.vMain.bounds mCarInfo:mCarInfoTemp];
    vCarDetail.vFavoritesList = self;
    [vcMain openView:vCarDetail animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 最后一个cell 开始加载更多
    if (indexPath.row == _mFavoritesList.count - 1) {
        // 满页情况下才有下一页 & 没有正在加载更多
        if (_mFavoritesList.count % kListPageSize == 0) {
            if (_tvFavoritesList.tableFooterView != _vLoadMore) {
                _tvFavoritesList.tableFooterView = _vLoadMore;
                if (_mFavoritesList.count < _totalCount) {
                    pageIndex++;
                    [self getFavoritesInCloudList:pageIndex isRefreshing:NO];
                }
                else{
                    _vFooter.height = 0;
                    _tvFavoritesList.tableFooterView = _vFooter;
                }
            }
        } else {
            _vFooter.height = kLoadViewHeight;
            _tvFavoritesList.tableFooterView = _vFooter;
        }
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.loadFavoritesInCloud) {
        //删除云端收藏
        
        UCFavoritesCloudModel *mFavCloud = [_mFavoritesList objectAtIndex:indexPath.row];
        
        APIHelper *delhelper = [[APIHelper alloc] init];
        [[AMToastView toastView] showLoading:@"删除中" cancel:^{
            [[AMToastView toastView]hide];
            [delhelper cancel];
        }];
        
        [delhelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
            
            if (error) {
                [[AMToastView toastView] showMessage:@"删除收藏失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
                return ;
            }
            if (apiHelper.data.length > 0) {
                BaseModel *mbase = [[BaseModel alloc] initWithData:apiHelper.data];
                if (mbase.returncode == 0) {
                    [[AMToastView toastView]hide];
                    [_mFavoritesList removeObjectAtIndex:indexPath.row];
                    
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    
                    if (_mFavoritesList.count == 0) {
                        [self refreshFavoritesList];
                    }
                }
                else{
                    [[AMToastView toastView] showMessage:@"删除收藏失败" icon:kImageRequestError duration:AMToastDurationNormal];
                }
            }
            else{
                [[AMToastView toastView] showMessage:@"删除收藏失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            }
            
        }];
        [delhelper addOrDeleteFavorite:mFavCloud.carid toType:0];
        
    }
    else{
        // 删除数据源
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            UCFavoritesModel *mCarInfo = [_mFavoritesList objectAtIndex:indexPath.row];
            [_mFavoritesList removeObjectAtIndex:indexPath.row];
            
            [AMCacheManage deleteCarFromFavourite:mCarInfo.quoteID];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            if (_mFavoritesList.count == 0) {
                [self refreshFavoritesList];
            }
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPat
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (NSIndexPath *)cellIndexPathForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    UIView * view = gestureRecognizer.view;
    if(![view isKindOfClass:[UITableView class]]) {
        return nil;
    }
    CGPoint point = [gestureRecognizer locationInView:view];
    NSIndexPath * indexPath = [_tvFavoritesList indexPathForRowAtPoint:point];
    return indexPath;
}

- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell
{
    if(editing) {
        if(_editingIndexPath) {
            UITableViewCell * editingCell = [_tvFavoritesList cellForRowAtIndexPath:_editingIndexPath];
            [self setEditing:NO atIndexPath:_editingIndexPath cell:editingCell];
        }
        [self addGestureRecognizer:_tapGestureRecognizer];
    } else {
        [self removeGestureRecognizer:_tapGestureRecognizer];
    }
    
    CGRect frame = cell.frame;
    
    CGFloat cellXOffset;
    CGFloat deleteButtonXOffsetOld;
    CGFloat deleteButtonXOffset;
    
    if(editing) {
        cellXOffset = -kDeleteButtonWidth;
        deleteButtonXOffset = self.width - kDeleteButtonWidth;
        deleteButtonXOffsetOld = self.width;
        _editingIndexPath = indexPath;
    } else {
        cellXOffset = 0;
        deleteButtonXOffset = self.width;
        deleteButtonXOffsetOld = self.width - kDeleteButtonWidth;
        _editingIndexPath = nil;
    }
    
    _cellHeight = [_tvFavoritesList.delegate tableView:_tvFavoritesList heightForRowAtIndexPath:indexPath];
    _deleteButton.frame = (CGRect) {deleteButtonXOffsetOld, frame.origin.y, _deleteButton.frame.size.width, _cellHeight};
    
    [UIView animateWithDuration:0.2f animations:^{
        cell.frame = CGRectMake(cellXOffset, frame.origin.y, frame.size.width, frame.size.height);
        _deleteButton.frame = (CGRect) {deleteButtonXOffset, frame.origin.y, _deleteButton.frame.size.width, _cellHeight};
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 弹出框删除和取消
    if (buttonIndex == 1) {
        
        NSIndexPath * indexPath = _editingIndexPath;
        UITableViewCell * cell = [_tvFavoritesList cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        
        [_tvFavoritesList.dataSource tableView:_tvFavoritesList commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
        
        _editingIndexPath = nil;
        [UIView animateWithDuration:0.2f animations:^{
            CGRect frame = _deleteButton.frame;
            _deleteButton.frame = (CGRect){frame.origin, frame.size.width, 0};
        } completion:^(BOOL finished) {
            CGRect frame = _deleteButton.frame;
            _deleteButton.frame = (CGRect){self.width, frame.origin.y, frame.size.width, kDeleteButtonHeight};
        }];
        
    } else if (buttonIndex == 0) {
        
        UITableViewCell * cell = [_tvFavoritesList cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        CGRect frame = cell.frame;
        
        CGFloat cellXOffset = 0.0;
        [UIView animateWithDuration:0.2f animations:^{
            cell.frame = CGRectMake(cellXOffset, frame.origin.y, frame.size.width, frame.size.height);
            _deleteButton.frame = (CGRect) {self.width, frame.origin.y, _deleteButton.frame.size.width, _cellHeight};
        }];
        
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // 关掉手势使其不是第一响应者
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 接受touch事件
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark -UIscrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_editingIndexPath) {
        UITableViewCell *cell = [_tvFavoritesList cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        _editingIndexPath = nil;
    }
}
@end
