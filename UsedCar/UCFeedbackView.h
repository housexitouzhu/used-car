//
//  UCFeedbackView.h
//  UsedCar
//
//  Created by wangfaquan on 13-12-6.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UMFeedback.h"
#import "UISelectorView.h"
#import "UCOptionBar.h"
#import "UCFilterView.h"

@class GHSettingsView;
@interface UCFeedbackView : UCView <UITableViewDataSource, UITableViewDelegate, UMFeedbackDataDelegate, UITextViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, UISelectorViewDelegate, UIAlertViewDelegate>
{
    UMFeedback *_feedback;
    UIView *_selectBar;
    UIImageView *_bottomBar;
    UITextView *_tvFeedbackText;
    UIButton *_btnSend;
    CGFloat _keyboardY;
    BOOL _isShowSelector;
    UISelectorView *_selectorView;//类似pickerView的选择框
    UIImageView *_ivSelect;
    
    NSInteger _isShowContactView;
}

@property (nonatomic, strong) UITableView *tvFeedback;
@property (nonatomic, weak) GHSettingsView *vSetting;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSArray *ageArray;
@property (nonatomic, strong) NSArray *genderArray;

@property (nonatomic) NSInteger ageIndex;
@property (nonatomic) NSInteger gander;
@property (nonatomic, strong) NSString *contact;

@end

@interface FeedbackCell : UITableViewCell

@property (nonatomic) BOOL isLeft;
@property (nonatomic, strong) UILabel *labTime;
@property (nonatomic, strong) UIImageView *ivBg;

@end
