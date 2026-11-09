//
//  CYLConversationViewController.m
//  CYLChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/20.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

//CYLDebugging定义为1表示【debugging】 ，注释、不定义或者0 表示【debugging】
//#define CYLDebugging 1

#import "CYLConversationViewController.h"

#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

#import "UITableView+FDTemplateLayoutCell.h"
#import "CYLCellRegisterController.h"
#import "CYLStatusView.h"
#import "CYLSoundManager.h"
#import "CYLTextFullScreenViewController.h"
#import <objc/runtime.h>
#import "NSMutableArray+CYLMessageExtention.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#import "CYLConversationNavigationTitleView.h"
#import "CYLWebViewController.h"
#import "CYLSafariActivity.h"
#import "CYLAlertController.h"
#import "CYLPhotoBrowser.h"

#if __has_include(<CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>)
#import <CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>
#else
#import "CYLDeallocBlockExecutor.h"
#endif

#ifdef CYLDebugging
#import <MLeaksFinder/MLeaksFinder.h>
#endif

NSString *const CYLConversationViewControllerErrorDomain = @"CYLConversationViewControllerErrorDomain";

@interface CYLConversationViewController () <CYLChatBarDelegate, CYLChatMessageCellDelegate, CYLConversationViewModelDelegate, CYLPhotoBrowserDelegate>

@property (nonatomic, strong, readwrite) id<CYLConversationProtocol> conversation;
//@property (copy, nonatomic) NSString *messageSender /**< 正在聊天的用户昵称 */;
//@property (copy, nonatomic) NSString *avatarURL /**< 正在聊天的用户头像 */;
/**< 正在聊天的用户 */
@property (nonatomic, copy) id<CYLUserDelegate> user;
/**< 正在聊天的用户clientId */
@property (nonatomic, copy) NSString *userId;
/**< 正在聊天的用户头像 */
//@property (nonatomic, copy) NSURL *avatarURL;
@property (nonatomic, strong) CYLConversationViewModel *chatViewModel;
@property (nonatomic, copy) CYLFetchConversationHandler fetchConversationHandler;
@property (nonatomic, copy) CYLLoadLatestMessagesHandler loadLatestMessagesHandler;
@property (nonatomic, copy, readwrite) NSString *conversationId;
@property (nonatomic, strong) CYLWebViewController *webViewController;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, assign, getter=isFirstTimeJoinGroup) BOOL firstTimeJoinGroup;
@end

@implementation CYLConversationViewController

- (void)setFetchConversationHandler:(CYLFetchConversationHandler)fetchConversationHandler {
    _fetchConversationHandler = fetchConversationHandler;
}

- (void)setLoadLatestMessagesHandler:(CYLLoadLatestMessagesHandler)loadLatestMessagesHandler {
    _loadLatestMessagesHandler = loadLatestMessagesHandler;
}

#pragma mark -
#pragma mark - initialization Method

- (instancetype)initWithConversationId:(NSString *)conversationId {
    self = [super init];
    if (!self) {
        return nil;
    }
    _conversationId = [conversationId copy];
    [self setup];
    return self;
}

- (instancetype)initWithPeerId:(NSString *)peerId {
    self = [super init];
    if (!self) {
        return nil;
    }
    _peerId = [peerId copy];
    [self setup];
    return self;
}

- (id<CYLConversationProtocol>)getConversationIfExists {
    if (_conversation) {
        return _conversation;
    }
    return nil;
}

- (id<CYLConversationProtocol>)conversation {
    if (_conversation) { return _conversation; }
    do {
        /* If object is clean, ignore save request. */
        if (_peerId) {
            [[CYLConversationService sharedInstance] fetchConversationWithPeerId:self.peerId callback:^(id<CYLConversationProtocol> conversation, NSError *error) {
                //SDK没有好友概念，任何两个ID均可会话，请APP层自行处理好友关系。
                [self refreshConversation:conversation isJoined:YES error:error];
            }];
            break;
        }
        /* If object is clean, ignore save request. */
        if (_conversationId) {
            [[CYLConversationService sharedInstance] fetchConversationWithConversationId:self.conversationId callback:^(id<CYLConversationProtocol> conversation, NSError *error) {
                if (error) {
                    //如果用户已经已经被踢出群，此时依然能拿到 Conversation 对象，不会报 4401 错误，需要单独判断。即使后期服务端在这种情况下返回error，这里依然能正确处理。
                    [self refreshConversation:conversation isJoined:NO error:error];
                    return;
                }
                NSString *currentClientId = [CYLSessionService sharedInstance].clientId;
                //系统对话无成员概念，对应字段的优先顺序 sys > tr > memeber
                if (conversation.members.count == 0 && (!conversation.transient)) {
                    [self refreshConversation:conversation isJoined:YES];
                    return;
                }
                BOOL containsCurrentClientId = [conversation.members containsObject:currentClientId];
                if (containsCurrentClientId) {
                    [self refreshConversation:conversation isJoined:YES];
                    return;
                }
                if (self.isEnableAutoJoin) {
                    [[LCChatKit sharedInstance].IMProvider joinConversation:conversation callback:^(BOOL succeeded, NSError *error) {
                        [self refreshConversation:conversation isJoined:succeeded error:error];
                        if (succeeded) {
                            self.firstTimeJoinGroup = YES;
                        }
                    }];
                } else {
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
                    [self refreshConversation:conversation isJoined:NO error:error_];
                }
            }];
            break;
        }
    } while (NO);
    return _conversation;
}

