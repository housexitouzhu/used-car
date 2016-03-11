//
//  UCHomeOrderList.m
//  UsedCar
//
//  Created by Sun Honglin on 14-8-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCFilterOrderList.h"
#import "AppDelegate.h"
#import "HomeOptListCell.h"

@interface UCFilterOrderList ()
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *orderValues;
@property (nonatomic, strong) UITableView *tvOrder;
@property (nonatomic, assign) BOOL shouldSelect;
@property (nonatomic, strong) NSString *orderIDTemp;

@end

@implementation UCFilterOrderList

- (id)initWithFrame:(CGRect)frame orderID:(NSString *)orderID
{
    self = [super initWithFrame:frame];
    if (self) {
        _orderIDTemp = [NSString stringWithFormat:@"%@",orderID];
        // Initialization code
        [self initView];
        [self setSelectedCellWithValue:_orderIDTemp];
    }
    return self;
}

- (void)initView
{
    self.backgroundColor = kColorWhite;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"FilterValues" ofType:@"plist"];
    NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
    self.orderValues = values[@"Order"];
    
    _tvOrder = [[UITableView alloc] initWithClearFrame:CGRectMake(0, 0, self.width, self.height)];
    _tvOrder.scrollEnabled = YES;
    _tvOrder.backgroundColor = kColorWhite;
    _tvOrder.delegate = self;
    _tvOrder.dataSource = self;
    
    _tvOrder.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self addSubview:_tvOrder];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.orderValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *Identifier = @"Cell";
    
    HomeOptListCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell)
        cell = [[HomeOptListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier cellWidth:tableView.width];
    cell.labTitle.text = [[self.orderValues objectAtIndex:indexPath.row] objectForKey:@"Name"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
{
	return 50.0;
}

/** 选择历史记录 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *name = [[self.orderValues objectAtIndex:indexPath.row] objectForKey:@"Name"];
    NSString *order = [[self.orderValues objectAtIndex:indexPath.row] objectForKey:@"Value"];
    
    if (_orderIDTemp.integerValue == order.integerValue) {
        if ([self.delegate respondsToSelector:@selector(UCFilterOrderList:didSelectedWithName:value:isChanged:)]) {
            [self.delegate UCFilterOrderList:self didSelectedWithName:name value:order isChanged:NO];
        }
    }
    else{
        if ([self.delegate respondsToSelector:@selector(UCFilterOrderList:didSelectedWithName:value:isChanged:)]) {
            [self.delegate UCFilterOrderList:self didSelectedWithName:name value:order isChanged:YES];
        }
    }
    
}

/** 设置选中 */
- (void)setSelectedCellWithValue:(NSString *)value{
    
    __weak typeof(self) weakSelf = self;
    [self.orderValues enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSInteger cmpValue = [[obj objectForKey:@"Value"] integerValue];
        if (cmpValue == value.integerValue){
            [weakSelf.tvOrder selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
        
        if (stop && (value==nil || value == 0)) {
            [weakSelf.tvOrder selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
        
    }];
    
}

@end




