//
//  LCCKUIService.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/1.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "LCCKUIService.h"

NSString *const LCCKUIServiceErrorDomain = @"LCCKUIServiceErrorDomain";

@implementation LCCKUIService
@synthesize openProfileBlock = _openProfileBlock;
@synthesize previewImageMessageBlock = _previewImageMessageBlock;
@synthesize previewLocationMessageBlock = _previewLocationMessageBlock;
@synthesize longPressMessageBlock = _longPressMessageBlock;
@synthesize showNotificationBlock = _showNotificationBlock;
@synthesize HUDActionBlock = _HUDActionBlock;
@synthesize avatarImageViewCornerRadiusBlock = _avatarImageViewCornerRadiusBlock;

- (void)setPreviewImageMessageBlock:(LCCKPreviewImageMessageBlock)previewImageMessageBlock {
    _previewImageMessageBlock = [previewImageMessageBlock copy];
}

- (void)setPreviewLocationMessageBlock:(LCCKPreviewLocationMessageBlock)previewLocationMessageBlock {
    _previewLocationMessageBlock = [previewLocationMessageBlock copy];
}

- (void)setOpenProfileBlock:(LCCKOpenProfileBlock)openProfileBlock {
    _openProfileBlock = [openProfileBlock copy];
}

- (void)setShowNotificationBlock:(LCCKShowNotificationBlock)showNotificationBlock {
    _showNotificationBlock = [showNotificationBlock copy];
}

- (void)setHUDActionBlock:(LCCKHUDActionBlock)HUDActionBlock {
    _HUDActionBlock = [HUDActionBlock copy];
}

- (void)setUnreadCountChangedBlock:(LCCKUnreadCountChangedBlock)unreadCountChangedBlock {
    _unreadCountChangedBlock = [unreadCountChangedBlock copy];
}

- (void)setAvatarImageViewCornerRadiusBlock:(LCCKAvatarImageViewCornerRadiusBlock)avatarImageViewCornerRadiusBlock {
    _avatarImageViewCornerRadiusBlock = [avatarImageViewCornerRadiusBlock copy];
}

- (void)setLongPressMessageBlock:(LCCKLongPressMessageBlock)longPressMessageBlock {
    _longPressMessageBlock = [longPressMessageBlock copy];
}

@end
