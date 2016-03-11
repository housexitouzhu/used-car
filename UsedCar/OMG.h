//
//  OMG.h
//  UsedCar
//
//  Created by Alan on 13-8-16.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

//#define NSLS(key) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]

// 友盟
#define UM_APP_KEY @"4e03dcb3431fe33ca80002ec"

// 开启显示环境
#define OnTestStatus     0
// 0:线上 1:线下 -1:关闭
#define HostStatus       0
// 是否存在开机引导页（欢迎页）：0:关闭 1:开启
#define IntroGuide       1

#ifndef AMLog
#if DEBUG
#define AMLog(id, ...) NSLog((@"%s [Line %d] " id),__PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define AMLog(id, ...)
#endif
#endif

// 当前设备版本号
#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define APP_BUILD [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define IOS5_OR_LATER       ([[[UIDevice currentDevice] systemVersion] compare:@"5"] != NSOrderedAscending)
#define IOS6_OR_LATER       ([[[UIDevice currentDevice] systemVersion] compare:@"6"] != NSOrderedAscending)
#define IOS7_OR_LATER       ([[[UIDevice currentDevice] systemVersion] compare:@"7"] != NSOrderedAscending)
#define IOS8_OR_LATER       ([[[UIDevice currentDevice] systemVersion] compare:@"8"] != NSOrderedAscending)

#define DEVICE_IS_IPHONE5   ([[UIScreen mainScreen] bounds].size.height == 568)

#define APP_VERSION_EQUAL_TO(v)([APP_VERSION compare:v options:NSNumericSearch] == NSOrderedSame)
#define APP_VERSION_GREATER_THAN(v) ([APP_VERSION compare:v options:NSNumericSearch] == NSOrderedDescending)
#define APP_VERSION_GREATER_THAN_OR_EQUAL_TO(v)([APP_VERSION compare:v options:NSNumericSearch]!=NSOrderedAscending)
#define APP_VERSION_VERSION_LESS_THAN_OR_EQUAL_TO(v)([APP_VERSION compare:v options:NSNumericSearch]!=NSOrderedDescending)

#define COlOR_RGB(r,g,b)    [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define COlOR_RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]

#define DEGREES_TO_RADIANS(degrees) (degrees * M_PI / 180)
#define RADIANS_TO_DERREES(radians) (radians * 180 / M_PI)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RGBColorAlpha(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]

#define kColorBlue1             [UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1]
#define kColorBlue3             [UIColor colorWithRed:51/255.0 green:77/255.0 blue:132/255.0 alpha:1]
#define kColorWhite             [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]
#define kColorOrange            [UIColor colorWithRed:255/255.0 green:152/255.0 blue:19/255.0 alpha:1]
#define kColorLightGreen        [UIColor colorWithRed:83/255.0 green:215/255.0 blue:105/255.0 alpha:1]
#define kColorGreen2            [UIColor colorWithRed:34/255.0 green:195/255.0 blue:95/255.0 alpha:1]
#define kColorGray1             [UIColor colorWithRed:31/255.0 green:31/255.0 blue:31/255.0 alpha:1]
#define kColorGrey2             [UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1]
#define kColorGrey3             [UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0 alpha:1]
#define kColorGrey4             [UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1]
#define kColorGrey5             [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]
#define kColorGrey6             [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1]
#define kColorGrey7             [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]
#define kColorRed               [UIColor colorWithRed:245/255.0 green:52/255.0 blue:47/255.0 alpha:1]
#define kColorWhite             [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]

