 //
//  CYLConversationViewModel.m
//  CYLChatExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/18.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

#import "CYLConversationViewModel.h"

#import "CYLChatTextMessageCell.h"
#import "CYLChatImageMessageCell.h"
#import "CYLChatVoiceMessageCell.h"
#import "CYLChatSystemMessageCell.h"
#import "CYLChatLocationMessageCell.h"

#import "CYLAVAudioPlayer.h"
#import "CYLChatConstants.h"
#import "CYLConversationService.h"
#import "CYLSoundManager.h"

#import "UITableView+FDTemplateLayoutCell.h"
#import "CYLCellIdentifierFactory.h"

#import "CYLMessage.h"
#import "CYLConversationViewController.h"
#import "CYLUserSystemService.h"
#import "CYLSessionService.h"
#import "UIImage+CYLExtension.h"
#import "NSMutableArray+CYLMessageExtention.h"
#import "CYLAlertController.h"
#import "NSObject+CYLExtension.h"

#if __has_include(<CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>)
#import <CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>
#else
#import "CYLDeallocBlockExecutor.h"
#endif

#define CYLLock() dispatch_semaphore_wait(self->_cyl_lock, DISPATCH_TIME_FOREVER)
#define CYLUnlock() dispatch_semaphore_signal(self->_cyl_lock)

@interface CYLConversationViewModel () {
    dispatch_semaphore_t _cyl_lock;
}

@property (nonatomic, weak) CYLConversationViewController *parentConversationViewController;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray<id<CYLIMMessageProtocol>> *avimTypedMessage;

/*!
 * 懒加载，只在下拉刷新和第一次进入时，做消息流插入，所以在conversationViewController的生命周期里，只load一次就可以。
 */
@property (nonatomic, copy) NSArray *allFailedMessageIds;
@property (nonatomic, strong) NSArray *allFailedMessages;

@end

@implementation CYLConversationViewModel

- (instancetype)initWithParentViewController:(CYLConversationViewController *)parentConversationViewController {
    if (self = [super init]) {
        _cyl_lock = dispatch_semaphore_create(1);
        _dataArray = [NSMutableArray array];
        _avimTypedMessage = [NSMutableArray array];
        self.parentConversationViewController = parentConversationViewController;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:CYLNotificationMessageReceived object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationInvalided:) name:CYLNotificationCurrentConversationInvalided object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageStatusChanged:) name:CYLNotificationMessageRead object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageStatusChanged:) name:CYLNotificationMessageDelivered object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundImageChanged:) name:CYLNotificationConversationViewControllerBackgroundImageDidChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileMessageDidDownload:) name:CYLNotificationConversionImageMessageDidDownloaded object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(refresh) name:CYLNotificationSessionResumed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageUpdated:) name:CYLNotificationMessageUpdated object:nil];
        [self cyl_willDeallocWithSelfCallback:^(__unsafe_unretained id owner, NSUInteger identifier) {
            [[NSNotificationCenter defaultCenter] removeObserver:owner];
        }];
    }
    return self;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (void)fileMessageDidDownload:(NSNotification *)notification {
    CYLChatImageMessageCell *cell = notification.object;
    if (!cell) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(fileMessageDidDownload:)]) {
        [self.delegate performSelector:@selector(fileMessageDidDownload:) withObject:cell];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id message = self.dataArray[indexPath.row];
    NSString *identifier = [CYLCellIdentifierFactory cellIdentifierForMessageConfiguration:message conversationType:[self.parentConversationViewController getConversationIfExists].cyl_type];
    CYLChatMessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    messageCell.tableView = self.parentConversationViewController.tableView;
    messageCell.indexPath = indexPath;
    messageCell.delegate = self.parentConversationViewController;
    if ([messageCell respondsToSelector:@selector(configureCellWithData:)]) {
        [messageCell configureCellWithData:message];
    }
    return messageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id message = self.dataArray[indexPath.row];
    NSString *identifier = [CYLCellIdentifierFactory cellIdentifierForMessageConfiguration:message conversationType:[self.parentConversationViewController getConversationIfExists].cyl_type];
    NSString *cacheKey = [CYLCellIdentifierFactory cacheKeyForMessage:message];
    return [tableView fd_heightForCellWithIdentifier:identifier cacheByKey:cacheKey configuration:^(CYLChatMessageCell *cell) {
        [cell configureCellWithData:message];
    }];
}

#pragma mark - CYLChatServerDelegate

- (void)receiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = notification.object;
    if (!userInfo) {
        return;
    }
    NSArray<id<CYLIMMessageProtocol>> *messages = userInfo[CYLDidReceiveMessagesUserInfoMessagesKey];
    id<CYLConversationProtocol> conversation = userInfo[CYLMessageNotifacationUserInfoConversationKey];
    BOOL isCurrentConversationMessage = [self isCurrentConversationMessageForConversationId:conversation.conversationId];
    if (!isCurrentConversationMessage) {
        return;
    }
    id<CYLConversationProtocol> currentConversation = [self.parentConversationViewController getConversationIfExists];
    if (currentConversation.muted == NO) {
        [[CYLSoundManager defaultManager] playReceiveSoundIfNeed];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSArray *lcckMessages = [NSMutableArray cyl_messagesWithAVIMMessages:messages];
        dispatch_async(dispatch_get_main_queue(),^{
            [self receivedNewMessages:lcckMessages];
        });
    });
}

