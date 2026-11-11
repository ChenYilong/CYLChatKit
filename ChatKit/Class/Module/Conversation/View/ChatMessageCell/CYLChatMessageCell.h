//
//  CYLChatMessageCell.h
//  CYLChatExample
//  CYLChatMessageCell 是所有CYLChatCell的父类
//  提供了delegate,messageOwner,messageType属性
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/13.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYLMessageSendStateView.h"
#import "CYLContentView.h"
#import "CYLChatConstants.h"
#import "CYLMessage.h"
#import "CYLSettingService.h"
#import "NSString+CYLExtension.h"

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#if __has_include(<MLLabel/MLLinkLabel.h>)
    #import <MLLabel/MLLinkLabel.h>
#else
    #import "MLLinkLabel.h"
#endif


@class CYLChatMessageCell;

@protocol CYLChatMessageCellSubclassing <NSObject>
@required
/*!
 子类实现此方法用于返回该类对应的消息类型
 @return 消息类型
 */
+ (CYLMessageMediaType)classMediaType;
@end

@protocol CYLChatMessageCellDelegate <NSObject>

- (void)messageCellTappedBlank:(CYLChatMessageCell *)messageCell;
- (void)messageCellTappedHead:(CYLChatMessageCell *)messageCell;
- (void)messageCellTappedMessage:(CYLChatMessageCell *)messageCell;
- (void)textMessageCellDoubleTapped:(CYLChatMessageCell *)messageCell;
- (void)resendMessage:(CYLChatMessageCell *)messageCell;
- (void)avatarImageViewLongPressed:(CYLChatMessageCell *)messageCell;
- (void)messageCell:(CYLChatMessageCell *)messageCell didTapLinkText:(NSString *)linkText linkType:(MLLinkType)linkType;
- (void)fileMessageDidDownload:(CYLChatMessageCell *)messageCell;
- (void)modifyMessage:(CYLChatMessageCell *)messageCell newMessage:(CYLMessage *)newMessage callback:(void (^)(BOOL, NSError *))callback;
- (void)recallMessage:(CYLChatMessageCell *)messageCell callback:(void (^)(BOOL, NSError *))callback;

@end

@interface CYLChatMessageCell : UITableViewCell

+ (void)registerCustomMessageCell;
+ (void)registerSubclass;
- (void)addGeneralView;

@property (nonatomic, strong) CYLMessage *message;

/*!

 * FIXME:retain cycle

 */
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *indexPath;

/*!
 *  显示用户头像
 */
@property (nonatomic, strong) UIImageView *officialSignImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;

/*!
 *  显示用户昵称的UILabel
 */
@property (nonatomic, strong) UILabel *nickNameLabel;

/*!
 *  显示用户消息主体的View,所有的消息用到的textView,imageView都会被添加到这个view中 -> CYLContentView 自带一个CAShapeLayer的蒙版
 */
@property (nonatomic, strong) CYLContentView *messageContentView;

/*!
 *  显示消息阅读状态的UIImageView -> 主要用于VoiceMessage
 */
@property (nonatomic, strong) UIImageView *messageReadStateImageView;

/*!
 *  显示消息发送状态的UIImageView -> 用于消息发送不成功时显示
 */
@property (nonatomic, strong) CYLMessageSendStateView *messageSendStateView;

/*!
 *  messageContentView的背景层
 */
@property (nonatomic, strong) UIImageView *messageContentBackgroundImageView;

@property (nonatomic, weak) id<CYLChatMessageCellDelegate> delegate;

/*!
 *  消息的类型,只读类型,会根据自己的具体实例类型进行判断
 */
@property (nonatomic, assign, readonly) CYLMessageMediaType mediaType;

/*!
 *  消息的所有者,只读类型,会根据自己的reuseIdentifier进行判断
 */
@property (nonatomic, assign, readonly) CYLMessageOwnerType messageOwner;

/*!
 *  消息群组类型,只读类型,根据reuseIdentifier判断
 */
@property (nonatomic, assign) CYLConversationType messageChatType;

/*!
 *  消息发送状态,当状态为CYLMessageSendFail或CYLMessageSendStateSending时,CYLmessageSendStateImageView显示
 */
@property (nonatomic, assign) CYLMessageSendState messageSendState;

/*!
 *  消息阅读状态,当状态为CYLMessageUnRead时,CYLmessageReadStateImageView显示
 */
@property (nonatomic, assign) CYLMessageReadState messageReadState;

@property (nonatomic, strong) UIColor *conversationViewMessageLeftTextColor; /**< 左侧文本消息文字颜色 */
@property (nonatomic, strong) UIColor *conversationViewMessageRightTextColor; /**< 右侧文本消息文字颜色 */

#pragma mark - Public Methods

- (void)setup;
- (void)configureCellWithData:(id)message;

@end


