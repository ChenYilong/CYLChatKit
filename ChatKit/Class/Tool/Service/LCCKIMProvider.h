//
//  LCCKIMProvider.h
//  CYLChatKit
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//
//  The interface between ChatKit's UI layer and an IM backend.
//
//  ChatKit itself does not link any IM SDK. The app implements `LCCKIMProvider` with the IM SDK
//  it uses and registers it once, before opening a session:
//
//  ```
//  [LCChatKit sharedInstance].IMProvider = [MyIMProvider new];
//  ```
//
//  The demo app (`ChatKit-OC`) contains a complete LeanCloud implementation,
//  `LCCKLeanCloudIMProvider`.
//
//  Notification contract. The provider posts the following notifications, defined in
//  `LCCKConstants.h`, so the UI can refresh. Conversation values conform to
//  `LCCKConversationDelegate`; message values conform to `LCCKIMMessageDelegate`.
//
//  - `LCCKNotificationMessageReceived`: object is a dictionary with
//    `LCCKMessageNotifacationUserInfoConversationKey` and `LCCKDidReceiveMessagesUserInfoMessagesKey`
//    (an array of messages).
//  - `LCCKNotificationMessageUpdated` and `LCCKNotificationMessageDelivered`: object is a dictionary
//    with `LCCKMessageNotifacationUserInfoConversationKey` and `LCCKMessageNotifacationUserInfoMessageKey`.
//  - `LCCKNotificationCustomTransientMessageReceived`: object is a dictionary with
//    `LCCKMessageNotifacationUserInfoConversationKey` and `LCCKDidReceiveCustomMessageUserInfoMessageKey`.
//  - `LCCKNotificationConnectivityUpdated`: object is an `NSNumber` BOOL of the connection state.
//  - `LCCKNotificationSessionResumed`, `LCCKNotificationUnreadsUpdated`,
//    `LCCKNotificationConversationListDataSourceUpdated`: no payload is required.
//  - `LCCKNotificationConversationInvalided` and `LCCKNotificationCurrentConversationInvalided`:
//    object is the client id of the member who removed the current user.

#import <Foundation/Foundation.h>
#import "LCCKConstants.h"
#import "LCCKConversationDelegate.h"
#import "LCCKIMMessageDelegate.h"

@class LCCKMessage;

NS_ASSUME_NONNULL_BEGIN

typedef void (^LCCKIMConversationResultBlock)(id<LCCKConversationDelegate> _Nullable conversation, NSError * _Nullable error);
typedef void (^LCCKIMMessageResultBlock)(BOOL succeeded, NSError * _Nullable error, id<LCCKIMMessageDelegate> _Nullable message);
typedef void (^LCCKIMRecentConversationsResultBlock)(NSArray<id<LCCKConversationDelegate>> * _Nullable conversations, NSInteger totalUnreadCount, NSError * _Nullable error);

#pragma mark - Session

/// Opening and closing the IM session of the current user.
@protocol LCCKIMSessionProvider <NSObject>

@required

/// The client id of the current user, or nil before a session is opened.
- (nullable NSString *)clientId;

/// Whether the client is connected to the IM server. Drives the connection status bar.
- (BOOL)isConnected;

/// Whether the session is opened. ChatKit asks the app to reconnect when it is not.
- (BOOL)isClientOpened;

/*!
 * Opens the session. ChatKit has already validated `clientId`.
 * The provider sets up its local storage for the user here, and calls
 * `-[LCCKSessionService handleSingleSignOnError:callback:]` when another device takes over the session.
 * @param force Whether to kick other devices logged in with the same client id.
 */
- (void)openWithClientId:(NSString *)clientId force:(BOOL)force callback:(nullable LCCKBooleanResultBlock)callback;

/// Closes the session. ChatKit resets its services after a successful close.
- (void)closeWithCallback:(nullable LCCKBooleanResultBlock)callback;

@optional

/// The underlying SDK client object, exposed for app code that needs SDK-specific features.
- (nullable id)client;

