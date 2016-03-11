//
//  UCAttentionHeader.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-21.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCAttentionDetailHeader : UIView

@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UILabel *countLabel;

@property (retain, nonatomic) NSString *titleStr;
@property (assign, nonatomic) NSInteger resultCount;

@end
