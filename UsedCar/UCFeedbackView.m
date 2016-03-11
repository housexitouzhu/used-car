//
//  UCFeedbackView.m
//  UsedCar
//
//  Created by wangfaquan on 13-12-6.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCFeedbackView.h"
#import "MainViewController.h"
#import "UIImage+Util.h"
#import "UCTopBar.h"
@interface UCFeedbackView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UIButton *btnTitle;

@end

#define Font [UIFont systemFontOfSize:16]
#define StringWidth 200

#define kAlertViewTitleFont             [UIFont boldSystemFontOfSize:20]
#define kAlertViewTitleTextColor        [UIColor colorWithWhite:0 alpha:1.0]
#define kAlertViewTitleShadowColor      [UIColor colorWithWhite:1 alpha:0.5]
#define kAlertViewTitleShadowOffset     CGSizeMake(0, -1)

#define kAlertViewMessageFont           [UIFont systemFontOfSize:18]
#define kAlertViewMessageTextColor      [UIColor colorWithWhite:0 alpha:1.0]
#define kAlertViewMessageShadowColor    [UIColor colorWithWhite:1 alpha:0.5]
#define kAlertViewMessageShadowOffset   CGSizeMake(0, -1)

#define kAlertViewButtonFont            [UIFont boldSystemFontOfSize:18]
#define kAlertViewButtonTextColor       [UIColor whiteColor]
#define kAlertViewButtonShadowColor     [UIColor colorWithWhite:0 alpha:0.3]
#define kAlertViewButtonShadowOffset    CGSizeMake(0, -1)

#define kContactAlerView 45676665

@implementation UCFeedbackView

