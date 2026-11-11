//
//  CYLChatMessageCell.m
//  CYLChatExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/13.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import "CYLChatMessageCell.h"

#import "CYLChatTextMessageCell.h"
#import "CYLChatImageMessageCell.h"
#import "CYLChatVoiceMessageCell.h"
#import "CYLChatSystemMessageCell.h"
#import "CYLChatLocationMessageCell.h"

#import <objc/runtime.h>
#import "CYLBubbleImageFactory.h"

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#else
#import "UIImageView+WebCache.h"
#endif

#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

#import "UIImageView+CYLExtension.h"
#import "UIImage+CYLExtension.h"
#import "NSObject+CYLExtension.h"
#import "CYLChatConstants.h"

NSMutableDictionary const *CYLChatMessageCellMediaTypeDict = nil;

static CGFloat const kAvatarImageViewWidth = 50.f;
static CGFloat const kAvatarImageViewHeight = kAvatarImageViewWidth;
static CGFloat const CYLMessageSendStateViewWidthHeight = 30.f;
static CGFloat const CYLMessageSendStateViewLeftOrRightToMessageContentView = 2.f;

static CGFloat const CYL_MSG_CELL_NICKNAME_HEIGHT = 16;
static CGFloat const CYL_MSG_CELL_NICKNAME_FONT_SIZE = 12;

@interface CYLChatMessageCell ()<CYLSendImageViewDelegate>

//@property (nonatomic, strong, readwrite) CYLMessage *message;
@property (nonatomic, assign, readwrite) CYLMessageMediaType mediaType;
@property (nonatomic, strong) UIColor *conversationViewSenderNameTextColor;

@end

@implementation CYLChatMessageCell

+ (void)registerCustomMessageCell {
    [self registerSubclass];
}

+ (void)registerSubclass {
    if ([self conformsToProtocol:@protocol(CYLChatMessageCellSubclassing)]) {
        Class<CYLChatMessageCellSubclassing> class = self;
        CYLMessageMediaType mediaType = [class classMediaType];
        [self registerClass:class forMediaType:mediaType];
    }
}

+ (Class)classForMediaType:(CYLMessageMediaType)mediaType {
    NSNumber *key = [NSNumber numberWithInteger:mediaType];
    Class class = [CYLChatMessageCellMediaTypeDict objectForKey:key];
    if (!class) {
        class = self;
    }
    return class;
}

