//
//  UITableViewCell+CYLCellIdentifier.m
//  CYLChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/23.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import "CYLCellIdentifierFactory.h"
#import "CYLMessage.h"
#import "NSObject+CYLExtension.h"
#import "CYLIMMessageProtocol.h"
#import "CYLChatConstants.h"

@implementation CYLCellIdentifierFactory

+ (NSString *)cellIdentifierForMessageConfiguration:(id)message conversationType:(CYLConversationType)conversationType {
    NSString *groupKey;
    switch (conversationType) {
        case CYLConversationTypeGroup:
            groupKey = CYLCellIdentifierGroup;
            break;
        case CYLConversationTypeSingle:
            groupKey = CYLCellIdentifierSingle;
            break;
        default:
            groupKey = @"";
            break;
    }
    
    if ([message cyl_isCustomMessage]) {
        return [self cellIdentifierForCustomMessageConfiguration:(id<CYLIMMessageProtocol>)message groupKey:groupKey];
    }
    return [self cellIdentifierForDefaultMessageConfiguration:(CYLMessage *)message groupKey:groupKey];
}

+ (NSString *)cellIdentifierForDefaultMessageConfiguration:(CYLMessage *)message groupKey:(NSString *)groupKey {
    CYLMessageOwnerType messageOwner = message.ownerType;
    CYLMessageMediaType messageType = message.mediaType;
    if ([message cyl_isCustomCYLMessage]) {
        messageType = CYLMessageMediaTypeText;
    }
    NSNumber *key = [NSNumber numberWithInteger:messageType];
    Class aClass = [CYLChatMessageCellMediaTypeDict objectForKey:key];
    NSString *typeKey = NSStringFromClass(aClass);
    NSString *ownerKey;
    switch (messageOwner) {
        case CYLMessageOwnerTypeSystem:
            ownerKey = CYLCellIdentifierOwnerSystem;
            break;
        case CYLMessageOwnerTypeOther:
            ownerKey = CYLCellIdentifierOwnerOther;
            break;
        case CYLMessageOwnerTypeSelf:
            ownerKey = CYLCellIdentifierOwnerSelf;
            break;
        default:
            NSAssert(NO, @"Message Owner Unknow");
            break;
    }
    NSAssert(typeKey.length > 0, @"🔴类名与方法名：%@（在第%@行），描述：%@,%@", @(__PRETTY_FUNCTION__), @(__LINE__), @(message.mediaType), NSStringFromClass([message class]));
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%@_%@", typeKey, ownerKey, groupKey];
    return cellIdentifier;
}

+ (NSString *)cellIdentifierForCustomMessageConfiguration:(id<CYLIMMessageProtocol>)message groupKey:(NSString *)groupKey {
    CYLMessageOwnerType messageOwner = [message cyl_ownerType];
    CYLMessageMediaType messageType = message.mediaType;
    // A custom message without a registered cell is shown with the text cell.
    if (![CYLChatMessageCellMediaTypeDict objectForKey:@(messageType)]) {
        messageType = CYLMessageMediaTypeText;
    }
    NSNumber *key = [NSNumber numberWithInteger:messageType];
    NSString *typeKey = NSStringFromClass([CYLChatMessageCellMediaTypeDict objectForKey:key]);
    NSAssert(typeKey.length > 0, @"🔴类名与方法名：%@（在第%@行），描述：%@,%@", @(__PRETTY_FUNCTION__), @(__LINE__), @(message.mediaType), NSStringFromClass([message class]));
    NSString *ownerKey;
    switch (messageOwner) {
        case CYLMessageOwnerTypeSelf:
            ownerKey = CYLCellIdentifierOwnerSelf;
            break;
        case CYLMessageOwnerTypeOther:
            ownerKey = CYLCellIdentifierOwnerOther;
            break;
        default:
            NSAssert(NO, @"Message Owner Unknow");
            break;
    }
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%@_%@", typeKey, ownerKey, groupKey];
    return cellIdentifier;
}

+ (NSString *)cacheKeyForMessage:(id)message {
    if (![message cyl_isCustomMessage]) {
        CYLMessage *message_ = (CYLMessage *)message;
        return message_.messageId ?: message_.systemText;
    }
    id<CYLIMMessageProtocol> message_ = (id<CYLIMMessageProtocol>)message;
    return message_.messageId;
}

@end
