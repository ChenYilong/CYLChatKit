//
//  CYLDemoUtil.swift
//  ChatKit-OC
//
//  Translated from Objective-C.
//

import UIKit
import CYLChatKit
import MBProgressHUD
import TWMessageBarManager

@objc(CYLDemoUtil)
final class CYLDemoUtil: NSObject {

    private class func applicationWindow() -> UIWindow? {
        return UIApplication.shared.delegate?.window ?? nil
    }

    class func errorWithText(_ text: String) -> NSError {
        let code = 0
        let errorInfo: [String: Any] = [
            "code": code,
            NSLocalizedDescriptionKey: text,
        ]
        return NSError(domain: "LeanCloudChatKitExample", code: code, userInfo: errorInfo)
    }

    class func showProgressText(_ text: String?, duration: TimeInterval) {
        let hud = MBProgressHUD.showAdded(to: applicationWindow(), animated: true)
        hud?.detailsLabelFont = UIFont.systemFont(ofSize: 14)
        hud?.detailsLabelText = text
        hud?.margin = 10
        hud?.removeFromSuperViewOnHide = true
        hud?.mode = .indeterminate
        hud?.hide(true, afterDelay: duration)
    }

    class func showProgress() {
        MBProgressHUD.showAdded(to: applicationWindow(), animated: true)
    }

    class func hideProgress() {
        MBProgressHUD.hide(for: applicationWindow(), animated: true)
    }

    /// Shows a notification with the default CYLChatKit style. Replace it with the notification style of your app.
    class func showNotification(withTitle title: String?, subtitle: String?, type: CYLMessageNotificationType, duration: CGFloat) {
        let barType: TWMessageBarMessageType
        switch type {
        case .error:
            barType = .error
        case .success:
            barType = .success
        case .warning:
            barType = .info
        case .message:
            barType = .info
        @unknown default:
            barType = .info
        }
        TWMessageBarManager.sharedInstance().showMessage(withTitle: title,
                                                         description: subtitle,
                                                         type: barType,
                                                         duration: duration,
                                                         callback: nil)
    }

    class func showNotification(withTitle title: String?, subtitle: String?, type: CYLMessageNotificationType) {
        showNotification(withTitle: title, subtitle: subtitle, type: type, duration: 1.0)
    }

    class func hideNotification() {
        TWMessageBarManager.sharedInstance().hideAll()
    }
}
