//
//  UITableViewCell+CYLCellIdentifier.h
//  CYLChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/ChenYilong/CYLChatKit ) on 15/11/23.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010） . All rights reserved.
//

#import "CYLChatMessageCell.h"

@interface CYLCellIdentifierFactory : NSObject

/*!
 *  用来获取cellIdentifier
 */

+ (NSString *)cellIdentifierForMessageConfiguration:(id)message conversationType:(CYLConversationType)conversationType;

+ (NSString *)cacheKeyForMessage:(id)message;

@end
