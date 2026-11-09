//
//  CYLIMProvider.h
//  CYLChatKit
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//
//  The interface between ChatKit's UI layer and an IM backend.
//
//  ChatKit itself does not link any IM SDK. The app implements `CYLIMProvider` with the IM SDK
//  it uses and registers it once, before opening a session:
//
//  ```
//  [LCChatKit sharedInstance].IMProvider = [MyIMProvider new];
//  ```
//
//  The demo app (`ChatKit-OC`) contains a complete LeanCloud implementation,
//  `CYLLeanCloudIMProvider`.
//
//  Notification contract. The provider posts the following notifications, defined in
//  `CYLChatConstants.h`, so the UI can refresh. Conversation values conform to
//  `CYLConversationProtocol`; message values conform to `CYLIMMessageProtocol`.
//
//  - `CYLNotificationMessageReceived`: object is a dictionary with
//    `CYLMessageNotifacationUserInfoConversationKey` and `CYLDidReceiveMessagesUserInfoMessagesKey`
//    (an array of messages).
//  - `CYLNotificationMessageUpdated` and `CYLNotificationMessageDelivered`: object is a dictionary
//    with `CYLMessageNotifacationUserInfoConversationKey` and `CYLMessageNotifacationUserInfoMessageKey`.
//  - `CYLNotificationCustomTransientMessageReceived`: object is a dictionary with
//    `CYLMessageNotifacationUserInfoConversationKey` and `CYLDidReceiveCustomMessageUserInfoMessageKey`.
//  - `CYLNotificationConnectivityUpdated`: object is an `NSNumber` BOOL of the connection state.
//  - `CYLNotificationSessionResumed`, `CYLNotificationUnreadsUpdated`,
//    `CYLNotificationConversationListDataSourceUpdated`: no payload is required.
//  - `CYLNotificationConversationInvalided` and `CYLNotificationCurrentConversationInvalided`:
//    object is the client id of the member who removed the current user.

#import <Foundation/Foundation.h>
#import "CYLChatConstants.h"
#import "CYLConversationProtocol.h"
#import "CYLIMMessageProtocol.h"

@class CYLMessage;

NS_ASSUME_NONNULL_BEGIN

typedef void (^CYLIMConversationResultBlock)(id<CYLConversationProtocol> _Nullable conversation, NSError * _Nullable error);
typedef void (^CYLIMMessageResultBlock)(BOOL succeeded, NSError * _Nullable error, id<CYLIMMessageProtocol> _Nullable message);
typedef void (^CYLIMRecentConversationsResultBlock)(NSArray<id<CYLConversationProtocol>> * _Nullable conversations, NSInteger totalUnreadCount, NSError * _Nullable error);

#pragma mark - Session

/// Opening and closing the IM session of the current user.
@protocol CYLIMSessionProvider <NSObject>

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
 * `-[CYLSessionService handleSingleSignOnError:callback:]` when another device takes over the session.
 * @param force Whether to kick other devices logged in with the same client id.
 */
- (void)openWithClientId:(NSString *)clientId force:(BOOL)force callback:(nullable CYLBooleanResultBlock)callback;

/// Closes the session. ChatKit resets its services after a successful close.
- (void)closeWithCallback:(nullable CYLBooleanResultBlock)callback;

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
@protocol CYLIMConversationProvider <NSObject>

@required

- (void)fetchConversationWithConversationId:(NSString *)conversationId callback:(nullable CYLIMConversationResultBlock)callback;

/// The callback array contains objects conforming to `CYLConversationProtocol`.
- (void)fetchConversationsWithConversationIds:(NSSet<NSString *> *)conversationIds callback:(nullable CYLArrayResultBlock)callback;

/// Fetches, or creates if needed, the one-to-one conversation with `peerId`.
- (void)fetchConversationWithPeerId:(NSString *)peerId callback:(nullable CYLIMConversationResultBlock)callback;

/*!
 * @param unique If YES, an existing conversation with the same members is returned instead of creating a new one.
 */
- (void)createConversationWithMembers:(NSArray<NSString *> *)members
                                 type:(CYLConversationType)type
                               unique:(BOOL)unique
                             callback:(nullable CYLIMConversationResultBlock)callback;

/// Adds the current user to the conversation. Used when `enableAutoJoin` is YES.
- (void)joinConversation:(id<CYLConversationProtocol>)conversation callback:(nullable CYLBooleanResultBlock)callback;

/// Marks all messages of the conversation as read on the server and clears its mention flag.
- (void)markConversationAsRead:(id<CYLConversationProtocol>)conversation;

@optional

/// Called before ChatKit uses a conversation, for example to attach it to the current SDK client.
- (void)prepareConversation:(id<CYLConversationProtocol>)conversation;

@end

#pragma mark - Message

/// Converting, sending, loading, editing, and recalling messages.
@protocol CYLIMMessageProvider <NSObject>

@required

/*!
 * Converts an SDK message for display.
 * @return An `CYLMessage` for a built-in media type, the message itself for a supported custom
 *         message, or nil if the message should not be displayed (for example, a recalled message).
 */
- (nullable id)displayMessageFromIMMessage:(id<CYLIMMessageProtocol>)message;

/*!
 * Converts a message the UI wants to send into an SDK message.
 * @param message An `CYLMessage`, or a custom message that already conforms to `CYLIMMessageProtocol`.
 * @return The SDK message, or nil if the message cannot be sent.
 */
