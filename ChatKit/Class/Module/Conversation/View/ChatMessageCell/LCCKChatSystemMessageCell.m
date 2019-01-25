//
//  LCCKChatSystemMessageCell.m
//  LCCKChatExample
//
//  Created by ElonChan ( https://github.com/leancloud/ChatKit-OC ) on 15/11/17.
//  Copyright © 2015年 https://LeanCloud.cn . All rights reserved.
//

#import "LCCKChatSystemMessageCell.h"

#import "Masonry.h"

@interface LCCKChatSystemMessageCell ()

@property (nonatomic, weak) UILabel *systemMessageLabel;
@property (nonatomic, strong) UIView *systemmessageContentView;
@property (nonatomic, strong, readonly) NSDictionary *systemMessageStyle;

@end

@implementation LCCKChatSystemMessageCell
@synthesize systemMessageStyle = _systemMessageStyle;

#pragma mark - Override Methods

- (void)updateConstraints {
    [super updateConstraints];
//    [self.systemmessageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.contentView.mas_top).with.offset(8);
//        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-8);
//        make.width.lessThanOrEqualTo(@LCCKMessageCellLimit);
//        make.centerX.equalTo(self.contentView.mas_centerX);
//    }];
    [self.systemmessageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = 3;//8
        make.top.equalTo(self.contentView.mas_top).with.offset(offset);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-offset);
        make.width.lessThanOrEqualTo(@LCCKMessageCellLimit);
        //FIXME:
        make.height.equalTo(@20);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
}

#pragma mark - Public Methods

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.systemmessageContentView];
    [self updateConstraintsIfNeeded];
}

- (void)configureCellWithData:(LCCKMessage *)message {
    [super configureCellWithData:message];
    self.systemMessageLabel.attributedText = [[NSAttributedString alloc] initWithString:message.systemText attributes:self.systemMessageStyle];
}

#pragma mark - Getters

- (UIView *)systemmessageContentView {
    if (!_systemmessageContentView) {
        _systemmessageContentView = [[UIView alloc] init];
        _systemmessageContentView.backgroundColor = [UIColor lightGrayColor];
        _systemmessageContentView.alpha = .8f;
        _systemmessageContentView.layer.cornerRadius = 6.0f;
        _systemmessageContentView.translatesAutoresizingMaskIntoConstraints = NO;

        UILabel *systemMessageLabel = [[UILabel alloc] init];
        systemMessageLabel.numberOfLines = 0;
        
        [_systemmessageContentView addSubview:self.systemMessageLabel = systemMessageLabel];
        [systemMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            CGFloat offsetTopBottom = 3;//8
            CGFloat offsetLeftRight = 2 * offsetTopBottom;//8
            make.edges.equalTo(_systemmessageContentView).with.insets(UIEdgeInsetsMake(offsetTopBottom, offsetLeftRight, offsetTopBottom, offsetLeftRight));
        }];
        systemMessageLabel.attributedText = [[NSAttributedString alloc] initWithString:@"2015-11-16" attributes:self.systemMessageStyle];
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
                 NSForegroundColorAttributeName: [UIColor whiteColor]
                 };
    }
    return _systemMessageStyle;
}

@end
