//
//  ChatCell.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "BaseChatCell.h"

@implementation BaseChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kColorClear;
        _btnResend = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnResend setImage:[UIImage imageNamed:@"consultation_sendfailed"] forState:UIControlStateNormal];
        [_btnResend setFrame:CGRectMake(0, 0, 27, 27)];
        [_btnResend setHidden:YES];
        [self.contentView addSubview:_btnResend];
    }
    return self;
}

- (void)setChatCellWithMessage:(StorageMessage *)message{
    _message = message;
    
}

- (void)setChatCellWithMessage:(StorageMessage *)message contact:(StorageContact *)contact{
    [self setChatCellWithMessage:message];
    _contact = contact;
}

//- (void)setChatCellWithMessage:(StorageMessage *)message contact:(StorageContact *)contact uploader:(XMPPMessageUploader *)uploader{
//    [self setChatCellWithMessage:message contact:contact];
//    _uploader = uploader;
//}

//- (void)setHighlighted:(BOOL)highlighted{
//    [super setHighlighted:highlighted];
//    for (UIView *view in self.contentView.subviews) {
//        if ([view isKindOfClass:[UIButton class]]) {
//            UIButton *btn = (UIButton *)view;
//            [btn setHighlighted:NO];
//        }
//    }
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//    // Configure the view for the selected state
//    
//    for (UIView *view in self.contentView.subviews) {
//        if ([view isKindOfClass:[UIButton class]]) {
//            UIButton *btn = (UIButton *)view;
//            [btn setSelected:NO];
//        }
//    }
//}

@end
