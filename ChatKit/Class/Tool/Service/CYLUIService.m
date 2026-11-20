//
//  CYLUIService.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/1.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLUIService.h"

NSString *const CYLUIServiceErrorDomain = @"CYLUIServiceErrorDomain";

@implementation CYLUIService
@synthesize openProfileBlock = _openProfileBlock;
@synthesize previewImageMessageBlock = _previewImageMessageBlock;
@synthesize previewLocationMessageBlock = _previewLocationMessageBlock;
@synthesize longPressMessageBlock = _longPressMessageBlock;
@synthesize showNotificationBlock = _showNotificationBlock;
@synthesize HUDActionBlock = _HUDActionBlock;
@synthesize avatarImageViewCornerRadiusBlock = _avatarImageViewCornerRadiusBlock;

- (void)setPreviewImageMessageBlock:(CYLPreviewImageMessageBlock)previewImageMessageBlock {
    _previewImageMessageBlock = [previewImageMessageBlock copy];
}

- (void)setPreviewLocationMessageBlock:(CYLPreviewLocationMessageBlock)previewLocationMessageBlock {
    _previewLocationMessageBlock = [previewLocationMessageBlock copy];
}

- (void)setOpenProfileBlock:(CYLOpenProfileBlock)openProfileBlock {
    _openProfileBlock = [openProfileBlock copy];
}

- (void)setShowNotificationBlock:(CYLShowNotificationBlock)showNotificationBlock {
    _showNotificationBlock = [showNotificationBlock copy];
}

- (void)setHUDActionBlock:(CYLHUDActionBlock)HUDActionBlock {
    _HUDActionBlock = [HUDActionBlock copy];
}

- (void)setUnreadCountChangedBlock:(CYLUnreadCountChangedBlock)unreadCountChangedBlock {
    _unreadCountChangedBlock = [unreadCountChangedBlock copy];
}

- (void)setAvatarImageViewCornerRadiusBlock:(CYLAvatarImageViewCornerRadiusBlock)avatarImageViewCornerRadiusBlock {
    _avatarImageViewCornerRadiusBlock = [avatarImageViewCornerRadiusBlock copy];
}

- (void)setLongPressMessageBlock:(CYLLongPressMessageBlock)longPressMessageBlock {
    _longPressMessageBlock = [longPressMessageBlock copy];
}

@end
