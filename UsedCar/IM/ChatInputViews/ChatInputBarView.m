//
//  ChatInputBarView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "ChatInputBarView.h"
#import "UIImage+Util.h"
#import "UIView+Util.h"
#import "AMCacheManage.h"
#import "IMCacheManage.h"


#define kRecordingLength_Min 1
#define kRecordingLength_Max 60

@interface ChatInputBarView ()<UITextViewDelegate, InputPhrasePanelDelegate>
{
    UIView *_vBar;
    UIView *_vPanel;
    
    UIButton *_btnMic;
    UIButton *_btnBubble;
    UIButton *_btnMore;
    UIButton *_btnVoice;
    UITextView *_tvInput;
    
    UIImage *_iconMic;
    UIImage *_iconKeyboard;
    UIImage *_iconBubble;
    UIImage *_iconMore;
    
    UIImage *_iconMicPress;
    UIImage *_iconKeyboardPress;
    UIImage *_iconBubblePress;
    UIImage *_iconMorePress;
    
    InputPhrasePanel *_panelPhrase;
//    InputMorePanel *_panelMore;
    
    //keyboard
    CGRect inputBarRect;
    
    //recording
    NSTimer *_recordingTimer;
    NSInteger _timerCount;
    
}


@end

@implementation ChatInputBarView

- (id)initWithFrame:(CGRect)frame{
    frame.size.height = InputBoxBarHeight + InputBoxPanelHeight;
    inputBarRect = frame;
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [self initView];
    }
    return self;
}

- (void)initView{
    self.backgroundColor = kColorClear;
    
    _vBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, InputBoxBarHeight)];
    _vBar.backgroundColor = kColorNewGray3;
    [self addSubview:_vBar];
    
    [self createInputBarView];
    
    _vPanel = [[UIView alloc] initWithFrame:CGRectMake(0, _vBar.maxY, self.width, InputBoxPanelHeight)];
    _vPanel.backgroundColor = kColorClear;
    [self addSubview:_vPanel];
    
    [self createPanelView];
    
}