#pragma mark - Life Cycle

- (void)setup {
    self.allowScrollToBottom = YES;
    self.loadingMoreMessage = NO;
    self.disableTextShowInFullScreen = NO;
    BOOL clientStatusOpened = [CYLSessionService sharedInstance].isClientOpened;
    if (!clientStatusOpened) {
        [self refreshConversation:nil isJoined:NO];
        [[CYLSessionService sharedInstance] reconnectForViewController:self callback:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self conversation];
            }
        }];
    }
}

#ifdef CYLDebugging
- (BOOL)willDealloc {
    if (![super willDealloc]) {
        return NO;
    }
    MLCheck(self.chatViewModel);
    return YES;
}
#endif

- (CYLConversationViewModel *)chatViewModel {
    if (_chatViewModel == nil) {
        CYLConversationViewModel *chatViewModel = [[CYLConversationViewModel alloc] initWithParentViewController:self];
        chatViewModel.delegate = self;
        _chatViewModel = chatViewModel;
    }
    return _chatViewModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userWillSendMsgWithoutPower) name:CYLNotificationRecordNoPower object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveNewMsgForLengthOut) name:CYLNotificationTextLengthOut object:nil];
    
    [self cyl_willDeallocWithSelfCallback:^(__unsafe_unretained CYLConversationViewController *owner, NSUInteger identifier) {
        !owner.viewControllerWillDeallocBlock ?: owner.viewControllerWillDeallocBlock(owner);
    }];
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    self.tableView.delegate = self.chatViewModel;
    self.tableView.dataSource = self.chatViewModel;
    self.chatBar.delegate = self;
    [self.view addSubview:self.chatBar];
    [self.view addSubview:self.clientStatusView];
    [self updateStatusView];
    [self initBarButton];
    [[CYLUserSystemService sharedInstance] fetchCurrentUserInBackground:^(id<CYLUserDelegate> user, NSError *error) {
        self.user = user;
    }];
    [self.chatViewModel setDefaultBackgroundImage];
    if (self.title) {
        self.navigationItem.title = self.title;
    }
    if (!self.navigationItem.titleView.superview) {
        [self setupNavigationItemTitleWithConversation:self.conversation];
    }
    !self.viewDidLoadBlock ?: self.viewDidLoadBlock(self);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self conversation];
    !self.viewWillAppearBlock ?: self.viewWillAppearBlock(self, animated);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.chatBar open];
    [self saveCurrentConversationInfoIfExists];
    //TODO:  群聊人数改变，改群名称
    [self setupNavigationItemTitleWithConversation:self.conversation];
    !self.viewDidAppearBlock ?: self.viewDidAppearBlock(self, animated);
}

- (void)loadDraft {
    [self.chatBar appendString:_conversation.cyl_draft];
    [self.chatBar beginInputing];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self.chatBar close];
    NSString *conversationId = [self getConversationIdIfExists:nil];
    if (conversationId) {
        [[CYLConversationService sharedInstance] updateDraft:self.chatBar.cachedText conversationId:conversationId];
    }
    [self clearCurrentConversationInfo];
    [[CYLAVAudioPlayer sharePlayer] stopAudioPlayer];
    [CYLAVAudioPlayer sharePlayer].identifier = nil;
    [CYLAVAudioPlayer sharePlayer].URLString = nil;
    !self.viewWillDisappearBlock ?: self.viewWillDisappearBlock(self, animated);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //TODO:  群聊人数改变，改群名称
    !self.viewDidDisappearBlock ?: self.viewDidDisappearBlock(self, animated);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    !self.didReceiveMemoryWarningBlock ?: self.didReceiveMemoryWarningBlock(self);
}

#pragma mark -
#pragma mark - public Methods

- (void)sendTextMessage:(NSString *)text {
    [self sendTextMessage:text mentionList:@[]];
}

- (void)sendTextMessage:(NSString *)text mentionList:(NSArray<NSString *> *)mentionList {
    if ([text length] > 0 ) {
        CYLMessage *lcckMessage = [[CYLMessage alloc] initWithText:text
                                                            senderId:self.userId
                                                              sender:self.user
                                                           timestamp:CYL_CURRENT_TIMESTAMP
                                                     serverMessageId:nil];
        [self makeSureSendValidMessage:lcckMessage afterFetchedConversationShouldWithAssert:NO];
        [self.chatViewModel sendMessage:lcckMessage mentionList:mentionList];
    }
}

- (void)sendImages:(NSArray<UIImage *> *)pictures {
    for (UIImage *image in pictures) {
        [self sendImageMessage:image];
    }
}

- (void)sendImageMessage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    [self sendImageMessageData:imageData];
}

