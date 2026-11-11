//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit

#import "CYLDemoUserGroupItemCell.h"
//#import <UIButton+WebCache.h>
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif
#import "CYLDemoUser.h"
#import "CYLDemoExampleConstants.h"

@interface CYLDemoUserGroupItemCell()

@property (nonatomic, strong) UIButton *avatarView;

@property (nonatomic, strong) UILabel *usernameLabel;

@end

@implementation CYLDemoUserGroupItemCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.usernameLabel];
        
        [self p_addMasonry];
    }
    return self;
}

- (void)setUser:(CYLDemoUser *)user {
    [self setUser:user operationType:CYLDemoConversationOperationTypeNone];
}

- (void)setUser:(CYLDemoUser *)user operationType:(CYLDemoConversationOperationType)operationType {
    _user = user;
    if (user != nil) {
        [self.avatarView sd_setImageWithURL:user.avatarURL forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:CYLDEMO_DEFAULT_AVATAR_PATH]];
        [self.usernameLabel setText:user.name ?: user.clientId];
    } else {
        NSString *normalImageName = (operationType == CYLDemoConversationOperationTypeRemove) ?  @"chatdetail_remove_member" : @"chatdetail_add_member";
        NSString *highlightedImageName = (operationType == CYLDemoConversationOperationTypeRemove) ?  @"chatdetail_remove_memberHL" : @"chatdetail_add_memberHL" ;
        [self.avatarView setImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
        [self.avatarView setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateHighlighted];
        [self.usernameLabel setText:nil];
    }
}

#pragma mark - EventResponse -
- (void)avatarButtonDown {
    self.clickBlock(self.user);
}

#pragma mark - Private Methods -
- (void)p_addMasonry {
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.avatarView.mas_width);
    }];
    [self.usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.bottom.mas_equalTo(self.contentView);
        make.left.and.right.mas_lessThanOrEqualTo(self.contentView);
    }];
}

#pragma mark - Getter -
- (UIButton *)avatarView {
    if (_avatarView == nil) {
        _avatarView = [[UIButton alloc] init];
        [_avatarView.layer setMasksToBounds:YES];
        [_avatarView.layer setCornerRadius:5.0f];
        [_avatarView addTarget:self action:@selector(avatarButtonDown) forControlEvents:UIControlEventTouchUpInside];
    }
    return _avatarView;
}

- (UILabel *)usernameLabel {
    if (_usernameLabel == nil) {
        _usernameLabel = [[UILabel alloc] init];
        [_usernameLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_usernameLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _usernameLabel;
}

@end
