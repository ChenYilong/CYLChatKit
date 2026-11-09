 //
//  LCCKConversationViewModel.m
//  LCCKChatExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/18.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

#import "LCCKConversationViewModel.h"

#import "LCCKChatTextMessageCell.h"
#import "LCCKChatImageMessageCell.h"
#import "LCCKChatVoiceMessageCell.h"
#import "LCCKChatSystemMessageCell.h"
#import "LCCKChatLocationMessageCell.h"

#import "LCCKAVAudioPlayer.h"
#import "LCCKConstants.h"
#import "LCCKConversationService.h"
#import "LCCKSoundManager.h"

#import "UITableView+FDTemplateLayoutCell.h"
#import "LCCKCellIdentifierFactory.h"

#import "LCCKMessage.h"
#import "LCCKConversationViewController.h"
#import "LCCKUserSystemService.h"
#import "LCCKSessionService.h"
#import "UIImage+LCCKExtension.h"
#import "NSMutableArray+LCCKMessageExtention.h"
#import "LCCKAlertController.h"
#import "NSObject+LCCKExtension.h"

#if __has_include(<CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>)
#import <CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>
#else
#import "CYLDeallocBlockExecutor.h"
#endif

#define LCCKLock() dispatch_semaphore_wait(self->_lcck_lock, DISPATCH_TIME_FOREVER)
#define LCCKUnlock() dispatch_semaphore_signal(self->_lcck_lock)

@interface LCCKConversationViewModel () {
    dispatch_semaphore_t _lcck_lock;
}

@property (nonatomic, weak) LCCKConversationViewController *parentConversationViewController;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray<id<LCCKIMMessageProtocol>> *avimTypedMessage;

/*!
 * 懒加载，只在下拉刷新和第一次进入时，做消息流插入，所以在conversationViewController的生命周期里，只load一次就可以。
 */
@property (nonatomic, copy) NSArray *allFailedMessageIds;
@property (nonatomic, strong) NSArray *allFailedMessages;

@end

@implementation LCCKConversationViewModel

- (instancetype)initWithParentViewController:(LCCKConversationViewController *)parentConversationViewController {
    if (self = [super init]) {
        _lcck_lock = dispatch_semaphore_create(1);
        _dataArray = [NSMutableArray array];
        _avimTypedMessage = [NSMutableArray array];
        self.parentConversationViewController = parentConversationViewController;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:LCCKNotificationMessageReceived object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationInvalided:) name:LCCKNotificationCurrentConversationInvalided object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageStatusChanged:) name:LCCKNotificationMessageRead object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageStatusChanged:) name:LCCKNotificationMessageDelivered object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundImageChanged:) name:LCCKNotificationConversationViewControllerBackgroundImageDidChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileMessageDidDownload:) name:LCCKNotificationConversionImageMessageDidDownloaded object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(refresh) name:LCCKNotificationSessionResumed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageUpdated:) name:LCCKNotificationMessageUpdated object:nil];
        [self cyl_willDeallocWithSelfCallback:^(__unsafe_unretained id owner, NSUInteger identifier) {
            [[NSNotificationCenter defaultCenter] removeObserver:owner];
        }];
    }
    return self;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (void)fileMessageDidDownload:(NSNotification *)notification {
    LCCKChatImageMessageCell *cell = notification.object;
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
    NSString *identifier = [LCCKCellIdentifierFactory cellIdentifierForMessageConfiguration:message conversationType:[self.parentConversationViewController getConversationIfExists].lcck_type];
    LCCKChatMessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
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
    NSString *identifier = [LCCKCellIdentifierFactory cellIdentifierForMessageConfiguration:message conversationType:[self.parentConversationViewController getConversationIfExists].lcck_type];
    NSString *cacheKey = [LCCKCellIdentifierFactory cacheKeyForMessage:message];
    return [tableView fd_heightForCellWithIdentifier:identifier cacheByKey:cacheKey configuration:^(LCCKChatMessageCell *cell) {
        [cell configureCellWithData:message];
    }];
}

