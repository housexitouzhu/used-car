//
//  EmojiFaceView.h
//  IMDemo
//
//  Created by jun on 11/20/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFaceDelButtonTag (45763)

@protocol FaceViewDelegate <NSObject>

-(void)selectedFaceItem:(UIButton *)item;

@end



@interface EmojiFaceView : UIView

@property (nonatomic,weak) id<FaceViewDelegate> delegate;

-(void)loadFacialView:(int)page;

@end
