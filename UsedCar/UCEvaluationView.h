//
//  UCEvaluationView.h
//  UsedCar
//
//  Created by 张鑫 on 13-12-31.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UISelectorView.h"
#import "UCChooseCarView.h"
#import "UCEvaluationDetailView.h"

@interface UCEvaluationView : UCView <UITextFieldDelegate, UITextViewDelegate, UISelectorViewDelegate, UCChooseCarViewDelegate, UCEvaluationDetailViewDelegate>

@end
