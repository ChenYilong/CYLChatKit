//
//  CYLInputViewPlugin.h
//  Pods
//
//  v2.1.1 Created by ElonChan on 16/7/19.
//
//

@class CYLChatBar;
@class CYLConversationViewController;

#import "CYLChatConstants.h"

@protocol CYLInputViewPluginSubclassing <NSObject>

@required

/*!
 子类实现此方法用于返回该类对应的消息类型
 @return 消息类型
 */
+ (CYLInputViewPluginType)classPluginType;

@end

@protocol CYLInputViewPluginDelegate <NSObject>
@required

/*!
 * 加载该插件的inputView
 */
@property (nonatomic, weak) CYLChatBar *inputViewRef;

/*!
 * 插件图标
 */
@property (nonatomic, readonly, strong) UIImage  *pluginIconImage;

/*!
 * 插件名称
 */
@property (nonatomic, readonly, copy) NSString *pluginTitle;

/*!
 * 插件对应的 view，会被加载到 inputView 上
 */
@property (nonatomic, readonly, strong) UIView *pluginContentView;

@property (nonatomic, weak) id<CYLInputViewPluginDelegate> delegate;

/*!
 * 发送自定消息的实现
 */
@property (nonatomic, copy) CYLIdResultBlock sendCustomMessageHandler;

/*!
 * 插件被选中运行
 */
- (void)pluginDidClicked;

@end

@interface CYLInputViewPlugin : UIControl <CYLInputViewPluginDelegate>

/*!
 * 插件类型，用来向对方发送当前用户正在做的操作，例如正在拍照或者正在选择地理位置，详见 CYLInputViewPluginType 的定义
 */
@property (nonatomic, readonly) CYLInputViewPluginType pluginType;
@property (nonatomic, readonly) CYLConversationViewController *conversationViewController;

- (void)fillWithPluginTitle:(NSString *)pluginTitle
                    pluginIconImage:(UIImage *)pluginIconImage;

+ (void)registerSubclass;

+ (void)registerCustomInputViewPlugin;

@end
