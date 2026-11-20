//
//  CYLDemoChatDetailHelper.swift
//  Translated from Objective-C.
//

import Foundation
import CYLChatKit
import AVOSCloudIM

@objc(CYLDemoChatDetailHelper)
final class CYLDemoChatDetailHelper: NSObject {

    func chatDetailData(bySingleInfo singleInfo: AVIMConversation) -> [CYLDemoSettingGroup] {
        let users = CYLDemoCreateSettingItem("users")
        users.type = .other
        let group1 = CYLDemoCreateSettingGroup(nil, nil, [users])

        let top = CYLDemoCreateSettingItem("置顶聊天")
        top.type = .switch
        let screen = CYLDemoCreateSettingItem("消息免打扰")
        screen.type = .switch
        screen.isSwithOn = singleInfo.muted
        let group2 = CYLDemoCreateSettingGroup(nil, nil, [top, screen])

        let chatFile = CYLDemoCreateSettingItem("聊天文件")
        let group3 = CYLDemoCreateSettingGroup(nil, nil, [chatFile])

        let chatBG = CYLDemoCreateSettingItem("设置当前聊天背景")
        let chatHistory = CYLDemoCreateSettingItem("查找聊天内容")
        let group4 = CYLDemoCreateSettingGroup(nil, nil, [chatBG, chatHistory])

        let clear = CYLDemoCreateSettingItem("清空聊天记录")
        clear.showDisclosureIndicator = false
        let group5 = CYLDemoCreateSettingGroup(nil, nil, [clear])

        let report = CYLDemoCreateSettingItem("举报")
        let group6 = CYLDemoCreateSettingGroup(nil, nil, [report])

        return [group1, group2, group3, group4, group5, group6]
    }

    func chatDetailData(byGroupInfo groupInfo: AVIMConversation) -> [CYLDemoSettingGroup] {
        let users = CYLDemoCreateSettingItem("users")
        users.type = .other
        let allUsers = CYLDemoCreateSettingItem("全部群成员(\(groupInfo.members?.count ?? 0))")
        let group1 = CYLDemoCreateSettingGroup(nil, nil, [users, allUsers])

        let groupName = CYLDemoCreateSettingItem("群聊名称")
        groupName.subTitle = groupInfo.name
        let groupQR = CYLDemoCreateSettingItem("群二维码")
        groupQR.rightImagePath = "mine_cell_myQR"
        let groupPost = CYLDemoCreateSettingItem("群公告")
        // TODO: show the real group post once the conversation exposes it.
        groupPost.subTitle = "未设置"
        let groupManagement = CYLDemoCreateSettingItem("群管理")
        let group2 = CYLDemoCreateSettingGroup(nil, nil, [groupName, groupQR, groupPost, groupManagement])

        let screen = CYLDemoCreateSettingItem("消息免打扰")
        screen.type = .switch
        screen.isSwithOn = groupInfo.muted

        let top = CYLDemoCreateSettingItem("置顶聊天")
        top.type = .switch
        let save = CYLDemoCreateSettingItem("保存到通讯录")
        save.type = .switch
        let group3 = CYLDemoCreateSettingGroup(nil, nil, [screen, top, save])

        let myNikeName = CYLDemoCreateSettingItem("我在本群的昵称")
        var nickName: NSString?
        let currentUserClientId: String? = CYLChatKit.sharedInstance().clientId
        if let clientId = currentUserClientId {
            CYLChatKit.sharedInstance().getCachedProfileIfExists(clientId, name: &nickName, avatarURL: nil, error: nil)
        }
        myNikeName.subTitle = (nickName as String?) ?? currentUserClientId
        let showOtherNikeName = CYLDemoCreateSettingItem("显示群成员昵称")
        showOtherNikeName.type = .switch
        let group4 = CYLDemoCreateSettingGroup(nil, nil, [myNikeName, showOtherNikeName])

        let chatFile = CYLDemoCreateSettingItem("聊天文件")
        let chatHistory = CYLDemoCreateSettingItem("查找聊天内容")
        let chatBG = CYLDemoCreateSettingItem("设置当前聊天背景")
        let report = CYLDemoCreateSettingItem("举报")
        let group5 = CYLDemoCreateSettingGroup(nil, nil, [chatFile, chatHistory, chatBG, report])

        let clear = CYLDemoCreateSettingItem("清空聊天记录")
        clear.showDisclosureIndicator = false
        let group6 = CYLDemoCreateSettingGroup(nil, nil, [clear])

        return [group1, group2, group3, group4, group5, group6]
    }
}
