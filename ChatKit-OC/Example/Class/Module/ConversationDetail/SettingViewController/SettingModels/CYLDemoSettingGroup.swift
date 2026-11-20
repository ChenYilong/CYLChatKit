//
//  CYLDemoSettingGroup.swift
//  Translated from Objective-C.
//

import UIKit

func CYLDemoCreateSettingGroup(_ header: String?, _ footer: String?, _ items: [CYLDemoSettingItem]) -> CYLDemoSettingGroup {
    return CYLDemoSettingGroup.createGroup(withHeaderTitle: header, footerTitle: footer, items: items)
}

@objc(CYLDemoSettingGroup)
final class CYLDemoSettingGroup: NSObject {

    /// Section header title.
    var headerTitle: String? {
        didSet {
            headerHeight = CYLDemoUIUtility.getTextHeight(ofText: headerTitle, font: UIFont.cylDemoFontSettingHeaderAndFooterTitle(), width: UIScreen.main.bounds.size.width - 30)
        }
    }

    /// Section footer text.
    var footerTitle: String? {
        didSet {
            footerHeight = CYLDemoUIUtility.getTextHeight(ofText: footerTitle, font: UIFont.cylDemoFontSettingHeaderAndFooterTitle(), width: UIScreen.main.bounds.size.width - 30)
        }
    }

    /// Section items.
    var items: [CYLDemoSettingItem] = []

    private(set) var headerHeight: CGFloat = 0
    private(set) var footerHeight: CGFloat = 0

    var count: Int {
        return items.count
    }

    class func createGroup(withHeaderTitle headerTitle: String?, footerTitle: String?, items: [CYLDemoSettingItem]) -> CYLDemoSettingGroup {
        let group = CYLDemoSettingGroup()
        group.headerTitle = headerTitle
        group.footerTitle = footerTitle
        group.items = items
        return group
    }

    // MARK: - Public Methods

    func object(at index: Int) -> CYLDemoSettingItem {
        return items[index]
    }

    func index(of obj: CYLDemoSettingItem) -> Int {
        return items.firstIndex(where: { $0 === obj }) ?? NSNotFound
    }

    func remove(_ obj: CYLDemoSettingItem) {
        items.removeAll(where: { $0 === obj })
    }
}
