//
//  CYLServiceDefinition.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//  All the Typedefine for all kinds of services.

#import <UIKit/UIKit.h>
#import "CYLChatConstants.h"
#import "CYLSingleton.h"
#import "CYLMenuItem.h"
#import "CYLConversationProtocol.h"
#import "CYLIMMessageProtocol.h"
#import "CYLIMProvider.h"
#import <CoreLocation/CoreLocation.h>
@class CYLConversationViewController;
@class CYLConversationListViewController;
@class CYLMessage;

#pragma mark - CYLSessionService
/*!
 * @name CYLSessionService
 */

@protocol CYLSessionService <NSObject>

typedef void (^CYLReconnectSessionCompletionHandler)(BOOL succeeded, NSError *error);

/*!
 * @param granted granted fore single signOn
 * 默认允许重连，error的code为4111时，需要额外请求权限，才可标记为YES。
 */
typedef void (^CYLForceReconnectSessionBlock)(NSError *error, BOOL granted, __kindof UIViewController *viewController, CYLReconnectSessionCompletionHandler completionHandler);

@property (nonatomic, copy, readonly) NSString *clientId;
/*!
 * The underlying SDK client of the current `CYLIMProvider`, if it exposes one.
 * For the LeanCloud provider in the demo this is the SDK client.
 */
@property (nonatomic, strong, readonly) id client;
@property (nonatomic, assign) BOOL disableSingleSignOn;
@property (nonatomic, copy) CYLForceReconnectSessionBlock forceReconnectSessionBlock;

/*!
 * @param clientId You can use the user id in your user system as clientId, ChatKit will get the current user's information by both this id and the method `-[CYLChatService getProfilesForUserIds:callback:]`.
 * @param callback Callback
 */
- (void)openWithClientId:(NSString *)clientId callback:(CYLBooleanResultBlock)callback;

/*!
 * @param force Just for Single Sign On
 */
- (void)openWithClientId:(NSString *)clientId force:(BOOL)force callback:(CYLBooleanResultBlock)callback;
/*!
 * @brief Close the client
 * @param callback Callback
 */
- (void)closeWithCallback:(CYLBooleanResultBlock)callback;

/*!
 * set how you want to force reconnect session. It is usually usefully for losing session because of single sign-on, or weak network.
 */
- (void)setForceReconnectSessionBlock:(CYLForceReconnectSessionBlock)forceReconnectSessionBlock;

/*!
 * @param role The member role reported by the IM provider. For LeanCloud it is the SDK member role value.
 */
- (void)setMemberInfoChangedBlock:(void (^)(id<CYLConversationProtocol> conversation, NSString *byClientId, NSString *clientId, NSUInteger role))block;

@end

#pragma mark - CYLUserSystemService
/*!
 * @name CYLUserSystemService
 */

@protocol CYLUserSystemService <NSObject>

/*!
 *  @brief The block to execute with the users' information for the userIds. Always execute this block at some point when fetching profiles completes on main thread. Specify users' information how you want ChatKit to show.
 *  @attention If you fetch users fails, you should reture nil, meanwhile, give the error reason.
 */
typedef void(^CYLFetchProfilesCompletionHandler)(NSArray<id<CYLUserDelegate>> *users, NSError *error);

/*!
 *  @brief When LeanCloudChatKit wants to fetch profiles, this block will be invoked.
 *  @param userIds User ids
 *  @param completionHandler The block to execute with the users' information for the userIds. Always execute this block at some point during your implementation of this method on main thread. Specify users' information how you want ChatKit to show.
 */
typedef void(^CYLFetchProfilesBlock)(NSArray<NSString *> *userIds, CYLFetchProfilesCompletionHandler completionHandler);

@property (nonatomic, copy) CYLFetchProfilesBlock fetchProfilesBlock;

/*!
 *  @brief Add the ablitity to fetch profiles.
 *  @attention  You must get peer information by peer id with a synchronous implementation.
 *              If implemeted, this block will be invoked automatically by LeanCloudChatKit for fetching peer profile.
 */
- (void)setFetchProfilesBlock:(CYLFetchProfilesBlock)fetchProfilesBlock;

/*!
 * Remove all cached profiles.
 */
- (void)removeAllCachedProfiles;

/*!
 *  remove person profile cache
 *
 *  @param person id
 */
- (void)removeCachedProfileForPeerId:(NSString *)peerId;