+ (void)registerClass:(Class)class forMediaType:(CYLMessageMediaType)mediaType {
    if (!CYLChatMessageCellMediaTypeDict) {
        CYLChatMessageCellMediaTypeDict = [[NSMutableDictionary alloc] init];
    }
    NSNumber *key = [NSNumber numberWithInteger:mediaType];
    Class c = [CYLChatMessageCellMediaTypeDict objectForKey:key];
    if (!c || [class isSubclassOfClass:c]) {
        [CYLChatMessageCellMediaTypeDict setObject:class forKey:key];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

// add support for CYLMenuItem. Needs to be called once per class.
+ (void)load {
    [CYLMenuItem installMenuHandlerForObject:self];
}

+ (void)initialize {
    [CYLMenuItem installMenuHandlerForObject:self];
}

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

#pragma mark - Override Methods

- (BOOL)showName {
    BOOL isMessageOwner = self.messageOwner == CYLMessageOwnerTypeOther;
    BOOL isMessageChatTypeGroup = self.messageChatType == CYLConversationTypeGroup;
    if (isMessageOwner && isMessageChatTypeGroup) {
        self.nickNameLabel.hidden = NO;
        return YES;
    }
    self.nickNameLabel.hidden = YES;
    return NO;
}

- (void)updateConstraints {
    [super updateConstraints];
    if (self.messageOwner == CYLMessageOwnerTypeSystem || self.messageOwner == CYLMessageOwnerTypeUnknown) {
        return;
    }
    if (self.messageOwner == CYLMessageOwnerTypeSelf) {
        if (self.avatarImageView.superview) {
            [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.contentView.mas_right).with.offset(-CYL_MSG_CELL_EDGES_OFFSET);
                make.top.equalTo(self.contentView.mas_top).with.offset(CYL_MSG_CELL_EDGES_OFFSET);
                make.width.equalTo(@(kAvatarImageViewWidth));
                make.height.equalTo(@(kAvatarImageViewHeight));
            }];
        }
        if (self.nickNameLabel.superview) {
            [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.avatarImageView.mas_top);
                make.right.equalTo(self.avatarImageView.mas_left).with.offset(-CYL_MSG_CELL_EDGES_OFFSET);
                make.width.mas_lessThanOrEqualTo(@120);
                make.height.equalTo(@0);
            }];
        }
        if (self.messageContentView.superview) {
            [self.messageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.avatarImageView.mas_left).with.offset(-CYLAvatarToMessageContent);
                make.top.equalTo(self.nickNameLabel.mas_bottom).with.offset(self.showName ? 0 : CYLAvatarBottomToMessageContentTop);
                CGFloat width = [UIApplication sharedApplication].keyWindow.frame.size.width;
                CGFloat height = [UIApplication sharedApplication].keyWindow.frame.size.height;
                CGFloat widthLimit = MIN(width, height)/5 * 3;
                make.width.lessThanOrEqualTo(@(widthLimit)).priorityHigh();
                make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-CYL_MSG_CELL_EDGES_OFFSET).priorityLow();
            }];
        }
        if (self.messageSendStateView.superview) {
            [self.messageSendStateView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.messageContentView.mas_left).with.offset(-CYLMessageSendStateViewLeftOrRightToMessageContentView);
                make.centerY.equalTo(self.messageContentView.mas_centerY);
                make.width.equalTo(@(CYLMessageSendStateViewWidthHeight));
                make.height.equalTo(@(CYLMessageSendStateViewWidthHeight));
            }];
        }
        if (self.messageReadStateImageView.superview) {
            [self.messageReadStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.messageContentView.mas_left).with.offset(-8);
                make.centerY.equalTo(self.messageContentView.mas_centerY);
                make.width.equalTo(@10);
                make.height.equalTo(@10);
            }];
        }
    } else if (self.messageOwner == CYLMessageOwnerTypeOther){
        if (self.avatarImageView.superview) {
            [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView.mas_left).with.offset(CYL_MSG_CELL_EDGES_OFFSET);
                make.top.equalTo(self.contentView.mas_top).with.offset(CYL_MSG_CELL_EDGES_OFFSET);
                make.width.equalTo(@(kAvatarImageViewWidth));
                make.height.equalTo(@(kAvatarImageViewHeight));
            }];
        }
        if (self.nickNameLabel.superview) {
            [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.avatarImageView.mas_top);
                make.left.equalTo(self.avatarImageView.mas_right).with.offset(CYL_MSG_CELL_EDGES_OFFSET);
                make.width.mas_lessThanOrEqualTo(@120);
                make.height.equalTo(self.messageChatType == CYLConversationTypeGroup ? @(CYL_MSG_CELL_NICKNAME_HEIGHT) : @0);
            }];
        }
        if (self.messageContentView.superview) {
            [self.messageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.avatarImageView.mas_right).with.offset(CYLAvatarToMessageContent);
                make.top.equalTo(self.nickNameLabel.mas_bottom).with.offset(self.showName ? 0 : CYLAvatarBottomToMessageContentTop);
                CGFloat width = [UIApplication sharedApplication].keyWindow.frame.size.width;
                CGFloat height = [UIApplication sharedApplication].keyWindow.frame.size.height;
                CGFloat widthLimit = MIN(width, height)/5 * 3;
                make.width.lessThanOrEqualTo(@(widthLimit)).priorityHigh();
                make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-CYL_MSG_CELL_EDGES_OFFSET).priorityLow();
            }];
        }
        if (self.messageSendStateView.superview) {
            [self.messageSendStateView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.messageContentView.mas_right).with.offset(CYLMessageSendStateViewLeftOrRightToMessageContentView);
                make.centerY.equalTo(self.messageContentView.mas_centerY);
                make.width.equalTo(@(CYLMessageSendStateViewWidthHeight));
                make.height.equalTo(@(CYLMessageSendStateViewWidthHeight));
            }];
        }
        if (self.messageReadStateImageView.superview) {
            [self.messageReadStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.messageContentView.mas_right).with.offset(8);
                make.centerY.equalTo(self.messageContentView.mas_centerY);
                make.width.equalTo(@10);
                make.height.equalTo(@10);
            }];
        }
    }
    
    if (self.messageContentBackgroundImageView.superview) {
        [self.messageContentBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.messageContentView);
        }];
    }
    
    if (!self.showName) {
        if (self.nickNameLabel.superview) {
            [self.nickNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@0);
            }];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint touchPoint = [[touches anyObject] locationInView:self.contentView];
    if (CGRectContainsPoint(self.messageContentView.frame, touchPoint)) {
        self.messageContentBackgroundImageView.highlighted = YES;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.messageContentBackgroundImageView.highlighted = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.messageContentBackgroundImageView.highlighted = NO;
}

