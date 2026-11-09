//
//  LCCKIMMessageProtocol.h
//  CYLChatKit
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//
//  A message object owned by the IM SDK behind an `LCCKIMProvider`.
//  ChatKit treats these objects as opaque: it only reads the members below.
//  Built-in messages are converted to `LCCKMessage` for display; a message whose
//  `mediaType` is greater than 0 is a custom message and is passed to its registered
//  custom cell as-is. For example, the LeanCloud provider in the demo makes
//  `AVIMTypedMessage` conform through a category.

#import <Foundation/Foundation.h>
#import "LCCKConstants.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * @attention Members are declared as methods instead of properties so that an existing SDK
 *            class can conform through a category without property attribute conflicts.
 */
@protocol LCCKIMMessageProtocol <NSObject>

@required

/// The media type. Values greater than 0 are custom messages.
- (LCCKMessageMediaType)mediaType;

/// The server message id. Nil before the message is sent.
- (nullable NSString *)messageId;

/// The id of the conversation the message belongs to.
- (nullable NSString *)conversationId;

/// The text content. Used for the conversation list preview of text messages.
- (nullable NSString *)text;

/// Whether the message mentions the current user.
- (BOOL)mentioned;

/// Custom attributes, such as `LCCKCustomMessageTypeTitleKey`.
- (nullable NSDictionary *)attributes;
- (void)setAttributes:(nullable NSDictionary *)attributes;

/// The client id of the sender.
- (nullable NSString *)lcck_senderId;
- (void)setLcck_senderId:(nullable NSString *)senderId;

/// Whether the current user sent the message.
- (LCCKMessageOwnerType)lcck_ownerType;

/// The send state.
- (LCCKMessageSendState)lcck_sendStatus;

/// Send time in milliseconds since 1970. 0 while the message is still being sent.
- (int64_t)lcck_sendTimestamp;

@end

NS_ASSUME_NONNULL_END
