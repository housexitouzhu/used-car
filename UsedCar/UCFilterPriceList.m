//
//  UCHomePriceList.m
//  UsedCar
//
//  Created by Sun Honglin on 14-8-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCFilterPriceList.h"
#import "HomeOptListCell.h"
#import "UCFilterModel.h"

@interface UCFilterPriceList ()
{
    
}

@property (nonatomic, strong) UCFilterModel *mFiler;
@property (nonatomic, strong) NSArray *priceValues;
@property (nonatomic, strong) UITableView *tvPrice;
@property (retain, nonatomic) NSString *currentValue;
@property (assign, nonatomic) BOOL matchHit;
@end

@implementation UCFilterPriceList

- (id)initWithFrame:(CGRect)frame filter:(UCFilterModel *)mFilter
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.mFiler = [mFilter copy];
        self.matchHit = NO;
        [self initView];
        
        if (self.mFiler.priceregion == nil) {
            [self.tvPrice selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
        else{
            [self setSelectedCellWithValue:self.mFiler.priceregion];
        }
    }
    return self;
}

- (void)initView
{
    self.backgroundColor = kColorWhite;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"FilterValues" ofType:@"plist"];
    NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
    self.priceValues = values[@"Prices"];
    
    _tvPrice = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _tvPrice.delegate = self;
    _tvPrice.dataSource = self;
    _tvPrice.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self addSubview:_tvPrice];
    
}

- (void)setSelectedCellWithValue:(NSString*)value{
    
    self.currentValue = value;
    
    __weak typeof(self) weakSelf = self;
    [self.priceValues enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *cmpValue = [obj objectForKey:@"Value"];
        if ([cmpValue isEqualToString:value]){
            weakSelf.matchHit = YES;
            [weakSelf.tvPrice selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
        else{
            
        }
        // 循环停止，无命中项
        if (stop && weakSelf.matchHit == NO) {
            
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.priceValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *Identifier = @"Cell";
    HomeOptListCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell)
        cell = [[HomeOptListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier cellWidth:tableView.width];
    
    if (indexPath.row == 0) {
        cell.labTitle.text = @"价格不限";
    }
    else if (indexPath.row == 1){
        cell.labTitle.text = @"3万以下";
    }
    else{
        cell.labTitle.text = [[self.priceValues objectAtIndex:indexPath.row] objectForKey:@"Name"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
{
	return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *priceregion = [[self.priceValues objectAtIndex:indexPath.row] objectForKey:@"Value"];
    NSString *priceregionText = [[self.priceValues objectAtIndex:indexPath.row] objectForKey:@"Name"];
    
    if ([self.currentValue isEqualToString:priceregion]) {
        if ([self.delegate respondsToSelector:@selector(UCFilterPriceList:didSelectedWithName:value:isChanged:)]) {
            [self.delegate UCFilterPriceList:self didSelectedWithName:priceregionText value:priceregion isChanged:NO];
        }
    }
    else{
        if ([self.delegate respondsToSelector:@selector(UCFilterPriceList:didSelectedWithName:value:isChanged:)]) {
            [self.delegate UCFilterPriceList:self didSelectedWithName:priceregionText value:priceregion isChanged:YES];
        }
    }
    
}



- (void)dealloc
{
    AMLog(@"dealloc...");
}

@end
