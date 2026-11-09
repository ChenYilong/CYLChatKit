//
//  NSMutableArray+CYLMessageExtention.h
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/5/26.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (CYLMessageExtention)

/*!
 * Converts IM SDK messages (conforming to `CYLIMMessageProtocol`) for display with
 * `-[CYLIMProvider displayMessageFromIMMessage:]`, after applying `filterMessagesBlock`.
 * The historical name is kept for compatibility.
 */
+ (NSMutableArray *)cyl_messagesWithAVIMMessages:(NSArray *)avimTypedMessage;

- (void)cyl_removeMessageAtIndex:(NSUInteger)index;

- (id)cyl_messageAtIndex:(NSUInteger)index;

@end