- (void)getCachedProfileIfExists:(NSString *)userId name:(NSString **)name avatarURL:(NSURL **)avatarURL error:(NSError * __autoreleasing *)error;
- (void)getCachedProfileIfExists:(NSString *)userId name:(NSString **)name avatarURL:(NSURL **)avatarURL userTye:(NSInteger *)userType error:(NSError * __autoreleasing *)theError;
- (NSArray<id<CYLUserDelegate>> *)getCachedProfilesIfExists:(NSArray<NSString *> *)userIds error:(NSError * __autoreleasing *)error;

/*!
 * 如果从缓存查询到的userids数量不相符，则返回nil
 */
- (NSArray<id<CYLUserDelegate>> *)getCachedProfilesIfExists:(NSArray<NSString *> *)userIds shouldSameCount:(BOOL)shouldSameCount error:(NSError * __autoreleasing *)theError;
- (void)getProfileInBackgroundForUserId:(NSString *)userId callback:(CYLUserResultCallBack)callback;
- (void)getProfilesInBackgroundForUserIds:(NSArray<NSString *> *)userIds callback:(CYLUserResultsCallBack)callback;
- (NSArray<id<CYLUserDelegate>> *)getProfilesForUserIds:(NSArray<NSString *> *)userIds error:(NSError * __autoreleasing *)error;

@end

#pragma mark - CYLSignatureService
/*!
 * @name CYLSignatureService
 */

@protocol CYLSignatureService <NSObject>

/*!
 *  @brief The block to execute with the signature information for session. Always execute this block at some point when fetching signature information completes on main thread. Specify signature information how you want ChatKit pin to these actions: open, start(create conversation), kick, invite.
 *  @attention If you fetch the signature fails, you should reture nil, meanwhile, give the error reason.
 *  @param signature The signature object your IM provider expects. For LeanCloud it is the SDK signature object.
 */
typedef void(^CYLGenerateSignatureCompletionHandler)(id signature, NSError *error);

/*!
 *  @brief If implemeted, this block will be invoked automatically for pinning signature to these actions: open, start(create conversation), kick, invite.
 *  @param clientId - Id of operation initiator
 *  @param conversationId －  Id of target conversation
 *  @param action － Kinds of action:
                    "open": log in an account
                    "start": create a conversation
                    "add": invite myself or others to the conversation
                    "remove": kick someone out the conversation
 *  @param clientIds － Target id list for the action
 *  @param completionHandler The block to execute with the signature information for session. Always execute this block at some point during your implementation of this method on main thread. Specify signature information how you want ChatKit pin to these actions: open, start(create conversation), kick, invite.
 */
typedef void(^CYLGenerateSignatureBlock)(NSString *clientId, NSString *conversationId, NSString *action, NSArray *clientIds, CYLGenerateSignatureCompletionHandler completionHandler);

@property (nonatomic, copy) CYLGenerateSignatureBlock generateSignatureBlock;

/*!
 * @brief Add the ablitity to pin signature to these actions: open, start(create conversation), kick, invite.
 * @attention  If implemeted, this block will be invoked automatically for pinning signature to these actions: open, start(create conversation), kick, invite.
 */
- (void)setGenerateSignatureBlock:(CYLGenerateSignatureBlock)generateSignatureBlock;

@end

#pragma mark - CYLUIService
/*!
 * @name CYLUIService
 */

#import "CYLServiceDefinition.h"

@protocol CYLUIService <NSObject>

/*!

 * 传递触发的UIViewController对象

 */
#define CYLPreviewImageMessageUserInfoKeyFromController    @"CYLPreviewImageMessageUserInfoKeyFromController"
/*!
 * 传递触发的UIView对象
 */
#define CYLPreviewImageMessageUserInfoKeyFromView          @"CYLPreviewImageMessageUserInfoKeyFromView"
/*!
 * 传递触发的UIView对象
 */
#define CYLPreviewImageMessageUserInfoKeyFromPlaceholderView          @"CYLPreviewImageMessageUserInfoKeyFromPlaceholderView"

/*!
 *  打开某个profile的回调block
 *  @param userId 被点击的user 的 userId (clientId) ，与 user 属性中 clientId 的区别在于，本属性永远不为空，但 user可能为空。
 *  @param parentController 用于打开的顶层控制器
 */
typedef void(^CYLOpenProfileBlock)(NSString *userId, id<CYLUserDelegate> user, __kindof UIViewController *parentController);