#pragma mark - Private Methods

- (BOOL)isAbleToTap {
    BOOL isAbleToTap = NO;
    //For Link handle
    if (self.mediaType < 0) {
        isAbleToTap = YES;
    }
    return isAbleToTap;
}
- (UIImageView *)messageContentBackgroundImageView {
    if (!_messageContentBackgroundImageView) {
        _messageContentBackgroundImageView = [[UIImageView alloc] init];
    }
    return _messageContentBackgroundImageView;
}

- (void)addGeneralView {
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.nickNameLabel];
    [self.contentView addSubview:self.messageContentView];
    [self.contentView addSubview:self.messageReadStateImageView];
    [self.contentView addSubview:self.messageSendStateView];
    
    
    [self.messageContentBackgroundImageView setImage:[CYLBubbleImageFactory bubbleImageViewForType:self.messageOwner messageType:self.mediaType isHighlighted:NO]];
    [self.messageContentBackgroundImageView setHighlightedImage:[CYLBubbleImageFactory bubbleImageViewForType:self.messageOwner messageType:self.mediaType isHighlighted:YES]];
    
    self.messageContentView.layer.mask.contents = (__bridge id _Nullable)(self.messageContentBackgroundImageView.image.CGImage);
    [self.contentView insertSubview:self.messageContentBackgroundImageView belowSubview:self.messageContentView];
    [self updateConstraintsIfNeeded];
    
    self.messageSendStateView.hidden = YES;
    self.messageReadStateImageView.hidden = YES;

    if (self.isAbleToTap) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.delegate = self;
        tap.numberOfTapsRequired = 1;
        [self.contentView addGestureRecognizer:tap];
    }
    
    UITapGestureRecognizer *avatarImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewHandleTap:)];
    self.avatarImageView.userInteractionEnabled = YES;
    [self.avatarImageView addGestureRecognizer:avatarImageViewTap];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [recognizer setMinimumPressDuration:0.4f];
    [self addGestureRecognizer:recognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint tapPoint = [gestureRecognizer locationInView:self.contentView];
    if (CGRectContainsPoint(self.avatarImageView.frame, tapPoint)) {
        return NO;
    } else if(CGRectContainsPoint(self.messageContentView.frame, tapPoint) && [self isKindOfClass:[CYLChatTextMessageCell class]]) {
        return NO;
    }
    return YES;
}

