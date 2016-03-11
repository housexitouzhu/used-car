//
//  UCIMRootEntry.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCIMRootEntry.h"
#import "MainViewController.h"
#import "UCChatRootView.h"
#import "UCDealerVerifyView.h"
#import "UCInputCodeView.h"
#import "AMCacheManage.h"
#import "IMCacheManage.h"
#import "UCIMHistoryView.h"
#import "UCCarDetailInfoModel.h"
#import "XMPPDBCacheManager.h"
#import "UCMainView.h"

typedef enum {
    UCIMRootEntryOpenClient,
    UCIMRootEntryOpenDealer,
    UCIMRootEntryOpenChatRoot,
    UCIMRootEntryOpenChatHistory,
} UCIMRootEntryOpenViewType;

@interface UCIMRootEntry ()

@property (nonatomic, strong) UCClientVerifyView *vClientVerify;
@property (nonatomic, strong) UCDealerVerifyView *vDealerVerify;
@property (nonatomic, weak) UCCarDetailInfoModel *mCarInfo;

@end

@implementation UCIMRootEntry

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(UCClientVerifyView *)vClientVerify
{
    if (!_vClientVerify) {
        _vClientVerify = [[UCClientVerifyView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds];
    }
    return _vClientVerify;
}

-(UCDealerVerifyView *)vDealerVerify
{
    if (!_vDealerVerify) {
        _vDealerVerify = [[UCDealerVerifyView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds];
    }
    return _vDealerVerify;
}

-(UCIMHistoryView *)vIMHistory
{
    return [[UCIMHistoryView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds];
}

- (UCChatRootView *)getChatRootView:(UCCarDetailInfoModel *)carModel
{
    return [[UCChatRootView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds withCarInfoModel:carModel];
}

/** 新建聊天页面 */
- (void)openChatRootByVerified:(UCCarDetailInfoModel *)mCarInfo
{
    // 已验证
    if ([IMCacheManage currentIMUserInfo]) {
        [[MainViewController sharedVCMain] openView:[self getChatRootView:mCarInfo] animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
    // 未验证
    else {
        // 商家
        if ([AMCacheManage currentUserType] == UserStyleBusiness) {
            [self.vDealerVerify verifyDealerIM:^(UCDealerVerifyView *vDealerIM, BOOL isSuccess, NSError *error) {
                if (isSuccess) {
                    // 是否显示首页小红点
                    [[UCMainView sharedMainView] refreshRedPointAndUserCenterChatBarCountIfNeed];
                    [[MainViewController sharedVCMain] closeView:vDealerIM animateOption:AnimateOptionMoveNone];
                    [[MainViewController sharedVCMain] openView:[self getChatRootView:mCarInfo] animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
                }
            }];
            [[MainViewController sharedVCMain] openView:self.vDealerVerify animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
        // 个人
        else {
            self.vClientVerify.delegate = self;
            [UMStatistics event:pv_4_3_buyCar_Detail_IM_Auth];
            [UMSAgent postEvent:buycar_chat_verify_user_pv page_name:NSStringFromClass(self.vClientVerify.class)];
            [self.vClientVerify verifyClientIM:^(UCClientVerifyView *vClientIM, BOOL isSuccess, NSError *error) {
                if (isSuccess) {
                    // 是否显示首页小红点
                    [[UCMainView sharedMainView] refreshRedPointAndUserCenterChatBarCountIfNeed];
                    [UMStatistics event:c_4_3_buyCar_Detail_IM_Auth_Done];
                    [[MainViewController sharedVCMain] openView:[self getChatRootView:mCarInfo] animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionPrevious];
                }
            }];
            [[MainViewController sharedVCMain] openView:self.vClientVerify animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
    }
    
}

/** 打开聊天记录页 */
- (void)openChatHistoryByVerified
{
    // 已验证
    if ([IMCacheManage currentIMUserInfo]) {
        [[MainViewController sharedVCMain] openView:self.vIMHistory animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
    // 未验证
    else {
        UCView * vTemp = nil;
        if ([AMCacheManage currentUserType] == UserStyleBusiness) {
            vTemp = self.vDealerVerify;
            [self.vDealerVerify verifyDealerIM:^(UCDealerVerifyView *vDealerIM, BOOL isSuccess, NSError *error) {
                if (isSuccess) {
                    // 是否显示首页小红点
                    [[UCMainView sharedMainView] refreshRedPointAndUserCenterChatBarCountIfNeed];
                    [[MainViewController sharedVCMain] closeView:vDealerIM animateOption:AnimateOptionMoveNone];
                    [[MainViewController sharedVCMain] openView:self.vIMHistory animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
                }
            }];
        } else {
            vTemp = self.vClientVerify;
            [self.vClientVerify verifyClientIM:^(UCClientVerifyView *vClientIM, BOOL isSuccess, NSError *error) {
                if (isSuccess) {
                    // 是否显示首页小红点
                    [[UCMainView sharedMainView] refreshRedPointAndUserCenterChatBarCountIfNeed];
                    [[MainViewController sharedVCMain] openView:self.vIMHistory animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionPrevious];
                }
            }];
        }
        [[MainViewController sharedVCMain] openView:vTemp animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    };
}

/** 打开商家验证 */
- (void)openVerifyDealerPermissionView
{
    [self.vDealerVerify verifyDealerIM:^(UCDealerVerifyView *vDealerIM, BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            // 是否显示首页小红点
            [[UCMainView sharedMainView] refreshRedPointAndUserCenterChatBarCountIfNeed];
            [[MainViewController sharedVCMain] closeView:vDealerIM animateOption:AnimateOptionMoveAuto];
        }
    }];
    [[MainViewController sharedVCMain] openView:self.vDealerVerify animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
}

#pragma mark - UCClientVerifyViewDelegate
-(void)clientVerifyViewDidClickCancel:(UCClientVerifyView *)vClientVerify
{
    [UMStatistics event:c_4_3_buyCar_Detail_IM_Auth_Cancel];
}

@end
