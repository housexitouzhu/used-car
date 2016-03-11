//
//  SpecMessage.m
//  IMDemo
//
//  Created by jun on 11/4/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "CarMessageBody.h"
#import "UCCarDetailInfoModel.h"
#import "NSString+Util.h"

@implementation CarMessageBody

-(id)init
{
    if (self = [super init]) {
        self.type = [NSNumber numberWithInteger:kXMPP_MESSAGE_CAR];
    }
    return self;
}

- (id)initWithJsonObj:(id)jsonObj
{
    if ([super initWithJsonObj:jsonObj]) {
        id body               = [jsonObj objectForKey:@"body"];
        self.carid            = [body objectForKey:@"carid"];
        self.nickname         = [body objectForKey:@"nickname"];
        self.carname          = [body objectForKey:@"carname"];
        self.carprice         = [body objectForKey:@"carprice"];
        self.carimage         = [body objectForKey:@"carimage"];
        self.registrationdate = [body objectForKey:@"registrationdate"];
        self.mileage          = [body objectForKey:@"mileage"];
        self.carJson          = [body objectForKey:@"carJson"];
        self.nickname         = [body objectForKey:@"nickname"];
        self.dealerid         = [body objectForKey:@"dealerid"];
        self.memberid         = [body objectForKey:@"memberid"];
        self.dealername       = [body objectForKey:@"dealername"];
    }
    return self;
}

- (id)initWithModel:(UCCarDetailInfoModel *)model
{
    if (self = [super init]) {
        self.type             = [NSNumber numberWithInteger:kXMPP_MESSAGE_CAR];
        self.carid            = model.carid ? model.carid : [NSNumber numberWithInteger:0];
        self.carname          = [model.carname dNull];
        NSArray *thumbimgurls = [model.thumbimgurls componentsSeparatedByString:@","];
        if (thumbimgurls.count > 0) {
            self.carimage         = [thumbimgurls objectAtIndex:0];
        } else {
            self.carimage = @"";
        }
        self.carprice         = [model.bookprice.stringValue dNull];
        self.registrationdate = [model.firstregtime dNull];
        self.mileage          = [model.drivemileage.stringValue dNull];
        self.carJson          = [[model jsonString] dNull];
        self.dealerid         = model.userid ? model.userid : [NSNumber numberWithInteger:0];
        self.memberid         = model.memberid.integerValue > 0 ? model.memberid : [NSNumber numberWithInteger:0];
        self.dealername       = model.userid.integerValue > 0 ? [model.dealername dNull] : @"个人";
        self.nickname         = [model.salesPerson.salesname dNull];
        
    }
    return self;
}

//{
//    "type":400,
//    "body": {
//        "carid": 12847323,
//        "carname": "迈腾2011款1.4TSI 精英型",
//        "carimage":"http://img.autoimg.cn/logo/brand/100/129302900065156250.jpg",
//        "carprice":"14.85",
//        "registrationdate":"2011-05",
//        "mileage":"5.51",
//
//        "nickname":"黎小姐",
//        "dealerid":139108,
//        "dealername":"神马商家名称"
//    }
//}
- (NSString *)jsonString
{
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setObject:self.carimage forKey:@"carimage"];
    [body setObject:self.carprice forKey:@"carprice"];
    [body setObject:self.registrationdate forKey:@"registrationdate"];
    [body setObject:self.mileage forKey:@"mileage"];
    [body setObject:self.memberid forKey:@"memberid"];
    [body setObject:self.carid forKey:@"carid"];
    if (self.carJson.length>0) {
        [body setObject:self.carJson forKey:@"carJson"];
    }
    if (self.nickname.length>0) {
        [body setObject:self.nickname forKey:@"nickname"];
    }
    if (self.carname.length>0) {
        [body setObject:self.carname forKey:@"carname"];
    }
    if (self.dealerid.integerValue>0) {
        [body setObject:self.dealerid forKey:@"dealerid"];
    }
    if (self.dealername.length>0) {
        [body setObject:self.dealername forKey:@"dealername"];
    }
    
    NSDictionary *jsonDic = @{
                              @"type":self.type,
                              @"body":body
                              };
    
    //    NSDictionary *jsonDic = @{
    //                              @"type":self.type,
    //                              @"body":@{
    //                                          @"carid": self.carid,
    //                                          @"carname": self.carname,
    //                                          @"carimage": self.carimage,
    //                                          @"carprice": self.carprice,
    //                                          @"registrationdate": self.registrationdate,
    //                                          @"mileage": self.mileage,
    //                                          @"nickname":self.nickname,
    //                                          @"dealerid":self.dealerid,
    //                                          @"dealername":self.dealername
    //                                      }
    //                              };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
