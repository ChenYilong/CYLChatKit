//
//  CYLSettingService.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/23.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLSettingService.h"
#import "NSBundle+CYLExtension.h"
#import "NSString+CYLExtension.h"
#import "UIImage+CYLExtension.h"
#import "CYLConversationService.h"
#if __has_include(<CYLChatKit/LCChatKit.h>)
#import <CYLChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

NSString *const CYLSettingServiceErrorDomain = @"CYLSettingServiceErrorDomain";

static BOOL CYLAllLogsEnabled;

@interface CYLSettingService ()

@property (nonatomic, strong) NSDictionary *defaultSettings;
@property (nonatomic, strong) NSDictionary *defaultTheme;
@property (nonatomic, strong) NSDictionary *messageBubbleCustomizeSettings;

@end

@implementation CYLSettingService
@synthesize useDevPushCerticate = _useDevPushCerticate;
@synthesize disablePreviewUserId = _disablePreviewUserId;

+ (void)setAllLogsEnabled:(BOOL)enabled {
    CYLAllLogsEnabled = enabled;
    id<CYLIMProvider> IMProvider = [LCChatKit sharedInstance].IMProvider;
    if ([IMProvider respondsToSelector:@selector(setAllLogsEnabled:)]) {
        [IMProvider setAllLogsEnabled:YES];
    }
}

- (id<CYLIMProvider>)pushProvider {
    return [LCChatKit sharedInstance].IMProvider;
}

+ (BOOL)allLogsEnabled {
    return CYLAllLogsEnabled;
}

+ (NSString *)ChatKitVersion {
    NSString *v = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *version = [NSString stringWithFormat:@"v%@", v];
    return version;
}

- (NSString *)tmpPath {
    return [[self getFilesPath] stringByAppendingFormat:@"%@", [[NSUUID UUID] UUIDString]];
}

- (NSString *)getFilesPath {
    NSString *appPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filesPath = [appPath stringByAppendingString:@"/files/"];
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSError *error;
    BOOL isDir = YES;
    if ([fileMan fileExistsAtPath:filesPath isDirectory:&isDir] == NO) {
        [fileMan createDirectoryAtPath:filesPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            //TODO: add debug model
            NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"error when create dir" );
            return filesPath;
        }
    }
    return filesPath;
}

- (NSString *)getPathByObjectId:(NSString *)objectId {
    return [[self getFilesPath] stringByAppendingFormat:@"%@", objectId];
}

- (NSString *)videoPathOfMessage:(id<CYLIMMessageProtocol>)message {
    // 视频播放会根据文件扩展名来识别格式
    NSString *format = nil;
    if ([message respondsToSelector:@selector(format)]) {
        format = [(id)message valueForKey:@"format"];
    }
    return [[self getFilesPath] stringByAppendingFormat:@"%@.%@", message.messageId, format];
}

- (void)registerForRemoteNotification {
    id<CYLIMProvider> pushProvider = self.pushProvider;
    if ([pushProvider respondsToSelector:@selector(registerForRemoteNotification)]) {
        [pushProvider registerForRemoteNotification];
    }
}

- (void)saveInstallationWithDeviceToken:(NSData *)deviceToken userId:(NSString *)userId {
    id<CYLIMProvider> pushProvider = self.pushProvider;
    if ([pushProvider respondsToSelector:@selector(saveInstallationWithDeviceToken:userId:)]) {
        [pushProvider saveInstallationWithDeviceToken:deviceToken userId:userId];
    }
}

//TODO:Never used
- (void)pushMessage:(NSString *)message userIds:(NSArray *)userIds block:(CYLBooleanResultBlock)block {
    id<CYLIMProvider> pushProvider = self.pushProvider;
    if ([pushProvider respondsToSelector:@selector(pushMessage:userIds:block:)]) {
        [pushProvider pushMessage:message userIds:userIds block:block];
        return;
    }
    !block ?: block(NO, nil);
}

