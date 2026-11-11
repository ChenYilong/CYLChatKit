//
//  CYLDemoTabBarControllerConfig.swift
//  ChatKit-OC
//
//  Translated from Objective-C (CYLDemoTabBarControllerConfig.h/.m).
//

import UIKit
import CYLChatKit
import CYLTabBarController

@objc(CYLDemoTabBarControllerConfig)
final class CYLDemoTabBarControllerConfig: NSObject {

    /// The tab bar controller, created on first access.
    private(set) lazy var tabBarController: CYLTabBarController = {
        let firstViewController = CYLConversationListViewController()
        let firstNavigationController = CYLChatBaseNavigationController(rootViewController: firstViewController)

        let secondViewController = CYLDemoContactListController()
        // Read the saved client id from the user defaults.
        let currentClientID = UserDefaults.standard.string(forKey: CYLDEMO_KEY_USERID)
        // No client ID is saved before the first login (and in CI screenshots).
        if let currentClientID = currentClientID, !currentClientID.isEmpty {
            secondViewController.excludedPersonIDs = [currentClientID]
        } else {
            secondViewController.excludedPersonIDs = []
        }
        let secondNavigationController = CYLChatBaseNavigationController(rootViewController: secondViewController)

        let tabBarController = CYLTabBarController()

        // Set the attributes of the tab bar items (title, image, selected image) before `-setViewControllers:`.
        setUpTabBarItemsAttributes(for: tabBarController)

        tabBarController.viewControllers = [
            firstNavigationController,
            secondNavigationController,
        ]
        // More tab bar customization: see `customizeTabBarAppearance()`.
        return tabBarController
    }()

    private func setUpTabBarItemsAttributes(for tabBarController: CYLTabBarController) {
        let dict1: [AnyHashable: Any] = [
            CYLTabBarItemTitle: CYLDemoExampleLocalizedString("tab.messages", "Messages"),
            CYLTabBarItemImage: "tabbar_chat_normal",
            CYLTabBarItemSelectedImage: "tabbar_chat_active",
        ]
        let dict2: [AnyHashable: Any] = [
            CYLTabBarItemTitle: CYLDemoExampleLocalizedString("tab.contacts", "Contacts"),
            CYLTabBarItemImage: "tabbar_contacts_normal",
            CYLTabBarItemSelectedImage: "tabbar_contacts_active",
        ]
        tabBarController.tabBarItemsAttributes = [dict1, dict2]
    }

    /// More tab bar customization: text attributes of selected and unselected items, selection background. Not used.
    static func customizeTabBarAppearance() {
        // Remove the shadow at the top of the tab bar.
        UITabBar.appearance().shadowImage = UIImage()

        // Text attributes of the normal state.
        let normalAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        // Text attributes of the selected state.
        let selectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        let tabBar = UITabBarItem.appearance()
        tabBar.setTitleTextAttributes(normalAttrs, for: .normal)
        tabBar.setTitleTextAttributes(selectedAttrs, for: .selected)

        // Background color of the selected item.
        UITabBar.appearance().selectionIndicatorImage = imageFromColor(
            UIColor(red: 26 / 255.0, green: 163 / 255.0, blue: 133 / 255.0, alpha: 1),
            forSize: CGSize(width: UIScreen.main.bounds.size.width / 5.0, height: 49),
            withCornerRadius: 0)
    }

    static func imageFromColor(_ color: UIColor, forSize size: CGSize, withCornerRadius radius: CGFloat) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(rect)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // A new image with the rounded corners.
        UIGraphicsBeginImageContext(size)
        UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
        image?.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
