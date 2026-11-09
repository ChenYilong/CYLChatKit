//
//  LCCKLeanCloudIMProvider.m
//  ChatKit-OC
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//
//  A stateless adapter. Session state lives in `LCCKLeanCloudSessionService` and
//  conversation state in `LCCKLeanCloudConversationService`; both are `LCCKSingleton`
//  subclasses that ChatKit resets after closing a session.

#import "LCCKLeanCloudIMProvider.h"
#import <AVOSCloud/AVOSCloud.h>
#import <AVOSCloudIM/AVOSCloudIM.h>
#import "LCCKLeanCloudSessionService.h"
#import "LCCKLeanCloudConversationService.h"
#import "AVIMConversation+LCCKExtension.h"
#import "AVIMTypedMessage+LCCKExtension.h"

@implementation LCCKLeanCloudIMProvider

- (LCCKLeanCloudSessionService *)session {
    return [LCCKLeanCloudSessionService sharedInstance];
}

- (LCCKLeanCloudConversationService *)conversations {
    return [LCCKLeanCloudConversationService sharedInstance];
}

#pragma mark - LCCKIMSessionProvider

- (NSString *)clientId {
    return self.session.clientId;
}

- (BOOL)isConnected {
    return self.session.connect;
}

- (BOOL)isClientOpened {
    return [self.session isClientOpened];
}

- (void)openWithClientId:(NSString *)clientId force:(BOOL)force callback:(LCCKBooleanResultBlock)callback {
    [self.session openWithClientId:clientId force:force callback:callback];
}

- (void)closeWithCallback:(LCCKBooleanResultBlock)callback {
    [self.session closeWithCallback:callback];
}

- (id)client {
    return self.session.client;
}

- (void)setAppId:(NSString *)appId appKey:(NSString *)appKey {
    [AVOSCloud setApplicationId:appId clientKey:appKey];
}

- (void)setAllLogsEnabled:(BOOL)enabled {
    [AVOSCloud setAllLogsEnabled:YES];
}

#pragma mark - LCCKIMConversationProvider

- (void)fetchConversationWithConversationId:(NSString *)conversationId callback:(LCCKIMConversationResultBlock)callback {
    [self.conversations fetchConversationWithConversationId:conversationId callback:callback];
}

- (void)fetchConversationsWithConversationIds:(NSSet<NSString *> *)conversationIds callback:(LCCKArrayResultBlock)callback {
    [self.conversations fetchConversationsWithConversationIds:conversationIds callback:callback];
}

- (void)fetchConversationWithPeerId:(NSString *)peerId callback:(LCCKIMConversationResultBlock)callback {
    [self.conversations fetchConversationWithPeerId:peerId callback:callback];
}

- (void)createConversationWithMembers:(NSArray<NSString *> *)members type:(LCCKConversationType)type unique:(BOOL)unique callback:(LCCKIMConversationResultBlock)callback {
    [self.conversations createConversationWithMembers:members type:type unique:unique callback:callback];
}

- (void)joinConversation:(id<LCCKConversationProtocol>)conversation callback:(LCCKBooleanResultBlock)callback {
    [self.conversations joinConversation:conversation callback:callback];
}

- (void)markConversationAsRead:(id<LCCKConversationProtocol>)conversation {
    [self.conversations markConversationAsRead:conversation];
}

- (void)prepareConversation:(id<LCCKConversationProtocol>)conversation {
    [self.conversations prepareConversation:conversation];
}

#pragma mark - LCCKIMMessageProvider

- (id)displayMessageFromIMMessage:(id<LCCKIMMessageProtocol>)message {
    return [self.conversations displayMessageFromIMMessage:message];
}

- (id<LCCKIMMessageProtocol>)IMMessageFromMessage:(id)message {
    return [self.conversations IMMessageFromMessage:message];
}

- (void)sendMessage:(id<LCCKIMMessageProtocol>)message
       conversation:(id<LCCKConversationProtocol>)conversation
        mentionList:(NSArray<NSString *> *)mentionList
      progressBlock:(LCCKProgressBlock)progressBlock
           callback:(LCCKBooleanResultBlock)callback {
    [self.conversations sendMessage:message conversation:conversation mentionList:mentionList progressBlock:progressBlock callback:callback];
}

- (void)queryMessagesWithConversation:(id<LCCKConversationProtocol>)conversation
                            messageId:(NSString *)messageId
                            timestamp:(int64_t)timestamp
                                limit:(NSInteger)limit
                             callback:(LCCKArrayResultBlock)callback {
    [self.conversations queryMessagesWithConversation:conversation messageId:messageId timestamp:timestamp limit:limit callback:callback];
}

- (void)updateMessage:(id<LCCKIMMessageProtocol>)oldMessage
             withText:(NSString *)text
         conversation:(id<LCCKConversationProtocol>)conversation
             callback:(LCCKIMMessageResultBlock)callback {
    [self.conversations updateMessage:oldMessage withText:text conversation:conversation callback:callback];
}

