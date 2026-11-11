//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit

#import <Foundation/Foundation.h>
#import "CYLDemoSettingGroup.h"

@class CYLDemoUser, AVIMConversation;

@interface CYLDemoChatDetailHelper : NSObject

- (NSMutableArray *)chatDetailDataBySingleInfo:(AVIMConversation *)singleInfo;

- (NSMutableArray *)chatDetailDataByGroupInfo:(AVIMConversation *)groupInfo;

@end
