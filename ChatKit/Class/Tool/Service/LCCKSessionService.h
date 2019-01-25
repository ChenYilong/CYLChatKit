//
//  LCCKSessionService.h
//  LeanCloudChatKit-iOS
//
//  Created by ElonChan on 16/3/1.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

@import Foundation;
@import UIKit;
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

@end
