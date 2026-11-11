//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit


#import <UIKit/UIKit.h>

@interface UIFont (CYLDemoExtension)

#pragma mark - Common
+ (UIFont *)cyl_demo_fontNavBarTitle;

#pragma mark - Conversation
+ (UIFont *)cyl_demo_fontConversationUsername;
+ (UIFont *)cyl_demo_fontConversationDetail;
+ (UIFont *)cyl_demo_fontConversationTime;

#pragma mark - Friends
+ (UIFont *)cyl_demo_fontFriendsUsername;

#pragma mark - Mine
+ (UIFont *)cyl_demo_fontMineNikename;
+ (UIFont *)cyl_demo_fontMineUsername;

#pragma mark - Setting
+ (UIFont *)cyl_demo_fontSettingHeaderAndFooterTitle;


#pragma mark - Chat
+ (UIFont *)cyl_demo_fontTextMessageText;

@end
