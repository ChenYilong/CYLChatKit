//
//  LCChatKit.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan  on 18/6/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "LCChatKit.h"

@interface LCChatKit ()
/*!
 *  appId
 */
@property (nonatomic, copy, readwrite) NSString *appId;

/*!
 *  appkey
 */
@property (nonatomic, copy, readwrite) NSString *appKey;
@end

@implementation LCChatKit
@synthesize forceReconnectSessionBlock = _forceReconnectSessionBlock;
@synthesize fetchProfilesBlock = _fetchProfilesBlock;
@synthesize generateSignatureBlock = _generateSignatureBlock;
@synthesize openProfileBlock = _openProfileBlock;
@synthesize previewImageMessageBlock = _previewImageMessageBlock;
@synthesize previewLocationMessageBlock = _previewLocationMessageBlock;
@synthesize longPressMessageBlock = _longPressMessageBlock;
@synthesize showNotificationBlock = _showNotificationBlock;
@synthesize HUDActionBlock = _HUDActionBlock;
@synthesize avatarImageViewCornerRadiusBlock = _avatarImageViewCornerRadiusBlock;
@synthesize useDevPushCerticate = _useDevPushCerticate;
@synthesize didSelectConversationsListCellBlock = _didSelectConversationsListCellBlock;
@synthesize didDeleteConversationsListCellBlock = _didDeleteConversationsListCellBlock;
@synthesize conversationEditActionBlock = _conversationEditActionBlock;
@synthesize markBadgeWithTotalUnreadCountBlock = _markBadgeWithTotalUnreadCountBlock;
@synthesize conversationInvalidedHandler = _conversationInvalidedHandler;
@synthesize fetchConversationHandler = _fetchConversationHandler;
@synthesize loadLatestMessagesHandler = _loadLatestMessagesHandler;
@synthesize disableSingleSignOn = _disableSingleSignOn;
@synthesize filterMessagesBlock = _filterMessagesBlock;
@synthesize sendMessageHookBlock = _sendMessageHookBlock;
@synthesize conversationListShowHookBlock = _conversationListShowHookBlock;

#pragma mark -

+ (id)copyWithZone:(NSZone *)zone {
    // Not allow copying to a different zone
    return [self sharedInstance];
}

/**
 * create a singleton instance of LCChatKit
 */
+ (instancetype)sharedInstance {
    static LCChatKit *_sharedLCChatKit = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLCChatKit = [[self alloc] init];
    });
    return _sharedLCChatKit;
}

#pragma mark -
#pragma mark - LCChatKit Method

+ (void)setAppId:(NSString *)appId appKey:(NSString *)appKey {
    id<CYLIMProvider> IMProvider = [LCChatKit sharedInstance].IMProvider;
    if ([IMProvider respondsToSelector:@selector(setAppId:appKey:)]) {
        [IMProvider setAppId:appId appKey:appKey];
    }
    [LCChatKit sharedInstance].appId = appId;
    [LCChatKit sharedInstance].appKey = appKey;
    if ([CYLSettingService allLogsEnabled]) {
        CYLLog(@"ChatKit Version is %@", [CYLSettingService ChatKitVersion]);
    }
}

#pragma mark -
#pragma mark - Service Delegate Method

- (CYLSessionService *)sessionService {
    return [CYLSessionService sharedInstance];
}

- (CYLUserSystemService *)userSystemService {
    return [CYLUserSystemService sharedInstance];
}

- (CYLSignatureService *)signatureService {
    return [CYLSignatureService sharedInstance];
}

- (CYLSettingService *)settingService {
    return [CYLSettingService sharedInstance];
}

- (CYLUIService *)UIService {
    return [CYLUIService sharedInstance];
}

- (CYLConversationService *)conversationService {
    return [CYLConversationService sharedInstance];
}

- (CYLConversationListService *)conversationListService {
    return [CYLConversationListService sharedInstance];
}

#pragma mark - CYLSessionService
///=============================================================================
/// @name CYLSessionService
///=============================================================================

