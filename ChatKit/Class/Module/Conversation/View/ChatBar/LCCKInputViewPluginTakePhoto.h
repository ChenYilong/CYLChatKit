//
//  LCCKInputViewPluginTakePhoto.h
//  Pods
//
//  v2.1.1 Created by ElonChan on 18/6/11.
//
//

#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

@interface LCCKInputViewPluginTakePhoto : LCCKInputViewPlugin<LCCKInputViewPluginSubclassing>

@property (nonatomic, weak) LCCKChatBar *inputViewRef;

@end