- (void)setup {
    if (![self conformsToProtocol:@protocol(CYLChatMessageCellSubclassing)]) {
        //TODO: add debug model
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), [NSString stringWithFormat:@"%@%@", @"CYLChatMessageCellNotSubclassException", @"Class does not conform CYLChatMessageCellSubclassing protocol."]);
        return;
    }
    self.mediaType = [[self class] classMediaType];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];;
}

#pragma mark - Public Methods

- (void)configureCellWithData:(id)message {
    NSString *nickName = nil;
    NSURL *avatarURL = nil;
    NSInteger userType = 0;
    CYLMessageSendState sendStatus;
    if ([message cyl_isCustomMessage]) {
        NSString *senderClientId = [(id<CYLIMMessageProtocol>)message cyl_senderId];
        NSError *error;
        //TODO:如果我正在群里聊天，这时有人进入群聊，需要异步获取头像等信息，模仿ConversationList的做法。
        [[CYLUserSystemService sharedInstance] getCachedProfileIfExists:senderClientId name:&nickName avatarURL:&avatarURL userTye:&userType error:&error];
        if (!nickName)  { nickName = senderClientId; }
        self.message = nil;
        sendStatus = [(id<CYLIMMessageProtocol>)message cyl_sendStatus];
    } else {
        self.message = message;
        nickName = self.message.localDisplayName;
        avatarURL = self.message.sender.avatarURL;
        sendStatus = self.message.sendStatus;
        userType = self.message.userType;
        //FIXME: SDK 暂不支持已读未读
        //        if ([(CYLMessage *)message messageReadState]) {
        //            self.messageReadState = self.message.messageReadState;
        //        }
    }
    self.nickNameLabel.text = nickName;
    [self.avatarImageView sd_setImageWithURL:avatarURL
                            placeholderImage:({
        NSString *imageName = @"Placeholder_Avatar";
        UIImage *image = [UIImage cyl_imageNamed:imageName bundleName:@"Placeholder" bundleForClass:[self class]];
        image;})
     ];
    if (userType == 1) {
        self.officialSignImageView.hidden = NO;
    } else {
        self.officialSignImageView.hidden = YES;
    }
    self.messageSendState = sendStatus;
}

#pragma mark - Private Methods

- (void)handleTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint tapPoint = [tap locationInView:self.contentView];
        if (CGRectContainsPoint(self.messageContentView.frame, tapPoint)) {
            [self.delegate messageCellTappedMessage:self];
            return;
        }
        [self.delegate messageCellTappedBlank:self];
    }
}

- (void)avatarImageViewHandleTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        [self.delegate messageCellTappedHead:self];
    }
}

#pragma mark - Setters

- (void)setMessageSendState:(CYLMessageSendState)messageSendState {
    _messageSendState = messageSendState;
    if (self.messageOwner == CYLMessageOwnerTypeOther) {
        self.messageSendStateView.hidden = YES;
    }
    self.messageSendStateView.messageSendState = messageSendState;
}

- (void)setMessageReadState:(CYLMessageReadState)messageReadState {
    _messageReadState = messageReadState;
    if (self.messageOwner == CYLMessageOwnerTypeSelf) {
        self.messageSendStateView.hidden = YES;
    }
    switch (_messageReadState) {
            case CYLMessageUnRead:
            self.messageReadStateImageView.hidden = NO;
            break;
        default:
            self.messageReadStateImageView.hidden = YES;
            break;
    }
}

