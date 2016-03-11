//
//  UCAutonomyAddView.m
//  UsedCar
//
//  Created by wangfaquan on 14-5-13.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCAutonomyAddView.h"
#import "UCTopBar.h"
#import "UISelectorView.h"

#define kCarTitleStarTag            200000
#define KMessageStartTag            100000
#define KlabTag                     500
#define kCarbtnManualTag            100001
#define kCarDisplacementTag         100002
#define midleTag                    400000

@interface UCAutonomyAddView()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UIView *vTransmissionBg;
@property (nonatomic, strong) UIButton *btnMessage;
@property (nonatomic, strong) UITextField *tfDisplacement;
@property (nonatomic, strong) UISelectorView *vSelector;
@property (nonatomic, strong) NSMutableDictionary *dicCarModel;     //返回数据

@end

@implementation UCAutonomyAddView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dicCarModel = [[NSMutableDictionary alloc] init];
        [UMStatistics event:pv_3_6_Selectcar_add];
        [self initView];
    }
    return self;
}

#pragma mark - initView
/** 初始化视图 */
- (void)initView
{
    self.backgroundColor = kColorWhite;
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    // 标题
    [self.tbTop.btnTitle setTitle:@"添加车型" forState:UIControlStateNormal];
    [_tbTop setLetfTitle:@"返回"];
    [self.tbTop.btnRight setTitle:@"确定" forState:UIControlStateNormal];
    [self.tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    [self.tbTop.btnRight addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    UIView * creatTrans = [self creatTransmissionView:CGRectMake(0, _tbTop.maxY, self.width, 200)];
    // 触摸关闭键盘
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(closeKeyboard)];
    singleFingerOne.numberOfTapsRequired = 1;
    singleFingerOne.delegate = self;
    [self addGestureRecognizer:singleFingerOne];
    [self addSubview:creatTrans];
}

/** 创建视图 */
- (UIView *)creatTransmissionView:(CGRect)frame
{
    UIView *creatView = [[UIView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, 200)];
    CGFloat height = 50;
    CGFloat minY = 0;
    
    NSArray *arrText = [[NSArray alloc] initWithObjects:@"车型:", @"变速箱:", @"排  量:", nil];
    for (int i = 0 ; i < 3; i ++) {
        _btnMessage = [[UIButton alloc] initWithFrame:CGRectMake(0, minY, self.width, 50)];
        // 分割线
        _btnMessage.userInteractionEnabled = YES;
        UIView *vLine1 = [[UIView alloc] initLineWithFrame:CGRectMake(15, height + minY, self.width - 10, kLinePixel) color:kColorNewLine];
        [creatView addSubview:vLine1];
        if (i == 0) {
            UITextField *tfContent = [[UITextField alloc] initWithFrame:CGRectMake(5, 9, self.width, 35)];
            tfContent.userInteractionEnabled = YES;
            tfContent.tag = KMessageStartTag;
            tfContent.textAlignment = UITextAlignmentLeft;
            tfContent.font = kFontLarge;
            
            UILabel *labMidel = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, self.width - 40, 35)];
            labMidel.text = @"例如：马自达6 2007款";
            labMidel.font = [UIFont systemFontOfSize:11];
            labMidel.tag = KlabTag;
            labMidel.textColor = kColorGrey3;
            [tfContent addSubview:labMidel];
            // leftView
            UILabel *labLeft = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 8, 75, height)];
            tfContent.leftView = labLeft;
            tfContent.leftViewMode = UITextFieldViewModeAlways;
            tfContent.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            tfContent.delegate = self;
            [tfContent becomeFirstResponder];
            [_btnMessage addSubview:tfContent];
        } else if (i == 1) {
            // 手动挡
            UIButton *btnManual = [[UIButton alloc] initWithFrame:CGRectMake(90, 1, 72, 50)];
            btnManual.tag = 65274570;
            btnManual.selected = NO;
            [btnManual setTitle:@"手动" forState:UIControlStateNormal];
            btnManual.titleLabel.font = [UIFont systemFontOfSize:15];
            [btnManual setTitleColor:kColorGray1 forState:UIControlStateNormal];
            [btnManual addTarget:self action:@selector(onClickTransmissionBtn:) forControlEvents:UIControlEventTouchUpInside];
            [btnManual setImage:[UIImage imageNamed:@"vehicle_circle"] forState:UIControlStateNormal];
            [btnManual setImage:[UIImage imageNamed:@"vehicle_circle_h"] forState:UIControlStateSelected];
            [btnManual setImage:[UIImage imageNamed:@"vehicle_circle_h"] forState:UIControlStateHighlighted];
            btnManual.imageEdgeInsets = UIEdgeInsetsMake(1, -10, 0, 0);
            
            // 自动挡
            UIButton *btnAutomatic = [[UIButton alloc] initWithFrame:CGRectMake(btnManual.maxX + 9, 1, 72, 50)];
            btnAutomatic.tag = 65274571;
            btnAutomatic.selected = NO;
            [btnAutomatic setTitle:@"自动" forState:UIControlStateNormal];
            btnAutomatic.titleLabel.font = [UIFont systemFontOfSize:15];
            [btnAutomatic setTitleColor:kColorGray1 forState:UIControlStateNormal];
            [btnAutomatic addTarget:self action:@selector(onClickTransmissionBtn:) forControlEvents:UIControlEventTouchUpInside];
            [btnAutomatic setImage:[UIImage imageNamed:@"vehicle_circle"] forState:UIControlStateNormal];
            [btnAutomatic setImage:[UIImage imageNamed:@"vehicle_circle_h"] forState:UIControlStateSelected];
            [btnAutomatic setImage:[UIImage imageNamed:@"vehicle_circle_h"] forState:UIControlStateHighlighted];
            btnAutomatic.imageEdgeInsets = UIEdgeInsetsMake(1, -10, 0, 0);
            
            [_btnMessage addSubview:btnManual];
            [_btnMessage addSubview:btnAutomatic];
        } else if (i == 2) {
            
            // 输入排量
            _tfDisplacement = [[UITextField alloc] initWithFrame:CGRectMake(80, 1, 130, 50)];
            _tfDisplacement.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _tfDisplacement.delegate = self;
            _tfDisplacement.tag = kCarDisplacementTag;
            _tfDisplacement.textAlignment = NSTextAlignmentCenter;
            
            UILabel *labL = [[UILabel alloc] initWithFrame:CGRectMake(_tfDisplacement.maxX + 1, 2, 20, 49)];
            labL.text = @"L";
    
            // 初始化选择器
            NSArray *selectorNums = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
            _vSelector = [[UISelectorView alloc] initWithFrame:CGRectMake(0, 0, self.width, 150)];
            _vSelector.colorSelector = kColorBlue1;
            _vSelector.delegate = self;
            _vSelector.backgroundColor = kColorGrey5;
            _vSelector.dataSource = [NSMutableArray arrayWithObjects:selectorNums,@[@"."], selectorNums, nil];
            [_vSelector selectRow:0 inComponent:0 animated:NO];
            [_vSelector selectRow:0 inComponent:1 animated:NO];
            _vSelector.colorStateNormal = kColorGray1;
            
            _tfDisplacement.inputView = _vSelector;
            [_btnMessage addSubview:_tfDisplacement];
            [_btnMessage addSubview:labL];
            
        }
        
        // 标题
        UILabel *labTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(12, 10, 75, 30)];
        labTitle.backgroundColor = [UIColor clearColor];
        labTitle.textColor = kColorGrey2;
        labTitle.textAlignment = NSTextAlignmentLeft;
        labTitle.font = [UIFont systemFontOfSize:14];
        labTitle.tag = kCarTitleStarTag + i;
        labTitle.text = [arrText objectAtIndex:i];
        [_btnMessage addSubview:labTitle];
        [creatView addSubview: _btnMessage];
        
        minY += 50;
    }
    return creatView;
}

