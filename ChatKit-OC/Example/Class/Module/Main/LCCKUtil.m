//
//  LCCKUtil.m
//  LeanCloudChatKit-iOS
//
//  Created by ElonChan on 16/2/26.
//  Copyright © 2016年 LeanCloud. All rights reserved.
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

@end
