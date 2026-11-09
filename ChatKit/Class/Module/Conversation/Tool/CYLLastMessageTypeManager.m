//
//  CYLLastMessageTypeManager.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLLastMessageTypeManager.h"
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif
#import "CYLUserSystemService.h"
#import "NSObject+CYLExtension.h"

static NSMutableDictionary *attributedStringCache = nil;

@implementation CYLLastMessageTypeManager

+ (NSString *)getMessageTitle:(id<CYLIMMessageProtocol>)message {
    NSString *title;
    switch (message.mediaType) {
        case CYLMessageMediaTypeText: {
            //Custom message
            BOOL isCustom = [[message.attributes valueForKey:CYLCustomMessageIsCustomKey] boolValue];
            if (!isCustom) {
                title = message.text;
                break;
            }
            title = [self titleForCustomMessage:message];
            break;
        }
        case CYLMessageMediaTypeAudio:
            title = CYLLocalizedStrings(@"Voice");
            title = [NSString stringWithFormat:@"[%@]",title];
            break;
            
        case CYLMessageMediaTypeImage:
            title = CYLLocalizedStrings(@"Photo");
            title = [NSString stringWithFormat:@"[%@]",title];
            break;
            
        case CYLMessageMediaTypeLocation:
            title = CYLLocalizedStrings(@"Location");
            title = [NSString stringWithFormat:@"[%@]",title];
            break;
            
        case CYLMessageMediaTypeVideo:
            title = CYLLocalizedStrings(@"Video");
            title = [NSString stringWithFormat:@"[%@]",title];
            break;

        case CYLMessageMediaTypeRecalled:
            title = @"";
            break;
            
        default:
            title = [self titleForCustomMessage:message];
            break;
    }
    return title;
}

+ (NSString *)titleForCustomMessage:(id<CYLIMMessageProtocol>)customMessage {
    NSString *typeTitleKey = [customMessage.attributes valueForKey:CYLCustomMessageTypeTitleKey];
    NSString *title = @"";
    do {
        if (typeTitleKey.length > 0) {
            title = typeTitleKey;
            title = [NSString stringWithFormat:@"[%@]", title];
            break;
        }
        
        title = CYLLocalizedStrings(@"unknownMessageType");
        title = [NSString stringWithFormat:@"[%@]", title];
        break;
    } while (NO);
    return title;
}

+ (NSAttributedString *)attributedStringWithMessage:(id<CYLIMMessageProtocol>)message conversation:(id<CYLConversationProtocol>)conversation userName:(NSString *)userName {
    NSString *title = [self getMessageTitle:message];
    if (conversation.cyl_type == CYLConversationTypeGroup) {
        if (!userName) {
            userName = @"";
        } else {
            userName = [NSString stringWithFormat:@"%@: ", userName];
        }
        title = [NSString stringWithFormat:@"%@%@", userName, title];
    }
    if (conversation.muted && conversation.cyl_unreadCount > 0) {
        title = [NSString stringWithFormat:@"[%@条] %@", @(conversation.cyl_unreadCount), title];
    }
    
    NSString *mentionText = [NSString stringWithFormat:@"%@ ", CYLLocalizedStrings(@"mentioned")];
    BOOL hasMentioned = (message.mentioned || conversation.cyl_mentioned);
    if (conversation.cyl_draft.length > 0) {
        title = conversation.cyl_draft;
        NSString *draftText = [NSString stringWithFormat:@"[%@]", CYLLocalizedStrings(@"draft")];
        if (hasMentioned) {
            mentionText = [mentionText stringByAppendingString:draftText];
        } else {
            mentionText = draftText;
        }
    }
    
    NSString *finalText;
    if (hasMentioned || conversation.cyl_draft.length > 0) {
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
    
    if (hasMentioned || conversation.cyl_draft.length > 0) {
        NSRange range = [finalText rangeOfString:mentionText];
        [attributedString setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:183/255.0 green:20/255.0 blue:20/255.0 alpha:1], NSFontAttributeName : font} range:range];
    }
    
    
    [attributedStringCache setObject:attributedString forKey:finalText];
    
    return attributedString;
}

@end