- (NSString *)clientId {
    return self.sessionService.clientId;
}

- (id)client {
    return self.sessionService.client;
}

- (void)openWithClientId:(NSString *)clientId callback:(CYLBooleanResultBlock)callback {
    [self.sessionService openWithClientId:clientId callback:callback];
}

- (void)openWithClientId:(NSString *)clientId force:(BOOL)force callback:(CYLBooleanResultBlock)callback {
    [self.sessionService openWithClientId:clientId force:force callback:callback];
}

- (void)closeWithCallback:(CYLBooleanResultBlock)callback {
    [self.sessionService closeWithCallback:callback];
}

- (void)setForceReconnectSessionBlock:(CYLForceReconnectSessionBlock)forceReconnectSessionBlock {
    [self.sessionService setForceReconnectSessionBlock:forceReconnectSessionBlock];
}

- (void)setDisableSingleSignOn:(BOOL)disableSingleSignOn {
    self.sessionService.disableSingleSignOn = disableSingleSignOn;
}

- (void)setMemberInfoChangedBlock:(void (^)(id<CYLConversationProtocol> conversation, NSString *byClientId, NSString *clientId, NSUInteger role))block {
    self.sessionService.memberInfoChangedBlock = block;
}
#pragma mark - CYLUserSystemService
///=============================================================================
/// @name CYLUserSystemService
///=============================================================================

- (void)setFetchProfilesBlock:(CYLFetchProfilesBlock)fetchProfilesBlock {
    [self.userSystemService setFetchProfilesBlock:fetchProfilesBlock];
}

- (void)removeCachedProfileForPeerId:(NSString *)peerId {
    [self.userSystemService removeCachedProfileForPeerId:peerId];
}

- (void)removeAllCachedProfiles {
    [self.userSystemService removeAllCachedProfiles];
}

- (void)getCachedProfileIfExists:(NSString *)userId name:(NSString **)name avatarURL:(NSURL **)avatarURL error:(NSError * __autoreleasing *)error {
    [self.userSystemService getCachedProfileIfExists:userId name:name avatarURL:avatarURL error:error];
}

// The two members below are required by CYLUserSystemService but were never forwarded, so calling them on
// LCChatKit raised "unrecognized selector".
- (CYLFetchProfilesBlock)fetchProfilesBlock {
    return self.userSystemService.fetchProfilesBlock;
}

- (void)getCachedProfileIfExists:(NSString *)userId name:(NSString **)name avatarURL:(NSURL **)avatarURL userTye:(NSInteger *)userType error:(NSError * __autoreleasing *)error {
    [self.userSystemService getCachedProfileIfExists:userId name:name avatarURL:avatarURL userTye:userType error:error];
}

- (NSArray<id<CYLUserDelegate>> *)getCachedProfilesIfExists:(NSArray<NSString *> *)userIds error:(NSError * __autoreleasing *)error {
   return [self.userSystemService getCachedProfilesIfExists:userIds error:error];
}
- (NSArray<id<CYLUserDelegate>> *)getCachedProfilesIfExists:(NSArray<NSString *> *)userIds shouldSameCount:(BOOL)shouldSameCount error:(NSError * __autoreleasing *)error {
    return [self.userSystemService getCachedProfilesIfExists:userIds shouldSameCount:shouldSameCount error:error];
}

- (void)getProfileInBackgroundForUserId:(NSString *)userId callback:(CYLUserResultCallBack)callback {
    [self.userSystemService getProfileInBackgroundForUserId:userId callback:callback];
}

- (void)getProfilesInBackgroundForUserIds:(NSArray<NSString *> *)userIds callback:(CYLUserResultsCallBack)callback {
    [self.userSystemService getProfilesInBackgroundForUserIds:userIds callback:callback];
}

- (NSArray<id<CYLUserDelegate>> *)getProfilesForUserIds:(NSArray<NSString *> *)userIds error:(NSError * __autoreleasing *)error {
    return [self.userSystemService getProfilesForUserIds:userIds error:error];
}

