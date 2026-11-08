//
//  LCCKMessageSendStateView.h
//  LCCKChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/23.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol LCCKSendImageViewDelegate <NSObject>
@required
- (void)resendMessage:(id)sender;
@end

#import "LCCKConstants.h"

@interface LCCKMessageSendStateView : UIButton

@property (nonatomic, assign) LCCKMessageSendState messageSendState;
@property (nonatomic, weak) id<LCCKSendImageViewDelegate> delegate;

@end
