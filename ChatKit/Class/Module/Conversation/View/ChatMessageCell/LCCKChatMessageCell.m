//
//  LCCKChatMessageCell.m
//  LCCKChatExample
//
//  Created by ElonChan ( https://github.com/leancloud/ChatKit-OC ) on 15/11/13.
//  Copyright © 2015年 https://LeanCloud.cn . All rights reserved.
//

#import "LCCKChatMessageCell.h"

#import "LCCKChatTextMessageCell.h"
#import "LCCKChatImageMessageCell.h"
#import "LCCKChatVoiceMessageCell.h"
#import "LCCKChatSystemMessageCell.h"
#import "LCCKChatLocationMessageCell.h"

#import "Masonry.h"
#import <objc/runtime.h>
#import "LCCKBubbleImageFactory.h"

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#else
#import "UIImageView+WebCache.h"
#endif

#import "LCChatKit.h"
#import "UIImageView+LCCKExtension.h"
#import "UIImage+LCCKExtension.h"

static CGFloat const kAvatarImageViewWidth = 50.f;
static CGFloat const kAvatarImageViewHeight = 50.f;

@interface LCCKChatMessageCell ()

@property (nonatomic, strong, readwrite) LCCKMessage *message;

@end

@implementation LCCKChatMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

// add support for LCCKMenuItem. Needs to be called once per class.
+ (void)load {
    [LCCKMenuItem installMenuHandlerForObject:self];
}

+ (void)initialize {
    [LCCKMenuItem installMenuHandlerForObject:self];
}

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

#pragma mark - Override Methods


- (void)updateConstraints {
    [super updateConstraints];
    if (self.messageOwner == LCCKMessageOwnerSystem || self.messageOwner == LCCKMessageOwnerUnknown) {
        return;
    }
    if (self.messageOwner == LCCKMessageOwnerSelf) {
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).with.offset(-16);
            make.top.equalTo(self.contentView.mas_top).with.offset(16);
            make.width.equalTo(@(kAvatarImageViewWidth));
            make.height.equalTo(@(kAvatarImageViewHeight));
        }];
        
        [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_top);
            make.right.equalTo(self.avatarImageView.mas_left).with.offset(-16);
            make.width.mas_lessThanOrEqualTo(@120);
            make.height.equalTo(self.messageChatType == LCCKConversationTypeGroup ? @16 : @0);
        }];
        
        [self.messageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.avatarImageView.mas_left).with.offset(-16);
            make.top.equalTo(self.nicknameLabel.mas_bottom).with.offset(4);
            make.width.lessThanOrEqualTo(@LCCKMessageCellLimit).priorityHigh();
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-16).priorityLow();
        }];
        
        [self.messageSendStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.messageContentView.mas_left).with.offset(-8);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
            make.width.equalTo(@20);
            make.height.equalTo(@20);
        }];
        
        [self.messageReadStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.messageContentView.mas_left).with.offset(-8);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
            make.width.equalTo(@10);
            make.height.equalTo(@10);
        }];
    } else if (self.messageOwner == LCCKMessageOwnerOther){
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).with.offset(16);
            make.top.equalTo(self.contentView.mas_top).with.offset(16);
            make.width.equalTo(@(kAvatarImageViewWidth));
            make.height.equalTo(@(kAvatarImageViewHeight));
        }];
        
        [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_top);
            make.left.equalTo(self.avatarImageView.mas_right).with.offset(16);
            make.width.mas_lessThanOrEqualTo(@120);
            make.height.equalTo(self.messageChatType == LCCKConversationTypeGroup ? @16 : @0);
        }];
        
        [self.messageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImageView.mas_right).with.offset(16);
            make.top.equalTo(self.nicknameLabel.mas_bottom).with.offset(4);
            make.width.lessThanOrEqualTo(@LCCKMessageCellLimit).priorityHigh();
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-16).priorityLow();
        }];
        
        [self.messageSendStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.messageContentView.mas_right).with.offset(8);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
            make.width.equalTo(@20);
            make.height.equalTo(@20);
        }];
        
        [self.messageReadStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.messageContentView.mas_right).with.offset(8);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
            make.width.equalTo(@10);
            make.height.equalTo(@10);
        }];
    }
    [self.messageContentBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.messageContentView);
    }];
    
    if (self.messageChatType == LCCKConversationTypeSingle) {
        [self.nicknameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@0);
        }];
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

