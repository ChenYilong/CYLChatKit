//
//  NSMutableArray+LCCKMessageExtention.h
//  ChatKit
//
//  v0.8.5 Created by ElonChan on 16/5/26.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (LCCKMessageExtention)

+ (NSMutableArray *)lcck_messagesWithAVIMMessages:(NSArray *)avimTypedMessage;

- (void)lcck_removeMessageAtIndex:(NSUInteger)index;

- (id)lcck_messageAtIndex:(NSUInteger)index;

@end
