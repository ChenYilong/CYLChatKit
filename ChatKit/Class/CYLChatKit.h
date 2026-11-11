//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//  Core class of LeanCloudChatKit

#import "ChatKitHeaders.h"

/*
 
 CYLChatKit manages the main service of the LeanCloudChatKit-iOS, such as, open, close, set up appid and appkey, and start chatting.
 
 To use CYLChatKit, steps are as follows:
 
 0. Set `[CYLChatKit sharedInstance].IMProvider` to an object implementing `CYLIMProvider`. ChatKit is UI only and does not link an IM SDK; the demo app ships a LeanCloud implementation, `CYLLeanCloudIMProvider`.
 1. Start your IM SDK in `-[AppDelegate application:didFinishLaunchingWithOptions:]` (the demo's LeanCloud provider does this in `-setAppId:appKey:`).
 2. Invoke `-[CYLChatKit setAppId:appKey:]` after your login **everytime** to start ChatKit service.
 3. Invoke `-[[CYLChatKit sharedInstance] openWithClientId:callback:]` to log in the IM service and begin chatting.
 4. Invoke `-[[CYLChatKit sharedInstance] closeWithCallback:]` to log out the IM service and end chatting.
 5. Implement `-[[CYLChatKit sharedInstance] setFetchProfilesBlock:]`, so ChatKit can get user information by user id. `CYLUserSystemService.h` file gives an example showing how to use AVUser as the user system.
 6. Implement `-[[CYLChatKit sharedInstance] setGenerateSignatureBlock:]`. If implemeted, this method will be invoked automatically for pinning signature to these actions: open, start(create conversation), kick, invite.
 
 */

@interface CYLChatKit : NSObject <CYLSessionService, CYLUserSystemService, CYLSignatureService, CYLSettingService, CYLUIService, CYLConversationService, CYLConversationsListService>

/*!
 * The IM backend used by ChatKit. Set it before calling `+setAppId:appKey:` or opening a session.
 * The provider is kept when ChatKit services are reset after closing a session.
 */
@property (nonatomic, strong) id<CYLIMProvider> IMProvider;

/*!
 *  appId
 */
@property (nonatomic, copy, readonly) NSString *appId;

/*!
 *  appkey
 */
@property (nonatomic, copy, readonly) NSString *appKey;

/*!
 *
 * @brief Set up application id(appId) and client key(appKey) to start ChatKit. If the IM provider implements `-setAppId:appKey:`, it is forwarded so the provider can start its SDK.
 * @attention Initializing your IM SDK does not replace this call. Call `+[CYLChatKit setAppId:appKey:]` after **every** login;
              the IM SDK itself only needs to be initialized once at launch.
 */
+ (void)setAppId:(NSString *)appId appKey:(NSString *)appKey;

/*!
 *  Returns the shared instance of CYLChatKit, creating it if necessary.
 *
 *  @return Shared instance of CYLChatKit.
 */
+ (instancetype)sharedInstance;

@end
