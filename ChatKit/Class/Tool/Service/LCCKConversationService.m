//
//  LCCKConversationService.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/1.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//
//  ChatKit no longer links an IM SDK. This service keeps the state the UI needs
//  (current conversation, hooks) and forwards IM operations and local storage to
//  `-[LCChatKit IMProvider]`.

#import "LCCKConversationService.h"
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

#import "LCCKMessage.h"

NSString *const LCCKConversationServiceErrorDomain = @"LCCKConversationServiceErrorDomain";

@implementation LCCKConversationService
@synthesize currentConversation = _currentConversation;
@synthesize fetchConversationHandler = _fetchConversationHandler;
@synthesize conversationInvalidedHandler = _conversationInvalidedHandler;
@synthesize loadLatestMessagesHandler = _loadLatestMessagesHandler;
@synthesize filterMessagesBlock = _filterMessagesBlock;
@synthesize sendMessageHookBlock = _sendMessageHookBlock;

#pragma mark - IM provider

- (id<LCCKIMProvider>)IMProvider {
    id<LCCKIMProvider> IMProvider = [LCChatKit sharedInstance].IMProvider;
    if (!IMProvider) {
        LCCKLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Set `-[LCChatKit setIMProvider:]` before using ChatKit.");
    }
    return IMProvider;
}

- (NSError *)errorWithReason:(NSString *)reason {
    NSInteger code = 0;
    NSDictionary *errorInfo = @{
                                @"code" : @(code),
                                NSLocalizedDescriptionKey : reason ?: @"",
                                };
    return [NSError errorWithDomain:LCCKConversationServiceErrorDomain code:code userInfo:errorInfo];
}

#pragma mark - fetch conversations

- (void)fetchConversationWithConversationId:(NSString *)conversationId callback:(LCCKConversationResultBlock)callback {
    NSAssert(conversationId.length > 0, @"Conversation id is nil");
    [self.IMProvider fetchConversationWithConversationId:conversationId callback:callback];
}

- (void)fetchConversationsWithConversationIds:(NSSet *)conversationIds callback:(LCCKArrayResultBlock)callback {
    [self.IMProvider fetchConversationsWithConversationIds:conversationIds callback:callback];
}

- (void)fetchConversationWithPeerId:(NSString *)peerId callback:(LCCKConversationResultBlock)callback {
    [self.IMProvider fetchConversationWithPeerId:peerId callback:callback];
}

- (void)createConversationWithMembers:(NSArray *)members type:(LCCKConversationType)type unique:(BOOL)unique callback:(LCCKConversationResultBlock)callback {
    [self.IMProvider createConversationWithMembers:members type:type unique:unique callback:callback];
}

#pragma mark - current conversation

