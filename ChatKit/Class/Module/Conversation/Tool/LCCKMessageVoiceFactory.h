//
//  LCCKMessageVoiceFactory.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/21.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCCKConstants.h"

@interface LCCKMessageVoiceFactory : NSObject

+ (UIImageView *)messageVoiceAnimationImageViewWithBubbleMessageType:(LCCKMessageOwnerType)owner;

@end