#pragma mark - CYLSignatureService
///=============================================================================
/// @name CYLSignatureService
///=============================================================================

- (void)setGenerateSignatureBlock:(CYLGenerateSignatureBlock)generateSignatureBlock {
    [self.signatureService setGenerateSignatureBlock:generateSignatureBlock];
}

- (CYLGenerateSignatureBlock)generateSignatureBlock {
    return [self.signatureService generateSignatureBlock];
}

#pragma mark - CYLUIService
///=============================================================================
/// @name CYLUIService
///=============================================================================

- (void)setOpenProfileBlock:(CYLOpenProfileBlock)openProfileBlock {
    [self.UIService setOpenProfileBlock:openProfileBlock];
}

- (void)setPreviewImageMessageBlock:(CYLPreviewImageMessageBlock)previewImageMessageBlock {
    [self.UIService setPreviewImageMessageBlock:previewImageMessageBlock];
}

- (void)setPreviewLocationMessageBlock:(CYLPreviewLocationMessageBlock)previewLocationMessageBlock {
    [self.UIService setPreviewLocationMessageBlock:previewLocationMessageBlock];
}

- (void)setShowNotificationBlock:(CYLShowNotificationBlock)showNotificationBlock {
    [self.UIService setShowNotificationBlock:showNotificationBlock];
}
- (void)setHUDActionBlock:(CYLHUDActionBlock)HUDActionBlock {
    [self.UIService setHUDActionBlock:HUDActionBlock];
}

- (void)setAvatarImageViewCornerRadiusBlock:(CYLAvatarImageViewCornerRadiusBlock)avatarImageViewCornerRadiusBlock {
    [self.UIService setAvatarImageViewCornerRadiusBlock:avatarImageViewCornerRadiusBlock];
}

- (CYLAvatarImageViewCornerRadiusBlock)avatarImageViewCornerRadiusBlock {
    return self.UIService.avatarImageViewCornerRadiusBlock;
}

- (void)setLongPressMessageBlock:(CYLLongPressMessageBlock)longPressMessageBlock {
    return [self.UIService setLongPressMessageBlock:longPressMessageBlock];
}

- (CYLLongPressMessageBlock)longPressMessageBlock {
    return self.UIService.longPressMessageBlock;
}

#pragma mark - CYLSettingService
///=============================================================================
/// @name CYLSettingService
///=============================================================================

+ (void)setAllLogsEnabled:(BOOL)enabled {
    [CYLSettingService setAllLogsEnabled:YES];
}

+ (BOOL)allLogsEnabled {
   return [CYLSettingService allLogsEnabled];
}

+ (NSString *)ChatKitVersion {
    return [CYLSettingService ChatKitVersion];
}

- (void)syncBadge {
    [self.settingService syncBadge];
}

- (BOOL)useDevPushCerticate {
    return [self.settingService useDevPushCerticate];
}

- (void)setUseDevPushCerticate:(BOOL)useDevPushCerticate {
    self.settingService.useDevPushCerticate = useDevPushCerticate;
}

- (BOOL)isDisablePreviewUserId {
    return self.settingService.isDisablePreviewUserId;
}

- (void)setDisablePreviewUserId:(BOOL)disablePreviewUserId {
    self.settingService.disablePreviewUserId = disablePreviewUserId;
}

- (void)setBackgroundImage:(UIImage *)image forConversationId:(NSString *)conversationId scaledToSize:(CGSize)scaledToSize {
    [self.settingService setBackgroundImage:image forConversationId:conversationId scaledToSize:scaledToSize];
}

#pragma mark - CYLConversationService
///=============================================================================
/// @name CYLConversationService
///=============================================================================

- (void)setFetchConversationHandler:(CYLFetchConversationHandler)fetchConversationHandler {
    [self.conversationService setFetchConversationHandler:fetchConversationHandler];
}

- (void)setConversationInvalidedHandler:(CYLConversationInvalidedHandler)conversationInvalidedHandler {
    [self.conversationService setConversationInvalidedHandler:conversationInvalidedHandler];
}

