//
//  BubbleButton.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-25.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "BubbleButton.h"

@implementation BubbleButton

- (id)initWithCustomButtonWithType:(BubbleType)type{
    self = [super init];
    if (self) {
        _bubbleType = type;
        
    }
    return self;
}

- (UIImage *)bubbleLeft{
    UIImage *img = [[UIImage imageNamed:@"consultation_you_bubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(21, 19, 9, 10)];
    return img;
}

- (UIImage *)bubbleLeftPress{
    UIImage *img = [[UIImage imageNamed:@"consultation_you_bubble_pre"] resizableImageWithCapInsets:UIEdgeInsetsMake(21, 19, 9, 10)];
    return img;
}

- (UIImage *)bubbleRight{
    UIImage *img = [[UIImage imageNamed:@"consultation_i_bubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 19, 19)];
    return img;
}

- (UIImage *)bubbleRightPress{
    UIImage *img = [[UIImage imageNamed:@"consultation_i_bubble_pre"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 19, 19)];
    return img;
}

- (UIImage *)bubbleInfoLeft{
    UIImage *img = [[UIImage imageNamed:@"consultation_you_linkbubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(21, 19, 9, 10)];
    return img;
}

- (UIImage *)bubbleInfoLeftPress{
    UIImage *img = [[UIImage imageNamed:@"consultation_you_linkbubble_pre"] resizableImageWithCapInsets:UIEdgeInsetsMake(21, 19, 9, 10)];
    return img;
}

- (UIImage *)bubbleInfoRight{
    UIImage *img = [[UIImage imageNamed:@"consultation_i_linkbubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 19, 19)];
    return img;
}

- (UIImage *)bubbleInfoRightPress{
    UIImage *img = [[UIImage imageNamed:@"consultation_i_linkbubble_pre"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 19, 19)];
    return img;
}

- (UIImage *)bubbleImageLeft{
    UIImage *img = [UIImage imageNamed:@"consultation_you_picture"];
    return img;
}

- (UIImage *)bubbleImageRight{
    UIImage *img = [UIImage imageNamed:@"consultation_i_picture"];
    return img;
}




@end
