//
//  LCCKLeanCloudConversationService.m
//  ChatKit-OC
//
//  Moved from ChatKit's CYLConversationService and CYLConversationListService
//  (v2.1.1, created by ElonChan on 16/3/1 and 16/3/22).
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//
//  LeanCloud conversations and messages, and the SQLite stores of recent conversations
//  and failed messages. ChatKit keeps the UI state (current conversation, hooks) in its own
//  CYLConversationService and calls this class through `LCCKLeanCloudIMProvider`.

#import "LCCKLeanCloudConversationService.h"
#import "LCCKLeanCloudSessionService.h"
#import "AVIMConversation+LCCKExtension.h"
#import "AVIMTypedMessage+LCCKExtension.h"
#import "AVIMMessage+LCCKExtension.h"
#import "CYLMessage+LCCKExtension.h"
#if __has_include(<FMDB/FMDB.h>)
#import <FMDB/FMDB.h>
#else
#import "FMDB.h"
#endif

static NSString *const LCCKLeanCloudConversationServiceErrorDomain = @"LCCKLeanCloudConversationServiceErrorDomain";

@interface LCCKLeanCloudConversationService()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@property (nonatomic, strong) NSMutableDictionary<NSString *, AVIMConversation *> *conversationDictionary;
@property (nonatomic, strong) dispatch_queue_t sqliteQueue;
@property (nonatomic, assign) BOOL refreshedFromServer;

@end

@implementation LCCKLeanCloudConversationService

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _refreshedFromServer = NO;
    return self;
}

- (AVIMClient *)client {
    return [LCCKLeanCloudSessionService sharedInstance].client;
}

- (NSError *)errorWithReason:(NSString *)reason {
    NSInteger code = 0;
    NSDictionary *errorInfo = @{
                                @"code" : @(code),
                                NSLocalizedDescriptionKey : reason ?: @"",
                                };
    return [NSError errorWithDomain:LCCKLeanCloudConversationServiceErrorDomain code:code userInfo:errorInfo];
}

#pragma mark - CYLIMConversationProvider

/**
 *  根据 conversationId 获取对话
 *  @param convid   对话的 id
 *  @param callback
 */
- (void)fetchConversationWithConversationId:(NSString *)conversationId callback:(CYLIMConversationResultBlock)callback {
    AVIMConversation *conversation = [self.client conversationForId:conversationId];
    if (conversation) {
        !callback ?: callback(conversation, nil);
        return;
    }

    NSSet *conversationSet = [NSSet setWithObject:conversationId];
    [self fetchConversationsWithConversationIds:conversationSet callback:^(NSArray *objects, NSError *error) {
        if (error) {
            !callback ?: callback(nil, error);
        } else {
            if (objects.count == 0 || !objects) {
                NSString *errorReasonText = [NSString stringWithFormat:@"conversation of %@ are not exists", conversationId];
                !callback ?: callback(nil, [self errorWithReason:errorReasonText]);
            } else {
                !callback ?: callback(objects[0], error);
            }
        }
    }];
}

- (void)fetchConversationsWithConversationIds:(NSSet *)conversationIds
                                     callback:(CYLArrayResultBlock)callback {
    AVIMConversationQuery *query = [self.client conversationQuery];
    [query whereKey:@"objectId" containedIn:[conversationIds allObjects]];
    query.limit = conversationIds.count;
    query.option = AVIMConversationQueryOptionWithMessage;
    query.cacheMaxAge = kAVIMCachePolicyIgnoreCache;
    [query findConversationsWithCallback: ^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [objects makeObjectsPerformSelector:@selector(lastMessage)];
            dispatch_async(dispatch_get_main_queue(),^{
                !callback ?: callback(objects, error);
            });
        });
    }];
}

