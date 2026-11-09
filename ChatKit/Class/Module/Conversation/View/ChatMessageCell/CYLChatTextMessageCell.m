//
//  CYLChatTextMessageCell.m
//  CYLChatExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/13.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//


#import "CYLChatTextMessageCell.h"
#import "CYLFaceManager.h"
#import "CYLWebViewController.h"

@interface CYLChatTextMessageCell ()

/**
 *  用于显示文本消息的文字
 */
@property (nonatomic, strong) MLLinkLabel *messageTextLabel;
@property (nonatomic, copy, readonly) NSDictionary *textStyle;
@property (nonatomic, strong) NSArray *expressionData;
@property (nonatomic, strong) UIColor *conversationViewMessageLinkColorLeft; /**< 左侧消息中链接文字颜色，如果没有该项，则使用统一的消息链接文字颜色 */
@property (nonatomic, strong) UIColor *conversationViewMessageLinkColorRight; /**< 右侧消息中链接文字颜色，如果没有该项，则使用统一的消息链接文字颜色 */
@property (nonatomic, strong) UIColor *conversationViewMessageLinkColor; /**< 右侧消息中链接文字颜色，如果没有该项，则使用统一的消息链接文字颜色 */

//TODO:
//ConversationView-Message-Middle-TextColor: 居中文本消息文字颜色

@end

@implementation CYLChatTextMessageCell
@synthesize textStyle = _textStyle;

#pragma mark - Override Methods

- (void)updateConstraints {
    [super updateConstraints];
    UIEdgeInsets edgeMessageBubbleCustomize;
    if (self.messageOwner == CYLMessageOwnerTypeSelf) {
        UIEdgeInsets rightEdgeMessageBubbleCustomize = [CYLSettingService sharedInstance].rightEdgeMessageBubbleCustomize;
        edgeMessageBubbleCustomize = rightEdgeMessageBubbleCustomize;
    } else {
        UIEdgeInsets leftEdgeMessageBubbleCustomize = [CYLSettingService sharedInstance].leftEdgeMessageBubbleCustomize;
        edgeMessageBubbleCustomize = leftEdgeMessageBubbleCustomize;
    }
    [self.messageTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        // Related short-text bubble sizing report: https://github.com/leancloud/ChatKit-OC/issues/341
        make.edges.equalTo(self.messageContentView).with.insets(edgeMessageBubbleCustomize);
    }];
}

#pragma mark - Public Methods

- (void)setup {
    [self.messageContentView addSubview:self.messageTextLabel];
    UIColor *linkColor = [UIColor blueColor];
    if (self.messageOwner == CYLMessageOwnerTypeSelf) {
        self.messageTextLabel.textColor = self.conversationViewMessageRightTextColor;
        if (self.conversationViewMessageLinkColorRight) {
            linkColor = self.conversationViewMessageLinkColorRight;
        } else if (self.conversationViewMessageLinkColor) {
            linkColor = self.conversationViewMessageLinkColor;
        }
    } else {
        self.messageTextLabel.textColor = self.conversationViewMessageLeftTextColor;
        if (self.conversationViewMessageLinkColorLeft) {
            linkColor = self.conversationViewMessageLinkColorLeft;
        } else if (self.conversationViewMessageLinkColor) {
            linkColor = self.conversationViewMessageLinkColor;
        }
    }
    self.messageTextLabel.linkTextAttributes = @{ NSForegroundColorAttributeName : linkColor };
    self.messageTextLabel.activeLinkTextAttributes = @{
                                                       NSForegroundColorAttributeName : linkColor ,
                                                       NSBackgroundColorAttributeName : kDefaultActiveLinkBackgroundColorForMLLinkLabel
                                                       };
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapMessageContentViewGestureRecognizerHandle:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [self.messageContentView addGestureRecognizer:tapGestureRecognizer];
    [super setup];
    [self addGeneralView];
    
}

- (void)configureCellWithData:(CYLMessage *)message {
    [super configureCellWithData:message];
    NSMutableAttributedString *attrS = [CYLFaceManager emotionStrWithString:message.text];
    [attrS addAttributes:self.textStyle range:NSMakeRange(0, attrS.length)];
    self.messageTextLabel.attributedText = attrS;
}

#pragma mark - Getters

- (MLLinkLabel *)messageTextLabel {
    if (!_messageTextLabel) {
        _messageTextLabel = [[MLLinkLabel alloc] init];
        _messageTextLabel.font = [CYLSettingService sharedInstance].defaultThemeTextMessageFont;
        _messageTextLabel.numberOfLines = 0;
        _messageTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        __weak __typeof(self) weakSelf = self;
        [_messageTextLabel setDidClickLinkBlock:^(MLLink *link, NSString *linkText, MLLinkLabel *label) {
            if ([weakSelf.delegate respondsToSelector:@selector(messageCell:didTapLinkText:linkType:)]) {
                [weakSelf.delegate messageCell:weakSelf didTapLinkText:linkText linkType:link.linkType];
            }
        }];
    }
    return _messageTextLabel;
}

- (void)doubleTapMessageContentViewGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(textMessageCellDoubleTapped:)]) {
            [self.delegate textMessageCellDoubleTapped:self];
        }
    }
}

- (NSDictionary *)textStyle {
    if (!_textStyle) {
        UIFont *font = [CYLSettingService sharedInstance].defaultThemeTextMessageFont;
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.alignment = NSTextAlignmentLeft;
        style.paragraphSpacing = 0.25 * font.lineHeight;
        style.hyphenationFactor = 1.0;
        _textStyle = @{NSFontAttributeName: font,
                       NSParagraphStyleAttributeName: style};
    }
    return _textStyle;
}

#pragma mark -
#pragma mark - CYLChatMessageCellSubclassing Method

+ (void)load {
    [self registerSubclass];
}

+ (CYLMessageMediaType)classMediaType {
    return CYLMessageMediaTypeText;
} 

- (UIColor *)conversationViewMessageLinkColorLeft {
    if (_conversationViewMessageLinkColorLeft) {
        return _conversationViewMessageLinkColorLeft;
    }
    _conversationViewMessageLinkColorLeft = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"ConversationView-Message-LinkColor-Left"];
    return _conversationViewMessageLinkColorLeft;
}

- (UIColor *)conversationViewMessageLinkColorRight {
    if (_conversationViewMessageLinkColorRight) {
        return  _conversationViewMessageLinkColorRight;
    }
    _conversationViewMessageLinkColorRight = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"ConversationView-Message-LinkColor-Right"];
    return _conversationViewMessageLinkColorRight;
}

- (UIColor *)conversationViewMessageLinkColor {
    if (_conversationViewMessageLinkColor) {
        return _conversationViewMessageLinkColor;
    }
    _conversationViewMessageLinkColor = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"ConversationView-Message-LinkColor"];
    return _conversationViewMessageLinkColor;
}

@end
