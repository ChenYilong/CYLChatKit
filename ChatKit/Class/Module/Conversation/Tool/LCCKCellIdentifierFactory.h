//
//  UITableViewCell+LCCKCellIdentifier.h
//  LCCKChatBarExample
//
//  v2.1.1 Created by ElonChan ( https://github.com/leancloud/ChatKit-OC ) on 15/11/23.
//  Copyright © 2015年 https://LeanCloud.cn . All rights reserved.
//

#import "LCCKChatMessageCell.h"

@interface LCCKCellIdentifierFactory : NSObject

/**
 *  用来获取cellIdentifier
 */

+ (NSString *)cellIdentifierForMessageConfiguration:(id)message conversationType:(LCCKConversationType)conversationType;

+ (NSString *)cacheKeyForMessage:(id)message;

@end