- (void)messageUpdated:(NSNotification *)notification {
    NSDictionary *userInfo = notification.object;
    if (!userInfo) {
        return;
    }
    id<CYLConversationProtocol> conversation = userInfo[CYLMessageNotifacationUserInfoConversationKey];
    if (![self isCurrentConversationMessageForConversationId:conversation.conversationId]) {
        return;
    }
    id<CYLIMMessageProtocol> modifiedMessage = userInfo[CYLMessageNotifacationUserInfoMessageKey];
    if (![modifiedMessage conformsToProtocol:@protocol(CYLIMMessageProtocol)]) {
        return;
    }
    for (int i = 0; i < self.avimTypedMessage.count; i++) {
        id<CYLIMMessageProtocol> oldTypedMessage = self.avimTypedMessage[i];
        if ([modifiedMessage.messageId isEqualToString:oldTypedMessage.messageId]) {
            self.avimTypedMessage[i] = modifiedMessage;
            break;
        }
    }
    // Compare with the element count, not the array pointer.
    for (int i = 0; i < self.dataArray.count; i++) {
        CYLMessage *oldMessage = self.dataArray[i];
        if ([oldMessage isKindOfClass:[CYLMessage class]] && [modifiedMessage.messageId isEqualToString:oldMessage.serverMessageId]) {
            id lcckMessage = [self.IMProvider displayMessageFromIMMessage:modifiedMessage];
            if (lcckMessage) {
                self.dataArray[i] = lcckMessage;
                [self.parentConversationViewController.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            } else if (modifiedMessage.mediaType == CYLMessageMediaTypeRecalled) {
                [self.dataArray removeObjectAtIndex:i];
                [self.parentConversationViewController.tableView reloadData];
            }
            break;
        }
    }
}

- (void)messageStatusChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.object;
    if (!userInfo) {
        return;
    }
    id<CYLConversationProtocol> conversation = userInfo[CYLMessageNotifacationUserInfoConversationKey];
    BOOL isCurrentConversationMessage = [self isCurrentConversationMessageForConversationId:conversation.conversationId];
    if (!isCurrentConversationMessage) {
        return;
    }
    id<CYLIMMessageProtocol> message = userInfo[CYLMessageNotifacationUserInfoMessageKey];
//    int64_t readTimestamp = message.readTimestamp;
//    int64_t deliveredTimestamp = message.deliveredTimestamp;
//    BOOL isReadMessage = (readTimestamp > 0);
//    BOOL isDeliveredMessage = (deliveredTimestamp > 0);
    //TODO:
    
}

- (void)backgroundImageChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.object;
    if (!userInfo) {
        return;
    }
    NSString *userInfoConversationId = userInfo[CYLNotificationConversationViewControllerBackgroundImageDidChangedUserInfoConversationIdKey];
    BOOL isCurrentConversationMessage = [self isCurrentConversationMessageForConversationId:userInfoConversationId];
    if (!isCurrentConversationMessage) {
        return;
    }
    [self resetBackgroundImage];
}