- (void)sendImageMessageData:(NSData *)imageData {
    NSString *path = [[CYLSettingService sharedInstance] tmpPath];
    NSError *error;
    [imageData writeToFile:path options:NSDataWritingAtomic error:&error];
    UIImage *representationImage = [[UIImage alloc] initWithData:imageData];
    UIImage *thumbnailPhoto = [representationImage cyl_imageByScalingAspectFill];
    if (error == nil) {
        CYLMessage *message = [[CYLMessage alloc] initWithPhoto:representationImage
                                                       photoWidth:0
                                                      photoHeight:0
                                                   thumbnailPhoto:thumbnailPhoto
                                                        photoPath:path
                                                     thumbnailURL:nil
                                                   originPhotoURL:nil
                                                         senderId:self.userId
                                                           sender:self.user
                                                        timestamp:CYL_CURRENT_TIMESTAMP
                                                  serverMessageId:nil
                                ];
        [self makeSureSendValidMessage:message afterFetchedConversationShouldWithAssert:NO];
        [self.chatViewModel sendMessage:message];
    } else {
        [self alert:@"write image to file error"];
    }
}

- (void)sendVoiceMessageWithPath:(NSString *)voicePath time:(NSTimeInterval)recordingSeconds {
    CYLMessage *message = [[CYLMessage alloc] initWithVoicePath:voicePath
                                                         voiceURL:nil
                                                    voiceDuration:[NSString stringWithFormat:@"%@", @(recordingSeconds)]
                                                         senderId:self.userId
                                                           sender:self.user
                                                        timestamp:CYL_CURRENT_TIMESTAMP
                                                  serverMessageId:nil];
    [self makeSureSendValidMessage:message afterFetchedConversationShouldWithAssert:NO];
    [self.chatViewModel sendMessage:message];
}

- (void)sendLocationMessageWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate locatioTitle:(NSString *)locationTitle {
    
    CYLMessage *message = [[CYLMessage alloc] initWithLocalPositionPhoto:({
        NSString *imageName = @"message_sender_location";
        UIImage *image = [UIImage cyl_imageNamed:imageName bundleName:@"MessageBubble" bundleForClass:[self class]];
        image;})
                                                              geolocations:locationTitle
                                                                  location:[[CLLocation alloc] initWithLatitude:locationCoordinate.latitude
                                                                                                      longitude:locationCoordinate.longitude]
                                                                  senderId:self.userId
                                                                    sender:self.user
                                                                 timestamp:CYL_CURRENT_TIMESTAMP
                                                           serverMessageId:nil];
    [self makeSureSendValidMessage:message afterFetchedConversationShouldWithAssert:NO];
    [self.chatViewModel sendMessage:message];
}

- (void)sendLocalFeedbackTextMessge:(NSString *)localFeedbackTextMessge {
    [self.chatViewModel sendLocalFeedbackTextMessge:localFeedbackTextMessge];
}

- (void)sendCustomMessage:(id<CYLIMMessageProtocol>)customMessage {
    [self makeSureSendValidMessageAfterFetchedConversation:customMessage];
    [self.chatViewModel sendCustomMessage:customMessage];
}

- (void)sendCustomMessage:(id<CYLIMMessageProtocol>)customMessage
            progressBlock:(CYLProgressBlock)progressBlock
                  success:(CYLBooleanResultBlock)success
                   failed:(CYLBooleanResultBlock)failed {
    [self makeSureSendValidMessageAfterFetchedConversation:customMessage];
    [self.chatViewModel sendCustomMessage:customMessage progressBlock:progressBlock success:success failed:failed];
}

- (void)makeSureSendValidMessageAfterFetchedConversation:(id)message {
    [self makeSureSendValidMessage:message afterFetchedConversationShouldWithAssert:YES];
}

- (void)makeSureSendValidMessage:(id)message afterFetchedConversationShouldWithAssert:(BOOL)withAssert {
    NSString *formatString = @"\n\n\
    ------ BEGIN NSException Log ---------------\n \
    class name: %@                              \n \
    ------line: %@                              \n \
    ----reason: %@                              \n \
    ------ END -------------------------------- \n\n";
    if (!self.isAvailable) {
        NSString *reason = [NSString stringWithFormat:formatString,
                            @(__PRETTY_FUNCTION__),
                            @(__LINE__),
                            @"Remember to check if `isAvailable` is ture, making sure sending message after conversation has been fetched"];
        if (!withAssert) {
            CYLLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), reason);
            return;
        }
        NSAssert(NO, reason);
    }
    if ([message isKindOfClass:[CYLMessage class]]) {
        return;
    }
    if ([message conformsToProtocol:@protocol(CYLIMMessageProtocol)]) {
        return;
    }
    {
        NSString *reason = [NSString stringWithFormat:formatString,
                            @(__PRETTY_FUNCTION__),
                            @(__LINE__),
                            @"ChatKit only support sending CYLMessage or messages conforming to CYLIMMessageProtocol"];
        //TODO: add debug model
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), reason);
        return;
    }
}

#pragma mark - UI init

- (void)initBarButton {
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backBtn];
}

- (void)clearCurrentConversationInfo {
    [CYLConversationService sharedInstance].currentConversationId = nil;
}

- (void)saveCurrentConversationInfoIfExists {
    NSString *conversationId = [self getConversationIdIfExists:nil];
    if (conversationId) {
        [CYLConversationService sharedInstance].currentConversationId = conversationId;
    }
    
    if (_conversation) {
        [CYLConversationService sharedInstance].currentConversation = _conversation;
    }
}

