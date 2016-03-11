//
//  OMG.m
//  CarMaster
//
//  Created by Alan on 13-8-16.
//  Copyright (c) 2013年 Alan. All rights reserved.
//
//
#import "OMG.h"
#import "DatabaseHelper1.h"
#import "AMToastView.h"
#import "AreaProvinceItem.h"
#import "AreaCityItem.h"
#import "MobClick.h"
#import "NSString+Util.h"
#import "UCAreaMode.h"
#import "UCFilterModel.h"
#import "AMCacheManage.h"
#import "UCCarBrandModel.h"
#import "UCCarSeriesModel.h"
#import "UCCarSpecModel.h"
#import "UCHotAreaModel.h"
#import <objc/runtime.h>

//static UIToastView *_toastView;
//static UserInfoModel *_mUserInfo;
static NSMutableArray *_areaProvinces;
static NSMutableArray *_hotAreas;
static NSString *_udid;

@implementation OMG

+ (CGFloat)degreesToRadians:(CGFloat)degrees {return degrees * M_PI / 180;}
+ (CGFloat)radiansToDegrees:(CGFloat)radians {return radians * 180 / M_PI;}

+ (NSString *)openUDID
{
    if (!_udid)
        _udid = [NSString openUDID];
    AMLog(@"UDID:%@", _udid);
    return _udid;
}

+ (NSDate *)dateFromStringWithFormat:(NSString *)format string:(NSString *)string
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:format];
    NSDate *date =[dateFormat dateFromString:string];
    return date;
}

+ (NSString *)stringFromDateWithFormat:(NSString *)format date:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timezone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:timezone];
    [dateFormatter setDateFormat:format];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

/** 距离当前时间 */
+ (NSString *)intervalSinceNow: (NSDate *)fromDate
{
    NSString *timeString= @"刚刚";
    NSTimeZone *fromzone = [NSTimeZone systemTimeZone];
    NSInteger frominterval = [fromzone secondsFromGMTForDate: fromDate];
    NSDate *fromDateTemp = [fromDate dateByAddingTimeInterval: frominterval];
    
    //获取当前时间
    NSDate *adate = [NSDate date];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: adate];
    NSDate *localeDate = [adate  dateByAddingTimeInterval: interval];
    
    double intervalTime = [fromDateTemp timeIntervalSinceReferenceDate] - [localeDate timeIntervalSinceReferenceDate];
    long lTime = fabs((long)intervalTime);
    NSInteger iHours = fabs(lTime/3600);
    NSInteger iDays = lTime/60/60/24;
    
    if (iHours<1)
    {
        timeString=[OMG stringFromDateWithFormat:@"HH:mm" date:fromDate];
        
    }
    else if (iHours>0&& iHours < 48) {
        timeString=[NSString stringWithFormat:@"昨天%@",[OMG stringFromDateWithFormat:@"HH:mm" date:fromDate]];
    }else if (iDays>2 && iDays < 7)
    {
        timeString=[NSString stringWithFormat:@"%@",[OMG stringFromDateWithFormat:@"EEEEHH:mm" date:fromDate]];
    }
    else
    {
        timeString=[OMG stringFromDateWithFormat:@"yyyy/MM/dd" date:fromDate];
    }

    return timeString;
}

/* 是否有效点击 */
static NSTimeInterval lastClickTime;
+ (BOOL)isValidClick
{
    return [OMG isValidClick:0.3];
}

+ (BOOL)isValidClick:(NSTimeInterval)intervalTime
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    if (fabs(time - lastClickTime) < intervalTime)
        return NO;
    lastClickTime = time;
    return YES;
}

/** 省市表 */
+ (NSArray *)areaProvinces
{
    if (!_areaProvinces) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"AreaProvince" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSArray *areaProvinces = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
        
        _areaProvinces = [[NSMutableArray alloc] init];
        for (id item in areaProvinces) {
            [_areaProvinces addObject:[[AreaProvinceItem alloc] initWithJson:item]];
        }
    }
    return _areaProvinces;
}

