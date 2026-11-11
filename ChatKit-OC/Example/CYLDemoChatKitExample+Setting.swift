//
//  CYLDemoChatKitExample+Setting.swift
//  ChatKit-OC
//
//  Translated from Objective-C (CYLDemoChatKitExample+Setting.h/.m).
//  Not translated (never called in the Objective-C demo, kept there only as commented-out examples): the signature
//  setup, the message filter, and the send-message hook. The MWPhotoBrowser preview was already commented out.
//

import UIKit
import CoreLocation
import AVOSCloudIM
import CYLChatKit
import CYLTabBarController

#if DEBUG
private func cylDemoLog(_ message: @autoclosure () -> String) {
    NSLog("%@", message())
}
#else
private func cylDemoLog(_ message: @autoclosure () -> String) {}
#endif

extension CYLDemoChatKitExample {

    /// Initial settings.
    func cylDemoSetting() {
        // Set up the user system.
        cylDemoSetFetchProfiles()
        // Set up the conversation list.
        cylDemoSetupConversationsList()
        // Set up the conversation.
        cylDemoSetupConversation()
        // Other settings.
        cylDemoSetupOther()
        cylDemoMemberInfoChanged()
    }

    private func cylDemoSetupConversationsList() {
        // Operations on the cells of the conversation list.
        cylDemoSetupConversationsCellOperation()
        // Custom cell menu.
        cylDemoSetupConversationEditActionForConversationList()
    }

    private func cylDemoSetupConversation() {
        // What happens when a conversation opens.
        cylDemoSetupOpenConversation()
        cylDemoSetupConversationInvalidedHandler()
        cylDemoSetupLoadLatestMessages()
        cylDemoSetupLongPressMessage()
    }

    private func cylDemoSetupOther() {
        cylDemoSetupForceReconect()
        cylDemoSetupHud()
        cylDemoSetupOpenProfile()
        cylDemoSetupNotification()
        cylDemoSetupPreviewLocationMessage()
    }

    // MARK: - User system

    /// ChatKit calls this block whenever it needs the user information for user ids.
    /// TODO: CHANGE TO YOUR OWN USER SYSTEM. Without this block ChatKit cannot show avatars and nicknames. The loop
    /// below simulates a synchronous query of the users for the user ids; replace it with a call to your app's API.
    private func cylDemoSetFetchProfiles() {
        CYLChatKit.sharedInstance().fetchProfilesBlock = { userIds, completionHandler in
            guard let userIds = userIds, !userIds.isEmpty else {
                let code = 0
                let errorReasonText = "User ids is nil"
                let errorInfo: [String: Any] = [
                    "code": code,
                    NSLocalizedDescriptionKey: errorReasonText,
                ]
                let error = NSError(domain: NSStringFromClass(CYLDemoChatKitExample.self), code: code, userInfo: errorInfo)
                completionHandler?(nil, error)
                return
            }
            var users: [CYLUserDelegate] = []
            for clientId in userIds {
                if let user = CYLDemoContactProfiles.first(where: { $0[CYLDemoProfileKeyPeerId] == clientId }) {
                    let avatarURL = URL(string: user[CYLDemoProfileKeyAvatarURL] ?? "")
                    let user_ = CYLDemoUser(userId: user[CYLDemoProfileKeyPeerId] ?? "",
                                            name: user[CYLDemoProfileKeyName] ?? "",
                                            avatarURL: avatarURL,
                                            clientId: clientId)
                    users.append(user_)
                } else {
                    // If the network request fails, provide at least the client id.
                    users.append(CYLDemoUser(clientId: clientId))
                }
            }
            // IMPORTANT: the completion handler must be called once the user information has been fetched.
            completionHandler?(users, nil)
        }
    }

    // MARK: - Conversation list

    private func cylDemoSetupConversationEditActionForConversationList() {
        // Custom cell menu.
        CYLChatKit.sharedInstance().conversationEditActionBlock = { [weak self] indexPath, _, conversation, controller in
            guard let self = self, let conversation = conversation, let controller = controller else {
                return []
            }
            return self.cylDemoExampleConversationEditAction(at: indexPath, conversation: conversation, controller: controller)
        }
    }

