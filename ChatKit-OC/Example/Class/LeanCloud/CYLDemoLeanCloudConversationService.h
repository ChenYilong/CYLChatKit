//
//  CYLDemoLeanCloudConversationService.h
//  ChatKit-OC
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//
//  LeanCloud conversations, messages, and the local stores of recent conversations and
//  failed messages, used by `CYLDemoLeanCloudIMProvider`.
//  It is an `CYLSingleton`, so ChatKit resets it together with its own services after closing a session.

#import <AVOSCloudIM/AVOSCloudIM.h>
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif

@interface CYLDemoLeanCloudConversationService : CYLSingleton <CYLIMConversationProvider,
                                                             CYLIMMessageProvider,
                                                             CYLIMRecentConversationProvider,
                                                             CYLIMFailedMessageProvider>

/*!
 * Sends a message with LeanCloud send options. The default options request a receipt.
 */
- (void)sendMessage:(AVIMTypedMessage *)message
       conversation:(AVIMConversation *)conversation
            options:(AVIMMessageSendOption)options
        mentionList:(NSArray<NSString *> *)mentionList
      progressBlock:(CYLProgressBlock)progressBlock
           callback:(CYLBooleanResultBlock)block;

@end
