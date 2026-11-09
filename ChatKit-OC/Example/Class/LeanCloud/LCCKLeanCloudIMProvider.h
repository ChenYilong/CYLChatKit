//
//  LCCKLeanCloudIMProvider.h
//  ChatKit-OC
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//
//  The LeanCloud implementation of ChatKit's `CYLIMProvider`.
//  ChatKit is UI only; the demo plugs LeanCloud in with:
//
//  ```
//  [LCChatKit sharedInstance].IMProvider = [[LCCKLeanCloudIMProvider alloc] init];
//  ```

#import <Foundation/Foundation.h>
#if __has_include(<ChatKit/LCChatKit.h>)
#import <ChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

@interface LCCKLeanCloudIMProvider : NSObject <CYLIMProvider>

@end
