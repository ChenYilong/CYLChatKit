//
//  CYLDemoPlusButtonSubclass.swift
//  ChatKit-OC
//
//  Translated from Objective-C (CYLDemoPlusButtonSubclass.h/.m).
//  The Objective-C class registered itself in `+load`, which Swift does not have: call
//  `CYLDemoPlusButtonSubclass.registerPlusButton()` once at launch, before the tab bar controller is created
//  (AppDelegate does it).
//

import UIKit
import CYLChatKit
import CYLTabBarController

@objc(CYLDemoPlusButtonSubclass)
final class CYLDemoPlusButtonSubclass: CYLPlusButton, CYLPlusButtonSubclassing {

    // MARK: - CYLPlusButtonSubclassing

    /// Creates a custom button without title; the tab bar puts it in its center.
    static func plusButton() -> Any {
        let buttonImage = UIImage(named: "tabbar_compose_button")
        let highlightImage = UIImage(named: "tabbar_compose_button_highlighted")
        let iconImage = UIImage(named: "tabbar_compose_icon_add")
        let highlightIconImage = UIImage(named: "tabbar_compose_icon_add")

        let button = CYLDemoPlusButtonSubclass(type: .custom)

        button.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleTopMargin]
        let size = buttonImage?.size ?? .zero
        button.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        button.setImage(iconImage, for: .normal)
        button.setImage(highlightIconImage, for: .highlighted)
        button.setBackgroundImage(buttonImage, for: .normal)
        button.setBackgroundImage(highlightImage, for: .highlighted)
        button.addTarget(button, action: #selector(CYLDemoPlusButtonSubclass.clickPublish), for: .touchUpInside)

        return button
    }

    // MARK: - Event Response

    @objc func clickPublish() {
        CYLDemoChatKitExample.exampleOpenConversationViewController(
            withConversaionId: "570da6a9daeb3a63ca5b07b0",
            fromNavigationController: nil)
    }
}