- (void)setupNavigationItemTitleWithConversation:(id<CYLConversationProtocol>)conversation {
    // Related report about the conversation title's initial position: https://github.com/leancloud/ChatKit-OC/issues/202
    if (self.navigationItem.title) {
        return;
    }
    self.navigationItem.titleView = nil;
    CYLConversationNavigationTitleView *navigationItemTitle = [[CYLConversationNavigationTitleView alloc] initWithConversation:conversation navigationController:self.navigationController];
    navigationItemTitle.frame = CGRectZero;
    //仅修高度,xyw值不变
    navigationItemTitle.frame = ({
        CGRect frame = navigationItemTitle.frame;
        CGFloat containerViewHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat containerViewWidth = self.navigationController.navigationBar.frame.size.width - 130;
        frame.size.width = containerViewWidth;
        frame.size.height = containerViewHeight;
        navigationItemTitle.center = self.navigationController.navigationBar.center;
        frame;
    });
    self.navigationItem.titleView = navigationItemTitle;
}

- (void)fetchConversationHandler:(id<CYLConversationProtocol>)conversation {
    CYLFetchConversationHandler fetchConversationHandler;
    do {
        if (_fetchConversationHandler) {
            fetchConversationHandler = _fetchConversationHandler;
            break;
        }
        CYLFetchConversationHandler generalFetchConversationHandler = [CYLConversationService sharedInstance].fetchConversationHandler;
        if (generalFetchConversationHandler) {
            fetchConversationHandler = generalFetchConversationHandler;
            break;
        }
    } while (NO);
    if (fetchConversationHandler) {
        dispatch_async(dispatch_get_main_queue(),^{
            fetchConversationHandler(conversation, self);
        });
    }
}

- (void)loadLatestMessagesHandler:(BOOL)succeeded error:(NSError *)error {
    CYLLoadLatestMessagesHandler loadLatestMessagesHandler;
    do {
        if (_loadLatestMessagesHandler) {
            loadLatestMessagesHandler = _loadLatestMessagesHandler;
            break;
        }
        CYLLoadLatestMessagesHandler generalLoadLatestMessagesHandler = [CYLConversationService sharedInstance].loadLatestMessagesHandler;
        if (generalLoadLatestMessagesHandler) {
            loadLatestMessagesHandler = generalLoadLatestMessagesHandler;
            break;
        }
    } while (NO);
    if (loadLatestMessagesHandler) {
        dispatch_async(dispatch_get_main_queue(),^{
            loadLatestMessagesHandler(self, succeeded, error);
        });
    }
}

- (void)refreshConversation:(id<CYLConversationProtocol>)conversation isJoined:(BOOL)isJoined {
    [self refreshConversation:conversation isJoined:isJoined error:nil];
}

- (NSString *)getConversationIdIfExists:(id<CYLConversationProtocol>)conversation {
    NSString *conversationId;
    do {
        if (self.conversationId) {
            conversationId = self.conversationId;
            break;
        }
        if (_conversation) {
            conversationId = self.conversation.conversationId;
            break;
        }
        if (conversation) {
            conversationId = conversation.conversationId;
            break;
        }
    } while (NO);
    return conversationId;
}

- (void)notJoinedHandler:(id<CYLConversationProtocol>)conversation error:(NSError *)aError {
    void(^notJoinedHandler)(id<CYLUserDelegate> user, NSError *error) = ^(id<CYLUserDelegate> user, NSError *error) {
        CYLConversationInvalidedHandler conversationInvalidedHandler = [[CYLConversationService sharedInstance] conversationInvalidedHandler];
        NSString *conversationId = [self getConversationIdIfExists:conversation];
        //错误码参考：https://leancloud.cn/docs/realtime_v2.html#%E4%BA%91%E7%AB%AF%E9%94%99%E8%AF%AF%E7%A0%81%E8%AF%B4%E6%98%8E
        if (error.code == 4401 && conversationId.length > 0) {
            //如果被管理员踢出群之后，再进入该会话，本地可能有缓存，要清除掉，防止下次再次进入。
            [[CYLConversationService sharedInstance] deleteRecentConversationWithConversationId:conversationId];
        }
        conversationInvalidedHandler(conversationId, self, user, error);
    };
    
    if (conversation && (conversation.creator.length > 0)) {
        [[CYLUserSystemService sharedInstance] getProfilesInBackgroundForUserIds:@[ conversation.creator ] callback:^(NSArray<id<CYLUserDelegate>> *users, NSError *error) {
            id<CYLUserDelegate> user;
            @try {
                user = users[0];
            } @catch (NSException *exception) {}
            !notJoinedHandler ?: notJoinedHandler(user, aError);
        }];
    } else {
        !notJoinedHandler ?: notJoinedHandler(nil, aError);
    }
}

/*!
 * conversation 不一定有值，可能为 nil
 */
- (void)refreshConversation:(id<CYLConversationProtocol>)aConversation isJoined:(BOOL)isJoined error:(NSError *)error {
    if (error) {
        [self notJoinedHandler:aConversation error:error];
        aConversation = nil;
    }
    
    id<CYLConversationProtocol> conversation;
    if (isJoined && !error) {
        conversation = aConversation;
    }
    //peer初始化成功时也会对conversation赋值
    _conversation = conversation;
    [self saveCurrentConversationInfoIfExists];
    //    if (_conversation) {
    //    }
    [self callbackCurrentConversationEvenNotExists:conversation callback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                [[CYLConversationService sharedInstance] updateConversationAsReadWithLastMessage:_conversation.cyl_lastMessage];
            });
            [self handleLoadHistoryMessagesHandlerIfIsJoined:isJoined];
        }
    }];
}

