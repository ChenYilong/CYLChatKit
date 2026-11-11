//
//  CYLConversationService.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/1.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//
//  ChatKit no longer links an IM SDK. This service keeps the state the UI needs
//  (current conversation, hooks) and forwards IM operations and local storage to
//  `-[CYLChatKit IMProvider]`.

#import "CYLConversationService.h"
#if __has_include(<CYLChatKit/CYLChatKit.h>)
#import <CYLChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif

#import "CYLMessage.h"

NSString *const CYLConversationServiceErrorDomain = @"CYLConversationServiceErrorDomain";

@implementation CYLConversationService
@synthesize currentConversation = _currentConversation;
@synthesize fetchConversationHandler = _fetchConversationHandler;
@synthesize conversationInvalidedHandler = _conversationInvalidedHandler;
@synthesize loadLatestMessagesHandler = _loadLatestMessagesHandler;
@synthesize filterMessagesBlock = _filterMessagesBlock;
@synthesize sendMessageHookBlock = _sendMessageHookBlock;

#pragma mark - IM provider

- (id<CYLIMProvider>)IMProvider {
    id<CYLIMProvider> IMProvider = [CYLChatKit sharedInstance].IMProvider;
    if (!IMProvider) {
        CYLLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Set `-[CYLChatKit setIMProvider:]` before using ChatKit.");
    }
    return IMProvider;
}

- (NSError *)errorWithReason:(NSString *)reason {
    NSInteger code = 0;
    NSDictionary *errorInfo = @{
                                @"code" : @(code),
                                NSLocalizedDescriptionKey : reason ?: @"",
                                };
    return [NSError errorWithDomain:CYLConversationServiceErrorDomain code:code userInfo:errorInfo];
}

#pragma mark - fetch conversations

- (void)fetchConversationWithConversationId:(NSString *)conversationId callback:(CYLConversationResultBlock)callback {
    NSAssert(conversationId.length > 0, @"Conversation id is nil");
    [self.IMProvider fetchConversationWithConversationId:conversationId callback:callback];
}

- (void)fetchConversationsWithConversationIds:(NSSet *)conversationIds callback:(CYLArrayResultBlock)callback {
    [self.IMProvider fetchConversationsWithConversationIds:conversationIds callback:callback];
}

- (void)fetchConversationWithPeerId:(NSString *)peerId callback:(CYLConversationResultBlock)callback {
    [self.IMProvider fetchConversationWithPeerId:peerId callback:callback];
}

- (void)createConversationWithMembers:(NSArray *)members type:(CYLConversationType)type unique:(BOOL)unique callback:(CYLConversationResultBlock)callback {
    [self.IMProvider createConversationWithMembers:members type:type unique:unique callback:callback];
}

#pragma mark - current conversation

