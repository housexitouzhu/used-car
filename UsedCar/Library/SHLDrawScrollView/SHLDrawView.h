//
//  SHLDrawView.h
//
//  Created by Sun Honglin on 14-11-6.
//  Copyright (c) 2014年 Pavan Itagi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHLDrawCanvas.h"


@interface SHLDrawView : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) SHLDrawCanvas *drawCanvas;

- (id)initWithImage:(UIImage *)image andWidth:(CGFloat)width;

@end