- (void)setDefaultBackgroundImage {
    UIImage *image = [self imageInBundlePathForImageName:@"conversationViewController_default_backgroundImage"];
    [self.parentConversationViewController.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
}

- (void)resetBackgroundImage {
    NSString *conversationId = self.parentConversationViewController.conversationId;
    NSString *conversationViewControllerBackgroundImageKey = [NSString stringWithFormat:@"%@%@_%@", CYLCustomConversationViewControllerBackgroundImageNamePrefix, [CYLSessionService sharedInstance].clientId, conversationId];
    NSString *conversationViewControllerBackgroundImage = [[NSUserDefaults standardUserDefaults] objectForKey:conversationViewControllerBackgroundImageKey];
    if (conversationViewControllerBackgroundImage == nil) {
        conversationViewControllerBackgroundImage = [[NSUserDefaults standardUserDefaults] objectForKey:CYLDefaultConversationViewControllerBackgroundImageName];
        if (conversationViewControllerBackgroundImage == nil) {
            [self setDefaultBackgroundImage];
        } else {
            NSString *imagePath = [conversationViewControllerBackgroundImage cyl_pathForConversationBackgroundImage];
            UIImage *image = [UIImage imageNamed:imagePath];
            [self.parentConversationViewController.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
        }
    } else {
        NSString *imagePath = [conversationViewControllerBackgroundImage cyl_pathForConversationBackgroundImage];
        UIImage *image = [UIImage imageNamed:imagePath];
        [self.parentConversationViewController.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    }
}

- (void)receivedNewMessages:(NSArray *)messages {
    [self appendMessagesToTrailing:messages];
    if ([self.delegate respondsToSelector:@selector(reloadAfterReceiveMessage)]) {
        [self.delegate reloadAfterReceiveMessage];
    }
}

- (void)conversationInvalided:(NSNotification *)notification {
    NSString *clientId = notification.object;
    [[LCChatKit sharedInstance] deleteRecentConversationWithConversationId:self.currentConversationId];
    [[CYLUserSystemService sharedInstance] getProfilesInBackgroundForUserIds:@[ clientId ] callback:^(NSArray<id<CYLUserDelegate>> *users, NSError *error) {
        id<CYLUserDelegate> user;
        @try {
            user = users[0];
        } @catch (NSException *exception) {}
        
        NSInteger code = 4401;
        //错误码参考：https://leancloud.cn/docs/realtime_v2.html#%E4%BA%91%E7%AB%AF%E9%94%99%E8%AF%AF%E7%A0%81%E8%AF%B4%E6%98%8E
        NSString *errorReasonText = @"INVALID_MESSAGING_TARGET 您已被被管理员移除该群";
        NSDictionary *errorInfo = @{
                                    @"code":@(code),
                                    NSLocalizedDescriptionKey : errorReasonText,
                                    };
        NSError *error_ = [NSError errorWithDomain:NSStringFromClass([self class])
                                              code:code
                                          userInfo:errorInfo];
        
        CYLConversationInvalidedHandler conversationInvalidedHandler = [[CYLConversationService sharedInstance] conversationInvalidedHandler];
        if (conversationInvalidedHandler) {
            conversationInvalidedHandler(self.currentConversation.conversationId, self.parentConversationViewController, user, error_);
        }
    }];
}

- (void)appendMessagesToTrailing:(NSArray *)messages {
    id lastObject = (self.dataArray.count > 0) ? [self.dataArray lastObject] : nil;
    [self appendMessagesToDataArrayTrailing:[self messagesWithSystemMessages:messages lastMessage:lastObject]];
}

- (void)appendMessagesToDataArrayTrailing:(NSArray *)messages {
    if (messages.count > 0) {
        CYLLock();
        [self.dataArray addObjectsFromArray:messages];
        CYLUnlock();
    }
}

/*!
 * 与`-addMessages`方法的区别在于，第一次加载历史消息时需要查找最后一条消息之余还有没有消息。
 * 时间戳必须传0，后续方法会根据是否为了0，来判断是否是第一次进对话页面。
 */
- (void)addMessagesFirstTime:(NSArray *)messages {
    messages = [self messagesWithLocalMessages:messages freshTimestamp:0];
    if (messages.count > 0) {
        CYLLock();
        self.dataArray = messages.mutableCopy;
        CYLUnlock();
    }
}

- (void)refresh {
    [self loadMessagesFirstTimeWithCallback:^(BOOL succeeded, id object, NSError *error) {}];
}

/**
 *  lazy load allFailedMessages
 *
 *  @return NSArray
 */
- (NSArray *)allFailedMessages {
    if (_allFailedMessages == nil) {
        NSArray *allFailedMessages = [[CYLConversationService sharedInstance] failedMessagesByConversationId:self.currentConversationId];
        _allFailedMessages = allFailedMessages;
    }
    return _allFailedMessages;
}

/**
 *  lazy load allFailedMessageIds
 *
 *  @return NSArray
 */
- (NSArray *)allFailedMessageIds {
    if (_allFailedMessageIds == nil) {
        NSArray *allFailedMessageIds = [[CYLConversationService sharedInstance] failedMessageIdsByConversationId:self.parentConversationViewController.conversationId];
        _allFailedMessageIds = allFailedMessageIds;
    }
    return _allFailedMessageIds;
}

- (NSArray<CYLMessage *> *)failedMessagesWithPredicate:(NSPredicate *)predicate {
    NSArray *allFailedMessageIdsByConversationId = self.allFailedMessageIds;
    NSArray *failedMessageIds = [allFailedMessageIdsByConversationId filteredArrayUsingPredicate:predicate];
    NSArray<CYLMessage *> *failedCYLMessages;
    if (failedMessageIds.count > 0) {
        failedCYLMessages = [[CYLConversationService sharedInstance] failedMessagesByMessageIds:failedMessageIds];
    }
    return failedCYLMessages;
}

/*!
 * @param messages 从服务端刷新下来的，夹杂着本地失败消息（但还未插入原有的旧消息self.dataArray里)。
 * 该方法能让preload时动态判断插入时间戳，同时也用在第一次加载时插入时间戳。
 */
- (NSArray *)messagesWithSystemMessages:(NSArray *)messages lastMessage:(id)lastMessage {
    NSMutableArray *messageWithSystemMessages = lastMessage ? @[lastMessage].mutableCopy : @[].mutableCopy;
    for (id message in messages) {
        [messageWithSystemMessages addObject:message];
        [message cyl_shouldDisplayTimestampForMessages:messageWithSystemMessages callback:^(BOOL shouldDisplayTimestamp, NSTimeInterval messageTimestamp) {
            if (shouldDisplayTimestamp) {
                [messageWithSystemMessages insertObject:[CYLMessage systemMessageWithTimestamp:messageTimestamp] atIndex:(messageWithSystemMessages.count - 1)];
            }
        }];
    }
    if (lastMessage) {
        @try {
            [messageWithSystemMessages removeObjectAtIndex:0];
        } @catch (NSException *exception) {
            NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), exception.reason);
        }
    }
    return [messageWithSystemMessages copy];
}

/*!
 * 用于加载历史记录，首次进入加载以及下拉刷新加载。
 */
- (NSArray *)messagesWithSystemMessages:(NSArray *)messages {
    return [self messagesWithSystemMessages:messages lastMessage:nil];
}

- (NSArray *)oldestFailedMessagesBeforeMessage:(id)message {
    NSString *startDate = [NSString stringWithFormat:@"%@", @([message cyl_messageTimestamp])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF <= %@) AND (SELF MATCHES %@)", startDate, CYL_TIMESTAMP_REGEX];
    NSArray<CYLMessage *> *failedCYLMessages = [self failedMessagesWithPredicate:predicate];
    return failedCYLMessages;
}

/*!
 * freshTimestamp 下拉刷新的时间戳, 为0表示从当前时间开始查询。
 * //TODO:自定义消息暂时不支持失败缓存
 * @param messages 服务端返回到消息，如果一次拉去的是10条，那么这个数组将是10条，或少于10条。
 */
- (NSArray *)messagesWithLocalMessages:(NSArray *)messages freshTimestamp:(int64_t)timestamp {
    NSMutableArray *messagesWithLocalMessages = [NSMutableArray arrayWithCapacity:messages.count];
    BOOL shouldLoadMoreMessagesScrollToTop = self.parentConversationViewController.shouldLoadMoreMessagesScrollToTop;
    //情况一：当前对话，没有历史消息，只有失败消息的情况，直接返回数据库所有失败消息
    if (!shouldLoadMoreMessagesScrollToTop && messages.count == 0 && (timestamp == 0)) {
        NSArray *failedMessagesByConversationId = self.allFailedMessages;
        messagesWithLocalMessages = [NSMutableArray arrayWithArray:failedMessagesByConversationId];
        return [self messagesWithSystemMessages:messagesWithLocalMessages];
    }
    //情况二：正常情况，服务端有消息返回
    
    //服务端的历史纪录已经加载完成，将比服务端最旧的一条消息还旧的失败消息拼接到顶端。
    if (!shouldLoadMoreMessagesScrollToTop && messages.count > 0) {
        id message = messages[0];
        NSArray *oldestFailedMessagesBeforeMessage = [self oldestFailedMessagesBeforeMessage:message];
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:oldestFailedMessagesBeforeMessage];
        [mutableArray addObjectsFromArray:[messagesWithLocalMessages copy]];
        messagesWithLocalMessages = [mutableArray mutableCopy];
    }
    
    /*!
     *
     messages追加失败消息时，涉及到的概念对应关系：
     
     index        |  参数        |     参数       |     屏幕位置
    --------------|-------------|----------------|-------------
     0            |             |                |      顶部
     1            |   fromDate  |  formerMessage |      上
     2            |     --      |  failedMessage |      中
     3            |    toDate   |     message    |      下
     ...          |             |                |
     n(last)      |   fromDate  |   lastMessage  |     队尾，最后一条消息
      -           |     --      |  failedMessage |
fromTimestamp     |    toDate   |                |  上次上拉刷新顶端，第一条消息
     
     */
    __block int64_t fromDate;
    __block int64_t toDate;
    //messages追加失败消息，第一步：
    //对应于上图中index里的0到3
    [messages enumerateObjectsUsingBlock:^(id _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            [messagesWithLocalMessages addObject:message];
            return;
        }
        id formerMessage = [messages objectAtIndex:idx - 1];
        fromDate = [formerMessage cyl_messageTimestamp];
        toDate = [message cyl_messageTimestamp];
        [self appendFailedMessagesToMessagesWithLocalMessages:messagesWithLocalMessages fromDate:fromDate toDate:toDate];
        [messagesWithLocalMessages addObject:message];
    }];
    //messages追加失败消息，第二步：
    //对应于上图中index里的n(last)到fromTimestamp
    //总是追加最后一条消息到上次下拉刷新之间的失败消息，如果历史记录里只有一条消息，也依然。
    id lastMessage = [messages lastObject];
    if (lastMessage) {
        fromDate = [lastMessage cyl_messageTimestamp];
        toDate = timestamp;
        if (timestamp == 0) {
            toDate = CYL_FUTURE_TIMESTAMP;
        }
        [self appendFailedMessagesToMessagesWithLocalMessages:messagesWithLocalMessages fromDate:fromDate toDate:toDate];
    }
    return [self messagesWithSystemMessages:messagesWithLocalMessages];
}