- (void)updateConversationAsReadWithLastMessage:(id)lastMessage {
    id<CYLConversationProtocol> conversation = self.currentConversation;
    NSString *conversationId = conversation.conversationId;
    if (!conversation.createAt || conversationId.length == 0) {
        NSLog( @"类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"conversation is not available");
        return;
    }
    [self insertRecentConversation:conversation shouldRefreshWhenFinished:NO];
    [self updateUnreadCountToZeroWithConversationId:conversationId shouldRefreshWhenFinished:NO];
    [self updateMentioned:NO conversationId:conversationId shouldRefreshWhenFinished:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationUnreadsUpdated object:nil];
}

- (void)setCurrentConversation:(id<CYLConversationProtocol>)currentConversation {
    _currentConversation = currentConversation;
    [self prepareConversationIfNeeded:currentConversation];
}

- (id<CYLConversationProtocol>)currentConversation {
    [self prepareConversationIfNeeded:_currentConversation];
    return _currentConversation;
}

- (void)prepareConversationIfNeeded:(id<CYLConversationProtocol>)conversation {
    if (!conversation) {
        return;
    }
    id<CYLIMProvider> IMProvider = self.IMProvider;
    if ([IMProvider respondsToSelector:@selector(prepareConversation:)]) {
        [IMProvider prepareConversation:conversation];
    }
}

- (BOOL)isChatting {
    return (self.currentConversationId.length > 0);
}

#pragma mark - recent conversations

- (void)setupDatabaseWithUserId:(NSString *)userId {
    id<CYLIMProvider> IMProvider = self.IMProvider;
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

- (void)insertRecentConversation:(id<CYLConversationProtocol>)conversation {
    [self insertRecentConversation:conversation shouldRefreshWhenFinished:YES];
}

- (void)insertRecentConversation:(id<CYLConversationProtocol>)conversation shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    if (!conversation) {
        return;
    }
    [self insertRecentConversations:@[conversation] shouldRefreshWhenFinished:shouldRefreshWhenFinished];
}

- (void)insertRecentConversations:(NSArray<id<CYLConversationProtocol>> *)conversations {
    [self insertRecentConversations:conversations shouldRefreshWhenFinished:YES];
}

- (void)insertRecentConversations:(NSArray<id<CYLConversationProtocol>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
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

- (void)insertFailedCYLMessage:(CYLMessage *)message {
    if (message.conversationId == nil) {
        //TODO: add debug model
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"conversationId is nil");
        return;
    }
    [self.IMProvider insertFailedCYLMessage:message];
}

- (void)insertFailedMessage:(id<CYLIMMessageProtocol>)message {
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

- (void)sendMessage:(id<CYLIMMessageProtocol>)message
       conversation:(id<CYLConversationProtocol>)conversation
      progressBlock:(CYLProgressBlock)progressBlock
           callback:(CYLBooleanResultBlock)block {
    [self sendMessage:message conversation:conversation mentionList:nil progressBlock:progressBlock callback:block];
}

- (void)sendMessage:(id<CYLIMMessageProtocol>)message
       conversation:(id<CYLConversationProtocol>)conversation
        mentionList:(NSArray<NSString *> *)mentionList
      progressBlock:(CYLProgressBlock)progressBlock
           callback:(CYLBooleanResultBlock)block {
    if (!message || !conversation) {
        !block ?: block(NO, [self errorWithReason:@"message or conversation is nil"]);
        return;
    }
    [self.IMProvider sendMessage:message conversation:conversation mentionList:mentionList progressBlock:progressBlock callback:block];
}

- (void)sendWelcomeMessageToPeerId:(NSString *)peerId text:(NSString *)text block:(CYLBooleanResultBlock)block {
    [self fetchConversationWithPeerId:peerId callback:^(id<CYLConversationProtocol> conversation, NSError *error) {
        [self sendText:text toConversation:conversation error:error block:block];
    }];
}

- (void)sendWelcomeMessageToConversationId:(NSString *)conversationId text:(NSString *)text block:(CYLBooleanResultBlock)block {
    [self fetchConversationWithConversationId:conversationId callback:^(id<CYLConversationProtocol> conversation, NSError *error) {
        [self sendText:text toConversation:conversation error:error block:block];
    }];
}

- (void)sendText:(NSString *)text toConversation:(id<CYLConversationProtocol>)conversation error:(NSError *)error block:(CYLBooleanResultBlock)block {
    if (error || !conversation) {
        !block ?: block(NO, error ?: [self errorWithReason:@"conversation is nil"]);
        return;
    }
    CYLMessage *textMessage = [[CYLMessage alloc] initWithText:text
                                                         senderId:self.IMProvider.clientId
                                                           sender:nil
                                                        timestamp:CYL_CURRENT_TIMESTAMP
                                                  serverMessageId:nil];
    id<CYLIMMessageProtocol> message = [self.IMProvider IMMessageFromMessage:textMessage];
    [self sendMessage:message conversation:conversation progressBlock:nil callback:block];
}

#pragma mark - query msgs

- (void)setFetchConversationHandler:(CYLFetchConversationHandler)fetchConversationHandler {
    _fetchConversationHandler = fetchConversationHandler;
}

- (void)setConversationInvalidedHandler:(CYLConversationInvalidedHandler)conversationInvalidedHandler {
    _conversationInvalidedHandler = conversationInvalidedHandler;
}

- (void)setLoadLatestMessagesHandler:(CYLLoadLatestMessagesHandler)loadLatestMessagesHandler {
    _loadLatestMessagesHandler = loadLatestMessagesHandler;
}

- (void)queryTypedMessagesWithConversation:(id<CYLConversationProtocol>)conversation
                                 messageId:(NSString *)messageId
                                 timestamp:(int64_t)timestamp
                                     limit:(NSInteger)limit
                                     block:(CYLArrayResultBlock)block {
    if (!conversation) {
        !block ?: block(@[], [self errorWithReason:@"conversation is nil"]);
        return;
    }
    [self.IMProvider queryMessagesWithConversation:conversation messageId:messageId timestamp:timestamp limit:limit callback:block];
}

#pragma mark -
#pragma mark - deprecated Method

- (void)fecthConversationWithConversationId:(NSString *)conversationId callback:(CYLConversationResultBlock)callback {
    [self fetchConversationWithConversationId:conversationId callback:callback];
}

- (void)fecthConversationWithPeerId:(NSString *)peerId callback:(CYLConversationResultBlock)callback {
    [self fetchConversationWithPeerId:peerId callback:callback];
}

@end
