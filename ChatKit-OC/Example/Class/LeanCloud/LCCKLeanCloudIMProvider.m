//
//  LCCKLeanCloudIMProvider.m
//  ChatKit-OC
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//
//  A stateless adapter. Session state lives in `LCCKLeanCloudSessionService` and
//  conversation state in `LCCKLeanCloudConversationService`; both are `CYLSingleton`
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

#pragma mark - CYLIMSessionProvider

- (NSString *)clientId {
    return self.session.clientId;
}

- (BOOL)isConnected {
    return self.session.connect;
}

- (BOOL)isClientOpened {
    return [self.session isClientOpened];
}

- (void)openWithClientId:(NSString *)clientId force:(BOOL)force callback:(CYLBooleanResultBlock)callback {
    [self.session openWithClientId:clientId force:force callback:callback];
}

- (void)closeWithCallback:(CYLBooleanResultBlock)callback {
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

#pragma mark - CYLIMConversationProvider

- (void)fetchConversationWithConversationId:(NSString *)conversationId callback:(CYLIMConversationResultBlock)callback {
    [self.conversations fetchConversationWithConversationId:conversationId callback:callback];
}

- (void)fetchConversationsWithConversationIds:(NSSet<NSString *> *)conversationIds callback:(CYLArrayResultBlock)callback {
    [self.conversations fetchConversationsWithConversationIds:conversationIds callback:callback];
}

- (void)fetchConversationWithPeerId:(NSString *)peerId callback:(CYLIMConversationResultBlock)callback {
    [self.conversations fetchConversationWithPeerId:peerId callback:callback];
}

- (void)createConversationWithMembers:(NSArray<NSString *> *)members type:(CYLConversationType)type unique:(BOOL)unique callback:(CYLIMConversationResultBlock)callback {
    [self.conversations createConversationWithMembers:members type:type unique:unique callback:callback];
}

- (void)joinConversation:(id<CYLConversationProtocol>)conversation callback:(CYLBooleanResultBlock)callback {
    [self.conversations joinConversation:conversation callback:callback];
}

- (void)markConversationAsRead:(id<CYLConversationProtocol>)conversation {
    [self.conversations markConversationAsRead:conversation];
}

- (void)prepareConversation:(id<CYLConversationProtocol>)conversation {
    [self.conversations prepareConversation:conversation];
}

#pragma mark - CYLIMMessageProvider

- (id)displayMessageFromIMMessage:(id<CYLIMMessageProtocol>)message {
    return [self.conversations displayMessageFromIMMessage:message];
}

- (id<CYLIMMessageProtocol>)IMMessageFromMessage:(id)message {
    return [self.conversations IMMessageFromMessage:message];
}

- (void)sendMessage:(id<CYLIMMessageProtocol>)message
       conversation:(id<CYLConversationProtocol>)conversation
        mentionList:(NSArray<NSString *> *)mentionList
      progressBlock:(CYLProgressBlock)progressBlock
           callback:(CYLBooleanResultBlock)callback {
    [self.conversations sendMessage:message conversation:conversation mentionList:mentionList progressBlock:progressBlock callback:callback];
}

- (void)queryMessagesWithConversation:(id<CYLConversationProtocol>)conversation
                            messageId:(NSString *)messageId
                            timestamp:(int64_t)timestamp
                                limit:(NSInteger)limit
                             callback:(CYLArrayResultBlock)callback {
    [self.conversations queryMessagesWithConversation:conversation messageId:messageId timestamp:timestamp limit:limit callback:callback];
}

- (void)updateMessage:(id<CYLIMMessageProtocol>)oldMessage
             withText:(NSString *)text
         conversation:(id<CYLConversationProtocol>)conversation
             callback:(CYLIMMessageResultBlock)callback {
    [self.conversations updateMessage:oldMessage withText:text conversation:conversation callback:callback];
}

- (void)recallMessage:(id<CYLIMMessageProtocol>)message
         conversation:(id<CYLConversationProtocol>)conversation
             callback:(CYLIMMessageResultBlock)callback {
    [self.conversations recallMessage:message conversation:conversation callback:callback];
}

- (void)downloadAttachmentOfMessage:(CYLMessage *)message completion:(void (^)(NSURL *, NSError *))completion {
    [self.conversations downloadAttachmentOfMessage:message completion:completion];
}

#pragma mark - CYLIMRecentConversationProvider

- (void)setupDatabaseWithUserId:(NSString *)userId {
    [self.conversations setupDatabaseWithUserId:userId];
}

- (NSArray<id<CYLConversationProtocol>> *)allRecentConversations {
    return [self.conversations allRecentConversations];
}

- (BOOL)isRecentConversationExistWithConversationId:(NSString *)conversationId {
    return [self.conversations isRecentConversationExistWithConversationId:conversationId];
}

- (void)insertRecentConversations:(NSArray<id<CYLConversationProtocol>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.conversations insertRecentConversations:conversations shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (void)updateRecentConversation:(NSArray<id<CYLConversationProtocol>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
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

- (void)findRecentConversationsWithBlock:(CYLIMRecentConversationsResultBlock)block {
    [self.conversations findRecentConversationsWithBlock:block];
}

- (void)fetchRelationConversationsFromServerCallback:(CYLArrayResultBlock)block {
    [self.conversations fetchRelationConversationsFromServerCallback:block];
}

#pragma mark - CYLIMFailedMessageProvider

- (void)insertFailedCYLMessage:(CYLMessage *)message {
    [self.conversations insertFailedCYLMessage:message];
}

- (void)insertFailedMessage:(id<CYLIMMessageProtocol>)message {
    [self.conversations insertFailedMessage:message];
}

- (BOOL)deleteFailedMessageByRecordId:(NSString *)recordId {
    return [self.conversations deleteFailedMessageByRecordId:recordId];
}

- (NSArray<CYLMessage *> *)failedMessagesByConversationId:(NSString *)conversationId {
    return [self.conversations failedMessagesByConversationId:conversationId];
}

- (NSArray<NSString *> *)failedMessageIdsByConversationId:(NSString *)conversationId {
    return [self.conversations failedMessageIdsByConversationId:conversationId];
}

- (NSArray<CYLMessage *> *)failedMessagesByMessageIds:(NSArray<NSString *> *)messageIds {
    return [self.conversations failedMessagesByMessageIds:messageIds];
}

#pragma mark - CYLIMPushProvider

- (void)registerForRemoteNotification {
    [AVOSCloud registerForRemoteNotification];
}

- (void)saveInstallationWithDeviceToken:(NSData *)deviceToken userId:(NSString *)userId {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    //FIXME: openClient 的时候也会将 clientId 注册到 channels，这里多余了？
    if (userId) {
        [currentInstallation addUniqueObject:userId forKey:CYLInstallationKeyChannels];
    }
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)pushMessage:(NSString *)message userIds:(NSArray<NSString *> *)userIds block:(CYLBooleanResultBlock)block {
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
