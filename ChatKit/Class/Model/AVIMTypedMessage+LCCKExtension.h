//
//  AVIMTypedMessage+LCCKExtension.h
//  ChatKit
//
//  v0.8.5 Created by ElonChan on 16/5/26.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <AVOSCloudIM/AVOSCloudIM.h>
@class LCCKMessage;

@interface AVIMTypedMessage (LCCKExtension)

- (BOOL)lcck_isSupportThisCustomMessage;

+ (AVIMTypedMessage *)lcck_messageWithLCCKMessage:(LCCKMessage *)message;
- (void)lcck_setObject:(id)object forKey:(NSString *)key;

@end
