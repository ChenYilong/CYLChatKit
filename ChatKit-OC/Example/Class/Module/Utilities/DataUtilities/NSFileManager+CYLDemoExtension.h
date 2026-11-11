//
//  CYLContactListViewController.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFileManager+Paths.h"

@interface NSFileManager (CYLDemoExtension_)

/**
 *  图片 — 设置
 */
+ (NSString *)cyl_demo_pathUserSettingImage:(NSString *)imageName userId:(NSString *)userId;

/**
 *  图片 — 聊天
 */
+ (NSString *)cyl_demo_pathUserChatImage:(NSString*)imageName userId:(NSString *)userId;

/**
 *  图片 — 聊天背景
 */
+ (NSString *)cyl_demo_pathUserChatBackgroundImage:(NSString *)imageName userId:(NSString *)userId;

/**
 *  图片 — 用户头像
 */
+ (NSString *)cyl_demo_pathUserAvatar:(NSString *)imageName userId:(NSString *)userId;

/**
 *  图片 — 屏幕截图
 */
+ (NSString *)cyl_demo_pathScreenshotImage:(NSString *)imageName;

/**
 *  图片 — 本地通讯录
 */
+ (NSString *)cyl_demo_pathContactsAvatar:(NSString *)imageName userId:(NSString *)userId;

/**
 *  聊天语音
 */
+ (NSString *)cyl_demo_pathUserChatVoice:(NSString *)voiceName userId:(NSString *)userId;

/**
 *  表情
 */
+ (NSString *)cyl_demo_pathExpressionForGroupID:(NSString *)groupID;

/**
 *  数据 — 本地通讯录
 */
+ (NSString *)cyl_demo_pathContactsData;

/**
 *  数据库 — 通用
 */
+ (NSString *)cyl_demo_pathDBCommonForUserId:(NSString *)userId;;

/**
 *  数据库 — 聊天
 */
+ (NSString *)cyl_demo_pathDBMessageForUserId:(NSString *)userId;;

/**
 *  缓存
 */
+ (NSString *)cyl_demo_cacheForFile:(NSString *)filename;


@end
