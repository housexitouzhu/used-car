//
//  ChatCellText.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-25.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "BaseChatCell.h"

@interface TextChatCell : BaseChatCell

@property (nonatomic, strong) BubbleButtonText *btnText;

+ (CGFloat)heightOfTextCell:(NSString*)message;

@end
