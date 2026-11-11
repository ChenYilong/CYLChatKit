//
//  CYLChatConstants.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/19.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//  Common typdef and constants, and so on.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CYLUserDelegate.h"

#pragma mark - Message Media Type
/*!
 * @name Message Media Type
 */

/*!
 * Media type of a message, owned by ChatKit so the UI layer does not depend on any IM SDK.
 * The underlying type is `int8_t` and the raw values match LeanCloud's message media type
 * values, so an IM provider can cast between the two types directly.
 * Positive values are reserved for custom messages.
 */
typedef NS_ENUM(int8_t, CYLMessageMediaType) {
    CYLMessageMediaTypeNone = 0,
    CYLMessageMediaTypeText = -1,
    CYLMessageMediaTypeImage = -2,
    CYLMessageMediaTypeAudio = -3,
    CYLMessageMediaTypeVideo = -4,
    CYLMessageMediaTypeLocation = -5,
    CYLMessageMediaTypeFile = -6,
    CYLMessageMediaTypeSystem = -7,
    CYLMessageMediaTypeRecalled = -127,
};

/*!
 * Error codes ChatKit recognizes from an IM provider.
 * `CYLIMErrorCodeConnectionLost` matches LeanCloud's "connection lost" error code.
 */
typedef NS_ENUM(NSInteger, CYLIMErrorCode) {
    CYLIMErrorCodeConnectionLost = 9001,
};

#pragma mark - Base ViewController Life Time Block
/*!
 * @name Base ViewController Life Time Block
 */

/*!

 * Callback with Custom type

 */
typedef void (^CYLUserResultsCallBack)(NSArray<id<CYLUserDelegate>> *users, NSError *error);
typedef void (^CYLUserResultCallBack)(id<CYLUserDelegate> user, NSError *error);
/*!
 * Callback with Foundation type
 */
typedef void (^CYLBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^CYLViewControllerBooleanResultBlock)(__kindof UIViewController *viewController, BOOL succeeded, NSError *error);

typedef void (^CYLIntegerResultBlock)(NSInteger number, NSError *error);
typedef void (^CYLStringResultBlock)(NSString *string, NSError *error);
typedef void (^CYLDictionaryResultBlock)(NSDictionary * dict, NSError *error);
typedef void (^CYLArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^CYLSetResultBlock)(NSSet *channels, NSError *error);
typedef void (^CYLDataResultBlock)(NSData *data, NSError *error);
typedef void (^CYLIdResultBlock)(id object, NSError *error);
typedef void (^CYLIdBoolResultBlock)(BOOL succeeded, id object, NSError *error);
typedef void (^CYLRequestAuthorizationBoolResultBlock)(BOOL granted, NSError *error);

/*!

 * Callback with Function object

 */
typedef void (^CYLVoidBlock)(void);
typedef void (^CYLErrorBlock)(NSError *error);
typedef void (^CYLImageResultBlock)(UIImage * image, NSError *error);
typedef void (^CYLProgressBlock)(NSInteger percentDone);

#pragma mark - Common Define
/*!
 * =============================================================================
 * @name Common Define
 * =============================================================================
 */
static CGFloat const CYLAvatarToMessageContent = 5.f;
static CGFloat const CYLAvatarBottomToMessageContentTop = -1.f;
static CGFloat const CYL_MSG_CELL_EDGES_OFFSET = 16;

#define CYL_STATUSBAR_HEIGHT ([UIApplication sharedApplication].statusBarFrame.size.height)

/*!
 * Whether the device has a bottom safe area (the home indicator): iPhone X and later. The check is the bottom safe
 * area of the key window, not the status bar height: the old check (`status bar == 44`) was NO on iPhones with a
 * Dynamic Island, whose status bar is taller.
 */
static inline BOOL CYLChatDeviceHasBottomSafeArea(void) {
    UIWindow *window = nil;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) {
            continue;
        }
        for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {
            if (candidate.isKeyWindow) {
                window = candidate;
                break;
            }
        }
        if (window) {
            break;
        }
    }
    // Apps without scenes (like the demo) have no scene windows.
    if (!window) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    return window.safeAreaInsets.bottom > 0;
}
#define CYL_IS_iPHONEX (CYLChatDeviceHasBottomSafeArea())
static NSInteger const CYL_iPHONEX_OFFSET = 34;

static NSString *const CYLBadgeTextForNumberGreaterThanLimit = @"···";

