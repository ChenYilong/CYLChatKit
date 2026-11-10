//
//  LCCKLeanCloudSessionService.m
//  ChatKit-OC
//
//  Moved from ChatKit's CYLSessionService (v2.1.1, created by ElonChan on 16/3/1).
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//
//  The LeanCloud IM session: AVIMClient lifecycle, client delegate callbacks, and
//  received-message handling. UI-side logic (reconnect HUD, single sign-on alert)
//  stays in ChatKit's CYLSessionService.

#import "LCCKLeanCloudSessionService.h"
#import <AVOSCloudIM/AVOSCloudIM.h>
#import "LCCKLeanCloudConversationService.h"
#import "AVIMConversation+LCCKExtension.h"
#import "AVIMMessage+LCCKExtension.h"
#import "CYLSoundManager.h"

static NSString *const LCCKLeanCloudSessionServiceErrorDomain = @"LCCKLeanCloudSessionServiceErrorDomain";

@interface LCCKLeanCloudSessionService() <AVIMClientDelegate, AVIMSignatureDataSource>

@property (nonatomic, assign, readwrite) BOOL connect;
@property (nonatomic, assign, getter=isPlayingSound) BOOL playingSound;

@end

@implementation LCCKLeanCloudSessionService
@synthesize clientId = _clientId;
@synthesize client = _client;

- (BOOL)isClientOpened {
    return _client.status == AVIMClientStatusOpened;
}

/*!
 * ChatKit's CYLSessionService has validated `clientId` and dispatched to the main queue.
 */
- (void)openWithClientId:(NSString *)clientId force:(BOOL)force callback:(CYLBooleanResultBlock)callback {
    _clientId = clientId;
    [[LCCKLeanCloudConversationService sharedInstance] setupDatabaseWithUserId:_clientId];
    //判断是否是第一次使用该appId
    [[LCChatKit sharedInstance] cyl_isFirstLaunchToEvent:[LCChatKit sharedInstance].appId
                                               evenUpdate:YES
                                              firstLaunch:^BOOL(){
                                                  return [[LCChatKit sharedInstance] removeAllCachedRecentConversations];
                                              }];
    NSString *tag;
    if (![CYLSessionService sharedInstance].disableSingleSignOn) {
        tag = clientId;
    }
    _client = [[AVIMClient alloc] initWithClientId:clientId tag:tag];
    _client.delegate = self;
    /* 实现了generateSignatureBlock，将对 im 的 open , start(create conv), kick, invite 操作签名，更安全.
     可以从你的服务器获得签名，也可以部署云代码获取 https://leancloud.cn/docs/leanengine_overview.html .
     */
    if ([[LCChatKit sharedInstance] generateSignatureBlock]) {
        _client.signatureDataSource = self;
    }
    
    AVIMClientOpenOption option = AVIMClientOpenOptionReopen;
    if (force) {
        option = AVIMClientOpenOptionForceOpen;
    }
    [_client openWithOption:option callback:^(BOOL succeeded, NSError *error) {
        [self updateConnectStatus];
        BOOL isFirstLaunchForClientId = [[LCChatKit sharedInstance] cyl_isFirstLaunchToEvent:clientId
                                                                                   evenUpdate:YES
                                                                                  firstLaunch:^BOOL(){
                                                                                      return YES;
                                                                                  }];
        if (succeeded  && isFirstLaunchForClientId) {
            [[LCCKLeanCloudConversationService sharedInstance] fetchRelationConversationsFromServerCallback:^(NSArray * _Nullable conversations, NSError * _Nullable error) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    [[LCCKLeanCloudConversationService sharedInstance] insertRecentConversations:conversations ?: @[] shouldRefreshWhenFinished:NO];
                    dispatch_async(dispatch_get_main_queue(),^{
                        !callback ?: callback(succeeded, error);
                    });
                });
            }];
        } else {
            !callback ?: callback(succeeded, error);
        }
        if (error.code == AVIMErrorCodeSessionConflict) {
            [self handleSingleSignOnError:error callback:^(BOOL succeeded, NSError *error) {
                !callback ?: callback(succeeded, error);
            }];
        }
    }];
}

- (void)closeWithCallback:(CYLBooleanResultBlock)callback {
    [_client closeWithCallback:^(BOOL succeeded, NSError *error) {
        !callback ?: callback(succeeded, error);
    }];
}

#pragma mark - AVIMClientDelegate

- (void)imClientPaused:(AVIMClient *)imClient {
    [self updateConnectStatus];
}

- (void)imClientResuming:(AVIMClient *)imClient {
    [self updateConnectStatus];
}