- (void)cleanBadge {
    id<CYLIMProvider> pushProvider = self.pushProvider;
    if ([pushProvider respondsToSelector:@selector(cleanBadge)]) {
        [pushProvider cleanBadge];
        return;
    }
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    [application cancelAllLocalNotifications];
}

- (void)syncBadge {
    id<CYLIMProvider> pushProvider = self.pushProvider;
    if ([pushProvider respondsToSelector:@selector(syncBadge)]) {
        [pushProvider syncBadge];
    }
}

- (void)setUseDevPushCerticate:(BOOL)useDevPushCerticate {
    _useDevPushCerticate = useDevPushCerticate;
    id<CYLIMProvider> pushProvider = self.pushProvider;
    if ([pushProvider respondsToSelector:@selector(setUseDevPushCerticate:)]) {
        [pushProvider setUseDevPushCerticate:useDevPushCerticate];
    }
}

- (NSDictionary *)defaultSettings {
    if (_defaultSettings) {
        return _defaultSettings;
    }
    NSBundle *bundle = [NSBundle cyl_bundleForName:@"Other" class:[self class]];
    NSString *defaultSettingsFile = [bundle pathForResource:@"ChatKit-Settings" ofType:@"plist"];
    NSDictionary *defaultSettings = [[NSDictionary alloc] initWithContentsOfFile:defaultSettingsFile];
    _defaultSettings = defaultSettings;
    return _defaultSettings;
}

- (NSDictionary *)defaultTheme {
    if (_defaultTheme) {
        return _defaultTheme;
    }
    NSBundle *bundle = [NSBundle cyl_bundleForName:@"Other" class:[self class]];
    NSString *defaultThemeFile = [bundle pathForResource:@"ChatKit-Theme" ofType:@"plist"];
    NSDictionary *defaultTheme = [[NSDictionary alloc] initWithContentsOfFile:defaultThemeFile];
    _defaultTheme = defaultTheme;
    return _defaultTheme;
}

- (NSDictionary *)messageBubbleCustomizeSettings {
    if (_messageBubbleCustomizeSettings) {
        return _messageBubbleCustomizeSettings;
    }
    NSBundle *bundle = [NSBundle cyl_bundleForName:@"MessageBubble" class:[self class]];
    NSString *messageBubbleCustomizeSettingsFile = [bundle pathForResource:@"MessageBubble-Customize" ofType:@"plist"];
    NSDictionary *messageBubbleCustomizeSettings =  [[NSDictionary alloc] initWithContentsOfFile:messageBubbleCustomizeSettingsFile];
    _messageBubbleCustomizeSettings = messageBubbleCustomizeSettings;
    return _messageBubbleCustomizeSettings;
}

/**
 * @param capOrEdge 分为：cap_insets和edge_insets
 * @param position 主要分为：CommonLeft、CommonRight等
 */
- (UIEdgeInsets)messageBubbleCustomizeSettingsForPosition:(NSString *)position capOrEdge:(NSString *)capOrEdge {
    NSDictionary *CapOrEdgeDict = self.messageBubbleCustomizeSettings[@"BubbleStyle"][position][@"background"][capOrEdge];
    CGFloat top = [(NSNumber *)CapOrEdgeDict[@"top"] floatValue];
    CGFloat left = [(NSNumber *)CapOrEdgeDict[@"left"] floatValue];
    CGFloat bottom = [(NSNumber *)CapOrEdgeDict[@"bottom"] floatValue];
    CGFloat right = [(NSNumber *)CapOrEdgeDict[@"right"] floatValue];
    UIEdgeInsets CapOrEdge = UIEdgeInsetsMake(top, left, bottom, right);
    return CapOrEdge;
}

