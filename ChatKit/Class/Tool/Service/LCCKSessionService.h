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

@interface LCCKSessionService : LCCKSingleton <LCCKSessionService>

@property (nonatomic, copy, readonly) NSString *clientId;

/*!
 * AVIMClient 实例
 */
@property (nonatomic, strong, readonly) AVIMClient *client;

/**
 *  是否和聊天服务器连通
 */
@property (nonatomic, assign, readonly) BOOL connect;

- (void)reconnectForViewController:(UIViewController *)reconnectForViewController callback:(LCCKBooleanResultBlock)aCallback;

@end