    /// What happens when a cell of the conversation list is selected or deleted.
    private func cylDemoSetupConversationsCellOperation() {
        CYLChatKit.sharedInstance().setDidSelectConversationsListCellBlock { _, conversation, controller in
            CYLDemoChatKitExample.exampleOpenConversationViewController(
                withConversaionId: conversation?.conversationId() ?? "",
                fromNavigationController: controller?.navigationController)
        }
        // Called after a conversation is deleted (usually nothing to do).
        CYLChatKit.sharedInstance().setDidDeleteConversationsListCellBlock { _, _, _ in
            // TODO:
        }
    }

    // MARK: - Conversation

    /// What happens when a conversation opens.
    private func cylDemoSetupOpenConversation() {
        CYLChatKit.sharedInstance().fetchConversationHandler = { conversation, aConversationController in
            guard let conversation = conversation, let aConversationController = aConversationController else {
                return
            }
            // Return when the conversation has no creation date.
            if conversation.createAt() == nil {
                return
            }
            _ = CYLDemoChatKitExample.showMessage("加载历史记录...", toView: aConversationController.view)
            let members = conversation.members() ?? []
            // More than two members: a group chat, with the group profile button and its action.
            if members.count > 2 {
                aConversationController.configureBarButtonItem(style: .groupProfile) { viewController, _, _ in
                    let groupConversationDetailViewController = CYLDemoGroupConversationDetailViewController()
                    groupConversationDetailViewController.conversation = (conversation as! AVIMConversation)
                    viewController?.navigationController?.pushViewController(groupConversationDetailViewController, animated: true)
                }
            } else if members.count == 2 { // A single chat, with the single profile button and its action.
                aConversationController.configureBarButtonItem(style: .singleProfile) { viewController, _, _ in
                    let currentClientId = CYLChatKit.sharedInstance().clientId ?? ""
                    let peerId = members.filter { $0 != currentClientId }[0]
                    CYLChatKit.sharedInstance().getProfileInBackground(forUserId: peerId) { _, _ in
                        let singleConversationDetailViewController = CYLDemoSingleConversationDetailViewController()
                        singleConversationDetailViewController.conversation = (conversation as! AVIMConversation)
                        viewController?.navigationController?.pushViewController(singleConversationDetailViewController, animated: true)
                    }
                }
            }
            // System conversations and transient chat rooms have no members and need separate handling, see
            // https://leancloud.cn/docs/realtime_v2.html#%E7%B3%BB%E7%BB%9F%E5%AF%B9%E8%AF%9D_System_Conversation_
        }
    }

    /// What happens when a conversation becomes invalid.
    private func cylDemoSetupConversationInvalidedHandler() {
        CYLChatKit.sharedInstance().conversationInvalidedHandler = { _, conversationController, administrator, error in
            let nsError = error as NSError?
            if nsError?.code == 4401 {
                // Runs when the current user is kicked out of the group, or is not in the group and `enableAutoJoin` is off.
                conversationController?.navigationController?.popToRootViewController(animated: true)
                let title = "进群失败！"
                let subTitle = "请联系管理员\(administrator?.name ?? administrator?.clientId ?? "(null)")"
                cylDemoLog(nsError?.description ?? "")
                CYLDemoUtil.showNotification(withTitle: title, subtitle: subTitle, type: .error)
            } else if nsError?.code == 4304 {
                conversationController?.navigationController?.popToRootViewController(animated: true)
                let title = "群已满，普通群人数上限为500"
                let subTitle = "暂态聊天室无人数限制"
                CYLDemoUtil.showNotification(withTitle: title, subtitle: subTitle, type: .error)
            }
        }
    }

    /// What happens when the latest messages are loaded.
    private func cylDemoSetupLoadLatestMessages() {
        CYLChatKit.sharedInstance().loadLatestMessagesHandler = { conversationController, _, _ in
            CYLDemoChatKitExample.hideHUDForView(conversationController?.view)
            // The notification about loading the history stays off (`__OPTIMIZE__` was defined in the demo).
        }
    }