- (UIEdgeInsets)rightCapMessageBubbleCustomize {
    UIEdgeInsets rightCapMessageBubbleCustomizeSettings = [self messageBubbleCustomizeSettingsForPosition:@"CommonRight" capOrEdge:@"cap_insets"];
    return rightCapMessageBubbleCustomizeSettings;
}

- (UIEdgeInsets)rightEdgeMessageBubbleCustomize {
    UIEdgeInsets rightEdgeMessageBubbleCustomizeSettings = [self messageBubbleCustomizeSettingsForPosition:@"CommonRight" capOrEdge:@"edge_insets"];
    return rightEdgeMessageBubbleCustomizeSettings;
}

- (UIEdgeInsets)leftCapMessageBubbleCustomize {
    UIEdgeInsets leftCapMessageBubbleCustomizeSettings = [self messageBubbleCustomizeSettingsForPosition:@"CommonLeft" capOrEdge:@"cap_insets"];
    return leftCapMessageBubbleCustomizeSettings;
}

- (UIEdgeInsets)leftEdgeMessageBubbleCustomize {
    UIEdgeInsets leftEdgeMessageBubbleCustomizeSettings = [self messageBubbleCustomizeSettingsForPosition:@"CommonLeft" capOrEdge:@"edge_insets"];
    return leftEdgeMessageBubbleCustomizeSettings;
}

- (UIEdgeInsets)rightHollowCapMessageBubbleCustomize {
    UIEdgeInsets rightHollowCapMessageBubbleCustomize = [self messageBubbleCustomizeSettingsForPosition:@"HollowRight" capOrEdge:@"cap_insets"];
    return rightHollowCapMessageBubbleCustomize;
}

- (UIEdgeInsets)rightHollowEdgeMessageBubbleCustomize {
    UIEdgeInsets rightHollowCapMessageBubbleCustomize = [self messageBubbleCustomizeSettingsForPosition:@"HollowRight" capOrEdge:@"edge_insets"];
    return rightHollowCapMessageBubbleCustomize;
}

- (UIEdgeInsets)leftHollowCapMessageBubbleCustomize {
    UIEdgeInsets leftHollowCapMessageBubbleCustomize = [self messageBubbleCustomizeSettingsForPosition:@"HollowLeft" capOrEdge:@"cap_insets"];
    return leftHollowCapMessageBubbleCustomize;
}

- (UIEdgeInsets)leftHollowEdgeMessageBubbleCustomize {
    UIEdgeInsets leftHollowEdgeMessageBubbleCustomize = [self messageBubbleCustomizeSettingsForPosition:@"HollowLeft" capOrEdge:@"edge_insets"];
    return leftHollowEdgeMessageBubbleCustomize;
}

- (NSString *)imageNameForMessageBubbleCustomizeForPosition:(NSString *)position normalOrHighlight:(NSString *)normalOrHighlight {
    NSString *imageNameForMessageBubbleCustomizeForPosition = self.messageBubbleCustomizeSettings[@"BubbleStyle"][position][@"background"][normalOrHighlight];
    return imageNameForMessageBubbleCustomizeForPosition;
}

- (NSString *)leftNormalImageNameMessageBubbleCustomize {
    NSString *leftNormalImageNameMessageBubbleCustomize = [self imageNameForMessageBubbleCustomizeForPosition:@"CommonLeft" normalOrHighlight:@"image_name_normal"];
    return leftNormalImageNameMessageBubbleCustomize;
}

- (NSString *)leftHighlightImageNameMessageBubbleCustomize {
    NSString *leftHighlightImageNameMessageBubbleCustomize = [self imageNameForMessageBubbleCustomizeForPosition:@"CommonLeft" normalOrHighlight:@"image_name_highlight"];
    return leftHighlightImageNameMessageBubbleCustomize;
}

- (NSString *)rightHighlightImageNameMessageBubbleCustomize {
    NSString *rightHighlightImageNameMessageBubbleCustomize = [self imageNameForMessageBubbleCustomizeForPosition:@"CommonRight" normalOrHighlight:@"image_name_highlight"];
    return rightHighlightImageNameMessageBubbleCustomize;
}

