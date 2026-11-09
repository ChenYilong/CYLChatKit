//
//  LCCKMessage+LCCKExtension.h
//  ChatKit-OC
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//
//  LeanCloud conversion for ChatKit's message model.
//  Moved from ChatKit to the demo because it depends on LeanCloud; the selector is unchanged.

#import <AVOSCloudIM/AVOSCloudIM.h>
#if __has_include(<ChatKit/LCChatKit.h>)
#import <ChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

@interface LCCKMessage (LCCKExtension)

/*!
 * Converts a LeanCloud message for display.
 * @return The message itself for a supported custom message, an `LCCKMessage` for a built-in type,
 *         or nil for messages ChatKit does not display (video, file, recalled).
 */
+ (id)messageWithAVIMTypedMessage:(AVIMTypedMessage *)message;

@end