#define CYL_DEPRECATED(explain) __attribute__((deprecated(explain)))

#ifndef CYLLocalizedStrings
#define CYLLocalizedStrings(key) \
    NSLocalizedStringFromTableInBundle(key, @"LCChatKitString", [NSBundle cyl_bundleForName:@"Other" class:[CYLChatKit class]], nil)
#endif

/*!
 * Function form of `CYLLocalizedStrings` for Swift callers (Swift cannot import function-like macros). Same bundle and
 * table: `Other.bundle`, `LCChatKitString`.
 */
FOUNDATION_EXTERN NSString *CYLLocalizedStringForKey(NSString *key);


#ifdef DEBUG
#define CYLLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);
#else
#   define CYLLog(...)
#endif

#define XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8    __has_include(<UserNotifications/UserNotifications.h>)
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

static NSString * const CYLNotificationSessionResumed = @"CYLNotificationSessionResumed";

#pragma mark - Notification Name
/*!
 * @name Notification Name
 */

/*!
 *  未读数改变了。通知去服务器同步 installation 的badge
 */
static NSString *const CYLNotificationUnreadsUpdated = @"CYLNotificationUnreadsUpdated";

/*!
 *  消息到来了，通知聊天页面和最近对话页面刷新
 */
static NSString *const CYLNotificationMessageReceived = @"CYLNotificationMessageReceived";

/*!
 *  消息被修改了，通知聊天页面和最近对话页面刷新
 */
static NSString *const CYLNotificationMessageUpdated = @"CYLNotificationMessageUpdated";

static NSString *const CYLNotificationMessageSent = @"CYLNotificationMessageSent";

/*!
 *  消息到来了，通知聊天页面和最近对话页面刷新
 */
static NSString *const CYLNotificationCustomMessageReceived = @"CYLNotificationCustomMessageReceived";

static NSString *const CYLNotificationCustomTransientMessageReceived = @"CYLNotificationCustomTransientMessageReceived";

/*!
 *  消息到达对方了，通知聊天页面更改消息状态
 */
static NSString *const CYLNotificationMessageDelivered = @"CYLNotificationMessageDelivered";

/*!
 *  消息对方已读，通知聊天页面更改消息状态
 */
static NSString *const CYLNotificationMessageRead = @"CYLNotificationMessageRead";

/*!
 *  对话的元数据变化了，通知页面刷新
 */
static NSString *const CYLNotificationConversationUpdated = @"CYLNotificationConversationUpdated";

/*!
 *  聊天服务器连接状态更改了，通知最近对话和聊天页面是否显示红色警告条
 */
static NSString *const CYLNotificationConnectivityUpdated = @"CYLNotificationConnectivityUpdated";

/*!
 * 会话失效，如当群被解散或当前用户不再属于该会话时，对应会话会失效应当被删除并且关闭聊天窗口
 */
static NSString *const CYLNotificationCurrentConversationInvalided = @"CYLNotificationCurrentConversationInvalided";

/*!
 * 对话聊天背景切换
 */
static NSString *const CYLNotificationConversationViewControllerBackgroundImageDidChanged = @"CYLNotificationConversationViewControllerBackgroundImageDidChanged";

static NSString *const CYLNotificationConversationViewControllerBackgroundImageDidChangedUserInfoConversationIdKey = @"CYLNotificationConversationViewControllerBackgroundImageDidChangedUserInfoConversationIdKey";


static NSString *const CYLNotificationConversationInvalided = @"CYLNotificationConversationInvalided";
static NSString *const CYLNotificationConversationListDataSourceUpdated = @"CYLNotificationConversationListDataSourceUpdated";
static NSString *const CYLNotificationContactListDataSourceUpdated = @"CYLNotificationContactListDataSourceUpdated";

static NSString *const CYLNotificationContactListDataSourceUpdatedUserInfoDataSourceKey = @"CYLNotificationContactListDataSourceUpdatedUserInfoDataSourceKey";

static NSString *const CYLNotificationContactListDataSourceUserIdType = @"CYLNotificationContactListDataSourceUserIdType";
static NSString *const CYLNotificationContactListDataSourceContactObjType = @"CYLNotificationContactListDataSourceContactObjType";
static NSString *const CYLNotificationContactListDataSourceUpdatedUserInfoDataSourceTypeKey = @"CYLNotificationContactListDataSourceUpdatedUserInfoDataSourceTypeKey";
static NSString *const CYLNotificationConversionImageMessageDidDownloaded = @"CYLNotificationConversionImageMessageDidDownloaded";