#pragma mark - initView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置背景颜色
        self.backgroundColor = kColorWhite;
        
        // 导航头
        _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
        [_tbTop.btnTitle setTitle:@"用户反馈" forState:UIControlStateNormal];
        [_tbTop setLetfTitle:@"返回"];
        [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_tbTop];

        //监听键盘
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        //设置无最新消息
        NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
        [userDefult setBool:NO forKey:@"feedback"];
        [userDefult synchronize];
        
        //友盟反馈
        _feedback = [UMFeedback sharedInstance];
        [_feedback setAppkey:UM_APP_KEY delegate:self];
        [self getData];
        
        //设置选项内容
        self.ageArray = [NSArray arrayWithObjects:@"小于18岁", @"18～24岁", @"25～30岁", @"31～35岁",@"36～40岁", @"41～50岁", @"51～59岁", @"大于60岁", nil];
        self.genderArray = [NSArray arrayWithObjects: @"女", @"男", nil];
        self.ageIndex = 1;
        self.gander = 0;
        
        //选项卡
        _selectBar = [[UIView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, 42.5)];
        _selectBar.backgroundColor = kColorGrey5;
        [self addSubview:_selectBar];
        
        //创建选项按钮
        int x = 0;
        for (int i = 0; i < 3; i++) {
            
            UIImage *imgArrow = [UIImage imageNamed:@"user_arrow_below"];
    
            UIButton *btnSelect = [[UIButton alloc] initWithFrame:CGRectMake(x, (_selectBar.height - 40)*0.5-1.5, self.width/3, 42)];
            
            [btnSelect setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:CGSizeMake(91, 80)] forState:1];
            [btnSelect setImage:imgArrow forState:0];
            [btnSelect setTitleColor:kColorBlue1 forState:0];
            [btnSelect setTitleShadowColor:kColorWhite forState:0];
            btnSelect.titleLabel.shadowOffset = CGSizeMake(1, 1);
            btnSelect.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            if (i == 0)
                [btnSelect setTitle:@" 选择性别 " forState:0];
            else if (i == 1)
                [btnSelect setTitle:@" 选择年龄 " forState:0];
            else
                [btnSelect setTitle:@"   联系方式 " forState:0];
            btnSelect.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btnSelect.titleEdgeInsets = UIEdgeInsetsMake(0, (btnSelect.width - btnSelect.imageView.width - [btnSelect.titleLabel.text sizeWithFont:btnSelect.titleLabel.font].width) / 2, 0, 0);
            btnSelect.imageEdgeInsets = UIEdgeInsetsMake(btnSelect.height - btnSelect.imageView.height, btnSelect.width - btnSelect.imageView.width, 0, 0);
            
            [btnSelect addTarget:self action:@selector(showSelectView:) forControlEvents:UIControlEventTouchUpInside];
            btnSelect.tag = 100+i;
            
            //添加选择框分割线
            [_selectBar addSubview:btnSelect];
            UIView *vSelectBtnLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, kLinePixel,btnSelect.height) color:kColorNewLine];
            [btnSelect addSubview:vSelectBtnLine];

            x += _selectBar.width / 3;
            
        }
        
        //添加分割线
        UIView * labelLine=[[UIView alloc] initLineWithFrame:CGRectMake(0, _selectBar.height-1, self.width, kLinePixel) color:kColorNewLine];
        [_selectBar addSubview:labelLine];
        
        UIImage *imgSend = [UIImage imageNamed:@"bg_feedback_btn_send"];
        // 反馈条
        _bottomBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, imgSend.size.height + 10)];
        _bottomBar.userInteractionEnabled = YES;
        _bottomBar.backgroundColor = kColorGrey5;
        _bottomBar.maxY = self.height;
        _bottomBar.layer.shadowColor = kColorGray1.CGColor;
        _bottomBar.layer.shadowOffset = CGSizeMake(0, 0);
        UIView *view = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine];
        [_bottomBar addSubview:view];
        [self addSubview:_bottomBar];
        
        // 发送按钮
        _btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnSend.frame = CGRectMake(self.width-imgSend.size.width-5, 5, imgSend.size.width, imgSend.size.height);
        [_btnSend setTitle:@"发送" forState:0];
        _btnSend.titleLabel.font = [UIFont systemFontOfSize:16];
        [_btnSend setTitleColor:kColorBlue1 forState:UIControlStateNormal];
        
        [_btnSend setTitleColor:kColorBlue3 forState:UIControlStateHighlighted];
        [_btnSend addTarget:self action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
        _btnSend.enabled = NO;
        [_bottomBar addSubview:_btnSend];
        
        // 反馈输入框
        _tvFeedbackText = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, _btnSend.minX-10, _btnSend.height)];
        _tvFeedbackText.delegate = self;
        _tvFeedbackText.layer.masksToBounds = YES;
        _tvFeedbackText.font = Font;
        _tvFeedbackText.layer.borderWidth =1.0;
        [[_tvFeedbackText layer] setCornerRadius:5];
        [[_tvFeedbackText layer] setBorderWidth:1];
        [[_tvFeedbackText layer] setBorderColor:kColorGrey5.CGColor];
        [_bottomBar addSubview:_tvFeedbackText];
        // 反馈内容tableView
        _tvFeedback = [[UITableView alloc] initWithFrame:CGRectMake(0, _selectBar.maxY, self.width, self.height-_tbTop.height - _bottomBar.height - _selectBar.height)];
        _tvFeedback.delegate = self;
        _tvFeedback.dataSource = self;
        _tvFeedback.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tvFeedback.backgroundColor = [UIColor clearColor];
        _tvFeedback.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
        [self addSubview:_tvFeedback];
        
        UIControl *vRecoverBack = [[UIControl alloc] initWithFrame:_tvFeedback.bounds];
        [vRecoverBack addTarget:self action:@selector(tapCloseKeybroad) forControlEvents:UIControlEventTouchUpInside];
        vRecoverBack.backgroundColor = [UIColor clearColor];
        [_tvFeedback addSubview:vRecoverBack];
        
        //滑动到底部
        [self scrollToBottomAnimated:NO];
        
        [self bringSubviewToFront:_selectBar];
        [self bringSubviewToFront:_tbTop];
        [self bringSubviewToFront:_bottomBar];
        
        //选择框，类似pickeView
        _ivSelect = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.height, self.width, 100)];
        _ivSelect.backgroundColor = kColorGrey5;
        _ivSelect.userInteractionEnabled = YES;
        [self addSubview:_ivSelect];
        
        _selectorView = [[UISelectorView alloc] initWithFrame:CGRectMake(0, 10, _ivSelect.width, _ivSelect.height-10)];
        _selectorView.delegate = self;
        [_ivSelect addSubview:_selectorView];
        _selectorView.colorSelector = kColorBlue1;
        
        //友盟反馈
        [_feedback get];
    }
    
    return self;
}

