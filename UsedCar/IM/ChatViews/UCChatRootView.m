//
//  UCChatRootView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCChatRootView.h"
#import "UCTopBar.h"
#import "ChatListView.h"
#import "ChatInputBarView.h"
#import "APIHelper.h"
#import "XMPPManager.h"
#import "IMCacheManage.h"
#import "XMPPDBCacheManager.h"
#import "UCCarDetailInfoModel.h"
#import "CarMessageBody.h"
#import "TextMessageBody.h"
#import "ImageMessageBody.h"
#import "VoiceMessageBody.h"
#import "BaseChatCell.h"
#import "UCCarDetailView.h"
#import "UCMainView.h"
#import "NSString+Util.h"

#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "StorageContact.h"
#import "AMCacheManage.h"
#import "XMPPFileCacheManager.h"
#import "UCImageBrowseView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ALAssetsLibrary+Util.h"


@interface UCChatRootView ()<ChatInputBarViewDelegate, XMPPManagerDelegate, ChatCellDelegate, InputMorePanelDelegate, ELCImagePickerControllerDelegate, UIImagePickerControllerDelegate, ChatListViewDelegate, ELCAlbumPickerControllerDelegate>
{
    CGRect inputBarRect;
    BOOL _baseCarInfoSent;
    BOOL _goingToNextView;
}

@property (nonatomic, assign) BOOL viewInited;
@property (nonatomic, assign) BOOL fromHistory;
@property (nonatomic, strong) UCTopBar                 *tbTop;
@property (nonatomic, strong) ChatListView             *vChatList;
@property (nonatomic, strong) ChatInputBarView         *vInputBar;
@property (nonatomic, strong) APIHelper                *serverHelper;
@property (nonatomic, strong) NSString                 *serverIP;
@property (nonatomic, strong) NSString                 *serverPort;
@property (nonatomic, strong) UCCarDetailInfoModel     *mCarInfo;
@property (nonatomic, strong) ELCAlbumPickerController *elcPicker;
@property (nonatomic, strong) StorageContact           *contact;
@property (nonatomic, strong) NSArray                  *messages;
@property (nonatomic, strong) UIImagePickerController  *imagePickerController;
@property (nonatomic, strong) ALAssetsLibrary *lib;

@property (nonatomic, strong) IMUserInfoModel *mContactInfo;         // 对方的IM信息

@property (nonatomic, strong) APIHelper *regIMHelper;
@property (nonatomic, strong) APIHelper *linkHelper;

@end


@implementation UCChatRootView

- (id)initWithFrame:(CGRect)frame contact:(StorageContact *)listContact withHistoryArray:(NSArray *)array{
    
    self = [super initWithFrame:frame];
    if (self) {
        _fromHistory = YES;
        _baseCarInfoSent = YES;
        self.contact = listContact;
        [self initView];
        
        self.messages = array;
        [_vChatList addHistoryMessagesToArray:array contact:listContact];
        
        [[XMPPManager sharedManager] addToDelegateQueue:self];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withCarInfoModel:(UCCarDetailInfoModel *)mCarInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _baseCarInfoSent = NO;
        _fromHistory = NO;
        _mCarInfo = mCarInfo;
        [self initView];
        
        [[XMPPManager sharedManager] addToDelegateQueue:self];
    }
    return self;
}

-(StorageContact *)contact
{
    if (!_contact) {
        _contact = [[StorageContact alloc] init];
    }
    return _contact;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
        [[XMPPManager sharedManager] addToDelegateQueue:self];
    }
    return self;
}

/** 防止首页红点显示 */
-(void)viewWillShow:(BOOL)animated
{
    [super viewWillShow:animated];
    [[XMPPManager sharedManager] removeFromDelegateQueue:[UCMainView sharedMainView]];
    
    XMPPManager *xmpp = [XMPPManager sharedManager];
    if (xmpp.xStream.isDisconnected && self.viewInited) {
        [_tbTop.btnTitle setTitle:@"(连接中...)" forState:UIControlStateNormal];
        [xmpp connectToServer];
    }
}

-(void)viewWillHide:(BOOL)animated
{
    [self endEditing:NO];
    [[XMPPManager sharedManager] addToDelegateQueue:[UCMainView sharedMainView]];
}

-(void)viewWillClose:(BOOL)animated
{
    [super viewWillClose:animated];
    [[XMPPManager sharedManager] removeFromDelegateQueue:self];
}