/*!
   *  发送语音消息没有权限。通知界面提醒用户
   */
static NSString *const CYLNotificationRecordNoPower = @"CYLChatBarRecordVoiceNoPower";

/*!
   *  发送文本消息过长。通知界面提醒用户
   */
static NSString *const CYLNotificationTextLengthOut = @"CYLChatBarTextLengthOut";

/*!
   *  发送语音消息倒计时结束。通知UI停止动效
   */
static NSString *const CYLNotificationRecordTimeOut = @"CYLChatBarRecordVoiceTimeOut";
static NSInteger const CYLNotificationTextLengthOutLength = 1000;
#pragma mark - Conversation Enum : Message Type and operation
/*!
 * @name Conversation Enum : Message Type and operation
 */

/*!
 *  消息聊天类型
 */
typedef NS_ENUM(NSUInteger, CYLConversationType){
    CYLConversationTypeSingle = 0 /**< 单人聊天,不显示nickname */,
    CYLConversationTypeGroup /**< 群组聊天,显示nickname */,
};

/*!
 *  消息拥有者类型
 */
typedef NS_ENUM(NSUInteger, CYLMessageOwnerType){
    CYLMessageOwnerTypeUnknown = 0 /**< 未知的消息拥有者 */,
    CYLMessageOwnerTypeSystem /**< 系统消息 */,
    CYLMessageOwnerTypeSelf NS_SWIFT_NAME(mine) /**< 自己发送的消息 */,
    CYLMessageOwnerTypeOther /**< 接收到的他人消息 */,
};

/*!

 * Kept for source compatibility. Use `CYLMessageMediaTypeSystem` in new code.

 */
static CYLMessageMediaType const kCYLIMMessageMediaTypeSystem = CYLMessageMediaTypeSystem;

/*!
 *  消息发送状态,自己发送的消息时有
 */
typedef NS_ENUM(NSUInteger, CYLMessageSendState){
    CYLMessageSendStateNone = 0,
    CYLMessageSendStateSending = 1, /**< 消息发送中 */
    CYLMessageSendStateSent, /**< 消息发送成功 */
    CYLMessageSendStateDelivered, /**< 消息对方已接收*/
    CYLMessageSendStateFailed, /**< 消息发送失败 */
    CYLMessageSendStateRead  /**< 消息已读 */
};

/*!
 *  消息读取状态,接收的消息时有
 */
typedef NS_ENUM(NSUInteger, CYLMessageReadState) {
    CYLMessageUnRead = 0 /**< 消息未读 */,
    CYLMessageReading /**< 正在接收 */,
    CYLMessageReaded /**< 消息已读 */,
};

/*!
 *  录音消息的状态
 */
typedef NS_ENUM(NSUInteger, CYLVoiceMessageState){
    CYLVoiceMessageStateNormal,/**< 未播放状态 */
    CYLVoiceMessageStateDownloading,/**< 正在下载中 */
    CYLVoiceMessageStatePlaying,/**< 正在播放 */
    CYLVoiceMessageStateCancel,/**< 播放被取消 */
};

/*!
 *  CYLChatMessageCell menu对应action类型
 */
typedef NS_ENUM(NSUInteger, CYLChatMessageCellMenuActionType) {
    CYLChatMessageCellMenuActionTypeCopy, /**< 复制 */
    CYLChatMessageCellMenuActionTypeRelay, /**< 转发 */
};
static CGFloat const kCYLVolumeMaxTimeLength = 60;
static NSInteger const kCYLOnePageSize = 10;
static NSString *const CYL_CONVERSATION_TYPE = @"type";
static NSString *const CYLInstallationKeyChannels = @"channels";

static NSString *const CYLMessageNotifacationUserInfoConversationKey = @"conversation";
static NSString *const CYLDidReceiveMessagesUserInfoMessagesKey = @"receivedMessages";
static NSString *const CYLDidReceiveCustomMessageUserInfoMessageKey = @"receivedCustomMessage";
static NSString *const CYLMessageNotifacationUserInfoMessageKey = @"message";

#define CYL_CURRENT_TIMESTAMP ([[NSDate date] timeIntervalSince1970] * 1000)
#define CYL_FUTURE_TIMESTAMP ([[NSDate distantFuture] timeIntervalSince1970] * 1000)
/*!
 * 整数或小数
 */