#pragma mark - private Method
/** 收键盘 */
- (void)closeKeyboard
{
    UITextField *text = (UITextField *)[self viewWithTag:KMessageStartTag];
    [text resignFirstResponder];
    [_tfDisplacement resignFirstResponder];
}

#pragma mark - onClickBtn
/** 导航栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (btn.tag == UCTopBarButtonLeft) {
        [[MainViewController sharedVCMain] closeView:self animateOption: AnimateOptionMoveLeft];
    } if (btn.tag == UCTopBarButtonRight) {
        
        [UMStatistics event:c_3_6_Selectcar_add_confirm];
        
        UITextField *tfItemCarName = (UITextField *)[self viewWithTag:KMessageStartTag];
    
        [tfItemCarName resignFirstResponder];
        [_tfDisplacement resignFirstResponder];
        UIButton *btnManual = (UIButton *)[self viewWithTag:65274570];
        UIButton *btnAutomatic = (UIButton *)[self viewWithTag:65274571];
        
        NSMutableArray *errors = [NSMutableArray arrayWithCapacity:3];
        if (tfItemCarName.text.length == 0)
            [errors addObject:[NSNumber numberWithInt:KMessageStartTag]];
        if (_tfDisplacement.text.length == 0)
            [errors addObject:[NSNumber numberWithInt:kCarDisplacementTag]];
        if (btnManual.selected == NO && btnAutomatic.selected == NO)
            [errors addObject:[NSNumber numberWithInt:kCarbtnManualTag]];
        
        // 未填完提示
        if (errors.count > 0) {
            [[AMToastView toastView] showMessage:[NSString stringWithFormat:@"还有%d项未填写", errors.count] icon:kImageRequestError duration:AMToastDurationNormal];
            for (NSNumber *num in errors) {
                UILabel *labTitle = (UILabel *)[self viewWithTag:num.integerValue + KMessageStartTag];
                labTitle.textColor = kColorRed;
            }
        }  else {
            [_dicCarModel setObject:tfItemCarName.text forKey:@"CarName"];
            
            // 存储变速器
            if (btnManual.selected || btnAutomatic.selected)
                [_dicCarModel setObject:btnManual.selected ? @"手动" : @"自动" forKey:@"Gearbox"];
            
            // 存储排量
            [_dicCarModel setObject:_tfDisplacement.text forKey:@"Displacement"];
            
            // 执行代理
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(UCAutonomyAddView:didFinishEditCarInfo:)]) {
                    [self.delegate UCAutonomyAddView:self didFinishEditCarInfo:_dicCarModel];
                }
            }
            
        }
    }
}

/** 选择手动档，自动挡 */
- (void)onClickTransmissionBtn:(UIButton *)button
{
    // 关闭键盘
    UITextField *text = (UITextField *)[self viewWithTag:KMessageStartTag];
    [text resignFirstResponder];
    [_tfDisplacement resignFirstResponder];
    
    button.selected = YES;
    if (button.tag == 65274570) {
        UIButton *btnTemp = (UIButton *)[self viewWithTag:65274571];
        btnTemp.selected = NO;
    }else{
        UIButton *btnTemp = (UIButton *)[self viewWithTag:65274570];
        btnTemp.selected = NO;
    }
    UILabel *labTitle = (UILabel *)[self viewWithTag:kCarbtnManualTag + 100000];
    [labTitle setTextColor:kColorGrey2];
}

