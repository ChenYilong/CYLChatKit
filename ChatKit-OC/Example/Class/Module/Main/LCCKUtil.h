//
//  LCCKUtil.h
//  LeanCloudChatKit-iOS
//
//  Created by ElonChan on 18/6/26.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

@import Foundation;
@import UIKit;
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

@interface LCCKUtil : NSObject

+ (BOOL)isIPhoneX;

+ (NSError *)errorWithText:(NSString *)text;
+ (void)showProgressText:(NSString *)text duration:(NSTimeInterval)duration;
+ (void)showProgress;
+ (void)hideProgress;

/**
 *  显示提示信息
 */
+ (void)showNotificationWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                             type:(LCCKMessageNotificationType)type;

/**
 *  显示提示信息
 */
+ (void)showNotificationWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                             type:(LCCKMessageNotificationType)type
                         duration:(CGFloat)duration;

/**
 *  显示提示信息
 */
+ (void)hideNotification;

+ (CGSize)sizeFromOSSURLString:(NSString *)URLString;

+ (BOOL)containsQRInfoFromOSSURLString:(NSString *)URLString;

@end