/** 热门地区 */
+ (NSArray *)hotArea
{
    if (!_hotAreas) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HotArea" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSArray *hotAreas = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
        
        _hotAreas = [[NSMutableArray alloc] init];
        for (id item in hotAreas) {
            [_hotAreas addObject:[[UCHotAreaModel alloc] initWithJson:item]];
        }
    }
    return _hotAreas;
}

/** 根据省份ID获取省份实体 */
+ (AreaProvinceItem *)areaProvince:(NSInteger)PI
{
    if (PI > 0) {
        NSArray *areProvinces = [OMG areaProvinces];
        for (AreaProvinceItem *apItem in areProvinces) {
            if (apItem.PI.integerValue == PI) {
                return apItem;
                break;
            }
        }
    }
    return nil;
}

/** 根据城市名称获得城市实体 */
+ (UCAreaMode *)areaCityWithCityName:(NSString *)name
{
    NSArray *areProvinces = [OMG areaProvinces];
    for (AreaProvinceItem *mAreaProvince in areProvinces) {
        for (AreaCityItem *mAreaCity in mAreaProvince.CL) {
            if ([name rangeOfString:mAreaCity.CN].location != NSNotFound) {
                UCAreaMode *mAreaMode = [[UCAreaMode alloc] init];
                mAreaMode.pName = mAreaProvince.PN;
                mAreaMode.pid = [mAreaProvince.PI stringValue];
                mAreaMode.cName = mAreaCity.CN;
                mAreaMode.cid = [mAreaCity.CI stringValue];
                return mAreaMode;
            }
        }
    }
    return nil;
}

/** 根据城市ID获得地点实体 */
+ (UCAreaMode *)areaModelWithCid:(NSString *)cid
{
    NSArray *areProvinces = [OMG areaProvinces];
    for (AreaProvinceItem *mAreaProvince in areProvinces) {
        for (AreaCityItem *mAreaCity in mAreaProvince.CL) {
            if ([[mAreaCity.CI stringValue] isEqualToString:cid]) {
                UCAreaMode *mAreaMode = [[UCAreaMode alloc] init];
                mAreaMode.pName = mAreaProvince.PN;
                mAreaMode.pid = [mAreaProvince.PI stringValue];
                mAreaMode.cName = mAreaCity.CN;
                mAreaMode.cid = [mAreaCity.CI stringValue];
                return mAreaMode;
            }
        }
    }
    return nil;
}

/** 根据城市ID和省份实体获取城市实体 */
+ (AreaCityItem *)areaCity:(NSInteger)CI apItem:(AreaProvinceItem *)apItem
{
    if (CI > 0 && apItem) {
        for (AreaCityItem *acItem in apItem.CL) {
            if (acItem.CI.integerValue == CI) {
                return acItem;
                break;
            }
        }
    }
    return nil;
}

