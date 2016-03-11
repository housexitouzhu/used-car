//
//  UCCarPhotoEditView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-6.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"

@protocol UCCarPhotoEditViewDelegate;

@interface UCCarPhotoEditView : UCView

@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, weak) id<UCCarPhotoEditViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame photoArray:(NSArray*)array;

@end


@protocol UCCarPhotoEditViewDelegate <NSObject>

- (void)UCCarPhotoEditView:(UCCarPhotoEditView*)CarPhotoEditView didFinishEditingPhotos:(NSArray*)edittedPhotoArray;
- (void)UCCarPhotoEditView:(UCCarPhotoEditView*)CarPhotoEditView cancelledWithOrignalArray:(NSArray*)orignalArray;

@end

#pragma mark - 本页使用的横滚 scrollview

@interface EditScrollView : UIScrollView

@property (nonatomic, assign) BOOL isDrawing;

@end