- (void)getData
{
    self.dataArray = _feedback.topicAndReplies;
    
    NSDictionary *dic = nil;
    if (self.dataArray.count != 0)
        dic = [self.dataArray objectAtIndex:0];
    
    if (!dic || [[dic objectForKey:@"datetime"] length] != 0) {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        [tempDic setObject:@"dev_reply" forKey:@"type"];
        [tempDic setObject:@"请留下您宝贵的意见或建议，我们将及时回复" forKey:@"content"];
        [tempDic setObject:@"" forKey:@"datetime"];
        [self.dataArray insertObject:tempDic atIndex:0];
    }
}

- (void)postFinishedWithError:(NSError *)error
{
    _btnSend.enabled = YES;
    
    if (!error) {
        _tvFeedbackText.text = @"";
        [_feedback get];
        
        UIImage *imgSend = [UIImage imageNamed:@"bg_feedback_btn_send"];
        
        [UIView animateWithDuration:0.25 animations:^{
            CGFloat height = imgSend.size.height + 10;
            //_bottomBar.maxY = _keyboardY;
            _bottomBar.frame = CGRectMake(_bottomBar.minX, _keyboardY-height, _bottomBar.width, height);
            _tvFeedbackText.height = imgSend.size.height;
            _btnSend.minY = 5;
            
            self.tvFeedback.height = _bottomBar.minY - _selectBar.maxY;
        }];
        
        [self endEditing:YES];
    }
    else
        [[AMToastView toastView] showMessage:@"发送失败" icon:kImageRequestError duration:AMToastDurationNormal];
}

- (void)scrollToBottomAnimated:(BOOL)animate {
    if ([self.tvFeedback numberOfRowsInSection:0] > 1) {
        int lastRowNumber = [self.tvFeedback numberOfRowsInSection:0] - 1;
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [self.tvFeedback scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animate];
    }
}

#pragma mark - Private methods

- (void)sendFeedback:(UIButton *)bt
{
    if ([_tvFeedbackText hasText]) {
        bt.enabled = NO;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:_tvFeedbackText.text forKey:@"content"];
        [dictionary setObject:@"user_reply" forKey:@"type"];
        [dictionary setObject:timeStr forKey:@"datetime"];
        
        if (self.ageIndex >= 0)
            [dictionary setObject:[NSString stringWithFormat:@"%d", self.ageIndex] forKey:@"age_group"];
        
        if (self.gander >= 0)
            [dictionary setObject:[NSString stringWithFormat:@"%d", self.gander] forKey:@"gender"];
        
        if (self.contact.length > 0) {
            NSDictionary *contact = [NSDictionary dictionaryWithObject:self.contact forKey:@"email"];
            [dictionary setObject:contact forKey:@"contact"];
        }
        
        [_feedback post:dictionary];
    }
}

/* 收回选择框 */
-(void)tapCloseKeybroad{
    if (_isShowSelector)
        [UIView animateWithDuration:0.2 animations:^{
            _ivSelect.minY = self.height;
            _isShowSelector = NO;
        }];
    
    if (_tvFeedbackText.isFirstResponder == YES) {
        [_tvFeedbackText resignFirstResponder];
    }
    
}

//显示底部的选择框 类似pickerView
- (void)showSelectView:(UIButton *)btn
{
    [self endEditing:YES];
    
    if (btn.tag != 102) {
        _selectorView.tag = btn.tag;
        if (btn.tag == 100) {
            _selectorView.dataSource = [NSMutableArray arrayWithObjects:self.genderArray, nil];
            [_selectorView selectRow:self.gander inComponent:0 animated:NO];
        } else {
            _selectorView.dataSource = [NSMutableArray arrayWithObjects:self.ageArray, nil];
            [_selectorView selectRow:self.ageIndex - 1 inComponent:0 animated:NO];
        }
        
        if (!_isShowSelector) {
            [UIView animateWithDuration:0.2 animations:^{
                _ivSelect.maxY = self.height;
            }];
            _isShowSelector = YES;
        }
    }
    else {
        if (_isShowSelector) {
            [UIView animateWithDuration:0.3 animations:^{
                _ivSelect.minY = self.height;
            }];
            _isShowSelector = NO;
        }
        
        [self switchContactView];
        
    }
}

