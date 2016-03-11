//
//  HotBrandLogoButton.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-10.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "HotBrandLogoButton.h"
#import "UIImageView+WebCache.h"

@implementation HotBrandLogoButton

// 50, 60
- (id)initWithFrame:(CGRect)frame itemInfo:(NSDictionary *)itemDict
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSString *name = [itemDict objectForKey:@"name"];
        NSString *logoURLstr = [itemDict objectForKey:@"logourl"];
        //http://www.autoimg.cn/logo/brand/100/129743627900268975.jpg
        NSRange range = [logoURLstr rangeOfString:@"www"];
        if (range.length != 0) {
            NSString *substr = [logoURLstr substringFromIndex:(range.location+3)];
            logoURLstr = [NSString stringWithFormat:@"http://img%@",substr];
        }
        
        
        NSURL *logoURL = [NSURL URLWithString:logoURLstr];
        
        _logoView = [[UIImageView alloc] initWithFrame:CGRectMake(13.5, 15, 35, 35)];
        [_logoView setBackgroundColor: [UIColor clearColor]];
        [_logoView sd_setImageWithURL:logoURL placeholderImage:[UIImage imageNamed:@"screen_picture"]];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_logoView.frame)+5, 52, 14)];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        [_nameLabel setText:name];
        [_nameLabel setTextColor:kColorNewGray1];
        [_nameLabel setFont:kFontNormal];
        
        [self addSubview:_logoView];
        [self addSubview:_nameLabel];
    }
    return self;
}

@end