#define CYL_TIMESTAMP_REGEX @"^[0-9]*(.)?[0-9]*$"

#pragma mark - Custom Message
/*!
 * @name Custom Message
 */

/*!
 * 用来定义如何展示老版本未支持的自定义消息类型
 */
static NSString *const CYLCustomMessageDegradeKey = @"degrade";

/*!
 * 最近对话列表中最近一条消息的title，比如：最近一条消息是图片，可设置该字段内容为：`@"图片"`，相应会展示：`[图片]`
 */
static NSString *const CYLCustomMessageTypeTitleKey = @"typeTitle";

/*!
 * 用来显示在push提示中。
 */
static NSString *const CYLCustomMessageSummaryKey = @"summary";

static NSString *const CYLCustomMessageIsCustomKey = @"isCustom";

static NSString *const CYLCustomMessageOnlyVisiableForPartClientIds = @"OnlyVisiableForPartClientIds";

/*!
 * 对话类型，用来展示在推送提示中，以达到这样的效果： [群消息]Tom：hello gays!
 * 以枚举 CYLConversationType 定义为准，0为单聊，1为群聊
 */
static NSString *const CYLCustomMessageConversationTypeKey = @"conversationType";

#define CYLConversationGroupAvatarURLKey (CYLLocalizedStrings(@"ConversationAvatarURLKey") ?: @"avatarURL")

#pragma mark - Custom Message Cell
/*!
 * @name Custom Message Cell
 */

FOUNDATION_EXTERN NSMutableDictionary const * CYLChatMessageCellMediaTypeDict;

static NSString *const CYLCellIdentifierDefault = @"CYLCellIdentifierDefault";
static NSString *const CYLCellIdentifierCustom = @"CYLCellIdentifierCustom";
static NSString *const CYLCellIdentifierGroup = @"CYLCellIdentifierGroup";
static NSString *const CYLCellIdentifierSingle = @"CYLCellIdentifierSingle";
static NSString *const CYLCellIdentifierOwnerSelf = @"CYLCellIdentifierOwnerSelf";
static NSString *const CYLCellIdentifierOwnerOther = @"CYLCellIdentifierOwnerOther";
static NSString *const CYLCellIdentifierOwnerSystem = @"CYLCellIdentifierOwnerSystem";

#pragma mark - 聊天输入框默认插件类型定义
/*!
 * @name 聊天输入框默认插件类型定义
 */

FOUNDATION_EXTERN NSMutableDictionary const * CYLInputViewPluginDict;
FOUNDATION_EXTERN NSMutableArray const * CYLInputViewPluginArray;
static NSString *const CYLInputViewPluginTypeKey = @"CYLInputViewPluginTypeKey";
static NSString *const CYLInputViewPluginClassKey = @"CYLInputViewPluginClassKey";

/*!
 *  默认插件的类型定义
 */
typedef NS_ENUM(NSUInteger, CYLInputViewPluginType) {
    CYLInputViewPluginTypeDefault = 0,       /**< 默认未知类型 */
    CYLInputViewPluginTypeTakePhoto = -1,         /**< 拍照 */
    CYLInputViewPluginTypePickImage = -2,         /**< 选择照片 */
    CYLInputViewPluginTypeLocation = -3,          /**< 地理位置 */
    CYLInputViewPluginTypeShortVideo = -4,        /**< 短视频 */
//    CYLInputViewPluginTypeMorePanel= -7,         /**< 显示更多面板 */
//    CYLInputViewPluginTypeText = -1,              /**< 文本输入 */
//    CYLInputViewPluginTypeVoice = -2,             /**< 语音输入 */
};

#define CYL_CURRENT_CONVERSATIONVIEWCONTROLLER_OBJECT              \
({                                                                  \
    CYLConversationViewController *conversationViewController;     \
    conversationViewController = self.conversationViewController;   \
    conversationViewController;                                     \
}) 

#pragma mark - 自定义UI行为
/*!
 * =============================================================================
 * @name 自定义UI行为
 * =============================================================================
 */
static NSString *const CYLCustomConversationViewControllerBackgroundImageNamePrefix = @"CONVERSATION_BACKGROUND_";
static NSString *const CYLDefaultConversationViewControllerBackgroundImageName = @"CONVERSATION_BACKGROUND_ALL";
    
static CGFloat const CYLAnimateDuration = .25f;

