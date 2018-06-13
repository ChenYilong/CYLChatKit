//
//  RedPacketChangeInputViewPlugin.h
//  ChatKit-OC
//
//  Created by 都基鹏 on 16/9/9.
//  Copyright © 2016年 ElonChan. All rights reserved.
//

#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif


@interface RedPacketChangeInputViewPlugin : LCCKInputViewPlugin<LCCKInputViewPluginSubclassing>

@property (nonatomic, weak) LCCKChatBar *inputViewRef;

@end
