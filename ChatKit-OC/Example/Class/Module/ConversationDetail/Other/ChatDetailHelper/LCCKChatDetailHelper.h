//
//  LCChatKit.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//  Core class of LeanCloudChatKit

#import <Foundation/Foundation.h>
#import "LCCKSettingGroup.h"

@class LCCKUser, AVIMConversation;

@interface LCCKChatDetailHelper : NSObject

- (NSMutableArray *)chatDetailDataBySingleInfo:(AVIMConversation *)singleInfo;

- (NSMutableArray *)chatDetailDataByGroupInfo:(AVIMConversation *)groupInfo;

@end
