//
//  SHLDrawCanvas.h
//
//  Created by Sun Honglin on 14-11-5.
//  Copyright (c) 2014年 Pavan Itagi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SHLDrawModeNone = 0,
    SHLDrawModePaint,
    SHLDrawModeErase,
} SHLDrawMode;

@protocol SHLDrawCanvasDelegate;

@interface SHLDrawCanvas : UIView

@property (nonatomic, assign) BOOL imageDrawed;
@property (nonatomic, assign) SHLDrawMode drawMode;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIImage *drawImage;
@property (nonatomic, weak) id<SHLDrawCanvasDelegate> delegate;

- (void)removeImageDrawed;

@end

@protocol SHLDrawCanvasDelegate <NSObject>

@optional
- (void)imageDrawedOnCanvas:(SHLDrawCanvas*)canvas;

@end