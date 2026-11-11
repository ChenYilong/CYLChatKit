//
//  CYLDemoSettingButtonCell.swift
//  Translated from Objective-C.
//

import UIKit

@objc(CYLDemoSettingButtonCell)
final class CYLDemoSettingButtonCell: UITableViewCell {

    var item: CYLDemoSettingItem? {
        didSet {
            textLabel?.text = item?.title
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.textAlignment = .center
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        textLabel?.textAlignment = .center
    }
}
