//
//  CYLChatKit.h
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//  Core class of LeanCloudChatKit


#import "CYLDemoChatDetailHelper.h"
#import "AVIMConversation+CYLDemoExtension.h"
#import "CYLDemoUser.h"
#import <AVOSCloudIM/AVOSCloudIM.h>

@implementation CYLDemoChatDetailHelper

- (NSMutableArray *)chatDetailDataBySingleInfo:(AVIMConversation *)singleInfo {
    CYLDemoSettingItem *users = CYLDemoCreateSettingItem(@"users");
    users.type = CYLDemoSettingItemTypeOther;
    CYLDemoSettingGroup *group1 = CYLDemoCreateSettingGroup(nil, nil, @[users]);
    
    CYLDemoSettingItem *top = CYLDemoCreateSettingItem(@"置顶聊天");
    top.type = CYLDemoSettingItemTypeSwitch;
    CYLDemoSettingItem *screen = CYLDemoCreateSettingItem(@"消息免打扰");
    screen.type = CYLDemoSettingItemTypeSwitch;
    screen.isSwithOn = singleInfo.muted;
    CYLDemoSettingGroup *group2 = CYLDemoCreateSettingGroup(nil, nil, (@[top, screen]));
    
    CYLDemoSettingItem *chatFile = CYLDemoCreateSettingItem(@"聊天文件");
    CYLDemoSettingGroup *group3 = CYLDemoCreateSettingGroup(nil, nil, @[chatFile]);
    
    CYLDemoSettingItem *chatBG = CYLDemoCreateSettingItem(@"设置当前聊天背景");
    CYLDemoSettingItem *chatHistory = CYLDemoCreateSettingItem(@"查找聊天内容");
    CYLDemoSettingGroup *group4 = CYLDemoCreateSettingGroup(nil, nil, (@[chatBG, chatHistory]));
    
    CYLDemoSettingItem *clear = CYLDemoCreateSettingItem(@"清空聊天记录");
    clear.showDisclosureIndicator = NO;
    CYLDemoSettingGroup *group5 = CYLDemoCreateSettingGroup(nil, nil, @[clear]);
    
    CYLDemoSettingItem *report = CYLDemoCreateSettingItem(@"举报");
    CYLDemoSettingGroup *group6 = CYLDemoCreateSettingGroup(nil, nil, @[report]);
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObjectsFromArray:@[group1, group2, group3, group4, group5, group6]];
    return data;
}

- (NSMutableArray *)chatDetailDataByGroupInfo:(AVIMConversation *)groupInfo {
    CYLDemoSettingItem *users = CYLDemoCreateSettingItem(@"users");
    users.type = CYLDemoSettingItemTypeOther;
    CYLDemoSettingItem *allUsers = CYLDemoCreateSettingItem(([NSString stringWithFormat:@"全部群成员(%ld)", (long)groupInfo.members.count]));
    CYLDemoSettingGroup *group1 = CYLDemoCreateSettingGroup(nil, nil, (@[users, allUsers]));
    
    CYLDemoSettingItem *groupName = CYLDemoCreateSettingItem(@"群聊名称");
    groupName.subTitle = groupInfo.name;
    CYLDemoSettingItem *groupQR = CYLDemoCreateSettingItem(@"群二维码");
    groupQR.rightImagePath = @"mine_cell_myQR";
    CYLDemoSettingItem *groupPost = CYLDemoCreateSettingItem(@"群公告");
    //TODO:
//    if (groupInfo.post.length > 0) {
//        groupPost.subTitle = groupInfo.post;
//    }
//    else {
        groupPost.subTitle = @"未设置";
//    }
    CYLDemoSettingItem *groupManagement = CYLDemoCreateSettingItem(@"群管理");
    CYLDemoSettingGroup *group2 = CYLDemoCreateSettingGroup(nil, nil, (@[groupName, groupQR, groupPost, groupManagement]));
    
    CYLDemoSettingItem *screen = CYLDemoCreateSettingItem(@"消息免打扰");
    screen.type = CYLDemoSettingItemTypeSwitch;
    screen.isSwithOn = groupInfo.muted;
    
    CYLDemoSettingItem *top = CYLDemoCreateSettingItem(@"置顶聊天");
    top.type = CYLDemoSettingItemTypeSwitch;
    CYLDemoSettingItem *save = CYLDemoCreateSettingItem(@"保存到通讯录");
    save.type = CYLDemoSettingItemTypeSwitch;
    CYLDemoSettingGroup *group3 = CYLDemoCreateSettingGroup(nil, nil, (@[screen, top, save]));
    
    CYLDemoSettingItem *myNikeName = CYLDemoCreateSettingItem(@"我在本群的昵称");
    NSString *nickName = nil;
    NSString *currentUserClientId = [CYLChatKit sharedInstance].clientId;
    [[CYLChatKit sharedInstance] getCachedProfileIfExists:currentUserClientId name:&nickName avatarURL:nil error:nil];
    myNikeName.subTitle = nickName ?: currentUserClientId;
    CYLDemoSettingItem *showOtherNikeName = CYLDemoCreateSettingItem(@"显示群成员昵称");
    showOtherNikeName.type = CYLDemoSettingItemTypeSwitch;
    CYLDemoSettingGroup *group4 = CYLDemoCreateSettingGroup(nil, nil, (@[myNikeName, showOtherNikeName]));
    
    CYLDemoSettingItem *chatFile = CYLDemoCreateSettingItem(@"聊天文件");
    CYLDemoSettingItem *chatHistory = CYLDemoCreateSettingItem(@"查找聊天内容");
    CYLDemoSettingItem *chatBG = CYLDemoCreateSettingItem(@"设置当前聊天背景");
    CYLDemoSettingItem *report = CYLDemoCreateSettingItem(@"举报");
    CYLDemoSettingGroup *group5 = CYLDemoCreateSettingGroup(nil, nil, (@[chatFile, chatHistory, chatBG, report]));
    
    CYLDemoSettingItem *clear = CYLDemoCreateSettingItem(@"清空聊天记录");
    clear.showDisclosureIndicator = NO;
    CYLDemoSettingGroup *group6 = CYLDemoCreateSettingGroup(nil, nil, @[clear]);
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObjectsFromArray:@[group1, group2, group3, group4, group5, group6]];
    return data;
}

@end