- (nullable id<CYLIMMessageProtocol>)IMMessageFromMessage:(id)message;

/*!
 * Sends a message.
 * @param mentionList Client ids mentioned in the message. May be empty.
 */
- (void)sendMessage:(id<CYLIMMessageProtocol>)message
       conversation:(id<CYLConversationProtocol>)conversation
        mentionList:(nullable NSArray<NSString *> *)mentionList
      progressBlock:(nullable CYLProgressBlock)progressBlock
           callback:(nullable CYLBooleanResultBlock)callback;

/*!
 * Loads history messages, newest last.
 * @param timestamp 0 loads the latest page; otherwise loads messages before `messageId` and `timestamp`.
 * The callback array contains objects conforming to `CYLIMMessageProtocol`.
 */
- (void)queryMessagesWithConversation:(id<CYLConversationProtocol>)conversation
                            messageId:(nullable NSString *)messageId
                            timestamp:(int64_t)timestamp
                                limit:(NSInteger)limit
                             callback:(nullable CYLArrayResultBlock)callback;

/// Replaces the text of a sent message. The callback returns the new SDK message.
- (void)updateMessage:(id<CYLIMMessageProtocol>)oldMessage
             withText:(NSString *)text
         conversation:(id<CYLConversationProtocol>)conversation
             callback:(nullable CYLIMMessageResultBlock)callback;

/// Recalls a sent message. The callback returns the recalled SDK message.
- (void)recallMessage:(id<CYLIMMessageProtocol>)message
         conversation:(id<CYLConversationProtocol>)conversation
             callback:(nullable CYLIMMessageResultBlock)callback;

@optional

/*!
 * Downloads the attachment of a received image message to a local file.
 * If not implemented, ChatKit downloads `originPhotoURL` with `NSURLSession`.
 */
- (void)downloadAttachmentOfMessage:(CYLMessage *)message
                         completion:(void (^)(NSURL * _Nullable filePath, NSError * _Nullable error))completion;

@end

#pragma mark - Recent conversations

/*!
 * The local store of recent conversations shown in the conversation list.
 * Methods taking `shouldRefreshWhenFinished` post `CYLNotificationConversationListDataSourceUpdated`
 * when the flag is YES.
 */
@protocol CYLIMRecentConversationProvider <NSObject>

@required

- (NSArray<id<CYLConversationProtocol>> *)allRecentConversations;
- (BOOL)isRecentConversationExistWithConversationId:(NSString *)conversationId;
- (void)insertRecentConversations:(NSArray<id<CYLConversationProtocol>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateRecentConversation:(NSArray<id<CYLConversationProtocol>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)deleteRecentConversationWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateUnreadCountToZeroWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)increaseUnreadCount:(NSUInteger)increaseUnreadCount withConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateMentioned:(BOOL)mentioned conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateDraft:(nullable NSString *)draft conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (nullable NSString *)draftWithConversationId:(NSString *)conversationId;
- (BOOL)removeAllCachedRecentConversations;

/*!
 * Loads the conversations shown in the conversation list, sorted newest first, applying
 * `conversationListShowHookBlock` of `CYLConversationListService`.
 */
- (void)findRecentConversationsWithBlock:(nullable CYLIMRecentConversationsResultBlock)block;

/// Fetches the current user's conversations from the server.
- (void)fetchRelationConversationsFromServerCallback:(nullable CYLArrayResultBlock)block;

@optional

/// Prepares the local store for a user. Providers usually do this when opening the session.
- (void)setupDatabaseWithUserId:(NSString *)userId;

@end

#pragma mark - Failed messages

/// The local store of messages that failed to send, so they can be shown and resent later.
@protocol CYLIMFailedMessageProvider <NSObject>

@required

- (void)insertFailedCYLMessage:(CYLMessage *)message;
- (void)insertFailedMessage:(id<CYLIMMessageProtocol>)message;
- (BOOL)deleteFailedMessageByRecordId:(NSString *)recordId;
- (NSArray<CYLMessage *> *)failedMessagesByConversationId:(NSString *)conversationId;
- (NSArray<NSString *> *)failedMessageIdsByConversationId:(NSString *)conversationId;
- (nullable NSArray<CYLMessage *> *)failedMessagesByMessageIds:(NSArray<NSString *> *)messageIds;

@end

#pragma mark - Push

/// Optional remote notification support.
@protocol CYLIMPushProvider <NSObject>

@optional

- (void)registerForRemoteNotification;
- (void)saveInstallationWithDeviceToken:(NSData *)deviceToken userId:(nullable NSString *)userId;
- (void)pushMessage:(NSString *)message userIds:(NSArray<NSString *> *)userIds block:(nullable CYLBooleanResultBlock)block;
- (void)cleanBadge;
- (void)syncBadge;
- (void)setUseDevPushCerticate:(BOOL)useDevPushCerticate;

@end

#pragma mark - Provider

/// Everything ChatKit needs from an IM backend.
@protocol CYLIMProvider <CYLIMSessionProvider,
                          CYLIMConversationProvider,
                          CYLIMMessageProvider,
                          CYLIMRecentConversationProvider,
                          CYLIMFailedMessageProvider,
                          CYLIMPushProvider>
@end

NS_ASSUME_NONNULL_END