- (void)fetchConversationWithPeerId:(NSString *)peerId callback:(CYLIMConversationResultBlock)callback {
    if (![LCCKLeanCloudSessionService sharedInstance].connect) {
        !callback ?: callback(nil, [self errorWithReason:@"Session not opened"]);
        return;
    }
    if ([peerId isEqualToString:[LCCKLeanCloudSessionService sharedInstance].clientId]) {
        NSString *formatString = @"\n\n\
        ------ BEGIN NSException Log ---------------\n \
        class name: %@                              \n \
        ------line: %@                              \n \
        ----reason: %@                              \n \
        ------ END -------------------------------- \n\n";
        NSString *reason = [NSString stringWithFormat:formatString,
                            @(__PRETTY_FUNCTION__),
                            @(__LINE__),
                            @"You cannot chat with yourself"];
        //TODO: add debug model
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), reason);
        return;
    }
    NSString *myId = [LCCKLeanCloudSessionService sharedInstance].clientId;
    NSArray *array = @[ myId, peerId ];
    [self fetchConversationWithMembers:array type:CYLConversationTypeSingle callback:callback];
}

- (void)checkDuplicateValueOfArray:(NSArray *)array {
    NSSet *set = [NSSet setWithArray:array];
    if (set.count != array.count) {
        //TODO: add debug model
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"The array has duplicate value");
        return;
    }
}

- (void)fetchConversationWithMembers:(NSArray *)members type:(CYLConversationType)type callback:(CYLIMConversationResultBlock)callback {
    if ([members containsObject:[LCCKLeanCloudSessionService sharedInstance].clientId] == NO) {
        //TODO: add debug model
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"members should contain myself");
        return;
    }
    [self checkDuplicateValueOfArray:members];
    [self createConversationWithMembers:members type:type unique:YES callback:callback];
}

- (void)createConversationWithMembers:(NSArray *)members type:(CYLConversationType)type unique:(BOOL)unique callback:(CYLIMConversationResultBlock)callback {
    NSString *name = nil;
    if (type == CYLConversationTypeGroup) {
        // 群聊默认名字， 老王、小李
        name = [self groupConversaionDefaultNameForUserIds:members];
    }
    AVIMConversationOption options;
    if (unique) {
        // 如果相同 members 的对话已经存在，将返回原来的对话
        options = AVIMConversationOptionUnique;
    } else {
        // 创建一个新对话
        options = AVIMConversationOptionNone;
    }
    [self.client createConversationWithName:name clientIds:members attributes:@{ CYL_CONVERSATION_TYPE : @(type) } options:options callback:^(AVIMConversation * _Nullable conversation, NSError * _Nullable error) {
        !callback ?: callback(conversation, error);
    }];
}

- (NSString *)groupConversaionDefaultNameForUserIds:(NSArray *)userIds {
    NSError *error = nil;
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:userIds];
    NSString *currentClientId = [LCChatKit sharedInstance].clientId;
    [mutableArray addObject:currentClientId];
    userIds = [mutableArray copy];
    NSArray<id<CYLUserDelegate>> *array = [[CYLUserSystemService sharedInstance] getCachedProfilesIfExists:userIds error:&error];
    if (error || (array.count == 0)) {
        NSString *groupName = [userIds componentsJoinedByString:@","];
        return groupName;
    }

    NSMutableArray *names = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id<CYLUserDelegate>  _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        [names addObject:user.name ?: user.clientId];
    }];
    return [names componentsJoinedByString:@","];
}

- (void)joinConversation:(id<CYLConversationProtocol>)conversation callback:(CYLBooleanResultBlock)callback {
    [(AVIMConversation *)conversation joinWithCallback:^(BOOL succeeded, NSError * _Nullable error) {
        !callback ?: callback(succeeded, error);
    }];
}

- (void)markConversationAsRead:(id<CYLConversationProtocol>)conversation {
    AVIMConversation *avimConversation = (AVIMConversation *)conversation;
    [avimConversation readInBackground];
    [avimConversation setUnreadMessagesMentioned:NO];
}

- (void)prepareConversation:(id<CYLConversationProtocol>)conversation {
    [self pinIMClientToConversationIfNeeded:(AVIMConversation *)conversation];
}

- (void)pinIMClientToConversationIfNeeded:(AVIMConversation *)conversation {
    if (![conversation isKindOfClass:[AVIMConversation class]]) {
        return;
    }
    AVIMClient *client = self.client;
    if (!client) {
        return;
    }
    if (!conversation.imClient || ![conversation.imClient.clientId isEqualToString:client.clientId]) {
        [conversation setValue:client forKey:@"imClient"];
    }
}

#pragma mark - CYLIMMessageProvider

- (id)displayMessageFromIMMessage:(id<CYLIMMessageProtocol>)message {
    if (![message isKindOfClass:[AVIMTypedMessage class]]) {
        return nil;
    }
    return [CYLMessage messageWithAVIMTypedMessage:(AVIMTypedMessage *)message];
}