#pragma mark - UISelectorViewDelegate
- (void)selectorView:(UISelectorView *)selectorView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _tfDisplacement.text = @".";
    UILabel *labLight = (UILabel *)[self viewWithTag:10];
    labLight.text = [[selectorView.dataSource objectAtIndex:0] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:0] row]];
    UILabel *labRight = (UILabel *)[self viewWithTag:11];
    labRight.text = [[selectorView.dataSource objectAtIndex:0] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:2] row]];
    
    UILabel *labTitle = (UILabel *)[self viewWithTag:kCarDisplacementTag + 100000];
    [labTitle setTextColor:kColorGrey2];
    
    if ([labLight.text isEqualToString:@"0"] && [labRight.text isEqualToString:@"0"] ) {
        labLight.text = @"";
        labRight.text = @"";
    }
    _tfDisplacement.text = [NSString stringWithFormat:@"%@.%@",[[selectorView.dataSource objectAtIndex:0] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:0] row]],[[selectorView.dataSource objectAtIndex:0] objectAtIndex:[[selectorView.selectedIndexPaths objectAtIndex:2] row]]];
    _tfDisplacement.font = [UIFont systemFontOfSize:15];
    
    if ([_tfDisplacement.text isEqualToString:@"0.0"])
        _tfDisplacement.text = @"";
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return self == touch.view;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    // 设置标题为正常颜色
    UILabel *labTitle = (UILabel *)[self viewWithTag:KMessageStartTag + 100000];
    [labTitle setTextColor:kColorGrey2];
    
    UILabel *labItem1 = (UILabel *)[self viewWithTag:KlabTag];
    
    labItem1.hidden = (textField.text.length + string.length) > 0 ? YES : NO;
    if (textField.text.length == 1 && string.length == 0) {
        labItem1.hidden = NO;
    }
    return YES;
}

@end
