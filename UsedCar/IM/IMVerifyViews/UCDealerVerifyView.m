//
//  UCDealerVerifyView.m
//  UsedCar
//
//  Created by 张鑫 on 14/11/18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCDealerVerifyView.h"
#import "UCTopBar.h"
#import "UserInfoModel.h"
#import "AMCacheManage.h"
#import "UIImage+Util.h"
#import "NSString+Util.h"
#import "APIHelper.h"
#import "UCInputCodeView.h"

#define kCellHeight             46

@interface UCDealerVerifyView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UITableView *tvSalesPeople;
@property (nonatomic, strong) UIButton *btnSendCode;
@property (nonatomic, strong) NSMutableArray *salesData;
@property (nonatomic, strong) UIImageView *ivSelected;
@property (nonatomic, strong) APIHelper *apiCode;
@property (nonatomic, strong) SalesPersonModel *mSalesPerson;

@end


@implementation UCDealerVerifyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [UMStatistics event:pv_4_3_IM_Saler_Indentify];
        [UMSAgent postEvent:buycar_chat_verify_shop_pv page_name:NSStringFromClass(self.class)];
        
        [self initView];
    }
    return self;
}

-(APIHelper *)apiCode
{
    if (!_apiCode) {
        _apiCode = [[APIHelper alloc] init];
    }
    return _apiCode;
}

-(NSMutableArray *)salesData
{
    if (!_salesData) {
        _salesData = [[NSMutableArray alloc] init];
        _salesData = [AMCacheManage currentUserInfo].salespersonlist;
    }
    return _salesData;
}

-(UIImageView *)ivSelected
{
    if (!_ivSelected) {
        UIImage *iSelected = [UIImage imageNamed:@"radio"];
        _ivSelected = [[UIImageView alloc] initWithImage:iSelected];
        [self.tvSalesPeople addSubview:_ivSelected];
        _ivSelected.hidden = YES;
    }
    return _ivSelected;
}

- (void)initView{
    
    self.backgroundColor =  kColorNewBackground;
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    
    // 选择手机号
    UIView *vSalesPeople = [self creatSalesPeople:CGRectMake(0, _tbTop.maxY, self.width, 0)];
    
    // 发送验证码
    UIView *vCode = [self creatCodeView:CGRectMake(0, vSalesPeople.maxY, self.width, 115)];
    
    [self addSubview:vSalesPeople];
    [self addSubview:vCode];
    
    // 无销售代表提示
    if (self.salesData.count == 0) {
        UIAlertView *avAlert = [[UIAlertView alloc] initWithTitle:@"请先添加销售代表" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [avAlert show];
    }
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"开通在线咨询" forState:UIControlStateNormal];
    [vTopBar.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

- (UIView *)creatSalesPeople:(CGRect)frame
{
    UIView *vSalesPeople = [[UIView alloc] initWithFrame:frame];
    
    UILabel *labTitle = [[UILabel alloc] init];
    labTitle.textColor = kColorNewGray1;
    labTitle.text = @"选择你的手机号码";
    labTitle.backgroundColor = kColorClear;
    labTitle.font = kFontLarge;
    [labTitle sizeToFit];
    
    labTitle.origin = CGPointMake(10, 20);
    
    CGFloat maxHeight = self.height - _tbTop.height - (labTitle.height + 20 + 10) - 115;
    CGFloat heithtBySalesCount = self.salesData.count * kCellHeight;
    
    self.tvSalesPeople = [[UITableView alloc] initWithFrame:CGRectMake(0, labTitle.maxY + 10, self.width, heithtBySalesCount > maxHeight ? maxHeight : heithtBySalesCount)];
    self.tvSalesPeople.delegate = self;
    self.tvSalesPeople.dataSource = self;
    [self.tvSalesPeople setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [vSalesPeople addSubview:labTitle];
    [vSalesPeople addSubview:self.tvSalesPeople];
    
    vSalesPeople.height = self.tvSalesPeople.maxY;
    
    [vSalesPeople addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, self.tvSalesPeople.minY, vSalesPeople.width, kLinePixel) color:kColorNewLine]];
    
    return vSalesPeople;
}

- (UIView *)creatCodeView:(CGRect)frame
{
    UIView *vCode = [[UIView alloc] initWithFrame:frame];
    
    _btnSendCode = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, frame.size.width - 10 * 2, 44)];
    _btnSendCode.backgroundColor = kColorBlue;
    [_btnSendCode setBackgroundImage:[UIImage imageWithColor:kColorBlueD size:_btnSendCode.size] forState:UIControlStateDisabled];
    [_btnSendCode setTitle:@"发送验证码" forState:UIControlStateNormal];
    _btnSendCode.titleLabel.font = kFontLarge1;
    _btnSendCode.layer.masksToBounds = YES;
    _btnSendCode.layer.cornerRadius = 3;
    _btnSendCode.enabled = NO;
    [_btnSendCode addTarget:self action:@selector(onClickSendCodeBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *labText = [[UILabel alloc] init];
    labText.font = kFontSmall;
    labText.textColor = kColorNewGray2;
    labText.text = @"验证手机后，您的手机会收到买家的咨询";
    labText.backgroundColor = kColorClear;
    [labText sizeToFit];
    labText.origin = CGPointMake(10, _btnSendCode.maxY + 20);
    
    [vCode addSubview:_btnSendCode];
    [vCode addSubview:labText];
    
    return vCode;
}

- (void)verifyDealerIM:(RegisterDealerIM)block
{
    self.blockDealer = block;
}

#pragma mark - button actions
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveAuto];
}