@property (nonatomic, copy) CYLOpenProfileBlock openProfileBlock;

/*!
 *  打开某个profile的回调block
 *  @param userId 某个userId
 *  @param parentController 用于打开的顶层控制器
 */
- (void)setOpenProfileBlock:(CYLOpenProfileBlock)openProfileBlock;

/*!
 *  当ChatKit需要预览图片消息时，会调用这个block
 *  @param index 用户点击的图片消息在imageMessages中的下标
 *  @param allVisibleImages 元素可能是图片，也可能是NSURL，以及混合。
 *  @param userInfo 用来传递上下文信息，例如，从某个Controller触发，或者从某个view触发等，键值在下面定义
 */
typedef void(^CYLPreviewImageMessageBlock)(NSUInteger index, NSArray *allVisibleImages, NSArray *allVisibleThumbs, NSDictionary *userInfo);

@property (nonatomic, copy) CYLPreviewImageMessageBlock previewImageMessageBlock;

/*!

 * 传递触发的UIViewController对象

 */
#define CYLPreviewImageMessageUserInfoKeyFromController    @"CYLPreviewImageMessageUserInfoKeyFromController"
/*!
 * 传递触发的UIView对象
 */
#define CYLPreviewImageMessageUserInfoKeyFromView          @"CYLPreviewImageMessageUserInfoKeyFromView"
/*!
 * 传递触发的UIView对象
 */
#define CYLPreviewImageMessageUserInfoKeyFromPlaceholderView          @"CYLPreviewImageMessageUserInfoKeyFromPlaceholderView"

/*!
 *  当ChatKit需要预览图片消息时，会调用这个block.
 *  使用NSDictionary传递上下文信息，便于扩展
 */
- (void)setPreviewImageMessageBlock:(CYLPreviewImageMessageBlock)previewImageMessageBlock;

/*!
 *  当ChatKit需要预览地理位置消息时，会调用这个block
 *  @param location 地理位置坐标
 *  @param geolocations 地理位置的文字描述
 *  @param userInfo 用来传递上下文信息，例如，从某个Controller触发，或者从某个view触发等，键值在下面定义
 */
typedef void(^CYLPreviewLocationMessageBlock)(CLLocation *location, NSString *geolocations, NSDictionary *userInfo);

@property (nonatomic, copy) CYLPreviewLocationMessageBlock previewLocationMessageBlock;

/*!

 * 传递触发的UIViewController对象

 */
#define CYLPreviewLocationMessageUserInfoKeyFromController    @"CYLPreviewLocationMessageUserInfoKeyFromController"
/*!
 * 传递触发的UIView对象
 */
#define CYLPreviewLocationMessageUserInfoKeyFromView          @"CYLPreviewLocationMessageUserInfoKeyFromView"

/*!
 *  当ChatKit需要预览地理位置消息时，会调用这个block.
 *  使用NSDictionary传递上下文信息，便于扩展
 */
- (void)setPreviewLocationMessageBlock:(CYLPreviewLocationMessageBlock)previewLocationMessageBlock;

//TODO:可自定义长按能响应的消息类型
/*!
 *  ChatKit会在长按消息时，调用这个block
 *  @param message 被长按的消息
 *  @param userInfo 用来传递上下文信息，例如，从某个Controller触发，或者从某个view触发等，键值在下面定义
 */
typedef NSArray<CYLMenuItem *> *(^CYLLongPressMessageBlock)(CYLMessage *message, NSDictionary *userInfo);

@property (nonatomic, copy) CYLLongPressMessageBlock longPressMessageBlock;

/*!

 * 传递触发的UIViewController对象

 */
#define CYLLongPressMessageUserInfoKeyFromController    @"CYLLongPressMessageUserInfoKeyFromController"
/*!
 * 传递触发的UIView对象
 */
#define CYLLongPressMessageUserInfoKeyFromView          @"CYLLongPressMessageUserInfoKeyFromView"
/*!
 * message owner
 */
#define CYLLongPressMessageUserInfoKeyMessageOwner @"CYLLongPressMessageUserInfoKeyMessageOwner"
/*!
 * message cell
 */
#define CYLLongPressMessageUserInfoKeyMessageCell @"CYLLongPressMessageUserInfoKeyMessageCell"
/*!
 *  ChatKit会在长按消息时，调用这个block
 *  使用NSDictionary传递上下文信息，便于扩展
 */
