//
//  EmojiFaceView.m
//  IMDemo
//
//  Created by jun on 11/20/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "EmojiFaceView.h"

#define kFaceButtonWidth (40)
#define kFaceButtonHeight (40)

#define kTopMargin (20)
#define kLeftMargin (20)

@implementation EmojiFaceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)loadFacialView:(int)page
{
    //row number  3行
	for (int i=0; i<3; i++) {
		//column numer 7列
		for (int y=0; y<7; y++) {
			UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            
            [button setFrame:CGRectMake(kLeftMargin+y*kFaceButtonWidth,kTopMargin+i*kFaceButtonHeight, kFaceButtonWidth, kFaceButtonHeight)];
            
            if (i == 2 && y == 6) {
                [button setImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateNormal];
                button.tag = kFaceDelButtonTag;
            }else{
                // 每页都是20个，最后一个是删除按钮
                int faceIndex = i*7+y+(page*20);
                NSString *faceName = [NSString stringWithFormat:@"emoji_%02d",faceIndex];
                
                [button setImage:[UIImage imageNamed:faceName] forState:UIControlStateNormal];
                button.tag=i*7+y+(page*20);
            }
            
			[button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:button];
		}
	}
}

- (void)selected:(UIButton *)sender
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedFaceItem:)])
    {
        [self.delegate selectedFaceItem:sender];
    }
}

@end
