//
//  LCCKLastMessageTypeManager.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "LCCKLastMessageTypeManager.h"
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif
#import "LCCKUserSystemService.h"
#import "NSObject+LCCKExtension.h"

static NSMutableDictionary *attributedStringCache = nil;

@implementation LCCKLastMessageTypeManager

+ (NSString *)getMessageTitle:(id<LCCKIMMessageDelegate>)message {
    NSString *title;
    switch (message.mediaType) {
        case kLCCKMessageMediaTypeText: {
            //Custom message
            BOOL isCustom = [[message.attributes valueForKey:LCCKCustomMessageIsCustomKey] boolValue];
            if (!isCustom) {
                title = message.text;
                break;
            }
            title = [self titleForCustomMessage:message];
            break;
        }
        case kLCCKMessageMediaTypeAudio:
            title = LCCKLocalizedStrings(@"Voice");
            title = [NSString stringWithFormat:@"[%@]",title];
            break;
            
        case kLCCKMessageMediaTypeImage:
            title = LCCKLocalizedStrings(@"Photo");
            title = [NSString stringWithFormat:@"[%@]",title];
            break;
            
        case kLCCKMessageMediaTypeLocation:
            title = LCCKLocalizedStrings(@"Location");
            title = [NSString stringWithFormat:@"[%@]",title];
            break;
            
        case kLCCKMessageMediaTypeVideo:
            title = LCCKLocalizedStrings(@"Video");
            title = [NSString stringWithFormat:@"[%@]",title];
            break;

        case kLCCKMessageMediaTypeRecalled:
            title = @"";
            break;
            
        default:
            title = [self titleForCustomMessage:message];
            break;
    }
    return title;
}

+ (NSString *)titleForCustomMessage:(id<LCCKIMMessageDelegate>)customMessage {
    NSString *typeTitleKey = [customMessage.attributes valueForKey:LCCKCustomMessageTypeTitleKey];
    NSString *title = @"";
    do {
        if (typeTitleKey.length > 0) {
            title = typeTitleKey;
            title = [NSString stringWithFormat:@"[%@]", title];
            break;
        }
        
        title = LCCKLocalizedStrings(@"unknownMessageType");
        title = [NSString stringWithFormat:@"[%@]", title];
        break;
    } while (NO);
    return title;
}

+ (NSAttributedString *)attributedStringWithMessage:(id<LCCKIMMessageDelegate>)message conversation:(id<LCCKConversationDelegate>)conversation userName:(NSString *)userName {
    NSString *title = [self getMessageTitle:message];
    if (conversation.lcck_type == LCCKConversationTypeGroup) {
        if (!userName) {
            userName = @"";
        } else {
            userName = [NSString stringWithFormat:@"%@: ", userName];
        }
        title = [NSString stringWithFormat:@"%@%@", userName, title];
    }
    if (conversation.muted && conversation.lcck_unreadCount > 0) {
        title = [NSString stringWithFormat:@"[%@条] %@", @(conversation.lcck_unreadCount), title];
    }
    
    NSString *mentionText = [NSString stringWithFormat:@"%@ ", LCCKLocalizedStrings(@"mentioned")];
    BOOL hasMentioned = (message.mentioned || conversation.lcck_mentioned);
    if (conversation.lcck_draft.length > 0) {
        title = conversation.lcck_draft;
        NSString *draftText = [NSString stringWithFormat:@"[%@]", LCCKLocalizedStrings(@"draft")];
        if (hasMentioned) {
            mentionText = [mentionText stringByAppendingString:draftText];
        } else {
            mentionText = draftText;
        }
    }
    
    NSString *finalText;
    if (hasMentioned || conversation.lcck_draft.length > 0) {
        finalText = [NSString stringWithFormat:@"%@%@", mentionText, title];
    } else {
        finalText = title;
    }
    if (finalText == nil) {
        finalText = @"";
    }
    if ([attributedStringCache objectForKey:finalText]) {
        return [attributedStringCache objectForKey:finalText];
    }
    UIFont *font = [UIFont systemFontOfSize:13];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName: [UIColor grayColor], (id)NSFontAttributeName:font};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:finalText attributes:attributes];
    
    if (hasMentioned || conversation.lcck_draft.length > 0) {
        NSRange range = [finalText rangeOfString:mentionText];
        [attributedString setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:183/255.0 green:20/255.0 blue:20/255.0 alpha:1], NSFontAttributeName : font} range:range];
    }
    
    
    [attributedStringCache setObject:attributedString forKey:finalText];
    
    return attributedString;
}

@end