- (void)initView{
    [UMStatistics event:pv_4_3_buyCar_Detail_IM_Chat];
    [UMSAgent postEvent:buycar_chat_pv page_name:NSStringFromClass(self.class)];
    
    self.backgroundColor =  kColorNewBackground;
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    
    inputBarRect = CGRectMake(0, self.height-InputBoxBarHeight, self.width, InputBoxBarHeight);
    _vInputBar = [[ChatInputBarView alloc] initWithFrame:inputBarRect];
    _vInputBar.delegate = self;
    _vInputBar.panelMore.delegate = self;
    
    [_vInputBar setInputBoxEnabled:_fromHistory ? YES : NO];
    
    _vChatList = [[ChatListView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, _vInputBar.minY - _tbTop.maxY)];
    _vChatList.delegateOfCell = self;
    _vChatList.delegate = self;
    [self addSubview:_vChatList];
    [self addSubview:_vInputBar];
    
    [self getIMServiceInfo];
    
    // 标记已读
    [[XMPPDBCacheManager sharedManager] setMessagesIsReadedWithJid:self.contact.shortJid];
    
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];

    // 标题
    if (_fromHistory) {
        [vTopBar.btnTitle setTitle:[self titleForTopBar] forState:UIControlStateNormal];
    }
    else{
        [vTopBar.btnTitle setTitle:@"(连接中...)" forState:UIControlStateNormal];
    }
    
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

- (NSString *)titleForTopBar{
    NSString *dearName = nil;
    if (_fromHistory) {
        dearName = self.contact.dealerid.integerValue > 0 ? @"(商家)" : @"(个人)";
    } else {
        dearName = _mCarInfo.userid.integerValue > 0 ? @"(商家)" : @"(个人)";
    }
    NSString *userName = _fromHistory ? self.contact.nickName : _mCarInfo.salesPerson.salesname;
    NSString *title = [NSString stringWithFormat:@"%@%@", userName, dearName];
    return title;
}

#pragma mark - ChatListView Delegate
- (void)ChatListView:(ChatListView *)chatListView shouldDismissKeyboard:(BOOL)flag{
    
    if (_vInputBar.isInEditing) {
        [_vInputBar endEditting];
        [_vChatList refreshTableScrollToMessage:NO];
    }
}

#pragma mark - button actions
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    if (![OMG isValidClick]) {
        return;
    }
    [[XMPPManager sharedManager] removeFromDelegateQueue:self];
    [self endEditing:YES];
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}



#pragma mark - ChatInputBarViewDelegate

- (void)ChatInputBarView:(ChatInputBarView*)inputBarView frameDidChanged:(CGRect)frame{
    //    AMLog(@"inputframeY %f %f", frame.origin.y, frame.origin.y - _tbTop.maxY);
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //    [UIView setAnimationDuration:0.25];
    //    [_vChatList setFrame:CGRectMake(0, _tbTop.maxY, self.width, frame.origin.y - _tbTop.maxY)];
    //    [UIView commitAnimations];
    
    [_vChatList setFrame:CGRectMake(0, _tbTop.maxY, self.width, frame.origin.y - _tbTop.maxY)];
    
    if (_goingToNextView) {
        _goingToNextView = NO;
    }
    else{
        [_vChatList.tableView scrollRectToVisible:CGRectMake(0, _vChatList.tableView.contentSize.height - _vChatList.tableView.height, _vChatList.tableView.width, _vChatList.tableView.height) animated:NO];
    }
    
}


- (void)ChatInputBarView:(ChatInputBarView*)inputBarView sendText:(NSString*)textStr{
    [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_SendText];
    TextMessageBody *tmBody = [[TextMessageBody alloc] initWithMessage:textStr];
    StorageMessage *message = [[StorageMessage alloc] initWithText:tmBody andContact:self.contact];
    message.isOutgoing = 1;
    [[XMPPDBCacheManager sharedManager] insertMessage:message];
    [_vChatList addNewMessageToArray:message];
    [[XMPPManager sharedManager] sendStorageMessage:message];
}