- (void)callbackCurrentConversationEvenNotExists:(id<CYLConversationProtocol>)conversation callback:(CYLBooleanResultBlock)callback {
    if (conversation.createAt) {
        id<CYLIMProvider> IMProvider = [LCChatKit sharedInstance].IMProvider;
        if ([IMProvider respondsToSelector:@selector(prepareConversation:)]) {
            [IMProvider prepareConversation:conversation];
        }
        BOOL hasDraft = (conversation.cyl_draft.length > 0);
        if (hasDraft) {
            [self loadDraft];
        }
        self.conversationId = conversation.conversationId;
        [self.chatViewModel resetBackgroundImage];
        NSArray *members = conversation.members;
        //系统对话
        if (members.count == 0) {
            self.navigationItem.title = conversation.cyl_title;
            [self fetchConversationHandler:conversation];
            !callback ?: callback(YES, nil);
            return;
        }
        //_conversation初始化成功时也会对_peerId赋值
        if (!_peerId && members.count == 2) {
            _peerId = conversation.cyl_peerId;
        }
        [[LCChatKit sharedInstance] getProfilesInBackgroundForUserIds:members callback:^(NSArray<id<CYLUserDelegate>> *users, NSError *error) {
            if (!self.disableTitleAutoConfig && (users.count > 0)) {
                [self setupNavigationItemTitleWithConversation:conversation];
            }
            [self fetchConversationHandler:conversation];
            !callback ?: callback(YES, nil);
            return;
        }];
    } else {
        [self fetchConversationHandler:conversation];
        NSInteger code = 0;
        NSString *errorReasonText = @"error reason";
        NSDictionary *errorInfo = @{
                                    @"code":@(code),
                                    NSLocalizedDescriptionKey : errorReasonText,
                                    };
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:code
                                         userInfo:errorInfo];
        
        !callback ?: callback(NO, error);
    }
}

- (BOOL)isAvailable {
    BOOL isAvailable = self.conversation;
    return isAvailable;
}

//TODO:Conversation为nil,不callback
- (void)handleLoadHistoryMessagesHandlerIfIsJoined:(BOOL)isJoined {
    if (!isJoined) {
        BOOL succeeded = NO;
        //错误码参考：https://leancloud.cn/docs/realtime_v2.html#服务器端错误码说明
        NSInteger code = 4312;
        NSString *errorReasonText = @"拉取对话消息记录被拒绝，当前用户不再对话中";
        NSDictionary *errorInfo = @{
                                    @"code" : @(code),
                                    NSLocalizedDescriptionKey : errorReasonText,
                                    };
        NSError *error = [NSError errorWithDomain:CYLConversationViewControllerErrorDomain
                                             code:code
                                         userInfo:errorInfo];
        [self loadLatestMessagesHandler:succeeded error:error];
        return;
    }
    __weak __typeof(self) weakSelf = self;
    [self.chatViewModel loadMessagesFirstTimeWithCallback:^(BOOL succeeded, id object, NSError *error) {
        dispatch_async(dispatch_get_main_queue(),^{
            [weakSelf loadLatestMessagesHandler:succeeded error:error];
            BOOL isFirstTimeMeet = (([object count] == 0) && succeeded);
            [self sendWelcomeMessageIfNeeded:isFirstTimeMeet];
        });
    }];
}

- (void)sendWelcomeMessageIfNeeded:(BOOL)isFirstTimeMeet {
    //系统对话
    if (_conversation.members.count == 0) {
        return;
    }
    __block NSString *welcomeMessage;
    CYLConversationType conversationType = _conversation.cyl_type;
    switch (conversationType) {
        case CYLConversationTypeSingle:
            welcomeMessage = CYLLocalizedStrings(@"SingleWelcomeMessage");
            break;
        case CYLConversationTypeGroup:
            welcomeMessage = CYLLocalizedStrings(@"GroupWelcomeMessage");
            break;
        default:
            break;
    }
    BOOL isAllowInUserSetting = ([welcomeMessage length] > 0);
    if (!isAllowInUserSetting) {
        return;
    }
    BOOL isSessionAvailable = [CYLSessionService sharedInstance].connect;
    BOOL isNeverChat = (isSessionAvailable && isFirstTimeMeet);
    BOOL shouldSendWelcome = self.isFirstTimeJoinGroup || isNeverChat;
    if (shouldSendWelcome) {
        [[CYLUserSystemService sharedInstance] fetchCurrentUserInBackground:^(id<CYLUserDelegate> user, NSError *error) {
            NSString *userName = user.name;
            if (userName.length > 0 && (conversationType == CYLConversationTypeGroup)) {
                welcomeMessage = [NSString stringWithFormat:@"%@%@", CYLLocalizedStrings(@"GroupWelcomeMessageWithNickName"), userName];
            }
            [self sendTextMessage:welcomeMessage];
        }];
    }
}

