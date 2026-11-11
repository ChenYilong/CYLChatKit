//
//  NSMutableArray+CYLMessageExtention.m
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/5/26.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "NSMutableArray+CYLMessageExtention.h"
#if __has_include(<CYLChatKit/CYLChatKit.h>)
#import <CYLChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif

@implementation NSMutableArray (CYLMessageExtention)

+ (NSMutableArray *)cyl_messagesWithCYLIMMessages:(NSArray *)cylimTypedMessages {
   __block NSMutableArray *messages = @[].mutableCopy;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        
        void(^filteredMessageCallback)(NSArray *_cylimTypedMessages) = ^(NSArray *_cylimTypedMessages) {
            id<CYLIMProvider> IMProvider = [CYLChatKit sharedInstance].IMProvider;
            for (id<CYLIMMessageProtocol> typedMessage in _cylimTypedMessages) {
                id message = [IMProvider displayMessageFromIMMessage:typedMessage];
                if (message) {
                    [messages addObject:message];
                }
            }
        };
        
        CYLFilterMessagesBlock filterMessagesBlock = [CYLConversationService sharedInstance].filterMessagesBlock;
        if (filterMessagesBlock) {
            CYLFilterMessagesCompletionHandler filterMessagesCompletionHandler = ^(NSArray *filterMessages, NSError *error) {
                if (!error) {
                    !filteredMessageCallback ?: filteredMessageCallback([filterMessages copy]);
                }
            };
            filterMessagesBlock([CYLConversationService sharedInstance].currentConversation, cylimTypedMessages, filterMessagesCompletionHandler);
        } else {
            !filteredMessageCallback ?: filteredMessageCallback(cylimTypedMessages);
        }
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    return messages;
}

- (void)cyl_removeMessageAtIndex:(NSUInteger)index {
    if (index < self.count) {
        [self removeObjectAtIndex:index];
    }
}

- (id)cyl_messageAtIndex:(NSUInteger)index {
    BOOL valid = (index < self.count);
    if (valid) {
        return self[index];
    }
    NSLog(@" `self.cylimTypedMessage` in `-loadOldMessages` has no object");
    //    NSAssert(valid, @" `self.cylimTypedMessage` in `-loadOldMessages` has no object");
    return nil;
}

@end