/** 第二版 */
#define kColorClear             [UIColor clearColor]
#define kColorNewBackground     [UIColor colorWithRed:236/255.0 green:238/255.0 blue:240/255.0 alpha:1]
#define kColorNewLine           [UIColor colorWithRed:220/255.0 green:223/255.0 blue:228/255.0 alpha:1]
#define kColorNewGray1          [UIColor colorWithRed:74/255.0 green:87/255.0 blue:108/255.0 alpha:1]
#define kColorNewGray2          [UIColor colorWithRed:144/255.0 green:154/255.0 blue:171/255.0 alpha:1]
#define kColorNewGray3          [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1]
#define kColorNewOrange         [UIColor colorWithRed:250/255.0 green:140/255.0 blue:0 alpha:1]
#define kColorBlue              [UIColor colorWithRed:0/255.0 green:110/255.0 blue:191/255.0 alpha:1]
#define kColorBlueH             [UIColor colorWithRed:0/255.0 green:84/255.0 blue:144/255.0 alpha:1]
#define kColorBlueD             [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1]
#define kColorBlue2             [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1]
#define kColorBlue2H            [UIColor colorWithRed:0/255.0 green:96/255.0 blue:200/255.0 alpha:1]
#define kColorNewBlue3          [UIColor colorWithRed:32/255.0 green:160/255.0 blue:247/255.0 alpha:1]
#define kColorNeWRed            [UIColor colorWithRed:245/255.0 green:52/255.0 blue:47/255.0 alpha:1]
#define kColorNeWGreen          [UIColor colorWithRed:83/255.0 green:215/255.0 blue:105/255.0 alpha:1]
#define kColorNeWGreen1         [UIColor colorWithRed:70/255.0 green:199/255.0 blue:92/255.0 alpha:1]
#define kColorNewGreen2         [UIColor colorWithRed:84/255.0 green:216/255.0 blue:58/255.0 alpha:1]
#define kColorNewGreenH         [UIColor colorWithRed:71/255.0 green:183/255.0 blue:89/255.0 alpha:1]
#define kColorNeWGreen3         [UIColor colorWithRed:53/255.0 green:170/255.0 blue:73/255.0 alpha:1]
#define kColorRed1              [UIColor colorWithRed:255/255.0 green:74/255.0 blue:74/255.0 alpha:1]
#define kColorRed1H             [UIColor colorWithRed:210/255.0 green:58/255.0 blue:58/255.0 alpha:1]

#define kColorSwitchGreen       [UIColor colorWithRed:88/255.0 green:219/255.0 blue:119/255.0 alpha:1]
#define kColorGuideBG           [UIColor colorWithRed:253/255.0 green:228/255.0 blue:161/255.0 alpha:1]

// font
#define kFontSuper              [UIFont boldSystemFontOfSize:20]
#define kFontLarge1             [UIFont systemFontOfSize:17]
#define kFontLarge1_b           [UIFont boldSystemFontOfSize:17]
#define kFontLarge              [UIFont systemFontOfSize:15]

#define kFontLarge_b            [UIFont boldSystemFontOfSize:15]

#define kFontNormal             [UIFont systemFontOfSize:14]
#define kFontMiddle             [UIFont systemFontOfSize:13]
#define kFontSmall              [UIFont systemFontOfSize:12]
#define kFontSmallBold          [UIFont boldSystemFontOfSize:12]
#define kFontTiny               [UIFont systemFontOfSize:11]
#define kFontMini               [UIFont systemFontOfSize:10]

// pixel
#define kLinePixel  0.5
#define kUnkown     0

// 横条按钮的高度
#define kLineButtonHeight 46

// animation speed
#define kAnimateSpeedFlash    0.2
#define kAnimateSpeedFast     0.3
#define kAnimateSpeedNormal   0.4

// emotion
#define kImageRequestWarning    [UIImage imageNamed:@"tips_icon_warning"]
#define kImageRequestSuccess    [UIImage imageNamed:@"tips_icon_success"]
#define kImageRequestError      [UIImage imageNamed:@"tips_icon_error"]
#define kImageRequestLoading    [UIImage imageNamed:@"popup_loading_icon"]

// refresh time
#define kAttentionRefreshTime  600

// 渠道: App Store, 91 Market, Apple Yuan, PP, Tong Bu Tui, XY, AutoHome, Beta
#define kChannel_AppStore   @"App Store"
#define kChannel_91         @"91 Market"
#define kChannel_AppleYuan  @"Apple Yuan"
#define kChannel_PP         @"PP"
#define kChannel_TongBuTui  @"Tong Bu Tui"
#define kChannel_XY         @"XY"
#define kChannel_AutoHome   @"AutoHome"
#define kChannel_Beta       @"Beta"
#define kChannel_TongCe     @"TC"

/**
 *  获取屏幕物理高度
 */