- (void)appendFailedMessagesToMessagesWithLocalMessages:(NSMutableArray *)messagesWithLocalMessages fromDate:(int64_t)fromDate toDate:(int64_t)toDate {
    NSArray<CYLMessage *> *failedCYLMessages = [self failedCYLMessagesWithFromDate:fromDate toDate:toDate];
    if (failedCYLMessages.count > 0) {
        [messagesWithLocalMessages addObjectsFromArray:failedCYLMessages];
    }
}

- (NSArray *)failedCYLMessagesWithFromDate:(int64_t)fromDate toDate:(int64_t)toDate {
    NSString *fromDateString = [NSString stringWithFormat:@"%@", @(fromDate)];
    NSString *toDateString = [NSString stringWithFormat:@"%@", @(toDate)];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF >= %@) AND (SELF <= %@) AND (SELF MATCHES %@)", fromDateString, toDateString , CYL_TIMESTAMP_REGEX];
    NSArray<CYLMessage *> *failedCYLMessages = [self failedMessagesWithPredicate:predicate];
    return failedCYLMessages;
}

#pragma mark - Public Methods

- (void)sendCustomMessage:(id<CYLIMMessageProtocol>)customMessage {
    [self sendMessage:customMessage];
}

- (void)sendMessage:(id)message {
        [self sendMessage:message mentionList:@[]];
    }

- (void)sendMessage:(id)message mentionList:(NSArray<NSString *> *)mentionList {
    __weak __typeof(&*self) wself = self;
    [self sendMessage:message
          mentionList:mentionList
        progressBlock:^(NSInteger percentDone) {
            [self.delegate messageSendStateChanged:CYLMessageSendStateSending withProgress:percentDone/100.f forIndex:[self.dataArray indexOfObject:message]];
        }
              success:^(BOOL succeeded, NSError *error) {
                  if (![message cyl_isCustomMessage]) {
                      [(CYLMessage *)message setSendStatus:CYLMessageSendStateSent];
                  }
                  
                  [[CYLSoundManager defaultManager] playSendSoundIfNeed];
                  [self.delegate messageSendStateChanged:CYLMessageSendStateSent withProgress:1.0f forIndex:[self.dataArray indexOfObject:message]];
              } failed:^(BOOL succeeded, NSError *error) {
                  __strong __typeof(wself)self = wself;
                  if (![message cyl_isCustomMessage]) {
                      [(CYLMessage *)message setSendStatus:CYLMessageSendStateFailed];
                      if (self.currentConversationId.length > 0) {
                          [[CYLConversationService sharedInstance] insertFailedCYLMessage:message];
                      }
                  } else {
                      //TODO:自定义消息的失败缓存
                  }
                  [self.delegate messageSendStateChanged:CYLMessageSendStateFailed withProgress:0.0f forIndex:[self.dataArray indexOfObject:message]];
              }];
}

- (void)sendCustomMessage:(id<CYLIMMessageProtocol>)aMessage
            progressBlock:(CYLProgressBlock)progressBlock
                  success:(CYLBooleanResultBlock)success
                   failed:(CYLBooleanResultBlock)failed {
    [self sendMessage:aMessage mentionList:@[] progressBlock:progressBlock success:success failed:failed];
}

- (void)sendMessage:(id)aMessage
        mentionList:(NSArray<NSString *> *)mentionList
      progressBlock:(CYLProgressBlock)progressBlock
            success:(CYLBooleanResultBlock)success
             failed:(CYLBooleanResultBlock)failed {
    //[[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationMessageSent object:nil];
    if (!aMessage) {
        NSInteger code = 0;
        NSString *errorReasonText = @"message is nil";
        NSDictionary *errorInfo = @{
                                    @"code":@(code),
                                    NSLocalizedDescriptionKey : errorReasonText,
                                    };
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:code
                                         userInfo:errorInfo];
        
        !failed ?: failed(YES, error);
        return;
    }
    self.parentConversationViewController.allowScrollToBottom = YES;
    NSString *messageUUID =  [NSString stringWithFormat:@"%@", @(CYL_CURRENT_TIMESTAMP)];
