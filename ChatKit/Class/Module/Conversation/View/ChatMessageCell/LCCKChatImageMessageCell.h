//
//  LCCKChatImageMessageCell.h
//  LCCKChatExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/16.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import "LCCKChatMessageCell.h"

@interface LCCKChatImageMessageCell : LCCKChatMessageCell<LCCKChatMessageCellSubclassing>

/**
 *  用来显示image的UIImageView
 */
@property (nonatomic, strong, readonly) UIImageView *messageImageView;

- (void)setUploadProgress:(CGFloat)uploadProgress;

@end