- (void)imClientResumed:(AVIMClient *)imClient {
    [self updateConnectStatus];
    [NSNotificationCenter.defaultCenter postNotificationName:CYLNotificationSessionResumed object:nil];
}

- (void)imClientClosed:(AVIMClient *)imClient error:(NSError * _Nullable)error {
    [self updateConnectStatus];
}

/*!
 * Another device logged in with the same client id: let ChatKit ask the user and reconnect.
 */
- (void)handleSingleSignOnError:(NSError *)aError callback:(CYLBooleanResultBlock)aCallback {
    if (aError.code == AVIMErrorCodeSessionConflict) {
        [[CYLSessionService sharedInstance] handleSingleSignOnError:aError callback:aCallback];
    }
}

- (void)client:(AVIMClient *)client didOfflineWithError:(NSError *)aError {
    [self handleSingleSignOnError:aError callback:nil];
}

#pragma mark - status

// 除了 sdk 的上面三个回调调用了，还在 open client 的时候调用了，好统一处理
- (void)updateConnectStatus {
    /* for better UI presentation */
    ///
    if (_client.status == AVIMClientStatusPaused ||
        _client.status == AVIMClientStatusResuming) {
        return;
    }
    ///
    self.connect = _client.status == AVIMClientStatusOpened;
    [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationConnectivityUpdated object:@(self.connect)];
}

#pragma mark - signature

- (AVIMSignature *)signatureWithClientId:(NSString *)clientId
                          conversationId:(NSString *)conversationId
                                  action:(NSString *)action
                       actionOnClientIds:(NSArray *)clientIds {
    __block AVIMSignature *signature_;
    CYLGenerateSignatureBlock generateSignatureBlock = [[LCChatKit sharedInstance] generateSignatureBlock];
    CYLGenerateSignatureCompletionHandler completionHandler = ^(AVIMSignature *signature, NSError *error) {
        if (!error) {
            signature_ = signature;
        } else {
            NSLog(@"%@",error);
        }
    };
    generateSignatureBlock(clientId, conversationId, action, clientIds, completionHandler);
    return signature_;
}


#pragma mark - AVIMMessageDelegate

/*!
 * 低版本如果不支持某自定义消息，该自定义消息会走该代理
 */
- (void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message {
    if (!message.lcck_isValidMessage) {
        return;
    }
    AVIMTypedMessage *typedMessage = [message lcck_getValidTypedMessage];
    [self conversation:conversation didReceiveTypedMessage:typedMessage];
}

- (void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message {
    if (!message.lcck_isValidMessage) {
        return;
    }
    if (!message.messageId) {
        CYLLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"Receive Message , but MessageId is nil");
        return;
    }
    void (^fetchedConversationCallback)() = ^() {
        [self receiveMessage:message conversation:conversation];
    };
    [self makeSureConversation:conversation isAvailableCallback:fetchedConversationCallback];
}

- (void)conversation:(AVIMConversation *)conversation messageDelivered:(AVIMMessage *)message {
    [self didReceiveStatusMessage:message conversation:conversation];
}

- (void)conversation:(AVIMConversation *)conversation messageRead:(AVIMMessage *)message {
}

- (void)didReceiveStatusMessage:(AVIMMessage *)message conversation:(AVIMConversation *)conversation {
    if (!message.lcck_isValidMessage) {
        return;
    }
    NSDictionary *userInfo = @{
                               CYLMessageNotifacationUserInfoConversationKey : conversation,
                               CYLMessageNotifacationUserInfoMessageKey : message,
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationMessageDelivered object:userInfo];
}

- (void)conversation:(AVIMConversation *)conversation didUpdateForKey:(AVIMConversationUpdatedKey)key {
    NSString *currentConversationId = CYLConversationService.sharedInstance.currentConversationId;
    NSString *conversationId = conversation.conversationId;
    
    if ([key isEqualToString:AVIMConversationUpdatedKeyUnreadMessagesCount]) {
        if ([currentConversationId isEqualToString:conversationId]) {
            // do nothing.
        } else {
            [CYLConversationService.sharedInstance insertRecentConversation:conversation shouldRefreshWhenFinished:true];
        }
        return;
    }
    
    if ([key isEqualToString:AVIMConversationUpdatedKeyUnreadMessagesMentioned]) {
        if ([currentConversationId isEqualToString:conversationId]) {
            // do nothing
        } else {
            [CYLConversationService.sharedInstance insertRecentConversation:conversation shouldRefreshWhenFinished:true];
        }
        return;
    }
    
    if ([key isEqualToString:AVIMConversationUpdatedKeyLastMessage]) {
        if ([currentConversationId isEqualToString:conversationId]) {
            // do nothing
        } else {
            [CYLConversationService.sharedInstance insertRecentConversation:conversation shouldRefreshWhenFinished:true];
        }
        return;
    }
    
}

- (void)conversation:(AVIMConversation *)conversation messageHasBeenUpdated:(AVIMMessage *)message {
    NSString *currentConversationId = CYLConversationService.sharedInstance.currentConversationId;
    NSString *conversationId = conversation.conversationId;
    if ([currentConversationId isEqualToString:conversationId]) {
        NSDictionary *userInfo = @{
                                   CYLMessageNotifacationUserInfoConversationKey: conversation,
                                   CYLMessageNotifacationUserInfoMessageKey: message };
        [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationMessageUpdated object:userInfo];
    }
}

- (void)conversation:(AVIMConversation *)conversation
didMemberInfoUpdateBy:(NSString *)byClientId
            memberId:(NSString *)memberId
                role:(AVIMConversationMemberRole)role {
    void (^memberInfoChangedBlock)(id<CYLConversationProtocol>, NSString *, NSString *, NSUInteger) = [CYLSessionService sharedInstance].memberInfoChangedBlock;
    !memberInfoChangedBlock ?: memberInfoChangedBlock(conversation, byClientId, memberId, (NSUInteger)role);
}

- (void)makeSureConversation:(AVIMConversation *)conversation isAvailableCallback:(CYLVoidBlock)callback {
    if (!conversation.createAt && ![[LCCKLeanCloudConversationService sharedInstance] isRecentConversationExistWithConversationId:conversation.conversationId]) {
        [conversation fetchWithCallback:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                !callback ?: callback();
                return;
            }
            CYLLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), error);
        }];
    } else {
        !callback ?: callback();
    }
}

