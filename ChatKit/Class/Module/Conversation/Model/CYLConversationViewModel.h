//
//  CYLConversationViewModel.h
//  CYLChatExample
//
//  v2.1.1 Created by ElonChan  ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/18.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CYLMessage.h"
#import "CYLChatConstants.h"
#import "CYLIMMessageProtocol.h"

@class CYLMessage;
@class CYLConversationViewController;
@class CYLChatMessageCell;

@protocol CYLConversationViewModelDelegate <NSObject>

@optional
- (void)reloadAfterReceiveMessage;
- (void)messageSendStateChanged:(CYLMessageSendState)sendState  withProgress:(CGFloat)progress forIndex:(NSUInteger)index;
- (void)messageReadStateChanged:(CYLMessageReadState)readState withProgress:(CGFloat)progress forIndex:(NSUInteger)index;
@end

@protocol CYLChatMessageCellDelegate;

typedef void (^CYLSendMessageSuccessBlock)(NSString *messageUUID);
typedef void (^CYLSendMessageSuccessFailedBlock)(NSString *messageUUID, NSError *error);

@interface CYLConversationViewModel : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign, readonly) NSUInteger messageCount;

@property (nonatomic, weak) id<CYLConversationViewModelDelegate> delegate;

- (instancetype)initWithParentViewController:(CYLConversationViewController *)parentViewController;

@property (nonatomic, strong, readonly) NSMutableArray<CYLMessage *> *dataArray;
/*!
 * The IM SDK messages loaded from the server, used for paging, editing, and recalling.
 * The historical name is kept for compatibility.
 */
@property (nonatomic, strong, readonly) NSMutableArray<id<CYLIMMessageProtocol>> *avimTypedMessage;

/**
 *  发送一条消息,消息已经通过addMessage添加到CYLConversationViewModel数组中了,此方法主要为了CYLChatServer发送消息过程
 */
- (void)sendMessage:(id)message;
- (void)sendMessage:(id)message mentionList:(NSArray<NSString *> *)mentionList;
- (void)sendCustomMessage:(id<CYLIMMessageProtocol>)customMessage;
- (void)sendCustomMessage:(id<CYLIMMessageProtocol>)aMessage
            progressBlock:(CYLProgressBlock)progressBlock
                  success:(CYLBooleanResultBlock)success
                   failed:(CYLBooleanResultBlock)failed;
- (void)sendLocalFeedbackTextMessge:(NSString *)localFeedbackTextMessge;
- (void)loadMessagesFirstTimeWithCallback:(CYLIdBoolResultBlock)callback;
- (void)loadOldMessages;
- (void)getAllVisibleImagesForSelectedMessage:(CYLMessage *)message
                             allVisibleImages:(NSArray **)allVisibleImages
                             allVisibleThumbs:(NSArray **)allVisibleThumbs
                         selectedMessageIndex:(NSNumber **)selectedMessageIndex;
- (void)resendMessageForMessageCell:(CYLChatMessageCell *)messageCell;
- (void)modifyMessageForMessageCell:(CYLChatMessageCell *)messageCell newMessage:(CYLMessage *)newMessage callback:(void (^)(BOOL, NSError *))callback;
- (void)recallMessageForMessageCell:(CYLChatMessageCell *)messageCell callback:(void (^)(BOOL, NSError *))callback;
- (void)resetBackgroundImage;
- (void)setDefaultBackgroundImage;

@end
