//
//  CYLMessage+CYLDemoExtension.h
//  ChatKit-OC
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//
//  LeanCloud conversion for ChatKit's message model.
//  Moved from ChatKit to the demo because it depends on LeanCloud; the selector is unchanged.

#import <AVOSCloudIM/AVOSCloudIM.h>
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif

@interface CYLMessage (CYLDemoExtension)

/*!
 * Converts a LeanCloud message for display.
 * @return The message itself for a supported custom message, an `CYLMessage` for a built-in type,
 *         or nil for messages ChatKit does not display (video, file, recalled).
 */
+ (id)messageWithAVIMTypedMessage:(AVIMTypedMessage *)message;

@end
