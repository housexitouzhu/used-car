//
//  UCSNHelper.m
//  UsedCar
//
//  Created by Sun Honglin on 14-10-23.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSNSHelper.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialData.h"
#import "WXApi.h"
#import "AMToastView.h"

@interface UCSNSHelper()<UMSocialUIDelegate>

@property (nonatomic, strong) NSDictionary *wxsessionContent;
@property (nonatomic, assign) SNSChannelType channelType;

@end

@implementation UCSNSHelper


- (void)openShareViewForAllPlatform:(BOOL)forAll{
    
    self.wxsessionContent = @{@"title":self.title,
                              @"shareText":self.contentWeChat
                              };
    
    // 设置分享标题
    [UMSocialData defaultData].extConfig.qzoneData.title = self.title;
    [UMSocialData defaultData].extConfig.qzoneData.url = self.shareURL;
    [UMSocialData defaultData].extConfig.renrenData.url = self.shareURL;
    [UMSocialData defaultData].extConfig.emailData.title = self.title;
    [UMSocialData defaultData].extConfig.wechatSessionData.title = [self.wxsessionContent objectForKey:@"title"];
    
    if (self.useTitleForWechatTimeLine) {
        [UMSocialData defaultData].extConfig.wechatTimelineData.title = [self.wxsessionContent objectForKey:@"title"];
    }
    
    
    if (self.imageURL.length > 0)
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:self.imageURL];
    else
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeDefault];
    
    // 分享到微信设置url
    [UMSocialWechatHandler setWXAppId:@"wx7ea3320364626402" appSecret:@"82a1f7a4f98d61c103a37d17fc0b298d" url:self.shareURL];
    
    NSMutableArray *names = [NSMutableArray array];
    if ([WXApi isWXAppInstalled]) {
        [names addObject:UMShareToWechatSession];
        [names addObject:UMShareToWechatTimeline];
    }
    [names addObject:UMShareToSina];
    [names addObject:UMShareToSms];
    
    if (forAll) {
        if ([QQApi isQQInstalled])
            [names addObject:UMShareToQzone];
        
        [names addObject:UMShareToTencent];
        [names addObject:UMShareToRenren];
        [names addObject:UMShareToEmail];
    }
    
    //如果得到分享完成回调，需要设置delegate为self
    if (self.imageURL.length > 0) {
        [UMSocialSnsService presentSnsIconSheetView:[MainViewController sharedVCMain] appKey:UM_APP_KEY shareText:self.content shareImage:nil shareToSnsNames:names delegate:self];
    }
    else if(self.imageShareIcon){
        [UMSocialSnsService presentSnsIconSheetView:[MainViewController sharedVCMain] appKey:UM_APP_KEY shareText:self.content shareImage:self.imageShareIcon shareToSnsNames:names delegate:self];
    }
    else{
        [UMSocialSnsService presentSnsIconSheetView:[MainViewController sharedVCMain] appKey:UM_APP_KEY shareText:self.content shareImage:nil shareToSnsNames:names delegate:self];
    }
}


// 分享完毕
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if (response.responseCode == UMSResponseCodeSuccess){
        [[AMToastView toastView] showMessage:@"分享成功" icon:kImageRequestSuccess duration:AMToastDurationNormal];
        
        if ([self.delegate respondsToSelector:@selector(UCSNSHelper:shareSuccessWithChannelType:)]) {
            [self.delegate UCSNSHelper:self shareSuccessWithChannelType:self.channelType];
        }
    }
    else{
        
        if (response.responseCode == UMSResponseCodeNetworkError)
            [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
        else if (response.responseCode == UMSResponseCodeShareRepeated)
            [[AMToastView toastView] showMessage:@"分享内容重复" icon:kImageRequestError duration:AMToastDurationNormal];
        else if (response.responseCode != UMSResponseCodeCancel)
            [[AMToastView toastView] showMessage:@"分享失败" icon:kImageRequestError duration:AMToastDurationNormal];
        
        if ([self.delegate respondsToSelector:@selector(UCSNSHelper:shareFailedWithChannelType:)]) {
            [self.delegate UCSNSHelper:self shareFailedWithChannelType:self.channelType];
        }
    }
}

/** 截获分享渠道 */
-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    // 微信好友特殊处理 放到下面的 switch 里了
//    if ([platformName isEqualToString:@"wxsession"] || [platformName isEqualToString:@"wxtimeline"]) {
//        socialData.shareText = [_wxsessionContent objectForKey:@"shareText"];
//    }
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:platformName];
    
    //    SNSChannelTypeWeibo         = 1, //微博
    //    SNSChannelTypeQZone         = 2, //QZone
    //    SNSChannelTypeTencentWeibo  = 3, //腾讯微博
    //    SNSChannelTypeWeChat        = 4, //微信好友
    //    SNSChannelTypeWeChatMoments = 5, //微信朋友圈
    //    SNSChannelTypeRenRen        = 6, //人人
    //    SNSChannelTypeEmail         = 7, //邮件
    //    SNSChannelTypeSMS           = 8, //短信
    
    switch (snsPlatform.shareToType) {
        case UMSocialSnsTypeSina:
        {
            self.channelType = SNSChannelTypeWeibo;
        }
            break;
        case UMSocialSnsTypeQzone:
        {
            self.channelType = SNSChannelTypeQZone;
        }
            break;
        case UMSocialSnsTypeTenc:
        {
            self.channelType = SNSChannelTypeTencentWeibo;
        }
            break;
        case UMSocialSnsTypeWechatSession:
        {
            self.channelType = SNSChannelTypeWeChat;
            socialData.shareText = [_wxsessionContent objectForKey:@"shareText"];
        }
            break;
        case UMSocialSnsTypeWechatTimeline:
        {
            self.channelType = SNSChannelTypeWeChatMoments;
            socialData.shareText = [_wxsessionContent objectForKey:@"shareText"];
        }
            break;
            
        case UMSocialSnsTypeRenr:
        {
            self.channelType = SNSChannelTypeRenRen;
//            if (self.contentNoURL.length>0) {
//                socialData.shareText = self.contentNoURL;
//            }
        }
            break;
            
        case UMSocialSnsTypeEmail:
        {
            self.channelType = SNSChannelTypeEmail;
        }
            break;
        case UMSocialSnsTypeSms:
        {
            self.channelType = SNSChannelTypeSMS;
        }
            break;
        default:
            break;
    }
    
}

-(void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType{
    AMLog(@"didCloseUIViewController");
    if ([self.delegate respondsToSelector:@selector(UCSNSHelperShareCancelled)]) {
        [self.delegate UCSNSHelperShareCancelled];
    }
}


@end
