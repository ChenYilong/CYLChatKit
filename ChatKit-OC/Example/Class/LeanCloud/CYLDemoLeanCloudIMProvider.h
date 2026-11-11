//
//  CYLDemoLeanCloudIMProvider.h
//  ChatKit-OC
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//
//  The LeanCloud implementation of ChatKit's `CYLIMProvider`.
//  ChatKit is UI only; the demo plugs LeanCloud in with:
//
//  ```
//  [CYLChatKit sharedInstance].IMProvider = [[CYLDemoLeanCloudIMProvider alloc] init];
//  ```

#import <Foundation/Foundation.h>
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif

@interface CYLDemoLeanCloudIMProvider : NSObject <CYLIMProvider>

@end
