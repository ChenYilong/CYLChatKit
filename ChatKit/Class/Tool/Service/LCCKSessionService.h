//
//  LCCKSessionService.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan  on 16/3/1.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "LCCKServiceDefinition.h"

/*!
 * LCCKSessionService error demain
 */
FOUNDATION_EXTERN NSString *const LCCKSessionServiceErrorDemain;

/*!
 * Session state used by the UI. IM work is forwarded to `-[LCChatKit IMProvider]`.
 */
@interface LCCKSessionService : LCCKSingleton <LCCKSessionService>

@property (nonatomic, copy, readonly) NSString *clientId;

/*!
 * The underlying SDK client of the IM provider, if it exposes one (an `AVIMClient` for LeanCloud).
 */
@property (nonatomic, strong, readonly) id client;

/**
 *  是否和聊天服务器连通
 */
@property (nonatomic, assign, readonly) BOOL connect;

/*!
 * Whether the IM session is opened.
 */
@property (nonatomic, assign, readonly, getter=isClientOpened) BOOL clientOpened;

/*!
 * Invoked by the IM provider when a member's role changes.
 * `role` is the provider's role value, for example an `AVIMConversationMemberRole`.
 */
@property (nonatomic, copy) void (^ memberInfoChangedBlock)(id<LCCKConversationDelegate> conversation, NSString *byClientId, NSString *clientId, NSUInteger role);

- (void)reconnectForViewController:(UIViewController *)reconnectForViewController callback:(LCCKBooleanResultBlock)aCallback;

/*!
 * Asks the user whether to log in again after another device took over the session,
 * then invokes `forceReconnectSessionBlock`. IM providers call this for single sign-on errors.
 */
- (void)handleSingleSignOnError:(NSError *)error callback:(LCCKBooleanResultBlock)callback;

@end
