//
//  InputPhrasePanel.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "InputPhrasePanel.h"

@interface InputPhrasePanel () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_vTable;
}
@end

@implementation InputPhrasePanel


- (id)initWithFrame:(CGRect)frame listArray:(NSArray*)array{
    if ([self initWithFrame:frame]) {
        _arrPhrase = array;
        [_vTable reloadData];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView{
    self.backgroundColor = kColorClear;
    
    _vTable = [[UITableView alloc] initWithFrame:self.bounds];
    _vTable.backgroundColor = kColorNewGray3;
    _vTable.delegate = self;
    _vTable.dataSource = self;
    [_vTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:_vTable];
}

#pragma mark - UITableView Delegate & Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    [cell setBackgroundColor:kColorClear];
    UIView *selbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 46)];
    selbg.backgroundColor = kColorNewLine;
    [cell setSelectedBackgroundView:selbg];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.width-15, 45)];
    label.backgroundColor = kColorClear;
    label.font = kFontLarge;
    label.textColor = kColorNewGray1;
    [label setText:[_arrPhrase objectAtIndex:indexPath.row]];
    [cell.contentView addSubview:label];
    
    UIView *hLine = [[UIView alloc] initLineWithFrame:CGRectMake(15, 46-kLinePixel, self.width - 15, kLinePixel) color:kColorNewLine];
    [cell.contentView addSubview:hLine];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(InputPhrasePanel:didSelectPhrase:)]) {
        [self.delegate InputPhrasePanel:self didSelectPhrase:[_arrPhrase objectAtIndex:indexPath.row]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrPhrase.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 46;
}



@end