/// Called by `+[LCChatKit setAppId:appKey:]` so the provider can initialize its SDK.
- (void)setAppId:(NSString *)appId appKey:(NSString *)appKey;

/// Called by `+[LCChatKit setAllLogsEnabled:]`.
- (void)setAllLogsEnabled:(BOOL)enabled;

@end

#pragma mark - Conversation

/// Fetching, creating, and joining conversations.
@protocol LCCKIMConversationProvider <NSObject>

@required

- (void)fetchConversationWithConversationId:(NSString *)conversationId callback:(nullable LCCKIMConversationResultBlock)callback;

/// The callback array contains objects conforming to `LCCKConversationDelegate`.
- (void)fetchConversationsWithConversationIds:(NSSet<NSString *> *)conversationIds callback:(nullable LCCKArrayResultBlock)callback;

/// Fetches, or creates if needed, the one-to-one conversation with `peerId`.
- (void)fetchConversationWithPeerId:(NSString *)peerId callback:(nullable LCCKIMConversationResultBlock)callback;

/*!
 * @param unique If YES, an existing conversation with the same members is returned instead of creating a new one.
 */
- (void)createConversationWithMembers:(NSArray<NSString *> *)members
                                 type:(LCCKConversationType)type
                               unique:(BOOL)unique
                             callback:(nullable LCCKIMConversationResultBlock)callback;

/// Adds the current user to the conversation. Used when `enableAutoJoin` is YES.
- (void)joinConversation:(id<LCCKConversationDelegate>)conversation callback:(nullable LCCKBooleanResultBlock)callback;

/// Marks all messages of the conversation as read on the server and clears its mention flag.
- (void)markConversationAsRead:(id<LCCKConversationDelegate>)conversation;

@optional

/// Called before ChatKit uses a conversation, for example to attach it to the current SDK client.
- (void)prepareConversation:(id<LCCKConversationDelegate>)conversation;

@end

#pragma mark - Message

/// Converting, sending, loading, editing, and recalling messages.
@protocol LCCKIMMessageProvider <NSObject>

@required

/*!
 * Converts an SDK message for display.
 * @return An `LCCKMessage` for a built-in media type, the message itself for a supported custom
 *         message, or nil if the message should not be displayed (for example, a recalled message).
 */
- (nullable id)displayMessageFromIMMessage:(id<LCCKIMMessageDelegate>)message;

/*!
 * Converts a message the UI wants to send into an SDK message.
 * @param message An `LCCKMessage`, or a custom message that already conforms to `LCCKIMMessageDelegate`.
 * @return The SDK message, or nil if the message cannot be sent.
 */
- (nullable id<LCCKIMMessageDelegate>)IMMessageFromMessage:(id)message;

/*!
 * Sends a message.
 * @param mentionList Client ids mentioned in the message. May be empty.
 */
- (void)sendMessage:(id<LCCKIMMessageDelegate>)message
       conversation:(id<LCCKConversationDelegate>)conversation
        mentionList:(nullable NSArray<NSString *> *)mentionList
      progressBlock:(nullable LCCKProgressBlock)progressBlock
           callback:(nullable LCCKBooleanResultBlock)callback;

/*!
 * Loads history messages, newest last.
 * @param timestamp 0 loads the latest page; otherwise loads messages before `messageId` and `timestamp`.
 * The callback array contains objects conforming to `LCCKIMMessageDelegate`.
 */
- (void)queryMessagesWithConversation:(id<LCCKConversationDelegate>)conversation
                            messageId:(nullable NSString *)messageId
                            timestamp:(int64_t)timestamp
                                limit:(NSInteger)limit
                             callback:(nullable LCCKArrayResultBlock)callback;

/// Replaces the text of a sent message. The callback returns the new SDK message.
- (void)updateMessage:(id<LCCKIMMessageDelegate>)oldMessage
             withText:(NSString *)text
         conversation:(id<LCCKConversationDelegate>)conversation
             callback:(nullable LCCKIMMessageResultBlock)callback;

