//
//  NSMutableArray+LCCKMessageExtention.m
//  ChatKit
//
//  v0.8.5 Created by ElonChan on 16/5/26.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import "NSMutableArray+LCCKMessageExtention.h"
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

@implementation NSMutableArray (LCCKMessageExtention)

+ (NSMutableArray *)lcck_messagesWithAVIMMessages:(NSArray *)avimTypedMessages {
   __block NSMutableArray *messages = @[].mutableCopy;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        
        void(^filteredMessageCallback)(NSArray *_avimTypedMessages) = ^(NSArray *_avimTypedMessages) {
            for (AVIMTypedMessage *typedMessage in _avimTypedMessages) {
                id message = [LCCKMessage messageWithAVIMTypedMessage:typedMessage];
                if (message) {
                    [messages addObject:message];
                }
            }
        };
        
        LCCKFilterMessagesBlock filterMessagesBlock = [LCCKConversationService sharedInstance].filterMessagesBlock;
        if (filterMessagesBlock) {
            LCCKFilterMessagesCompletionHandler filterMessagesCompletionHandler = ^(NSArray *filterMessages, NSError *error) {
                if (!error) {
                    !filteredMessageCallback ?: filteredMessageCallback([filterMessages copy]);
                }
            };
            filterMessagesBlock([LCCKConversationService sharedInstance].currentConversation, avimTypedMessages, filterMessagesCompletionHandler);
        } else {
            !filteredMessageCallback ?: filteredMessageCallback(avimTypedMessages);
        }
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    return messages;
}

- (void)lcck_removeMessageAtIndex:(NSUInteger)index {
    if (index < self.count) {
        [self removeObjectAtIndex:index];
    }
}

- (id)lcck_messageAtIndex:(NSUInteger)index {
    BOOL valid = (index < self.count);
    if (valid) {
        return self[index];
    }
    NSLog(@" `self.avimTypedMessage` in `-loadOldMessages` has no object");
    //    NSAssert(valid, @" `self.avimTypedMessage` in `-loadOldMessages` has no object");
    return nil;
}

@end
