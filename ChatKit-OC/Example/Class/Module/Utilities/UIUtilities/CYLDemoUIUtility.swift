//
//  CYLDemoUIUtility.swift
//  ChatKit-OC
//
//  Translated from Objective-C. `captureScreenshotFromView` was not called anywhere and is not translated.
//

import UIKit

@objc(CYLDemoUIUtility)
final class CYLDemoUIUtility: NSObject {

    private static var heightLabel: UILabel?

    /// Returns the height that `text` needs in `width` points with `font`.
    class func getTextHeight(ofText text: String?, font: UIFont?, width: CGFloat) -> CGFloat {
        let label: UILabel
        if let existing = heightLabel {
            label = existing
        } else {
            label = UILabel(frame: UIScreen.main.bounds)
            label.numberOfLines = 0
            heightLabel = label
        }
        var frame = label.frame
        frame.size.width = width
        label.frame = frame
        label.font = font
        label.text = text
        return label.sizeThatFits(CGSize(width: width, height: CGFloat(Float.greatestFiniteMagnitude))).height
    }
}