- (void)conversation:(AVIMConversation *)conversation kickedByClientId:(NSString *)clientId {
    [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationConversationInvalided object:clientId];
    if ([[CYLConversationService sharedInstance].currentConversationId isEqualToString:conversation.conversationId]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationCurrentConversationInvalided object:clientId];
    }
}

#pragma mark - receive message handle

- (void)receiveMessage:(AVIMTypedMessage *)message conversation:(AVIMConversation *)conversation {
    if (message.mediaType > 0) {
        NSDictionary *userInfo = @{
                                   CYLMessageNotifacationUserInfoConversationKey : conversation,
                                   CYLDidReceiveCustomMessageUserInfoMessageKey : message,
                                   };
        [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationCustomTransientMessageReceived object:userInfo];
    }
    if (!message || !conversation) {
        return;
    }
    [self receiveMessages:@[message] conversation:conversation isUnreadMessage:NO];
}

- (void)receiveMessages:(NSArray<AVIMTypedMessage *> *)messages
           conversation:(AVIMConversation *)conversation
        isUnreadMessage:(BOOL)isUnreadMessage {
    
    void (^checkMentionedMessageCallback)() = ^(NSArray *filterdMessages) {
        // - 插入最近对话列表
        // 下面的LCCKNotificationMessageReceived也会通知ConversationListVC刷新
        [[CYLConversationService sharedInstance] insertRecentConversation:conversation shouldRefreshWhenFinished:NO];
        // - 播放接收音
        if (!isUnreadMessage) {
            [self playLoudReceiveSoundIfNeededForConversation:conversation];
        }
        NSDictionary *userInfo = @{
                                   CYLMessageNotifacationUserInfoConversationKey : conversation,
                                   CYLDidReceiveMessagesUserInfoMessagesKey : filterdMessages,
                                   };
        // - 通知相关页面接收到了消息：“当前对话页面”、“最近对话页面”；
        [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationMessageReceived object:userInfo];
    };
    
    void(^filteredMessageCallback)(NSArray *originalMessages) = ^(NSArray *filterdMessages) {
        if (filterdMessages.count == 0) { return; }
        // - 在最近对话列表页时，检查是否有人@我
        if ([CYLConversationService.sharedInstance.currentConversationId isEqualToString:conversation.conversationId] && [CYLConversationService.sharedInstance isChatting] && isUnreadMessage) {
            [conversation readInBackground];
            conversation.unreadMessagesMentioned = false;
            !checkMentionedMessageCallback ?: checkMentionedMessageCallback(filterdMessages);
        } else {
            // 没有在聊天的时候才增加未读数和设置mentioned
            [self isMentionedByMessages:filterdMessages callback:^(BOOL succeeded, NSError *error) {
                !checkMentionedMessageCallback ?: checkMentionedMessageCallback(filterdMessages);
                if (succeeded) {
                    [[CYLConversationService sharedInstance] updateMentioned:YES conversationId:conversation.conversationId];
                    // 下面的LCCKNotificationMessageReceived也会通知ConversationListVC刷新
                    // [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationUnreadsUpdated object:nil];
                }
            }];
            
        }
    };
    
    CYLFilterMessagesBlock filterMessagesBlock = [CYLConversationService sharedInstance].filterMessagesBlock;
    if (filterMessagesBlock) {
        CYLFilterMessagesCompletionHandler filterMessagesCompletionHandler = ^(NSArray *filteredMessages, NSError *error) {
            if (!error) {
                !filteredMessageCallback ?: filteredMessageCallback([filteredMessages copy]);
            }
        };
        filterMessagesBlock(conversation, messages, filterMessagesCompletionHandler);
    } else {
        !filteredMessageCallback ?: filteredMessageCallback(messages);
    }
}

