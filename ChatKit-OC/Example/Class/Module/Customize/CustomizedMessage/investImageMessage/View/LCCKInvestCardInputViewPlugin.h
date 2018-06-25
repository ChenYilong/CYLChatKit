//
//  LCCKInvestCardInputViewPlugin.h
//  ChatKit-OC
//
//  Created by chenyilong on 23/6/2018.
//  Copyright © 2018 ElonChan. All rights reserved.
//

#import "LCCKInputViewPlugin.h"
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

static LCCKInputViewPluginType const LCCKInputViewPluginTypeInvestCard = 5;

@interface LCCKInvestCardInputViewPlugin : LCCKInputViewPlugin<LCCKInputViewPluginSubclassing>

@property (nonatomic, weak) LCCKChatBar *inputViewRef;

@end