- (id<CYLIMMessageProtocol>)IMMessageFromMessage:(id)message {
    if ([message isKindOfClass:[AVIMTypedMessage class]]) {
        return message;
    }
    if ([message isKindOfClass:[CYLMessage class]]) {
        return [AVIMTypedMessage lcck_messageWithLCCKMessage:(CYLMessage *)message];
    }
    return nil;
}

- (void)sendMessage:(id<CYLIMMessageProtocol>)message
       conversation:(id<CYLConversationProtocol>)conversation
        mentionList:(NSArray<NSString *> *)mentionList
      progressBlock:(CYLProgressBlock)progressBlock
           callback:(CYLBooleanResultBlock)block {
    [self sendMessage:(AVIMTypedMessage *)message
         conversation:(AVIMConversation *)conversation
              options:AVIMMessageSendOptionRequestReceipt
          mentionList:mentionList
        progressBlock:progressBlock
             callback:block];
}

- (void)sendMessage:(AVIMTypedMessage *)message
       conversation:(AVIMConversation *)conversation
            options:(AVIMMessageSendOption)options
        mentionList:(NSArray<NSString *> *)mentionList
      progressBlock:(CYLProgressBlock)progressBlock
           callback:(CYLBooleanResultBlock)block {
    id<CYLUserDelegate> currentUser = [[CYLUserSystemService sharedInstance] fetchCurrentUser];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    // 云代码中获取到用户名，来设置推送消息, 老王:今晚约吗？
    if (currentUser.name && currentUser.name.length > 0) {
        // 避免为空造成崩溃
        [attributes setObject:currentUser.name forKey:@"username"];
    }
    if ([CYLSettingService sharedInstance].useDevPushCerticate) {
        [attributes setObject:@YES forKey:@"dev"];
    }
    if (message.attributes == nil) {
        message.attributes = attributes;
    } else {
        [attributes addEntriesFromDictionary:message.attributes];
        message.attributes = attributes;
    }
    if (mentionList.count > 0) {
        message.mentionList = mentionList;
    }
    [conversation sendMessage:message options:options progressBlock:progressBlock callback:block];
}

- (void)queryMessagesWithConversation:(id<CYLConversationProtocol>)aConversation
                            messageId:(NSString *)messageId
                            timestamp:(int64_t)timestamp
                                limit:(NSInteger)limit
                             callback:(CYLArrayResultBlock)block {
    AVIMConversation *conversation = (AVIMConversation *)aConversation;
    void (^callback)(NSArray *messages, NSError *error) = ^(NSArray *messages, NSError *error) {
        if (!messages) {
            NSString *errorReason = [NSString stringWithFormat:@"类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"SDK处理异常，请联系SDK维护者修复luohanchenyilong@163.com"];
            NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), errorReason);
        }
        //以下过滤为了避免非法的消息，引起崩溃，确保展示的只有 AVIMTypedMessage 类型
        NSMutableArray *typedMessages = [NSMutableArray array];
        for (AVIMMessage *message in messages) {
            AVIMTypedMessage *typedMessage = [message lcck_getValidTypedMessage];
            !typedMessage ?: [typedMessages addObject:typedMessage];
        }
        !block ?: block(typedMessages, error);
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        if(timestamp == 0) {
            // 该方法能确保在有网络时总是从服务端拉取最新的消息，首次拉取必须使用该方法
            // sdk 会设置好 timestamp
            [conversation queryMessagesWithLimit:limit callback:callback];
        } else {
            //会先根据本地缓存判断是否有必要从服务端拉取，这个方法不能用于首次拉取
            [conversation queryMessagesBeforeId:messageId
                                      timestamp:timestamp
                                          limit:limit
                                       callback:callback];
        }
    });
}

- (void)updateMessage:(id<CYLIMMessageProtocol>)oldMessage
             withText:(NSString *)text
         conversation:(id<CYLConversationProtocol>)conversation
             callback:(CYLIMMessageResultBlock)callback {
    AVIMTypedMessage *newTypedMessage = [AVIMTextMessage messageWithText:text attributes:nil];
    [(AVIMConversation *)conversation updateMessage:(AVIMMessage *)oldMessage toNewMessage:newTypedMessage callback:^(BOOL succeeded, NSError * _Nullable error) {
        !callback ?: callback(succeeded, error, newTypedMessage);
    }];
}