/** 根据新车报价url获得"areaModel + filterModel"的NSArray */
+ (NSArray *)getFilterModelAndAreaModelArrayWithUrl:(NSString *)strCarPrice
{
    if (strCarPrice.length > 0) {
        // 数据字符串
        NSRange range = [strCarPrice rangeOfString:@"searchcar?"];
        if (range.length > 0) {
            NSString *strPriceCarData = [strCarPrice substringFromIndex:range.location + range.length];
            
            if (strPriceCarData.length > 0) {
                // 获得数据
                UCFilterModel *mFilter = [[UCFilterModel alloc] init];
                UCAreaMode *mArea = [[UCAreaMode alloc] init];
                
                NSMutableDictionary *dicCarPriceApp = [[NSMutableDictionary alloc] init];
                
                if (strPriceCarData.length > 0) {
                    NSArray *array = [strPriceCarData componentsSeparatedByString:@"&"];
                    for (int i = 0; i < array.count; i++) {
                        NSArray *arrayItem = [[array objectAtIndex:i] componentsSeparatedByString:@"="];
                        if (arrayItem.count == 2) {
                            NSString *strKey =[arrayItem objectAtIndex:0];
                            NSString *strValue = [arrayItem objectAtIndex:1];
                            [dicCarPriceApp setValue:strValue forKey:strKey];
                        }
                    }
                }
                /** 补全filterModel */
                mFilter.brandid = [dicCarPriceApp objectForKey:@"brandid"];
                mFilter.seriesid = [dicCarPriceApp objectForKey:@"seriesid"];
                mFilter.specid = [dicCarPriceApp objectForKey:@"specid"];
                NSArray *brand = [AMCacheManage selectFrome:@"CarBrand" where:@"BrandId" equalValue:mFilter.brandid];
                NSArray *series = [AMCacheManage selectFrome:@"CarSeries" where:@"SeriesId" equalValue:mFilter.seriesid];
                NSArray *spec = [AMCacheManage selectFrome:@"CarSpec" where:@"SpecId" equalValue:mFilter.specid];
                if (brand.count > 0)
                    mFilter.brandidText = ([[UCCarBrandModel alloc] initWithJson:[brand objectAtIndex:0]]).name;
                if (series.count > 0)
                    mFilter.seriesidText = ([[UCCarSeriesModel alloc] initWithJson:[series objectAtIndex:0]]).name;
                if (spec.count > 0)
                    mFilter.specidText = ([[UCCarSpecModel alloc] initWithJson:[spec objectAtIndex:0]]).name;
                
                /** 补全areaModel */
                mArea.pid = [dicCarPriceApp objectForKey:@"pid"];
                mArea.cid = [dicCarPriceApp objectForKey:@"cid"];
                // 省市
                if (mArea.cid.length > 0) {
                    [mArea setEqualToArea:[OMG areaModelWithCid:mArea.cid]];
                }
                // 省
                if ([mArea.pid integerValue] == 0 || [mArea.pid integerValue] == NSNotFound) {
                    AreaProvinceItem *mAreaPro = [OMG areaProvince:[mArea.pid integerValue]];
                    mArea.pName = mAreaPro.PN;
                }
                
                return [[NSArray alloc] initWithObjects:mFilter, mArea, nil];
            }
        }
    }
    return nil;
}

/** 播放电话 */
+ (BOOL)callPhone:(NSString *)num
{
    //        NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", @"112"]];
    //        UIWebView *phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    //        [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    //        AMRELEASE(phoneCallWebView);
    
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])){
        [[AMToastView toastView] showMessage:@"您的设备不支持拨打电话" icon:kImageRequestError duration:AMToastDurationNormal];
        return NO;
    }
    else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", num]]];
        return YES;
    }
}

/** 友盟事件统计 */
+ (void)umengEvent:(NSString *)eventId{
    [MobClick event:eventId];
}

+ (void)umengBeginEvent:(NSString *)eventId{
    [MobClick beginEvent:eventId];
}

+ (void)umengEndEvent:(NSString *)eventId{
    [MobClick endEvent:eventId];
}

+ (void)umengBeginLogPageName:(NSString *)name{
    AMLog(@"############ BB %@", name);
    [MobClick beginLogPageView:name];
}

+ (void)umengEndLogPageName:(NSString *)name{
    AMLog(@"############ EE %@", name);
    [MobClick endLogPageView:name];
}

+ (void)umengBeginLogPageView:(UIView *)view{
    AMLog(@"############ B %@", NSStringFromClass(view.class));
    [MobClick beginLogPageView:NSStringFromClass(view.class)];
}

+ (void)umengEndLogPageView:(UIView *)view{
    AMLog(@"############ E %@", NSStringFromClass(view.class));
    [MobClick endLogPageView:NSStringFromClass(view.class)];
}


#pragma mark ------------------
//使用颜色生成图片
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;
    
    @autoreleasepool {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context,
                                       color.CGColor);
        CGContextFillRect(context, rect);
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return img;
}

/** 设置观察者模式 */
+(void)setKVOWithModel:(id)model isOpen:(BOOL)isOpen delegate:(id)delegate;
{
    // 注册观察者
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    for (i=0; i<outCount; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if (isOpen) {
            [model addObserver:delegate forKeyPath:key options:NSKeyValueObservingOptionOld context:nil];
        } else {
            [model removeObserver:delegate forKeyPath:key];
        }
    }
    free(properties);
}