- (void)setLongPressMessageBlock:(CYLLongPressMessageBlock)longPressMessageBlock;

/*!
 *  当ChatKit需要显示通知时，会调用这个block。
 *  开发者需要实现并设置这个block，以便给用户提示。
 *  @param viewController 当前的controller
 *  @param title 标题
 *  @param subtitle 子标题
 *  @param type 类型
 */
typedef void(^CYLShowNotificationBlock)(__kindof UIViewController *viewController, NSString *title, NSString *subtitle, CYLMessageNotificationType type);

@property (nonatomic, copy) CYLShowNotificationBlock showNotificationBlock;

/*!
 *  当ChatKit需要显示通知时，会调用这个block。
 *  开发者需要实现并设置这个block，以便给用户提示。
 *  @param viewController 当前的controller
 *  @param title 标题
 *  @param subtitle 子标题
 *  @param type 类型
 */
- (void)setShowNotificationBlock:(CYLShowNotificationBlock)showNotificationBlock;

/*!
 *  当ChatKit需要显示通知时，会调用这个block。
 *  开发者需要实现并设置这个block，以便给用户提示。
 *  @param viewController 当前的controller
 *  @param title 标题
 *  @param type 类型
 */

typedef void(^CYLHUDActionBlock)(__kindof UIViewController *viewController, UIView *view, NSString *title, CYLMessageHUDActionType type);

@property (nonatomic, copy) CYLHUDActionBlock HUDActionBlock;

/*!
 *  当ChatKit需要显示通知时，会调用这个block。
 *  开发者需要实现并设置这个block，以便给用户提示。
 *  @param viewController 当前的controller
 *  @param title 标题
 *  @param subtitle 子标题
 *  @param type 类型
 */
- (void)setHUDActionBlock:(CYLHUDActionBlock)HUDActionBlock;

typedef CGFloat (^CYLAvatarImageViewCornerRadiusBlock)(CGSize avatarImageViewSize);

@property (nonatomic, copy) CYLAvatarImageViewCornerRadiusBlock avatarImageViewCornerRadiusBlock;

/*!
 *  设置对话列表和聊天界面头像ImageView的圆角弧度
 *  注意，请在需要圆角矩形时设置，对话列表和聊天界面头像默认圆形。
 */
- (void)setAvatarImageViewCornerRadiusBlock:(CYLAvatarImageViewCornerRadiusBlock)avatarImageViewCornerRadiusBlock;

@end

#pragma mark - CYLSettingService
/*!
 * @name CYLSettingService
 */

@protocol CYLSettingService <NSObject>

/*!
 * You should always use like this, never forgive to cancel log before publishing.
 
 ```
 #ifndef __OPTIMIZE__
 [[CYLChatKit sharedInstance] setAllLogsEnabled:YES];
 #endif
 ```
 
 */
+ (void)setAllLogsEnabled:(BOOL)enabled;
+ (BOOL)allLogsEnabled;
+ (NSString *)ChatKitVersion;
- (void)syncBadge;

/*!
 * 禁止预览id
 * 如果不设置，或者设置为NO，在群聊需要显示最后一条消息的发送者时，会在网络请求用户昵称成功前，先显示id，然后，成功后再显示昵称。
 */
@property (nonatomic, assign, getter=isDisablePreviewUserId) BOOL disablePreviewUserId;

/*!
 *  是否使用开发证书去推送，默认为 NO。如果设为 YES 的话每条消息会带上这个参数，云代码利用 Hook 设置证书
 *  参考 https://github.com/leancloud/leanchat-cloudcode/blob/master/cloud/mchat.js
 */
@property (nonatomic, assign) BOOL useDevPushCerticate;
- (void)setBackgroundImage:(UIImage *)image forConversationId:(NSString *)conversationId scaledToSize:(CGSize)scaledToSize NS_SWIFT_NAME(setBackgroundImage(_:forConversationId:scaledToSize:));

@end

#pragma mark - CYLConversationService
/*!
 * @name CYLConversationService
 */

typedef void (^CYLConversationResultBlock)(id<CYLConversationProtocol> conversation, NSError *error);
typedef void (^CYLFetchConversationHandler) (id<CYLConversationProtocol> conversation, CYLConversationViewController *conversationController);
typedef void (^CYLConversationInvalidedHandler) (NSString *conversationId, CYLConversationViewController *conversationController, id<CYLUserDelegate> administrator, NSError *error);

@protocol CYLConversationService <NSObject>

