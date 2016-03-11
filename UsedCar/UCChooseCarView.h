//
//  UCChooseCarView.h
//  UsedCar
//
//  Created by 张鑫 on 13-11-27.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCSearchView.h"
#import "UISelectorView.h"
#import "UCFilterBrandView.h"
#import "UCAutonomyAddView.h"
#import "UCFilterModel.h"

@protocol UCChooseCarViewDelegate;

@interface UCChooseCarView : UCView <UITextFieldDelegate, UISelectorViewDelegate, UCFilterBrandViewDelegate, UCSerchViewDelegate, UCAutonomyViewDelegate>

@property (nonatomic, weak) id<UCChooseCarViewDelegate> delegate;
@property (nonatomic, strong) NSString *carNames;

/** 包含自定义车辆 */
- (id)initWithFrame:(CGRect)frame viewStyle:(UCFilterBrandViewStyle)viewStyle isTop:(BOOL)isTop;

- (id)initWithCustomCarFrame:(CGRect)frame viewStyle:(UCFilterBrandViewStyle)viewStyle carName:(NSString *)carName mAFilter:(UCFilterModel *)filter;

- (id)initWithCustomCarFrame:(CGRect)frame viewStyle:(UCFilterBrandViewStyle)viewStyle;

@end

@protocol UCChooseCarViewDelegate <NSObject>
@required

- (void)chooseCarViewDidCancel:(UCChooseCarView *)vChooseCar;
- (void)chooseCarView:(UCChooseCarView *)vChooseCar didFinishChooseWithInfo:(NSDictionary *)info;

@end
