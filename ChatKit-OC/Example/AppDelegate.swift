//
//  AppDelegate.swift
//  ChatKit-OC
//
//  Translated from Objective-C (AppDelegate.h/.m and main.m). `@main` replaces main.m.
//

import UIKit
import UserNotifications
import AVOSCloud
import AVOSCloudIM
import CYLChatKit
import CYLTabBarController

// TODO: CHANGE TO YOUR OWN AppId and AppKey
private let CYLDemoAPPID = "dYRQ8YfHRiILshUnfFJu2eQM-gzGzoHsz"
private let CYLDemoAPPKEY = "ye24iIK6ys8IvaISMC4Bs5WK"

@main
@objc(AppDelegate)
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // The Objective-C plus button registered itself in `+load`; Swift has no `+load`, so register it here, before
        // any tab bar controller is created.
        CYLDemoPlusButtonSubclass.register()
        registerForRemoteNotification()
        customizeNavigationBar()
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let loginViewController = CYLDemoLoginViewController(nibName: "CYLDemoLoginViewController", bundle: Bundle.main)
        loginViewController.autoLogin = true
        loginViewController.setClientIDHandler { [weak self] clientID in
            CYLDemoUtil.showProgressText("open client ...", duration: 10.0)
            CYLDemoChatKitExample.invokeThisMethodAfterLoginSuccess(withClientId: clientID, success: {
                CYLDemoUtil.hideProgress()
                let tabBarControllerConfig = CYLDemoTabBarControllerConfig()
                self?.window?.rootViewController = tabBarControllerConfig.tabBarController
            }, failed: { error in
                CYLDemoUtil.hideProgress()
                NSLog("%@", String(describing: error))
            })
        }

        // Outside China, enable the North America node. It must be called before the app id is set, otherwise the
        // China node is used.
        // AVOSCloud.setServiceRegion(.US)
        // ChatKit is UI only. Plug in the LeanCloud IM backend before starting ChatKit.
        CYLChatKit.sharedInstance().imProvider = CYLDemoLeanCloudIMProvider()
        CYLChatKit.setAppId(CYLDemoAPPID, appKey: CYLDemoAPPKEY)
        // Enable unread notifications.
        AVIMClient.setUnreadNotificationEnabled(true)
        AVIMClient.setTimeoutIntervalInSeconds(20)
        // Plugins at the bottom of the input box. To change an icon or title, subclass and call `+registerSubclass`.
        CYLInputViewPluginTakePhoto.registerSubclass()
        CYLInputViewPluginPickImage.registerSubclass()
        CYLInputViewPluginLocation.registerSubclass()

        window.rootViewController = loginViewController
        showScreenForScreenshotIfRequested()
        window.backgroundColor = UIColor.white
        window.makeKeyAndVisible()
        dumpAccessibilityIfRequested()
        return true
    }

    // MARK: - Accessibility dump

    /// `-CYLDemoAccessibilityDump YES` writes what VoiceOver would find on the screen, element by element, to
    /// Documents/accessibility.txt a few seconds after launch. CI (scripts/demo-screenshots.sh) prints that file next to
    /// each screenshot, so a run shows the accessibility labels, hints, and identifiers and not only the pixels.
    private func dumpAccessibilityIfRequested() {
        guard UserDefaults.standard.bool(forKey: "CYLDemoAccessibilityDump") else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            guard let self = self else {
                return
            }
            // Walk every visible window of the app, the key window first: the screen on display is not always
            // `self.window` (the first CI run of the Swift demo wrote an empty dump from it).
            var windows = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .filter { !$0.isHidden }
            if let appWindow = self.window, !appWindow.isHidden, !windows.contains(appWindow) {
                windows.append(appWindow)
            }
            windows.sort { $0.isKeyWindow && !$1.isKeyWindow }
            var dump = ""
            for window in windows {
                self.appendAccessibility(of: window, depth: 0, to: &dump)
            }
            if dump.isEmpty {
                for window in windows {
                    self.appendViewTree(of: window, depth: 0, to: &dump)
                }
                // Diagnostics for CI: say what was walked instead of writing an empty file.
                dump = "(no accessibility elements; windows: \(windows.count))\n"
                    + windows.map { "  \(NSStringFromClass(type(of: $0))) key=\($0.isKeyWindow) alpha=\($0.alpha) "
                        + "subviews=\($0.subviews.count) root=\($0.rootViewController.map { NSStringFromClass(type(of: $0)) } ?? "nil")\n" }
                    .joined()
            }
            let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            let path = (directory as NSString).appendingPathComponent("accessibility.txt")
            try? dump.write(toFile: path, atomically: true, encoding: .utf8)
        }
    }

    /// Diagnostics when nothing was found: the raw view tree with the properties that decide the walk.
    private func appendViewTree(of view: UIView, depth: Int, to dump: inout String) {
        guard depth < 14 else { return }
        dump += String(repeating: " ", count: depth * 2)
            + "\(NSStringFromClass(type(of: view))) hidden=\(view.isHidden) alpha=\(view.alpha) "
            + "axElement=\(view.isAccessibilityElement) axHidden=\(view.accessibilityElementsHidden) "
            + "axElements=\(view.accessibilityElements?.count ?? -1) id=\"\(view.accessibilityIdentifier ?? "")\"\n"
        for subview in view.subviews {
            appendViewTree(of: subview, depth: depth + 1, to: &dump)
        }
    }

    /// Walks like VoiceOver: an accessibility element ends the walk; a container lists its `accessibilityElements`, any
    /// other view its visible subviews.
    private func appendAccessibility(of object: NSObject, depth: Int, to dump: inout String) {
        if let view = object as? UIView {
            if view.isHidden || view.alpha < 0.01 || view.accessibilityElementsHidden {
                return
            }
        }
        let indent = String(repeating: " ", count: depth * 2)
        if object.isAccessibilityElement {
            let identifier = (object as? UIAccessibilityIdentification)?.accessibilityIdentifier ?? ""
            let traits = String(object.accessibilityTraits.rawValue, radix: 16)
            dump += "\(indent)\(NSStringFromClass(type(of: object))) label=\"\(object.accessibilityLabel ?? "")\" "
                + "value=\"\(object.accessibilityValue ?? "")\" hint=\"\(object.accessibilityHint ?? "")\" "
                + "id=\"\(identifier)\" traits=0x\(traits)\n"
            return
        }
        // A container's `accessibilityElements` and a view's subviews are both walked (each object once). On the macOS 26
        // simulator a window's `accessibilityElements` can hold objects that end the walk, so subviews alone are not
        // replaced by them any more.
        var children: [NSObject] = (object.accessibilityElements ?? []).compactMap { $0 as? NSObject }
        if let view = object as? UIView {
            for subview in view.subviews where !children.contains(where: { $0 === subview }) {
                children.append(subview)
            }
        }
        for child in children {
            appendAccessibility(of: child, depth: depth + 1, to: &dump)
        }
    }

    // MARK: - Screenshot hook

    /// CI screenshots (scripts/demo-screenshots.sh) launch the app with `-CYLDemoScreen <name>` to show ChatKit's UI
    /// without logging in to the IM service, which a CI runner cannot rely on:
    /// - `conversations`: the tab bar with the conversation list.
    /// - `chat`: a conversation screen with the chat input bar.
    /// `-CYLDemoText <text>` (with `chat`) types that text into the input field without opening the keyboard.
    /// `-CYLDemoKeyboard YES` (with `chat`) then focuses the input field next to the 发送 (send) button, the same as
    /// tapping it, so the keyboard comes up and the screenshot shows the chat bar sitting on it.
    /// Without the argument the app starts at the login screen as usual.
    private func showScreenForScreenshotIfRequested() {
        guard let screen = UserDefaults.standard.string(forKey: "CYLDemoScreen"), !screen.isEmpty else {
            return
        }
        let tabBarControllerConfig = CYLDemoTabBarControllerConfig()
        let tabBarController = tabBarControllerConfig.tabBarController
        window?.rootViewController = tabBarController
        if screen == "chat" {
            if let firstViewController = tabBarController.viewControllers?.first as? UINavigationController,
               let conversationViewController = CYLConversationViewController(peerId: "Jerry") {
                firstViewController.pushViewController(conversationViewController, animated: false)
                if let demoText = UserDefaults.standard.string(forKey: "CYLDemoText"), !demoText.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        conversationViewController.chatBar.append(demoText, beginInputing: false)
                    }
                }
                if UserDefaults.standard.bool(forKey: "CYLDemoKeyboard") {
                    // The chat bar is opened in -viewDidAppear:, so wait until the screen is up.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        conversationViewController.chatBar.beginInputing()
                    }
                }
            }
        }
    }

    // MARK: - Remote notifications

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AVOSCloud.handleRemoteNotifications(withDeviceToken: deviceToken)
    }

    private func customizeNavigationBar() {
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.white,
        ]
        UINavigationBar.appearance().barTintColor = NAVIGATION_COLOR
        UINavigationBar.appearance().isTranslucent = false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        CYLChatKit.sharedInstance().syncBadge()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CYLChatKit.sharedInstance().syncBadge()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if application.applicationState == .active {
            // A push received in the foreground can only be a normal push, not an offline message push.
        } else {
            // When the push content is changed by https://github.com/leancloud/leanchat-cloudcode the payload has
            // `aps` (alert, badge, sound) and `convid`.
            CYLChatKit.sharedInstance().didReceiveRemoteNotification(userInfo)
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return true
    }

    // MARK: - UNUserNotificationCenter

    /// Registers for remote notifications.
    private func registerForRemoteNotification() {
        // CI screenshots (scripts/demo-screenshots.sh) pass -CYLDemoScreenshots YES so the permission alert does not
        // cover the screen.
        if UserDefaults.standard.bool(forKey: "CYLDemoScreenshots") {
            return
        }
        // The deployment target is iOS 15, so the iOS 10+ path is the only one.
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            NSLog("%@", granted ? "授权成功" : "授权失败")
        }
        center.getNotificationSettings { settings in
            NSLog("%@", "\(settings)")
            // notDetermined: no choice yet; denied: not authorized; authorized: authorized.
            if settings.authorizationStatus == .notDetermined {
                NSLog("未选择")
            } else if settings.authorizationStatus == .denied {
                NSLog("未授权")
            } else if settings.authorizationStatus == .authorized {
                NSLog("已授权")
            }
        }
    }

    /// Required for iOS 10+: a notification arrives in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if notification.request.trigger is UNPushNotificationTrigger {
            // TODO: handle the remote push content
            NSLog("%@", "\(userInfo)")
        }
        // Choose whether to alert the user: badge, sound, or alert.
        completionHandler(.alert)
    }

    /// Required for iOS 10+: the user taps a notification (in the background or before launch).
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.trigger is UNPushNotificationTrigger {
            // TODO: handle the remote push content
            NSLog("%@", "\(userInfo)")
        }
        completionHandler()
    }

    /// Required for iOS 7+.
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // TODO: handle the remote push content
        NSLog("%@", "\(userInfo)")
        // Must be called when finished.
        completionHandler(.newData)
    }

    /// Also used in iOS 10.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("[无法注册远程提醒, 错误信息]\n-----\n%@\n\n", "\(error)")
    }
}
