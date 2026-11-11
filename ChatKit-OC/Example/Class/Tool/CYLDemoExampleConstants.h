//
//  CYLDemoExampleConstants.h
//  ChatKit-OC
//
//  v0.8.5 Created by ElonChan on 16/8/13.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#ifndef CYLDemoExampleConstants_h
#define CYLDemoExampleConstants_h

#pragma mark - 用以产生Demo中的联系人数据的宏定义
///=============================================================================
/// @name 用以产生Demo中的联系人数据的宏定义
///=============================================================================

#define CYLDemoProfileKeyPeerId        @"peerId"
#define CYLDemoProfileKeyName          @"username"
#define CYLDemoProfileKeyAvatarURL     @"avatarURL"
#define CYLDemoDeveloperPeerId @"571dae7375c4cd3379024b2f"

//TODO:add more friends
#define CYLDemoContactProfiles \
@[ \
    @{ CYLDemoProfileKeyPeerId:CYLDemoDeveloperPeerId, CYLDemoProfileKeyName:@"ChatKit-iOS小秘书", CYLDemoProfileKeyAvatarURL:@"http://image17-c.poco.cn/mypoco/myphoto/20151211/16/17338872420151211164742047.png" },\
    @{ CYLDemoProfileKeyPeerId:@"Tom", CYLDemoProfileKeyName:@"Tom", CYLDemoProfileKeyAvatarURL:@"http://www.avatarsdb.com/avatars/tom_and_jerry2.jpg" },\
    @{ CYLDemoProfileKeyPeerId:@"Jerry", CYLDemoProfileKeyName:@"Jerry", CYLDemoProfileKeyAvatarURL:@"http://www.avatarsdb.com/avatars/jerry.jpg" },\
    @{ CYLDemoProfileKeyPeerId:@"Harry", CYLDemoProfileKeyName:@"Harry", CYLDemoProfileKeyAvatarURL:@"http://www.avatarsdb.com/avatars/young_harry.jpg" },\
    @{ CYLDemoProfileKeyPeerId:@"William", CYLDemoProfileKeyName:@"William", CYLDemoProfileKeyAvatarURL:@"http://www.avatarsdb.com/avatars/william_shakespeare.jpg" },\
    @{ CYLDemoProfileKeyPeerId:@"Bob", CYLDemoProfileKeyName:@"Bob", CYLDemoProfileKeyAvatarURL:@"http://www.avatarsdb.com/avatars/bath_bob.jpg" },\
    @{ CYLDemoProfileKeyPeerId:@"RP", CYLDemoProfileKeyName:@"RP", CYLDemoProfileKeyAvatarURL:@"http://www.avatarsdb.com/avatars/bath_bob.jpg" },\
    @{ CYLDemoProfileKeyPeerId:@"RP1", CYLDemoProfileKeyName:@"RP1", CYLDemoProfileKeyAvatarURL:@"http://www.avatarsdb.com/avatars/bath_bob.jpg" },\
    @{ CYLDemoProfileKeyPeerId:@"5771e7656be3ff0063a0dada", CYLDemoProfileKeyName:@"hhx2", CYLDemoProfileKeyAvatarURL:@"http://ac-x3o016bx.clouddn.com/jXyGZv2B2W4oc3OaEQtYDo3w7fJjgovHeXGuyfFD" },\
]

#define CYLDemoContactPeerIds \
    [CYLDemoContactProfiles valueForKeyPath:CYLDemoProfileKeyPeerId]

#define CYLDemoTestPersonProfiles \
@[ \
    @{ CYLDemoProfileKeyPeerId:@"Tom" },\
    @{ CYLDemoProfileKeyPeerId:@"Jerry" },\
    @{ CYLDemoProfileKeyPeerId:@"Harry" },\
    @{ CYLDemoProfileKeyPeerId:@"William" },\
    @{ CYLDemoProfileKeyPeerId:@"Bob" },\
    @{ CYLDemoProfileKeyPeerId:@"RP1" },\
    @{ CYLDemoProfileKeyPeerId:@"RP" },\
    @{ CYLDemoProfileKeyPeerId:@"5771e7656be3ff0063a0dada" },\
]

