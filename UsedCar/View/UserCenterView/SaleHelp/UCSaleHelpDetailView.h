//
//  UCSaleHelpDetailView.h
//  UsedCar
//
//  Created by 张鑫 on 14/11/4.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCWebView.h"

@interface UCSaleHelpDetailView : UCView <UCWebViewDelegate>

- (id)initWithFrame:(CGRect)frame withWebURL:(NSString *)url;

@end
