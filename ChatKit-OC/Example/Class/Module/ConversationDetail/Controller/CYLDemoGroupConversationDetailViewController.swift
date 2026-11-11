//
//  CYLDemoGroupConversationDetailViewController.swift
//  Translated from Objective-C.
//

import UIKit
import CYLChatKit
import CYLTabBarController
import AVOSCloudIM

@objc(CYLDemoGroupConversationDetailViewController)
final class CYLDemoGroupConversationDetailViewController: CYLDemoSettingViewController, CYLDemoUserGroupCellDelegate, CYLDemoProfileNameEditViewControllerDelegate {

    private var helper: CYLDemoChatDetailHelper?
    private var cachedData: [CYLDemoSettingGroup]?

    /// Lazily loaded data.
    override var data: [CYLDemoSettingGroup] {
        get {
            if cachedData == nil {
                cachedData = helper?.chatDetailData(byGroupInfo: conversation) ?? []
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

        tableView.register(CYLDemoUserGroupCell.self, forCellReuseIdentifier: NSStringFromClass(CYLDemoUserGroupCell.self))
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CYLDemoUserGroupCell.self)) as? CYLDemoUserGroupCell {
                let users: [CYLUserDelegate] = (try? CYLChatKit.sharedInstance().getCachedProfilesIfExists(conversation.members ?? [])) ?? []
                cell.users = users
                cell.delegate = self
                cell.collectionView.reloadData()
                return cell
            }
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = data[indexPath.section].object(at: indexPath.row)
        if item.title == "群聊名称" {
            let isCreater = conversation.cyl_isCreaterForCurrentUser()
            let tooManyMembers = (conversation.members?.count ?? 0) > 5
            if tooManyMembers && !isCreater {
                var creatorNickname: NSString?
                if let creator = conversation.creator {
                    _ = try? CYLChatKit.sharedInstance().getCachedProfileIfExists(creator, name: &creatorNickname, avatarURL: nil)
                }
                let title = "当前群聊人数较多，只有群主\((creatorNickname as String?) ?? conversation.creator ?? "(null)")才能修改群名称"
                presentSimpleAlert(title: nil, message: title, buttonTitle: "我知道了")
                return
            }
            let profileNameEditViewController = CYLDemoProfileNameEditViewController()
            profileNameEditViewController.title = "群聊名称"
            profileNameEditViewController.delegate = self
            profileNameEditViewController.placeholderName = conversation.name
            navigationController?.pushViewController(profileNameEditViewController, animated: true)
        } else if item.title == "群二维码" {
            // Not implemented in the demo.
        } else if item.title == "设置当前聊天背景" {
            present(pickerController, animated: true, completion: nil)
        } else if item.title == "聊天文件" {
            // Not implemented in the demo.
        } else if item.title == "清空聊天记录" {
            // Not implemented in the demo.
        } else if item.title == "群管理" {
            let vc = CYLDemoGroupConversationManagementViewController(style: .grouped)
            vc.conversation = conversation
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            var count = conversation.members?.count ?? 0
            if cyl_isCreatorForCurrentGroupConversaton() {
                count += 1
            }
            return CGFloat(((count + 1) / 4 + (((count + 1) % 4) == 0 ? 0 : 1)) * 90 + 15)
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func settingSwitchCell(forItem settingItem: CYLDemoSettingItem, didChangeStatus on: Bool, completionHandler: @escaping CYLDemoSettingSwitchCellCompletionhandler) {
        if settingItem.title == "消息免打扰" {
            _ = NSObject.showHUD()
            conversation.cyl_setConversationWithMute(on) { [weak self] succeeded, error in
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

    // MARK: - CYLDemoUserGroupCellDelegate

    func userGroupCellDidSelectUser(_ user: CYLUserDelegate) {
        let currentClientID: String? = CYLChatKit.sharedInstance().clientId
        if currentClientID == user.clientId {
            return
        }
        let peerId = user.clientId
        let conversationViewController = CYLConversationViewController(peerId: peerId)
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
        switch operationType {
        case .none:
            break
        case .add:
            let allPersonIds = (CYLDemoContactManager.defaultManager().fetchContactPeerIds() as? [String]) ?? []
            presentSelectMemberViewControllerMemberIds(allPersonIds, excludedUserIds: conversation.members) { [weak self] peerIds, _ in
                guard let self = self else { return }
                self.addAndCacheMembers(withClientIds: peerIds) { [weak self] succeeded, _ in
                    NSObject.hideHUD()
                    guard let self = self else { return }
                    if succeeded {
                        self.cachedData = nil
                        NSObject.showSuccess("添加成功")
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    } else {
                        NSObject.showError("添加失败")
                    }
                }
            }
        case .remove:
            presentSelectMemberViewControllerMemberIds(conversation.members ?? [], excludedUserIds: nil) { [weak self] peerIds, _ in
                guard let self = self else { return }
                self.conversation.removeMembers(withClientIds: peerIds) { [weak self] succeeded, _ in
                    NSObject.hideHUD()
                    guard let self = self else { return }
                    if succeeded {
                        NSObject.showSuccess("移除成功")
                        self.cachedData = nil
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    } else {
                        NSObject.showError("移除失败")
                    }
                }
            }
        }
    }

    func addAndCacheMembers(withClientIds clientIds: [String], callback: ((Bool, Error?) -> Void)?) {
        conversation.addMembers(withClientIds: clientIds) { succeeded, error in
            if succeeded {
                CYLUserSystemService.sharedInstance().cacheUsers(withIds: Set(clientIds.map { AnyHashable($0) })) { succeeded, error in
                    callback?(succeeded, error)
                }
            } else {
                callback?(succeeded, error)
            }
        }
    }

    // MARK: - CYLDemoProfileNameEditViewControllerDelegate

    func profileNameDidChanged(_ name: String) {
        _ = NSObject.showHUD()
        // FIXME: updating the group name is not implemented (same as the Objective-C demo).
    }
}