#pragma mark - Getters
- (UIImageView *)officialSignImageView {
    if (!_officialSignImageView) {
        UIImageView *officialSignImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 12.5)];
        [officialSignImageView sd_setImageWithURL:[NSURL URLWithString:@"https://hdl-middletier-prd.oss-cn-beijing.aliyuncs.com/app-img/v2/my/my_official.png"]];
        _officialSignImageView = officialSignImageView;
        _officialSignImageView.hidden = YES;
    }
    return _officialSignImageView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;//防止特别长或者宽的图片显示不正常
        CYLAvatarImageViewCornerRadiusBlock avatarImageViewCornerRadiusBlock = [LCChatKit sharedInstance].avatarImageViewCornerRadiusBlock;
        if (avatarImageViewCornerRadiusBlock) {
            CGSize avatarImageViewSize = CGSizeMake(kAvatarImageViewWidth, kAvatarImageViewHeight);
            // Set bounds before applying the configured corner radius to prevent first-layout clipping failures: https://github.com/leancloud/ChatKit-OC/issues/347
            // This also addresses the reported conversation-avatar refresh behavior: https://github.com/leancloud/ChatKit-OC/issues/348
            // Avatar sizing and aspect-fill behavior: https://github.com/ChenYilong/CYLChatKit/issues/4
            _avatarImageView.frame = CGRectMake(0, 0, kAvatarImageViewWidth, kAvatarImageViewHeight);
            CGFloat avatarImageViewCornerRadius = avatarImageViewCornerRadiusBlock(avatarImageViewSize);
            _avatarImageView.cyl_cornerRadius = avatarImageViewCornerRadius;
           [_avatarImageView addSubview:self.officialSignImageView];
        }
        [self bringSubviewToFront:_avatarImageView];
        
    }
    return _avatarImageView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = [UIFont systemFontOfSize:CYL_MSG_CELL_NICKNAME_FONT_SIZE];
        _nickNameLabel.textColor = self.conversationViewSenderNameTextColor;
        _nickNameLabel.text = @"nickname";
        [_nickNameLabel sizeToFit];
    }
    return _nickNameLabel;
}

- (CYLContentView *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [[CYLContentView alloc] init];
    }
    return _messageContentView;
}

- (UIImageView *)messageReadStateImageView {
    if (!_messageReadStateImageView) {
        _messageReadStateImageView = [[UIImageView alloc] initWithImage:({
            NSString *imageName = @"VoiceMessage_Unread";
            UIImage *image = [UIImage cyl_imageNamed:imageName bundleName:@"MessageBubble" bundleForClass:[self class]];
            image;})];
    }
    return _messageReadStateImageView;
}

- (CYLMessageSendStateView *)messageSendStateView {
    if (!_messageSendStateView) {
        _messageSendStateView = [[CYLMessageSendStateView alloc] init];
        _messageSendStateView.delegate = self;
    }
    return _messageSendStateView;
}

- (CYLConversationType)messageChatType {
    if ([self.reuseIdentifier cyl_containsString:CYLCellIdentifierGroup]) {
        return CYLConversationTypeGroup;
    }
    return CYLConversationTypeSingle;
}

- (CYLMessageOwnerType)messageOwner {
    if ([self.reuseIdentifier cyl_containsString:CYLCellIdentifierOwnerSelf]) {
        return CYLMessageOwnerTypeSelf;
    } else if ([self.reuseIdentifier cyl_containsString:CYLCellIdentifierOwnerOther]) {
        return CYLMessageOwnerTypeOther;
    } else if ([self.reuseIdentifier cyl_containsString:CYLCellIdentifierOwnerSystem]) {
        return CYLMessageOwnerTypeSystem;
    }
    return CYLMessageOwnerTypeUnknown;
}


- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGes {
    if (longPressGes.state == UIGestureRecognizerStateBegan) {
        CGPoint longPressPoint = [longPressGes locationInView:self.contentView];
        if (!CGRectContainsPoint(self.messageContentView.frame, longPressPoint)) {
            if (CGRectContainsPoint(self.avatarImageView.frame, longPressPoint)) {
                if ([self.delegate respondsToSelector:@selector(avatarImageViewLongPressed:)]) {
                    [self.delegate avatarImageViewLongPressed:self];
                }
            }
            return;
        }
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        NSUInteger delaySeconds = CYLAnimateDuration;
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC));
        dispatch_after(when, dispatch_get_main_queue(), ^{
            [self becomeFirstResponder];
            CYLLongPressMessageBlock longPressMessageBlock = [LCChatKit sharedInstance].longPressMessageBlock;
            NSDictionary *userInfo = @{ CYLLongPressMessageUserInfoKeyFromController: self.delegate,
                                        CYLLongPressMessageUserInfoKeyFromView: self.tableView,
                                        CYLLongPressMessageUserInfoKeyMessageOwner: @(self.messageOwner),
                                        CYLLongPressMessageUserInfoKeyMessageCell: self };
            NSArray *menuItems = [NSArray array];
            if (longPressMessageBlock) {
                menuItems = longPressMessageBlock(self.message, userInfo);
            } else {
                CYLMenuItem *copyItem = [[CYLMenuItem alloc] initWithTitle:CYLLocalizedStrings(@"copy") block:^{
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    [pasteboard setString:[self.message text]];
                }];
                if (self.mediaType == CYLMessageMediaTypeText) {
                    menuItems = @[copyItem];
                }
            }
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            [menuController setMenuItems:menuItems];
            [menuController setArrowDirection:UIMenuControllerArrowDown];
            UITableView *tableView = self.tableView;
            CGRect targetRect = [self convertRect:self.messageContentView.frame toView:tableView];
            [menuController setTargetRect:targetRect inView:tableView];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuWillShowNotification:) name:UIMenuControllerWillShowMenuNotification object:nil];
            [menuController setMenuVisible:YES animated:YES];
        });
    }
}

#pragma mark - Notifications

- (void)handleMenuWillHideNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
}

- (void)handleMenuWillShowNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillHideNotification:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
}

#pragma mark -
#pragma mark - CYLSendImageViewDelegate Method

- (void)resendMessage:(id)sender {
    if ([self.delegate respondsToSelector:@selector(resendMessage:)]) {
        [self.delegate resendMessage:self];
    }
}

- (UIColor *)conversationViewSenderNameTextColor {
    if (_conversationViewSenderNameTextColor) {
        return _conversationViewSenderNameTextColor;
    }
    _conversationViewSenderNameTextColor = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"ConversationView-SenderName-TextColor"];
    return _conversationViewSenderNameTextColor;
}

- (UIColor *)conversationViewMessageRightTextColor {
    if (_conversationViewMessageRightTextColor) {
        return _conversationViewMessageRightTextColor;
    }
    _conversationViewMessageRightTextColor = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"ConversationView-Message-Right-TextColor"];
    return _conversationViewMessageRightTextColor;
}

- (UIColor *)conversationViewMessageLeftTextColor {
    if (_conversationViewMessageLeftTextColor) {
        return _conversationViewMessageLeftTextColor;
    }
    _conversationViewMessageLeftTextColor = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"ConversationView-Message-Left-TextColor"];
    return _conversationViewMessageLeftTextColor;
}

#pragma mark - Accessibility