- (void)updateConversationAsReadWithLastMessage:(id)lastMessage {
    id<LCCKConversationDelegate> conversation = self.currentConversation;
    NSString *conversationId = conversation.conversationId;
    if (!conversation.createAt || conversationId.length == 0) {
        NSLog( @"类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"conversation is not available");
        return;
    }
    [self insertRecentConversation:conversation shouldRefreshWhenFinished:NO];
    [self updateUnreadCountToZeroWithConversationId:conversationId shouldRefreshWhenFinished:NO];
    [self updateMentioned:NO conversationId:conversationId shouldRefreshWhenFinished:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:LCCKNotificationUnreadsUpdated object:nil];
}

- (void)setCurrentConversation:(id<LCCKConversationDelegate>)currentConversation {
    _currentConversation = currentConversation;
    [self prepareConversationIfNeeded:currentConversation];
}

- (id<LCCKConversationDelegate>)currentConversation {
    [self prepareConversationIfNeeded:_currentConversation];
    return _currentConversation;
}

- (void)prepareConversationIfNeeded:(id<LCCKConversationDelegate>)conversation {
    if (!conversation) {
        return;
    }
    id<LCCKIMProvider> IMProvider = self.IMProvider;
    if ([IMProvider respondsToSelector:@selector(prepareConversation:)]) {
        [IMProvider prepareConversation:conversation];
    }
}

- (BOOL)isChatting {
    return (self.currentConversationId.length > 0);
}

#pragma mark - recent conversations

- (void)setupDatabaseWithUserId:(NSString *)userId {
    id<LCCKIMProvider> IMProvider = self.IMProvider;
    if ([IMProvider respondsToSelector:@selector(setupDatabaseWithUserId:)]) {
        [IMProvider setupDatabaseWithUserId:userId];
    }
}

- (void)updateUnreadCountToZeroWithConversationId:(NSString *)conversationId {
    [self updateUnreadCountToZeroWithConversationId:conversationId shouldRefreshWhenFinished:YES];
}

- (void)updateUnreadCountToZeroWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.IMProvider updateUnreadCountToZeroWithConversationId:conversationId shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (void)deleteRecentConversationWithConversationId:(NSString *)conversationId {
    [self deleteRecentConversationWithConversationId:conversationId shouldRefreshWhenFinished:YES];
}

- (void)deleteRecentConversationWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.IMProvider deleteRecentConversationWithConversationId:conversationId shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (void)insertRecentConversation:(id<LCCKConversationDelegate>)conversation {
    [self insertRecentConversation:conversation shouldRefreshWhenFinished:YES];
}

- (void)insertRecentConversation:(id<LCCKConversationDelegate>)conversation shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    if (!conversation) {
        return;
    }
    [self insertRecentConversations:@[conversation] shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (void)insertRecentConversations:(NSArray<id<LCCKConversationDelegate>> *)conversations {
    [self insertRecentConversations:conversations shouldRefreshWhenFinished:YES];
}

- (void)insertRecentConversations:(NSArray<id<LCCKConversationDelegate>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.IMProvider insertRecentConversations:conversations ?: @[] shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (BOOL)isRecentConversationExistWithConversationId:(NSString *)conversationId {
    return [self.IMProvider isRecentConversationExistWithConversationId:conversationId];
}

- (void)increaseUnreadCountWithConversationId:(NSString *)conversationId {
    [self increaseUnreadCountWithConversationId:conversationId shouldRefreshWhenFinished:YES];
}

- (void)increaseUnreadCountWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self increaseUnreadCount:1 withConversationId:conversationId shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (void)increaseUnreadCount:(NSUInteger)increaseUnreadCount withConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.IMProvider increaseUnreadCount:increaseUnreadCount withConversationId:conversationId shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (void)updateMentioned:(BOOL)mentioned conversationId:(NSString *)conversationId {
    [self updateMentioned:mentioned conversationId:conversationId shouldRefreshWhenFinished:YES];
}

- (void)updateMentioned:(BOOL)mentioned conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.IMProvider updateMentioned:mentioned conversationId:conversationId shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (NSString *)draftWithConversationId:(NSString *)conversationId {
    return [self.IMProvider draftWithConversationId:conversationId];
}

- (void)updateDraft:(NSString *)draft conversationId:(NSString *)conversationId {
    [self updateDraft:draft conversationId:conversationId shouldRefreshWhenFinished:YES];
}

- (void)updateDraft:(NSString *)draft conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.IMProvider updateDraft:draft conversationId:conversationId shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (NSArray *)allRecentConversations {
    return [self.IMProvider allRecentConversations];
}

- (void)updateRecentConversation:(NSArray *)conversations {
    [self updateRecentConversation:conversations shouldRefreshWhenFinished:YES];
}

- (void)updateRecentConversation:(NSArray *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.IMProvider updateRecentConversation:conversations ?: @[] shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

/**
 *  删除对话对应的UIProfile缓存，比如当用户信息发生变化时
 *  @param  conversation 对话，可以是单聊，也可是群聊
 */
- (void)removeCacheForConversationId:(NSString *)conversationId {
    [self deleteRecentConversationWithConversationId:conversationId];
}

/**
 *  删除全部缓存，比如当切换用户时，如果同一个人显示的名称和头像需要变更
 */
- (BOOL)removeAllCachedRecentConversations {
    return [self.IMProvider removeAllCachedRecentConversations];
}

#pragma mark - FailedMessageStore

- (NSArray *)failedMessagesByConversationId:(NSString *)conversationId {
    return [self.IMProvider failedMessagesByConversationId:conversationId];
}

- (NSArray *)failedMessageIdsByConversationId:(NSString *)conversationId {
    return [self.IMProvider failedMessageIdsByConversationId:conversationId];
}

- (NSArray *)failedMessagesByMessageIds:(NSArray *)messageIds {
    return [self.IMProvider failedMessagesByMessageIds:messageIds];
}

- (BOOL)deleteFailedMessageByRecordId:(NSString *)recordId {
    return [self.IMProvider deleteFailedMessageByRecordId:recordId];
}

- (void)insertFailedLCCKMessage:(LCCKMessage *)message {
    if (message.conversationId == nil) {
        //TODO: add debug model
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"conversationId is nil");
        return;
    }
    [self.IMProvider insertFailedLCCKMessage:message];
}

- (void)insertFailedMessage:(id<LCCKIMMessageDelegate>)message {
    if (message.conversationId == nil) {
        //TODO: add debug model
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"conversationId is nil");
        return;
    }
    [self.IMProvider insertFailedMessage:message];
}

#pragma mark - remote notification

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (userInfo[@"convid"]) {
        self.remoteNotificationConversationId = userInfo[@"convid"];
    }
}

#pragma mark - send messages

- (void)sendMessage:(id<LCCKIMMessageDelegate>)message
       conversation:(id<LCCKConversationDelegate>)conversation
      progressBlock:(LCCKProgressBlock)progressBlock
           callback:(LCCKBooleanResultBlock)block {
    [self sendMessage:message conversation:conversation mentionList:nil progressBlock:progressBlock callback:block];
}

- (void)sendMessage:(id<LCCKIMMessageDelegate>)message
       conversation:(id<LCCKConversationDelegate>)conversation
        mentionList:(NSArray<NSString *> *)mentionList
      progressBlock:(LCCKProgressBlock)progressBlock
           callback:(LCCKBooleanResultBlock)block {
    if (!message || !conversation) {
        !block ?: block(NO, [self errorWithReason:@"message or conversation is nil"]);
        return;
    }
    [self.IMProvider sendMessage:message conversation:conversation mentionList:mentionList progressBlock:progressBlock callback:block];
}

- (void)sendWelcomeMessageToPeerId:(NSString *)peerId text:(NSString *)text block:(LCCKBooleanResultBlock)block {
    [self fetchConversationWithPeerId:peerId callback:^(id<LCCKConversationDelegate> conversation, NSError *error) {
        [self sendText:text toConversation:conversation error:error block:block];
    }];
}

- (void)sendWelcomeMessageToConversationId:(NSString *)conversationId text:(NSString *)text block:(LCCKBooleanResultBlock)block {
    [self fetchConversationWithConversationId:conversationId callback:^(id<LCCKConversationDelegate> conversation, NSError *error) {
        [self sendText:text toConversation:conversation error:error block:block];
    }];
}

- (void)sendText:(NSString *)text toConversation:(id<LCCKConversationDelegate>)conversation error:(NSError *)error block:(LCCKBooleanResultBlock)block {
    if (error || !conversation) {
        !block ?: block(NO, error ?: [self errorWithReason:@"conversation is nil"]);
        return;
    }
    LCCKMessage *textMessage = [[LCCKMessage alloc] initWithText:text
                                                         senderId:self.IMProvider.clientId
                                                           sender:nil
                                                        timestamp:LCCK_CURRENT_TIMESTAMP
                                                  serverMessageId:nil];
    id<LCCKIMMessageDelegate> message = [self.IMProvider IMMessageFromMessage:textMessage];
    [self sendMessage:message conversation:conversation progressBlock:nil callback:block];
}

#pragma mark - query msgs

- (void)setFetchConversationHandler:(LCCKFetchConversationHandler)fetchConversationHandler {
    _fetchConversationHandler = fetchConversationHandler;
}

- (void)setConversationInvalidedHandler:(LCCKConversationInvalidedHandler)conversationInvalidedHandler {
    _conversationInvalidedHandler = conversationInvalidedHandler;
}

- (void)setLoadLatestMessagesHandler:(LCCKLoadLatestMessagesHandler)loadLatestMessagesHandler {
    _loadLatestMessagesHandler = loadLatestMessagesHandler;
}

- (void)queryTypedMessagesWithConversation:(id<LCCKConversationDelegate>)conversation
                                 messageId:(NSString *)messageId
                                 timestamp:(int64_t)timestamp
                                     limit:(NSInteger)limit
                                     block:(LCCKArrayResultBlock)block {
    if (!conversation) {
        !block ?: block(@[], [self errorWithReason:@"conversation is nil"]);
        return;
    }
    [self.IMProvider queryMessagesWithConversation:conversation messageId:messageId timestamp:timestamp limit:limit callback:block];
}

#pragma mark -
#pragma mark - deprecated Method

- (void)fecthConversationWithConversationId:(NSString *)conversationId callback:(LCCKConversationResultBlock)callback {
    [self fetchConversationWithConversationId:conversationId callback:callback];
}

- (void)fecthConversationWithPeerId:(NSString *)peerId callback:(LCCKConversationResultBlock)callback {
    [self fetchConversationWithPeerId:peerId callback:callback];
}

@end
