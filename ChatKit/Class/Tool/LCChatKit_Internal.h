//
//  LCChatKit_Internal.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/9.
//  Copyright © 2016年 ElonChan. All rights reserved.
//
#import "LCChatKit.h"

@class CYLSessionService;
@class CYLUserSystemService;
@class CYLSignatureService;
@class CYLSettingService;
@class CYLUIService;
@class CYLConversationService;
@class CYLConversationListService;

@interface LCChatKit (CYLServices)

/*!
 * open or close client Service
 */
@property (nonatomic, strong, readonly) CYLSessionService *sessionService;

/*!
 * User-System Service
 */
@property (nonatomic, strong, readonly) CYLUserSystemService *userSystemService;

/*!
 * Signature Service
 */
@property (nonatomic, strong, readonly) CYLSignatureService *signatureService;

/*!
 * Setting Service
 */
@property (nonatomic, strong, readonly) CYLSettingService *settingService;

/*!
 * UI Service
 */
@property (nonatomic, strong, readonly) CYLUIService *UIService;

/*!
 * Conversation Service
 */
@property (nonatomic, strong, readonly) CYLConversationService *conversationService;

/*!
 * Conversation List Service
 */
@property (nonatomic, strong, readonly) CYLConversationListService *conversationListService;

@end
