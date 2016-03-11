//
//  UCSearchView.h
//  UsedCar
//
//  Created by wangfaquan on 14-5-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCCarBrandModel;

@protocol UCSerchViewDelegate;

@interface UCSearchView : UIView<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<UCSerchViewDelegate>delegate;
@property (nonatomic, strong) UITableView *tvSelect;
@property (nonatomic, strong) UITextField *tfSearch;
@property (nonatomic, strong) NSMutableArray *naCarNames;
@property (nonatomic, strong) UIImageView *ivSearchIcon;

- (id)initWithFrame:(CGRect)frame isShowCancelButton:(BOOL)isShowCancelButton;
- (id)initWithFrame:(CGRect)frame isShowCancelButton:(BOOL)isShowCancelButton isLightView:(BOOL)isLightView;
- (void)closeSearchList;
- (void)reloadSearchResultData:(UITextField *)tfSearch;

@end

@protocol UCSerchViewDelegate <NSObject>

@optional
- (void)searchView:(UCSearchView *)vSearch dicCarModel:(NSMutableDictionary *)dicCarModel;
- (BOOL)UCSearchView:(UCSearchView *)vSearch textFieldShouldBeginEditing:(UITextField *)textField;
- (BOOL)UCSearchView:(UCSearchView *)vSearch textFieldShouldReturn:(UITextField *)textField;
- (void)UCSearchView:(UCSearchView *)vSearch textFieldHaveChanged:(UITextField *)textField;
- (void)didClickCancelButton:(UCSearchView *)vSearch;
- (void)willCloseSearchView:(UCSearchView *)vSearch;
- (BOOL)UCSearchView:(UCSearchView *)vSearch textFieldShouldClear:(UITextField *)textField;

@end
