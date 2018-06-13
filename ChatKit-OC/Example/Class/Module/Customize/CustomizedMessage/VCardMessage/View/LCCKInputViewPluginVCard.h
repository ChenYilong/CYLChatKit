//
//  LCCKInputViewPluginVCard.h
//  ChatKit-OC
//
//  v0.8.5 Created by ElonChan on 16/8/12.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

static LCCKInputViewPluginType const LCCKInputViewPluginTypeVCard = 1;

@interface LCCKInputViewPluginVCard : LCCKInputViewPlugin<LCCKInputViewPluginSubclassing>

@property (nonatomic, weak) LCCKChatBar *inputViewRef;

@end
