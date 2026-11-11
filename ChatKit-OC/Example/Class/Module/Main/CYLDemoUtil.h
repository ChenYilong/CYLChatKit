//
//  CYLDemoUtil.h
//  LeanCloudChatKit-iOS
//
//  Created by ElonChan on 16/2/26.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

@import Foundation;
@import UIKit;
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif
@interface CYLDemoUtil : NSObject

+ (NSError *)errorWithText:(NSString *)text;
+ (void)showProgressText:(NSString *)text duration:(NSTimeInterval)duration;
+ (void)showProgress;
+ (void)hideProgress;

/**
 *  显示提示信息
 */
+ (void)showNotificationWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                             type:(CYLMessageNotificationType)type;

/**
 *  显示提示信息
 */
+ (void)showNotificationWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                             type:(CYLMessageNotificationType)type
                         duration:(CGFloat)duration;

/**
 *  显示提示信息
 */
+ (void)hideNotification;

@end