- (void)createInputBarView{
    
    _iconMic           = [UIImage imageNamed:@"consultation_microphone"];
    _iconMicPress      = [UIImage imageNamed:@"consultation_microphone_pre"];
    _iconKeyboard      = [UIImage imageNamed:@"consultation_Keyboard"];
    _iconKeyboardPress = [UIImage imageNamed:@"consultation_Keyboard_pre"];
    _iconBubble        = [UIImage imageNamed:@"consultation_commonlanguage"];
    _iconBubblePress   = [UIImage imageNamed:@"consultation_commonlanguage_pre"];
    _iconMore          = [UIImage imageNamed:@"consultation_add"];
    _iconMorePress     = [UIImage imageNamed:@"consultation_add_pre"];
    
    _btnMic = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnMic setImage:_iconMic forState:UIControlStateNormal];
    [_btnMic setImage:_iconMicPress forState:UIControlStateSelected];
    [_btnMic setImage:_iconMicPress forState:UIControlStateHighlighted];
    [_btnMic setFrame:CGRectMake(8, 0, 0, InputBoxBarHeight)];//CGRectMake(8, 0, 29, InputBoxBarHeight)];
    [_btnMic addTarget:self action:@selector(onClickBtnMic:) forControlEvents:UIControlEventTouchUpInside];
    [_vBar addSubview:_btnMic];
    
    _btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnMore setImage:_iconMore forState:UIControlStateNormal];
    [_btnMore setImage:_iconMorePress forState:UIControlStateSelected];
    [_btnMore setImage:_iconMorePress forState:UIControlStateHighlighted];
    [_btnMore setFrame:CGRectMake(_vBar.width - 8 - 29, 0, 29, InputBoxBarHeight)];
    [_btnMore addTarget:self action:@selector(onClickBtnMore:) forControlEvents:UIControlEventTouchUpInside];
    [_vBar addSubview:_btnMore];
    
    _btnBubble = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnBubble setImage:_iconBubble forState:UIControlStateNormal];
    [_btnBubble setImage:_iconBubblePress forState:UIControlStateSelected];
    [_btnBubble setImage:_iconBubblePress forState:UIControlStateHighlighted];
    [_btnBubble setFrame:CGRectMake(_btnMore.minX - 8 - 29, 0, 29, InputBoxBarHeight)];
    [_btnBubble addTarget:self action:@selector(onClickBtnBubble:) forControlEvents:UIControlEventTouchUpInside];
    [_vBar addSubview:_btnBubble];
    
    CGFloat inputWidth = _btnBubble.minX - _btnMic.maxX-16;
    _btnVoice = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnVoice setFrame:CGRectMake(_btnMic.maxX+8, 7, inputWidth, 32)];
    [_btnVoice setTitle:@"按住 说话" forState:UIControlStateNormal];
    [_btnVoice.titleLabel setFont:kFontLarge1];
    [_btnVoice setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
    [_btnVoice setBackgroundImage:[UIImage imageWithColor:kColorWhite size:_btnVoice.size] forState:UIControlStateNormal];
    [_btnVoice setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:0.2] size:_btnVoice.size] forState:UIControlStateHighlighted];
    [_btnVoice.layer setBorderColor:[kColorNewLine CGColor]];
    [_btnVoice.layer setBorderWidth:kLinePixel];
    [_btnVoice.layer setCornerRadius:3.0];
    [_btnVoice.layer setMasksToBounds:YES];
    [_btnVoice addTarget:self action:@selector(voiceButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_btnVoice addTarget:self action:@selector(voiceButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_btnVoice addTarget:self action:@selector(voiceButtonDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [_vBar addSubview:_btnVoice];
    
    _tvInput = [[UITextView alloc] initWithFrame:_btnVoice.frame];
    [_tvInput setFont:kFontLarge];
    [_tvInput setReturnKeyType:UIReturnKeySend];
    [_tvInput setEnablesReturnKeyAutomatically:YES];
    [_tvInput setDelegate:self];
    [_tvInput.layer setBorderColor:[kColorNewLine CGColor]];
    [_tvInput.layer setBorderWidth:kLinePixel];
    [_tvInput.layer setCornerRadius:3.0];
    [_tvInput.layer setMasksToBounds:YES];
    [_vBar addSubview:_tvInput];
    
    _tvInput.hidden = YES;
    _btnVoice.hidden = YES;
    
    UIView *hLineT = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, _vBar.width, kLinePixel) color:kColorNewLine];
    
    UIView *hLineB = [[UIView alloc] initLineWithFrame:CGRectMake(0, InputBoxBarHeight - kLinePixel, _vBar.width, kLinePixel) color:kColorNewLine];
    [_vBar addSubview:hLineT];
    [_vBar addSubview:hLineB];
    
    [_tvInput setEditable:NO];
    [_btnBubble setEnabled:NO];
    [_btnMore setEnabled:NO];
}

- (void)createPanelView{
    
    //常用语 Panel
    NSArray *arrPhrase = nil;
    if ([AMCacheManage currentUserType] == UserStyleBusiness) {
        arrPhrase =  @[@"你好，车还在的，随时欢迎看车。", @"价格您过来看车，咱们好商量。"];
    }
    else{
        arrPhrase =  @[@"您好，车还在么？", @"车在哪里？", @"价格还能聊么？", @"您是二手车之家的保障金商家么？"];
    }
    
    _panelPhrase = [[InputPhrasePanel alloc] initWithFrame:_vPanel.bounds listArray:arrPhrase];
    _panelPhrase.delegate = self;
    [_vPanel addSubview:_panelPhrase];
    
    //更多 Panel
    NSArray *titles = nil;
    NSArray *iconNames = nil;
    if ([AMCacheManage currentUserType] == UserStyleBusiness) {
        iconNames = @[@"consultation_add_picture", @"consultation_add_camera",@"consultation_add_car",@"consultation_add_other",@"consultation_add_address"];
        titles = @[@"图片",@"拍照",@"本车照片",@"推荐其他",@"店铺位置"];
    }
    else{
        iconNames = @[@"consultation_add_picture", @"consultation_add_camera",@"consultation_add_car"];
        titles = @[@"图片",@"拍照",@"本车照片"];
    }
    _panelMore = [[InputMorePanel alloc] initWithFrame:_vPanel.bounds iconNameArray:iconNames titleArray:titles];
    [_vPanel addSubview:_panelMore];
    
    _panelPhrase.hidden = YES;
    _panelMore.hidden = YES;
}

#pragma mark - 设置输入条的状态
- (void)setInputMode:(InputBoxMode)inputMode{
    _inputMode = inputMode;
    
    switch (_inputMode) {
        case InputBoxModeKeyboard:
        {
            [IMCacheManage setCurrentInputboxMode:_inputMode];
            [_btnMic setImage:_iconMic forState:UIControlStateNormal];
            [_btnMic setImage:_iconMicPress forState:UIControlStateSelected];
            [_btnMic setImage:_iconMicPress forState:UIControlStateHighlighted];
            
            [_btnBubble setImage:_iconBubble forState:UIControlStateNormal];
            [_btnBubble setImage:_iconBubblePress forState:UIControlStateSelected];
            [_btnBubble setImage:_iconBubblePress forState:UIControlStateHighlighted];
            
            _tvInput.hidden = NO;
            _btnVoice.hidden = YES;
            
            [_tvInput becomeFirstResponder];
            
            _panelPhrase.hidden = YES;
            _panelMore.hidden = YES;
            
        }
            break;
        case InputBoxModeVoice:
        {
            [IMCacheManage setCurrentInputboxMode:_inputMode];
            [_btnMic setImage:_iconKeyboard forState:UIControlStateNormal];
            [_btnMic setImage:_iconKeyboardPress forState:UIControlStateSelected];
            [_btnMic setImage:_iconKeyboardPress forState:UIControlStateHighlighted];
            
            [_btnBubble setImage:_iconBubble forState:UIControlStateNormal];
            [_btnBubble setImage:_iconBubblePress forState:UIControlStateSelected];
            [_btnBubble setImage:_iconBubblePress forState:UIControlStateHighlighted];
            
            
            if(_tvInput.isFirstResponder){
                [_tvInput resignFirstResponder];
            }
            else{
                
                if ([_delegate respondsToSelector:@selector(ChatInputBarView:frameDidChanged:)]) {
                    [_delegate ChatInputBarView:self frameDidChanged:inputBarRect];
                }
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration:0.25];
                [self setFrame:inputBarRect];
                [UIView commitAnimations];
            }
            
            _tvInput.hidden = YES;
            _btnVoice.hidden = NO;
            _panelPhrase.hidden = YES;
            _panelMore.hidden = YES;
        }
            break;
        case InputBoxModePhrase:
        {
            [_btnMic setImage:_iconMic forState:UIControlStateNormal];
            [_btnMic setImage:_iconMicPress forState:UIControlStateSelected];
            [_btnMic setImage:_iconMicPress forState:UIControlStateHighlighted];
            
            [_btnBubble setImage:_iconKeyboard forState:UIControlStateNormal];
            [_btnBubble setImage:_iconKeyboardPress forState:UIControlStateSelected];
            [_btnBubble setImage:_iconKeyboardPress forState:UIControlStateHighlighted];
            
            if(_tvInput.isFirstResponder){
                [_tvInput resignFirstResponder];
            }
            else{
                CGRect viewFrame = self.frame;
                viewFrame.origin.y = inputBarRect.origin.y - InputBoxPanelHeight;

                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration:0.25];
                
                [self setFrame:viewFrame];
                
                [UIView commitAnimations];
                
                if ([_delegate respondsToSelector:@selector(ChatInputBarView:frameDidChanged:)]) {
                    [_delegate ChatInputBarView:self frameDidChanged:viewFrame];
                }
            }
            
            _tvInput.hidden = NO;
            _btnVoice.hidden = YES;
            _panelPhrase.hidden = NO;
            _panelMore.hidden = YES;
            
        }
            break;
        case InputBoxModeMore:
        {
            [_btnBubble setImage:_iconBubble forState:UIControlStateNormal];
            [_btnBubble setImage:_iconBubblePress forState:UIControlStateSelected];
            [_btnBubble setImage:_iconBubblePress forState:UIControlStateHighlighted];
            
            _panelPhrase.hidden = YES;
            _panelMore.hidden = NO;
            
            if(_tvInput.isFirstResponder){
                [_tvInput resignFirstResponder];
            }
            else{
                CGRect viewFrame = self.frame;
                viewFrame.origin.y = inputBarRect.origin.y - InputBoxPanelHeight;
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration:0.25];
                
                [self setFrame:viewFrame];
                
                [UIView commitAnimations];
                
                if ([_delegate respondsToSelector:@selector(ChatInputBarView:frameDidChanged:)]) {
                    [_delegate ChatInputBarView:self frameDidChanged:viewFrame];
                }
                
            }
        }
            break;
        default:
            break;
    }
    
    _isInEditing = YES;
}