/** 发送验证码 */
- (void)onClickSendCodeBtn:(UIButton *)btn
{
    [UMStatistics event:c_4_3_IM_Saler_Indentify_GetCode];
    [self getCodeAPI:self.mSalesPerson.salesphone];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.ivSelected.hidden = NO;
    self.ivSelected.origin = CGPointMake(tableView.width - self.ivSelected.width - 15, cell.minY + (kCellHeight - self.ivSelected.height) / 2);
    _btnSendCode.enabled = YES;
    self.mSalesPerson = [self.salesData objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *Identifier = @"UCDealerVerifyCell";
    
    UCDealerVerifyCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
        cell = [[UCDealerVerifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier cellWidth:tableView.width];
    
    SalesPersonModel *mSalesPerson = [self.salesData objectAtIndex:indexPath.row];
    [cell makeCell:mSalesPerson];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.salesData.count;
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveAuto];
}

#pragma mark - UCInputCodeViewDelegate
-(void)didVerifyDealerSuccessed:(UCInputCodeView *)vInputCode
{
    if (self.blockDealer) {
        self.blockDealer(self, YES, nil);
        self.blockDealer = nil;
    }
}

#pragma mark - APIHelper
/** 验证码 */
- (void)getCodeAPI:(NSString *)mobile
{
    if (self.apiCode.isConnecting) {
        [self.apiCode cancel];
    }
    
    [[AMToastView toastView] showLoading:@"验证码获取中..." cancel:^{
        [self.apiCode cancel];
        [[AMToastView toastView] hide];
    }];
    
    __weak UCDealerVerifyView *vSelf = self;
    [self.apiCode setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    [[AMToastView toastView] hide];
                    vSelf.vInputCode = [[UCInputCodeView alloc] initWithFrame:vSelf.bounds salesPersonModel:vSelf.mSalesPerson];
                    vSelf.vInputCode.delegate = vSelf;
                    [[MainViewController sharedVCMain] openView:vSelf.vInputCode animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
                }
                else {
                    if (mBase.message) {
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                    } else {
                        [[AMToastView toastView] hide];
                    }
                }
            } else {
                [[AMToastView toastView] showMessage:@"获取验证码失败，请重试" icon:kImageRequestError duration:AMToastDurationNormal];
            }
        } else {
            [[AMToastView toastView] showMessage:@"获取验证码失败，请重试" icon:kImageRequestError duration:AMToastDurationNormal];
        }
    }];
    [self.apiCode getVerifyCode:mobile type:[NSNumber numberWithInteger:4]];
    
}

@end

@interface UCDealerVerifyCell () {
    UILabel *labName;
    UILabel *labPhone;
}

@end

@implementation UCDealerVerifyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.width = self.contentView.width = cellWidth;
        
        labName = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 90, kCellHeight)];
        labName.font = kFontLarge;
        labName.textColor = kColorNewGray1;
        labName.numberOfLines = 1;
        labName.backgroundColor = kColorClear;
        
        labPhone = [[UILabel alloc] initWithFrame:CGRectMake(labName.maxX + 15, labName.minY, 150, kCellHeight)];
        labPhone.font = labName.font;
        labPhone.textColor =labName.textColor;
        labPhone.backgroundColor = kColorClear;
        
        [self.contentView addSubview:labName];
        [self.contentView addSubview:labPhone];
    }
    return self;
}

- (void)makeCell:(SalesPersonModel *)mSales
{
    
    labName.text = [mSales.salesname omitForSize:CGSizeMake(88, kCellHeight) font:labName.font];
    labPhone.text = mSales.salesphone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted)
        self.contentView.backgroundColor = kColorNewLine;
    else
        self.contentView.backgroundColor = kColorWhite;
}

@end