/// Recalls a sent message. The callback returns the recalled SDK message.
- (void)recallMessage:(id<LCCKIMMessageDelegate>)message
         conversation:(id<LCCKConversationDelegate>)conversation
             callback:(nullable LCCKIMMessageResultBlock)callback;

@optional

/*!
 * Downloads the attachment of a received image message to a local file.
 * If not implemented, ChatKit downloads `originPhotoURL` with `NSURLSession`.
 */
- (void)downloadAttachmentOfMessage:(LCCKMessage *)message
                         completion:(void (^)(NSURL * _Nullable filePath, NSError * _Nullable error))completion;

@end

#pragma mark - Recent conversations

/*!
 * The local store of recent conversations shown in the conversation list.
 * Methods taking `shouldRefreshWhenFinished` post `LCCKNotificationConversationListDataSourceUpdated`
 * when the flag is YES.
 */
@protocol LCCKIMRecentConversationProvider <NSObject>

@required

- (NSArray<id<LCCKConversationDelegate>> *)allRecentConversations;
- (BOOL)isRecentConversationExistWithConversationId:(NSString *)conversationId;
- (void)insertRecentConversations:(NSArray<id<LCCKConversationDelegate>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateRecentConversation:(NSArray<id<LCCKConversationDelegate>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)deleteRecentConversationWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateUnreadCountToZeroWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)increaseUnreadCount:(NSUInteger)increaseUnreadCount withConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateMentioned:(BOOL)mentioned conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateDraft:(nullable NSString *)draft conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (nullable NSString *)draftWithConversationId:(NSString *)conversationId;
- (BOOL)removeAllCachedRecentConversations;

/*!
 * Loads the conversations shown in the conversation list, sorted newest first, applying
 * `conversationListShowHookBlock` of `LCCKConversationListService`.
 */
- (void)findRecentConversationsWithBlock:(nullable LCCKIMRecentConversationsResultBlock)block;

/// Fetches the current user's conversations from the server.
- (void)fetchRelationConversationsFromServerCallback:(nullable LCCKArrayResultBlock)block;

@optional

/// Prepares the local store for a user. Providers usually do this when opening the session.
- (void)setupDatabaseWithUserId:(NSString *)userId;

@end

#pragma mark - Failed messages

/// The local store of messages that failed to send, so they can be shown and resent later.
@protocol LCCKIMFailedMessageProvider <NSObject>

@required

- (void)insertFailedLCCKMessage:(LCCKMessage *)message;
- (void)insertFailedMessage:(id<LCCKIMMessageDelegate>)message;
- (BOOL)deleteFailedMessageByRecordId:(NSString *)recordId;
- (NSArray<LCCKMessage *> *)failedMessagesByConversationId:(NSString *)conversationId;
- (NSArray<NSString *> *)failedMessageIdsByConversationId:(NSString *)conversationId;
- (nullable NSArray<LCCKMessage *> *)failedMessagesByMessageIds:(NSArray<NSString *> *)messageIds;

@end

#pragma mark - Push

/// Optional remote notification support.
@protocol LCCKIMPushProvider <NSObject>

@optional

- (void)registerForRemoteNotification;
- (void)saveInstallationWithDeviceToken:(NSData *)deviceToken userId:(nullable NSString *)userId;
- (void)pushMessage:(NSString *)message userIds:(NSArray<NSString *> *)userIds block:(nullable LCCKBooleanResultBlock)block;
- (void)cleanBadge;
- (void)syncBadge;
- (void)setUseDevPushCerticate:(BOOL)useDevPushCerticate;

@end

#pragma mark - Provider

/// Everything ChatKit needs from an IM backend.
@protocol LCCKIMProvider <LCCKIMSessionProvider,
                          LCCKIMConversationProvider,
                          LCCKIMMessageProvider,
                          LCCKIMRecentConversationProvider,
                          LCCKIMFailedMessageProvider,
                          LCCKIMPushProvider>
@end

NS_ASSUME_NONNULL_END