/** 日期计算方法 **/
+(NSDateFormatter*)defaultDateFormatter{
    static dispatch_once_t pred = 0;
    static NSDateFormatter *dateFormatter = nil;
    dispatch_once(&pred, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    return dateFormatter;
}

+(NSString *)FormattedStringOfNSDate:(NSDate*)date inTimeZone:(NSTimeZone*)timeZone Format:(NSString*)format{
    NSDateFormatter *dateFormatter = [self.class defaultDateFormatter];
    if (timeZone) {
        [dateFormatter setTimeZone:timeZone];
    }
    [dateFormatter setDateFormat:format];
    NSString *dateStr = [dateFormatter stringFromDate:date];
#if DEBUG
    [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss Z"];
    NSString *testStr = [dateFormatter stringFromDate:date];
    AMLog(@"YMDStringOfNSDate\n>>InputDate %@ \n>>OutputDate %@ ", date, testStr);
#endif
    
    return dateStr;
}

//年月日的字符串
+(NSString *)YMDStringOfNSDate:(NSDate*)date inTimeZone:(NSTimeZone*)timeZone{
    
    return [self FormattedStringOfNSDate:date inTimeZone:timeZone Format:@"yyyy年MM月dd日"];
}

+(BOOL)isValidateNumbers:(NSString *)numbers{
    NSString *numberRegex = @"^[0-9]+$";
    NSPredicate *numbersTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    return [numbersTest evaluateWithObject:numbers];
}

+(BOOL)isValidateMobile:(NSString *)mobile{
    NSString *numberRegex = @"^[0-9]{11}";
    NSPredicate *numbersTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    return [numbersTest evaluateWithObject:mobile];
}

+(BOOL)isValidateUserName:(NSString *)userName{
    
    NSInteger count = [self.class charLengthOfText:userName];
    if (count >= 4 && count <= 20) {
        //匹配中文字符[\u4e00-\u9fa5]
        //匹配帐号是否合法(字母开头，允许5-16字节，允许字母数字下划线)：^[a-zA-Z][a-zA-Z0-9_]{5,16}$
        NSString *userNameRegex = @"[a-zA-Z0-9_\u4e00-\u9fa5]+$"; //+号的意思是1或者更多//允许4-20字节 @"[a-zA-Z0-9_\u4e00-\u9fa5]{4,20}$"
        NSPredicate *userNameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];
        AMLog(@"isValidateNickName: %lu",(unsigned long)[userNameTest evaluateWithObject:userName]);
        return [userNameTest evaluateWithObject:userName];
    }
    else{
        return NO;
    }
}

//返回字数，区分中文英文的占位字节
+ (NSInteger)textLength:(NSString *)text
{
    float number = 0.0;
    for (int index = 0; index < [text length]; index++)
    {
        NSString *character = [text substringWithRange:NSMakeRange(index, 1)];
        
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3)
        {
            number++;
        }
        else
        {
            number = number + 0.5;
        }
    }
    return ceil(number);
}

