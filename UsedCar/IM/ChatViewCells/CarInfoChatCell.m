//
//  CarInfoChatCell.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-25.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "CarInfoChatCell.h"
#import "BubbleButtonCar.h"
#import "CarMessageBody.h"
#import "UIImageView+WebCacheAnimation.h"

@implementation CarInfoChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        _btnCar = [[BubbleButtonCar alloc] initWithCustomButtonWithType:BubbleTypeNone];
        [_btnCar addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnCar];
        
        [self.btnResend addTarget:self action:@selector(onclickResendButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setChatCellWithMessage:(StorageMessage *)message{
    [super setChatCellWithMessage:message];
    
    CarMessageBody *mbCar = (CarMessageBody *)message.mesBody;
    
    if (message.isOutgoing == 0) {
        [_btnCar setBubbleType: BubbleTypeLeft];
        [_btnCar setFrame:CGRectMake(kCellHGap, kCellVGap, kBubbleCarWidth, kBubbleCarHeight)];
        
        [self.btnResend setFrame:CGRectMake(_btnCar.maxX+5, (kCellCarHeight-40)/2, 40, 40)];
        self.btnResend.hidden = YES;
    }
    else{
        [_btnCar setBubbleType:BubbleTypeRight];
        [_btnCar setFrame:CGRectMake(SCREEN_WIDTH - kBubbleCarWidth - kCellHGap, kCellVGap, kBubbleCarWidth, kBubbleCarHeight)];
        
        [self.btnResend setFrame:CGRectMake(_btnCar.minX - 5 - 40, (kCellCarHeight-40)/2, 40, 40)];
        
        if (message.status == IMMessageStatusFailure) {
            self.btnResend.hidden = NO;
        }
        else{
            self.btnResend.hidden = YES;
        }
    }
    
    [_btnCar.labCarName setText: mbCar.carname];
    [_btnCar.imageViewCar sd_setImageWithURL:[NSURL URLWithString:mbCar.carimage]
                            placeholderImage:[UIImage imageNamed:@"home_default"]
                                     animate:YES];
    [_btnCar.labPrice setText:[NSString stringWithFormat:@"价格：%@万",mbCar.carprice]];
    [_btnCar.labRegDate setText:[NSString stringWithFormat:@"上牌：%@",mbCar.registrationdate]];
    [_btnCar.labMileage setText:[NSString stringWithFormat:@"里程：%@万公里",mbCar.mileage]];
    
}

- (void)onClickButton:(id)sender{
    if ([self.delegate respondsToSelector:@selector(ChatCell:buttonClickedWithMessage:)]) {
        [self.delegate ChatCell:self buttonClickedWithMessage:self.message];
    }
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