- (NSString *)userId {
    return [LCChatKit sharedInstance].clientId;
}

#pragma mark - CYLChatBarDelegate

- (void)chatBar:(CYLChatBar *)chatBar sendMessage:(NSString *)message mentionList:(NSArray<NSString *> *)mentionList {
    [self sendTextMessage:message mentionList:mentionList];
}

- (void)chatBar:(CYLChatBar *)chatBar sendVoice:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds{
    [self sendVoiceMessageWithPath:voiceFileName time:seconds];
}

- (void)chatBar:(CYLChatBar *)chatBar sendPictures:(NSArray<UIImage *> *)pictures{
    [self sendImages:pictures];
}

- (void)didInputAtSign:(CYLChatBar *)chatBar {
    //系统对话
    if (_conversation.members.count == 0) {
        return;
    }
    if (self.conversation.cyl_type == CYLConversationTypeGroup) {
        [self presentSelectMemberViewController];
    }
}

- (void)presentSelectMemberViewController {
    NSString *cuttentClientId = [CYLSessionService sharedInstance].clientId;
    NSArray<id<CYLUserDelegate>> *users = [[CYLUserSystemService sharedInstance] getCachedProfilesIfExists:self.conversation.members shouldSameCount:YES error:nil];
    CYLContactListViewController *contactListViewController = [[CYLContactListViewController alloc] initWithContacts:[NSSet setWithArray:users] userIds:[NSSet setWithArray:self.conversation.members] excludedUserIds:[NSSet setWithArray:@[cuttentClientId]] mode:CYLContactListModeMultipleSelection];
    [contactListViewController setViewDidDismissBlock:^(CYLChatBaseViewController *viewController) {
        [self.chatBar open];
        [self.chatBar beginInputing];
    }];
    [contactListViewController setSelectedContactCallback:^(UIViewController *viewController, NSString *peerId) {
        [viewController dismissViewControllerAnimated:YES completion:^{
            [self.chatBar open];
        }];
        if (peerId.length > 0) {
            [self.chatBar appendString:[NSString stringWithFormat:@"@%@ ", peerId] mentionList:@[peerId]];
        }
    }];
    [contactListViewController setSelectedContactsCallback:^(UIViewController *viewController, NSArray<NSString *> *peerIds) {
        if (peerIds.count > 0) {
            NSString *peerString = [[peerIds valueForKey:@"description"] componentsJoinedByString:@" @"];
            peerString = [NSString stringWithFormat:@"@%@ ", peerString];
            [self.chatBar appendString:peerString mentionList:peerIds];
        }
    }];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contactListViewController];
    [self presentViewController:navigationController animated:YES completion:^{
        [self.chatBar close];
    }];
}

- (void)chatBar:(CYLChatBar *)chatBar sendLocation:(CLLocationCoordinate2D)locationCoordinate locationText:(NSString *)locationText {
    [self sendLocationMessageWithLocationCoordinate:locationCoordinate locatioTitle:locationText];
}

- (void)chatBarFrameDidChange:(CYLChatBar *)chatBar shouldScrollToBottom:(BOOL)shouldScrollToBottom {
    [UIView animateWithDuration:CYLAnimateDuration animations:^{
        [self.tableView.superview layoutIfNeeded];
        self.allowScrollToBottom = shouldScrollToBottom;
        [self scrollToBottomAnimated:NO];
    } completion:nil];
}

#pragma mark - CYLChatMessageCellDelegate

- (void)messageCellTappedHead:(CYLChatMessageCell *)messageCell {
    CYLOpenProfileBlock openProfileBlock = [CYLUIService sharedInstance].openProfileBlock;
    NSString *senderId = nil;
    @try {
      senderId = messageCell.message.senderId;
    } @catch (NSException *exc) {}
    if (!senderId) {
        @try {
            id<CYLIMMessageProtocol> message = (id<CYLIMMessageProtocol>)messageCell.message;
            senderId = [message cyl_senderId];
        } @catch (NSException *exc) {}
    }
    id<CYLUserDelegate> sender = nil;
    @try {
        sender = messageCell.message.sender;
    } @catch (NSException *exc) {}
    
    !openProfileBlock ?: openProfileBlock(senderId, sender, self);
}

- (void)messageCellTappedBlank:(CYLChatMessageCell *)messageCell {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)messageCellTappedMessage:(CYLChatMessageCell *)messageCell {
    if (!messageCell) {
        return;
    }
    [self.chatBar close];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:messageCell];
    id<CYLMessageDelegate> message = [self.chatViewModel.dataArray cyl_messageAtIndex:indexPath.row];
    switch (messageCell.mediaType) {
        case CYLMessageMediaTypeAudio: {
            CYLMessage *voiceMessage = (CYLMessage *)message;
            NSString *voiceFileName = voiceMessage.voicePath;//必须带后缀，.mp3；
            [[CYLAVAudioPlayer sharePlayer] playAudioWithURLString:voiceFileName identifier:message.messageId];
        }
            break;
        case CYLMessageMediaTypeImage: {
            [self imageMessageCellTappedMessageCell:messageCell];
        }
            break;
        case CYLMessageMediaTypeLocation: {
            CYLMessage *locationMessage = (CYLMessage *)message;
            NSDictionary *userInfo = @{
                                       /// 传递触发的UIViewController对象
                                       CYLPreviewLocationMessageUserInfoKeyFromController : self,
                                       /// 传递触发的UIView对象
                                       CYLPreviewLocationMessageUserInfoKeyFromView : self.tableView,
                                       };
            CYLPreviewLocationMessageBlock previewLocationMessageBlock = [CYLUIService sharedInstance].previewLocationMessageBlock;
            !previewLocationMessageBlock ?: previewLocationMessageBlock(locationMessage.location, locationMessage.geolocations, userInfo);
        }
            break;
        default: {
            BOOL isImage = NO;
            @try {
                isImage = (message.photo || message.photoPath.length > 0);
            }
            @catch (NSException *){}
            if (isImage) {
                [self imageMessageCellTappedMessageCell:messageCell];
                
            }
        }
            break;
    }
    [self.chatBar open];
}