- (void)recallMessage:(id<CYLIMMessageProtocol>)message
         conversation:(id<CYLConversationProtocol>)conversation
             callback:(CYLIMMessageResultBlock)callback {
    [(AVIMConversation *)conversation recallMessage:(AVIMMessage *)message callback:^(BOOL succeeded, NSError * _Nullable error, AVIMRecalledMessage * _Nullable recalledMessage) {
        !callback ?: callback(succeeded, error, recalledMessage);
    }];
}

- (void)downloadAttachmentOfMessage:(CYLMessage *)message completion:(void (^)(NSURL *, NSError *))completion {
    AVIMTypedMessage *typedMessage = message.message;
    if (![typedMessage isKindOfClass:[AVIMTypedMessage class]] || !typedMessage.file) {
        !completion ?: completion(nil, nil);
        return;
    }
    [typedMessage.file downloadWithCompletionHandler:^(NSURL * _Nullable filePath, NSError * _Nullable error) {
        !completion ?: completion(filePath, error);
    }];
}

#pragma mark - conversations local data

- (NSString *)databasePathWithUserId:(NSString *)userId {
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *appId = [LCChatKit sharedInstance].appId;
    return [libPath stringByAppendingPathComponent:[NSString stringWithFormat:@"com.leancloud.lcchatkit.%@.%@.db", appId, userId]];
}

- (void)setupDatabaseWithUserId:(NSString *)userId {
    NSString *dbPath = [self databasePathWithUserId:userId];
    [self setupSucceedMessageDatabaseWithPath:dbPath];
    [self setupFailedMessagesDBWithDatabasePath:dbPath];
}

- (void)setupSucceedMessageDatabaseWithPath:(NSString *)path {
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:CYLConversatoinTableCreateSQL];
    }];
}

- (NSData *)dataFromConversation:(AVIMConversation *)conversation {
    AVIMKeyedConversation *keydConversation = [conversation keyedConversation];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:keydConversation];
    return data;
}

- (AVIMConversation *)conversationFromData:(NSData *)data {
    AVIMKeyedConversation *keyedConversation = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    AVIMConversation *conversation = [self.client conversationWithKeyedConversation:keyedConversation];
    return conversation;
}

#pragma mark - CYLIMRecentConversationProvider

- (void)updateUnreadCountToZeroWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    AVIMConversation *cachedConversation = [self.conversationDictionary objectForKey:conversationId];
    [cachedConversation readInBackground];
    dispatch_async(self.sqliteQueue, ^{
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:CYLConversationTableUpdateUnreadCountSQL  withArgumentsInArray:@[@0, conversationId]];
        }];
    });
    if (shouldRefreshWhenFinished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationConversationListDataSourceUpdated object:self];
    }
}

- (void)deleteRecentConversationWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    [self.conversationDictionary removeObjectForKey:conversationId];
    dispatch_async(self.sqliteQueue, ^{
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:CYLConversationTableDeleteSQL withArgumentsInArray:@[conversationId]];
        }];
    });
    if (shouldRefreshWhenFinished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationConversationListDataSourceUpdated object:self];
    }
}

- (void)insertRecentConversations:(NSArray<id<CYLConversationProtocol>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    dispatch_async(self.sqliteQueue, ^{
        [conversations enumerateObjectsUsingBlock:^(id<CYLConversationProtocol> _Nonnull aConversation, NSUInteger idx, BOOL * _Nonnull stop) {
            AVIMConversation *conversation = (AVIMConversation *)aConversation;
            if (![conversation isKindOfClass:[AVIMConversation class]] || !conversation.createAt) {
                return;
            }
            AVIMConversation *cachedConversation = [self.conversationDictionary objectForKey:conversation.conversationId];
            if (!cachedConversation) {
                [self.conversationDictionary setObject:conversation forKey:conversation.conversationId];
            }
            [self.databaseQueue inDatabase:^(FMDatabase *db) {
                NSData *data = [self dataFromConversation:conversation];
                [db executeUpdate:CYLConversationTableInsertSQL withArgumentsInArray:@[conversation.conversationId, data, @0, @(NO), @""]];
            }];
        }];

        dispatch_async(dispatch_get_main_queue(),^{
            if (shouldRefreshWhenFinished) {
                [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationConversationListDataSourceUpdated object:self];
            }
        });
    });
}