/* 联系方式view */
- (void)switchContactView
{
    _isShowContactView = !_isShowContactView;
    
    UIView *vContact = nil;
    
    if (_isShowContactView) {
        // 初始化
        vContact = [[UIView alloc] initWithFrame:self.bounds];
        vContact.tag = 45634325;
        vContact.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        vContact.alpha = 0.0;
        
        // 提示框
        UIView *vAlert = [[UIView alloc] initWithFrame:CGRectMake((self.width - 284) / 2, (self.height - 132) / 2, 284, 132)];
        vAlert.tag = kContactAlerView;
        vAlert.backgroundColor = kColorGrey5;
        vAlert.layer.cornerRadius = 5.0;
        vAlert.layer.masksToBounds = YES;
        
        // 标题
        UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 170, 27)];
        labTitle.text = @"请留下您的联系方式";
        labTitle.backgroundColor = [UIColor clearColor];
        
        // 输入框
        UITextField *tfContact = [[UITextField alloc] initWithFrame:CGRectMake(labTitle.minX, labTitle.maxY + 8, vAlert.width - 20, 32)];
        tfContact.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 10)];
        tfContact.leftViewMode = UITextFieldViewModeAlways;
        tfContact.placeholder = @"电话/QQ/电子邮箱";
        tfContact.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tfContact.tag = 0xAAA;
        tfContact.font = [UIFont systemFontOfSize:16];
        tfContact.delegate = self;
        tfContact.layer.cornerRadius = 5;
        tfContact.layer.borderWidth = 1;
        tfContact.layer.borderColor = kColorGrey3.CGColor;
        tfContact.textAlignment = UITextAlignmentLeft;
        
        // 取消按钮
        for (int i = 0; i < 2; i++) {
            UIButton *btnAlert = [[UIButton alloc] initWithFrame:CGRectMake((11 * (i+1) + i * 125), vAlert.height - 37 - 9, 125, 37)];
            UIImage *image = [[UIImage imageNamed:@"bg_popup_btn"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            UIImage *imageH = [[UIImage imageNamed:@"bg_popup_btn_h"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            
            image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width+1)>>1 topCapHeight:0];
            imageH = [imageH stretchableImageWithLeftCapWidth:(int)(imageH.size.width+1)>>1 topCapHeight:0];
            if (i == 0)
                [btnAlert setTitle:@"取消" forState:UIControlStateNormal];
            else
                [btnAlert setTitle:@"确定" forState:UIControlStateNormal];
            btnAlert.tag = i;
            btnAlert.titleLabel.font = kAlertViewButtonFont;
            btnAlert.titleLabel.textAlignment = NSTextAlignmentCenter;
            btnAlert.titleLabel.shadowOffset = CGSizeMake(0, 0);
            btnAlert.backgroundColor = [UIColor clearColor];
            btnAlert.layer.cornerRadius = 3;
            btnAlert.layer.masksToBounds = YES;
            [btnAlert addTarget:self action:@selector(onClickedButtonAtIndex:) forControlEvents:UIControlEventTouchUpInside];
            [btnAlert setBackgroundImage:image forState:UIControlStateNormal];
            [btnAlert setBackgroundImage:imageH forState:UIControlStateHighlighted];
            [btnAlert setTitleColor:kAlertViewButtonTextColor forState:UIControlStateNormal];
            [btnAlert setTitleShadowColor:kAlertViewButtonShadowColor forState:UIControlStateNormal];
            [vAlert addSubview:btnAlert];
        }
        
        // 关闭当前页
        UIControl *vBack = [[UIControl alloc] initWithFrame:vContact.bounds];
        [vBack addTarget:self action:@selector(tapCloseContactView) forControlEvents:UIControlEventTouchUpInside];
        
        [vContact addSubview:vBack];
        [vAlert addSubview:labTitle];
        [vAlert addSubview:tfContact];
        [vContact addSubview:vAlert];
        [self addSubview:vContact];
    }
    else
        vContact = (UIView *)[self viewWithTag:45634325];
    
    [UIView animateWithDuration:kAnimateSpeedFast animations:^{
        vContact.alpha = _isShowContactView == YES ? 1.0 :0.0;
    } completion:^(BOOL finished) {
        if (!_isShowContactView)
            [vContact removeFromSuperview];
    }];
    
}