    /// Long press menu of a message.
    private func cylDemoSetupLongPressMessage() {
        CYLChatKit.sharedInstance().longPressMessageBlock = { [weak self] message, userInfo in
            guard let message = message else {
                return []
            }
            let mediaType = message.mediaType
            let isNormalMediaTypeMessage = (mediaType == .text ||
                                            mediaType == .image ||
                                            mediaType == .audio ||
                                            mediaType == .video ||
                                            mediaType == .location ||
                                            mediaType == .file)
            let ownerTypeValue = (userInfo?["CYLLongPressMessageUserInfoKeyMessageOwner"] as? NSNumber)?.uintValue ?? 0
            let ownerType = CYLMessageOwnerType(rawValue: ownerTypeValue) ?? .unknown
            let fromController = userInfo?["CYLLongPressMessageUserInfoKeyFromController"] as? CYLConversationViewController
            let messageCell = userInfo?["CYLLongPressMessageUserInfoKeyMessageCell"] as? CYLChatMessageCell

            var menuItems: [CYLMenuItem] = []

            if mediaType == .text {
                let copyItem = CYLMenuItem(title: CYLLocalizedStringForKey("copy"), block: {
                    UIPasteboard.general.string = message.text
                })!
                menuItems.append(copyItem)
                if let fromController = fromController, ownerType == .mine {
                    let modifyItem = CYLMenuItem(title: CYLLocalizedStringForKey("modify"), block: {
                        let alert = UIAlertController(title: "\(CYLLocalizedStringForKey("modify"))?", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: CYLLocalizedStringForKey("cancel"), style: .cancel, handler: { _ in }))
                        alert.addTextField { textField in
                            textField.text = messageCell?.message.text
                        }
                        let modifyAction = UIAlertAction(title: CYLLocalizedStringForKey("modify"), style: .default, handler: { _ in
                            guard let oldMessage = messageCell?.message, let messageCell = messageCell else {
                                return
                            }
                            let newMessage = CYLMessage(text: alert.textFields?[0].text,
                                                        senderId: oldMessage.senderId,
                                                        sender: oldMessage.sender,
                                                        timestamp: oldMessage.timestamp,
                                                        serverMessageId: oldMessage.serverMessageId)
                            fromController.modifyMessage(messageCell, newMessage: newMessage, callback: { succeeded, _ in
                                if succeeded {
                                    cylDemoLog("消息修改成功")
                                }
                            })
                        })
                        alert.addAction(modifyAction)
                        fromController.present(alert, animated: true, completion: nil)
                    })!
                    menuItems.append(modifyItem)
                }
            }

            if let fromController = fromController, isNormalMediaTypeMessage {
                let transpondItem = CYLMenuItem(title: CYLLocalizedStringForKey("transpond"), block: {
                    self?.cylDemoTranspondMessage(message, toConversationViewController: fromController)
                })!
                menuItems.append(transpondItem)
            }

            if let fromController = fromController, ownerType == .mine, isNormalMediaTypeMessage {
                let recallItem = CYLMenuItem(title: CYLLocalizedStringForKey("recall"), block: {
                    guard let messageCell = messageCell else {
                        return
                    }
                    fromController.recallMessage(messageCell, callback: { succeeded, _ in
                        if succeeded {
                            cylDemoLog("消息撤回成功")
                        }
                    })
                })!
                menuItems.append(recallItem)
            }

            return menuItems
        }
    }

    // MARK: - Other settings

    /// Badge of the conversation list tab. Not used: the tab bar style sets the badge itself.
    private func cylDemoSetupBadge() {
        CYLChatKit.sharedInstance().markBadgeWithTotalUnreadCountBlock = { [weak self] totalUnreadCount, controller in
            self?.cylDemoExampleMarkBadge(withTotalUnreadCount: totalUnreadCount, controller: controller)
        }
    }

    /// Forced reconnect.
    private func cylDemoSetupForceReconect() {
        CYLChatKit.sharedInstance().forceReconnectSessionBlock = { aError, granted, viewController, completionHandler in
            let isSingleSignOnOffline = ((aError as NSError?)?.code == 4111)
            if !isSingleSignOnOffline {
                return
            }
            // The user allows the reconnect request: reconnect or force the login.
            if granted {
                let title = "正在重连聊天服务..."
                // Read the saved client id from the user defaults.
                let clientId = UserDefaults.standard.string(forKey: CYLDEMO_KEY_USERID) ?? ""
                _ = CYLDemoChatKitExample.showMessage(title, toView: viewController?.view)
                CYLChatKit.sharedInstance().open(withClientId: clientId, force: granted, callback: { succeeded, error in
                    CYLDemoChatKitExample.hideHUDForView(viewController?.view)
                    // The completion handler shows the HUD that says the reconnect worked.
                    completionHandler?(succeeded, error)
                })
                return
            }

            // After a single sign-on kick the user has to log in again: back to the login screen.
            CYLDemoChatKitExample.cylDemoClearLocalClientInfo()
            let loginViewController = CYLDemoLoginViewController()
            loginViewController.setClientIDHandler { clientID in
                CYLDemoUtil.showProgressText("open client ...", duration: 10.0)
                CYLDemoChatKitExample.invokeThisMethodAfterLoginSuccess(withClientId: clientID, success: {
                    CYLDemoUtil.hideProgress()
                    let tabBarControllerConfig = CYLDemoTabBarControllerConfig()
                    UIApplication.shared.keyWindow?.rootViewController = tabBarControllerConfig.tabBarController
                }, failed: { error in
                    CYLDemoUtil.hideProgress()
                    NSLog("%@", String(describing: error))
                })
            }
            CYLDemoChatKitExample.cylDemoTryPresentViewControllerViewController(loginViewController)
            // The completion handler shows the reconnect HUD; it is not needed here.
            completionHandler?(true, nil)
        }
    }

    /// HUDs of the various situations.
    private func cylDemoSetupHud() {
        CYLChatKit.sharedInstance().hudActionBlock = { _, view, title, type in
            switch type {
            case .show:
                _ = CYLDemoChatKitExample.showMessage(title, toView: view)
            case .hide:
                CYLDemoChatKitExample.hideHUDForView(view)
            case .error:
                CYLDemoChatKitExample.showError(title, toView: view)
            case .success:
                CYLDemoChatKitExample.showSuccess(title, toView: view)
            }
        }
    }

    /// Opening a user profile.
    private func cylDemoSetupOpenProfile() {
        CYLChatKit.sharedInstance().openProfileBlock = { [weak self] userId, user, parentController in
            guard let userId = userId else {
                CYLDemoUtil.showNotification(withTitle: "用户不存在", subtitle: nil, type: .error)
                return
            }
            self?.cylDemoExampleOpenProfile(forUser: user, userId: userId, parentController: parentController)
        }
    }

    /// Round avatars. Not used.
    private func cylDemoSetupAvatarImageCornerRadius() {
        CYLChatKit.sharedInstance().avatarImageViewCornerRadiusBlock = { avatarImageViewSize in
            if avatarImageViewSize.height > 0 {
                return avatarImageViewSize.height / 2
            }
            return 5
        }
    }

    /// Notifications of ChatKit.
    private func cylDemoSetupNotification() {
        CYLChatKit.sharedInstance().showNotificationBlock = { _, title, subtitle, type in
            CYLDemoUtil.showNotification(withTitle: title, subtitle: subtitle, type: type)
        }
    }

    /// Previewing a location.
    private func cylDemoSetupPreviewLocationMessage() {
        CYLChatKit.sharedInstance().previewLocationMessageBlock = { [weak self] location, geolocations, _ in
            self?.cylDemoExamplePreViewLocationMessage(with: location, geolocations: geolocations)
        }
    }

    // MARK: - private

    private func cylDemoExampleOpenProfile(forUser user: CYLUserDelegate?,
                                           userId: String,
                                           parentController: UIViewController?) {
        let currentClientId = CYLChatKit.sharedInstance().clientId
        var title = "打开用户主页 \nClientId是 : \(userId)"
        var subtitle = "name是 : \(user?.name ?? "(null)")"
        if userId == currentClientId {
            title = "打开自己的主页 \nClientId是 : \(userId)"
            subtitle = "我自己的name是 : \(user?.name ?? "(null)")"
        } else if parentController is CYLConversationViewController {
            let conversationViewController = CYLConversationViewController(peerId: user?.clientId ?? userId)!
            CYLDemoChatKitExample.cylDemoPush(conversationViewController, from: parentController)
            return
        }
        CYLDemoUtil.showNotification(withTitle: title, subtitle: subtitle, type: .message)
    }

    private func cylDemoExamplePreViewLocationMessage(with location: CLLocation?, geolocations: String?) {
        let title = "打开地理位置：\(geolocations ?? "(null)")"
        let latitude = location?.coordinate.latitude ?? 0
        let longitude = location?.coordinate.longitude ?? 0
        let subTitle = "纬度：\(latitude)\n经度：\(longitude)"
        CYLDemoUtil.showNotification(withTitle: title, subtitle: subTitle, type: .message)
    }

    /// Sets the unread count badge of the conversation list tab.
    private func cylDemoExampleMarkBadge(withTotalUnreadCount totalUnreadCount: Int, controller: UIViewController?) {
        if totalUnreadCount > 0 {
            var badgeValue = "\(totalUnreadCount)"
            if totalUnreadCount > 99 {
                badgeValue = CYLBadgeTextForNumberGreaterThanLimit
            }
            controller?.tabBarItem.badgeValue = badgeValue
            UIApplication.shared.applicationIconBadgeNumber = totalUnreadCount
        } else {
            controller?.tabBarItem.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    static func cylDemoExampleChangeGroupAvatarURLs(forConversationId conversationId: String, shouldInsert: Bool) {
    }

    /// Custom menu of a conversation of the list.
    private func cylDemoExampleConversationEditAction(at indexPath: IndexPath,
                                                      conversation: CYLConversationProtocol,
                                                      controller: CYLConversationListViewController) -> [UITableViewRowAction] {
        // Edit here to customize the menu of other conversations.
        return cylDemoRightButtons(at: indexPath, conversation: conversation, controller: controller)
    }

    private func cylDemoRightButtons(at indexPath: IndexPath,
                                     conversation: CYLConversationProtocol,
                                     controller: CYLConversationListViewController) -> [UITableViewRowAction] {
        let conversationId = conversation.conversationId() ?? ""
        let actionItemMore = UITableViewRowAction(style: .default, title: "标记为已读") { _, _ in
            controller.tableView.setEditing(false, animated: true)
            CYLChatKit.sharedInstance().updateUnreadCountToZero(withConversationId: conversationId)
        }
        actionItemMore.backgroundColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1.0)
        let actionItemDelete = UITableViewRowAction(style: .default, title: "删除") { _, _ in
            CYLChatKit.sharedInstance().deleteRecentConversation(withConversationId: conversationId)
        }
        let actionItemChangeGroupAvatar = UITableViewRowAction(style: .default, title: "改群头像") { _, _ in
            CYLDemoChatKitExample.cylDemoExampleChangeGroupAvatarURLs(forConversationId: conversationId, shouldInsert: false)
        }
        actionItemChangeGroupAvatar.backgroundColor = UIColor(red: 251 / 255.0, green: 186 / 255.0, blue: 11 / 255.0, alpha: 1.0)
        if conversation.cyl_type() == .single {
            return [actionItemDelete, actionItemMore]
        }
        return [actionItemDelete, actionItemMore, actionItemChangeGroupAvatar]
    }

    // MARK: - Navigation

    static func cylDemoPush(_ toViewController: UIViewController, from fromViewController: UIViewController?) {
        var fromViewController = fromViewController
        if fromViewController == nil {
            fromViewController = sharedInstance().cyl_tabBarController?.selectedViewController
        }
        _ = fromViewController?.cyl_popSelectTabBarChildViewController(at: 0, completion: { selectedChildTabBarController in
            selectedChildTabBarController.navigationController?.pushViewController(toViewController, animated: true)
        })
    }

    static func cylDemoPushToViewController(_ viewController: UIViewController) {
        cylDemoPush(viewController, from: nil)
    }

    static func cylDemoTryPresentViewControllerViewController(_ viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }
        var rootViewController = UIApplication.shared.delegate?.window??.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.visibleViewController
        }
        rootViewController?.dismiss(animated: false, completion: nil)
        rootViewController?.present(viewController, animated: true, completion: nil)
    }

    // MARK: - Clear client information

    static func cylDemoClearLocalClientInfo() {
        // Save in the user defaults.
        let defaultsSet = UserDefaults.standard
        defaultsSet.removeObject(forKey: CYLDEMO_KEY_USERID)
        defaultsSet.synchronize()
    }

    private func cylDemoTranspondMessage(_ message: CYLMessage, toConversationViewController conversationViewController: CYLConversationViewController) {
        cylDemoLog("消息转发")
    }

    // MARK: - Member Info Changed

    private func cylDemoMemberInfoChanged() {
        CYLChatKit.sharedInstance().setMemberInfoChangedBlock { conversation, byClientId, clientId, role in
            var roleString = "Member"
            if role == AVIMConversationMemberRole.owner.rawValue {
                roleString = "Owner"
            } else if role == AVIMConversationMemberRole.manager.rawValue {
                roleString = "Manager"
            }
            cylDemoLog("conversation id: \(conversation?.conversationId() ?? "(null)"), by client id: \(byClientId ?? "(null)"), client id: \(clientId ?? "(null)"), role: \(roleString)")
        }
    }
}