#pragma mark - LCCKChatServerDelegate

- (void)receiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = notification.object;
    if (!userInfo) {
        return;
    }
    NSArray<id<LCCKIMMessageProtocol>> *messages = userInfo[LCCKDidReceiveMessagesUserInfoMessagesKey];
    id<LCCKConversationProtocol> conversation = userInfo[LCCKMessageNotifacationUserInfoConversationKey];
    BOOL isCurrentConversationMessage = [self isCurrentConversationMessageForConversationId:conversation.conversationId];
    if (!isCurrentConversationMessage) {
        return;
    }
    id<LCCKConversationProtocol> currentConversation = [self.parentConversationViewController getConversationIfExists];
    if (currentConversation.muted == NO) {
        [[LCCKSoundManager defaultManager] playReceiveSoundIfNeed];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSArray *lcckMessages = [NSMutableArray lcck_messagesWithAVIMMessages:messages];
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
    id<LCCKConversationProtocol> conversation = userInfo[LCCKMessageNotifacationUserInfoConversationKey];
    if (![self isCurrentConversationMessageForConversationId:conversation.conversationId]) {
        return;
    }
    id<LCCKIMMessageProtocol> modifiedMessage = userInfo[LCCKMessageNotifacationUserInfoMessageKey];
    if (![modifiedMessage conformsToProtocol:@protocol(LCCKIMMessageProtocol)]) {
        return;
    }
    for (int i = 0; i < self.avimTypedMessage.count; i++) {
        id<LCCKIMMessageProtocol> oldTypedMessage = self.avimTypedMessage[i];
        if ([modifiedMessage.messageId isEqualToString:oldTypedMessage.messageId]) {
            self.avimTypedMessage[i] = modifiedMessage;
            break;
        }
    }
    // Compare with the element count, not the array pointer.
    for (int i = 0; i < self.dataArray.count; i++) {
        LCCKMessage *oldMessage = self.dataArray[i];
        if ([oldMessage isKindOfClass:[LCCKMessage class]] && [modifiedMessage.messageId isEqualToString:oldMessage.serverMessageId]) {
            id lcckMessage = [self.IMProvider displayMessageFromIMMessage:modifiedMessage];
            if (lcckMessage) {
                self.dataArray[i] = lcckMessage;
                [self.parentConversationViewController.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            } else if (modifiedMessage.mediaType == LCCKMessageMediaTypeRecalled) {
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
    id<LCCKConversationProtocol> conversation = userInfo[LCCKMessageNotifacationUserInfoConversationKey];
    BOOL isCurrentConversationMessage = [self isCurrentConversationMessageForConversationId:conversation.conversationId];
    if (!isCurrentConversationMessage) {
        return;
    }
    id<LCCKIMMessageProtocol> message = userInfo[LCCKMessageNotifacationUserInfoMessageKey];
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
    NSString *userInfoConversationId = userInfo[LCCKNotificationConversationViewControllerBackgroundImageDidChangedUserInfoConversationIdKey];
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
    NSString *conversationViewControllerBackgroundImageKey = [NSString stringWithFormat:@"%@%@_%@", LCCKCustomConversationViewControllerBackgroundImageNamePrefix, [LCCKSessionService sharedInstance].clientId, conversationId];
    NSString *conversationViewControllerBackgroundImage = [[NSUserDefaults standardUserDefaults] objectForKey:conversationViewControllerBackgroundImageKey];
    if (conversationViewControllerBackgroundImage == nil) {
        conversationViewControllerBackgroundImage = [[NSUserDefaults standardUserDefaults] objectForKey:LCCKDefaultConversationViewControllerBackgroundImageName];
        if (conversationViewControllerBackgroundImage == nil) {
            [self setDefaultBackgroundImage];
        } else {
            NSString *imagePath = [conversationViewControllerBackgroundImage lcck_pathForConversationBackgroundImage];
            UIImage *image = [UIImage imageNamed:imagePath];
            [self.parentConversationViewController.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
        }
    } else {
        NSString *imagePath = [conversationViewControllerBackgroundImage lcck_pathForConversationBackgroundImage];
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
    [[LCCKUserSystemService sharedInstance] getProfilesInBackgroundForUserIds:@[ clientId ] callback:^(NSArray<id<LCCKUserDelegate>> *users, NSError *error) {
        id<LCCKUserDelegate> user;
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
        
        LCCKConversationInvalidedHandler conversationInvalidedHandler = [[LCCKConversationService sharedInstance] conversationInvalidedHandler];
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
        LCCKLock();
        [self.dataArray addObjectsFromArray:messages];
        LCCKUnlock();
    }
}

/*!
 * 与`-addMessages`方法的区别在于，第一次加载历史消息时需要查找最后一条消息之余还有没有消息。
 * 时间戳必须传0，后续方法会根据是否为了0，来判断是否是第一次进对话页面。
 */
- (void)addMessagesFirstTime:(NSArray *)messages {
    messages = [self messagesWithLocalMessages:messages freshTimestamp:0];
    if (messages.count > 0) {
        LCCKLock();
        self.dataArray = messages.mutableCopy;
        LCCKUnlock();
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
        NSArray *allFailedMessages = [[LCCKConversationService sharedInstance] failedMessagesByConversationId:self.currentConversationId];
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
        NSArray *allFailedMessageIds = [[LCCKConversationService sharedInstance] failedMessageIdsByConversationId:self.parentConversationViewController.conversationId];
        _allFailedMessageIds = allFailedMessageIds;
    }
    return _allFailedMessageIds;
}

- (NSArray<LCCKMessage *> *)failedMessagesWithPredicate:(NSPredicate *)predicate {
    NSArray *allFailedMessageIdsByConversationId = self.allFailedMessageIds;
    NSArray *failedMessageIds = [allFailedMessageIdsByConversationId filteredArrayUsingPredicate:predicate];
    NSArray<LCCKMessage *> *failedLCCKMessages;
    if (failedMessageIds.count > 0) {
        failedLCCKMessages = [[LCCKConversationService sharedInstance] failedMessagesByMessageIds:failedMessageIds];
    }
    return failedLCCKMessages;
}

/*!
 * @param messages 从服务端刷新下来的，夹杂着本地失败消息（但还未插入原有的旧消息self.dataArray里)。
 * 该方法能让preload时动态判断插入时间戳，同时也用在第一次加载时插入时间戳。
 */
- (NSArray *)messagesWithSystemMessages:(NSArray *)messages lastMessage:(id)lastMessage {
    NSMutableArray *messageWithSystemMessages = lastMessage ? @[lastMessage].mutableCopy : @[].mutableCopy;
    for (id message in messages) {
        [messageWithSystemMessages addObject:message];
        [message lcck_shouldDisplayTimestampForMessages:messageWithSystemMessages callback:^(BOOL shouldDisplayTimestamp, NSTimeInterval messageTimestamp) {
            if (shouldDisplayTimestamp) {
                [messageWithSystemMessages insertObject:[LCCKMessage systemMessageWithTimestamp:messageTimestamp] atIndex:(messageWithSystemMessages.count - 1)];
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
    NSString *startDate = [NSString stringWithFormat:@"%@", @([message lcck_messageTimestamp])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF <= %@) AND (SELF MATCHES %@)", startDate, LCCK_TIMESTAMP_REGEX];
    NSArray<LCCKMessage *> *failedLCCKMessages = [self failedMessagesWithPredicate:predicate];
    return failedLCCKMessages;
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
        fromDate = [formerMessage lcck_messageTimestamp];
        toDate = [message lcck_messageTimestamp];
        [self appendFailedMessagesToMessagesWithLocalMessages:messagesWithLocalMessages fromDate:fromDate toDate:toDate];
        [messagesWithLocalMessages addObject:message];
    }];
    //messages追加失败消息，第二步：
    //对应于上图中index里的n(last)到fromTimestamp
    //总是追加最后一条消息到上次下拉刷新之间的失败消息，如果历史记录里只有一条消息，也依然。
    id lastMessage = [messages lastObject];
    if (lastMessage) {
        fromDate = [lastMessage lcck_messageTimestamp];
        toDate = timestamp;
        if (timestamp == 0) {
            toDate = LCCK_FUTURE_TIMESTAMP;
        }
        [self appendFailedMessagesToMessagesWithLocalMessages:messagesWithLocalMessages fromDate:fromDate toDate:toDate];
    }
    return [self messagesWithSystemMessages:messagesWithLocalMessages];
}

- (void)appendFailedMessagesToMessagesWithLocalMessages:(NSMutableArray *)messagesWithLocalMessages fromDate:(int64_t)fromDate toDate:(int64_t)toDate {
    NSArray<LCCKMessage *> *failedLCCKMessages = [self failedLCCKMessagesWithFromDate:fromDate toDate:toDate];
    if (failedLCCKMessages.count > 0) {
        [messagesWithLocalMessages addObjectsFromArray:failedLCCKMessages];
    }
}

- (NSArray *)failedLCCKMessagesWithFromDate:(int64_t)fromDate toDate:(int64_t)toDate {
    NSString *fromDateString = [NSString stringWithFormat:@"%@", @(fromDate)];
    NSString *toDateString = [NSString stringWithFormat:@"%@", @(toDate)];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF >= %@) AND (SELF <= %@) AND (SELF MATCHES %@)", fromDateString, toDateString , LCCK_TIMESTAMP_REGEX];
    NSArray<LCCKMessage *> *failedLCCKMessages = [self failedMessagesWithPredicate:predicate];
    return failedLCCKMessages;
}

#pragma mark - Public Methods

- (void)sendCustomMessage:(id<LCCKIMMessageProtocol>)customMessage {
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
            [self.delegate messageSendStateChanged:LCCKMessageSendStateSending withProgress:percentDone/100.f forIndex:[self.dataArray indexOfObject:message]];
        }
              success:^(BOOL succeeded, NSError *error) {
                  if (![message lcck_isCustomMessage]) {
                      [(LCCKMessage *)message setSendStatus:LCCKMessageSendStateSent];
                  }
                  
                  [[LCCKSoundManager defaultManager] playSendSoundIfNeed];
                  [self.delegate messageSendStateChanged:LCCKMessageSendStateSent withProgress:1.0f forIndex:[self.dataArray indexOfObject:message]];
              } failed:^(BOOL succeeded, NSError *error) {
                  __strong __typeof(wself)self = wself;
                  if (![message lcck_isCustomMessage]) {
                      [(LCCKMessage *)message setSendStatus:LCCKMessageSendStateFailed];
                      if (self.currentConversationId.length > 0) {
                          [[LCCKConversationService sharedInstance] insertFailedLCCKMessage:message];
                      }
                  } else {
                      //TODO:自定义消息的失败缓存
                  }
                  [self.delegate messageSendStateChanged:LCCKMessageSendStateFailed withProgress:0.0f forIndex:[self.dataArray indexOfObject:message]];
              }];
}

- (void)sendCustomMessage:(id<LCCKIMMessageProtocol>)aMessage
            progressBlock:(LCCKProgressBlock)progressBlock
                  success:(LCCKBooleanResultBlock)success
                   failed:(LCCKBooleanResultBlock)failed {
    [self sendMessage:aMessage mentionList:@[] progressBlock:progressBlock success:success failed:failed];
}

- (void)sendMessage:(id)aMessage
        mentionList:(NSArray<NSString *> *)mentionList
      progressBlock:(LCCKProgressBlock)progressBlock
            success:(LCCKBooleanResultBlock)success
             failed:(LCCKBooleanResultBlock)failed {
    //[[NSNotificationCenter defaultCenter] postNotificationName:LCCKNotificationMessageSent object:nil];
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
    NSString *messageUUID =  [NSString stringWithFormat:@"%@", @(LCCK_CURRENT_TIMESTAMP)];
//    if (![aMessage lcck_isCustomMessage]) {
    if (![aMessage lcck_isCustomMessage] && [aMessage respondsToSelector:@selector(setLocalMessageId:)]) {
        [(LCCKMessage *)aMessage setLocalMessageId:messageUUID];
    } else {
        //TODO:
        //自定义消息的失败id
    }
    [self.delegate messageSendStateChanged:LCCKMessageSendStateSending withProgress:0.0f forIndex:[self.dataArray indexOfObject:aMessage]];
    NSError *messageNULLError = nil;
    
    
    id avimTypedMessage = [self avimTypedMessageFromLCCKMessage:aMessage theError:&messageNULLError];
    
    
    void(^sendMessageCallBack)(LCCKBooleanResultBlock theSuccess,
                               LCCKBooleanResultBlock theFailed) = ^(LCCKBooleanResultBlock theSuccess,
                                                                     LCCKBooleanResultBlock theFailed) {
        // `mentionList` was never sent before ChatKit was decoupled from LeanCloud; nil keeps that behavior.
        [[LCCKConversationService sharedInstance] sendMessage:avimTypedMessage
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
    
    void(^LCCKBlockSendCallback)(LCCKBooleanResultBlock theSuccess,
                                 LCCKBooleanResultBlock theFailed) = ^(LCCKBooleanResultBlock theSuccess,
                                                                       LCCKBooleanResultBlock theFailed) {
        LCCKSendMessageHookBlock sendMessageHookBlock = [[LCCKConversationService sharedInstance] sendMessageHookBlock];
        if (!sendMessageHookBlock) {
            sendMessageCallBack(theSuccess, theFailed);
        } else {
            LCCKSendMessageHookCompletionHandler completionHandler = ^(BOOL granted, NSError *aError) {
                if (granted) {
                    sendMessageCallBack(theSuccess, theFailed);
                } else {
                    !failed ?: failed(YES, aError);
                }
            };
            sendMessageHookBlock(self.parentConversationViewController, avimTypedMessage, completionHandler);
        }
    };
    
    if (![avimTypedMessage lcck_isCustomMessage]) {
        
        
//       void(^LCCKBooleanResultBlock)() = ^(void) {
            if ([avimTypedMessage conformsToProtocol:@protocol(LCCKIMMessageProtocol)]) {
                //    if ([avimTypedMessage lcck_isCustomMessage]) {
                [self setAttribute:@([self.parentConversationViewController getConversationIfExists].lcck_type) forKey:LCCKCustomMessageConversationTypeKey toIMMessage:avimTypedMessage];
                [avimTypedMessage setLcck_senderId:[LCCKSessionService sharedInstance].clientId];//for LCCKSendMessageHookBlock
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
            LCCKBlockSendCallback(nil, nil);
        }];
    } else {
        void(^LCCKBooleanResultBlock)(BOOL succeeded, NSError *error) = ^(BOOL succeeded, NSError *error) {
            if ([aMessage conformsToProtocol:@protocol(LCCKIMMessageProtocol)]) {
                [self setAttribute:@([self.parentConversationViewController getConversationIfExists].lcck_type) forKey:LCCKCustomMessageConversationTypeKey toIMMessage:aMessage];
                [aMessage setLcck_senderId:[LCCKSessionService sharedInstance].clientId];//for LCCKSendMessageHookBlock
                [self appendMessagesToDataArrayTrailing:@[aMessage]];
                if ([self.delegate respondsToSelector:@selector(reloadAfterReceiveMessage)]) {
                    [self.delegate reloadAfterReceiveMessage];
                }
            }
        };
        LCCKBlockSendCallback(LCCKBooleanResultBlock, nil);
    }
}

- (id<LCCKIMProvider>)IMProvider {
    return [LCChatKit sharedInstance].IMProvider;
}

/*!
 * Merges one custom attribute into an IM SDK message, keeping its existing attributes.
 */
- (void)setAttribute:(id)object forKey:(NSString *)key toIMMessage:(id<LCCKIMMessageProtocol>)message {
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

- (id<LCCKIMMessageProtocol>)avimTypedMessageFromLCCKMessage:(LCCKMessage *)aMessage
                                                    theError:(NSError **)theError {
    id<LCCKIMMessageProtocol> avimTypedMessage;
    if ([aMessage isKindOfClass:[LCCKMessage class]]) {
//    if (![aMessage lcck_isCustomMessage]) {
        LCCKMessage *message = (LCCKMessage *)aMessage;
        message.conversationId = self.currentConversationId;
        if ([message respondsToSelector:@selector(setSendStatus:)]) {
            message.sendStatus = LCCKMessageSendStateSending;
        }
        id<LCCKUserDelegate> sender = [[LCCKUserSystemService sharedInstance] fetchCurrentUser];
        message.sender = sender;
        message.ownerType = LCCKMessageOwnerTypeSelf;
        message.message = avimTypedMessage;
        avimTypedMessage = [self.IMProvider IMMessageFromMessage:message];
    } else if ([aMessage conformsToProtocol:@protocol(LCCKIMMessageProtocol)]){
        avimTypedMessage = (id<LCCKIMMessageProtocol>)aMessage;
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
    LCCKMessage *localFeedbackMessge = [LCCKMessage localFeedbackText:localFeedbackTextMessge];
    [self appendMessagesToDataArrayTrailing:@[localFeedbackMessge]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0];
    dispatch_async(dispatch_get_main_queue(),^{
        [self.parentConversationViewController.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.parentConversationViewController scrollToBottomAnimated:YES];
    });
}

- (void)resendMessageForMessageCell:(LCCKChatMessageCell *)messageCell {
    NSString *title = [NSString stringWithFormat:@"%@?", LCCKLocalizedStrings(@"resend")];
    LCCKAlertController *alert = [LCCKAlertController alertControllerWithTitle:title
                                                                       message:@""
                                                                preferredStyle:LCCKAlertControllerStyleAlert];
    NSString *cancelActionTitle = LCCKLocalizedStrings(@"cancel");
    LCCKAlertAction *cancelAction = [LCCKAlertAction actionWithTitle:cancelActionTitle style:LCCKAlertActionStyleDefault
                                                             handler:^(LCCKAlertAction * action) {}];
    [alert addAction:cancelAction];
    NSString *resendActionTitle = LCCKLocalizedStrings(@"resend");
    LCCKAlertAction *resendAction = [LCCKAlertAction actionWithTitle:resendActionTitle style:LCCKAlertActionStyleDefault
                                                             handler:^(LCCKAlertAction * action) {
                                                                 [self resendMessageAtIndexPath:messageCell.indexPath];
                                                             }];
    [alert addAction:resendAction];
    [alert showWithSender:nil controller:self.parentConversationViewController animated:YES completion:NULL];
}

- (void)modifyMessageForMessageCell:(LCCKChatMessageCell *)messageCell newMessage:(LCCKMessage *)newMessage callback:(void (^)(BOOL, NSError *))callback {
    NSIndexPath *indexPath = messageCell.indexPath;
    LCCKMessage *oldMessage = self.dataArray[indexPath.row];
    int oldTypedMessageIndex = -1;
    id<LCCKIMMessageProtocol> oldTypedMessage = nil;
    for (int i = 0; i < self.avimTypedMessage.count; i++) {
        id<LCCKIMMessageProtocol> item = self.avimTypedMessage[i];
        if ([oldMessage.serverMessageId isEqualToString:item.messageId]) {
            oldTypedMessageIndex = i;
            oldTypedMessage = item;
            break;
        }
    }
    if (oldTypedMessage && oldTypedMessageIndex >= 0 && oldTypedMessageIndex < self.avimTypedMessage.count) {
        [self.IMProvider updateMessage:oldTypedMessage
                              withText:newMessage.text
                          conversation:LCCKConversationService.sharedInstance.currentConversation
                              callback:^(BOOL succeeded, NSError * _Nullable error, id<LCCKIMMessageProtocol> _Nullable newTypedMessage) {
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

- (void)recallMessageForMessageCell:(LCCKChatMessageCell *)messageCell
                           callback:(void (^)(BOOL, NSError *))callback {
    NSIndexPath *indexPath = messageCell.indexPath;
    LCCKMessage *oldMessage = self.dataArray[indexPath.row];
    int oldTypedMessageIndex = -1;
    id<LCCKIMMessageProtocol> oldTypedMessage = nil;
    for (int i = 0; i < self.avimTypedMessage.count; i++) {
        id<LCCKIMMessageProtocol> item = self.avimTypedMessage[i];
        if ([oldMessage.serverMessageId isEqualToString:item.messageId]) {
            oldTypedMessageIndex = i;
            oldTypedMessage = item;
            break;
        }
    }
    if (oldTypedMessage && oldTypedMessageIndex >= 0 && oldTypedMessageIndex < self.avimTypedMessage.count) {
        [self.IMProvider recallMessage:oldTypedMessage
                          conversation:LCCKConversationService.sharedInstance.currentConversation
                              callback:^(BOOL succeeded, NSError * _Nullable error, id<LCCKIMMessageProtocol> _Nullable recalledMessage) {
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
    LCCKMessage *lcckMessage = self.dataArray[indexPath.row];
    NSUInteger row = indexPath.row;
    LCCKMessage *message;
    @try {
        message = self.dataArray[row - 1];
    } @catch (NSException *exception) {}
    @try {
        if (message.mediaType == LCCKMessageMediaTypeSystem && !message.isLocalMessage) {
            [self.dataArray lcck_removeMessageAtIndex:row - 1];
            [self.avimTypedMessage lcck_removeMessageAtIndex:row - 1];
            row -= 1;
        }
    } @catch (NSException *exception) {}
    [self.dataArray lcck_removeMessageAtIndex:row];
    [self.avimTypedMessage lcck_removeMessageAtIndex:row];
    NSString *oldFailedMessageId = lcckMessage.localMessageId;
    [self.parentConversationViewController.tableView reloadData];
    self.parentConversationViewController.allowScrollToBottom = YES;
    [self sendMessage:lcckMessage];
    [[LCCKConversationService sharedInstance] deleteFailedMessageByRecordId:oldFailedMessageId];
}

- (void)preloadMessageToTableView:(id)aMessage callback:(LCCKVoidBlock)callback {
    if (![aMessage conformsToProtocol:@protocol(LCCKIMMessageProtocol)]) {
        LCCKMessage *message = (LCCKMessage *)aMessage;
        message.sendStatus = LCCKMessageSendStateSending;
    }
    NSUInteger oldLastMessageCount = self.dataArray.count;
    [self appendMessagesToTrailing:@[aMessage]];
    NSUInteger newLastMessageCout = self.dataArray.count;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0];
    [self.delegate messageSendStateChanged:LCCKMessageSendStateSending withProgress:0.0f forIndex:indexPath.row];
    LCCKLock();
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
        LCCKUnlock();
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

- (id<LCCKConversationProtocol>)currentConversation {
    return [self.parentConversationViewController getConversationIfExists];
}

- (NSString *)currentConversationId {
    return self.currentConversation.conversationId;
}

- (void)loadMessagesFirstTimeWithCallback:(LCCKIdBoolResultBlock)callback {
    [self queryAndCacheMessagesWithTimestamp:0
                                   messageId:nil
                                       block:^(NSArray *avimTypedMessages, NSError *error)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
             BOOL succeed = [self.parentConversationViewController filterAVIMError:error];
             if (succeed) {
                 if ([LCCKConversationService.sharedInstance.currentConversationId isEqualToString:self.currentConversationId] && [LCCKConversationService.sharedInstance isChatting]) {
                     [self.IMProvider markConversationAsRead:[self currentConversation]];
                 }
                 NSMutableArray *lcckSucceedMessags = [NSMutableArray lcck_messagesWithAVIMMessages:avimTypedMessages];
                 [self addMessagesFirstTime:lcckSucceedMessags];
                 NSMutableArray *allMessages = [NSMutableArray arrayWithArray:avimTypedMessages];
                 self.avimTypedMessage = allMessages;
                 dispatch_async(dispatch_get_main_queue(),^{
                     [self.parentConversationViewController.tableView reloadData];
                     [self.parentConversationViewController scrollToBottomAnimated:NO];
                     self.parentConversationViewController.loadingMoreMessage = NO;
                 });
                 if (self.avimTypedMessage.count > 0) {
                     [[LCCKConversationService sharedInstance] updateConversationAsReadWithLastMessage:avimTypedMessages.lastObject];
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
                                     block:(LCCKArrayResultBlock)block
{
    if (self.parentConversationViewController.loadingMoreMessage) {
        return;
    }
    if (self.dataArray.count == 0) {
        timestamp = 0;
    }
    self.parentConversationViewController.loadingMoreMessage = YES;
    [[LCCKConversationService sharedInstance] queryTypedMessagesWithConversation:self.currentConversation
                                                                       messageId:messageId
                                                                       timestamp:timestamp
                                                                           limit:kLCCKOnePageSize
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
             if (avimTypedMessages.count < kLCCKOnePageSize) {
                 self.parentConversationViewController.shouldLoadMoreMessagesScrollToTop = NO;
             }
             !block ?: block(avimTypedMessages, error);
         });
     }];
}

- (void)loadOldMessages {
    id<LCCKIMMessageProtocol> msg = [self.avimTypedMessage lcck_messageAtIndex:0];
    int64_t timestamp = [msg lcck_sendTimestamp];
    [self queryAndCacheMessagesWithTimestamp:timestamp
                                   messageId:msg.messageId
                                       block:^(NSArray *avimTypedMessages, NSError *error)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
             if ([self.parentConversationViewController filterAVIMError:error]) {
                 NSMutableArray *lcckMessages = [[NSMutableArray lcck_messagesWithAVIMMessages:avimTypedMessages] mutableCopy];
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

- (void)getAllVisibleImagesForSelectedMessage:(LCCKMessage *)message
                             allVisibleImages:(NSArray **)allVisibleImages
                             allVisibleThumbs:(NSArray **)allVisibleThumbs
                         selectedMessageIndex:(NSNumber **)selectedMessageIndex {
    NSMutableArray *allVisibleImages_ = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *allVisibleThumbs_ = [[NSMutableArray alloc] initWithCapacity:0];
    NSUInteger idx = 0;
    for (NSObject<LCCKMessageDelegate> *message_ in self.dataArray) {
        if ([message_ lcck_isCustomMessage]) {
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
          isImageType = (message_.mediaType == LCCKMessageMediaTypeImage || message_.photo || message_.originPhotoURL);
        } @catch (NSException *exception) {}
        if (isImageType) {
            UIImage *placeholderImage = ({
                NSString *imageName = @"Placeholder_Accept_Defeat";
                UIImage *image = [UIImage lcck_imageNamed:imageName bundleName:@"Placeholder" bundleForClass:[self class]];
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
    UIImage *image = [UIImage lcck_imageNamed:imageName bundleName:@"Other" bundleForClass:[self class]];
    return image;
}

@end