- (void)recallMessage:(id<LCCKIMMessageProtocol>)message
         conversation:(id<LCCKConversationProtocol>)conversation
             callback:(LCCKIMMessageResultBlock)callback {
    [self.conversations recallMessage:message conversation:conversation callback:callback];
}

- (void)downloadAttachmentOfMessage:(LCCKMessage *)message completion:(void (^)(NSURL *, NSError *))completion {
    [self.conversations downloadAttachmentOfMessage:message completion:completion];
}

#pragma mark - LCCKIMRecentConversationProvider

- (void)setupDatabaseWithUserId:(NSString *)userId {
    [self.conversations setupDatabaseWithUserId:userId];
}

- (NSArray<id<LCCKConversationProtocol>> *)allRecentConversations {
    return [self.conversations allRecentConversations];
}

- (BOOL)isRecentConversationExistWithConversationId:(NSString *)conversationId {
    return [self.conversations isRecentConversationExistWithConversationId:conversationId];
}

- (void)insertRecentConversations:(NSArray<id<LCCKConversationProtocol>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.conversations insertRecentConversations:conversations shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (void)updateRecentConversation:(NSArray<id<LCCKConversationProtocol>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.conversations updateRecentConversation:conversations shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (void)deleteRecentConversationWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.conversations deleteRecentConversationWithConversationId:conversationId shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (void)updateUnreadCountToZeroWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.conversations updateUnreadCountToZeroWithConversationId:conversationId shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (void)increaseUnreadCount:(NSUInteger)increaseUnreadCount withConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.conversations increaseUnreadCount:increaseUnreadCount withConversationId:conversationId shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (void)updateMentioned:(BOOL)mentioned conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.conversations updateMentioned:mentioned conversationId:conversationId shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (void)updateDraft:(NSString *)draft conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.conversations updateDraft:draft conversationId:conversationId shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (NSString *)draftWithConversationId:(NSString *)conversationId {
    return [self.conversations draftWithConversationId:conversationId];
}

- (BOOL)removeAllCachedRecentConversations {
    return [self.conversations removeAllCachedRecentConversations];
}

- (void)findRecentConversationsWithBlock:(LCCKIMRecentConversationsResultBlock)block {
    [self.conversations findRecentConversationsWithBlock:block];
}

- (void)fetchRelationConversationsFromServerCallback:(LCCKArrayResultBlock)block {
    [self.conversations fetchRelationConversationsFromServerCallback:block];
}

#pragma mark - LCCKIMFailedMessageProvider

- (void)insertFailedLCCKMessage:(LCCKMessage *)message {
    [self.conversations insertFailedLCCKMessage:message];
}

- (void)insertFailedMessage:(id<LCCKIMMessageProtocol>)message {
    [self.conversations insertFailedMessage:message];
}

- (BOOL)deleteFailedMessageByRecordId:(NSString *)recordId {
    return [self.conversations deleteFailedMessageByRecordId:recordId];
}

- (NSArray<LCCKMessage *> *)failedMessagesByConversationId:(NSString *)conversationId {
    return [self.conversations failedMessagesByConversationId:conversationId];
}

- (NSArray<NSString *> *)failedMessageIdsByConversationId:(NSString *)conversationId {
    return [self.conversations failedMessageIdsByConversationId:conversationId];
}

- (NSArray<LCCKMessage *> *)failedMessagesByMessageIds:(NSArray<NSString *> *)messageIds {
    return [self.conversations failedMessagesByMessageIds:messageIds];
}

#pragma mark - LCCKIMPushProvider

- (void)registerForRemoteNotification {
    [AVOSCloud registerForRemoteNotification];
}

- (void)saveInstallationWithDeviceToken:(NSData *)deviceToken userId:(NSString *)userId {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    //FIXME: openClient 的时候也会将 clientId 注册到 channels，这里多余了？
    if (userId) {
        [currentInstallation addUniqueObject:userId forKey:LCCKInstallationKeyChannels];
    }
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)pushMessage:(NSString *)message userIds:(NSArray<NSString *> *)userIds block:(LCCKBooleanResultBlock)block {
    AVPush *push = [[AVPush alloc] init];
    [push setChannels:userIds];
    [push setMessage:message];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        !block ?: block(succeeded, error);
    }];
}

- (void)cleanBadge {
    UIApplication *application = [UIApplication sharedApplication];
    NSInteger num = application.applicationIconBadgeNumber;
    if (num != 0) {
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation setBadge:0];
        [currentInstallation saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
            NSLog(@"%@", error ? error : @"succeed");
        }];
        application.applicationIconBadgeNumber = 0;
    }
    [application cancelAllLocalNotifications];
}

- (void)syncBadge {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    if (currentInstallation.badge != [UIApplication sharedApplication].applicationIconBadgeNumber) {
        [currentInstallation setBadge:[UIApplication sharedApplication].applicationIconBadgeNumber];
        [currentInstallation saveEventually: ^(BOOL succeeded, NSError *error) {
            NSLog(@"%@", error ? error : @"succeed");
        }];
    }
}

- (void)setUseDevPushCerticate:(BOOL)useDevPushCerticate {
    [AVPush setProductionMode:!useDevPushCerticate];
}

@end