// One message row is one VoiceOver element (AGENTS.md, "Accessibility"; docs/accessibility.md): who sent it, what it
// says, and whether it was delivered, in one label, instead of a dozen stops on avatar, name, bubble, and state icons.
// The text comes from CYLLocalizedStrings, so it follows the app's language.

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    CYLMessage *message = self.message;
    if (!message) {
        return nil;
    }
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    NSString *sender = nil;
    if (self.messageOwner == CYLMessageOwnerTypeSelf) {
        sender = CYLLocalizedStrings(@"message.you");
    } else if (self.messageOwner == CYLMessageOwnerTypeOther) {
        sender = self.nickNameLabel.text.length > 0 ? self.nickNameLabel.text : message.localDisplayName;
    }
    if (sender.length > 0) {
        [parts addObject:sender];
    }
    NSString *content = nil;
    switch (self.mediaType) {
        case CYLMessageMediaTypeImage:
            content = CYLLocalizedStrings(@"message.image");
            break;
        case CYLMessageMediaTypeAudio:
            content = [NSString stringWithFormat:CYLLocalizedStrings(@"message.voice"), message.voiceDuration ?: @"0"];
            break;
        case CYLMessageMediaTypeVideo:
            content = CYLLocalizedStrings(@"message.video");
            break;
        case CYLMessageMediaTypeLocation:
            content = [NSString stringWithFormat:CYLLocalizedStrings(@"message.location"), message.geolocations ?: @""];
            break;
        case CYLMessageMediaTypeFile:
            content = CYLLocalizedStrings(@"message.file");
            break;
        case CYLMessageMediaTypeSystem:
        case CYLMessageMediaTypeRecalled:
            content = message.systemText.length > 0 ? message.systemText : message.text;
            break;
        default:
            content = message.text;
            break;
    }
    if (content.length > 0) {
        [parts addObject:content];
    }
    if (self.messageSendState == CYLMessageSendStateSending) {
        [parts addObject:CYLLocalizedStrings(@"message.status.sending")];
    } else if (self.messageSendState == CYLMessageSendStateFailed) {
        [parts addObject:CYLLocalizedStrings(@"message.status.failed")];
    } else if (self.messageOwner == CYLMessageOwnerTypeSelf && self.messageReadState == CYLMessageReaded) {
        [parts addObject:CYLLocalizedStrings(@"message.status.read")];
    }
    return [parts componentsJoinedByString:@", "];
}

- (NSString *)accessibilityHint {
    switch (self.mediaType) {
        case CYLMessageMediaTypeAudio:
            return CYLLocalizedStrings(@"message.hint.play");
        case CYLMessageMediaTypeImage:
        case CYLMessageMediaTypeVideo:
        case CYLMessageMediaTypeLocation:
        case CYLMessageMediaTypeFile:
            return CYLLocalizedStrings(@"message.hint.open");
        default:
            return nil;
    }
}

- (UIAccessibilityTraits)accessibilityTraits {
    switch (self.mediaType) {
        case CYLMessageMediaTypeText:
        case CYLMessageMediaTypeSystem:
        case CYLMessageMediaTypeRecalled:
            return UIAccessibilityTraitStaticText;
        default:
            return UIAccessibilityTraitButton;
    }
}

/// The same as tapping the bubble: play the voice message, open the image, the location, and so on.
- (BOOL)accessibilityActivate {
    if ([self.delegate respondsToSelector:@selector(messageCellTappedMessage:)]) {
        [self.delegate messageCellTappedMessage:self];
        return YES;
    }
    return NO;
}

/// What a tap on the avatar or on the failure icon does, as VoiceOver actions.
- (NSArray<UIAccessibilityCustomAction *> *)accessibilityCustomActions {
    __weak typeof(self) weakSelf = self;
    NSMutableArray<UIAccessibilityCustomAction *> *actions = [NSMutableArray array];
    if (self.messageSendState == CYLMessageSendStateFailed) {
        [actions addObject:[[UIAccessibilityCustomAction alloc] initWithName:CYLLocalizedStrings(@"message.action.resend") actionHandler:^BOOL(UIAccessibilityCustomAction *action) {
            if ([weakSelf.delegate respondsToSelector:@selector(resendMessage:)]) {
                [weakSelf.delegate resendMessage:weakSelf];
                return YES;
            }
            return NO;
        }]];
    }
    if (self.messageOwner == CYLMessageOwnerTypeOther) {
        [actions addObject:[[UIAccessibilityCustomAction alloc] initWithName:CYLLocalizedStrings(@"message.action.profile") actionHandler:^BOOL(UIAccessibilityCustomAction *action) {
            if ([weakSelf.delegate respondsToSelector:@selector(messageCellTappedHead:)]) {
                [weakSelf.delegate messageCellTappedHead:weakSelf];
                return YES;
            }
            return NO;
        }]];
    }
    return actions;
}

@end