//    if (![aMessage cyl_isCustomMessage]) {
    if (![aMessage cyl_isCustomMessage] && [aMessage respondsToSelector:@selector(setLocalMessageId:)]) {
        [(CYLMessage *)aMessage setLocalMessageId:messageUUID];
    } else {
        //TODO:
        //自定义消息的失败id
    }
    [self.delegate messageSendStateChanged:CYLMessageSendStateSending withProgress:0.0f forIndex:[self.dataArray indexOfObject:aMessage]];
    NSError *messageNULLError = nil;
    
    
    id avimTypedMessage = [self avimTypedMessageFromCYLMessage:aMessage theError:&messageNULLError];
    
    
    void(^sendMessageCallBack)(CYLBooleanResultBlock theSuccess,
                               CYLBooleanResultBlock theFailed) = ^(CYLBooleanResultBlock theSuccess,
                                                                     CYLBooleanResultBlock theFailed) {
        // `mentionList` was never sent before ChatKit was decoupled from LeanCloud; nil keeps that behavior.
        [[CYLConversationService sharedInstance] sendMessage:avimTypedMessage
                                                 conversation:self.currentConversation
                                                  mentionList:nil
                                                progressBlock:progressBlock
                                                     callback:^(BOOL succeeded, NSError *error) {
                                                         if (error) {
                                                             !failed ?: failed(succeeded, error);
                                                             !theFailed ?: theFailed(succeeded, error);
                                                         } else {
                                                             !success ?: success(succeeded, nil);
                                                             !theSuccess ?: theSuccess(succeeded, nil);

                                                         }
                                                     }];
    };
    
    void(^CYLBlockSendCallback)(CYLBooleanResultBlock theSuccess,
                                 CYLBooleanResultBlock theFailed) = ^(CYLBooleanResultBlock theSuccess,
                                                                       CYLBooleanResultBlock theFailed) {
        CYLSendMessageHookBlock sendMessageHookBlock = [[CYLConversationService sharedInstance] sendMessageHookBlock];
        if (!sendMessageHookBlock) {
            sendMessageCallBack(theSuccess, theFailed);
        } else {
            CYLSendMessageHookCompletionHandler completionHandler = ^(BOOL granted, NSError *aError) {
                if (granted) {
                    sendMessageCallBack(theSuccess, theFailed);
                } else {
                    !failed ?: failed(YES, aError);
                }
            };
            sendMessageHookBlock(self.parentConversationViewController, avimTypedMessage, completionHandler);
        }
    };
    
    if (![avimTypedMessage cyl_isCustomMessage]) {
        
        
//       void(^CYLBooleanResultBlock)() = ^(void) {
            if ([avimTypedMessage conformsToProtocol:@protocol(CYLIMMessageProtocol)]) {
                //    if ([avimTypedMessage cyl_isCustomMessage]) {
                [self setAttribute:@([self.parentConversationViewController getConversationIfExists].cyl_type) forKey:CYLCustomMessageConversationTypeKey toIMMessage:avimTypedMessage];
                [avimTypedMessage setCyl_senderId:[CYLSessionService sharedInstance].clientId];//for CYLSendMessageHookBlock
                [self.avimTypedMessage addObject:avimTypedMessage];
            }
//        };
        [self preloadMessageToTableView:aMessage callback:^{
            if (!self.currentConversationId || self.currentConversationId.length == 0) {
                NSInteger code = 0;
                NSString *errorReasonText = @"Conversation invalid";
                NSDictionary *errorInfo = @{
                                            @"code":@(code),
                                            NSLocalizedDescriptionKey : errorReasonText,
                                            };
                NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                                     code:code
                                                 userInfo:errorInfo];
                !failed ?: failed(YES, error);
                return;
            }
            CYLBlockSendCallback(nil, nil);
        }];
    } else {
        void(^CYLBooleanResultBlock)(BOOL succeeded, NSError *error) = ^(BOOL succeeded, NSError *error) {
            if ([aMessage conformsToProtocol:@protocol(CYLIMMessageProtocol)]) {
                [self setAttribute:@([self.parentConversationViewController getConversationIfExists].cyl_type) forKey:CYLCustomMessageConversationTypeKey toIMMessage:aMessage];
                [aMessage setCyl_senderId:[CYLSessionService sharedInstance].clientId];//for CYLSendMessageHookBlock
                [self appendMessagesToDataArrayTrailing:@[aMessage]];
                if ([self.delegate respondsToSelector:@selector(reloadAfterReceiveMessage)]) {
                    [self.delegate reloadAfterReceiveMessage];
                }
            }
        };
        CYLBlockSendCallback(CYLBooleanResultBlock, nil);
    }
}

- (id<CYLIMProvider>)IMProvider {
    return [LCChatKit sharedInstance].IMProvider;
}

/*!
 * Merges one custom attribute into an IM SDK message, keeping its existing attributes.
 */
- (void)setAttribute:(id)object forKey:(NSString *)key toIMMessage:(id<CYLIMMessageProtocol>)message {
    if (!object || !key) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:object forKey:key];
    if (message.attributes) {
        [attributes addEntriesFromDictionary:message.attributes];
    }
    message.attributes = attributes;
}

- (id<CYLIMMessageProtocol>)avimTypedMessageFromCYLMessage:(CYLMessage *)aMessage
                                                    theError:(NSError **)theError {
    id<CYLIMMessageProtocol> avimTypedMessage;
    if ([aMessage isKindOfClass:[CYLMessage class]]) {
//    if (![aMessage cyl_isCustomMessage]) {
        CYLMessage *message = (CYLMessage *)aMessage;
        message.conversationId = self.currentConversationId;
        if ([message respondsToSelector:@selector(setSendStatus:)]) {
            message.sendStatus = CYLMessageSendStateSending;
        }
        id<CYLUserDelegate> sender = [[CYLUserSystemService sharedInstance] fetchCurrentUser];
        message.sender = sender;
        message.ownerType = CYLMessageOwnerTypeSelf;
        message.message = avimTypedMessage;
        avimTypedMessage = [self.IMProvider IMMessageFromMessage:message];
    } else if ([aMessage conformsToProtocol:@protocol(CYLIMMessageProtocol)]){
        avimTypedMessage = (id<CYLIMMessageProtocol>)aMessage;
    }
    if (!avimTypedMessage) {
        NSInteger code = 0;
        NSString *errorReasonText = @"message is nil";
        NSDictionary *errorInfo = @{
                                    @"code":@(code),
                                    NSLocalizedDescriptionKey : errorReasonText,
                                    };
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:code
                                         userInfo:errorInfo];
        if (theError != NULL) {
            *theError = error;
        }
        return nil;
    }
    return avimTypedMessage;
}

