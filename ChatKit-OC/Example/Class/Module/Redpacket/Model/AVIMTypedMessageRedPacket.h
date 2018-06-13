//
//  AVIMTypedMessageRedPacket.h
//  ChatKit-OC
//
//  Created by 都基鹏 on 18/6/16.
//  Copyright © 2016年 ElonChan. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif
#import "RedpacketMessageModel.h"

@interface AVIMTypedMessageRedPacket : AVIMTypedMessage<AVIMTypedMessageSubclassing>

/**
 *  红包相关数据模型
 */
@property (nonatomic,strong)RedpacketMessageModel * rpModel;

@end