#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
#define HEIGHT_SCALE  ([[UIScreen mainScreen]bounds].size.height/480.0)
//get the  size of the Application
#define APP_HEIGHT [[UIScreen mainScreen]applicationFrame].size.height
#define APP_WIDTH [[UIScreen mainScreen]applicationFrame].size.width

#import <Foundation/Foundation.h>

@class AreaProvinceItem;
@class AreaCityItem;
@class UCAreaMode;

typedef enum {
    UserStyleNone = 0,
    UserStyleBusiness = 1,
    UserStylePersonal = 2,
    UserStylePhone = 3,
} UserStyle;

@interface OMG : NSObject


+ (CGFloat)degreesToRadians:(CGFloat)degrees;
+ (CGFloat)radiansToDegrees:(CGFloat)radians;

+ (NSString *)openUDID;

/* 是否有效点击 */
+ (BOOL)isValidClick;
+ (BOOL)isValidClick:(NSTimeInterval)intervalTime;

/* 根据车龄属性得出车龄显示文字 */
+ (NSDate *)dateFromStringWithFormat:(NSString *)format string:(NSString *)string;
+ (NSString *)stringFromDateWithFormat:(NSString *)format date:(NSDate *)date;

/** 热门地区表 */
+ (NSArray *)hotArea;
/* 省市表 */
+ (NSArray *)areaProvinces;
/** 根据城市ID获得地点实体 */
+ (UCAreaMode *)areaModelWithCid:(NSString *)cid;
/** 根据省份ID获取省份实体 */
+ (AreaProvinceItem *)areaProvince:(NSInteger)PI;
/** 根据城市名称获得城市实体 */
+ (UCAreaMode *)areaCityWithCityName:(NSString *)name;
/** 根据城市ID和省份实体获取城市实体 */
+ (AreaCityItem *)areaCity:(NSInteger)CI apItem:(AreaProvinceItem *)apItem;
/** 根据新车报价url获得"filterModel + areaModel"的NSArray */
+ (NSArray *)getFilterModelAndAreaModelArrayWithUrl:(NSString *)strCarPrice;

/** 播放电话 */
+ (BOOL)callPhone:(NSString *)num;

/** 友盟统计 */
+ (void)umengEvent:(NSString *)eventId;
+ (void)umengBeginEvent:(NSString *)eventId;
+ (void)umengEndEvent:(NSString *)eventId;
+ (void)umengBeginLogPageName:(NSString *)name;
+ (void)umengEndLogPageName:(NSString *)name;
+ (void)umengBeginLogPageView:(UIView *)view;
+ (void)umengEndLogPageView:(UIView *)view;

/** 使用颜色生成图片 **/
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

/** 设置观察者模式 */
+(void)setKVOWithModel:(id)model isOpen:(BOOL)isOpen delegate:(id)delegate;


/** 日期计算方法 **/
+(NSDateFormatter*)defaultDateFormatter;
+(NSString *)FormattedStringOfNSDate:(NSDate*)date inTimeZone:(NSTimeZone*)timeZone Format:(NSString*)format;
/** 年月日的字符串 */
+(NSString *)YMDStringOfNSDate:(NSDate*)date inTimeZone:(NSTimeZone*)timeZone;
/** 距离当前时间 */
+ (NSString *)intervalSinceNow: (NSDate *)fromDate;

/** 验证是否全为数字 **/
+(BOOL)isValidateNumbers:(NSString *)numbers;

/** 验证是否合法的手机号 **/
+(BOOL)isValidateMobile:(NSString *)mobile;

/** 验证是否为合法用户名 **/
+(BOOL)isValidateUserName:(NSString *)userName;

//返回字数，区分中文英文的占位字节
+ (NSInteger)textLength:(NSString *)text;

//返回中英文的实际字符数
+ (NSInteger)charLengthOfText:(NSString *)text;

/** 发车时间联动 */
+ (NSString *)dateCheckForTag:(NSInteger)tag year:(NSInteger)year month:(NSInteger)month;
/** 发车构建时间 */
+ (NSMutableArray *)buildDateSource:(NSInteger)incremental strDate:(NSString *)strDate row0:(NSInteger *)row0 row1:(NSInteger *)row1;

@end
