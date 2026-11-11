//
//  NSObject+CYLExtension.m
//  Pods
//
//  v2.1.1 Created by ElonChan on 18/6/10.
//
//

#import "NSObject+CYLExtension.h"

#if __has_include(<CYLChatKit/CYLChatKit.h>)
#import <CYLChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif

@implementation NSObject (CYLExtension)

- (BOOL)cyl_isCustomMessage {
    return [self cyl_isCustomTypedMessage];
}

/*!
 * A custom message is an IM SDK message (conforming to `CYLIMMessageProtocol`) whose media type is greater than 0.
 */
- (BOOL)cyl_isCustomTypedMessage {
    BOOL isCustomMessage = NO;
    if ([self conformsToProtocol:@protocol(CYLIMMessageProtocol)]) {
        if ((int)[(id<CYLIMMessageProtocol>)self mediaType] > 0) {
            isCustomMessage = YES;
        }
    }
    return isCustomMessage;
}

- (BOOL)cyl_isCustomCYLMessage {
    BOOL isCustomMessage = NO;
    int mediaType = (int)[(CYLMessage *)self mediaType];
    if ( mediaType >= 0) {
        isCustomMessage = YES;
    }
    return isCustomMessage;
}

- (NSTimeInterval)cyl_messageTimestamp {
    NSTimeInterval selfMessageTimestamp;
    if ([self cyl_isCustomMessage]) {
        NSTimeInterval sendTime = [(id<CYLIMMessageProtocol>)self cyl_sendTimestamp];
        //如果当前消息是正在发送的消息，则没有时间戳
        if (sendTime == 0) {
            sendTime = CYL_CURRENT_TIMESTAMP;
        }
        selfMessageTimestamp = sendTime;
    } else if ([self respondsToSelector:@selector(timestamp)]){
        selfMessageTimestamp = [(CYLMessage *)self timestamp];
    }
    return selfMessageTimestamp;
}

// 是否显示时间轴Label
- (void)cyl_shouldDisplayTimestampForMessages:(NSArray *)messages callback:(CYLShouldDisplayTimestampCallBack)callback {
    /* Set CYLIsDebugging=1 in preprocessor macros under build settings to enable debugging.*/
#ifdef CYLIsDebugging
    //如果定义了CYLIsDebugging则执行从这里到#endif的代码
    return YES;
#endif
    BOOL containsMessage= [messages containsObject:self];
    if (!containsMessage) {
        return;
    }
    
    NSTimeInterval selfMessageTimestamp = [self cyl_messageTimestamp];
    
    NSUInteger index = [messages indexOfObject:self];
    if (index == 0) {
        !callback ?: callback(YES, selfMessageTimestamp);
        return;
    }
    id lastMessage;
    @try {
        lastMessage = [messages objectAtIndex:index - 1];
    } @catch (NSException *exception) {
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), exception.reason);
    }
    
    NSTimeInterval lastMessageTimestamp = [lastMessage cyl_messageTimestamp];
    NSTimeInterval interval = (selfMessageTimestamp - lastMessageTimestamp) / 1000;
    
    int limitInterval = 60 * 3;
    if (interval > limitInterval) {
        !callback ?: callback(YES, selfMessageTimestamp);
        return;
    }
    !callback ?: callback(NO, selfMessageTimestamp);
}

- (NSDictionary *)cyl_JSONValue {
    if (!self) { return nil; }
    id result = nil;
    NSError* error = nil;
    if ([self isKindOfClass:[NSString class]]) {
        if ([(NSString *)self length] == 0) { return nil; }
        NSData *dataToBeParsed = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
        result = [NSJSONSerialization JSONObjectWithData:dataToBeParsed options:kNilOptions error:&error];
    } else {
        result = [NSJSONSerialization JSONObjectWithData:(NSData *)self options:kNilOptions error:&error];
    }
    if (![result isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return result;
}

- (BOOL)cyl_isCreatorForCurrentGroupConversaton {
    BOOL isCreator = [[CYLConversationService sharedInstance].currentConversation.creator isEqualToString:[CYLChatKit sharedInstance].clientId];
    BOOL isGroupConversation = [CYLConversationService sharedInstance].currentConversation.members.count > 2;
    if (isCreator && isGroupConversation) {
        return YES;
    }
    return NO;
}

@end