- (void)imageMessageCellTappedMessageCell:(CYLChatImageMessageCell *)messageCell {
    ///FIXME:4S等低端机型在图片超过1M时，有几率会Crash，尤其是全景图。
    CYLPreviewImageMessageBlock previewImageMessageBlock = [CYLUIService sharedInstance].previewImageMessageBlock;
    UIImageView *placeholderView = [(CYLChatImageMessageCell *)messageCell messageImageView];
    NSDictionary *userInfo = @{
                               /// 传递触发的UIViewController对象
                               CYLPreviewImageMessageUserInfoKeyFromController : self,
                               /// 传递触发的UIView对象
                               CYLPreviewImageMessageUserInfoKeyFromView : self.tableView,
                               CYLPreviewImageMessageUserInfoKeyFromPlaceholderView : placeholderView
                               };
    NSArray *allVisibleImages = nil;
    NSArray *allVisibleThumbs = nil;
    NSNumber *selectedMessageIndex = nil;
    [self.chatViewModel getAllVisibleImagesForSelectedMessage:messageCell.message allVisibleImages:&allVisibleImages allVisibleThumbs:&allVisibleThumbs selectedMessageIndex:&selectedMessageIndex];
    if (previewImageMessageBlock) {
        previewImageMessageBlock(selectedMessageIndex.unsignedIntegerValue, allVisibleImages, allVisibleThumbs, userInfo);
    } else {
        [self previewImageMessageWithInitialIndex:selectedMessageIndex.unsignedIntegerValue allVisibleImages:allVisibleImages allVisibleThumbs:allVisibleThumbs placeholderImageView:placeholderView fromViewController:self];
    }
}

- (void)previewImageMessageWithInitialIndex:(NSUInteger)initialIndex
                           allVisibleImages:(NSArray *)allVisibleImages
                           allVisibleThumbs:(NSArray *)allVisibleThumbs
                       placeholderImageView:(UIImageView *)placeholderImageView
                         fromViewController:(CYLConversationViewController *)fromViewController{
    // Browser
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:[allVisibleImages count]];
    NSMutableArray *thumbs = [[NSMutableArray alloc] initWithCapacity:[allVisibleThumbs count]];
    if (allVisibleImages.count == 0 && allVisibleThumbs.count == 0) {
        return;
    }
    CYLPhoto *photo;
    for (NSUInteger index = 0; index < allVisibleImages.count; index++) {
        id image_ = allVisibleImages[index];
        
        if ([image_ isKindOfClass:[UIImage class]]) {
            photo = [CYLPhoto photoWithImage:image_];
        } else {
            photo = [CYLPhoto photoWithURL:image_];
        }
        if (index == initialIndex) {
            photo.placeholderImageView = placeholderImageView;
        }
        [photos addObject:photo];
    }
    // Options
    self.photos = photos;
    self.thumbs = thumbs;
    // Create browser
    CYLPhotoBrowser *browser = [[CYLPhotoBrowser alloc] initWithPhotos:photos];
    browser.actionButtonTitles = @[@"识别二维码"];
    browser.delegate = self;
    [browser setInitialPageIndex:initialIndex];
    browser.usePopAnimation = YES;
    browser.animationDuration = 0.15;
    // Show
    [fromViewController presentViewController:browser animated:YES completion:nil];
}

- (void)modifyMessage:(CYLChatMessageCell *)messageCell newMessage:(CYLMessage *)newMessage callback:(void (^)(BOOL, NSError *))callback {
    [self.chatViewModel modifyMessageForMessageCell:messageCell newMessage:newMessage callback:callback];
}


- (void)recallMessage:(CYLChatMessageCell *)messageCell callback:(void (^)(BOOL, NSError *))callback {
    [self.chatViewModel recallMessageForMessageCell:messageCell callback:callback];
}

- (void)photoBrowser:(CYLPhotoBrowser *)photoBrowser didDismissActionSheetWithButtonIndex:(NSUInteger)buttonIndex photoIndex:(NSUInteger)photoIndex {
    
    NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@--%@--%@", @(__PRETTY_FUNCTION__), @(__LINE__), photoBrowser, @(buttonIndex), @(photoIndex));
    UIImage *image =  self.photos[photoIndex];
}

