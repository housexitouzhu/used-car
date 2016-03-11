//
//  SHLDrawView.m
//
//  Created by Sun Honglin on 14-11-6.
//  Copyright (c) 2014年 Pavan Itagi. All rights reserved.
//

#import "SHLDrawView.h"

@implementation SHLDrawView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        self.drawCanvas = [[SHLDrawCanvas alloc] initWithFrame:self.bounds];

        [self addSubview:self.imageView];
        [self addSubview:self.drawCanvas];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image andWidth:(CGFloat)width{
    
    self = [super init];
    if (self) {
        
        _image = image;
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;
        CGFloat height = ceil(width*imageHeight/imageWidth); //解决高度是 float 时, 画的图会随着向上滚动.
        
        self.frame = CGRectMake(0, 0, width, height);
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        self.imageView.image = _image;
        [self addSubview:self.imageView];
        
        self.drawCanvas = [[SHLDrawCanvas alloc] initWithFrame:self.bounds];
        [self addSubview:self.drawCanvas];
        
    }
    return self;
}

- (void)setImage:(UIImage *)image{
    _image = image;
    [self.imageView setImage:_image];
}


#pragma mark - touch event
//pass all touch event to draw canvas
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.drawCanvas touchesBegan:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.drawCanvas touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.drawCanvas touchesEnded:touches withEvent:event];
}

@end