@property (nonatomic, copy) CYLFetchConversationHandler fetchConversationHandler;

/*!
 * 设置获取 conversation 对象结束后的 Handler。 这里可以做异常处理，比如获取失败等操作。
 * 获取失败时，CYLConversationHandler 返回值中的 conversation 为 nil，成功时为正确的 conversation 值。
 */
- (void)setFetchConversationHandler:(CYLFetchConversationHandler)fetchConversationHandler;

@property (nonatomic, copy) CYLConversationInvalidedHandler conversationInvalidedHandler;

/*!
 *  会话失效的处理 block，如当群被解散或当前用户不再属于该会话时，对应会话会失效应当被删除并且关闭聊天窗口
 */
- (void)setConversationInvalidedHandler:(CYLConversationInvalidedHandler)conversationInvalidedHandler;

typedef void (^CYLFilterMessagesCompletionHandler)(NSArray *filteredMessages, NSError *error);
/*!
 * @param messages SDK messages conforming to `CYLIMMessageProtocol`. Return the filtered SDK messages.
 */
typedef void (^CYLFilterMessagesBlock)(id<CYLConversationProtocol> conversation, NSArray<id<CYLIMMessageProtocol>> *messages, CYLFilterMessagesCompletionHandler completionHandler);

/*!
 * 用于筛选消息，比如：群定向消息、筛选黑名单消息、黑名单消息
 * @attention 同步方法异步方法皆可
 */
- (void)setFilterMessagesBlock:(CYLFilterMessagesBlock)filterMessagesBlock;

@property (nonatomic, copy) CYLFilterMessagesBlock filterMessagesBlock;

/*!
 * @param granted 该消息允许被发送
 * @param error 消息为何不允许被发送
 */
typedef void (^CYLSendMessageHookCompletionHandler)(BOOL granted, NSError *error);
/*!
 * @param message The SDK message about to be sent, conforming to `CYLIMMessageProtocol`.
 */
typedef void (^CYLSendMessageHookBlock)(CYLConversationViewController *conversationController, id<CYLIMMessageProtocol> message, CYLSendMessageHookCompletionHandler completionHandler);

/*!
 * 用于HOOK掉发送消息的行为，可以实现比如：禁止黑名单用户发消息、禁止发送包含敏感词掉消息
 * @attention 同步方法异步方法皆可
 */
- (void)setSendMessageHookBlock:(CYLSendMessageHookBlock)sendMessageHookBlock;

@property (nonatomic, copy) CYLSendMessageHookBlock sendMessageHookBlock;

/*!

 * TODO:未实现

 */
typedef void (^CYLLoadLatestMessagesHandler)(CYLConversationViewController *conversationController, BOOL succeeded, NSError *error);

@property (nonatomic, copy) CYLLoadLatestMessagesHandler loadLatestMessagesHandler;

/*!
 * 设置获取历史纪录结束时的 Handler。 这里可以做异常处理，比如获取失败等操作。
 * 获取失败时，CYLViewControllerBooleanResultBlock 返回值中的 error 不为 nil，包含错误原因，成功时 succeeded 值为 YES。
 */
- (void)setLoadLatestMessagesHandler:(CYLLoadLatestMessagesHandler)loadLatestMessagesHandler;

- (void)createConversationWithMembers:(NSArray *)members type:(CYLConversationType)type unique:(BOOL)unique callback:(CYLConversationResultBlock)callback;

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

/*!
 *  插入一条最近对话
 *  @param conversation 会话
 */
- (void)insertRecentConversation:(id<CYLConversationProtocol>)conversation;

/*!
 *  增加未读数
 *  @param conversationId 相应对话
 */
- (void)increaseUnreadCountWithConversationId:(NSString *)conversationId;

/*!
 *  最近对话列表左滑删除本地数据库的对话，将不显示在列表
 *  @param conversationId 相应的对话
 */
- (void)deleteRecentConversationWithConversationId:(NSString *)conversationId;

/*!
 *  清空未读数
 *  @param conversationId 相应的对话
 */
- (void)updateUnreadCountToZeroWithConversationId:(NSString *)conversationId;

/*!
 *  删除全部缓存，比如当切换用户时，如果同一个人显示的名称和头像需要变更
 */
- (BOOL)removeAllCachedRecentConversations;

