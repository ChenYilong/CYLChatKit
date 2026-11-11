//
//  CYLDemoChatKitExample.swift
//  ChatKit-OC
//
//  Translated from Objective-C (CYLDemoChatKitExample.h/.m).
//

import UIKit
import CYLChatKit
import CYLTabBarController

#if DEBUG
private func cylDemoLog(_ message: @autoclosure () -> String) {
    NSLog("%@", message())
}
#else
private func cylDemoLog(_ message: @autoclosure () -> String) {}
#endif

/// Glue code between the app and ChatKit: login, logout, and the screens ChatKit opens.
@objc(CYLDemoChatKitExample)
final class CYLDemoChatKitExample: NSObject {

    // MARK: - SDK Life Control

    /// Called before the user logs out.
    static func invokeThisMethodBeforeLogoutSuccess(_ success: (() -> Void)?, failed: ((Error?) -> Void)?) {
        let kit = CYLChatKit.sharedInstance()!
        kit.removeAllCachedProfiles()
        kit.close(callback: { succeeded, error in
            if succeeded {
                self.cylDemoClearLocalClientInfo()
                CYLDemoUtil.showNotification(withTitle: "退出成功", subtitle: nil, type: .success)
                success?()
            } else {
                CYLDemoUtil.showNotification(withTitle: "退出失败", subtitle: nil, type: .error)
                failed?(error)
            }
        })
    }

    /// Called after the user logs in.
    static func invokeThisMethodAfterLoginSuccess(withClientId clientId: String,
                                                  success: (() -> Void)?,
                                                  failed: ((Error?) -> Void)?) {
        sharedInstance().exampleInit()
        CYLChatKit.sharedInstance().open(withClientId: clientId, callback: { succeeded, error in
            if succeeded {
                self.saveLocalClientInfo(clientId)
                success?()
            } else {
                CYLDemoUtil.showNotification(withTitle: "登陆失败", subtitle: nil, type: .error)
                failed?(error)
            }
        })
    }

    static func invokeThisMethod(in application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if application.applicationState == .active {
            // A push received in the foreground can only be a normal push, not an offline message push.
        } else {
            CYLChatKit.sharedInstance().didReceiveRemoteNotification(userInfo)
        }
    }

    // MARK: - init Method

    /// Example of the initial setup.
    func exampleInit() {
        cylDemoSetting()
    }

    // MARK: - Other Method

    static func exampleChangeGroupAvatarURLs(forConversationId conversationId: String) {
        cylDemoExampleChangeGroupAvatarURLs(forConversationId: conversationId, shouldInsert: true)
    }

    /// Creates a group conversation.
    static func exampleCreateGroupConversation(from fromViewController: UIViewController) {
        // FIXME: add more to allPersonIds
        let kit = CYLChatKit.sharedInstance()!
        let allPersonIds = CYLDemoContactManager.defaultManager().fetchContactPeerIds().compactMap { $0 as? String }
        let users: [CYLUserDelegate] = (try? kit.getCachedProfilesIfExists(allPersonIds, shouldSameCount: true)) ?? []
        // ChatKit's contact list takes `CYLContact` objects.
        let contacts = Set(users.map {
            CYLContact(userId: $0.userId, name: $0.name, avatarURL: $0.avatarURL, clientId: $0.clientId)
        })
        let currentClientID = kit.clientId ?? ""
        let contactListViewController = CYLContactListViewController(
            contacts: contacts,
            userIds: Set(allPersonIds),
            excludedUserIds: Set([currentClientID]),
            mode: .multipleSelection)
        contactListViewController.title = "创建群聊"
        contactListViewController.setSelectedContactsCallback { viewController, peerIds in
            if peerIds.isEmpty {
                return
            }
            _ = self.showMessage("创建群聊...", toView: fromViewController.view)
            kit.createConversation(withMembers: peerIds, type: .group, unique: true, callback: { conversation, _ in
                self.hideHUDForView(fromViewController.view)
                if let conversation = conversation {
                    self.showSuccess("创建成功", toView: fromViewController.view)
                    self.exampleOpenConversationViewController(
                        withConversaionId: conversation.conversationId() ?? "",
                        fromNavigationController: viewController.navigationController)
                } else {
                    self.showError("创建失败", toView: fromViewController.view)
                }
            })
        }
        let navigationViewController = UINavigationController(rootViewController: contactListViewController)
        fromViewController.present(navigationViewController, animated: true, completion: nil)
    }

    /// Opens a single chat.
    static func exampleOpenConversationViewController(withPeerId peerId: String,
                                                      fromNavigationController navigationController: UINavigationController?) {
        let conversationViewController = CYLConversationViewController(peerId: peerId)!
        conversationViewController.setViewWillDisappearBlock { viewController, _ in
            self.hideHUDForView(viewController?.view)
        }
        cylDemoPushToViewController(conversationViewController)
    }

    /// Opens a conversation, a group chat or a single chat.
    static func exampleOpenConversationViewController(withConversaionId conversationId: String,
                                                      fromNavigationController navigationController: UINavigationController?) {
        let conversationViewController = CYLConversationViewController(conversationId: conversationId)!
        conversationViewController.enableAutoJoin = true
        conversationViewController.setViewWillDisappearBlock { viewController, _ in
            self.hideHUDForView(viewController?.view)
        }
        conversationViewController.setViewWillAppearBlock { _, animated in
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: animated)
        }
        cylDemoPushToViewController(conversationViewController)
    }

    static func signOut(from viewController: UIViewController) {
        CYLDemoUtil.showProgressText("close client ...", duration: 10.0)
        CYLDemoChatKitExample.invokeThisMethodBeforeLogoutSuccess({
            CYLDemoUtil.hideProgress()
            let loginViewController = CYLDemoLoginViewController()
            loginViewController.setClientIDHandler { clientID in
                CYLDemoChatKitExample.invokeThisMethodAfterLoginSuccess(withClientId: clientID, success: {
                    let tabBarControllerConfig = CYLDemoTabBarControllerConfig()
                    sharedInstance().cyl_tabBarController?.rootWindow().rootViewController = tabBarControllerConfig.tabBarController
                }, failed: { error in
                    cylDemoLog("\(String(describing: error))")
                })
            }
            viewController.present(loginViewController, animated: true, completion: nil)
        }, failed: { error in
            CYLDemoUtil.hideProgress()
            cylDemoLog("\(String(describing: error))")
        })
    }

    func exampleOpenProfile(forUser user: CYLUserDelegate?,
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
            CYLDemoChatKitExample.cylDemoPushToViewController(conversationViewController)
            return
        }
        CYLDemoUtil.showNotification(withTitle: title, subtitle: subtitle, type: .message)
    }

    // MARK: - Private Methods

    /// The shared instance of CYLDemoChatKitExample.
    static let sharedInstanceStorage = CYLDemoChatKitExample()

    static func sharedInstance() -> CYLDemoChatKitExample {
        return sharedInstanceStorage
    }

    private static func saveLocalClientInfo(_ clientId: String) {
        // Save the client id in the user defaults.
        let defaultsSet = UserDefaults.standard
        defaultsSet.set(clientId, forKey: CYLDEMO_KEY_USERID)
        defaultsSet.synchronize()
        let subtitle = "User Id 是 : \(clientId)"
        CYLDemoUtil.showNotification(withTitle: "登陆成功", subtitle: subtitle, type: .success)
    }
}
