//
//  AVIMMessage+CYLDemoExtension.m
//  Pods
//
//  Created by 陈宜龙 on 18/6/20.
//
//

#import "AVIMMessage+CYLDemoExtension.h"
#import "NSObject+CYLExtension.h"
#if __has_include(<CYLChatKit/CYLChatKit.h>)
#import <CYLChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif
#import "AVIMTypedMessage+CYLDemoExtension.h"

@implementation AVIMMessage (CYLDemoExtension)

- (BOOL)cyl_demo_isValidMessage {
    id messageToCheck = (id)self;
    if (!messageToCheck || messageToCheck == [NSNull null]) {
        return NO;
    }
    return YES;
}

- (AVIMTypedMessage *)cyl_demo_getValidTypedMessage {
    if (!self.cyl_demo_isValidMessage) {
        return nil;
    }
    if ([self isKindOfClass:[AVIMTypedMessage class]]) {
        return (AVIMTypedMessage *)self;
    }
    NSString *messageText;
    NSDictionary *attr;
    if ([[self class] isSubclassOfClass:[AVIMMessage class]]) {
        //当存在无法识别的自定义消息，SDK会返回 AVIMMessage 类型
        AVIMMessage *message = self;
        NSString *jsonString = message.content;
        NSDictionary *json = [jsonString cyl_JSONValue];
        do {
            NSString *customMessageDegradeKey = [json valueForKey:@"_lctext"];
            if (customMessageDegradeKey.length > 0) {
                messageText = customMessageDegradeKey;
                break;
            }
            attr = [json valueForKey:@"_lcattrs"];
            NSString *customMessageAttrDegradeKey = [attr valueForKey:CYLCustomMessageDegradeKey];
            if (customMessageAttrDegradeKey.length > 0) {
                messageText = customMessageAttrDegradeKey;
                break;
            }
            messageText = CYLLocalizedStrings(@"unknownMessage");
            break;
        } while (NO);
    }
    AVIMTextMessage *typedMessage = [AVIMTextMessage messageWithText:messageText attributes:attr];
    [typedMessage setValue:self.conversationId forKey:@"conversationId"];
    [typedMessage setValue:self.messageId forKey:@"messageId"];
    [typedMessage setValue:@(self.sendTimestamp) forKey:@"sendTimestamp"];
    [typedMessage setValue:self.clientId forKey:@"clientId"];
    [typedMessage cyl_demo_setObject:@(YES) forKey:CYLCustomMessageIsCustomKey];
    return typedMessage;
}

@end