- (void)sendLocalFeedbackTextMessge:(NSString *)localFeedbackTextMessge {
    CYLMessage *localFeedbackMessge = [CYLMessage localFeedbackText:localFeedbackTextMessge];
    [self appendMessagesToDataArrayTrailing:@[localFeedbackMessge]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0];
    dispatch_async(dispatch_get_main_queue(),^{
        [self.parentConversationViewController.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.parentConversationViewController scrollToBottomAnimated:YES];
    });
}

- (void)resendMessageForMessageCell:(CYLChatMessageCell *)messageCell {
    NSString *title = [NSString stringWithFormat:@"%@?", CYLLocalizedStrings(@"resend")];
    CYLAlertController *alert = [CYLAlertController alertControllerWithTitle:title
                                                                       message:@""
                                                                preferredStyle:CYLAlertControllerStyleAlert];
    NSString *cancelActionTitle = CYLLocalizedStrings(@"cancel");
    CYLAlertAction *cancelAction = [CYLAlertAction actionWithTitle:cancelActionTitle style:CYLAlertActionStyleDefault
                                                             handler:^(CYLAlertAction * action) {}];
    [alert addAction:cancelAction];
    NSString *resendActionTitle = CYLLocalizedStrings(@"resend");
    CYLAlertAction *resendAction = [CYLAlertAction actionWithTitle:resendActionTitle style:CYLAlertActionStyleDefault
                                                             handler:^(CYLAlertAction * action) {
                                                                 [self resendMessageAtIndexPath:messageCell.indexPath];
                                                             }];
    [alert addAction:resendAction];
    [alert showWithSender:nil controller:self.parentConversationViewController animated:YES completion:NULL];
}

