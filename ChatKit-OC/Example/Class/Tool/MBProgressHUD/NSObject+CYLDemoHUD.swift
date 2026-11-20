//
//  NSObject+CYLDemoHUD.swift
//  ChatKit-OC
//
//  Translated from Objective-C. Only the members the demo calls are kept; the instance helpers
//  (alert, toast, network indicator, ...) and the text/icon-only variants were not called anywhere.
//

import UIKit
import MBProgressHUD

// Normally 2 seconds.
private let cylDemoHUDTime: TimeInterval = 2.0
private let cylDemoHUDSuccessMessageTime: TimeInterval = 0.3
private let cylDemoHUDFailureMessageTime: TimeInterval = 0.3

extension NSObject {

    // MARK: - Success and error, disappear after a moment

    class func showSuccess(_ success: String?) {
        showText(success, icon: "success.png", view: nil, afterDelay: cylDemoHUDSuccessMessageTime)
    }

    class func showSuccess(_ success: String?, toView view: UIView?) {
        showText(success, icon: "success.png", view: view, afterDelay: cylDemoHUDSuccessMessageTime)
    }

    class func showError(_ error: String?) {
        showText(error, icon: "error.png", view: nil, afterDelay: cylDemoHUDFailureMessageTime)
    }

    class func showError(_ error: String?, toView view: UIView?) {
        showText(error, icon: "error.png", view: view, afterDelay: cylDemoHUDFailureMessageTime)
    }

    // MARK: - HUD

    /// Shows only the spinner (must be hidden by the caller, the HUD sits in the window).
    @discardableResult
    class func showHUD() -> MBProgressHUD? {
        return showMessage(nil, toView: nil)
    }

    /// Shows the spinner and a text (must be hidden by the caller, the HUD sits in the window).
    @discardableResult
    class func showMessage(_ message: String?) -> MBProgressHUD? {
        return showMessage(message, toView: nil)
    }

    /// Shows the spinner and a text in `view` (must be hidden by the caller).
    @discardableResult
    class func showMessage(_ message: String?, toView view: UIView?) -> MBProgressHUD? {
        guard let target = view ?? cylDemoRootWindowView() else {
            return nil
        }
        let hud = MBProgressHUD.showAdded(to: target, animated: true)
        hud?.labelText = message
        hud?.labelFont = UIFont.systemFont(ofSize: 22)
        hud?.removeFromSuperViewOnHide = true
        return hud
    }

    /// Hides the HUD in the window.
    class func hideHUD() {
        hideHUDForView(nil)
    }

    /// Hides the HUD in `view`.
    class func hideHUDForView(_ view: UIView?) {
        guard let target = view ?? cylDemoRootWindowView() else {
            return
        }
        MBProgressHUD.hide(for: target, animated: true)
    }

    // MARK: - Private

    private class func cylDemoRootWindowView() -> UIView? {
        return UIApplication.shared.windows.last
    }

    private class func showText(_ text: String?, icon: String, view: UIView?, afterDelay delay: TimeInterval) {
        guard let target = view ?? cylDemoRootWindowView() else {
            return
        }
        let hud = MBProgressHUD.showAdded(to: target, animated: true)
        hud?.labelText = text
        hud?.labelFont = UIFont.systemFont(ofSize: 22)
        hud?.customView = UIImageView(image: UIImage(named: "MBProgressHUD.bundle/\(icon)"))
        hud?.mode = .customView
        hud?.removeFromSuperViewOnHide = true
        hud?.hide(true, afterDelay: delay)
    }
}
