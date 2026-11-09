//
//  UITableViewCell+LCCKCellIdentifier.m
//  LCCKChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/23.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import "LCCKCellIdentifierFactory.h"
#import "LCCKMessage.h"
#import "NSObject+LCCKExtension.h"
#import "LCCKIMMessageDelegate.h"
#import "LCCKConstants.h"

@implementation LCCKCellIdentifierFactory

+ (NSString *)cellIdentifierForMessageConfiguration:(id)message conversationType:(LCCKConversationType)conversationType {
    NSString *groupKey;
    switch (conversationType) {
        case LCCKConversationTypeGroup:
            groupKey = LCCKCellIdentifierGroup;
            break;
        case LCCKConversationTypeSingle:
            groupKey = LCCKCellIdentifierSingle;
            break;
        default:
            groupKey = @"";
            break;
    }
    
    if ([message lcck_isCustomMessage]) {
        return [self cellIdentifierForCustomMessageConfiguration:(id<LCCKIMMessageDelegate>)message groupKey:groupKey];
    }
    return [self cellIdentifierForDefaultMessageConfiguration:(LCCKMessage *)message groupKey:groupKey];
}

+ (NSString *)cellIdentifierForDefaultMessageConfiguration:(LCCKMessage *)message groupKey:(NSString *)groupKey {
    LCCKMessageOwnerType messageOwner = message.ownerType;
    LCCKMessageMediaType messageType = message.mediaType;
    if ([message lcck_isCustomLCCKMessage]) {
        messageType = kLCCKMessageMediaTypeText;
    }
    NSNumber *key = [NSNumber numberWithInteger:messageType];
    Class aClass = [LCCKChatMessageCellMediaTypeDict objectForKey:key];
    NSString *typeKey = NSStringFromClass(aClass);
    NSString *ownerKey;
    switch (messageOwner) {
        case LCCKMessageOwnerTypeSystem:
            ownerKey = LCCKCellIdentifierOwnerSystem;
            break;
        case LCCKMessageOwnerTypeOther:
            ownerKey = LCCKCellIdentifierOwnerOther;
            break;
        case LCCKMessageOwnerTypeSelf:
            ownerKey = LCCKCellIdentifierOwnerSelf;
            break;
        default:
            NSAssert(NO, @"Message Owner Unknow");
            break;
    }
    NSAssert(typeKey.length > 0, @"🔴类名与方法名：%@（在第%@行），描述：%@,%@", @(__PRETTY_FUNCTION__), @(__LINE__), @(message.mediaType), NSStringFromClass([message class]));
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%@_%@", typeKey, ownerKey, groupKey];
    return cellIdentifier;
}

+ (NSString *)cellIdentifierForCustomMessageConfiguration:(id<LCCKIMMessageDelegate>)message groupKey:(NSString *)groupKey {
    LCCKMessageOwnerType messageOwner = [message lcck_ownerType];
    LCCKMessageMediaType messageType = message.mediaType;
    // A custom message without a registered cell is shown with the text cell.
    if (![LCCKChatMessageCellMediaTypeDict objectForKey:@(messageType)]) {
        messageType = kLCCKMessageMediaTypeText;
    }
    NSNumber *key = [NSNumber numberWithInteger:messageType];
    NSString *typeKey = NSStringFromClass([LCCKChatMessageCellMediaTypeDict objectForKey:key]);
    NSAssert(typeKey.length > 0, @"🔴类名与方法名：%@（在第%@行），描述：%@,%@", @(__PRETTY_FUNCTION__), @(__LINE__), @(message.mediaType), NSStringFromClass([message class]));
    NSString *ownerKey;
    switch (messageOwner) {
        case LCCKMessageOwnerTypeSelf:
            ownerKey = LCCKCellIdentifierOwnerSelf;
            break;
        case LCCKMessageOwnerTypeOther:
            ownerKey = LCCKCellIdentifierOwnerOther;
            break;
        default:
            NSAssert(NO, @"Message Owner Unknow");
            break;
    }
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%@_%@", typeKey, ownerKey, groupKey];
    return cellIdentifier;
}

+ (NSString *)cacheKeyForMessage:(id)message {
    if (![message lcck_isCustomMessage]) {
        LCCKMessage *message_ = (LCCKMessage *)message;
        return message_.messageId ?: message_.systemText;
    }
    id<LCCKIMMessageDelegate> message_ = (id<LCCKIMMessageDelegate>)message;
    return message_.messageId;
}

@end