#pragma mark - Button click actions
- (void)onClickBtnMic:(UIButton *)button{
    if (_inputMode != InputBoxModeVoice) {
        [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_Voice];
        [self setInputMode:InputBoxModeVoice];
    }
    else{
        [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_Text];
        [self setInputMode:InputBoxModeKeyboard];
    }
}

- (void)onClickBtnBubble:(UIButton *)button{
    if (_inputMode != InputBoxModePhrase) {
        [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_Common];
        [self setInputMode:InputBoxModePhrase];
    }
    else{
        [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_Text];
        [self setInputMode:InputBoxModeKeyboard];
    }
    
}

- (void)onClickBtnMore:(UIButton *)button{
    [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_More];
    [self setInputMode:InputBoxModeMore];
}


#pragma mark - Voice Button Actions
- (void)voiceButtonTouchDown:(UIButton *)button{
    
}

- (void)voiceButtonTouchUpInside:(UIButton *)button{
    
}

- (void)voiceButtonDragExit:(UIButton *)button{
    
}

#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    AMLog(@"\ntext UTF8String %s", [text UTF8String]);
    
    if (text.length != 0 && [text characterAtIndex:0] == 10) {
//        AMLog(@"\n[text characterAtIndex:0] %d %d", text.length, [text characterAtIndex:0]);
//        [self endEditting];
        // 这里做发送操作
        if (textView.text.length > 0 && [_delegate respondsToSelector:@selector(ChatInputBarView:sendText:)]) {
            [_delegate ChatInputBarView:self sendText:textView.text];
        }
        [textView setText:@""];
        return NO;
    }
    else{
        return YES;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [self setInputMode:InputBoxModeKeyboard];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    
}