- (void)avatarImageViewLongPressed:(CYLChatMessageCell *)messageCell {
    if (messageCell.message.senderId == [LCChatKit sharedInstance].clientId || self.conversation.cyl_type == CYLConversationTypeSingle) {
        return;
    }
    NSString *userName = messageCell.message.localDisplayName;
    if (userName.length == 0 || !userName || [userName isEqualToString:CYLLocalizedStrings(@"nickNameIsNil")]) {
        return;
    }
    NSString *appendString = [NSString stringWithFormat:@"@%@ ", userName];
    [self.chatBar appendString:appendString];
}

- (void)textMessageCellDoubleTapped:(CYLChatMessageCell *)messageCell {
    if (self.disableTextShowInFullScreen) {
        return;
    }
    CYLTextFullScreenViewController *textFullScreenViewController = [[CYLTextFullScreenViewController alloc] initWithText:messageCell.message.text];
    [self.navigationController pushViewController:textFullScreenViewController animated:NO];
}

- (void)resendMessage:(CYLChatMessageCell *)messageCell {
    [self.chatViewModel resendMessageForMessageCell:messageCell];
}

- (void)fileMessageDidDownload:(CYLChatMessageCell *)messageCell {
    [self.tableView reloadData];
}

- (void)messageCell:(CYLChatMessageCell *)messageCell didTapLinkText:(NSString *)linkText linkType:(MLLinkType)linkType {
    switch (linkType) {
        case MLLinkTypeURL: {
            CYLWebViewController *webViewController = [[CYLWebViewController alloc] init];
            if (![NSURL URLWithString:linkText].scheme) {
                linkText = [NSString stringWithFormat:@"http://%@", linkText];
            }
            webViewController.URL = [NSURL URLWithString:linkText];
            CYLSafariActivity *activity = [[CYLSafariActivity alloc] init];
            webViewController.applicationActivities = @[activity];
            webViewController.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypePostToWeibo];
            [self.navigationController pushViewController:webViewController animated:YES];
        }
            break;
        case MLLinkTypePhoneNumber: {
            NSString *title = [NSString stringWithFormat:@"%@?", CYLLocalizedStrings(@"call")];
            CYLAlertController *alert = [CYLAlertController alertControllerWithTitle:title
                                                                               message:@""
                                                                        preferredStyle:CYLAlertControllerStyleAlert];
            NSString *cancelActionTitle = CYLLocalizedStrings(@"cancel");
            CYLAlertAction* cancelAction = [CYLAlertAction actionWithTitle:cancelActionTitle style:CYLAlertActionStyleDefault
                                                                     handler:^(CYLAlertAction * action) {}];
            [alert addAction:cancelAction];
            NSString *resendActionTitle = CYLLocalizedStrings(@"call");
            CYLAlertAction* resendAction = [CYLAlertAction actionWithTitle:resendActionTitle style:CYLAlertActionStyleDefault
                                                                     handler:^(CYLAlertAction * action) {
                                                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"tel:%@", linkText]]];
                                                                     }];
            [alert addAction:resendAction];
            [alert showWithSender:nil controller:self animated:YES completion:NULL];
        }
            break;
        default:
            break;
    }
}

#pragma mark - CYLConversationViewModelDelegate

- (void)messageReadStateChanged:(CYLMessageReadState)readState withProgress:(CGFloat)progress forIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    CYLChatMessageCell *messageCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (![self.tableView.visibleCells containsObject:messageCell]) {
        return;
    }
    messageCell.messageReadState = readState;
}

- (void)messageSendStateChanged:(CYLMessageSendState)sendState withProgress:(CGFloat)progress forIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    CYLChatMessageCell *messageCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (![self.tableView.visibleCells containsObject:messageCell]) {
        return;
    }
    if (messageCell.mediaType == CYLMessageMediaTypeImage) {
        [(CYLChatImageMessageCell *)messageCell setUploadProgress:progress];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        messageCell.messageSendState = sendState;
    });
}

- (void)reloadAfterReceiveMessage {
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}

#pragma mark - CYLAVAudioPlayerDelegate

- (void)loadMoreMessagesScrollTotop {
    [self.chatViewModel loadOldMessages];
}

- (void)updateStatusView {
    if (!self.shouldCheckSessionStatus) {
        return;
    }
    BOOL isConnected = [CYLSessionService sharedInstance].connect;
    if (isConnected) {
        self.clientStatusView.hidden = YES;
    } else {
        self.clientStatusView.hidden = NO;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification

- (void)userWillSendMsgWithoutPower {
    [self showWaring:@"需要开启麦克风权限"];
}

- (void)recieveNewMsgForLengthOut {
    NSString *message = [NSString stringWithFormat:@"每次输入最多%@字~", @(CYLNotificationTextLengthOutLength)];
    [self showWaring:message];
}

- (void)showWaring:(NSString *)message {
    CYLAlertController *alert = [CYLAlertController alertControllerWithTitle:nil
                                                                       message:message
                                                                preferredStyle:CYLAlertControllerStyleAlert];
    NSString *cancelActionTitle = CYLLocalizedStrings(@"ok");
    CYLAlertAction *cancelAction = [CYLAlertAction actionWithTitle:cancelActionTitle style:CYLAlertActionStyleDefault
                                                             handler:^(CYLAlertAction * action) {}];
    [alert addAction:cancelAction];
    [alert showWithSender:nil controller:self animated:YES completion:NULL];
}

@end
