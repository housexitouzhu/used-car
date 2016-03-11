//
//  ImageChatCell.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-25.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "ImageChatCell.h"
#import "ImageMessageBody.h"
#import "UIImageView+WebCacheAnimation.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageChatCell ()

@property (nonatomic) NSInteger requestTag;
@property (nonatomic, strong) ALAssetsLibrary *libAssets;

@end

@implementation ImageChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        _btnImage = [[BubbleButtonImage alloc] initWithCustomButtonWithType:BubbleTypeNone];
        [_btnImage setFrame:CGRectMake(kCellHGap,kCellVGap,kBubbleImageWidth, kBubbleImageHeight)];
        [_btnImage addTarget:self action:@selector(onClickImageButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnImage];
        
        [self.btnResend addTarget:self action:@selector(onclickResendButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setChatCellWithMessage:(StorageMessage *)message contact:(StorageContact *)contact{
    [super setChatCellWithMessage:message contact:contact];
    
    [_btnImage addTarget:self action:@selector(onClickImageButton:) forControlEvents:UIControlEventTouchUpInside];
    
    ImageMessageBody *mbCar = (ImageMessageBody *)message.mesBody;
    
    if (message.isOutgoing == 0) {
        self.btnResend.hidden = YES;
        [_btnImage setFrame:CGRectMake(kCellHGap,kCellVGap,kBubbleImageWidth, kBubbleImageHeight)];
        [self.btnResend setFrame:CGRectMake(_btnImage.maxX+5, (kCellImageHeight-37)/2, 40, 40)];
        [_btnImage setBubbleType: BubbleTypeLeft];
        
        
        self.btnResend.hidden = YES;
        [_btnImage.vCarImage sd_setImageWithURL:[NSURL URLWithString:mbCar.smallUri]
                               placeholderImage:[UIImage imageNamed:@"home_default"]
                                        animate:YES];
        
    }
    else{
        [_btnImage setFrame:CGRectMake(SCREEN_WIDTH - kBubbleImageWidth - kCellHGap, kCellVGap, kBubbleImageWidth, kBubbleImageHeight)];
        [self.btnResend setFrame:CGRectMake(_btnImage.minX - 5 - 40, (kCellImageHeight-37)/2, 40, 40)];
        
        [_btnImage setBubbleType:BubbleTypeRight];
        
        //设置图片和其他按钮的显隐
        if (message.originalImage) {
            [_btnImage.vCarImage setImage:message.originalImage];
            
            if (message.status == IMMessageStatusSending) {
                _btnImage.vProgress.hidden = NO;
                self.btnResend.hidden = YES;
            }
            else if(message.status == IMMessageStatusFailure){
                _btnImage.vProgress.hidden = YES;
                self.btnResend.hidden = NO;
            }
            else{
                _btnImage.vProgress.hidden = YES;
                self.btnResend.hidden = YES;
            }
        }
        else{
            
            if (message.status == IMMessageStatusSending) {
                _btnImage.vProgress.hidden = NO;
                self.btnResend.hidden = YES;
            }
            else if (message.status == IMMessageStatusFailure) {
                self.btnResend.hidden = NO;
                
                ImageMessageBody *imb = (ImageMessageBody *)message.mesBody;
                
                if ([imb.uri hasPrefix:@"http"]) {
                    [_btnImage.vCarImage sd_setImageWithURL:[NSURL URLWithString:mbCar.smallUri]
                                           placeholderImage:[UIImage imageNamed:@"home_default"]
                                                    animate:YES];
                }
                else{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        if (!_libAssets) {
                            _libAssets = [[ALAssetsLibrary alloc] init];
                        }
                        
                        [_libAssets assetForURL:[NSURL URLWithString:imb.uri] resultBlock:^(ALAsset *asset) {
                            ALAssetRepresentation *imgRepresentation =[asset defaultRepresentation];
                            UIImage *img = [UIImage imageWithCGImage:[imgRepresentation fullScreenImage]
                                                               scale:[UIScreen mainScreen].scale
                                                         orientation:UIImageOrientationUp];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.btnImage.vCarImage setImage:img];
                                self.message.originalImage = img;
                            });
                            
                        } failureBlock:^(NSError *error) {
                            AMLog(@"_libAssets error: %@", error.description);
                        }];
                    });
                }
            }
            else{
                self.btnResend.hidden = YES;
                [_btnImage.vCarImage sd_setImageWithURL:[NSURL URLWithString:mbCar.smallUri]
                                       placeholderImage:[UIImage imageNamed:@"home_default"]
                                                animate:YES];
            }
        }
    }
}


- (void)onClickImageButton:(id)sender{
    if ([self.delegate respondsToSelector:@selector(ChatCell:buttonClickedWithMessage:)]) {
        [self.delegate ChatCell:self buttonClickedWithMessage:self.message];
    }
}

- (void)onclickResendButton:(id)sender{
    self.btnResend.hidden = YES;
    
    if (self.message.isOutgoing == 0) {
        ImageMessageBody *mbCar = (ImageMessageBody *)self.message.mesBody;
        [_btnImage.vCarImage sd_setImageWithURL:[NSURL URLWithString:mbCar.smallUri]
                               placeholderImage:[UIImage imageNamed:@"home_default"]
                                        animate:YES
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          if (error) {
                                              self.btnResend.hidden = NO;
                                          }
                                          else{
                                              self.btnResend.hidden = YES;
                                          }
                                      }];
    }
    else{
        self.message.status = IMMessageStatusSending;
        if ([self.resendDelegate respondsToSelector:@selector(ChatCell:resendButtonClickedWithMessage:contact:)]) {
            [self.resendDelegate ChatCell:self resendButtonClickedWithMessage:self.message contact:self.contact];
        }
    }
}

- (void)updateImageProgress:(float)progress{
    [_btnImage.vProgress setProgress:progress];
}




@end