- (void)modifyMessageForMessageCell:(CYLChatMessageCell *)messageCell newMessage:(CYLMessage *)newMessage callback:(void (^)(BOOL, NSError *))callback {
    NSIndexPath *indexPath = messageCell.indexPath;
    CYLMessage *oldMessage = self.dataArray[indexPath.row];
    int oldTypedMessageIndex = -1;
    id<CYLIMMessageProtocol> oldTypedMessage = nil;
    for (int i = 0; i < self.avimTypedMessage.count; i++) {
        id<CYLIMMessageProtocol> item = self.avimTypedMessage[i];
        if ([oldMessage.serverMessageId isEqualToString:item.messageId]) {
            oldTypedMessageIndex = i;
            oldTypedMessage = item;
            break;
        }
    }
    if (oldTypedMessage && oldTypedMessageIndex >= 0 && oldTypedMessageIndex < self.avimTypedMessage.count) {
        [self.IMProvider updateMessage:oldTypedMessage
                              withText:newMessage.text
                          conversation:CYLConversationService.sharedInstance.currentConversation
                              callback:^(BOOL succeeded, NSError * _Nullable error, id<CYLIMMessageProtocol> _Nullable newTypedMessage) {
            if (succeeded && newTypedMessage) {
                id lcckMessage = [self.IMProvider displayMessageFromIMMessage:newTypedMessage];
                if (lcckMessage) {
                    self.dataArray[indexPath.row] = lcckMessage;
                    [self.parentConversationViewController.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            callback(succeeded, error);
        }];
    }
}

- (void)recallMessageForMessageCell:(CYLChatMessageCell *)messageCell
                           callback:(void (^)(BOOL, NSError *))callback {
    NSIndexPath *indexPath = messageCell.indexPath;
    CYLMessage *oldMessage = self.dataArray[indexPath.row];
    int oldTypedMessageIndex = -1;
    id<CYLIMMessageProtocol> oldTypedMessage = nil;
    for (int i = 0; i < self.avimTypedMessage.count; i++) {
        id<CYLIMMessageProtocol> item = self.avimTypedMessage[i];
        if ([oldMessage.serverMessageId isEqualToString:item.messageId]) {
            oldTypedMessageIndex = i;
            oldTypedMessage = item;
            break;
        }
    }
    if (oldTypedMessage && oldTypedMessageIndex >= 0 && oldTypedMessageIndex < self.avimTypedMessage.count) {
        [self.IMProvider recallMessage:oldTypedMessage
                          conversation:CYLConversationService.sharedInstance.currentConversation
                              callback:^(BOOL succeeded, NSError * _Nullable error, id<CYLIMMessageProtocol> _Nullable recalledMessage) {
            if (succeeded) {
                [self.dataArray removeObjectAtIndex:indexPath.row];
                if (recalledMessage) {
                    self.avimTypedMessage[oldTypedMessageIndex] = recalledMessage;
                }
                [self.parentConversationViewController.tableView reloadData];
            }
            callback(succeeded, error);
        }];
    }
}

/*!
 * 自定义消息暂不支持失败缓存，不支持重发
 */
- (void)resendMessageAtIndexPath:(NSIndexPath *)indexPath {
    CYLMessage *lcckMessage = self.dataArray[indexPath.row];
    NSUInteger row = indexPath.row;
    CYLMessage *message;
    @try {
        message = self.dataArray[row - 1];
    } @catch (NSException *exception) {}
    @try {
        if (message.mediaType == CYLMessageMediaTypeSystem && !message.isLocalMessage) {
            [self.dataArray cyl_removeMessageAtIndex:row - 1];
            [self.avimTypedMessage cyl_removeMessageAtIndex:row - 1];
            row -= 1;
        }
    } @catch (NSException *exception) {}
    [self.dataArray cyl_removeMessageAtIndex:row];
    [self.avimTypedMessage cyl_removeMessageAtIndex:row];
    NSString *oldFailedMessageId = lcckMessage.localMessageId;
    [self.parentConversationViewController.tableView reloadData];
    self.parentConversationViewController.allowScrollToBottom = YES;
    [self sendMessage:lcckMessage];
    [[CYLConversationService sharedInstance] deleteFailedMessageByRecordId:oldFailedMessageId];
}

- (void)preloadMessageToTableView:(id)aMessage callback:(CYLVoidBlock)callback {
    if (![aMessage conformsToProtocol:@protocol(CYLIMMessageProtocol)]) {
        CYLMessage *message = (CYLMessage *)aMessage;
        message.sendStatus = CYLMessageSendStateSending;
    }
    NSUInteger oldLastMessageCount = self.dataArray.count;
    [self appendMessagesToTrailing:@[aMessage]];
    NSUInteger newLastMessageCout = self.dataArray.count;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0];
    [self.delegate messageSendStateChanged:CYLMessageSendStateSending withProgress:0.0f forIndex:indexPath.row];
    CYLLock();
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
    NSUInteger additionItemsCount = newLastMessageCout - oldLastMessageCount;
    if (additionItemsCount > 1) {
        for (NSUInteger index = 2; index <= additionItemsCount; index++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(newLastMessageCout - index) inSection:0];
            [indexPaths addObject:indexPath];
        }
    }
    dispatch_async(dispatch_get_main_queue(),^{
        [self.parentConversationViewController.tableView insertRowsAtIndexPaths:[indexPaths copy] withRowAnimation:UITableViewRowAnimationNone];
        CYLUnlock();
        [self.parentConversationViewController scrollToBottomAnimated:YES];
        !callback ?: callback();
    });
}

#pragma mark - Getters

- (BOOL)isCurrentConversationMessageForConversationId:(NSString *)conversationId {
    BOOL isCurrentConversationMessage = [conversationId isEqualToString:self.parentConversationViewController.conversationId];
    if (isCurrentConversationMessage) {
        return YES;
    }
    return NO;
}

- (NSUInteger)messageCount {
    return self.dataArray.count;
}

- (id<CYLConversationProtocol>)currentConversation {
    return [self.parentConversationViewController getConversationIfExists];
}

- (NSString *)currentConversationId {
    return self.currentConversation.conversationId;
}

- (void)loadMessagesFirstTimeWithCallback:(CYLIdBoolResultBlock)callback {
    [self queryAndCacheMessagesWithTimestamp:0
                                   messageId:nil
                                       block:^(NSArray *avimTypedMessages, NSError *error)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
             BOOL succeed = [self.parentConversationViewController filterAVIMError:error];
             if (succeed) {
                 if ([CYLConversationService.sharedInstance.currentConversationId isEqualToString:self.currentConversationId] && [CYLConversationService.sharedInstance isChatting]) {
                     [self.IMProvider markConversationAsRead:[self currentConversation]];
                 }
                 NSMutableArray *lcckSucceedMessags = [NSMutableArray cyl_messagesWithAVIMMessages:avimTypedMessages];
                 [self addMessagesFirstTime:lcckSucceedMessags];
                 NSMutableArray *allMessages = [NSMutableArray arrayWithArray:avimTypedMessages];
                 self.avimTypedMessage = allMessages;
                 dispatch_async(dispatch_get_main_queue(),^{
                     [self.parentConversationViewController.tableView reloadData];
                     [self.parentConversationViewController scrollToBottomAnimated:NO];
                     self.parentConversationViewController.loadingMoreMessage = NO;
                 });
                 if (self.avimTypedMessage.count > 0) {
                     [[CYLConversationService sharedInstance] updateConversationAsReadWithLastMessage:avimTypedMessages.lastObject];
                 }
             } else {
                 self.parentConversationViewController.loadingMoreMessage = NO;
             }
             !callback ?: callback(succeed, self.avimTypedMessage, error);
         });
     }];
}

- (void)queryAndCacheMessagesWithTimestamp:(int64_t)timestamp
                                 messageId:(NSString *)messageId
                                     block:(CYLArrayResultBlock)block
{
    if (self.parentConversationViewController.loadingMoreMessage) {
        return;
    }
    if (self.dataArray.count == 0) {
        timestamp = 0;
    }
    self.parentConversationViewController.loadingMoreMessage = YES;
    [[CYLConversationService sharedInstance] queryTypedMessagesWithConversation:self.currentConversation
                                                                       messageId:messageId
                                                                       timestamp:timestamp
                                                                           limit:kCYLOnePageSize
                                                                           block:^(NSArray *avimTypedMessages, NSError *error)
     {
         self.parentConversationViewController.shouldLoadMoreMessagesScrollToTop = YES;
         if (avimTypedMessages.count == 0) {
             self.parentConversationViewController.loadingMoreMessage = NO;
             self.parentConversationViewController.shouldLoadMoreMessagesScrollToTop = NO;
             !block ?: block(avimTypedMessages, error);
             return;
         }
         dispatch_async(dispatch_get_main_queue(),^{
             if (avimTypedMessages.count < kCYLOnePageSize) {
                 self.parentConversationViewController.shouldLoadMoreMessagesScrollToTop = NO;
             }
             !block ?: block(avimTypedMessages, error);
         });
     }];
}