#define CYLMessageCellLimit ([UIApplication sharedApplication].keyWindow.frame.size.width/5*3)

/*!

 * image STRETCH

 */
#define CYL_STRETCH_IMAGE(image, edgeInsets) [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch]
#define CYL_CONVERSATIONVIEWCONTROLLER_BACKGROUNDCOLOR [UIColor colorWithRed:234.0f/255.0f green:234/255.0f blue:234/255.f alpha:1.0f]
/*!
 *  提示信息的类型定义
 */
typedef NS_ENUM(NSUInteger, CYLMessageNotificationType) {
    /*!
     * 普通消息
     */
    CYLMessageNotificationTypeMessage = 0,
    /*!
     * 警告
     */
    CYLMessageNotificationTypeWarning,
    /*!
     * 错误
     */
    CYLMessageNotificationTypeError,
    /*!
     * 成功
     */
    CYLMessageNotificationTypeSuccess
};

/*!
 * HUD的行为
 */
typedef NS_ENUM(NSUInteger, CYLMessageHUDActionType) {
    /*!
     * 展示
     */
    CYLMessageHUDActionTypeShow,
    /*!
     * 隐藏
     */
    CYLMessageHUDActionTypeHide,
    /*!
     * 错误
     */
    CYLMessageHUDActionTypeError,
    /*!
     * 成功
     */
    CYLMessageHUDActionTypeSuccess
};

typedef enum : NSUInteger {
    CYLChatScrollDirectionNone,
    CYLChatScrollDirectionRight,
    CYLChatScrollDirectionLeft,
    CYLChatScrollDirectionUp,
    CYLChatScrollDirectionDown,
    CYLChatScrollDirectionCrazy,
} CYLChatScrollDirection;

/*!

 * TODO: to Delete

 */
typedef NS_ENUM(NSInteger, CYLBubbleMessageMenuSelectedType) {
    CYLBubbleMessageMenuSelectedTypeTextCopy = 0,
    CYLBubbleMessageMenuSelectedTypeTextTranspond = 1,
    CYLBubbleMessageMenuSelectedTypeTextFavorites = 2,
    CYLBubbleMessageMenuSelectedTypeTextMore = 3,
    
    CYLBubbleMessageMenuSelectedTypePhotoCopy = 4,
    CYLBubbleMessageMenuSelectedTypePhotoTranspond = 5,
    CYLBubbleMessageMenuSelectedTypePhotoFavorites = 6,
    CYLBubbleMessageMenuSelectedTypePhotoMore = 7,
    
    CYLBubbleMessageMenuSelectedTypeVideoTranspond = 8,
    CYLBubbleMessageMenuSelectedTypeVideoFavorites = 9,
    CYLBubbleMessageMenuSelectedTypeVideoMore = 10,
    
    CYLBubbleMessageMenuSelectedTypeVoicePlay = 11,
    CYLBubbleMessageMenuSelectedTypeVoiceFavorites = 12,
    CYLBubbleMessageMenuSelectedTypeVoiceTurnToText = 13,
    CYLBubbleMessageMenuSelectedTypeVoiceMore = 14,
};

#pragma mark - Succeed Message Store
/*!
 * @name Succeed Message Store
 */

#define CYLConversationTableName           @"conversations"
#define CYLConversationTableKeyId          @"id"
#define CYLConversationTableKeyData        @"data"
#define CYLConversationTableKeyUnreadCount @"unreadCount"
#define CYLConversationTableKeyMentioned   @"mentioned"
#define CYLConversationTableKeyDraft       @"draft"

#define CYLConversatoinTableCreateSQL                                       \
    @"CREATE TABLE IF NOT EXISTS " CYLConversationTableName @" ("           \
        CYLConversationTableKeyId           @" VARCHAR(63) PRIMARY KEY, "   \
        CYLConversationTableKeyData         @" BLOB NOT NULL, "             \
        CYLConversationTableKeyUnreadCount  @" INTEGER DEFAULT 0, "         \
        CYLConversationTableKeyMentioned    @" BOOL DEFAULT FALSE, "        \
        CYLConversationTableKeyDraft        @" VARCHAR(63)"                 \
    @")"