- (void)setup {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.nicknameLabel];
    [self.contentView addSubview:self.messageContentView];
    [self.contentView addSubview:self.messageReadStateImageView];
    [self.contentView addSubview:self.messageSendStateImageView];
    
    self.messageSendStateImageView.hidden = YES;
    self.messageReadStateImageView.hidden = YES;
    
    [self.messageContentBackgroundImageView setImage:[LCCKBubbleImageFactory bubbleImageViewForType:self.messageOwner messageType:self.messageType isHighlighted:NO]];
    [self.messageContentBackgroundImageView setHighlightedImage:[LCCKBubbleImageFactory bubbleImageViewForType:self.messageOwner messageType:self.messageType isHighlighted:YES]];
    
    self.messageContentView.layer.mask.contents = (__bridge id _Nullable)(self.messageContentBackgroundImageView.image.CGImage);
    [self.contentView insertSubview:self.messageContentBackgroundImageView belowSubview:self.messageContentView];
    
    [self updateConstraintsIfNeeded];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.contentView addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [recognizer setMinimumPressDuration:0.4f];
    [self addGestureRecognizer:recognizer];
    
}

#pragma mark - Public Methods

- (void)configureCellWithData:(LCCKMessage *)message {
    self.message = message;
    self.nicknameLabel.text = self.message.sender;
    [self.avatarImageView sd_setImageWithURL:self.message.avatorURL
                            placeholderImage:({
        NSString *imageName = @"Placeholder_Avator";
        UIImage *image = [UIImage lcck_imageNamed:imageName bundleName:@"Placeholder" bundleForClass:[self class]];
        image;})
     ];
    if (message.messageReadState) {
        self.messageReadState = self.message.messageReadState;
    }
    self.messageSendState = self.message.status;
}

#pragma mark - Private Methods

- (void)handleTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint tapPoint = [tap locationInView:self.contentView];
        if (CGRectContainsPoint(self.messageContentView.frame, tapPoint)) {
            [self.delegate messageCellTappedMessage:self];
        }  else if (CGRectContainsPoint(self.avatarImageView.frame, tapPoint)) {
            [self.delegate messageCellTappedHead:self];
        } else {
            [self.delegate messageCellTappedBlank:self];
        }
    }
}

#pragma mark - Setters

- (void)setMessageSendState:(LCCKMessageSendState)messageSendState {
    _messageSendState = messageSendState;
    if (self.messageOwner == LCCKMessageOwnerOther) {
        self.messageSendStateImageView.hidden = YES;
    }
    self.messageSendStateImageView.messageSendState = messageSendState;
}

- (void)setMessageReadState:(LCCKMessageReadState)messageReadState {
    _messageReadState = messageReadState;
    if (self.messageOwner == LCCKMessageOwnerSelf) {
        self.messageSendStateImageView.hidden = YES;
    }
    switch (_messageReadState) {
            case LCCKMessageUnRead:
            self.messageReadStateImageView.hidden = NO;
            break;
        default:
            self.messageReadStateImageView.hidden = YES;
            break;
    }
}

#pragma mark - Getters

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        LCCKAvatarImageViewCornerRadiusBlock avatarImageViewCornerRadiusBlock = [LCChatKit sharedInstance].avatarImageViewCornerRadiusBlock;
        if (avatarImageViewCornerRadiusBlock) {
            CGSize avatarImageViewSize = CGSizeMake(kAvatarImageViewWidth, kAvatarImageViewHeight);
            CGFloat avatarImageViewCornerRadius = avatarImageViewCornerRadiusBlock(avatarImageViewSize);
            [_avatarImageView lcck_cornerRadiusAdvance:avatarImageViewCornerRadius rectCornerType:UIRectCornerAllCorners];
        }
        [self bringSubviewToFront:_avatarImageView];
    }
    return _avatarImageView;
}

