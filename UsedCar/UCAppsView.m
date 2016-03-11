//
//  UCAppsView.m
//  UsedCar
//
//  Created by wangfaquan on 14-1-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCAppsView.h"
#import "UIImageView+WebCache.h"
#import "NSString+Util.h"
#import "UCHotAppModel.h"
#import "UIIndexControl.h"

#define kUCCachesPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define kAppsCachePath [kUCCachesPath stringByAppendingPathComponent:@"apps_ios.txt"]
#define viewTagBase 100

@interface UCAppsView ()

@property (nonatomic, copy) NSString *localVersion;
@property (nonatomic, strong) UIIndexControl *pcPhoto;
@property (nonatomic) NSInteger pageCount;

@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) UIScrollView *svSmail;

@end

@implementation UCAppsView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _arrData = [NSMutableArray arrayWithCapacity:20];
        [self initViews];
        // 加载本地数据
//        [self getLocalData];
        // 加载网络数据
        [self getAppData];
    }
    return self;
}

#pragma mark - initView
- (void)initViews
{
    _svSmail = [[UIScrollView alloc] initWithFrame:self.bounds];
    _svSmail.delegate = self;
    _svSmail.backgroundColor = kColorWhite;
    _svSmail.showsHorizontalScrollIndicator = NO;
    _svSmail.pagingEnabled = YES;

    [self addSubview:_svSmail];
}

#pragma mark - private Method
/** 视图创建*/
- (void)initScrollview:(NSMutableArray *)dataArry
{
    if (dataArry) {
        int index = 0;
        int count = [dataArry count];      // 一共是多少个元素,解析数据的个数
        int rowCount = 4;     // 每行是4个元素
        int pageCount = 8;     // 每页是8个
        int pageIndex = count % pageCount == 0 ? count / pageCount : count / pageCount + 1;    // 多少页
        int pageRowCount = count % rowCount == 0 ? count / rowCount : count / rowCount + 1;
        // 多少行
        int rowarr[20] = {0};
        
        _pageCount = pageIndex;
        
        [self initPageControl];
        // 2行
        for (int i = 0 ; i < pageRowCount / 2; i++)
            rowarr[i] = 2;
        
        // 1行
        if (pageRowCount % 2)
            rowarr[pageRowCount / 2] = 1;
        
        [_svSmail removeAllSubviews];
        for (int i = 0; i < pageIndex; i++) {
            // 创建视图
            UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(self.width * i, 20, self.width, 80 * 3)];
            [_svSmail addSubview:pageView];
            
            for (int j = 0; j < rowarr[i]; j ++) {
                for (int m = 0; m < rowCount; m ++) {
                    if (index++ < count) {
                        // 创建视图
                        UIView * vIcon = [[UIView alloc] initWithFrame:CGRectMake((self.width - 24 * 2 - 200) / 3 * m + m * 50 + 24, 50 * j + 30 * j, 50, 50)];
                        [pageView addSubview:vIcon];
                        vIcon.tag = viewTagBase + index - 1;
                        
                        // 添加点击手势
                        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taps:)];
                        [vIcon addGestureRecognizer:tapView];
                        
                        // 加载图片
                        UIImageView *ivPicture = [[UIImageView alloc] initWithFrame:vIcon.bounds];
                        
                        NSString *url = ((UCHotAppModel *)[dataArry objectAtIndex:index - 1]).icon;
                        
                        // 检查内置图片
                        UIImage *imgIcon = [UIImage imageNamed:url.md5];
                        // 无内置图片加载网络数据
                        if (imgIcon)
                            [ivPicture setImage:imgIcon];
                        else
                            [ivPicture sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"hot_apps"]];
                        
                        // 应用名称
                        UILabel *labName = [[UILabel alloc] initWithClearFrame:CGRectMake((self.width - 24 * 2 - 200) / 3 * m + m * 50 + 20, 50 * j + 30 * j + 50, 60, 20)];
                        labName.textAlignment = NSTextAlignmentCenter;
                        [pageView addSubview:labName];
                        [vIcon addSubview:ivPicture];
                        labName.text = ((UCHotAppModel *)[dataArry objectAtIndex:index - 1]).name;
                        labName.font = [UIFont systemFontOfSize:10];
                    }
                }
            }
        }
        _svSmail.contentSize = CGSizeMake(self.width * pageIndex, self.height);
    }
}