- (void)setInputBoxEnabled:(BOOL)enabled{
    if (enabled) {
        [_tvInput setEditable:YES];
        [_btnBubble setEnabled:YES];
        [_btnMore setEnabled:YES];
        [self setInputMode:[IMCacheManage currentInputBoxMode]];
    }
    else{
        [_tvInput setEditable:NO];
        [_btnBubble setEnabled:NO];
        [_btnMore setEnabled:NO];
    }
}


- (void)endEditting{
    
    if (_tvInput.isFirstResponder) {
        [_tvInput resignFirstResponder];
    }
    else{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.25];
        [self setFrame:inputBarRect];
        [UIView commitAnimations];
        
        if ([_delegate respondsToSelector:@selector(ChatInputBarView:frameDidChanged:)]) {
            [_delegate ChatInputBarView:self frameDidChanged:inputBarRect];
        }
    }
    _isInEditing = NO;
}


#pragma mark - InputPhrasePanelDelegate
- (void)InputPhrasePanel:(InputPhrasePanel *)panel didSelectPhrase:(NSString *)phraseString{
    if ([_delegate respondsToSelector:@selector(ChatInputBarView:didSelectPhrase:)]) {
        [_delegate ChatInputBarView:self didSelectPhrase:phraseString];
    }
    [self setInputMode:InputBoxModeKeyboard];
}

#pragma mark - keyboard notification

- (void)keyboardWillHide:(NSNotification*)notification{
    //    CGRect keyboardRect = [self convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    CGRect viewFrame = self.frame;
    if (_inputMode == InputBoxModePhrase || _inputMode == InputBoxModeMore) {
        viewFrame.origin.y = inputBarRect.origin.y - InputBoxPanelHeight;
    }
    else{
        viewFrame = inputBarRect;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    [self setFrame:viewFrame];

    [UIView commitAnimations];
    
    if ([_delegate respondsToSelector:@selector(ChatInputBarView:frameDidChanged:)]) {
        [_delegate ChatInputBarView:self frameDidChanged:viewFrame];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification*)notification{
    CGRect keyboardRect = [self convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    CGFloat keyboardHeight = keyboardRect.size.height;
    CGRect viewFrame = self.frame;
    viewFrame.origin.y = inputBarRect.origin.y - keyboardHeight;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    [self setFrame:viewFrame];
    
    [UIView commitAnimations];
    if ([_delegate respondsToSelector:@selector(ChatInputBarView:frameDidChanged:)]) {
        [_delegate ChatInputBarView:self frameDidChanged:viewFrame];
    }
}





#pragma mark - dealloc
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




@end
