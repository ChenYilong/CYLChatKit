//
//  LCCKContactManager.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/3/10.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCCKContactManager : NSObject

+ (instancetype)defaultManager;

- (NSArray *)fetchContactPeerIds;
- (BOOL)existContactForPeerId:(NSString *)peerId;
- (BOOL)addContactForPeerId:(NSString *)peerId;
- (BOOL)removeContactForPeerId:(NSString *)peerId;

@end