- (UILabel *)nicknameLabel {
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc] init];
        _nicknameLabel.font = [UIFont systemFontOfSize:12.0f];
        _nicknameLabel.textColor = [UIColor blackColor];
        _nicknameLabel.text = @"nickname";
    }
    return _nicknameLabel;
}

- (LCCKContentView *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [[LCCKContentView alloc] init];
    }
    return _messageContentView;
}

- (UIImageView *)messageReadStateImageView {
    if (!_messageReadStateImageView) {
        _messageReadStateImageView = [[UIImageView alloc] init];
    }
    return _messageReadStateImageView;
}

- (LCCKSendImageView *)messageSendStateImageView {
    if (!_messageSendStateImageView) {
        _messageSendStateImageView = [[LCCKSendImageView alloc] init];
    }
    return _messageSendStateImageView;
}

- (UIImageView *)messageContentBackgroundImageView {
    if (!_messageContentBackgroundImageView) {
        _messageContentBackgroundImageView = [[UIImageView alloc] init];
    }
    return _messageContentBackgroundImageView;
}

- (LCCKMessageType)messageType {
    if ([self isKindOfClass:[LCCKChatTextMessageCell class]]) {
        return LCCKMessageTypeText;
    } else if ([self isKindOfClass:[LCCKChatImageMessageCell class]]) {
        return LCCKMessageTypeImage;
    } else if ([self isKindOfClass:[LCCKChatVoiceMessageCell class]]) {
        return LCCKMessageTypeVoice;
    } else if ([self isKindOfClass:[LCCKChatLocationMessageCell class]]) {
        return LCCKMessageTypeLocation;
    } else if ([self isKindOfClass:[LCCKChatSystemMessageCell class]]) {
        return LCCKMessageTypeSystem;
    }
    return LCCKMessageTypeUnknow;
}

- (LCCKConversationType)messageChatType {
    if ([self.reuseIdentifier containsString:@"GroupCell"]) {
        return LCCKConversationTypeGroup;
    }
    return LCCKConversationTypeSingle;
}

- (LCCKMessageOwner)messageOwner {
    if ([self.reuseIdentifier containsString:@"OwnerSelf"]) {
        return LCCKMessageOwnerSelf;
    } else if ([self.reuseIdentifier containsString:@"OwnerOther"]) {
        return LCCKMessageOwnerOther;
    } else if ([self.reuseIdentifier containsString:@"OwnerSystem"]) {
        return LCCKMessageOwnerSystem;
    }
    return LCCKMessageOwnerUnknown;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGes {
    if (longPressGes.state == UIGestureRecognizerStateBegan) {
        CGPoint longPressPoint = [longPressGes locationInView:self.contentView];
        if (!CGRectContainsPoint(self.messageContentView.frame, longPressPoint)) {
            return;
        }
        [self becomeFirstResponder];
        LCCKLongPressMessageBlock longPressMessageBlock = [LCChatKit sharedInstance].longPressMessageBlock;
        NSArray *menuItems = [NSArray array];
        NSDictionary *userInfo = @{
                                   LCCKLongPressMessageUserInfoKeyFromController : self,
                                   LCCKLongPressMessageUserInfoKeyFromView : self.tableView,
                                   };
        if (longPressMessageBlock) {
            menuItems = longPressMessageBlock(self.message, userInfo);
        } else {
            LCCKMenuItem *copyItem = [[LCCKMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"copy", @"LCChatKitString", @"复制文本消息")
                                                               block:^{
                                                                   UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                                                   [pasteboard setString:[self.message text]];
                                                               }];
            //TODO:添加“转发”
            if (self.messageType == LCCKMessageTypeText) {
                menuItems = @[ copyItem ];
            }
        }
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setMenuItems:menuItems];
        [menuController setArrowDirection:UIMenuControllerArrowDown];
        UITableView *tableView = self.tableView;
        CGRect targetRect = [self convertRect:self.messageContentView.frame toView:tableView];
        [menuController setTargetRect:targetRect inView:tableView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMenuWillShowNotification:)
                                                     name:UIMenuControllerWillShowMenuNotification
                                                   object:nil];
        [menuController setMenuVisible:YES animated:YES];
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

@end

