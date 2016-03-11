//
//  UCAttentionHeader.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-21.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCAttentionDetailHeader.h"

@implementation UCAttentionDetailHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 10, 180, 15)];
        [self.titleLabel setTextColor:kColorNewGray2];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.titleLabel setFont:kFontTiny];
        [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self addSubview:self.titleLabel];
        
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.maxX, 10, 90, 15)];
        [self.countLabel setTextColor:kColorNewGray2];
        [self.countLabel setBackgroundColor:[UIColor clearColor]];
        [self.countLabel setFont:kFontTiny];
        [self.countLabel setTextAlignment:NSTextAlignmentRight];
        [self.countLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self addSubview:self.countLabel];
        
        self.backgroundColor = kColorNewLine;
        UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, self.height - kLinePixel, self.width, kLinePixel) color:kColorNewLine];
        [self addSubview:vLine];
    }
    return self;
}

- (void)setTitleStr:(NSString *)titleStr{
    _titleStr = titleStr;
    [self.titleLabel setText:_titleStr];
    [self.titleLabel sizeToFit];
    CGFloat xPoint = 7;
    CGFloat yPoint = (self.height - self.titleLabel.height)/2;
    [self.titleLabel setOrigin:CGPointMake(xPoint, yPoint)];
}

- (void)setResultCount:(NSInteger)resultCount{
    _resultCount = resultCount;
    NSString *countStr = [NSString stringWithFormat:@"%d辆车",_resultCount];
    [self.countLabel setText:countStr];
    [self.countLabel sizeToFit];
    CGFloat xPoint = self.width - 14 - self.countLabel.width;
    CGFloat yPoint = (self.height - self.countLabel.height)/2;
    [self.countLabel setOrigin:CGPointMake(xPoint, yPoint)];
}

@end