- (void)ChatInputBarView:(ChatInputBarView*)inputBarView didSelectPhrase:(NSString*)phrase
{
    [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_QuickType];
    TextMessageBody *tmBody = [[TextMessageBody alloc] initWithMessage:phrase];
    StorageMessage *message = [[StorageMessage alloc] initWithText:tmBody andContact:self.contact];
    message.isOutgoing = 1;
    [[XMPPDBCacheManager sharedManager] insertMessage:message];
    [_vChatList addNewMessageToArray:message];
    [[XMPPManager sharedManager] sendStorageMessage:message];
}

- (void)sendCarInfoIfNeed{
    // 有历史记录的message消息，不发送图片
    if (self.messages.count == 0) {
        CarMessageBody *cmBody = [[CarMessageBody alloc] initWithModel:_mCarInfo];
        StorageMessage *message = [[StorageMessage alloc] initWithSpecMessageBody:cmBody andContact:self.contact];
        message.isOutgoing = 1;
        [[XMPPDBCacheManager sharedManager] insertMessage:message withContactCheck:YES];
        [_vChatList addNewMessageToArray:message];
        [[XMPPManager sharedManager] sendStorageMessage:message];
    }
}

- (void)sendImageMessage:(NSArray*)images{
    
    for (NSInteger i = 0; i < images.count; i++) {
        NSDictionary *info = [images objectAtIndex:i];
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSURL *assetURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
        NSString *urlstr = [assetURL absoluteString];
        //异步上传、上传成功后发图片URL的IM消息
        
        ImageMessageBody *imb = [[ImageMessageBody alloc] initWithSmallUri:urlstr largeUri:urlstr];
        StorageMessage *message = [[StorageMessage alloc] initWithSendImage:image andContact:self.contact];
        message.isOutgoing = 1;
        message.message = imb.jsonString;
        [[XMPPDBCacheManager sharedManager] insertMessage:message];
        
        //发送IM消息ok后存图片到图片缓存
        [[XMPPFileCacheManager sharedManager] saveToCacheWithMessage:message];
        
        [_vChatList addNewMessageToArray:message toContact:self.contact];
    }
}

