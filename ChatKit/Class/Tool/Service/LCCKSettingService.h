//
//  LCCKSettingService.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/23.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//  Service for common chat setting.

#import <Foundation/Foundation.h>
#import "LCCKServiceDefinition.h"
/*!
 * LCCKSettingService Error Domain
 */
FOUNDATION_EXTERN NSString *const LCCKSettingServiceErrorDomain;

#define LCCK_STRING_BY_SEL(sel) NSStringFromSelector(@selector(sel))

@interface LCCKSettingService : LCCKSingleton <LCCKSettingService>

@property (nonatomic, strong, readonly) NSDictionary *defaultSettings;
@property (nonatomic, strong, readonly) NSDictionary *defaultTheme;
@property (nonatomic, strong, readonly) NSDictionary *messageBubbleCustomizeSettings;

//TODO:
/*!
 * 1. 设置离线推送
 * 2. 设置未读消息
 * 3. 推送相关设置
 * 4. Others
 */

/**
 *  图片消息，临时的压缩图片路径
 *  @return
 */
- (NSString *)tmpPath;

/**
 *  根据消息的 id 获取声音文件的路径
 *  @param objectId 消息的 id
 *  @return 文件路径
 */
- (NSString *)getPathByObjectId:(NSString *)objectId;

/*!
 *  根据消息来获取视频文件的路径。
 */
/*!
 * @param message A video message conforming to `LCCKIMMessageDelegate`. If it responds to `format`, the format is used as the file extension.
 */
- (NSString *)videoPathOfMessage:(id<LCCKIMMessageDelegate>)message;

// please call in application:didFinishLaunchingWithOptions:launchOptions
/*!
 * Push and badge methods are forwarded to `-[LCChatKit IMProvider]` when it implements `LCCKIMPushProvider`.
 */
- (void)registerForRemoteNotification;
- (void)saveInstallationWithDeviceToken:(NSData *)deviceToken userId:(NSString *)userId;

// push message
- (void)pushMessage:(NSString *)message userIds:(NSArray *)userIds block:(LCCKBooleanResultBlock)block;

// please call in applicationDidBecomeActive:application
- (void)cleanBadge;

//save the local applicationIconBadgeNumber to the server
- (void)syncBadge;

- (UIColor *)defaultThemeColorForKey:(NSString *)key;
- (UIFont *)defaultThemeTextMessageFont;

/**
 * @param capOrEdge 分为：cap_insets和edge_insets
 * @param position 主要分为：CommonLeft、CommonRight等
 */
- (UIEdgeInsets)messageBubbleCustomizeSettingsForPosition:(NSString *)position capOrEdge:(NSString *)capOrEdge;
- (UIEdgeInsets)rightCapMessageBubbleCustomize;
- (UIEdgeInsets)rightEdgeMessageBubbleCustomize;
- (UIEdgeInsets)leftCapMessageBubbleCustomize;
- (UIEdgeInsets)leftEdgeMessageBubbleCustomize;
- (UIEdgeInsets)rightHollowCapMessageBubbleCustomize;
- (UIEdgeInsets)rightHollowEdgeMessageBubbleCustomize;
- (UIEdgeInsets)leftHollowCapMessageBubbleCustomize;
- (UIEdgeInsets)leftHollowEdgeMessageBubbleCustomize;

- (NSString *)imageNameForMessageBubbleCustomizeForPosition:(NSString *)position normalOrHighlight:(NSString *)normalOrHighlight;
- (NSString *)leftNormalImageNameMessageBubbleCustomize;
- (NSString *)leftHighlightImageNameMessageBubbleCustomize;
- (NSString *)rightHighlightImageNameMessageBubbleCustomize;
- (NSString *)rightNormalImageNameMessageBubbleCustomize;
- (NSString *)hollowRightNormalImageNameMessageBubbleCustomize;
- (NSString *)hollowRightHighlightImageNameMessageBubbleCustomize;
- (NSString *)hollowLeftNormalImageNameMessageBubbleCustomize;
- (NSString *)hollowLeftHighlightImageNameMessageBubbleCustomize;

@end
