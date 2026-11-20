//
//  CYLMessageSendStateView.h
//  CYLChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/23.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol CYLSendImageViewDelegate <NSObject>
@required
- (void)resendMessage:(id)sender;
@end

#import "CYLChatConstants.h"

@interface CYLMessageSendStateView : UIButton

@property (nonatomic, assign) CYLMessageSendState messageSendState;
@property (nonatomic, weak) id<CYLSendImageViewDelegate> delegate;

@end
