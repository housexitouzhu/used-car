//
//  UCContactUsView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-9-16.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCContactUsView.h"

#define kDefaultLineGap 5.0 //默认的行间距

@implementation UCContactUsView

- (id)initWithFrame:(CGRect)frame withStatementArray:(NSArray*)arrState andPhoneNumber:(NSString*)number
{
    self = [super initWithFrame:frame];
    if (self) {
        self.arrStatement = arrState;
        self.phoneNumber = number;
        
        [self initView];
    }
    return self;
}

- (void)initView{
    UIView *vContact = [[UIView alloc] initWithFrame:self.bounds];
    vContact.backgroundColor = kColorClear;
    
    // 拨打按钮
    UIImage *imgCall = [UIImage imageNamed:@"merchant home_tel_btn_icon"];
    UIButton *btnPhone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPhone setFrame:CGRectMake(self.width - 20 - imgCall.size.width, (vContact.height - imgCall.size.height) / 2, imgCall.size.width, imgCall.size.height)];
    [btnPhone setImage:imgCall forState:UIControlStateNormal];
    [btnPhone addTarget:self action:@selector(onClickPhoneBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    // 分割线
    //    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, vContact.width, kLinePixel) color:kColorNewLine];
    NSArray *titles = self.arrStatement;
    
    UIView *labelSuperView = [[UIView alloc] init];
    [labelSuperView setBackgroundColor:kColorClear];
    CGFloat labelHeight = 0.0;
    
    NSMutableArray *arrMaxXs = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < titles.count; i++) {
        UILabel *labPrompt = [[UILabel alloc] init];
        labPrompt.text = [titles objectAtIndex:i];
        labPrompt.font = kFontTiny;
        
        if (i==0) {
            labPrompt.textColor = kColorNewGray2;
        }
        else{
            labPrompt.textColor = kColorNewGray1;
        }
        
        labPrompt.backgroundColor = [UIColor clearColor];
        [labPrompt sizeToFit];
        
        labelHeight = labPrompt.height;
        
        CGFloat y = (kDefaultLineGap + labelHeight) * i;
        labPrompt.origin = CGPointMake(0, y);
        
        //记录 label 的 maxX 值.
        [arrMaxXs addObject:[NSNumber numberWithFloat:labPrompt.maxX]];
        
        [labelSuperView addSubview:labPrompt];
    }
    
    //获取最长的 label 的 maxX
    CGFloat labelMaxX = [[arrMaxXs valueForKeyPath:@"@max.floatValue"] floatValue];
    
    //计算 label 的父 view 的 总高度 和 Y 值
    CGFloat labelSuperViewHeight = labelHeight * titles.count + kDefaultLineGap * (titles.count-1);
    CGFloat labelSuperViewY =  (self.height - labelSuperViewHeight) / 2;
    
    // 根据最长的 label 的 maxX 设置宽度
    [labelSuperView setFrame:CGRectMake(20, labelSuperViewY, labelMaxX, labelSuperViewHeight)];
    [vContact addSubview:labelSuperView];
    
    // 分割线
    CGFloat rightLineX = self.width - 80;
    CGFloat averageX = (btnPhone.minX - labelSuperView.maxX)/2+labelSuperView.maxX;
    if (averageX > rightLineX ) {
        rightLineX = averageX;
    }
    UIView *vRightLine = [[UIView alloc] initLineWithFrame:CGRectMake(rightLineX, (vContact.height - 40) / 2, kLinePixel, 40) color:kColorNewLine];
    
    //    [vContact addSubview:vLine];
    [vContact addSubview:btnPhone];
    [vContact addSubview:vRightLine];
    
    [self addSubview:vContact];
}

- (void)setViewWithStatementArray:(NSArray*)arrState andPhoneNumber:(NSString*)number{
    self.arrStatement = arrState;
    self.phoneNumber = number;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self initView];
}

/** 拨打电话 */
- (void)onClickPhoneBtn:(UIButton *)btn
{
    if (![OMG isValidClick])
        return;
    
    [OMG callPhone:self.phoneNumber];
}

@end
