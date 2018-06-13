//
//  LCCKVCardMessage.h
//  ChatKit-OC
//
//  v2.1.1 Created by ElonChan on 18/6/10.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <AVOSCloudIM/AVOSCloudIM.h>
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

static AVIMMessageMediaType const kAVIMMessageMediaTypeVCard = 1;

#import "LCCKVCardMessage.h"

@interface LCCKVCardMessage : AVIMTypedMessage<AVIMTypedMessageSubclassing>

- (instancetype)initWithClientId:(NSString *)clientId conversationType:(LCCKConversationType)conversationType;
+ (instancetype)vCardMessageWithClientId:(NSString *)clientId conversationType:(LCCKConversationType)conversationType;

@end
