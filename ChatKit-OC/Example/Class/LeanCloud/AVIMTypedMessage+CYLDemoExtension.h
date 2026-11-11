//
//  AVIMTypedMessage+CYLDemoExtension.h
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/5/26.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

//  Moved from ChatKit to the demo: ChatKit no longer depends on LeanCloud.
//  This category makes `AVIMTypedMessage` conform to ChatKit's `CYLIMMessageProtocol`,
//  so built-in and custom LeanCloud messages can pass through ChatKit's UI.

#import <AVOSCloudIM/AVOSCloudIM.h>
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif
@class CYLMessage;

@interface AVIMTypedMessage (CYLDemoExtension) <CYLIMMessageProtocol>

#pragma mark - CYLIMMessageProtocol

- (NSString *)cyl_senderId;
- (void)setCyl_senderId:(NSString *)senderId;
- (CYLMessageOwnerType)cyl_ownerType;
- (CYLMessageSendState)cyl_sendStatus;
- (int64_t)cyl_sendTimestamp;

#pragma mark - LeanCloud helpers

/*!
 * Whether the custom message class is registered with `+[AVIMTypedMessage registerSubclass]`.
 */
- (BOOL)cyl_demo_isSupportThisCustomMessage;

+ (AVIMTypedMessage *)cyl_demo_messageWithCYLDemoMessage:(CYLMessage *)message;
- (void)cyl_demo_setObject:(id)object forKey:(NSString *)key;

@end