- (NSString *)rightNormalImageNameMessageBubbleCustomize {
    NSString *rightNormalImageNameMessageBubbleCustomize = [self imageNameForMessageBubbleCustomizeForPosition:@"CommonRight" normalOrHighlight:@"image_name_normal"];
    return rightNormalImageNameMessageBubbleCustomize;
}

- (NSString *)hollowRightNormalImageNameMessageBubbleCustomize {
    NSString *hollowRightNormalImageNameMessageBubbleCustomize = [self imageNameForMessageBubbleCustomizeForPosition:@"HollowRight" normalOrHighlight:@"image_name_normal"];
    return hollowRightNormalImageNameMessageBubbleCustomize;
}

- (NSString *)hollowRightHighlightImageNameMessageBubbleCustomize {
    NSString *hollowRightHighlightImageNameMessageBubbleCustomize = [self imageNameForMessageBubbleCustomizeForPosition:@"HollowRight" normalOrHighlight:@"image_name_highlight"];
    return hollowRightHighlightImageNameMessageBubbleCustomize;
}

- (NSString *)hollowLeftNormalImageNameMessageBubbleCustomize {
   NSString *hollowLeftNormalImageNameMessageBubbleCustomize =  [self imageNameForMessageBubbleCustomizeForPosition:@"HollowLeft" normalOrHighlight:@"image_name_normal"];
    return hollowLeftNormalImageNameMessageBubbleCustomize;
}

- (NSString *)hollowLeftHighlightImageNameMessageBubbleCustomize {
    NSString *hollowLeftHighlightImageNameMessageBubbleCustomize =  [self imageNameForMessageBubbleCustomizeForPosition:@"HollowLeft" normalOrHighlight:@"image_name_highlight"];
    return hollowLeftHighlightImageNameMessageBubbleCustomize;
}


- (UIColor *)defaultThemeColorForKey:(NSString *)key {
    UIColor *defaultThemeColor = [self.defaultTheme[@"Colors"][key] cyl_hexStringToColor];
    return defaultThemeColor;
}

- (UIFont *)defaultThemeTextMessageFont {
    CGFloat defaultThemeTextMessageFontSize = [self.defaultTheme[@"Fonts"][@"ConversationView-Message-TextSystemFontSize"] floatValue];
    UIFont *defaultThemeTextMessageFont = [UIFont systemFontOfSize:defaultThemeTextMessageFontSize];
    return defaultThemeTextMessageFont;
}

- (void)setBackgroundImage:(UIImage *)image forConversationId:(NSString *)conversationId scaledToSize:(CGSize)scaledToSize {
    if (conversationId.length == 0 || !conversationId) {
        return;
    }
    image = [image cyl_scalingPatternImageToSize:scaledToSize];
    NSData *imageData = (UIImagePNGRepresentation(image) ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, 1));
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [[NSUUID UUID] UUIDString]];
    NSString *imagePath = [imageName cyl_pathForConversationBackgroundImage];;
    [[NSFileManager defaultManager] createFileAtPath:imagePath contents:imageData attributes:nil];
    if (conversationId.length > 0) {
        NSString *customImageNameKey = [NSString stringWithFormat:@"%@%@_%@", CYLCustomConversationViewControllerBackgroundImageNamePrefix, [CYLSessionService sharedInstance].clientId, conversationId];
        [[NSUserDefaults standardUserDefaults] setObject:imageName forKey:customImageNameKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:imageName forKey:CYLDefaultConversationViewControllerBackgroundImageName];
    }
    NSDictionary *userInfo = @{
                               CYLNotificationConversationViewControllerBackgroundImageDidChangedUserInfoConversationIdKey : conversationId,
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:CYLNotificationConversationViewControllerBackgroundImageDidChanged object:userInfo];
}

@end
