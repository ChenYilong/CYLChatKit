//
//  CYLDemoSingleConversationDetailViewController.swift
//  Translated from Objective-C.
//

import UIKit
import CYLChatKit
import CYLTabBarController
import AVOSCloudIM

@objc(CYLDemoSingleConversationDetailViewController)
final class CYLDemoSingleConversationDetailViewController: CYLDemoSettingViewController, CYLDemoUserGroupCellDelegate {

    private var helper: CYLDemoChatDetailHelper?
    private var cachedUser: CYLUserDelegate?
    private var cachedData: [CYLDemoSettingGroup]?

    private var user: CYLUserDelegate? {
        if let cachedUser = cachedUser {
            return cachedUser
        }
        if let peerId = conversation.cylPeerId() {
            cachedUser = (try? CYLChatKit.sharedInstance().getCachedProfilesIfExists([peerId]))?.first
        }
        return cachedUser
    }

    /// Lazily loaded data.
    override var data: [CYLDemoSettingGroup] {
        get {
            if cachedData == nil {
                cachedData = helper?.chatDetailData(bySingleInfo: conversation) ?? []
            }
            return cachedData ?? []
        }
        set {
            cachedData = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "聊天详情"

        helper = CYLDemoChatDetailHelper()

        tableView.register(CYLDemoUserGroupCell.self, forCellReuseIdentifier: "CYLDemoUserGroupCell")
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CYLDemoUserGroupCell.self)) as? CYLDemoUserGroupCell {
                if let user = user {
                    cell.users = [user]
                }
                cell.delegate = self
                return cell
            }
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = data[indexPath.section].object(at: indexPath.row)

        if item.title == "聊天文件" {
            // Not implemented in the demo.
        } else if item.title == "设置当前聊天背景" {
            present(pickerController, animated: true, completion: nil)
        } else if item.title == "清空聊天记录" {
            // Not implemented in the demo.
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func settingSwitchCell(forItem settingItem: CYLDemoSettingItem, didChangeStatus on: Bool, completionHandler: @escaping CYLDemoSettingSwitchCellCompletionhandler) {
        if settingItem.title == "消息免打扰" {
            _ = NSObject.showHUD()
            conversation.cylSetConversation(withMute: on) { [weak self] succeeded, error in
                completionHandler(succeeded, error)
                NSObject.hideHUD()
                guard let self = self else { return }
                if succeeded {
                    if let conversationId = self.conversation.conversationId {
                        CYLConversationService.sharedInstance().removeCache(forConversationId: conversationId)
                    }
                    NSObject.showSuccess(on ? "已设为静音" : "已设为提醒")
                } else {
                    NSObject.showSuccess("设置失败")
                }
            }
        } else {
            showUnhandledSwitchAlert(for: settingItem, on: on)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            let count = user != nil ? 1 : 0
            return CGFloat(((count + 1) / 4 + (((count + 1) % 4) == 0 ? 0 : 1)) * 90 + 15)
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    // MARK: - CYLDemoUserGroupCellDelegate

    func userGroupCellDidSelectUser(_ user: CYLUserDelegate) {
        let peerId = user.clientId
        guard let conversationViewController = CYLConversationViewController(peerId: peerId) else { return }
        cyl_pushOrPop(to: conversationViewController, animated: true) { viewControllers, completionHandler in
            var viewControllerPopTo: UIViewController?
            var shouldPop = false
            for obj in viewControllers {
                if let conversationVC = obj as? CYLConversationViewController, conversationVC.peerId == peerId {
                    viewControllerPopTo = conversationVC
                    shouldPop = true
                    break
                }
            }
            completionHandler(shouldPop, viewControllerPopTo, true, 0)
        }
    }

    func userGroupCellAddUserButtonDown(withOperationType operationType: CYLDemoConversationOperationType) {
        let currentClientID: String = CYLChatKit.sharedInstance().clientId
        switch operationType {
        case .none:
            break
        case .add:
            let allPersonIds = (CYLDemoContactManager.defaultManager().fetchContactPeerIds() as? [String]) ?? []
            presentSelectMemberViewControllerMemberIds(allPersonIds, excludedUserIds: conversation.members) { [weak self] peerIds, _ in
                guard let self = self else { return }
                var members: [String] = [currentClientID]
                if let peerClientId = self.user?.clientId {
                    members.append(peerClientId)
                }
                members.append(contentsOf: peerIds)
                CYLChatKit.sharedInstance().createConversation(withMembers: members, type: .group, unique: true) { [weak self] conversation, _ in
                    NSObject.hideHUD()
                    guard let self = self else { return }
                    if let conversation = conversation {
                        NSObject.showSuccess("创建对话成功")
                        self.cyl_popSelectTabBarChildViewController(at: 0) { selectedTabBarChildViewController in
                            guard let conversationViewController = CYLConversationViewController(conversationId: conversation.conversationId()) else { return }
                            selectedTabBarChildViewController.navigationController?.pushViewController(conversationViewController, animated: true)
                        }
                    } else {
                        NSObject.showError("创建对话失败")
                    }
                }
            }
        case .remove:
            break
        }
    }
}
