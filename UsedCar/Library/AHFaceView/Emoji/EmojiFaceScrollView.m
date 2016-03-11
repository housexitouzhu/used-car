//
//  EmojiFaceScrollView.m
//  IMDemo
//
//  Created by jun on 11/20/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "EmojiFaceScrollView.h"

#define kPage (6)

@interface EmojiFaceScrollView ()<FaceViewDelegate>

@end

@implementation EmojiFaceScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentSize = (CGSize){kPage*320,160};
        [self loadEmojiFaceViews];
    }
    return self;
}

- (void)loadEmojiFaceViews
{
    for (int i = 0; i < kPage; i++) {
        
        EmojiFaceView *emojiView = [[EmojiFaceView alloc] init];
        emojiView.frame = (CGRect){i*320,0,320,160};
        emojiView.delegate = self;
        [emojiView loadFacialView:i];
        [self addSubview:emojiView];
    }
}

#pragma mark -
-(void)selectedFaceItem:(UIButton *)item
{
    if (self.faceDelegate && [self.faceDelegate respondsToSelector:@selector(selectedFaceItem:)])
    {
        [self.faceDelegate selectedFaceItem:item];
    }
}

@end
