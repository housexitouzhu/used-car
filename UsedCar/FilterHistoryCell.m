//
//  FilterHistoryCell.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "FilterHistoryCell.h"

@implementation FilterHistoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellHeight:(CGFloat)cellHeight
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.width = self.contentView.width = cellHeight;
        
        self.recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.width - 15 * 2 - 50, 50)];
        [self.recordLabel setNumberOfLines:2];
        [self.recordLabel setFont:kFontSmall];
        [self.recordLabel setTextColor:kColorNewGray1];
        [self.recordLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.contentView addSubview:self.recordLabel];
        
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteButton setFrame:CGRectMake(self.maxX-50, 0, 50, 50)];
        [self.deleteButton setAdjustsImageWhenHighlighted:NO];
        [self.deleteButton setTitleColor:kColorBlue forState:UIControlStateNormal];
        [self.deleteButton.titleLabel setFont:kFontNormal];
        [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
         [self.deleteButton setBackgroundImage:[OMG imageWithColor:kColorNewBackground andSize:self.deleteButton.size] forState:UIControlStateNormal];
        [self.contentView addSubview:self.deleteButton];
        [self.contentView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 50 - kLinePixel, self.contentView.width, kLinePixel) color:kColorNewLine]];
    }
    return self;
}

-(void)deleteButtonClicked:(UIButton*)button{
    if ([self.delegate respondsToSelector:@selector(filterHistoryCellDeleteButtonClicked:atIndexPath:)]) {
        [self.delegate filterHistoryCellDeleteButtonClicked:button atIndexPath:self.indexPath];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setSelected:NO];
        }
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setHighlighted:NO];
        }
    }
}

@end