#define CYLConversationTableInsertSQL                           \
    @"INSERT OR IGNORE INTO " CYLConversationTableName @" ("    \
        CYLConversationTableKeyId               @", "           \
        CYLConversationTableKeyData             @", "           \
        CYLConversationTableKeyUnreadCount      @", "           \
        CYLConversationTableKeyMentioned        @", "           \
        CYLConversationTableKeyDraft                            \
    @") VALUES(?, ?, ?, ?, ?)"

#define CYLConversationTableWhereClause                         \
    @" WHERE " CYLConversationTableKeyId         @" = ?"

#define CYLConversationTableDeleteSQL                           \
    @"DELETE FROM " CYLConversationTableName                    \
    CYLConversationTableWhereClause

#define CYLDeleteConversationTable                              \
    @"DELETE FROM " CYLConversationTableName                    \

#define CYLConversationTableIncreaseUnreadCountSQL              \
    @"UPDATE " CYLConversationTableName         @" "            \
    @"SET " CYLConversationTableKeyUnreadCount  @" = "          \
            CYLConversationTableKeyUnreadCount  @" + ?"         \
    CYLConversationTableWhereClause

#define CYLConversationTableIncreaseOneUnreadCountSQL           \
    @"UPDATE " CYLConversationTableName         @" "            \
    @"SET " CYLConversationTableKeyUnreadCount  @" = "          \
            CYLConversationTableKeyUnreadCount  @" + 1 "        \
    CYLConversationTableWhereClause


#define CYLConversationTableUpdateUnreadCountSQL                \
    @"UPDATE " CYLConversationTableName         @" "            \
    @"SET " CYLConversationTableKeyUnreadCount  @" = ? "        \
    CYLConversationTableWhereClause

#define CYLConversationTableUpdateMentionedSQL                  \
    @"UPDATE " CYLConversationTableName         @" "            \
    @"SET " CYLConversationTableKeyMentioned    @" = ? "        \
    CYLConversationTableWhereClause

#define CYLConversationTableUpdateDraftSQL                      \
    @"UPDATE " CYLConversationTableName         @" "            \
    @"SET " CYLConversationTableKeyDraft        @" = ? "        \
    CYLConversationTableWhereClause


#define CYLConversationTableSelectSQL                           \
    @"SELECT * FROM " CYLConversationTableName                  \

#define CYLConversationTableSelectDraftSQL                      \
    @"SELECT draft FROM " CYLConversationTableName              \
    CYLConversationTableWhereClause

#define CYLConversationTableSelectOneSQL                        \
    @"SELECT * FROM " CYLConversationTableName                  \
    CYLConversationTableWhereClause

#define CYLConversationTableUpdateDataSQL                       \
    @"UPDATE " CYLConversationTableName @" "                    \
    @"SET " CYLConversationTableKeyData @" = ? "                \
    CYLConversationTableWhereClause                             \

#pragma mark - Failed Message Store
/*!
 * @name Failed Message Store
 */

#define CYLFaildMessageTable   @"failed_messages"
#define CYLKeyId               @"id"
#define CYLKeyConversationId   @"conversationId"
#define CYLKeyMessage          @"message"

#define CYLCreateTableSQL                                       \
    @"CREATE TABLE IF NOT EXISTS " CYLFaildMessageTable @"("    \
        CYLKeyId @" VARCHAR(63) PRIMARY KEY, "                  \
        CYLKeyConversationId @" VARCHAR(63) NOT NULL,"          \
        CYLKeyMessage @" BLOB NOT NULL"                         \
    @")"

#define CYLWhereConversationId \
    @" WHERE " CYLKeyConversationId @" = ? "

#define CYLSelectMessagesSQL                        \
    @"SELECT * FROM " CYLFaildMessageTable          \
    CYLWhereConversationId

#define CYLWhereKeyId \
    @" WHERE " CYLKeyId @" IN ('%@') "

/*!

 * SELECT * FROM failed_messages WHERE id IN ('%@')

 */
#define CYLSelectMessagesByIDSQL                        \
    @"SELECT * FROM " CYLFaildMessageTable              \
    CYLWhereKeyId

#define CYLInsertMessageSQL                             \
    @"INSERT OR IGNORE INTO " CYLFaildMessageTable @"(" \
        CYLKeyId @","                                   \
        CYLKeyConversationId @","                       \
        CYLKeyMessage                                   \
    @") values (?, ?, ?) "                               \

#define CYLDeleteMessageSQL                             \
    @"DELETE FROM " CYLFaildMessageTable @" "           \
    @"WHERE " CYLKeyId " = ? "                          \
    
