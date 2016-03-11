//
//  ChatCellText.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-25.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "TextChatCell.h"
#import "BubbleButtonText.h"
#import "TextMessageBody.h"

@implementation TextChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        
        _btnText = [[BubbleButtonText alloc] initWithCustomButtonWithType:BubbleTypeNone];
        [self.contentView addSubview:_btnText];
        
        [self.btnResend addTarget:self action:@selector(onclickResendButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setChatCellWithMessage:(StorageMessage *)message{
    [super setChatCellWithMessage:message];
    
    TextMessageBody *tmBody = (TextMessageBody *)message.mesBody;
    CGSize bubbleSize = [self sizeOfTextButton:tmBody.message];
    
    if (message.isOutgoing == 0) {
        [_btnText setBubbleType: BubbleTypeLeft];
        [_btnText setFrame:CGRectMake(kCellHGap, kCellVGap, bubbleSize.width, bubbleSize.height)];
        
        [self.btnResend setFrame:CGRectMake(_btnText.maxX+5, (_btnText.height-40)/2+kCellVGap, 40, 40)];
        self.btnResend.hidden = YES;
    }
    else{
        [_btnText setBubbleType:BubbleTypeRight];
        [_btnText setFrame:CGRectMake(SCREEN_WIDTH - bubbleSize.width - kCellHGap, kCellVGap, bubbleSize.width, bubbleSize.height)];
        
        [self.btnResend setFrame:CGRectMake(_btnText.minX - 5 - 40, (_btnText.height-40)/2+kCellVGap, 40, 40)];
        
        if (message.status == IMMessageStatusFailure) {
            self.btnResend.hidden = NO;
        }
        else{
            self.btnResend.hidden = YES;
        }
//        if(message.status == IMMessageStatusSending){
//            self.btnResend.hidden = YES;
//        }
//        else if (message.status == IMMessageStatusFailure) {
//            self.btnResend.hidden = NO;
//        }
//        else{
//            self.btnResend.hidden = YES;
//        }
    }
    [_btnText setTitle:tmBody.message];
}

- (CGSize)sizeOfTextButton:(NSString*)message{
    CGSize size = [message sizeWithFont:kFontLarge
                      constrainedToSize:CGSizeMake(kBubbleWidth_MAX - kBubbleTailGap - kBubbleHeadGap, kBubbleHeight_MAX)
                          lineBreakMode:NSLineBreakByCharWrapping];
    
    size.width += (kBubbleTailGap + kBubbleHeadGap);
    
    if(size.height > kFontLarge.pointSize*2){
        size.height += kBubbleVGap * 2;
    }
    else{
        size.height = kBubbleHeight_MIN;
    }
    
    return size;
}

+ (CGFloat)heightOfTextCell:(NSString*)message{
    CGSize size = [message sizeWithFont:kFontLarge
                      constrainedToSize:CGSizeMake(kBubbleWidth_MAX - kBubbleTailGap - kBubbleHeadGap, kBubbleHeight_MAX)
                          lineBreakMode:NSLineBreakByCharWrapping];
    if(size.height > kFontLarge.pointSize*2){
        size.height += kBubbleVGap * 2;
    }
    else{
        size.height = kBubbleHeight_MIN;
    }
    
    if (size.height + kCellVGap*2 < kCellDefaultHeight) {
        size.height = kCellDefaultHeight;
    }
    else{
        size.height += kCellVGap*2;
    }
    return size.height;
}

- (void)onclickResendButton:(id)sender{
    self.btnResend.hidden = YES;
    
    if (self.message.isOutgoing != 0) {
        self.message.status = IMMessageStatusSending;
        if ([self.resendDelegate respondsToSelector:@selector(ChatCell:resendButtonClickedWithMessage:contact:)]) {
            [self.resendDelegate ChatCell:self resendButtonClickedWithMessage:self.message contact:self.contact];
        }
    }
}

@end