- (BOOL)isRecentConversationExistWithConversationId:(NSString *)conversationId {
    AVIMConversation *cachedConversation = [self.conversationDictionary objectForKey:conversationId];
    BOOL exists = NO;
    if (cachedConversation) {
        exists = YES;
    }
    return exists;
}

- (void)increaseUnreadCount:(NSUInteger)increaseUnreadCount withConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    dispatch_async(self.sqliteQueue, ^{
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            if (increaseUnreadCount == 1) {
                [db executeUpdate:CYLConversationTableIncreaseOneUnreadCountSQL withArgumentsInArray:@[conversationId]];
            } else {
                [db executeUpdate:CYLConversationTableIncreaseUnreadCountSQL withArgumentsInArray:@[@(increaseUnreadCount) ,conversationId]];
            }
        }];
    });
    if (shouldRefreshWhenFinished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationConversationListDataSourceUpdated object:self];
    }
}

- (void)updateMentioned:(BOOL)mentioned conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    dispatch_async(self.sqliteQueue, ^{
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:CYLConversationTableUpdateMentionedSQL withArgumentsInArray:@[@(mentioned), conversationId]];
        }];
    });
    if (shouldRefreshWhenFinished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationConversationListDataSourceUpdated object:self];
    }
}

- (NSString *)draftWithConversationId:(NSString *)conversationId {
    AVIMConversation *cachedConversation = [self.conversationDictionary objectForKey:conversationId];
    return [cachedConversation.cyl_draft copy];
}

- (void)updateDraft:(NSString *)draft conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    AVIMConversation *cachedConversation = [self.conversationDictionary objectForKey:conversationId];
    cachedConversation.cyl_draft = [draft copy];
    dispatch_async(self.sqliteQueue, ^{
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:CYLConversationTableUpdateDraftSQL withArgumentsInArray:@[draft ?: @"", conversationId]];
        }];
    });
    if (shouldRefreshWhenFinished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationConversationListDataSourceUpdated object:self];
    }
}

- (AVIMConversation *)createConversationFromResultSet:(FMResultSet *)resultSet {
    NSData *data = [resultSet dataForColumn:CYLConversationTableKeyData];
    NSString *draft = [resultSet stringForColumn:CYLConversationTableKeyDraft];
    AVIMConversation *conversation = [self conversationFromData:data];
    conversation.cyl_draft = draft;
    [self pinIMClientToConversationIfNeeded:conversation];
    return conversation;
}

- (NSArray *)allRecentConversations {
    NSArray *conversations = [self.conversationDictionary allValues];
    return conversations;
}

- (void)updateRecentConversation:(NSArray *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished {
    for (AVIMConversation *conversation in conversations) {
        AVIMConversation *cachedConversation = [self.conversationDictionary objectForKey:conversation.conversationId];
        if (cachedConversation) {
            conversation.cyl_draft = [cachedConversation.cyl_draft copy];
            [self.conversationDictionary setObject:conversation forKey:conversation.conversationId];
        }
    }
    dispatch_async(self.sqliteQueue, ^{
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            [db beginTransaction];
            for (AVIMConversation *conversation in conversations) {
                [db executeUpdate:CYLConversationTableUpdateDataSQL, [self dataFromConversation:conversation], conversation.conversationId];
            }
            [db commit];
        }];
    });
    if (shouldRefreshWhenFinished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationConversationListDataSourceUpdated object:self];
    }
}

/**
 *  删除全部缓存，比如当切换用户时，如果同一个人显示的名称和头像需要变更
 */
- (BOOL)removeAllCachedRecentConversations {
    __block BOOL removeAllCachedRecentConversationsSuccess = NO;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        removeAllCachedRecentConversationsSuccess = [db executeUpdate:CYLDeleteConversationTable];
    }];
    if (removeAllCachedRecentConversationsSuccess) {
        [self.conversationDictionary removeAllObjects];
    }
    return removeAllCachedRecentConversationsSuccess;
}

#pragma mark - conversation list

