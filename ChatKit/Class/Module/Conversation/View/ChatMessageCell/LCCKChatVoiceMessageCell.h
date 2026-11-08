//
//  LCCKChatVoiceMessageCell.h
//  LCCKChatExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/16.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import "LCCKChatMessageCell.h"

@interface LCCKChatVoiceMessageCell : LCCKChatMessageCell<LCCKChatMessageCellSubclassing>

@property (nonatomic, assign) LCCKVoiceMessageState voiceMessageState;

@end
