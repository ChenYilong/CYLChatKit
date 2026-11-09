//
//  CYLConversationListCell.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLConversationListCell.h"
#import "CYLBadgeView.h"

#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

#import "UIImageView+CYLExtension.h"

static CGFloat CYLImageSize = 45;
static CGFloat CYLVerticalSpacing = 8;
static CGFloat CYLHorizontalSpacing = 10;
static CGFloat CYLTimestampeLabelWidth = 100;
static CGFloat CYLAutoResizingDefaultScreenWidth = 320;
static CGFloat CYLNameLabelHeightProportion = 3.0 / 5;
static CGFloat CYLNameLabelHeight;
static CGFloat CYLMessageLabelHeight;
static CGFloat CYLLittleBadgeSize = 10;
static CGFloat CYLRemindMuteSize = 18;

CGFloat const CYLConversationListCellDefaultHeight = 61; //CYLImageSize + CYLVerticalSpacing * 2;

@interface CYLConversationListCell ()

@property (nonatomic, strong) UIColor *conversationListUnreadBackgroundColor;
@property (nonatomic, strong) UIColor *conversationListUnreadTextColor;

@end

@implementation CYLConversationListCell

+ (instancetype)dequeueOrCreateCellByTableView :(UITableView *)tableView {
    CYLConversationListCell *cell = [tableView dequeueReusableCellWithIdentifier:[CYLConversationListCell identifier]];
    if (cell == nil) {
        cell = [[CYLConversationListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[self class] identifier]];
    }
    return cell;
}

+ (void)registerCellToTableView:(UITableView *)tableView {
    [tableView registerClass:[CYLConversationListCell class] forCellReuseIdentifier:[[self class] identifier]];
}

+ (NSString *)identifier {
    return NSStringFromClass([CYLConversationListCell class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"TableView-CellBackgroundColor"];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"TableView-CellBackgroundColor_Highlighted"];
    self.selectedBackgroundView = selectionColor;
    CYLNameLabelHeight = CYLImageSize * CYLNameLabelHeightProportion;
    CYLMessageLabelHeight = CYLImageSize - CYLNameLabelHeight;
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.timestampLabel];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.messageTextLabel];
    [self.contentView addSubview:self.remindMuteImageView];
    [self.contentView addSubview:self.litteBadgeView];
    [self.contentView bringSubviewToFront:self.litteBadgeView];
    [self.avatarImageView addSubview:self.officialSignImageView];
    self.litteBadgeView.layer.zPosition = 65.f / 2;

}

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
    if (_avatarImageView == nil) {
        UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CYLHorizontalSpacing, CYLVerticalSpacing, CYLImageSize, CYLImageSize)];
        avatarImageView.contentMode = UIViewContentModeScaleAspectFill;//防止特别长或者宽的图片显示不正常
        CYLAvatarImageViewCornerRadiusBlock avatarImageViewCornerRadiusBlock = [LCChatKit sharedInstance].avatarImageViewCornerRadiusBlock;
        if (avatarImageViewCornerRadiusBlock) {
            CGFloat avatarImageViewCornerRadius = avatarImageViewCornerRadiusBlock(avatarImageView.frame.size);
            // Related avatar rounding and refresh-flicker reports: https://github.com/leancloud/ChatKit-OC/issues/348 and https://github.com/leancloud/ChatKit-OC/issues/385
            avatarImageView.cyl_cornerRadius = avatarImageViewCornerRadius;
        }
        
        UITapGestureRecognizer *avatarImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewHandleTap:)];
        avatarImageView.userInteractionEnabled = YES;
        [avatarImageView addGestureRecognizer:avatarImageViewTap];
        
        _avatarImageView = avatarImageView;
    }
    return _avatarImageView;
}

- (void)avatarImageViewHandleTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        CYLOpenProfileBlock openProfileBlock = [CYLUIService sharedInstance].openProfileBlock;
        !openProfileBlock ?: openProfileBlock(self.clientId, nil, nil);
    }
}


- (UIView *)litteBadgeView {
    if (_litteBadgeView == nil) {
        UIView *litteBadgeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CYLLittleBadgeSize, CYLLittleBadgeSize)];
        litteBadgeView.backgroundColor = [UIColor redColor];
        litteBadgeView.layer.cornerRadius = CYLLittleBadgeSize / 2;
        litteBadgeView.center = CGPointMake(CGRectGetMaxX(_avatarImageView.frame), CGRectGetMinY(_avatarImageView.frame));
        litteBadgeView.hidden = YES;
        _litteBadgeView = litteBadgeView;
    }
    return _litteBadgeView;
}

