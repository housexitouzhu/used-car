//
//  UCDealerVerifyView.h
//  UsedCar
//
//  Created by 张鑫 on 14/11/18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCInputCodeView.h"

@class UCDealerVerifyView;
@class SalesPersonModel;

typedef void(^RegisterDealerIM)(UCDealerVerifyView *vDealerIM, BOOL isSuccess, NSError *error);

@interface UCDealerVerifyView : UCView <UITableViewDelegate, UITableViewDataSource, UCInputCodeViewDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) RegisterDealerIM blockDealer;
@property (nonatomic, strong) UCInputCodeView *vInputCode;
- (void)verifyDealerIM:(RegisterDealerIM)block;

@end



@interface UCDealerVerifyCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;
- (void)makeCell:(SalesPersonModel *)mSales;

@end
