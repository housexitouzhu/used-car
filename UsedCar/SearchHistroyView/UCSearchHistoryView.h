//
//  UCSearchHistoryView.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-11.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UCSearchHistoryViewDelegate <NSObject>

-(void)searchHistoryDidSelectRowWithKeyword:(NSString*)keyword;
@optional
-(void)shouldHideKeyboard; //滚动关闭键盘的 delegate

@end

@interface UCSearchHistoryView : UIView

@property (retain, nonatomic) NSMutableArray *dataArray;
@property (retain, nonatomic) id<UCSearchHistoryViewDelegate> delegate;

-(void)refreshTable;
-(void)saveHistoryWithNewEntry:(NSString*)searchText;

@end