+ (NSInteger)charLengthOfText:(NSString *)text{
    return [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

/** 年审时间联动 */
+ (NSString *)dateCheckForTag:(NSInteger)tag year:(NSInteger)year month:(NSInteger)month
{
    // 获取本地年月
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit;
    NSDateComponents *comps  = [calendar components:unitFlags fromDate:[NSDate date]];
    NSInteger localYear = [comps year];
    NSInteger localMonth = [comps month];
    
    NSInteger offsetYear = NSNotFound;
    // 本地日期不能小于首次上牌日期
    if (localYear - year > 0 || (localYear - year == 0 && localMonth >= month)) {
        // 年审
        if (tag == 1) {
            // 是否超过6年
            BOOL isMoreThan6Y = NO;
            if (localYear - year > 6 || (localYear - year == 6 && localMonth - month > 0))
                isMoreThan6Y = YES;
            
            // 小于6年, 2年一检
            if (!isMoreThan6Y) {
                // 本地年份 == 首次上牌年份, 年份+2
                if (localYear == year)
                    offsetYear = 2;
                // 本地年份 > 首次上牌年份
                else if (localYear > year) {
                    // 本地月份 与 首次上牌月份 相差被2整除, 年份保持不变, 否则年份+1
                    if ((localYear - year) % 2 == 0) {
                        offsetYear = localMonth <= month ? 0 : 2;
                    } else {
                        offsetYear = 1;
                    }
                }
            }
            // 大于6年, 1年一检
            else {
                // 本地年份 == 首次上牌年份, 年份+1
                if (localYear == year)
                    offsetYear = 1;
                // 本地年份 > 首次上牌年份, 再比较月份, 如果月份已过, 年份+1
                else if (localYear > year)
                    offsetYear = localMonth <= month ? 0 : 1;
            }
        }
        // 车船使用 or 交强险
        else if (tag == 2 || tag == 3) {
            // 本地年份 == 首次上牌年份, 年份+1
            if (localYear == year)
                offsetYear = 1;
            // 本地年份 > 首次上牌年份, 再比较月份, 如果月份已过, 年份+1
            else if (localYear > year)
                offsetYear = localMonth <= month ? 0 : 1;
        }
    } else {
        AMLog(@"本地时间不对或者上牌日期异常...");
    }
    
    if (offsetYear != NSNotFound) {
        // 车船使用只要年份
        if (tag == 2)
            return [NSString stringWithFormat:@"%d", localYear + offsetYear];
        else
            return [NSString stringWithFormat:@"%d-%d", localYear + offsetYear, month];
    }
    return nil;
}

/** 发车构建时间 */
+ (NSMutableArray *)buildDateSource:(NSInteger)incremental strDate:(NSString *)strDate row0:(NSInteger *)row0 row1:(NSInteger *)row1
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit;
    NSDateComponents *comps  = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSInteger year = [comps year] + incremental;
    //NSInteger month = [comps month];
    
    NSMutableArray *dateSource = nil;
    
    // 正常时间 年 月
    if (incremental >= 0) {
        // 已选中处理
        NSString *selectedYear = nil;
        NSString *selectedMonth = nil;
        NSInteger seletedRow0 = 0;
        NSInteger seletedRow1 = 0;
        if (strDate) {
            NSArray *year_month = [strDate componentsSeparatedByString:@"-"];
            if (year_month.count == 2) {
                selectedYear = [year_month objectAtIndex:0];
                selectedMonth = [year_month objectAtIndex:1];
            }
        }
        
        NSMutableArray *years = [NSMutableArray array];
        NSMutableArray *months = [NSMutableArray array];
        
        NSInteger count = 20;
        for (NSInteger i = 0; i < count; i++) {
            NSString *tmpYear = [NSString stringWithFormat:@"%d", year - i];
            if ([selectedYear isEqualToString:tmpYear])
                seletedRow0 = i;
            [years addObject:tmpYear];
        }
        for (NSInteger i = 0; i < 12; i++) {
            NSString *tmpMonth = [NSString stringWithFormat:@"%d", i + 1];
            if ([selectedMonth isEqualToString:tmpMonth])
                seletedRow1 = i;
            [months addObject:tmpMonth];
        }
        *row0 = seletedRow0;
        *row1 = seletedRow1;
        
        dateSource = [NSMutableArray arrayWithObjects:years, months, nil];
    }
    
    // 过期时间
    else {
        NSMutableArray *years = [NSMutableArray array];
        [years addObject:@"已过期"];
        [years addObject:[NSString stringWithFormat:@"%d", year + 1]];
        [years addObject:[NSString stringWithFormat:@"%d", year + 2]];
        
        NSInteger seletedRow0 = 0;
        for (int i = 0; i < years.count; i++) {
            if ([strDate isEqualToString:[years objectAtIndex:i]])
                seletedRow0 = i;
        }
        *row0 = seletedRow0;
        
        dateSource = [NSMutableArray arrayWithObjects:years, nil];
    }
    
    return dateSource;
}


@end