- (void)loadOldMessages {
    id<CYLIMMessageProtocol> msg = [self.avimTypedMessage cyl_messageAtIndex:0];
    int64_t timestamp = [msg cyl_sendTimestamp];
    [self queryAndCacheMessagesWithTimestamp:timestamp
                                   messageId:msg.messageId
                                       block:^(NSArray *avimTypedMessages, NSError *error)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
             if ([self.parentConversationViewController filterAVIMError:error]) {
                 NSMutableArray *lcckMessages = [[NSMutableArray cyl_messagesWithAVIMMessages:avimTypedMessages] mutableCopy];
                 NSMutableArray *newMessages = [NSMutableArray arrayWithArray:avimTypedMessages];
                 [newMessages addObjectsFromArray:self.avimTypedMessage];
                 self.avimTypedMessage = newMessages;
                 [self insertOldMessages:[self messagesWithLocalMessages:lcckMessages freshTimestamp:timestamp] completion: ^{
                     self.parentConversationViewController.loadingMoreMessage = NO;
                 }];
             } else {
                 dispatch_async(dispatch_get_main_queue(),^{
                     self.parentConversationViewController.loadingMoreMessage = NO;
                 });
             }
         });
     }];
}

- (void)insertOldMessages:(NSArray *)oldMessages completion:(void (^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSMutableArray *messages = [NSMutableArray arrayWithArray:oldMessages];
        [messages addObjectsFromArray:self.dataArray];
        __block CGSize beforeContentSize;
        dispatch_async(dispatch_get_main_queue(),^{
            beforeContentSize = self.parentConversationViewController.tableView.contentSize;
        });
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:oldMessages.count];
        [oldMessages enumerateObjectsUsingBlock:^(id message, NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [indexPaths addObject:indexPath];
        }];
        dispatch_async(dispatch_get_main_queue(),^{
            BOOL animationEnabled = [UIView areAnimationsEnabled];
            if (animationEnabled) {
                [UIView setAnimationsEnabled:NO];
                [self.parentConversationViewController.tableView beginUpdates];
                self.dataArray = [messages mutableCopy];
                [self.parentConversationViewController.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                [self.parentConversationViewController.tableView reloadData];
                [self.parentConversationViewController.tableView endUpdates];
                CGSize afterContentSize = self.parentConversationViewController.tableView.contentSize;
                CGPoint afterContentOffset = self.parentConversationViewController.tableView.contentOffset;
                CGPoint newContentOffset = CGPointMake(afterContentOffset.x, afterContentOffset.y + afterContentSize.height - beforeContentSize.height);
                [self.parentConversationViewController.tableView setContentOffset:newContentOffset animated:NO] ;
                [UIView setAnimationsEnabled:YES];
            }
            !completion ?: completion();
        });
    });
}

- (void)getAllVisibleImagesForSelectedMessage:(CYLMessage *)message
                             allVisibleImages:(NSArray **)allVisibleImages
                             allVisibleThumbs:(NSArray **)allVisibleThumbs
                         selectedMessageIndex:(NSNumber **)selectedMessageIndex {
    NSMutableArray *allVisibleImages_ = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *allVisibleThumbs_ = [[NSMutableArray alloc] initWithCapacity:0];
    NSUInteger idx = 0;
    for (NSObject<CYLMessageDelegate> *message_ in self.dataArray) {
        if ([message_ cyl_isCustomMessage]) {
////            AVIMTypedMessage *typedMessage = (AVIMTypedMessage *)message_;
//            NSString *imageLocalPath = message_.photoPath;
//            BOOL isImageLocal;
//            if ( (imageLocalPath.length >0 ) && ([NSData dataWithContentsOfFile:imageLocalPath])) {
//                isImageLocal = YES;
//            }
//
//            BOOL isRemoteImage = message_.originPhotoURL.absoluteString.length > 0;
//            if (!isImageLocal && !isRemoteImage && !message_.photo) {
//                continue;
//            }
            BOOL isImage;
            @try {
                isImage = (message_.photo || message_.photoPath.length > 0);
            } @catch (NSException *){}
            if (!isImage) {
                continue;
            }
        }
        
        BOOL isImageType;
        @try {
          isImageType = (message_.mediaType == CYLMessageMediaTypeImage || message_.photo || message_.originPhotoURL);
        } @catch (NSException *exception) {}
        if (isImageType) {
            UIImage *placeholderImage = ({
                NSString *imageName = @"Placeholder_Accept_Defeat";
                UIImage *image = [UIImage cyl_imageNamed:imageName bundleName:@"Placeholder" bundleForClass:[self class]];
                image;});
            //大图设置
            UIImage *image = message_.photo;
            if (image) {
                [allVisibleImages_ addObject:image];
            } else if (message_.originPhotoURL) {
                [allVisibleImages_ addObject:message_.originPhotoURL];
            } else {
                [allVisibleImages_ addObject:placeholderImage];
            }
            //缩略图设置
            UIImage *thumb = message_.thumbnailPhoto;
            if (thumb) {
                [allVisibleThumbs_ addObject:thumb];
            } else if ([message_  respondsToSelector:@selector(thumbnailURL)] && [message_  performSelector:@selector(thumbnailURL)]) {
                [allVisibleThumbs_ addObject:message_.thumbnailURL];
            } else {
                [allVisibleThumbs_ addObject:placeholderImage];
            }
            if ((message == message_) && (*selectedMessageIndex == nil)){
                *selectedMessageIndex = @(idx);
            }
            idx++;
        }
    }
    if (allVisibleImages) {
        *allVisibleImages = [allVisibleImages_ copy];
    }
    if (allVisibleThumbs) {
        *allVisibleThumbs = [allVisibleThumbs_ copy];
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.parentConversationViewController.isUserScrolling = YES;
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
    [self.parentConversationViewController.chatBar endInputing];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.parentConversationViewController.isUserScrolling = NO;
    BOOL allowScrollToBottom = self.parentConversationViewController.allowScrollToBottom;
    CGFloat frameBottomToContentBottom = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
    //200：差不多是两行
    if (frameBottomToContentBottom < 200) {
        allowScrollToBottom = YES;
    } else {
        allowScrollToBottom = NO;
    }
    self.parentConversationViewController.allowScrollToBottom = allowScrollToBottom;
}

- (UIImage *)imageInBundlePathForImageName:(NSString *)imageName {
    UIImage *image = [UIImage cyl_imageNamed:imageName bundleName:@"Other" bundleForClass:[self class]];
    return image;
}

@end