/* 关闭alertView */
-(void)tapCloseContactView
{
    [self switchContactView];
}

#pragma mark - Keyboard Methods
//显示键盘
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRect = [self keyboardRect: notification];
    _keyboardY = self.height - keyboardRect.size.height;
    
    if ([_tvFeedbackText isFirstResponder]) {
        [UIView animateWithDuration: 0.25 animations:^{
            _bottomBar.maxY = self.height - keyboardRect.size.height;
        }];
        
        self.tvFeedback.height = _bottomBar.minY - _selectBar.maxY;
        [self scrollToBottomAnimated:YES];
    }
    
    // 移动联系方式提示框
    UITextField *tfAlert = (UITextField *)[self viewWithTag:0xAAA];
    if ([tfAlert isFirstResponder]) {
        [UIView animateWithDuration: 0.25 animations:^{
            UIView *vContactAler = (UIView *)[self viewWithTag:kContactAlerView];
            vContactAler.maxY = self.height - keyboardRect.size.height - 2;
        }];
    }
}
//关闭键盘
- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([_tvFeedbackText isFirstResponder]) {
        [UIView animateWithDuration: 0.25 animations:^{
            _bottomBar.maxY = self.height;
            self.tvFeedback.height = _bottomBar.minY - _selectBar.maxY;
        }];
    }
    
    _keyboardY = self.height;
}

- (CGRect)keyboardRect:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    return [value CGRectValue];
}

#pragma mark onClickBtn
//关闭页面
- (void)onClickTopBar:(UIButton *)btn
{
    if (_isShowSelector)
        [UIView animateWithDuration:0.2 animations:^{
            _ivSelect.minY = self.height;
            _isShowSelector = NO;
        }];
    _feedback.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    
}

#pragma mark - UMFeedbackDataDelegate
- (void)getFinishedWithError:(NSError *)error
{
    if (!error) {
        [self getData];
        [self.tvFeedback reloadData];
        [self scrollToBottomAnimated:NO];
    }
}

/* "取消" or "确定" 按钮 */
- (void)onClickedButtonAtIndex:(UIButton *)button
{
    // 确定退出
    if (button.tag == 1) {
        UITextField *tfContact = (UITextField *)[self viewWithTag:0xAAA];
        self.contact = tfContact.text;
        UIButton *btnPhone = (UIButton *)[self viewWithTag:102];
        btnPhone.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [btnPhone setTitle:[tfContact.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forState:UIControlStateNormal];
        if ([tfContact.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 || tfContact.text.length == 0)
            [btnPhone setTitle:@"  联系方式" forState:UIControlStateNormal];
        btnPhone.titleEdgeInsets = UIEdgeInsetsMake(0, (btnPhone.width - btnPhone.imageView.width - [btnPhone.titleLabel.text sizeWithFont:btnPhone.titleLabel.font].width) / 2, 0, 0);
    }
    [self switchContactView];
}

#pragma mark - UISelectorViewDelegate
- (void)selectorView:(UISelectorView *)selectorView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UIButton *btnSelect = (UIButton *)[_selectBar viewWithTag:selectorView.tag];
    if (selectorView.tag == 100) {
        self.gander = row;
        [btnSelect setTitle:[self.genderArray objectAtIndex:row] forState:0];
    } else if (selectorView.tag == 101) {
        self.ageIndex = row + 1;
        [btnSelect setTitle:[self.ageArray objectAtIndex:row] forState:0];
    }
    btnSelect.titleEdgeInsets = UIEdgeInsetsMake(0, (btnSelect.width - btnSelect.imageView.width - [btnSelect.titleLabel.text sizeWithFont:btnSelect.titleLabel.font].width) / 2, 0, 0);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Cell";
    
    FeedbackCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[FeedbackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    [cell setNeedsDisplay];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *infoDic = [self.dataArray objectAtIndex:indexPath.row];
    NSString *content = [infoDic objectForKey:@"content"];
    NSString *type = [infoDic objectForKey:@"type"];
    NSString *time = [infoDic objectForKey:@"datetime"];
    if (time.length != 0){
        cell.labTime.text = time;
        cell.labTime.textColor = kColorGrey3;
    }
    else
        cell.labTime.text = @"";
    
    cell.textLabel.text = content;
    cell.textLabel.font = Font;
    
    if ([type isEqualToString:@"dev_reply"])
        cell.isLeft = YES;
    else
        cell.isLeft = NO;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.row];
    NSString *content = [dic objectForKey:@"content"];
    NSString *time = [dic objectForKey:@"datetime"];
    if (time.length != 0)
        return [self stringHeight:content] + 13 + 30;
    
    return [self stringHeight:content] + 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self endEditing:YES];
    
    if (_isShowSelector)
        [UIView animateWithDuration:0.2 animations:^{
            _ivSelect.minY = self.height;
            _isShowSelector = NO;
        }];
}

