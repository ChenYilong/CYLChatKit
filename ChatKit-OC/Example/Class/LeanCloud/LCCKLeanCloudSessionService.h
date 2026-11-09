//
//  LCCKLeanCloudSessionService.h
//  ChatKit-OC
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//
//  The LeanCloud IM session used by `LCCKLeanCloudIMProvider`.
//  It is an `CYLSingleton`, so ChatKit resets it together with its own services after closing a session.

#import <AVOSCloudIM/AVOSCloudIM.h>
#if __has_include(<ChatKit/LCChatKit.h>)
#import <ChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

@interface LCCKLeanCloudSessionService : CYLSingleton

@property (nonatomic, copy, readonly) NSString *clientId;

/*!
 * The LeanCloud client of the current session.
 */
@property (nonatomic, strong, readonly) AVIMClient *client;

/**
 *  是否和聊天服务器连通
 */
@property (nonatomic, assign, readonly) BOOL connect;

- (BOOL)isClientOpened;

- (void)openWithClientId:(NSString *)clientId force:(BOOL)force callback:(CYLBooleanResultBlock)callback;

- (void)closeWithCallback:(CYLBooleanResultBlock)callback;

@end
