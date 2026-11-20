//
//  CYLDemoSettingItem.swift
//  Translated from Objective-C.
//

import Foundation

enum CYLDemoSettingItemType: Int {
    case defalut = 0
    case titleButton
    case `switch`
    case other
}

func CYLDemoCreateSettingItem(_ title: String?) -> CYLDemoSettingItem {
    return CYLDemoSettingItem.createItem(withTitle: title)
}

@objc(CYLDemoSettingItem)
final class CYLDemoSettingItem: NSObject {

    var title: String?
    var subTitle: String?
    /// Local image name shown on the right.
    var rightImagePath: String?
    /// Remote image URL shown on the right.
    var rightImageURL: String?
    /// Whether the disclosure indicator is shown (default true).
    var showDisclosureIndicator: Bool = true
    /// Disables the highlight (default false).
    var disableHighlight: Bool = false
    var isSwithOn: Bool = false
    var type: CYLDemoSettingItemType = .defalut

    class func createItem(withTitle title: String?) -> CYLDemoSettingItem {
        let item = CYLDemoSettingItem()
        item.title = title
        return item
    }

    func cellClassName() -> String? {
        switch type {
        case .defalut:
            return NSStringFromClass(CYLDemoSettingCell.self)
        case .titleButton:
            return NSStringFromClass(CYLDemoSettingButtonCell.self)
        case .switch:
            return NSStringFromClass(CYLDemoSettingSwitchCell.self)
        case .other:
            return nil
        }
    }
}
