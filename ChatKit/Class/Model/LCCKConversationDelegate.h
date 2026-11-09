//
//  LCCKConversationDelegate.h
//  CYLChatKit
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//
//  The conversation model ChatKit's UI layer works with.
//  ChatKit does not depend on any IM SDK; an `LCCKIMProvider` hands conversation objects
//  conforming to this protocol to the UI. For example, the LeanCloud provider in the demo
//  makes `AVIMConversation` conform through a category.

#import <Foundation/Foundation.h>
#import "LCCKConstants.h"
#import "LCCKIMMessageDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * A conversation shown by ChatKit.
 * @attention Members are declared as methods instead of properties so that an existing SDK
 *            class can conform through a category without property attribute conflicts.
 */
@protocol LCCKConversationDelegate <NSObject>

@required

#pragma mark - Basic information

/// The unique id of the conversation.
- (nullable NSString *)conversationId;

/// The name of the conversation. May be nil for one-to-one conversations.
- (nullable NSString *)name;

/// The client id of the creator.
- (nullable NSString *)creator;

/// The client ids of all members.
- (nullable NSArray<NSString *> *)members;

/// Custom attributes of the conversation, for example the group avatar URL.
- (nullable NSDictionary *)attributes;

/// Whether the current user muted the conversation.
- (BOOL)muted;

/// Creation date. ChatKit treats a conversation without a creation date as not yet fetched.
- (nullable NSDate *)createAt;

/// Whether this is a transient (chat room) conversation without a member list.
- (BOOL)transient;

#pragma mark - ChatKit display information

/// One-to-one or group conversation.
- (LCCKConversationType)lcck_type;

/// The client id of the other member of a one-to-one conversation.
- (nullable NSString *)lcck_peerId;

/// The name to display: the peer's name for a one-to-one conversation, otherwise the conversation name.
- (nullable NSString *)lcck_displayName;

/// The navigation title, such as `Group(30)`.
- (nullable NSString *)lcck_title;

/// The text of the unread badge. Numbers above 99 are shown as an ellipsis.
- (nullable NSString *)lcck_badgeText;

/// The unsent draft for this conversation.
- (nullable NSString *)lcck_draft;
- (void)setLcck_draft:(nullable NSString *)lcck_draft;

/// The number of unread messages.
- (NSInteger)lcck_unreadCount;

/// Whether an unread message mentions the current user.
- (BOOL)lcck_mentioned;

/*!
 * The last message visible to the current user, used for the conversation list preview.
 * It is the IM SDK message, not converted for display, so every media type keeps its preview text.
 */
- (nullable id<LCCKIMMessageDelegate>)lcck_lastMessage;

/// The date of the last message.
- (nullable NSDate *)lcck_lastMessageAt;

/// Whether the current user created the conversation. The historical spelling is kept for compatibility.
- (BOOL)lcck_isCreaterForCurrentUser;

/// Mutes or unmutes the conversation.
- (void)lcck_setConversationWithMute:(BOOL)mute callback:(nullable LCCKBooleanResultBlock)callback;

@end

NS_ASSUME_NONNULL_END
