//
//  UCHelpPromptView.h
//  UsedCar
//
//  Created by 张鑫 on 14-3-21.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kConfigIsShowNightPrompt @"kConfigIsShowNightPrompt"    // 是否显示过夜间提示

typedef enum {
    UCHelpPromptViewTagNightMode = 100,
} UCHelpPromptViewTag;

@interface UCHelpPromptView : UIView

- (id)initWithFrame:(CGRect)frame UCHelpPromptViewTag:(UCHelpPromptViewTag)viewTag;

@end