- (UILabel *)timestampLabel {
    if (_timestampLabel == nil) {
        UILabel *timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(CYLAutoResizingDefaultScreenWidth - CYLHorizontalSpacing - CYLTimestampeLabelWidth, CGRectGetMinY(_avatarImageView.frame), CYLTimestampeLabelWidth, CYLNameLabelHeight)];
        timestampLabel.font = [UIFont systemFontOfSize:13];
        timestampLabel.textAlignment = NSTextAlignmentRight;
        timestampLabel.textColor = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"TableView-CellMinor"];
        timestampLabel.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        _timestampLabel = timestampLabel;
    }
    return _timestampLabel;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_avatarImageView.frame) + CYLHorizontalSpacing, CGRectGetMinY(_avatarImageView.frame), CGRectGetMinX(_timestampLabel.frame) - CYLHorizontalSpacing * 3 - CYLImageSize, CYLNameLabelHeight)];
        nameLabel.font = [UIFont systemFontOfSize:17];
        nameLabel.textColor = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"TableView-CellTitle"];
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _nameLabel = nameLabel;
    }
    return _nameLabel;
}

- (UILabel *)messageTextLabel {
    if (_messageTextLabel == nil) {
        UILabel *messageTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_nameLabel.frame), CGRectGetMaxY(_nameLabel.frame), CYLAutoResizingDefaultScreenWidth - 4 * CYLHorizontalSpacing - CYLImageSize - CYLRemindMuteSize, CYLMessageLabelHeight)];
        messageTextLabel.backgroundColor = [UIColor clearColor];
        messageTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        messageTextLabel.textColor = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"TableView-CellDetail"];
        _messageTextLabel = messageTextLabel;
    }
    return _messageTextLabel;
}

- (UIButton *)remindMuteImageView {
    if (_remindMuteImageView == nil) {
        UIButton *remindMuteImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        remindMuteImageView.frame = CGRectMake(CGRectGetMaxX(_messageTextLabel.frame) + CYLHorizontalSpacing, CGRectGetMinY(_messageTextLabel.frame), CYLRemindMuteSize, CYLRemindMuteSize);
        NSString *remindMuteImageName = @"Connectkeyboad_banner_mute";
//        remindMuteImageView.imageEdgeInsets = UIEdgeInsetsMake(2.5, 2.5, 2.5, 2.5);
        UIImage *remindMuteImage = [UIImage cyl_imageNamed:remindMuteImageName bundleName:@"Other" bundleForClass:[LCChatKit class]];
        [remindMuteImageView setImage:remindMuteImage forState:UIControlStateNormal];
        remindMuteImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        remindMuteImageView.hidden = YES;
        _remindMuteImageView = remindMuteImageView;
    }
    return _remindMuteImageView;
}

- (CYLBadgeView *)badgeView {
    if (_badgeView == nil) {
        CYLBadgeView *badgeView = [[CYLBadgeView alloc] initWithParentView:self.avatarImageView
                                                               alignment:CYLBadgeViewAlignmentTopRight];
        badgeView.badgeBackgroundColor = self.conversationListUnreadBackgroundColor;
        badgeView.badgeTextColor = self.conversationListUnreadTextColor;
        [self.avatarImageView addSubview:(_badgeView = badgeView)];
        [self.avatarImageView bringSubviewToFront:_badgeView];
    }
    return _badgeView;
}

- (UIColor *)conversationListUnreadBackgroundColor {
    if (_conversationListUnreadBackgroundColor) {
        return _conversationListUnreadBackgroundColor;
    }
    _conversationListUnreadBackgroundColor = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"ConversationList-UnreadBackground"];
    return _conversationListUnreadBackgroundColor;
}

- (UIColor *)conversationListUnreadTextColor {
    if (_conversationListUnreadTextColor) {
        return _conversationListUnreadTextColor;
    }
    _conversationListUnreadTextColor = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"ConversationList-UnreadText"];
    return _conversationListUnreadTextColor;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.badgeView.badgeText = nil;
// 长列表下会引起badgeView频繁创建和销毁，导致卡顿
//    self.badgeView = nil;
    self.litteBadgeView.hidden = YES;
    self.messageTextLabel.text = nil;
    self.timestampLabel.text = nil;
    self.nameLabel.text = nil;
}

@end
