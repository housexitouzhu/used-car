//
//  ImageChatCell.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-25.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "BaseChatCell.h"
#import "BubbleButtonImage.h"



@interface ImageChatCell : BaseChatCell

@property (nonatomic, strong) BubbleButtonImage *btnImage;


- (void)updateImageProgress:(float)progress;


@end