- (void)findRecentConversationsWithBlock:(CYLIMRecentConversationsResultBlock)block {
    [self selectOrRefreshConversationsWithBlock:^(NSArray *conversations, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSMutableArray *filterConversation = [NSMutableArray arrayWithCapacity:conversations.count];
            NSMutableSet *userIds = [NSMutableSet set];
            NSUInteger totalUnreadCount = 0;
            for (AVIMConversation *conversation in conversations) {
                BOOL hasHistory = (conversation.lastMessage);
                if (hasHistory) {
                    [filterConversation addObject:conversation];
                    if (conversation.cyl_type == CYLConversationTypeSingle) {
                        [userIds addObject:conversation.cyl_peerId];
                    } else {
                        NSString *userId = conversation.cyl_lastMessage.clientId;
                        (!userId || !conversation.cyl_lastMessage) ?: [userIds addObject:userId];
                    }
                }
                if (conversation.muted == NO && conversation.unreadMessagesCount > 0) {
                    totalUnreadCount += conversation.unreadMessagesCount;
                }
            }
            NSArray *sortedRooms = [filterConversation sortedArrayUsingComparator:^NSComparisonResult(AVIMConversation *conv1, AVIMConversation *conv2) {
                return (NSComparisonResult)(conv2.cyl_lastMessage.sendTimestamp - conv1.cyl_lastMessage.sendTimestamp);
            }];
            dispatch_async(dispatch_get_main_queue(),^{
                !block ?: block(sortedRooms, totalUnreadCount, error);
            });

            if (userIds.count == 0) {
                return;
            }
            [[CYLUserSystemService sharedInstance] cacheUsersWithIds:userIds callback:nil];
        });
    }];
}

- (void)fetchRelationConversationsFromServerCallback:(CYLArrayResultBlock)block {
    AVIMClient *client = self.client;
    AVIMConversationQuery *orConversationQuery = [client conversationQuery];
    orConversationQuery.cachePolicy = kAVIMCachePolicyIgnoreCache;
    orConversationQuery.option = AVIMConversationQueryOptionWithMessage;
    orConversationQuery.limit = 100;
    [orConversationQuery findConversationsWithCallback:^(NSArray<AVIMConversation *> * _Nullable conversations, NSError * _Nullable error) {
        !block ?: block(conversations, error);
    }];
}

- (void)selectOrRefreshConversationsWithBlock:(CYLArrayResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSArray *originConversations = [self allRecentConversations];
        void(^FilterCallback)(NSArray<AVIMConversation *> *conversations) = ^(NSArray<AVIMConversation *> *conversations) {
            if (self.refreshedFromServer || ![LCCKLeanCloudSessionService sharedInstance].connect) {
                dispatch_async(dispatch_get_main_queue(),^{
                    !block ?: block(conversations, nil);
                });
                return;
            }

            NSMutableSet *conversationIds = [NSMutableSet set];
            for (AVIMConversation *conversation in conversations) {
                [conversationIds addObject:conversation.conversationId];
            }
            [self fetchConversationsWithConversationIds:conversationIds callback:^(NSArray *objects, NSError *error) {
                if (error) {
                    !block ?: block(conversations, error);
                    return ;
                }
                self.refreshedFromServer = YES;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    [self updateRecentConversation:conversations shouldRefreshWhenFinished:YES];
                    dispatch_async(dispatch_get_main_queue(),^{
                        !block ?: block(conversations, error);
                    });
                });
            }];

        };

        CYLConversationListShowHookBlock conversationListShowHookBlock = [CYLConversationListService sharedInstance].conversationListShowHookBlock;
        if (!conversationListShowHookBlock) {
            FilterCallback(originConversations);
            return;
        }
        CYLConversationListShowHookCompletionHandler conversationListShowHookCompletionHandler = ^(NSArray<id<CYLConversationProtocol>> *conversations, NSError *aError) {
            FilterCallback(aError ? originConversations : (NSArray<AVIMConversation *> *)conversations);
        };
        conversationListShowHookBlock(originConversations, conversationListShowHookCompletionHandler);
        return;
    });
}

#pragma mark - conversationDictionary

/**
 *  在内存中缓存对话，避免反复查询数据库，与数据库保持一致，只对数据库只做增、删、改操作。
 */