- (void)initPageControl
{
    // 索引
    if (!_pcPhoto) {
        _pcPhoto = [[UIIndexControl alloc] initWithFrame:CGRectMake((self.width - 200) / 2, 170, 200, 20)currentImageName:@"individual_points_h" commonImageName:@"individual_points"];
        [self addSubview:_pcPhoto];
    }
    
    _pcPhoto.hidesForSinglePage = YES;
    _pcPhoto.userInteractionEnabled = NO;
    _pcPhoto.numberOfPages = _pageCount;
    
    [_pcPhoto setCurrentPage:0];
    
}

/** 请求本地数据 不需要了*/
- (void)getLocalData
{
    // 资源配置
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"apps_ios" ofType:@"txt"];
    NSDictionary *dicResource = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:resourcePath] options:NSJSONReadingMutableContainers error:nil];
    _localVersion = [dicResource objectForKey:@"version"];
    NSArray *apps = [dicResource objectForKey:@"array"];
    
    // 缓存配置
    NSDictionary *dicCache = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:kAppsCachePath]) {
        dicCache = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:kAppsCachePath] options:NSJSONReadingMutableContainers error:nil];
    }
    
    if (dicCache) {
        NSString *cacheVersion = [dicCache objectForKey:@"version"];
        if (cacheVersion.floatValue > _localVersion.floatValue) {
            _localVersion = cacheVersion;
            apps = [dicCache objectForKey:@"array"];
        }
    }
    
    [self initData:apps];
    [self initScrollview:_arrData];
}

/** 数据解析 */
- (void)initData:(NSArray *)apps
{
    [_arrData removeAllObjects];
    if (apps.count) {
        for (int i = 0; i < [apps count]; i++) {
            NSDictionary *diction = [apps objectAtIndex:i];
            UCHotAppModel *mHotApp = [[UCHotAppModel alloc] initWithJson:diction];
            [_arrData addObject:mHotApp];
        }
    }
}

/** 请求数据 */
- (void)getAppData
{
    // 缓存配置
    NSDictionary *dicCache = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:kAppsCachePath]) {
        dicCache = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:kAppsCachePath] options:NSJSONReadingMutableContainers error:nil];
    }
    
    if (dicCache) {
        NSArray *apps = nil;
        NSString *cacheVersion = [dicCache objectForKey:@"version"];
        if (cacheVersion.floatValue > _localVersion.floatValue) {
            _localVersion = cacheVersion;
            apps = [dicCache objectForKey:@"array"];
        }
        [self initData:apps];
        [self initScrollview:_arrData];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://apps.api.che168.com/phone/v40/RemApps/apps_ios.ashx"]] returningResponse:nil error:nil];
        if (data) {
            NSDictionary *dicApp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            // 网络数据
            if (dicApp) {
                // 获取数据版本号
                NSString *netVersion = [dicApp objectForKey:@"version"];
                
                // 替换缓存
                if(netVersion.floatValue > _localVersion.floatValue) {
                    [data writeToFile:kAppsCachePath atomically:YES];
                    // 解析数据
                    NSArray *app = [dicApp objectForKey:@"array"];
                    [self initData:app];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 刷新视图
                        [self initScrollview:_arrData];
                    });
                }
            }
        }
    });
}

/** 手势操作 */
- (void)taps:(UITapGestureRecognizer *)tap
{
    UCHotAppModel *mHotApps = _arrData[tap.view.tag - viewTagBase];
    [UMStatistics event:c_3_2_hot_apps label:[mHotApps name]];
    
    if (mHotApps.url.length > 0) {
        NSRange rangeStart = [mHotApps.url rangeOfString:@"/id"];
        NSRange rangeEnd = [mHotApps.url rangeOfString:@"?mt"];
        NSInteger indexStart = rangeStart.location + rangeStart.length;
        NSInteger strLen = rangeEnd.location - indexStart;
        if (indexStart > 0 && strLen > 0 && mHotApps.url.length > indexStart + strLen) {
            NSString *appid = [mHotApps.url substringWithRange:NSMakeRange(indexStart, strLen)];
            [[MainViewController sharedVCMain] showAppStore:appid type:0];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[mHotApps url]]];
        }
    }
}

#pragma  mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollViews
{
    CGPoint offsetofScrollView = scrollViews.contentOffset;
    [_pcPhoto setCurrentPage:(NSInteger)(offsetofScrollView.x / scrollViews.frame.size.width)];
}

@end

