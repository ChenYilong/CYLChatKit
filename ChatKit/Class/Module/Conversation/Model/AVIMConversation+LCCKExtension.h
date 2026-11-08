//
//  AVIMConversation+LCCKExtension.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/11.
//  Copyright © 2016年 ElonChan . All rights reserved.
//
#import <AVOSCloudIM/AVIMConversation.h>
#import "LCCKConversationService.h"
#import "LCCKConstants.h"
#import "LCCKConstants.h"

@interface AVIMConversation (LCCKExtension)

/**
 *  最后一条消息。通过 SDK 的消息缓存找到的
 */
@property (nonatomic, strong, readonly) AVIMTypedMessage *lcck_lastMessage;
@property (nonatomic, strong, readonly) NSDate *lcck_lastMessageAt;

/*!
 * 如果未读消息数未超出100，显示数字，否则显示省略号
 */
- (NSString *)lcck_badgeText;

/*!
 * 草稿
 */
@property (nonatomic, copy) NSString *lcck_draft;

/**
 *  对话的类型，通过成员数量来判断。系统对话按照群聊来处理。
 *
 *  @return 单聊或群聊
 */
- (LCCKConversationType)lcck_type;

/**
 *  单聊对话的对方的 clientId
 */
- (NSString *)lcck_peerId;

/**
 *  对话显示的名称。单聊显示对方名字，群聊显示对话的 name
 */
- (NSString *)lcck_displayName;

/**
 *  对话的标题。如 兴趣群(30)
 */
- (NSString *)lcck_title;

- (void)lcck_setConversationWithMute:(BOOL)mute callback:(LCCKBooleanResultBlock)callback;
- (BOOL)lcck_isCreaterForCurrentUser;

@end
