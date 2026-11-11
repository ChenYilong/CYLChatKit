//
//  AVIMConversation+CYLDemoExtension.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/11.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "AVIMConversation+CYLDemoExtension.h"
#import <objc/runtime.h>
#import "NSDate+CYLDateTools.h"
#import "AVIMMessage+CYLDemoExtension.h"

@implementation AVIMConversation (CYLDemoExtension)

- (AVIMTypedMessage *)cyl_lastMessage {
    AVIMTypedMessage *visiableLastMessage = nil;
    AVIMTypedMessage *lastMessageFromCache = [self.lastMessage cyl_demo_getValidTypedMessage];
    id visiableForPartClientIds = [lastMessageFromCache.attributes
                                   valueForKey:CYLCustomMessageOnlyVisiableForPartClientIds];
    BOOL isArray = [visiableForPartClientIds isKindOfClass:[NSArray class]];
    BOOL isString = [visiableForPartClientIds isKindOfClass:[NSString class]];
    if (!visiableForPartClientIds) {
        visiableLastMessage = lastMessageFromCache;
    } else if (isArray && ([(NSArray *)visiableForPartClientIds count] > 0)) {
        BOOL visiableForCurrentClientId =
        [visiableForPartClientIds containsObject:[CYLChatKit sharedInstance].clientId];
        if (visiableForCurrentClientId) {
            visiableLastMessage = lastMessageFromCache;
        }
    } else if (isString && ([(NSString *)visiableForPartClientIds length] > 0)) {
        if ([visiableForPartClientIds isEqualToString:[CYLChatKit sharedInstance].clientId]) {
            visiableLastMessage = lastMessageFromCache;
        }
    }
    return visiableLastMessage;
}

- (NSDate *)cyl_lastMessageAt {
    NSDate *dateFromServer = self.lastMessageAt;
    NSDate *dateFromCache = [NSDate dateWithTimeIntervalSince1970:self.cyl_lastMessage.sendTimestamp / 1000];
    BOOL isServerLate = [dateFromServer cyl_isLaterThan:dateFromCache];
    return isServerLate ? dateFromServer : dateFromCache;
}

- (NSInteger)cyl_unreadCount {
    return (NSInteger)self.unreadMessagesCount;
}

- (BOOL)cyl_mentioned {
    return self.unreadMessagesMentioned;
}

- (NSString *)cyl_badgeText {
    NSString *badgeText;
    NSUInteger unreadCount = self.unreadMessagesCount;
    if (unreadCount > 99) {
        badgeText = CYLBadgeTextForNumberGreaterThanLimit;
    } else {
        badgeText = [NSString stringWithFormat:@"%@", @(unreadCount)];
    }
    return badgeText;
}

- (NSString *)cyl_draft {
    return objc_getAssociatedObject(self, @selector(cyl_draft));
}

- (void)setCyl_draft:(NSString *)cyl_draft {
    objc_setAssociatedObject(self, @selector(cyl_draft), cyl_draft, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CYLConversationType)cyl_type {
    if (self.members.count == 2) {
        return CYLConversationTypeSingle;
    }
    //系统对话按照群聊处理
    return CYLConversationTypeGroup;
}

- (NSString *)cyl_displayName {
    BOOL disablePreviewUserId = [CYLSettingService sharedInstance].isDisablePreviewUserId;
    NSString *displayName;
    if ([self cyl_type] == CYLConversationTypeSingle) {
        NSString *peerId = [self cyl_peerId];
        NSError *error = nil;
        NSArray *peers = [[CYLUserSystemService sharedInstance] getCachedProfilesIfExists:@[peerId] error:&error];
        id<CYLUserDelegate> peer;
        if (peers.count > 0) {
            peer = peers[0];
        }
        displayName = peer.name ?: peerId;
        if (!peer.name && disablePreviewUserId) {
            NSString *defaultNickNameWhenNil = CYLLocalizedStrings(@"nickNameIsNil");
            displayName = defaultNickNameWhenNil.length > 0 ? defaultNickNameWhenNil : @"";
        }
        return displayName;
    }
    if (self.name.length > 0) {
        return self.name;
    }
    if (self.members.count == 0) {
        return CYLLocalizedStrings(@"SystemConversation");
    }
    return CYLLocalizedStrings(@"GroupConversation");
    
}

- (NSString *)cyl_peerId {
    NSArray *members = self.members;
    if (members.count == 0) {
        //TODO: add debug model
        //        [NSException raise:@"invalid conversation" format:@"invalid conversation"];
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"invalid conversation");
        return nil;
    }
    if (members.count == 1) {
        return members[0];
    }
    NSString *peerId;
    if ([members[0] isEqualToString:[CYLSessionService sharedInstance].clientId]) {
        peerId = members[1];
    } else {
        peerId = members[0];
    }
    return peerId;
}

- (NSString *)cyl_title {
    NSString *displayName = self.cyl_displayName;
    if (!self.cyl_displayName || self.cyl_displayName.length == 0 ||  [self.cyl_displayName isEqualToString:CYLLocalizedStrings(@"nickNameIsNil")]) {
        displayName = CYLLocalizedStrings(@"Chat");
    }
    if (self.cyl_type == CYLConversationTypeSingle || self.members.count == 0) {
        return displayName;
    } else {
        return [NSString stringWithFormat:@"%@(%ld)", displayName, (long)self.members.count];
        
    }
}

- (void)cyl_setConversationWithMute:(BOOL)mute callback:(CYLBooleanResultBlock)callback {
    if (mute) {
        [self muteWithCallback:^(BOOL succeeded, NSError * _Nullable error) {
            !callback ?: callback(succeeded, error);
        }];
    } else {
        [self unmuteWithCallback:^(BOOL succeeded, NSError * _Nullable error) {
            !callback ?: callback(succeeded, error);
        }];
    }
}

- (BOOL)cyl_isCreaterForCurrentUser {
    BOOL isCreater = [self.creator isEqualToString:[CYLChatKit sharedInstance].clientId];
    return isCreater;
}

@end

