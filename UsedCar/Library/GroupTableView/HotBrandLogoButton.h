//
//  HotBrandLogoButton.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-10.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotBrandLogoButton : UIButton

@property (strong, nonatomic) UIImageView *logoView;
@property (strong, nonatomic) UILabel     *nameLabel;

- (id)initWithFrame:(CGRect)frame itemInfo:(NSDictionary *)itemDict;

@end