- (NSMutableDictionary *)conversationDictionary {
    if (!_conversationDictionary) {
        _conversationDictionary = [[NSMutableDictionary alloc] init];
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            FMResultSet  *resultSet = [db executeQuery:CYLConversationTableSelectSQL withArgumentsInArray:@[]];
            while ([resultSet next]) {
                AVIMConversation *conversation = [self createConversationFromResultSet:resultSet];
                BOOL isAvailable = conversation.createAt;
                if (isAvailable) {
                    [_conversationDictionary setObject:conversation forKey:conversation.conversationId];
                }
            }
            [resultSet close];
        }];
    }
    return _conversationDictionary;
}

/**
 *  数据库增删改queue，对数据库的操作在这个queue上执行。
 */
- (dispatch_queue_t)sqliteQueue {
    if (!_sqliteQueue) {
        _sqliteQueue = dispatch_queue_create("com.chatkit-oc.sqliteQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _sqliteQueue;
}

#pragma mark - CYLIMFailedMessageProvider
///=============================================================================
/// @name FailedMessageStore
///=============================================================================

/**
 *  openClient 时调用
 *  @param path 与 clientId 相关
 */
- (void)setupFailedMessagesDBWithDatabasePath:(NSString *)path {
    if (!self.databaseQueue) {
        CYLLog(@"database queue should not be nil !!!!");
    }
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:CYLCreateTableSQL];
    }];
}

- (NSDictionary *)recordFromResultSet:(FMResultSet *)resultSet {
    NSMutableDictionary *record = [NSMutableDictionary dictionary];
    NSData *data = [resultSet dataForColumn:CYLKeyMessage];
    if (!data) {
        return nil;
    }
    id message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [record setObject:message forKey:CYLKeyMessage];
    NSString *idValue = [resultSet stringForColumn:CYLKeyId];
    [record setObject:idValue forKey:CYLKeyId];
    return record;
}

- (NSArray *)recordsByConversationId:(NSString *)conversationId {
    NSMutableArray *records = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:CYLSelectMessagesSQL, conversationId];
        while ([resultSet next]) {
            [records addObject:[self recordFromResultSet:resultSet]];
        }
        [resultSet close];
    }];
    return records;
}

- (NSArray *)failedMessagesByConversationId:(NSString *)conversationId {
    NSArray *records = [self recordsByConversationId:conversationId];
    NSMutableArray *messages = [NSMutableArray array];
    for (NSDictionary *record in records) {
        [messages addObject:record[CYLKeyMessage]];
    }
    return messages;
}

- (NSArray *)failedMessageIdsByConversationId:(NSString *)conversationId {
    NSArray *records = [self recordsByConversationId:conversationId];
    NSMutableArray *failedMessageIds = [NSMutableArray array];
    for (NSDictionary *record in records) {
        [failedMessageIds addObject:record[CYLKeyId]];
    }
    return failedMessageIds;
}

- (NSArray *)recordsByMessageIds:(NSArray<NSString *> *)messageIds {
    NSString *messageIdsString = [messageIds componentsJoinedByString:@"','"];
    NSMutableArray *records = [NSMutableArray array];
    NSString *query = [NSString stringWithFormat:CYLSelectMessagesByIDSQL, messageIdsString];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:query];
        while ([resultSet next]) {
            [records addObject:[self recordFromResultSet:resultSet]];
        }
        [resultSet close];
    }];

    return records;
}

- (NSArray *)failedMessagesByMessageIds:(NSArray *)messageIds {
    NSArray *records = [self recordsByMessageIds:messageIds];
    if (records.count == 0) {
        return nil;
    }
    NSMutableArray *messages = [NSMutableArray array];
    for (NSDictionary *record in records) {
        [messages addObject:record[CYLKeyMessage]];
    }
    return messages;
}

- (BOOL)deleteFailedMessageByRecordId:(NSString *)recordId {
    __block BOOL result;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:CYLDeleteMessageSQL, recordId];
    }];
    return result;
}

- (void)insertFailedCYLMessage:(CYLMessage *)message {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    NSAssert(data, @"You can not insert nil message to DB");
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:CYLInsertMessageSQL, message.localMessageId, message.conversationId, data];
    }];
}

- (void)insertFailedMessage:(id<CYLIMMessageProtocol>)message {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:CYLInsertMessageSQL, message.messageId, message.conversationId, data];
    }];
}

@end
