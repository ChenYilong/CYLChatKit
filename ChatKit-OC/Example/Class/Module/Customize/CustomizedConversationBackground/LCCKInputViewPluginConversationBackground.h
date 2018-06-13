//
//  LCCKInputViewPluginVCard.h
//  ChatKit-OC
//
//  v2.1.1 Created by ElonChan on 18/6/12.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

static LCCKInputViewPluginType const LCCKInputViewPluginTypeConversationBackground = 2;

@interface LCCKInputViewPluginConversationBackground : LCCKInputViewPlugin<LCCKInputViewPluginSubclassing>

@property (nonatomic, weak) LCCKChatBar *inputViewRef;

@end