#pragma mark - Chat Cell delgate
- (void)ChatCell:(BaseChatCell *)cell buttonClickedWithMessage:(StorageMessage *)message{
    AMLog(@"message %@",message);
    _goingToNextView = YES;
    [_vInputBar endEditting];
    
    switch (message.type) {
        case IMMessageTypeCar:
        {
            [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_CarInfo];
            CarMessageBody *mbCar = (CarMessageBody *)message.mesBody;
            UCCarDetailView *vCarDetail = [[UCCarDetailView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds CarID:mbCar.carid];
            [[MainViewController sharedVCMain] openView:vCarDetail animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
        case IMMessageTypeImage:
        {
            [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_ViewPhoto];
            [UMStatistics event:pv_4_3_buyCar_Detail_IM_Chat_More_Photo_Preview];
            ImageMessageBody *mbImage = (ImageMessageBody *)message.mesBody;
            UCImageBrowseView *imgBrower = [[UCImageBrowseView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds index:0 thumbimgurls:@[mbImage.smallUri] imageUrls:@[mbImage.uri]];
            [[MainViewController sharedVCMain] openView:imgBrower animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
        case IMMessageTypeVoice:
        {
            
        }
            break;
        default:
            break;
    }
}




#pragma mark - InputMorePanelDelegate
- (void)InputMorePanelDelegate:(InputMorePanel*)panel didSelectFunction:(InputMoreFunction)function{
    
    switch (function) {
        case InputMoreFunctionImage:
        {
            [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_More_Photo];
            ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
            albumController.delegate = self;
            ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
            [albumController setParent:imagePicker];
            [imagePicker setDelegate:self];
            [UMSAgent postEvent:buycar_chat_photo_pv page_name:NSStringFromClass(self.class)];
            [UMStatistics event:pv_4_3_buyCar_Detail_IM_Chat_More_Photo];
            [[MainViewController sharedVCMain] presentViewController:imagePicker animated:YES completion:NULL];
        }
            break;
        case InputMoreFunctionCamera:
        {
            [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_More_Camera];
            [self takePicture];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - ELCImagePickerController Delegate
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    
    AMLog(@"didFinishPickingMediaWithInfo %@", info);
    [picker dismissModalViewControllerAnimated:YES];
    [[AMToastView toastView] hide];
    if(info.count > 0){
        [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_More_Photo_Send];
        [self sendImageMessage:info];
    }
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)elcImagePickerController:(ELCImagePickerController *)picker didSelcetedNumber:(NSInteger)number{
    if (number == 1) {
        [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_More_Photo_Choose];
        return NO;
    }
    else{
        return YES;
    }
}

- (void)ELCAlbumPickerController:(ELCAlbumPickerController *)controller didSelectAlbumn:(ALAssetsGroup *)assetsGroup{
    [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_More_Photo_ChooseAlbum];
}

- (void)ELCAlbumPickerControllerDidSelectingAlbumn:(ELCAlbumPickerController *)controller{
    [UMStatistics event:pv_4_3_buyCar_Detail_IM_Chat_More_Photo_Album];
}

- (void)ELCAlbumPickerControllerSelectingDisabled:(ELCAlbumPickerController *)controller{
    [UMStatistics event:pv_4_3_buyCar_Detail_IM_Chat_More_Photo_Limit];
}

#pragma mark - 拍照
-(void)takePicture{
    
    //检查相机模式是否可用
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        AMLog(@"sorry, no camera or camera is unavailable.");
        
        return;
        
    }
    
    //获得相机模式下支持的媒体类型
    NSArray* availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    BOOL canTakePicture = NO;
    for (NSString* mediaType in availableMediaTypes) {
        if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
            //支持拍照
            canTakePicture = YES;
            break;
        }
    }
    
    //检查是否支持拍照
    if (!canTakePicture) {
        AMLog(@"sorry, taking picture is not supported.");
        return;
    }
    
//    if (IOS7_OR_LATER) {
//        if(!([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized)){
//            [UMStatistics event:pv_4_3_buyCar_Detail_IM_Chat_More_Camera_Limit];
//        }
//    }
    
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
    }
    //设置图像选取控制器的来源模式为相机模式
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePickerController.showsCameraControls =YES;
    //    [_imagePickerController setVideoQuality:UIImagePickerControllerQualityTypeIFrame960x540];
    
    //设置图像选取控制器的类型为静态图像
    _imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
    
    //允许用户进行编辑
    //    _imagePickerController.allowsEditing = YES;
    
    //设置委托对象
    [_imagePickerController setDelegate:self];
    
    [UMStatistics event:pv_4_3_buyCar_Detail_IM_Chat_More_Camera];
    [UMSAgent postEvent:buycar_chat_camera_pv page_name:NSStringFromClass(self.class)];
    [[MainViewController sharedVCMain] presentViewController:_imagePickerController animated:YES completion:NULL];
}

#pragma mark - UIIMAGE PICKER DELEGATE
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    AMLog(@"MediaWithInfo %@", info);
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_More_Camera_Shot];
        [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_More_Camera_Confirm];
        [UMStatistics event:pv_4_3_buyCar_Detail_IM_Chat_More_Camera_Confirm];
        [UMSAgent postEvent:buycar_chat_camera_confirm_pv page_name:NSStringFromClass(self.class)];
        
        NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
        if ([type isEqualToString:@"public.image"]) {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            
            _lib = [[ALAssetsLibrary alloc] init];
            [_lib saveImage:image toAlbum:@"二手车之家" withCompletionBlock:^(ALAsset *asset, NSError *error) {
                
                if (error) {
                    [[AMToastView toastView] showMessage:@"图片保存到二手车之家相册失败" icon:kImageRequestError duration:AMToastDurationNormal];
                }
                else{
                    AMLog(@"^^^^^^^^^^^^^^^\n%@", asset);
                    NSMutableDictionary *workingDictionary = [NSMutableDictionary new];
                    [workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
                    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
                    
                    CGImageRef imgRef = [assetRep fullScreenImage];
                    UIImage *img = [UIImage imageWithCGImage:imgRef
                                                       scale:[UIScreen mainScreen].scale
                                                 orientation:UIImageOrientationUp];
                    [workingDictionary setObject:img forKey:@"UIImagePickerControllerOriginalImage"];
                    [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
                    
                    [picker dismissViewControllerAnimated:YES completion:^{
                        [self sendImageMessage:@[workingDictionary]];
                    }];
                }
                
            }];
            
        }
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//#pragma mark - 照片保存后
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
//
//    AMLog(@"error %@ %@", error, contextInfo);
//
////    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
////
////    for(ALAsset *asset in assets) {
////
//        NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
//        [workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
//        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
//
//        CGImageRef imgRef = [assetRep fullScreenImage];
//        UIImage *img = [UIImage imageWithCGImage:imgRef
//                                           scale:[UIScreen mainScreen].scale
//                                     orientation:UIImageOrientationUp];
//        [workingDictionary setObject:img forKey:@"UIImagePickerControllerOriginalImage"];
//        [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
//
//        [returnArray addObject:workingDictionary];
////    }
//
//    if (!error) {
//
//        [_imagePickerController dismissViewControllerAnimated:YES completion:^{
//            [self sendImageMessage:@[image]];
//        }];
//
//    }
//}



#pragma mark - Used Car Networking

- (void)getIMServiceInfo{
    
    if (!_serverHelper) {
        _serverHelper = [[APIHelper alloc] init];
    }
    
    __weak UCChatRootView *weakSelf = self;
    [_serverHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            [[AMToastView toastView] showMessage:@"链接失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            [weakSelf performSelector:@selector(onClickBackBtn:) withObject:nil afterDelay:2.5];
            return ;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase.returncode == 0) {
                IMUserInfoModel *mIMUser = [IMCacheManage currentIMUserInfo];
                mIMUser.server      = [mBase.result objectForKey:@"server"];
                mIMUser.port        = [mBase.result objectForKey:@"port"];
                mIMUser.domain      = [mBase.result objectForKey:@"domain"];
                mIMUser.imgupload   = [mBase.result objectForKey:@"imgupload"];
                mIMUser.imgprefix   = [mBase.result objectForKey:@"imgprefix"];
                mIMUser.voiceupload = [mBase.result objectForKey:@"voiceupload"];
                mIMUser.voiceprefix = [mBase.result objectForKey:@"voiceprefix"];
                
                [IMCacheManage setCurrentIMUserInfo:mIMUser];
                
                if (weakSelf.fromHistory) {
                    [weakSelf addLinker];
                }
                else{
                    [weakSelf registerIM];
                }
            }
        }
    }];
    [_serverHelper getIMServerInfo];
}

- (void)registerIM{
    
    if (!_regIMHelper) {
        _regIMHelper = [[APIHelper alloc] init];
    }
    
    __weak UCChatRootView *weakSelf = self;
    
    [_regIMHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            [[AMToastView toastView] showMessage:@"链接失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            [weakSelf performSelector:@selector(onClickBackBtn:) withObject:nil afterDelay:2.5];
            return ;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mb = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mb.returncode == 0) {
                NSDictionary *result = mb.result;
                NSString *name = [result objectForKey:@"name"];
                NSString *nickName = [result objectForKey:@"nickname"];
                
                weakSelf.contact.shortJid = name;
                weakSelf.contact.fullJid = [NSString stringWithFormat:@"%@@%@/%@",weakSelf.contact.shortJid,[IMCacheManage currentIMUserInfo].domain,kXMPP_USER_RESOURCE];
                weakSelf.contact.nickName = nickName;
                
                // 获得聊天记录
                if (weakSelf.messages.count == 0 && [[XMPPDBCacheManager sharedManager] hasContactWithJid:weakSelf.contact.shortJid] > 0) {
                    NSArray *messageTemp = [[XMPPDBCacheManager sharedManager] firstPageMessagesWithJid:weakSelf.contact.shortJid];
                    if (messageTemp.count > 0) {
                        [weakSelf.vChatList addHistoryMessagesToArray:messageTemp contact:weakSelf.contact];
                    }
                }
                
                [weakSelf addLinker];
            }
            else{
                [[AMToastView toastView] showMessage:@"链接失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
                [weakSelf performSelector:@selector(onClickBackBtn:) withObject:nil afterDelay:2.5];
            }
        }
        else{
            [[AMToastView toastView] showMessage:@"链接失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            [weakSelf performSelector:@selector(onClickBackBtn:) withObject:nil afterDelay:2.5];
        }
        
    }];
    
    [_regIMHelper registerIMwithMobileName:_mCarInfo.salesPerson.salesphone nickname:_mCarInfo.salesPerson.salesname memberID:_mCarInfo.memberid.integerValue > 0 ? _mCarInfo.memberid.stringValue : nil dealerID:_mCarInfo.userid.integerValue > 0 ? _mCarInfo.userid.stringValue : nil salesID:_mCarInfo.userid.integerValue > 0 ? _mCarInfo.salesPerson.salesid.stringValue : nil validcode:nil];
}

- (void)addLinker{
    
    if (!_linkHelper) {
        _linkHelper = [[APIHelper alloc] init];
    }
    
    __weak UCChatRootView *weakSelf = self;
    [_linkHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            [[AMToastView toastView] showMessage:@"链接失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            [weakSelf performSelector:@selector(onClickBackBtn:) withObject:nil afterDelay:2.5];
            return ;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mb = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mb.returncode == 0) {
                XMPPManager *xmpp = [XMPPManager sharedManager];
                [xmpp connectToServer];
                
                weakSelf.viewInited = YES;
            }
            else{
                [[AMToastView toastView] showMessage:@"链接失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
                [weakSelf performSelector:@selector(onClickBackBtn:) withObject:nil afterDelay:2.5];
            }
        }
        else{
            [[AMToastView toastView] showMessage:@"链接失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            [weakSelf performSelector:@selector(onClickBackBtn:) withObject:nil afterDelay:2.5];
        }
        
    }];
    
    IMUserInfoModel *mIMUser = [IMCacheManage currentIMUserInfo];
    UserInfoModel *mUser = [AMCacheManage currentUserInfo];
    
    NSString *imgUrl = nil;
    NSString *dealerid = nil;
    NSString *memberid = nil;
    NSString *saleid = nil;
    
    if (_fromHistory) {
        imgUrl = self.contact.photo;
        dealerid = self.contact.dealerid;
        memberid = self.contact.memberid;
        saleid = self.contact.salesid;
    } else {
        if (_mCarInfo.thumbimgurls.length > 0) {
            NSArray *thumbImgUrls = [_mCarInfo.thumbimgurls componentsSeparatedByString:@","];
            imgUrl = thumbImgUrls.count > 0 ? [thumbImgUrls firstObject] : nil;
        }
        dealerid = _mCarInfo.userid.integerValue > 0 ? _mCarInfo.userid.stringValue : nil;
        memberid = _mCarInfo.memberid.integerValue > 0 ? _mCarInfo.memberid.stringValue : nil;
        saleid = _mCarInfo.userid.integerValue > 0 ? _mCarInfo.salesPerson.salesid.stringValue : nil;
        
    }
    [_linkHelper addIMLinkerNamefrom:mIMUser.name
                           nickname:mIMUser.nickname
                     dealernamefrom:[AMCacheManage currentUserType] == UserStyleBusiness ? mUser.username : nil
                             nameto:self.contact.shortJid
                         nicknameto:self.contact.nickName
                           dealerid:dealerid
                           memberid:memberid
                            salesid:saleid
                            carname:_fromHistory ? self.contact.carName : _mCarInfo.carname
                          carimgurl:imgUrl
                         dealername:_fromHistory ? self.contact.dealerName : _mCarInfo.dealer.username
                           objectid:_fromHistory ? self.contact.carid : _mCarInfo.carid.stringValue
                             typeid:nil];
    
}

#pragma mark - XMPP Connection Delegate
- (void)didAuthenticate{
    
    [_tbTop.btnTitle setTitle:[self titleForTopBar] forState:UIControlStateNormal];
    
    if (!_baseCarInfoSent) {
        [self sendCarInfoIfNeed];
    }
    if (!_fromHistory)
        [_vInputBar setInputBoxEnabled:YES];
}

- (void)didSendXMPPMessage:(XMPPMessage *)message
{
    if (message.isCarMessage) {
        _baseCarInfoSent = YES;
    }
}

- (void) didReceiveMessage:(StorageMessage *)message
{
    if ([message.jid isEqualToString:self.contact.shortJid]) {
        [_vChatList addNewMessageToArray:message];
    }
    
    [[XMPPDBCacheManager sharedManager] setMessagesIsReadedWithJid:self.contact.shortJid];
}

//- (void)streamDidDisconnected:(XMPPStream *)sender{
//    [_vInputBar setInputBoxEnabled:NO];
//    
//}

#pragma mark - dealloc
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[XMPPManager sharedManager] removeFromDelegateQueue:self];
    if (!_fromHistory)
        [[XMPPManager sharedManager] logout];
    
    if ([_regIMHelper isConnecting]) {
        [_regIMHelper cancel];
    }
    
    if ([_linkHelper isConnecting]) {
        [_linkHelper cancel];
    }
}


@end