#define CYLDemoTestPeerIds \
    [CYLDemoTestPersonProfiles valueForKeyPath:CYLDemoProfileKeyPeerId]
#define __CYLDemoContactsOfDevelopers \
@[                                 \
    CYLDemoDeveloperPeerId,           \
]

#define __CYLDemoContactsOfSections \
@[                               \
    CYLDemoTestPeerIds,             \
    __CYLDemoContactsOfDevelopers,  \
]

#define CYLDemoTestConversationGroupAvatarURLs                      \
    @[                                                           \
      @"http://www.avatarsdb.com/avatars/mickey.jpg",            \
      @"http://www.avatarsdb.com/avatars/mickey_mouse.jpg",      \
      @"http://www.avatarsdb.com/avatars/all_together.jpg",      \
      @"http://www.avatarsdb.com/avatars/baby_disney.jpg",       \
      @"http://www.avatarsdb.com/avatars/donald_duck01.jpg",     \
      @"http://www.avatarsdb.com/avatars/Blue_Team_Disney.jpg",  \
      @"http://www.avatarsdb.com/avatars/mickey_mouse_smile.jpg",\
      @"http://www.avatarsdb.com/avatars/baby_pluto_dog.jpg",    \
      @"http://www.avatarsdb.com/avatars/donald_duck_angry.jpg", \
      @"http://www.avatarsdb.com/avatars/mickey_mouse_colors.jpg"\
]

#pragma mark - UI opera
///=============================================================================
/// @name UI opera
///=============================================================================

/// Reads a demo string from `CYLDemoExample.bundle` (table `CYLDemoExample`) and returns `defaultValue` when the key is
/// missing. Demo strings never come from the core bundles (AGENTS.md, "Internationalization and localization").
#define CYLDemoExampleLocalizedString(key, defaultValue) \
    ([[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"CYLDemoExample" ofType:@"bundle"]] \
        localizedStringForKey:(key) value:(defaultValue) table:@"CYLDemoExample"] ?: (defaultValue))

/// Historical name, kept for existing callers. It used to read the core table and ignore `default`.
#define localize(key, default) CYLDemoExampleLocalizedString(key, default)

#pragma mark - Message Bars

#define kStringMessageBarErrorTitle CYLDemoExampleLocalizedString(@"message.bar.error.title", nil)
#define kStringMessageBarErrorMessage CYLDemoExampleLocalizedString(@"message.bar.error.message", nil)
#define kStringMessageBarSuccessTitle CYLDemoExampleLocalizedString(@"message.bar.success.title", nil)
#define kStringMessageBarSuccessMessage CYLDemoExampleLocalizedString(@"message.bar.success.message", nil)

#pragma mark - Buttons

#define kStringButtonLabelSuccessMessage CYLDemoExampleLocalizedString(@"button.label.success.message", nil)
#define kStringButtonLabelErrorMessage CYLDemoExampleLocalizedString(@"button.label.error.message", nil)
#define kStringButtonLabelInfoMessage CYLDemoExampleLocalizedString(@"button.label.info.message", nil)
#define kStringButtonLabelHideAll CYLDemoExampleLocalizedString(@"button.label.hide.all", nil)

#pragma mark - Dict or UserDefaults Key
///=============================================================================
/// @name Dict or UserDefaults Key
///=============================================================================

static NSString *const CYLDEMO_KEY_USERNAME = @"CYLDEMO_KEY_USERNAME";
static NSString *const CYLDEMO_KEY_USERID = @"CYLDEMO_KEY_USERID";


#pragma mark - Other
///=============================================================================
/// @name Other
///=============================================================================

#define     CYLDEMO_DEFAULT_AVATAR_PATH    @"lcck_conversation_placeholder_avatar"
#define     CYLDemoURL(urlString)    [NSURL URLWithString:urlString]
#define     CYLDemoNoNilString(str)  (str.length > 0 ? str : @"")
#define     CYLDemoTimeStamp(date)   ([NSString stringWithFormat:@"%lf", [date timeIntervalSince1970]])
#define     CYLDemoColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]

#endif /* CYLDemoExampleConstants_h */