- (void)setLoadLatestMessagesHandler:(CYLLoadLatestMessagesHandler)loadLatestMessagesHandler {
    [self.conversationService setLoadLatestMessagesHandler:loadLatestMessagesHandler];
}

- (void)setFilterMessagesBlock:(CYLFilterMessagesBlock)filterMessagesBlock {
    [self.conversationService setFilterMessagesBlock:filterMessagesBlock];
}

- (void)setSendMessageHookBlock:(CYLSendMessageHookBlock)sendMessageHookBlock {
    [self.conversationService setSendMessageHookBlock:sendMessageHookBlock];
}

- (void)createConversationWithMembers:(NSArray *)members type:(CYLConversationType)type unique:(BOOL)unique callback:(CYLConversationResultBlock)callback {
    [self.conversationService createConversationWithMembers:members type:type unique:unique callback:callback];
}

- (void)fetchConversationWithConversationId:(NSString *)conversationId callback:(CYLConversationResultBlock)callback {
    [self.conversationService fetchConversationWithConversationId:conversationId callback:callback];
}

- (void)fetchConversationWithPeerId:(NSString *)peerId callback:(CYLConversationResultBlock)callback {
    [self.conversationService fetchConversationWithPeerId:peerId callback:callback];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self.conversationService didReceiveRemoteNotification:userInfo];
}

- (void)insertRecentConversation:(id<CYLConversationProtocol>)conversation {
    [self.conversationService insertRecentConversation:conversation];
}

- (void)increaseUnreadCountWithConversationId:(NSString *)conversationId {
    [self.conversationService increaseUnreadCountWithConversationId:conversationId];
}

- (void)deleteRecentConversationWithConversationId:(NSString *)conversationId {
    [self.conversationService deleteRecentConversationWithConversationId:conversationId];
}

- (void)updateUnreadCountToZeroWithConversationId:(NSString *)conversationId {
    [self.conversationService updateUnreadCountToZeroWithConversationId:conversationId];
}

- (BOOL)removeAllCachedRecentConversations {
    return [self.conversationService removeAllCachedRecentConversations];
}

- (void)sendWelcomeMessageToPeerId:(NSString *)peerId text:(NSString *)text block:(CYLBooleanResultBlock)block {
    [self.conversationService sendWelcomeMessageToPeerId:peerId text:text block:block];
}

- (void)sendWelcomeMessageToConversationId:(NSString *)conversationId text:(NSString *)text block:(CYLBooleanResultBlock)block {
    [self.conversationService sendWelcomeMessageToConversationId:conversationId text:text block:block];
}

#pragma mark - CYLConversationsListService
///=============================================================================
/// @name CYLConversationsListService
///=============================================================================

- (void)setDidSelectConversationsListCellBlock:(CYLDidSelectConversationsListCellBlock)didSelectConversationsListCellBlock {
    [self.conversationListService setDidSelectConversationsListCellBlock:didSelectConversationsListCellBlock];
}

- (void)setDidDeleteConversationsListCellBlock:(CYLDidDeleteConversationsListCellBlock)didDeleteConversationsListCellBlock {
    [self.conversationListService setDidDeleteConversationsListCellBlock:didDeleteConversationsListCellBlock];
}

- (void)setConversationEditActionBlock:(CYLConversationEditActionsBlock)conversationEditActionBlock {
    [self.conversationListService setConversationEditActionBlock:conversationEditActionBlock];
}

- (void)setMarkBadgeWithTotalUnreadCountBlock:(CYLMarkBadgeWithTotalUnreadCountBlock)markBadgeWithTotalUnreadCountBlock {
    [self.conversationListService setMarkBadgeWithTotalUnreadCountBlock:markBadgeWithTotalUnreadCountBlock];
}

- (void)setConversationListShowHookBlock:(CYLConversationListShowHookBlock)conversationListShowHookBlock {
    [self.conversationListService setConversationListShowHookBlock:conversationListShowHookBlock];
}

@end


