//
//  EmojiFaceScrollView.h
//  IMDemo
//
//  Created by jun on 11/20/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EmojiFaceView.h"

@interface EmojiFaceScrollView : UIScrollView

@property (nonatomic,weak) id<FaceViewDelegate> faceDelegate;

@end
