//
//  AVIMConversation+CYLDemoExtension.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/11.
//  Copyright © 2016年 ElonChan . All rights reserved.
//
//  Moved from ChatKit to the demo: ChatKit no longer depends on LeanCloud.
//  This category makes `AVIMConversation` conform to ChatKit's `CYLConversationProtocol`.
//
#import <AVOSCloudIM/AVOSCloudIM.h>
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif
#import "AVIMTypedMessage+CYLDemoExtension.h"

@interface AVIMConversation (CYLDemoExtension) <CYLConversationProtocol>

/**
 *  最后一条消息。通过 SDK 的消息缓存找到的
 */
@property (nonatomic, strong, readonly) AVIMTypedMessage *cyl_lastMessage;
@property (nonatomic, strong, readonly) NSDate *cyl_lastMessageAt;

/**
 *  未读消息数，即 `unreadMessagesCount`
 */
- (NSInteger)cyl_unreadCount;

/**
 *  是否有人提到了你，即 `unreadMessagesMentioned`
 */
- (BOOL)cyl_mentioned;

/*!
 * 如果未读消息数未超出100，显示数字，否则显示省略号
 */
- (NSString *)cyl_badgeText;

/*!
 * 草稿
 */
@property (nonatomic, copy) NSString *cyl_draft;

/**
 *  对话的类型，通过成员数量来判断。系统对话按照群聊来处理。
 *
 *  @return 单聊或群聊
 */
- (CYLConversationType)cyl_type;

/**
 *  单聊对话的对方的 clientId
 */
- (NSString *)cyl_peerId;

/**
 *  对话显示的名称。单聊显示对方名字，群聊显示对话的 name
 */
- (NSString *)cyl_displayName;

/**
 *  对话的标题。如 兴趣群(30)
 */
- (NSString *)cyl_title;

- (void)cyl_setConversationWithMute:(BOOL)mute callback:(CYLBooleanResultBlock)callback;
- (BOOL)cyl_isCreaterForCurrentUser;

@end
