//
//  AVIMTypedMessage+LCCKExtension.h
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/5/26.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

//  Moved from ChatKit to the demo: ChatKit no longer depends on LeanCloud.
//  This category makes `AVIMTypedMessage` conform to ChatKit's `LCCKIMMessageDelegate`,
//  so built-in and custom LeanCloud messages can pass through ChatKit's UI.

#import <AVOSCloudIM/AVOSCloudIM.h>
#if __has_include(<ChatKit/LCChatKit.h>)
#import <ChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif
@class LCCKMessage;

@interface AVIMTypedMessage (LCCKExtension) <LCCKIMMessageDelegate>

#pragma mark - LCCKIMMessageDelegate

- (NSString *)lcck_senderId;
- (void)lcck_setSenderId:(NSString *)senderId;
- (LCCKMessageOwnerType)lcck_ownerType;
- (LCCKMessageSendState)lcck_sendStatus;
- (int64_t)lcck_sendTimestamp;

#pragma mark - LeanCloud helpers

/*!
 * Whether the custom message class is registered with `+[AVIMTypedMessage registerSubclass]`.
 */
- (BOOL)lcck_isSupportThisCustomMessage;

+ (AVIMTypedMessage *)lcck_messageWithLCCKMessage:(LCCKMessage *)message;
- (void)lcck_setObject:(id)object forKey:(NSString *)key;

@end
