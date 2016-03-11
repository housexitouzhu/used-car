//
//  UCSearchResultHeaderView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSearchResultHeaderView.h"
#import "NSString+Util.h"

@interface UCSearchResultHeaderView ()

@property (retain, nonatomic) UIImageView *iconView;

@end

@implementation UCSearchResultHeaderView

- (id)initWithFrame:(CGRect)frame
{
    frame.size.height = 20;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = kColorNewLine;
        
        UIImage *icon = [UIImage imageNamed:@"searchIcon_gray"];
        self.iconView = [[UIImageView alloc] initWithImage:icon];
        [self.iconView setFrame:CGRectMake(10, 0, 20, 20)];
        [self.iconView setContentMode:UIViewContentModeCenter];
        [self addSubview:self.iconView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconView.maxX+5, 2.5, 180, 15)];
        [self.titleLabel setTextColor:kColorNewGray2];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.titleLabel setFont:kFontTiny];
        [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self addSubview:self.titleLabel];
        
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.maxX, 2.5, 90, 15)];
        [self.countLabel setTextColor:kColorNewGray2];
        [self.countLabel setBackgroundColor:[UIColor clearColor]];
        [self.countLabel setFont:kFontTiny];
        [self.countLabel setTextAlignment:NSTextAlignmentRight];
        [self.countLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self addSubview:self.countLabel];
        
        UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, self.height - kLinePixel, self.width, kLinePixel) color:kColorNewLine];
        [self addSubview:vLine];
    }
    return self;
}

- (void)setTitleStr:(NSString *)titleStr{
    _titleStr = titleStr;
    [self.titleLabel setText:_titleStr];
    [self.titleLabel sizeToFit];
    CGFloat xPoint = self.iconView.maxX+5;
    CGFloat yPoint = (self.height - self.titleLabel.height)/2;
    [self.titleLabel setOrigin:CGPointMake(xPoint, yPoint)];
}

- (void)setResultCount:(NSInteger)resultCount{
    _resultCount = resultCount;
    NSString *countStr = [NSString stringWithFormat:@"共%d条",_resultCount];
    [self.countLabel setText:countStr];
    [self.countLabel sizeToFit];
    CGFloat xPoint = self.width - 10 - self.countLabel.width;
    CGFloat yPoint = (self.height - self.countLabel.height)/2;
    [self.countLabel setOrigin:CGPointMake(xPoint, yPoint)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
