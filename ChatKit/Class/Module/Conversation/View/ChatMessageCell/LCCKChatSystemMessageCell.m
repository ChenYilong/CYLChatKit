//
//  LCCKChatSystemMessageCell.m
//  LCCKChatExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/leancloud/ChatKit-OC ) on 15/11/17.
//  Copyright © 2015年 https://LeanCloud.cn . All rights reserved.
//

#import "LCCKChatSystemMessageCell.h"
#import "UIColor+LCCKExtension.h"

@interface LCCKChatSystemMessageCell ()

@property (nonatomic, weak) UILabel *systemMessageLabel;
@property (nonatomic, strong) UIView *systemmessageContentView;
@property (nonatomic, strong, readonly) NSDictionary *systemMessageStyle;
@property (nonatomic, strong) UIColor *conversationViewTimeLineTextColor;
@property (nonatomic, strong) UIColor *conversationViewTimeLineBackgroundColor;

@end

@implementation LCCKChatSystemMessageCell
@synthesize systemMessageStyle = _systemMessageStyle;

#pragma mark - Override Methods

- (void)updateConstraints {
    [super updateConstraints];
    [self.systemmessageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = 8;
        make.top.equalTo(self.contentView.mas_top).with.offset(offset);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-offset);
        CGFloat width = [UIApplication sharedApplication].keyWindow.frame.size.width;
        CGFloat height = [UIApplication sharedApplication].keyWindow.frame.size.height;
        CGFloat widthLimit = MIN(width, height)/5 * 3;
        make.width.lessThanOrEqualTo(@(widthLimit));
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
}

#pragma mark - Public Methods

- (void)setup {
    self.conversationViewTimeLineTextColor = [UIColor CJ_16_Color:@"999999"];
    self.conversationViewTimeLineBackgroundColor =  [UIColor CJ_16_Color:@"E9E9E9"];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.systemmessageContentView];
    [self updateConstraintsIfNeeded];
    [super setup];
}

- (void)configureCellWithData:(LCCKMessage *)message {
    [super configureCellWithData:message];
    self.systemMessageLabel.attributedText = [[NSAttributedString alloc] initWithString:message.systemText attributes:self.systemMessageStyle];
}

#pragma mark - Getters

- (UIView *)systemmessageContentView {
    if (!_systemmessageContentView) {
        _systemmessageContentView = [[UIView alloc] init];
        _systemmessageContentView.backgroundColor = self.conversationViewTimeLineBackgroundColor ?: [UIColor lightGrayColor];
        _systemmessageContentView.alpha = 1.0f;
        _systemmessageContentView.layer.cornerRadius = 6.0f;
        _systemmessageContentView.translatesAutoresizingMaskIntoConstraints = NO;

        UILabel *systemMessageLabel = [[UILabel alloc] init];
        systemMessageLabel.numberOfLines = 0;
        systemMessageLabel.textColor = self.conversationViewTimeLineTextColor;
        [_systemmessageContentView addSubview:self.systemMessageLabel = systemMessageLabel];
        [systemMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            CGFloat offsetTopBottom = 8;//8
            CGFloat offsetLeftRight = 8;//8
            make.edges.equalTo(_systemmessageContentView).with.insets(UIEdgeInsetsMake(offsetTopBottom, offsetLeftRight, offsetTopBottom, offsetLeftRight));
        }];
    }
    return _systemmessageContentView;
}

- (NSDictionary *)systemMessageStyle {
    if (!_systemMessageStyle) {
        UIFont *font = [UIFont systemFontOfSize:14];
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.paragraphSpacing = 0.15 * font.lineHeight;
        style.hyphenationFactor = 1.0;
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentCenter;
        _systemMessageStyle = @{
                 NSFontAttributeName: font,
                 NSParagraphStyleAttributeName: style,
                 NSForegroundColorAttributeName: self.conversationViewTimeLineTextColor
                 };
    }
    return _systemMessageStyle;
}

#pragma mark -
#pragma mark - LCCKChatMessageCellSubclassing Method

+ (void)load {
    [self registerSubclass];
}

+ (AVIMMessageMediaType)classMediaType {
    return kAVIMMessageMediaTypeSystem;
}

- (UIColor *)conversationViewTimeLineTextColor {
    if (_conversationViewTimeLineTextColor) {
        return _conversationViewTimeLineTextColor;
    }
    _conversationViewTimeLineTextColor = [[LCCKSettingService sharedInstance] defaultThemeColorForKey:@"ConversationView-TimeLine-TextColor"];
    return _conversationViewTimeLineTextColor;
}

- (UIColor *)conversationViewTimeLineBackgroundColor {
    if (_conversationViewTimeLineBackgroundColor) {
        return _conversationViewTimeLineBackgroundColor;
    }
    _conversationViewTimeLineBackgroundColor = [[LCCKSettingService sharedInstance] defaultThemeColorForKey:@"ConversationView-TimeLine-BackgroundColor"];
    return _conversationViewTimeLineBackgroundColor;
}

@end