- (CGFloat)stringHeight:(NSString *)string
{
    CGSize labelSize = [string sizeWithFont:Font
                          constrainedToSize:CGSizeMake(StringWidth, MAXFLOAT)
                              lineBreakMode:NSLineBreakByCharWrapping];
    
    return labelSize.height;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UITableView class]])
        [self endEditing:YES];
    
    if (_isShowSelector)
        [UIView animateWithDuration:0.2 animations:^{
            _ivSelect.minY = self.height;
            _isShowSelector = NO;
        }];
    
    _selectorView.tag = 0;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // 限制字数
    int surplus = 50 - textField.text.length;
    if (string.length > surplus)
        return NO;
    return YES;
}

//计算字符长度
- (int)convertToInt:(NSString*)strtemp
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    int surplus = 255 - textView.text.length;
    if (text.length > surplus) {
        textView.text = [textView.text stringByAppendingString:[text substringToIndex: surplus]];
        [self textViewDidChange:textView];
        return  NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView hasText])
        _btnSend.enabled = YES;
    else
        _btnSend.enabled = NO;
    
    if (textView.contentSize.height > 76.0)
        textView.height = 76.0;
    else
        textView.height = textView.contentSize.height;
    
    _bottomBar.height = textView.height + 10;
    _bottomBar.maxY = _keyboardY;
    
    _btnSend.centerY = _bottomBar.height*0.5;
  
    [textView scrollsToTop];
}

@end

@implementation FeedbackCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UILabel *timeLb = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLb.backgroundColor = [UIColor clearColor];
        timeLb.textAlignment = UITextAlignmentCenter;
        timeLb.font = [UIFont systemFontOfSize:10];
        timeLb.textColor = kColorGrey5;
        self.labTime = timeLb;
        [self.contentView addSubview:timeLb];
        
        UIImageView *ivBg = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.ivBg = ivBg;
        [self.contentView addSubview:ivBg];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.labTime sizeToFit];
    self.labTime.width = self.width;
    
    CGSize labelSize = [self.textLabel.text sizeWithFont:self.textLabel.font
                                       constrainedToSize:CGSizeMake(StringWidth, MAXFLOAT)
                                           lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat width = labelSize.width < StringWidth ? labelSize.width : StringWidth;
    
    if (self.isLeft) {
        UIImage *img = [[UIImage imageNamed:@"bg_feedback_pop1"] stretchableImageWithLeftCapWidth:20 topCapHeight:10];
        
        self.ivBg.image = img;
        self.ivBg.frame = CGRectMake(0, self.labTime.maxY, width + 25, labelSize.height + 20);
        
        self.textLabel.frame = CGRectMake(self.ivBg.minX + 17, self.ivBg.minY + 10, width, labelSize.height);
    }
    else {
        UIImage *img = [[UIImage imageNamed:@"bg_feedback_pop2"] stretchableImageWithLeftCapWidth:15 topCapHeight:10];
        
        self.ivBg.image = img;
        self.ivBg.frame = CGRectMake(0, self.labTime.maxY, width + 25, labelSize.height + 20);
        self.ivBg.maxX = self.width;
        
        self.textLabel.frame = CGRectMake(self.ivBg.minX + 8, self.ivBg.minY + 10, width, labelSize.height);
    }
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.numberOfLines = 0;
}

@end
