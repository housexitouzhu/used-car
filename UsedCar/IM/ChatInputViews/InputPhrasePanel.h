//
//  InputPhrasePanel.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputPhrasePanelDelegate;

@interface InputPhrasePanel : UIView

@property (nonatomic, strong) NSArray *arrPhrase;
@property (nonatomic, assign) id<InputPhrasePanelDelegate> delegate;

- (id)initWithFrame:(CGRect)frame listArray:(NSArray*)array;

@end

@protocol InputPhrasePanelDelegate <NSObject>

- (void)InputPhrasePanel:(InputPhrasePanel*)panel didSelectPhrase:(NSString *)phraseString;

@end