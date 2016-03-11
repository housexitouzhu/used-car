//
//  ChatInputBarView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputPhrasePanel.h"
#import "InputMorePanel.h"

#define InputBoxBarHeight 46
#define InputBoxPanelHeight 215


typedef enum : NSUInteger {
    InputBoxModePhrase   = 0, //如果需要改动这里, 需要改一下 AMCacheManage 里的setCurrentUserType对应的重置操作
    InputBoxModeKeyboard = 1,
    InputBoxModeVoice    = 2,
    InputBoxModeMore     = 3
} InputBoxMode;

@protocol ChatInputBarViewDelegate;

@interface ChatInputBarView : UIView

@property (nonatomic) BOOL isInEditing;
@property (nonatomic) InputBoxMode inputMode;
@property (nonatomic, weak) id<ChatInputBarViewDelegate> delegate;
//@property (nonatomic) id panelDelegate;
@property (nonatomic, strong) InputMorePanel *panelMore;

- (void)endEditting;

- (void)setInputBoxEnabled:(BOOL)enabled;

@end

@protocol ChatInputBarViewDelegate <NSObject>

- (void)ChatInputBarView:(ChatInputBarView*)inputBarView frameDidChanged:(CGRect)frame;

@optional
- (void)ChatInputBarView:(ChatInputBarView*)inputBarView sendText:(NSString*)textStr;
- (void)ChatInputBarView:(ChatInputBarView*)inputBarView didSelectPhrase:(NSString*)phrase;

@end