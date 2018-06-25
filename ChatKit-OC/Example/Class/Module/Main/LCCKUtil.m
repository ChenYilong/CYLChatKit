//
//  LCCKUtil.m
//  LeanCloudChatKit-iOS
//
//  Created by ElonChan on 18/6/26.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "LCCKUtil.h"
#import "TWMessageBarManager.h"
//#import "MBProgressHUD.h"
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif
#import <sys/utsname.h>

@implementation LCCKUtil

+ (NSError *)errorWithText:(NSString *)text {
    NSInteger code = 0;
    NSString *errorReasonText = text;
    NSDictionary *errorInfo = @{
                                @"code" : @(code),
                                NSLocalizedDescriptionKey : errorReasonText,
                                };
    NSError *error = [NSError errorWithDomain:@"LeanCloudChatKitExample"
                                         code:code
                                     userInfo:errorInfo];
    
    
    return error;
}

+ (void)showProgressText:(NSString *)text duration:(NSTimeInterval)duration {
    id<UIApplicationDelegate> delegate = ((id<UIApplicationDelegate>)[[UIApplication sharedApplication] delegate]);
    UIWindow *window = delegate.window;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    //    hud.labelText=text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:14];
    hud.detailsLabelText = text;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud hide:YES afterDelay:duration];
}

+ (void)showProgress {
    id<UIApplicationDelegate> delegate = ((id<UIApplicationDelegate>)[[UIApplication sharedApplication] delegate]);
    UIWindow *window = delegate.window;
    [MBProgressHUD showHUDAddedTo:window animated:YES];
}

+ (void)hideProgress {
    id<UIApplicationDelegate> delegate = ((id<UIApplicationDelegate>)[[UIApplication sharedApplication] delegate]);
    UIWindow *window = delegate.window;
    [MBProgressHUD hideHUDForView:window animated:YES];
}

+ (void)showNotificationWithTitle:(NSString *)title subtitle:(NSString *)subtitle type:(LCCKMessageNotificationType)type duration:(CGFloat)duration {
    /**
     在这里使用了LCChatKit提供的默认样式显示提示信息
     在你的app中，也可以换成你app中已有的提示方式
     */
    
    //TODO:
    TWMessageBarMessageType type_;
    switch (type) {
        case LCCKMessageNotificationTypeError:
            type_ = TWMessageBarMessageTypeError;
            break;
        case LCCKMessageNotificationTypeSuccess:
            type_ = TWMessageBarMessageTypeSuccess;
            break;
        case LCCKMessageNotificationTypeWarning:
            type_ = TWMessageBarMessageTypeInfo;
            break;
        case LCCKMessageNotificationTypeMessage:
            type_ = TWMessageBarMessageTypeInfo;
            break;
    }
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:title
                                                   description:subtitle
                                                          type:type_
                                                      duration:duration
                                                      callback:nil];
}

+ (void)showNotificationWithTitle:(NSString *)title subtitle:(NSString *)subtitle type:(LCCKMessageNotificationType)type {
    [self showNotificationWithTitle:title subtitle:subtitle type:type duration:1.f];
}

+ (void)hideNotification {
    [[TWMessageBarManager sharedInstance] hideAll];
}

+ (BOOL)isIPhoneX {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"]) {
        return (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) ||
                CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)));
    }
    // iPhone10,6是美版iPhoneX
    BOOL isIPhoneX = [platform isEqualToString:@"iPhone10,3"] || [platform isEqualToString:@"iPhone10,6"];
    return isIPhoneX;
}

/*!
*
* [self sizeFromOSSURLString:@"https://hdl-emas-app-bucket.oss-cn-beijing.aliyuncs.com/invest_card-containsqrinfo-501-767.png"];
 */
+ (CGSize)sizeFromOSSURLString:(NSString *)URLString {
    NSArray *array = [URLString componentsSeparatedByString:@"-"];
    if (array.count < 2) {
        return CGSizeZero;
    }
    id lastObject = array.lastObject;
    id lastSecondObject = array[(array.count - 2)];
    if ([[self class] isValidString:lastObject] && [[self class] isValidString:lastSecondObject]) {
        CGFloat height = 0;
        CGFloat width = 0;
        width = [lastSecondObject floatValue];
        NSArray *array = [lastObject componentsSeparatedByString:@"."];
        if (array.count < 2) {
            return CGSizeZero;
        }
        NSString *string = array[(array.count - 2)];
        if ([[self class] isValidString:string]) {
            height = [string floatValue];
        }
        if ((width > 0) && (height > 0)) {
            LCCKLog(@"🔴类名与方法名：%@（在第%@行），描述：%@--%@", @(__PRETTY_FUNCTION__), @(__LINE__), @(width), @(height));
            return CGSizeMake(width, height);
        }
    }
    return CGSizeZero;
}

+ (BOOL)containsQRInfoFromOSSURLString:(NSString *)URLString {
    BOOL containsqrinfo = [URLString containsString:@"containsqrinfo"];
    return containsqrinfo;
}

+ (BOOL)isValidString:(id)notValidString {
    if (!notValidString) {
        return NO;
    }
    BOOL isKindOf = NO;
    @try {
        isKindOf = [notValidString isKindOfClass:[NSString class]];
    } @catch (NSException *exception) {}
    if (!isKindOf) {
        return NO;
    }
    
    NSInteger stringLength = 0;
    @try {
        stringLength = [notValidString length];
    } @catch (NSException *exception) {}
    if (stringLength == 0) {
        return NO;
    }
    return YES;
}

@end

