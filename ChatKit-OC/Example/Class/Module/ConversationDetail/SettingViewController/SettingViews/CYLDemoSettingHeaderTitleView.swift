//
//  CYLDemoSettingHeaderTitleView.swift
//  Translated from Objective-C.
//

import UIKit

@objc(CYLDemoSettingHeaderTitleView)
class CYLDemoSettingHeaderTitleView: UITableViewHeaderFooterView {

    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = UIFont.cylDemoFontSettingHeaderAndFooterTitle()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var text: String? {
        didSet {
            titleLabel.text = text
        }
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        installTitleLabelConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentView.addSubview(titleLabel)
        installTitleLabelConstraints()
    }

    /// Header layout: pinned to the bottom. The footer subclass overrides this to pin to the top.
    func installTitleLabelConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5.0)
        ])
    }
}
