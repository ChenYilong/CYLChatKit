//
//  CYLChatVoiceMessageCell.h
//  CYLChatExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/16.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import "CYLChatMessageCell.h"

@interface CYLChatVoiceMessageCell : CYLChatMessageCell<CYLChatMessageCellSubclassing>

@property (nonatomic, assign) CYLVoiceMessageState voiceMessageState;

@end