- (void)sendWelcomeMessageToPeerId:(NSString *)peerId text:(NSString *)text block:(CYLBooleanResultBlock)block;
- (void)sendWelcomeMessageToConversationId:(NSString *)conversationId text:(NSString *)text block:(CYLBooleanResultBlock)block;

@end

#pragma mark - CYLConversationsListService
/*!
 * @name CYLConversationsListService
 */

@protocol CYLConversationsListService <NSObject>

/*!
 * @param granted 该会话允许被展示
 * @param error 消息为何不允许被发送
 */
typedef void (^CYLConversationListShowHookCompletionHandler)(NSArray<id<CYLConversationProtocol> > *conversations, NSError *error);
typedef void (^CYLConversationListShowHookBlock)(NSArray<id<CYLConversationProtocol> > *conversations, CYLConversationListShowHookCompletionHandler completionHandler);

/*!
 * 用于HOOK掉展示会话的行为，可以实现比如：禁止黑名单用户会话
 * @attention 同步方法异步方法皆可
 */
- (void)setConversationListShowHookBlock:(CYLConversationListShowHookBlock)conversationListShowHookBlock;

@property (nonatomic, copy) CYLConversationListShowHookBlock conversationListShowHookBlock;

/*!
 *  选中某个对话后的回调
 *  @param conversation 被选中的对话
 */
typedef void(^CYLDidSelectConversationsListCellBlock)(NSIndexPath *indexPath, id<CYLConversationProtocol> conversation, CYLConversationListViewController *controller);

/*!
 *  选中某个对话后的回调
 */
@property (nonatomic, copy) CYLDidSelectConversationsListCellBlock didSelectConversationsListCellBlock __deprecated_msg("CYLDidSelectConversationsListCellBlock is deprecated. Use <CYLConversationListViewControllerDelegate> instead");

/*!
 *  设置选中某个对话后的回调
 */
- (void)setDidSelectConversationsListCellBlock:(CYLDidSelectConversationsListCellBlock)didSelectConversationsListCellBlock __deprecated_msg("CYLDidSelectConversationsListCellBlock is deprecated. Use <CYLConversationListViewControllerDelegate> instead");

/*!
 *  删除某个对话后的回调
 *  @param conversation 被选中的对话
 */
typedef void(^CYLDidDeleteConversationsListCellBlock)(NSIndexPath *indexPath, id<CYLConversationProtocol> conversation, CYLConversationListViewController *controller);

/*!
 *  删除某个对话后的回调
 */
@property (nonatomic, copy) CYLDidDeleteConversationsListCellBlock didDeleteConversationsListCellBlock;

/*!
 *  设置删除某个对话后的回调
 */
- (void)setDidDeleteConversationsListCellBlock:(CYLDidDeleteConversationsListCellBlock)didDeleteConversationsListCellBlock;

/*!
 *  对话左滑菜单设置block
 *  @return  需要显示的菜单数组
 *  - param conversation, 对话
 *  - param editActions, 默认的菜单数组，成员为 UITableViewRowAction 类型
 */
typedef NSArray *(^CYLConversationEditActionsBlock)(NSIndexPath *indexPath, NSArray<UITableViewRowAction *> *editActions, id<CYLConversationProtocol> conversation, CYLConversationListViewController *controller);

/*!
 *  可以通过这个block设置对话列表中每个对话的左滑菜单，这个是同步调用的，需要尽快返回，否则会卡住UI
 */
@property (nonatomic, copy) CYLConversationEditActionsBlock conversationEditActionBlock;

/*!
 *  设置对话列表中每个对话的左滑菜单，这个是同步调用的，需要尽快返回，否则会卡住UI
 */
- (void)setConversationEditActionBlock:(CYLConversationEditActionsBlock)conversationEditActionBlock;

typedef void(^CYLMarkBadgeWithTotalUnreadCountBlock)(NSInteger totalUnreadCount, __kindof UIViewController *controller);

@property (nonatomic, copy) CYLMarkBadgeWithTotalUnreadCountBlock markBadgeWithTotalUnreadCountBlock;

/*!
 * 如果不是TabBar样式，请实现该Blcok。如果不实现，默认会把 App 当作是 TabBar 样式，修改 navigationController 的 tabBarItem 的 badgeValue 数字显示，数字超出99显示省略号。
 */
- (void)setMarkBadgeWithTotalUnreadCountBlock:(CYLMarkBadgeWithTotalUnreadCountBlock)markBadgeWithTotalUnreadCountBlock;

@end

//TODO:CacheService;