/*!
 * 如果是未读消息，会在 query 时播放一次，避免重复播放
 */
- (void)playLoudReceiveSoundIfNeededForConversation:(AVIMConversation *)conversation {
    if ([CYLConversationService sharedInstance].chatting) {
        //FIXME:
//        [conversation markAsReadInBackgroundForMessage:conversation.cyl_lastMessage];
        [conversation readInBackground];
        return;
    }
    if (conversation.muted) {
        return;
    }
    if (self.isPlayingSound) {
        return;
    }
    self.playingSound = YES;
    [[CYLSoundManager defaultManager] playLoudReceiveSoundIfNeed];
    [[CYLSoundManager defaultManager] vibrateIfNeed];
    //一定时间之内只播放声音一次
    NSUInteger delaySeconds = 1;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        self.playingSound = NO;
    });
}

#pragma mark - mention

- (void)isMentionedByMessages:(NSArray<AVIMTypedMessage *> *)messages callback:(CYLBooleanResultBlock)callback {
    if (!messages || messages.count == 0) {
        NSInteger code = 0;
        NSString *errorReasonText = @"no message to check";
        NSDictionary *errorInfo = @{
                                    @"code":@(code),
                                    NSLocalizedDescriptionKey : errorReasonText,
                                    };
        NSError *error = [NSError errorWithDomain:LCCKLeanCloudSessionServiceErrorDomain
                                             code:code
                                         userInfo:errorInfo];
        !callback ?: callback(NO, error);
        return;
    }

    __block BOOL isMentioned = NO;
    [[CYLUserSystemService sharedInstance] fetchCurrentUserInBackground:^(id<CYLUserDelegate> currentUser, NSError *error) {
        NSString *queueBaseLabel = [NSString stringWithFormat:@"com.chatkit.%@", NSStringFromClass([self class])];
        const char *queueName = [[NSString stringWithFormat:@"%@.%@.ForBarrier",queueBaseLabel, [[NSUUID UUID] UUIDString]] UTF8String];
        dispatch_queue_t queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT);
        
        [messages enumerateObjectsUsingBlock:^(AVIMTypedMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![message isKindOfClass:[AVIMTextMessage class]]) {
                return;
            }
            dispatch_async(queue, ^(void) {
                if (isMentioned) {
                    return;
                }
                NSString *text = ((AVIMTextMessage *)message).text;
                BOOL isMentioned_ = [self isMentionedByText:text currentUser:currentUser];
                //只要有一个提及，就callback
                if (isMentioned_) {
                    isMentioned = YES;
                    *stop = YES;
                    return;
                }
            });
        }];
        
        dispatch_barrier_async(queue, ^{
            //最后一个也没有提及就callback
            NSError *error = nil;
            if (!isMentioned) {
                NSInteger code = 0;
                NSString *errorReasonText = @"not mentioned";
                NSDictionary *errorInfo = @{
                                            @"code":@(code),
                                            NSLocalizedDescriptionKey : errorReasonText,
                                            };
                error = [NSError errorWithDomain:LCCKLeanCloudSessionServiceErrorDomain                                                         code:code
                                        userInfo:errorInfo];
            }
            dispatch_async(dispatch_get_main_queue(),^{
                !callback ?: callback(isMentioned, error);
            });
        });
        
    }];
}

- (BOOL)isMentionedByText:(NSString *)text currentUser:(id<CYLUserDelegate>)currentUser {
    if (!text || (text.length == 0)) {
        return NO;
    }
    NSString *patternWithUserName = [NSString stringWithFormat:@"@%@ ",currentUser.name ?: currentUser.clientId];
    NSString *patternWithLowercaseAll = @"@all ";
    NSString *patternWithUppercaseAll = @"@All ";
    BOOL isMentioned = [text cyl_containsString:patternWithUserName] || [text cyl_containsString:patternWithLowercaseAll] || [text cyl_containsString:patternWithUppercaseAll];
    if(isMentioned) {
        return YES;
    } else {
        return NO;
    }
}


@end
