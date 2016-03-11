//
//  HotBrandCell.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-9.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "HotBrandCell.h"
#import "APIHelper.h"
#import "HotBrandLogoButton.h"
#import "SMPageControl.h"

@interface HotBrandCell ()
<UIScrollViewDelegate>
@property (retain, nonatomic) APIHelper *apiHelper;
@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) SMPageControl *pageControl;
@property (retain, nonatomic) NSArray *resultArray;

@end

@implementation HotBrandCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupLoadingButton];
        [self getHotBrands];
    }
    return self;
}


-(void)getHotBrands{
    
    if (!_apiHelper) {
        _apiHelper = [[APIHelper alloc] init];
    }
    
    __weak typeof(self) weakSelf = self;
    [_apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            AMLog(@"%@",error.domain);
            [weakSelf.loadingButton setTitle:@"加载失败，点击刷新" forState:UIControlStateNormal];
            [weakSelf.loadingButton addTarget:weakSelf action:@selector(loadingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            return;
        }
        
        if (apiHelper.data.length > 0) {
            
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    weakSelf.resultArray = [NSArray arrayWithArray:(NSArray*)mBase.result];
                    [weakSelf setupSubviewsWithResult];
                }
            }
        }
    }];
    
    [_apiHelper getHotBrands];
}

-(void)setupLoadingButton{
    CGRect loadingButtonframe = self.bounds;
    loadingButtonframe.size.height = 85;
    self.loadingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loadingButton setFrame:loadingButtonframe];
    [self.loadingButton setTitle:@"加载中..." forState:UIControlStateNormal];
    [self.loadingButton.titleLabel setFont:kFontLarge];
    [self.loadingButton setTitleColor:kColorNewGray2 forState:UIControlStateNormal];
    [self.contentView addSubview:self.loadingButton];
}

-(void)setupSubviewsWithResult{
    
    [self.loadingButton removeFromSuperview];
    
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self.scrollView setDelegate:self];
        [self.scrollView setBackgroundColor:[UIColor clearColor]];
        [self.scrollView setPagingEnabled:YES];
        [self.scrollView setScrollEnabled:YES];
        [self.scrollView setAlwaysBounceHorizontal:YES];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.scrollView setShowsVerticalScrollIndicator:NO];
    }
    
    for (int i = 0 ; i < self.resultArray.count; i++) {
        
        HotBrandLogoButton *logoButton = [[HotBrandLogoButton alloc] initWithFrame:CGRectMake(i*62, 0, 62, 85) itemInfo:[self.resultArray objectAtIndex:i]];
        logoButton.tag = i;
        [logoButton addTarget:self action:@selector(logoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:logoButton];
    }
    [self.scrollView setContentSize:CGSizeMake(62*self.resultArray.count+10, 85)];
    
    if (!self.pageControl) {
        self.pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0, 70, self.frame.size.width, 15)];
    }
    [self.pageControl setPageIndicatorTintColor:kColorNewGray2];
    [self.pageControl setCurrentPageIndicatorTintColor:kColorBlue];
    [self.pageControl setNumberOfPages:ceil(self.resultArray.count/5)];
    [self.pageControl setUserInteractionEnabled:NO];
    [self.pageControl setCurrentPage:0];
    
    [self.contentView addSubview:self.scrollView];
    [self.contentView addSubview:self.pageControl];
    
}

#pragma mark - button click action
-(void)logoButtonClicked:(UIButton*)button{
    
    if ([self.delegate respondsToSelector:@selector(hotBrandCellDidClickAtBrand:andFirstLetter:)]) {
        NSInteger i = button.tag;
        NSDictionary *dict = [self.resultArray objectAtIndex:i];
        NSString *brandid = [dict objectForKey:@"id"];
        NSString *firstLetter = [dict objectForKey:@"fl"];
        [self.delegate hotBrandCellDidClickAtBrand:brandid andFirstLetter:firstLetter];
    }
}

-(void)loadingButtonClicked:(id)sender{
    [self.loadingButton setTitle:@"加载中..." forState:UIControlStateNormal];
    [self getHotBrands];
}

#pragma mark - uiscrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    CGFloat pageWidth = self.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    self.pageControl.currentPage = page;
    
}

#pragma mark - highlighted selected
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
//    for (UIView *subview in self.subviews) {
//        if ([subview isKindOfClass:[UIButton class]]) {
//            UIButton *button = (UIButton*)subview;
//            [button setHighlighted:NO];
//        }
//    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    
//    for (UIButton *button in self.scrollView.subviews) {
//        [button setHighlighted:NO];
//    }
    
}



@end
